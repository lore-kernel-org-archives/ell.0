Content-Type: multipart/mixed; boundary="===============4708628398367074294=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/10] pem: Support encrypted keys in l_pem_load_private_key
Date: Fri, 11 Aug 2017 01:10:14 +0200
Message-ID: <20170810231016.29445-8-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4708628398367074294==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add support for loading PKCS#8 encrypted private key files (those
generated with "openssl pkcs8 ..." or "openssl pkey ..." commands, not
"openssl rsa ..." commands).  The 'encrypted' parameter can be used to
check if a password is required to decode the key if the caller knows
nothing about the key other than the file path.
---
 ell/pem.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-=
----
 ell/pem.h |  4 +--
 ell/tls.c |  1 +
 3 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index d1f180e..058b8b8 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -36,6 +36,8 @@
 #include "pem.h"
 #include "base64.h"
 #include "string.h"
+#include "asn1-private.h"
+#include "cipher.h"
 =

 #define PEM_START_BOUNDARY	"-----BEGIN "
 #define PEM_END_BOUNDARY	"-----END "
@@ -232,11 +234,15 @@ LIB_EXPORT uint8_t *l_pem_load_certificate(const char=
 *filename, size_t *len)
 =

 LIB_EXPORT uint8_t *l_pem_load_private_key(const char *filename,
 						const char *passphrase,
+						bool *encrypted,
 						size_t *len)
 {
 	uint8_t *content;
 	char *label;
 =

+	if (encrypted)
+		*encrypted =3D false;
+
 	content =3D l_pem_load_file(filename, 0, &label, len);
 =

 	if (!content)
@@ -246,19 +252,89 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char=
 *filename,
 	 * RFC7469- and PKCS#8-compatible label (default in OpenSSL 1.0.1+)
 	 * and the older (OpenSSL <=3D 0.9.8 default) label.
 	 */
-	if (strcmp(label, "PRIVATE KEY") && strcmp(label, "RSA PRIVATE KEY")) {
+	if (!strcmp(label, "PRIVATE KEY") ||
+			!strcmp(label, "RSA PRIVATE KEY"))
+		goto done;
+
+	/* RFC5958 (PKCS#8) section 3 type encrypted key label */
+	if (!strcmp(label, "ENCRYPTED PRIVATE KEY")) {
+		const uint8_t *key_info, *alg_id, *data;
+		uint8_t tag;
+		size_t key_info_len, alg_id_len, data_len, tmp_len;
+		struct l_cipher *alg;
+		uint8_t *decrypted;
+		int i;
+
+		if (encrypted)
+			*encrypted =3D true;
+
+		if (!passphrase)
+			goto err;
+
+		/* Technically this is BER, not limited to DER */
+		key_info =3D der_find_elem(content, *len, 0, &tag, &key_info_len);
+		if (!key_info || tag !=3D ASN1_ID_SEQUENCE)
+			goto err;
+
+		alg_id =3D der_find_elem(key_info, key_info_len, 0, &tag,
+					&alg_id_len);
+		if (!alg_id || tag !=3D ASN1_ID_SEQUENCE)
+			goto err;
+
+		data =3D der_find_elem(key_info, key_info_len, 1, &tag,
+					&data_len);
+		if (!data || tag !=3D ASN1_ID_OCTET_STRING || data_len < 8 ||
+				(data_len & 7) !=3D 0)
+			goto err;
+
+		if (der_find_elem(content, *len, 2, &tag, &tmp_len))
+			goto err;
+
+		alg =3D l_cipher_from_pkcs5_id(alg_id, alg_id_len, passphrase);
+		if (!alg)
+			goto err;
+
+		decrypted =3D l_malloc(data_len);
+
+		if (!l_cipher_decrypt(alg, data, decrypted, data_len)) {
+			l_cipher_free(alg);
+			l_free(decrypted);
+			goto err;
+		}
+
+		l_cipher_free(alg);
 		l_free(content);
-		content =3D NULL;
+		content =3D decrypted;
+
+		/*
+		 * Strip padding as defined in RFC8018 (for PKCS#5 v1) or
+		 * RFC1423 / RFC5652 (for v2).
+		 */
+
+		if (content[data_len - 1] >=3D data_len ||
+				content[data_len - 1] > 16)
+			goto err;
+		for (i =3D 1; i < content[data_len - 1]; i++)
+			if (content[data_len - 1 - i] !=3D content[data_len - 1])
+				goto err;
+		*len =3D data_len - content[data_len - 1];
+
+		goto done;
 	}
 =

 	/*
-	 * TODO: handle ENCRYPTED PRIVATE KEY - RFC5958 section 3.
-	 *
-	 * TODO: handle RSA PRIVATE KEY encrypted keys (OpenSSL <=3D 0.9.8),
-	 * incompatible with RFC7468 parsing because of the headers present
-	 * before base64 encoded data.
+	 * TODO: handle RSA PRIVATE KEY format encrypted keys
+	 * (as produced by "openssl rsa" commands), incompatible with
+	 * RFC7468 parsing because of the headers present before
+	 * base64-encoded data.
 	 */
 =

+	/* Label not known */
+err:
+	l_free(content);
+	content =3D NULL;
+
+done:
 	l_free(label);
 =

 	return content;
diff --git a/ell/pem.h b/ell/pem.h
index c220fd4..93282a3 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -34,8 +34,8 @@ uint8_t *l_pem_load_file(const char *filename, int index,
 =

 uint8_t *l_pem_load_certificate(const char *filename, size_t *len);
 =

-uint8_t *l_pem_load_private_key(const char *filename,
-				const char *passphrase, size_t *len);
+uint8_t *l_pem_load_private_key(const char *filename, const char *passphra=
se,
+				bool *encrypted, size_t *len);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/tls.c b/ell/tls.c
index 9b199ef..0ca3d6e 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2223,6 +2223,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 =

 		priv_key =3D l_pem_load_private_key(priv_key_path,
 							priv_key_passphrase,
+							NULL,
 							&tls->priv_key_size);
 		if (!priv_key)
 			return false;
-- =

2.11.0


--===============4708628398367074294==--

