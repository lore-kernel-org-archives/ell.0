Content-Type: multipart/mixed; boundary="===============6625539010060414997=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v7 1/5] tls: Check buffer bounds in tls_rsa_sign
Date: Mon, 20 Jun 2016 16:53:36 -0700
Message-ID: <20160620235340.30410-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6625539010060414997==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h |  2 +-
 ell/tls.c         | 54 ++++++++++++++++++++++++++++++++++++++-------------=
---
 2 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 184f2ae..1a47970 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -65,7 +65,7 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-	bool (*sign)(struct l_tls *tls, uint8_t **out,
+	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
 			tls_get_hash_t get_hash);
diff --git a/ell/tls.c b/ell/tls.c
index 0baddf7..3bd7d7d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -25,6 +25,7 @@
 #define _GNU_SOURCE
 #include <time.h>
 #include <stdlib.h>
+#include <errno.h>
 =

 #include "util.h"
 #include "private.h"
@@ -274,7 +275,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls);
 static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
 				tls_get_hash_t get_hash);
 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash);
@@ -917,23 +918,25 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls=
 *tls)
 	return true;
 }
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
 				tls_get_hash_t get_hash)
 {
 	struct l_asymmetric_cipher *rsa_privkey;
 	uint8_t *privkey;
 	size_t key_size;
-	bool result;
+	ssize_t result;
 	const struct tls_hash_algorithm *hash_type;
 	uint8_t hash[HANDSHAKE_HASH_MAX_SIZE];
 	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
 	size_t sign_input_len;
+	bool prepend_hash_type =3D false;
+	size_t expected_bytes;
 =

 	if (!tls->priv_key_path) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
 =

-		return false;
+		return -ENOKEY;
 	}
 =

 	privkey =3D l_pem_load_private_key(tls->priv_key_path,
@@ -943,7 +946,7 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t **o=
ut,
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
 =

-		return false;
+		return -ENOKEY;
 	}
 =

 	rsa_privkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
@@ -953,10 +956,11 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t *=
*out,
 	if (!rsa_privkey) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
 =

-		return false;
+		return -ENOKEY;
 	}
 =

 	key_size =3D l_asymmetric_cipher_get_key_size(rsa_privkey);
+	expected_bytes =3D key_size + 2;
 =

 	if (tls->negotiated_version >=3D TLS_V12) {
 		hash_type =3D &tls_handshake_hash_data[tls->signature_hash];
@@ -966,21 +970,34 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t *=
*out,
 					sign_input, &sign_input_len,
 					hash, hash_type->length);
 =

-		*(*out)++ =3D hash_type->tls_id;
-		*(*out)++ =3D 1;	/* RSA_sign */
+		prepend_hash_type =3D true;
+		expected_bytes +=3D 2;
 	} else {
 		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
 		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
 		sign_input_len =3D 36;
 	}
 =

-	l_put_be16(key_size, *out);
-	result =3D l_asymmetric_cipher_sign(rsa_privkey, sign_input, *out + 2,
-						sign_input_len, key_size);
-	*out +=3D key_size + 2;
+	result =3D -EMSGSIZE;
+
+	if (len >=3D expected_bytes) {
+		if (prepend_hash_type) {
+			*out++ =3D hash_type->tls_id;
+			*out++ =3D 1;	/* RSA_sign */
+		}
+
+		l_put_be16(key_size, out);
+		if (l_asymmetric_cipher_sign(rsa_privkey, sign_input,
+						out + 2, sign_input_len,
+						key_size))
+			result =3D expected_bytes;
+	}
 =

 	l_asymmetric_cipher_free(rsa_privkey);
 =

+	if (result < 0)
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
 	return result;
 }
 =

@@ -1137,13 +1154,17 @@ static bool tls_get_handshake_hash_by_id(struct l_t=
ls *tls, uint8_t hash_id,
 static bool tls_send_certificate_verify(struct l_tls *tls)
 {
 	uint8_t buf[2048];
-	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	int i;
+	ssize_t sign_len;
 =

 	/* Fill in the Certificate Verify body */
 =

-	if (!tls->pending.cipher_suite->key_xchg->sign(tls, &ptr,
-						tls_get_handshake_hash_by_id))
+	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls,
+					buf + TLS_HANDSHAKE_HEADER_SIZE,
+					2048 - TLS_HANDSHAKE_HEADER_SIZE,
+					tls_get_handshake_hash_by_id);
+
+	if (sign_len < 0)
 		return false;
 =

 	/* Stop maintaining handshake message hashes other than SHA256. */
@@ -1152,7 +1173,8 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 			if (i !=3D HANDSHAKE_HASH_SHA256)
 				tls_drop_handshake_hash(tls, i);
 =

-	tls_tx_handshake(tls, TLS_CERTIFICATE_VERIFY, buf, ptr - buf);
+	tls_tx_handshake(tls, TLS_CERTIFICATE_VERIFY, buf,
+				sign_len + TLS_HANDSHAKE_HEADER_SIZE);
 =

 	return true;
 }
-- =

2.9.0


--===============6625539010060414997==--

