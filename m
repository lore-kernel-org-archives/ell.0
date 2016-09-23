Content-Type: multipart/mixed; boundary="===============2709469053655630558=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/9] key: Move asymmetric cipher type definition to the key
 subsystem
Date: Fri, 23 Sep 2016 16:02:17 -0700
Message-ID: <20160923230222.27401-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2709469053655630558==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.h |  4 ----
 ell/key.c    | 16 ++++++++--------
 ell/key.h    | 15 +++++++++------
 ell/tls.c    | 16 ++++++++--------
 4 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/ell/cipher.h b/ell/cipher.h
index 9f09d76..f5c6646 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -50,10 +50,6 @@ bool l_cipher_decrypt(struct l_cipher *cipher,
 bool l_cipher_set_iv(struct l_cipher *cipher, const uint8_t *iv,
 			size_t iv_length);
 =

-enum l_asymmetric_cipher_type {
-	L_CIPHER_RSA_PKCS1_V1_5,
-};
-
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/key.c b/ell/key.c
index b529f8a..a0cfcd4 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -336,12 +336,12 @@ LIB_EXPORT ssize_t l_key_get_payload_size(struct l_ke=
y *key)
 	return kernel_read_key(key->serial, NULL, 0);
 }
 =

-static const char *lookup_cipher(enum l_asymmetric_cipher_type cipher)
+static const char *lookup_cipher(enum l_key_cipher_type cipher)
 {
 	const char* ret =3D NULL;
 =

 	switch (cipher) {
-	case L_CIPHER_RSA_PKCS1_V1_5:
+	case L_KEY_RSA_PKCS1_V1_5:
 		ret =3D "pkcs1";
 		break;
 	}
@@ -376,7 +376,7 @@ static const char *lookup_checksum(enum l_checksum_type=
 checksum)
 	return ret;
 }
 =

-bool l_key_get_info(struct l_key *key, enum l_asymmetric_cipher_type ciphe=
r,
+bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type hash, size_t *bits,
 			bool *public)
 {
@@ -424,7 +424,7 @@ LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *o=
ther_public,
 =

 /* Common code for encrypt/decrypt/sign */
 static ssize_t eds_common(struct l_key *key,
-				enum l_asymmetric_cipher_type cipher,
+				enum l_key_cipher_type cipher,
 				enum l_checksum_type checksum, const void *in,
 				void *out, size_t len_in, size_t len_out,
 				int op)
@@ -438,7 +438,7 @@ static ssize_t eds_common(struct l_key *key,
 }
 =

 LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
-					enum l_asymmetric_cipher_type cipher,
+					enum l_key_cipher_type cipher,
 					enum l_checksum_type checksum,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
@@ -448,7 +448,7 @@ LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
 }
 =

 LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
-					enum l_asymmetric_cipher_type cipher,
+					enum l_key_cipher_type cipher,
 					enum l_checksum_type checksum,
 					const void *in, void *out,
 					size_t len_in, size_t len_out)
@@ -458,7 +458,7 @@ LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
 }
 =

 LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
-				enum l_asymmetric_cipher_type cipher,
+				enum l_key_cipher_type cipher,
 				enum l_checksum_type checksum, const void *in,
 				void *out, size_t len_in, size_t len_out)
 {
@@ -467,7 +467,7 @@ LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
 }
 =

 LIB_EXPORT bool l_key_verify(struct l_key *key,
-				enum l_asymmetric_cipher_type cipher,
+				enum l_key_cipher_type cipher,
 				enum l_checksum_type checksum, const void *data,
 				const void *sig, size_t len_data,
 				size_t len_sig)
diff --git a/ell/key.h b/ell/key.h
index 9cc69ff..4cd6cfe 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -31,7 +31,6 @@ extern "C" {
 #include <stdbool.h>
 =

 #include <ell/checksum.h>
-#include <ell/cipher.h>
 =

 struct l_key;
 struct l_keyring;
@@ -46,6 +45,10 @@ enum l_keyring_type {
 	L_KEYRING_TRUSTED_ASYM
 };
 =

+enum l_key_cipher_type {
+	L_KEY_RSA_PKCS1_V1_5,
+};
+
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
 			size_t payload_length);
 =

@@ -57,7 +60,7 @@ bool l_key_extract(struct l_key *key, void *payload, size=
_t *len);
 =

 ssize_t l_key_get_payload_size(struct l_key *key);
 =

-bool l_key_get_info(struct l_key *key, enum l_asymmetric_cipher_type ciphe=
r,
+bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, size_t *bits,
 			bool *public);
 =

@@ -67,19 +70,19 @@ bool l_key_compute_dh_public(struct l_key *generator, s=
truct l_key *private,
 bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *pri=
vate,
 			     struct l_key *prime, void *payload, size_t *len);
 =

-ssize_t l_key_encrypt(struct l_key *key, enum l_asymmetric_cipher_type cip=
her,
+ssize_t l_key_encrypt(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, const void *in,
 			void *out, size_t len_in, size_t len_out);
 =

-ssize_t l_key_decrypt(struct l_key *key, enum l_asymmetric_cipher_type cip=
her,
+ssize_t l_key_decrypt(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, const void *in,
 			void *out, size_t len_in, size_t len_out);
 =

-ssize_t l_key_sign(struct l_key *key, enum l_asymmetric_cipher_type cipher,
+ssize_t l_key_sign(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, const void *in,
 			void *out, size_t len_in, size_t len_out);
 =

-bool l_key_verify(struct l_key *key, enum l_asymmetric_cipher_type cipher,
+bool l_key_verify(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, const void *data,
 			const void *sig, size_t len_data, size_t len_sig);
 =

diff --git a/ell/tls.c b/ell/tls.c
index dc14b34..9b33ffb 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -875,9 +875,9 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 =

 	l_put_be16(tls->peer_pubkey_size, ptr);
 	bytes_encrypted =3D l_key_encrypt(tls->peer_pubkey,
-					L_CIPHER_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, pre_master_secret,
-					ptr + 2, 48, tls->peer_pubkey_size);
+					L_KEY_RSA_PKCS1_V1_5, L_CHECKSUM_NONE,
+					pre_master_secret, ptr + 2, 48,
+					tls->peer_pubkey_size);
 	ptr +=3D tls->peer_pubkey_size + 2;
 =

 	if (bytes_encrypted !=3D (ssize_t) tls->peer_pubkey_size) {
@@ -939,7 +939,7 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t =
*out, size_t len,
 		}
 =

 		l_put_be16(tls->priv_key_size, out);
-		result =3D l_key_sign(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+		result =3D l_key_sign(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, sign_input, out + 2,
 					sign_input_len, tls->priv_key_size);
 =

@@ -1026,7 +1026,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 		 */
 	}
 =

-	success =3D l_key_verify(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
+	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
 				L_CHECKSUM_NONE, expected, in + 4,
 				expected_len, tls->peer_pubkey_size);
 =

@@ -1519,7 +1519,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 		goto done;
 	}
 =

-	if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
+	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->peer_pubkey_size,
 					&dummy)) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
@@ -1707,7 +1707,7 @@ static void tls_handle_rsa_client_key_xchg(struct l_t=
ls *tls,
 		return;
 	}
 =

-	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+	bytes_decrypted =3D l_key_decrypt(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, buf + 2,
 					pre_master_secret, tls->priv_key_size,
 					48);
@@ -2232,7 +2232,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 			l_free(priv_key);
 		}
 =

-		if (!l_key_get_info(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
+		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
 					&is_public) || is_public) {
 			l_key_free(tls->priv_key);
-- =

2.10.0


--===============2709469053655630558==--

