Content-Type: multipart/mixed; boundary="===============1607125136833191346=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v5 1/5] tls: Check buffer bounds in tls_rsa_sign
Date: Fri, 17 Jun 2016 13:47:39 -0700
Message-ID: <20160617204743.6643-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1607125136833191346==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h |  2 +-
 ell/tls.c         | 29 ++++++++++++++++++++++-------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 184f2ae..9ea1554 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -65,7 +65,7 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-	bool (*sign)(struct l_tls *tls, uint8_t **out,
+	bool (*sign)(struct l_tls *tls, uint8_t **out, size_t len,
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
 			tls_get_hash_t get_hash);
diff --git a/ell/tls.c b/ell/tls.c
index 0baddf7..90404e4 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -274,7 +274,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls);
 static void tls_handle_rsa_client_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
 				tls_get_hash_t get_hash);
 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
 				tls_get_hash_t get_hash);
@@ -917,7 +917,7 @@ static bool tls_send_rsa_client_key_xchg(struct l_tls *=
tls)
 	return true;
 }
 =

-static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out,
+static bool tls_rsa_sign(struct l_tls *tls, uint8_t **out, size_t len,
 				tls_get_hash_t get_hash)
 {
 	struct l_asymmetric_cipher *rsa_privkey;
@@ -929,6 +929,12 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t **=
out,
 	uint8_t sign_input[HANDSHAKE_HASH_MAX_SIZE * 2 + 32];
 	size_t sign_input_len;
 =

+	if (len < 2) {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+
+		return false;
+	}
+
 	if (!tls->priv_key_path) {
 		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
 				TLS_ALERT_BAD_CERT);
@@ -968,16 +974,24 @@ static bool tls_rsa_sign(struct l_tls *tls, uint8_t *=
*out,
 =

 		*(*out)++ =3D hash_type->tls_id;
 		*(*out)++ =3D 1;	/* RSA_sign */
+		len -=3D 2;
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
+	if (len >=3D key_size + 2) {
+		l_put_be16(key_size, *out);
+		result =3D l_asymmetric_cipher_sign(rsa_privkey, sign_input,
+							*out + 2,
+							sign_input_len,
+							key_size);
+		*out +=3D key_size + 2;
+	} else {
+		tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
+		result =3D false;
+	}
 =

 	l_asymmetric_cipher_free(rsa_privkey);
 =

@@ -1143,7 +1157,8 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 	/* Fill in the Certificate Verify body */
 =

 	if (!tls->pending.cipher_suite->key_xchg->sign(tls, &ptr,
-						tls_get_handshake_hash_by_id))
+					2048 - TLS_HANDSHAKE_HEADER_SIZE,
+					tls_get_handshake_hash_by_id))
 		return false;
 =

 	/* Stop maintaining handshake message hashes other than SHA256. */
-- =

2.9.0


--===============1607125136833191346==--

