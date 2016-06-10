Content-Type: multipart/mixed; boundary="===============9162736599445352431=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 1/5] cipher: Update for current kernel akcipher interface
Date: Fri, 10 Jun 2016 10:09:06 -0700
Message-ID: <20160610170910.20259-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9162736599445352431==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

There are some significant differences in the current iteration of
kernel AF_ALG akcipher support:
 * Kernel handles padding
 * Kernel accepts DER-encoded certs as-is (no need to extract values)
 * Must explicitly set private or public key
---
 ell/cipher-private.h |   3 -
 ell/cipher.c         | 311 ++++++++++++++---------------------------------=
----
 ell/tls.c            |  43 +++----
 3 files changed, 97 insertions(+), 260 deletions(-)

diff --git a/ell/cipher-private.h b/ell/cipher-private.h
index 7d115f6..77ddd06 100644
--- a/ell/cipher-private.h
+++ b/ell/cipher-private.h
@@ -20,9 +20,6 @@
  *
  */
 =

-uint8_t *extract_rsakey(uint8_t *pkcs1_key, size_t pkcs1_key_len,
-			size_t *out_len);
-
 #define ASN1_ID(class, pc, tag)	(((class) << 6) | ((pc) << 5) | (tag))
 =

 #define ASN1_CLASS_UNIVERSAL	0
diff --git a/ell/cipher.c b/ell/cipher.c
index 671071b..f23bdda 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -78,6 +78,17 @@ struct af_alg_iv {
 #define SOL_ALG 279
 #endif
 =

+#ifndef ALG_OP_SIGN
+#define ALG_OP_SIGN	2
+#endif
+#ifndef ALG_OP_VERIFY
+#define ALG_OP_VERIFY	3
+#endif
+
+#ifndef ALG_SET_PUBKEY
+#define ALG_SET_PUBKEY	6
+#endif
+
 #define is_valid_type(type)  ((type) <=3D L_CIPHER_DES3_EDE_CBC)
 =

 struct l_cipher {
@@ -87,10 +98,11 @@ struct l_cipher {
 };
 =

 static int create_alg(const char *alg_type, const char *alg_name,
-				const void *key, size_t key_length)
+			const void *key, size_t key_length, bool public)
 {
 	struct sockaddr_alg salg;
 	int sk;
+	int keyopt;
 	int ret;
 =

 	sk =3D socket(PF_ALG, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
@@ -107,7 +119,8 @@ static int create_alg(const char *alg_type, const char =
*alg_name,
 		return -1;
 	}
 =

-	if (setsockopt(sk, SOL_ALG, ALG_SET_KEY, key, key_length) < 0) {
+	keyopt =3D public ? ALG_SET_PUBKEY : ALG_SET_KEY;
+	if (setsockopt(sk, SOL_ALG, keyopt, key, key_length) < 0) {
 		close(sk);
 		return -1;
 	}
@@ -149,11 +162,13 @@ LIB_EXPORT struct l_cipher *l_cipher_new(enum l_ciphe=
r_type type,
 		break;
 	}
 =

-	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
+	cipher->encrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
+					false);
 	if (cipher->encrypt_sk < 0)
 		goto error_free;
 =

-	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length);
+	cipher->decrypt_sk =3D create_alg("skcipher", alg_name, key, key_length,
+					false);
 	if (cipher->decrypt_sk < 0)
 		goto error_close;
 =

@@ -178,7 +193,8 @@ LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 }
 =

 static bool operate_cipher(int sk, __u32 operation,
-				const void *in, void *out, size_t len)
+				const void *in, void *out, size_t len_in,
+				size_t len_out)
 {
 	char c_msg_buf[CMSG_SPACE(sizeof(operation))];
 	struct msghdr msg;
@@ -198,7 +214,7 @@ static bool operate_cipher(int sk, __u32 operation,
 	memcpy(CMSG_DATA(c_msg), &operation, sizeof(operation));
 =

 	iov.iov_base =3D (void *) in;
-	iov.iov_len =3D len;
+	iov.iov_len =3D len_in;
 =

 	msg.msg_iov =3D &iov;
 	msg.msg_iovlen =3D 1;
@@ -206,7 +222,7 @@ static bool operate_cipher(int sk, __u32 operation,
 	if (sendmsg(sk, &msg, 0) < 0)
 		return false;
 =

-	if (read(sk, out, len) < 0)
+	if (read(sk, out, len_out) < 0)
 		return false;
 =

 	return true;
@@ -221,7 +237,8 @@ LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *ciphe=
r,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, out, len);
+	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, out, len,
+				len);
 }
 =

 LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *cipher,
@@ -233,7 +250,8 @@ LIB_EXPORT bool l_cipher_decrypt(struct l_cipher *ciphe=
r,
 	if (unlikely(!in) || unlikely(!out))
 		return false;
 =

-	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, len);
+	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in, out, len,
+				len);
 }
 =

 LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
@@ -275,6 +293,7 @@ LIB_EXPORT bool l_cipher_set_iv(struct l_cipher *cipher=
, const uint8_t *iv,
 struct l_asymmetric_cipher {
 	struct l_cipher cipher;
 	int key_size;
+	bool public_key;
 };
 =

 static inline int parse_asn1_definite_length(const uint8_t **buf,
@@ -334,20 +353,31 @@ static bool parse_rsa_key(struct l_asymmetric_cipher =
*cipher, const void *key,
 	 * and cache the size of the modulus n for later use.
 	 * (RFC3279)
 	 */
+	size_t seq_length;
 	size_t n_length;
+	uint8_t *seq;
 	uint8_t *der;
 	uint8_t tag;
+	bool pubkey =3D true;
 =

 	if (key_length < 8)
 		return false;
 =

 	/* Unpack the outer SEQUENCE */
-	der =3D der_find_elem((uint8_t *) key, key_length, 0, &tag, &n_length);
-	if (!der || tag !=3D ASN1_ID_SEQUENCE)
+	seq =3D der_find_elem((uint8_t *) key, key_length, 0, &tag, &seq_length);
+	if (!seq || tag !=3D ASN1_ID_SEQUENCE)
 		return false;
 =

-	/* Take first INTEGER as the modulus */
-	der =3D der_find_elem(der, n_length, 0, &tag, &n_length);
+	/* First INTEGER may be a 1-byte version (for private key) or
+	 * the modulus (public key)
+	 */
+	der =3D der_find_elem(seq, seq_length, 0, &tag, &n_length);
+	if (der && tag =3D=3D ASN1_ID_INTEGER && n_length =3D=3D 1) {
+		/* Found version number, implies this is a private key. */
+		der =3D der_find_elem(seq, seq_length, 1, &tag, &n_length);
+		pubkey =3D false;
+	}
+
 	if (!der || tag !=3D ASN1_ID_INTEGER || n_length < 4)
 		return false;
 =

@@ -358,95 +388,11 @@ static bool parse_rsa_key(struct l_asymmetric_cipher =
*cipher, const void *key,
 	}
 =

 	cipher->key_size =3D n_length;
+	cipher->public_key =3D pubkey;
 =

 	return true;
 }
 =

-static void write_asn1_definite_length(uint8_t **buf, size_t len)
-{
-	int n;
-
-	if (len < 0x80) {
-		*(*buf)++ =3D len;
-
-		return;
-	}
-
-	for (n =3D 1; len >> (n * 8); n++);
-	*(*buf)++ =3D 0x80 | n;
-
-	while (n--)
-		*(*buf)++ =3D len >> (n * 8);
-}
-
-/*
- * Extract a ASN1 RsaKey-formatted public+private key structure in the
- * form used in the kernel.  It is simpler than the PKCS#1 form as it only
- * contains the N, E and D integers and also correctly parses as a PKCS#1
- * RSAPublicKey.
- */
-uint8_t *extract_rsakey(uint8_t *pkcs1_key, size_t pkcs1_key_len,
-			size_t *out_len)
-{
-	uint8_t *key, *ptr, *ver, *n, *e, *d;
-	uint8_t tag;
-	size_t ver_len, n_len, e_len, d_len;
-	int pos;
-
-	/* Unpack the outer SEQUENCE */
-	pkcs1_key =3D der_find_elem(pkcs1_key, pkcs1_key_len, 0, &tag,
-					&pkcs1_key_len);
-	if (!pkcs1_key || tag !=3D ASN1_ID_SEQUENCE)
-		return NULL;
-
-	/* Check if the version element if present */
-	ver =3D der_find_elem(pkcs1_key, pkcs1_key_len, 0, &tag, &ver_len);
-	if (!ver || tag !=3D ASN1_ID_INTEGER)
-		return NULL;
-
-	pos =3D (ver_len =3D=3D 1 && ver[0] =3D=3D 0x00) ? 1 : 0;
-
-	n =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 0, &tag, &n_len);
-	if (!n || tag !=3D ASN1_ID_INTEGER)
-		return NULL;
-
-	e =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 1, &tag, &e_len);
-	if (!e || tag !=3D ASN1_ID_INTEGER)
-		return NULL;
-
-	d =3D der_find_elem(pkcs1_key, pkcs1_key_len, pos + 2, &tag, &d_len);
-	if (!d || tag !=3D ASN1_ID_INTEGER)
-		return NULL;
-
-	/* New SEQUENCE length including tags and lengths */
-	*out_len =3D 1 + (n_len >=3D 0x80 ? n_len >=3D 0x100 ? 3 : 2 : 1) + n_len=
 +
-		1 + (e_len >=3D 0x80 ? e_len >=3D 0x100 ? 3 : 2 : 1) + e_len +
-		1 + (d_len >=3D 0x80 ? d_len >=3D 0x100 ? 3 : 2 : 1) + d_len;
-	ptr =3D key =3D l_malloc(*out_len +
-		1 + (*out_len >=3D 0x80 ? *out_len >=3D 0x100 ? 3 : 2 : 1));
-
-	*ptr++ =3D ASN1_ID_SEQUENCE;
-	write_asn1_definite_length(&ptr, *out_len);
-
-	*ptr++ =3D ASN1_ID_INTEGER;
-	write_asn1_definite_length(&ptr, n_len);
-	memcpy(ptr, n, n_len);
-	ptr +=3D n_len;
-
-	*ptr++ =3D ASN1_ID_INTEGER;
-	write_asn1_definite_length(&ptr, e_len);
-	memcpy(ptr, e, e_len);
-	ptr +=3D e_len;
-
-	*ptr++ =3D ASN1_ID_INTEGER;
-	write_asn1_definite_length(&ptr, d_len);
-	memcpy(ptr, d, d_len);
-	ptr +=3D d_len;
-
-	*out_len =3D ptr - key;
-	return key;
-}
-
 LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_cipher_new(
 					enum l_asymmetric_cipher_type type,
 					const void *key, size_t key_length)
@@ -468,19 +414,23 @@ LIB_EXPORT struct l_asymmetric_cipher *l_asymmetric_c=
ipher_new(
 		if (!parse_rsa_key(cipher, key, key_length))
 			goto error_free;
 =

-		alg_name =3D "rsa";
+		alg_name =3D "pkcs1pad(rsa)";
 		break;
 	}
 =

 	cipher->cipher.encrypt_sk =3D create_alg("akcipher", alg_name,
-						key, key_length);
+						key, key_length,
+						cipher->public_key);
 	if (cipher->cipher.encrypt_sk < 0)
 		goto error_free;
 =

-	cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
-						key, key_length);
-	if (cipher->cipher.decrypt_sk < 0)
-		goto error_close;
+	if (!cipher->public_key) {
+		cipher->cipher.decrypt_sk =3D create_alg("akcipher", alg_name,
+							key, key_length,
+							cipher->public_key);
+		if (cipher->cipher.decrypt_sk < 0)
+			goto error_close;
+	}
 =

 	return cipher;
 =

@@ -508,151 +458,58 @@ LIB_EXPORT int l_asymmetric_cipher_get_key_size(
 	return cipher->key_size;
 }
 =

-static void getrandom_nonzero(uint8_t *buf, int len)
-{
-	while (len--) {
-		l_getrandom(buf, 1);
-		while (buf[0] =3D=3D 0)
-			l_getrandom(buf, 1);
-
-		buf++;
-	}
-}
-
-LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *ci=
pher,
+LIB_EXPORT bool l_asymmetric_cipher_encrypt(struct l_asymmetric_cipher *ac=
ipher,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
-		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
-		uint8_t buf[cipher->key_size];
-		int ps_len =3D cipher->key_size - len_in - 3;
-
-		if (len_in > (size_t) cipher->key_size - 11)
-			return false;
-		if (len_out !=3D (size_t) cipher->key_size)
-			return false;
-
-		buf[0] =3D 0x00;
-		buf[1] =3D 0x02;
-		getrandom_nonzero(buf + 2, ps_len);
-		buf[ps_len + 2] =3D 0x00;
-		memcpy(buf + ps_len + 3, in, len_in);
-
-		if (!l_cipher_encrypt(&cipher->cipher, buf, out,
-					cipher->key_size))
-			return false;
-	}
+	if (unlikely(!acipher))
+		return false;
 =

-	return true;
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.encrypt_sk, ALG_OP_ENCRYPT,
+				in, out, len_in, len_out);
 }
 =

-LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *ci=
pher,
+LIB_EXPORT bool l_asymmetric_cipher_decrypt(struct l_asymmetric_cipher *ac=
ipher,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
-		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
-		uint8_t buf[cipher->key_size];
-		int pos;
-
-		if (len_in !=3D (size_t) cipher->key_size)
-			return false;
-
-		if (!l_cipher_decrypt(&cipher->cipher, in, buf,
-					cipher->key_size))
-			return false;
-
-		if (buf[0] !=3D 0x00)
-			return false;
-		if (buf[1] !=3D 0x02)
-			return false;
-
-		for (pos =3D 2; pos < cipher->key_size; pos++)
-			if (buf[pos] =3D=3D 0)
-				break;
-		if (pos < 10 || pos =3D=3D cipher->key_size)
-			return false;
-
-		pos++;
-		if (len_out !=3D (size_t) cipher->key_size - pos)
-			return false;
-
-		memcpy(out, buf + pos, cipher->key_size - pos);
-	}
+	if (unlikely(!acipher))
+		return false;
 =

-	return true;
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.decrypt_sk, ALG_OP_DECRYPT,
+				in, out, len_in, len_out);
 }
 =

 LIB_EXPORT bool l_asymmetric_cipher_sign(struct l_asymmetric_cipher *ciphe=
r,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
-		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
-		uint8_t buf[cipher->key_size];
-		int ps_len =3D cipher->key_size - len_in - 3;
-
-		if (len_in > (size_t) cipher->key_size - 11)
-			return false;
-		if (len_out !=3D (size_t) cipher->key_size)
-			return false;
-
-		buf[0] =3D 0x00;
-		buf[1] =3D 0x01;
-		memset(buf + 2, 0xff, ps_len);
-		buf[ps_len + 2] =3D 0x00;
-		memcpy(buf + ps_len + 3, in, len_in);
-
-		/*
-		 * The RSA signing operation uses the same primitive as
-		 * decryption so just call decrypt for now.
-		 */
-		if (!l_cipher_decrypt(&cipher->cipher, buf, out,
-					cipher->key_size))
-			return false;
-	}
+	if (unlikely(!acipher))
+		return false;
 =

-	return true;
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.decrypt_sk, ALG_OP_SIGN,
+				in, out, len_in, len_out);
 }
 =

 LIB_EXPORT bool l_asymmetric_cipher_verify(struct l_asymmetric_cipher *cip=
her,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
 {
-	if (cipher->cipher.type =3D=3D L_CIPHER_RSA_PKCS1_V1_5) {
-		/* PKCS#1 v1.5 RSA padding according to RFC3447 */
-		uint8_t buf[cipher->key_size];
-		int pos;
-
-		if (len_in !=3D (size_t) cipher->key_size)
-			return false;
-
-		/*
-		 * The RSA verify operation uses the same primitive as
-		 * encryption so just call encrypt.
-		 */
-		if (!l_cipher_encrypt(&cipher->cipher, in, buf,
-					cipher->key_size))
-			return false;
-
-		if (buf[0] !=3D 0x00)
-			return false;
-		if (buf[1] !=3D 0x01)
-			return false;
-
-		for (pos =3D 2; pos < cipher->key_size; pos++)
-			if (buf[pos] !=3D 0xff)
-				break;
-		if (pos < 10 || pos =3D=3D cipher->key_size || buf[pos] !=3D 0)
-			return false;
-
-		pos++;
-		if (len_out !=3D (size_t) cipher->key_size - pos)
-			return false;
-
-		memcpy(out, buf + pos, cipher->key_size - pos);
-	}
+	if (unlikely(!acipher))
+		return false;
 =

-	return true;
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(acipher->cipher.encrypt_sk, ALG_OP_VERIFY,
+				in, out, len_in, len_out);
 }
diff --git a/ell/tls.c b/ell/tls.c
index a20236f..a55f24c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -920,8 +920,8 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t **o=
ut,
 				tls_get_hash_t get_hash)
 {
 	struct l_asymmetric_cipher *rsa_privkey;
-	uint8_t *privkey, *privkey_short;
-	size_t key_size, short_size;
+	uint8_t *privkey;
+	size_t key_size;
 	bool result;
 	const struct tls_hash_algorithm *hash_type;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
@@ -945,19 +945,9 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t **=
out,
 		return false;
 	}
 =

-	privkey_short =3D extract_rsakey(privkey, key_size, &short_size);
-	tls_free_key(privkey, key_size);
-
-	if (!privkey_short) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
-
-		return false;
-	}
-
 	rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-						privkey_short, short_size);
-	tls_free_key(privkey_short, short_size);
+						privkey, key_size);
+	tls_free_key(privkey, key_size);
 =

 	if (!rsa_privkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
@@ -1080,11 +1070,14 @@ static bool tls_rsa_verify(struct l_tls *tls, const=
 uint8_t *in, size_t len,
 		 */
 	}
 =

-	digest_info =3D alloca(expected_len);
+	if (expected_len > key_size)
+		goto err_free_rsa;
+
+	digest_info =3D alloca(key_size);
 =

 	result =3D l_asymmetric_cipher_verify(rsa_client_pubkey, in + 4,
 						digest_info,
-						key_size, expected_len);
+						key_size, key_size);
 =

 	l_asymmetric_cipher_free(rsa_client_pubkey);
 =

@@ -1743,8 +1736,8 @@ static void tls_handle_rsa_client_key_xchg(struct l_t=
ls *tls,
 {
 	uint8_t pre_master_secret[48], random_secret[46];
 	struct l_asymmetric_cipher *rsa_server_privkey;
-	uint8_t *privkey, *privkey_short;
-	size_t key_size, short_size;
+	uint8_t *privkey;
+	size_t key_size;
 	bool result;
 =

 	if (!tls->priv_key_path) {
@@ -1764,19 +1757,9 @@ static void tls_handle_rsa_client_key_xchg(struct l_=
tls *tls,
 		return;
 	}
 =

-	privkey_short =3D extract_rsakey(privkey, key_size, &short_size);
-	tls_free_key(privkey, key_size);
-
-	if (!privkey_short) {
-		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-				TLS_ALERT_BAD_CERT);
-
-		return;
-	}
-
 	rsa_server_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
-						privkey_short, short_size);
-	tls_free_key(privkey_short, short_size);
+							privkey, key_size);
+	tls_free_key(privkey, key_size);
 =

 	if (!rsa_server_privkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
-- =

2.8.4


--===============9162736599445352431==--

