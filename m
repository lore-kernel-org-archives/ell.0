Content-Type: multipart/mixed; boundary="===============0058322496949806770=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] pem: Return an l_key from l_pem_load_private_key
Date: Thu, 08 Nov 2018 13:06:49 +0100
Message-ID: <20181108120651.32521-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181108120651.32521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0058322496949806770==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Change l_pem_load_private_key to directly return the l_key object
instead of the byte buffer (and length) so there's no need to call
the l_key constructor seprately.
---
 ell/pem.c | 36 ++++++++++++++++++++++--------------
 ell/pem.h |  6 ++++--
 ell/tls.c | 18 +++++-------------
 3 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index f4aa7e2..98422e0 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -238,7 +238,6 @@ LIB_EXPORT struct l_cert *l_pem_load_certificate(const =
char *filename)
  * @filename: path string to the PEM file to load
  * @passphrase: private key encryption passphrase or NULL for unencrypted
  * @encrypted: receives indication whether the file was encrypted if non-N=
ULL
- * @len: receives the length of the returned buffer
  *
  * Load the PEM encoded RSA Private Key file at @filename.  If it is an
  * encrypted private key and @passphrase was non-NULL, the file is
@@ -247,20 +246,22 @@ LIB_EXPORT struct l_cert *l_pem_load_certificate(cons=
t char *filename)
  * success case and on error when NULL is returned.  This can be used to
  * check if a passphrase is required without prior information.
  *
- * Returns: Buffer containing raw DER data for the private key or NULL, to
- * be freed with l_free.
+ * Returns: An l_key object to be freed with an l_key_free* function,
+ * or NULL.
  **/
-LIB_EXPORT uint8_t *l_pem_load_private_key(const char *filename,
+LIB_EXPORT struct l_key *l_pem_load_private_key(const char *filename,
 						const char *passphrase,
-						bool *encrypted, size_t *len)
+						bool *encrypted)
 {
 	uint8_t *content;
 	char *label;
+	size_t len;
+	struct l_key *pkey =3D NULL;
 =

 	if (encrypted)
 		*encrypted =3D false;
 =

-	content =3D l_pem_load_file(filename, 0, &label, len);
+	content =3D l_pem_load_file(filename, 0, &label, &len);
 =

 	if (!content)
 		return NULL;
@@ -289,7 +290,7 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char *=
filename,
 			goto err;
 =

 		/* Technically this is BER, not limited to DER */
-		key_info =3D asn1_der_find_elem(content, *len, 0, &tag,
+		key_info =3D asn1_der_find_elem(content, len, 0, &tag,
 						&key_info_len);
 		if (!key_info || tag !=3D ASN1_ID_SEQUENCE)
 			goto err;
@@ -305,7 +306,7 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char *=
filename,
 				(data_len & 7) !=3D 0)
 			goto err;
 =

-		if (asn1_der_find_elem(content, *len, 2, &tag, &tmp_len))
+		if (asn1_der_find_elem(content, len, 2, &tag, &tmp_len))
 			goto err;
 =

 		alg =3D pkcs5_cipher_from_alg_id(alg_id, alg_id_len, passphrase);
@@ -321,8 +322,10 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char =
*filename,
 		}
 =

 		l_cipher_free(alg);
+		memset(content, 0, len);
 		l_free(content);
 		content =3D decrypted;
+		len =3D data_len;
 =

 		/*
 		 * Strip padding as defined in RFC8018 (for PKCS#5 v1) or
@@ -337,7 +340,7 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char *=
filename,
 			if (content[data_len - 1 - i] !=3D content[data_len - 1])
 				goto err;
 =

-		*len =3D data_len - content[data_len - 1];
+		len =3D data_len - content[data_len - 1];
 =

 		goto done;
 	}
@@ -350,12 +353,17 @@ LIB_EXPORT uint8_t *l_pem_load_private_key(const char=
 *filename,
 	 */
 =

 	/* Label not known */
-err:
-	l_free(content);
-	content =3D NULL;
+	goto err;
 =

 done:
-	l_free(label);
+	pkey =3D l_key_new(L_KEY_RSA, content, len);
 =

-	return content;
+err:
+	if (content) {
+		memset(content, 0, len);
+		l_free(content);
+	}
+
+	l_free(label);
+	return pkey;
 }
diff --git a/ell/pem.h b/ell/pem.h
index 9629ef2..7f0d27a 100644
--- a/ell/pem.h
+++ b/ell/pem.h
@@ -27,6 +27,7 @@
 extern "C" {
 #endif
 =

+#include <ell/key.h>
 #include <ell/cert.h>
 =

 uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
@@ -36,8 +37,9 @@ uint8_t *l_pem_load_file(const char *filename, int index,
 =

 struct l_cert *l_pem_load_certificate(const char *filename);
 =

-uint8_t *l_pem_load_private_key(const char *filename, const char *passphra=
se,
-				bool *encrypted, size_t *len);
+struct l_key *l_pem_load_private_key(const char *filename,
+					const char *passphrase,
+					bool *encrypted);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/tls.c b/ell/tls.c
index 6bea5dc..7433524 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2473,23 +2473,15 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
 	}
 =

 	if (priv_key_path) {
-		uint8_t *priv_key;
 		bool is_public =3D true;
 =

-		priv_key =3D l_pem_load_private_key(priv_key_path,
+		tls->priv_key =3D l_pem_load_private_key(priv_key_path,
 							priv_key_passphrase,
-							NULL,
-							&tls->priv_key_size);
-		TLS_DEBUG("l_pem_load_private_key returned %p, size %zi",
-				priv_key, tls->priv_key_size);
-
-		if (!priv_key)
+							NULL);
+		if (!tls->priv_key) {
+			TLS_DEBUG("Error loading %s", priv_key_path);
 			return false;
-
-		tls->priv_key =3D l_key_new(L_KEY_RSA, priv_key,
-						tls->priv_key_size);
-		memset(priv_key, 0, tls->priv_key_size);
-		l_free(priv_key);
+		}
 =

 		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
-- =

2.19.1


--===============0058322496949806770==--

