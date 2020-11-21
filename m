Content-Type: multipart/mixed; boundary="===============0148574277519319792=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] pem: Decrypt PKCS#1 encrypted private keys
Date: Sat, 21 Nov 2020 03:48:31 +0100
Message-ID: <20201121024834.76213-2-andrew.zaborowski@intel.com>
In-Reply-To: <20201121024834.76213-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0148574277519319792==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/pem.c | 306 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 284 insertions(+), 22 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 99020b1..c76af1b 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -31,6 +31,7 @@
 #include <unistd.h>
 #include <sys/mman.h>
 #include <strings.h>
+#include <ctype.h>
 =

 #include "util.h"
 #include "private.h"
@@ -194,7 +195,8 @@ const char *pem_next(const void *buf, size_t buf_len, c=
har **type_label,
 }
 =

 static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
-				char **type_label, size_t *len)
+				char **out_type_label, size_t *out_len,
+				char **out_headers)
 {
 	size_t base64_len;
 	const char *base64;
@@ -206,9 +208,50 @@ static uint8_t *pem_load_buffer(const void *buf, size_=
t buf_len,
 	if (!base64)
 		return NULL;
 =

-	ret =3D l_base64_decode(base64, base64_len, len);
+	if (memchr(base64, ':', base64_len)) {
+		const char *start;
+		const char *end;
+
+		while (base64_len && isspace(*base64)) {
+			base64++;
+			base64_len--;
+		}
+
+		start =3D base64;
+
+		if (!(end =3D memmem(start, base64_len, "\n\n", 2)) &&
+				!(end =3D memmem(start, base64_len, "\n\r\n", 3)))
+			return NULL;
+
+		/* Check that each header line has a key and a colon */
+		while (start < end) {
+			const char *lf =3D rawmemchr(start, '\n');
+			const char *colon =3D memchr(start, ':', lf - start);
+
+			if (!colon)
+				return NULL;
+
+			for (; start < colon; start++)
+				if (isalnum(*start))
+					break;
+
+			if (start =3D=3D colon)
+				return NULL;
+
+			start =3D lf + 1;
+		}
+
+		if (out_headers)
+			*out_headers =3D l_strndup(base64, end - base64);
+
+		base64_len -=3D end + 2 - base64;
+		base64 =3D end + 2;
+	} else if (out_headers)
+		*out_headers =3D NULL;
+
+	ret =3D l_base64_decode(base64, base64_len, out_len);
 	if (ret) {
-		*type_label =3D label;
+		*out_type_label =3D label;
 		return ret;
 	}
 =

@@ -220,7 +263,7 @@ static uint8_t *pem_load_buffer(const void *buf, size_t=
 buf_len,
 LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
 					char **type_label, size_t *out_len)
 {
-	return pem_load_buffer(buf, buf_len, type_label, out_len);
+	return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
 }
 =

 struct pem_file_info {
@@ -260,8 +303,8 @@ static void pem_file_close(struct pem_file_info *info)
 	close(info->fd);
 }
 =

-LIB_EXPORT uint8_t *l_pem_load_file(const char *filename,
-					char **type_label, size_t *len)
+static uint8_t *pem_load_file(const char *filename, char **out_type_label,
+				size_t *out_len, char **out_headers)
 {
 	struct pem_file_info file;
 	uint8_t *result;
@@ -273,11 +316,17 @@ LIB_EXPORT uint8_t *l_pem_load_file(const char *filen=
ame,
 		return NULL;
 =

 	result =3D pem_load_buffer(file.data, file.st.st_size,
-					type_label, len);
+					out_type_label, out_len, out_headers);
 	pem_file_close(&file);
 	return result;
 }
 =

+LIB_EXPORT uint8_t *l_pem_load_file(const char *filename,
+					char **out_type_label, size_t *out_len)
+{
+	return pem_load_file(filename, out_type_label, out_len, NULL);
+}
+
 static struct l_certchain *pem_list_to_chain(struct l_queue *list)
 {
 	struct l_certchain *chain;
@@ -391,10 +440,167 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_li=
st(const char *filename)
 	return list;
 }
 =

+#define SKIP_WHITESPACE(str)	\
+	while (isspace(*(str)))	\
+		(str)++;
+
+static const char *parse_rfc1421_dek_info(char *headers,
+						const char **out_params)
+{
+	const char *proc_type =3D NULL;
+	char *dek_info =3D NULL;
+	char *comma;
+
+	while (headers) {
+		char *lf =3D strchrnul(headers, '\n');
+		char *key;
+
+		key =3D headers;
+		SKIP_WHITESPACE(key);
+		headers =3D (*lf =3D=3D '\n') ? lf + 1 : NULL;
+
+		if (!memcmp(key, "X-", 2))
+			key +=3D 2;
+
+		if (!memcmp(key, "Proc-Type:", 10)) {
+			if (proc_type)
+				return NULL;
+
+			proc_type =3D key + 10;
+			SKIP_WHITESPACE(proc_type);
+		} else if (!memcmp(key, "DEK-Info:", 9)) {
+			if (dek_info)
+				return NULL;
+
+			dek_info =3D key + 9;
+			SKIP_WHITESPACE(dek_info);
+		} else
+			continue;
+
+		while (isspace(lf[-1]))
+			lf--;
+
+		*lf =3D '\0';
+	}
+
+	if (!proc_type || !dek_info)
+		return NULL;
+
+	/* Skip the version field (should be 3 or 4) */
+	proc_type =3D strchr(proc_type, ',');
+	if (!proc_type)
+		return NULL;
+
+	proc_type++;
+	SKIP_WHITESPACE(proc_type);
+
+	/* Section 4.6.1.1 */
+	if (strcmp(proc_type, "ENCRYPTED"))
+		return NULL;
+
+	comma =3D strchr(dek_info, ',');
+	if (comma) {
+		*out_params =3D comma + 1;
+		SKIP_WHITESPACE(*out_params);
+
+		while (comma > dek_info && isspace(comma[-1]))
+			comma--;
+
+		*comma =3D '\0';
+	} else
+		*out_params =3D NULL;
+
+	return dek_info;
+}
+
+static struct l_cipher *cipher_from_dek_info(const char *algid, const char=
 *params,
+						const char *passphrase,
+						size_t *block_len)
+{
+	enum l_cipher_type type;
+	struct l_cipher *cipher;
+	struct l_checksum *md5;
+	uint8_t key[32];
+	size_t key_len;
+	bool ok;
+	L_AUTO_FREE_VAR(uint8_t *, iv) =3D NULL;
+	size_t iv_len;
+
+	if (!strcmp(algid, "DES-CBC")) {
+		type =3D L_CIPHER_DES_CBC;
+		key_len =3D 8;
+		iv_len =3D 8;
+	} else if (!strcmp(algid, "DES-EDE3-CBC")) {
+		type =3D L_CIPHER_DES3_EDE_CBC;
+		key_len =3D 24;
+		iv_len =3D 8;
+	} else if (!strcmp(algid, "AES-128-CBC")) {
+		type =3D L_CIPHER_AES_CBC;
+		key_len =3D 16;
+		iv_len =3D 16;
+	} else if (!strcmp(algid, "AES-192-CBC")) {
+		type =3D L_CIPHER_AES_CBC;
+		key_len =3D 24;
+		iv_len =3D 16;
+	} else if (!strcmp(algid, "AES-256-CBC")) {
+		type =3D L_CIPHER_AES_CBC;
+		key_len =3D 32;
+		iv_len =3D 16;
+	} else
+		return NULL;
+
+	if (!params || strlen(params) !=3D 2 * iv_len)
+		return NULL;
+
+	*block_len =3D iv_len;
+
+	iv =3D l_util_from_hexstring(params, &iv_len);
+	if (!iv)
+		return NULL;
+
+	/*
+	 * The encryption key is the MD5(password | IV[:8]), this comes from
+	 * opessl's crypto/evp/evp_key.c:EVP_BytesToKey() and doesn't seem to
+	 * be backed by any standard:
+	 * https://web.archive.org/web/20190528100132/https://latacora.singles/20=
18/08/03/the-default-openssh.html
+	 */
+	md5 =3D l_checksum_new(L_CHECKSUM_MD5);
+	if (!md5)
+		return NULL;
+
+	ok =3D l_checksum_update(md5, passphrase, strlen(passphrase)) &&
+		l_checksum_update(md5, iv, 8) &&
+		l_checksum_get_digest(md5, key, 16) =3D=3D 16;
+
+	if (ok && key_len > 16) {
+		l_checksum_reset(md5);
+		ok =3D l_checksum_update(md5, key, 16) &&
+			l_checksum_update(md5, passphrase, strlen(passphrase)) &&
+			l_checksum_update(md5, iv, 8) &&
+			l_checksum_get_digest(md5, key + 16, 16) =3D=3D 16;
+	}
+
+	l_checksum_free(md5);
+
+	if (!ok)
+		return NULL;
+
+	cipher  =3D l_cipher_new(type, key, key_len);
+	if (!cipher)
+		return NULL;
+
+	if (l_cipher_set_iv(cipher, iv, iv_len))
+		return cipher;
+
+	l_cipher_free(cipher);
+	return NULL;
+}
+
 static struct l_key *pem_load_private_key(uint8_t *content,
 						size_t len,
 						char *label,
 						const char *passphrase,
+						char *headers,
 						bool *encrypted)
 {
 	struct l_key *pkey =3D NULL;
@@ -405,8 +611,13 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 	 * the PKCS#8/RFC5958 PrivateKeyInfo structure -- supported
 	 * directly by the pkcs8-key-parser kernel module.
 	 */
-	if (!strcmp(label, "PRIVATE KEY"))
+	if (!strcmp(label, "PRIVATE KEY")) {
+		/* RFC822 Headers explicitly disallowed in RFC7468 */
+		if (headers)
+			goto err;
+
 		goto done;
+	}
 =

 	/*
 	 * RFC7468 Section 11-compatible encrypted private key label
@@ -429,6 +640,10 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 		if (!passphrase)
 			goto err;
 =

+		/* RFC822 Headers explicitly disallowed in RFC7468 */
+		if (headers)
+			goto err;
+
 		/* Technically this is BER, not limited to DER */
 		key_info =3D asn1_der_find_elem(content, len, 0, &tag,
 						&key_info_len);
@@ -486,18 +701,10 @@ static struct l_key *pem_load_private_key(uint8_t *co=
ntent,
 	}
 =

 	/*
-	 * Legacy RSA private key label aka. SSLeay format label, created
-	 * by most software but not documented in an RFC.  Encodes the
+	 * Legacy RSA private key label aka. SSLeay format, understood by
+	 * most software but not documented in an RFC.  Encodes the
 	 * PKCS#1/RFC8017 RSAPrivateKey structure.  We wrap it in a PKCS#8
 	 * PrivateKeyInfo for the pkcs8-key-parser module.
-	 *
-	 * TODO: decrypt RSA PRIVATE KEY format encrypted keys
-	 * as produced by "openssl rsa" commands.  These are incompatible
-	 * with RFC7468 parsing because of the RFC822 headers present
-	 * before base64-encoded data.  The format is documented in
-	 * RFC1421 and the encryption algorithms in RFC1423 although
-	 * openssl allows many more algorithms than those documented.
-	 * Then wrap in a PrivateKeyInfo like above.
 	 */
 	if (!strcmp(label, "RSA PRIVATE KEY")) {
 		const uint8_t *data;
@@ -510,6 +717,8 @@ static struct l_key *pem_load_private_key(uint8_t *cont=
ent,
 		size_t private_key_len;
 		uint8_t *one_asymmetric_key;
 		uint8_t *ptr;
+		const char *dekalgid;
+		const char *dekparameters;
 =

 		static const uint8_t version0[] =3D {
 			ASN1_ID_INTEGER, 0x01, 0x00
@@ -521,6 +730,54 @@ static struct l_key *pem_load_private_key(uint8_t *con=
tent,
 			ASN1_ID_NULL, 0x00,
 		};
 =

+		/*
+		 * "openssl rsa ..." can produce encrypted PKCS#1-formatted
+		 * keys.  These are incompatible with RFC7468 parsing because
+		 * of the RFC822 headers present but the format is the same
+		 * as documented in RFC1421.  The encryption algorithms are
+		 * supposed to be the ones defined in RFC1423 but that would
+		 * be only DES-CBC while openssl allows other algorithms.
+		 * When decrypted we get the RSAPrivateKey struct and proceed
+		 * like with the unencrypted format.
+		 */
+		dekalgid =3D parse_rfc1421_dek_info(headers, &dekparameters);
+		if (dekalgid) {
+			struct l_cipher *alg;
+			bool r;
+			int i;
+			size_t block_len;
+
+			if (encrypted)
+				*encrypted =3D true;
+
+			if (!passphrase)
+				goto err;
+
+			alg =3D cipher_from_dek_info(dekalgid, dekparameters,
+							passphrase, &block_len);
+			if (!alg)
+				goto err;
+
+			if (len % block_len || !len)
+				goto err;
+
+			r =3D l_cipher_decrypt(alg, content, content, len);
+			l_cipher_free(alg);
+
+			if (!r)
+				goto err;
+
+			/* Remove padding like in RFC1423 Section 1.1 */
+			if (content[len - 1] > block_len)
+				goto err;
+
+			for (i =3D 1; i < content[len - 1]; i++)
+				if (content[len - 1 - i] !=3D content[len - 1])
+					goto err;
+
+			len -=3D content[len - 1];
+		}
+
 		/*
 		 * Sanity check that it's a version 0 or 1 RSAPrivateKey
 		 * structure with the 8 integers, if it's not, make a last
@@ -586,6 +843,7 @@ err:
 	}
 =

 	l_free(label);
+	l_free(headers);
 	return pkey;
 }
 =

@@ -597,16 +855,18 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_from_=
data(const void *buf,
 	uint8_t *content;
 	char *label;
 	size_t len;
+	char *headers;
 =

 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D pem_load_buffer(buf, buf_len, &label, &len);
+	content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers);
 =

 	if (!content)
 		return NULL;
 =

-	return pem_load_private_key(content, len, label, passphrase, encrypted);
+	return pem_load_private_key(content, len, label, passphrase, headers,
+					encrypted);
 }
 =

 /**
@@ -632,14 +892,16 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(const=
 char *filename,
 	uint8_t *content;
 	char *label;
 	size_t len;
+	char *headers;
 =

 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D l_pem_load_file(filename, &label, &len);
+	content =3D pem_load_file(filename, &label, &len, &headers);
 =

 	if (!content)
 		return NULL;
 =

-	return pem_load_private_key(content, len, label, passphrase, encrypted);
+	return pem_load_private_key(content, len, label, passphrase, headers,
+					encrypted);
 }
-- =

2.25.1

--===============0148574277519319792==--

