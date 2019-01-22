Content-Type: multipart/mixed; boundary="===============6845473246524527085=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/9] tls: Simplify .sign/.verify get_hash callbacks
Date: Tue, 22 Jan 2019 07:09:00 +0100
Message-ID: <20190122060905.27452-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6845473246524527085==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Pass the handshake_hash_type to the get_hash callbacks directly from the
signature algorithm's .sign and .verify methods and drop the output hash
type parameter.  This simplifies both the get_hash callbacks and the
callers and reduces the number of hash type lookups needed.
---
 ell/tls-private.h | 44 +++++++++++++++---------------
 ell/tls-suites.c  | 69 +++++++++++++++++++++--------------------------
 ell/tls.c         | 58 +++++++++++++++------------------------
 3 files changed, 75 insertions(+), 96 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 1adc389..957109d 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -49,12 +49,31 @@ struct tls_hash_algorithm {
 	const char *name;
 };
 =

+/*
+ * Support the minimum required set of handshake hash types for the
+ * Certificate Verify digital signature and the Finished PRF seed so we
+ * don't have to accumulate all of messages full contents until the
+ * Finished message.  If we're sent a hash of a different type (in TLS 1.2=
+)
+ * and need to verify we'll give up.
+ * SHA1 and MD5 are explicitly required by versions < 1.2 and 1.2 requires
+ * that the Finished hash is the same as used for the PRF so we need to
+ * keep at least the hashes our supported cipher suites specify for the PR=
F.
+ */
+enum handshake_hash_type {
+	HANDSHAKE_HASH_SHA384,
+	HANDSHAKE_HASH_SHA256,
+	HANDSHAKE_HASH_MD5,
+	HANDSHAKE_HASH_SHA1,
+	__HANDSHAKE_HASH_COUNT,
+};
+#define HANDSHAKE_HASH_MAX_SIZE	48
+
 extern const struct tls_hash_algorithm tls_handshake_hash_data[];
 =

-typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
+typedef bool (*tls_get_hash_t)(struct l_tls *tls,
+				enum handshake_hash_type type,
 				const uint8_t *data, size_t data_len,
-				uint8_t *out, size_t *out_len,
-				enum l_checksum_type *type);
+				uint8_t *out, size_t *out_len);
 =

 struct tls_key_exchange_algorithm {
 	uint8_t id;
@@ -179,25 +198,6 @@ enum tls_handshake_type {
 	TLS_FINISHED		=3D 20,
 };
 =

-/*
- * Support the minimum required set of handshake hash types for the
- * Certificate Verify digital signature and the Finished PRF seed so we
- * don't have to accumulate all of messages full contents until the
- * Finished message.  If we're sent a hash of a different type (in TLS 1.2=
+)
- * and need to verify we'll give up.
- * SHA1 and MD5 are explicitly required by versions < 1.2 and 1.2 requires
- * that the Finished hash is the same as used for the PRF so we need to
- * keep@least the hashes our supported cipher suites specify for the PR=
F.
- */
-enum handshake_hash_type {
-	HANDSHAKE_HASH_SHA384,
-	HANDSHAKE_HASH_SHA256,
-	HANDSHAKE_HASH_MD5,
-	HANDSHAKE_HASH_SHA1,
-	__HANDSHAKE_HASH_COUNT,
-};
-#define HANDSHAKE_HASH_MAX_SIZE	48
-
 struct l_tls {
 	bool server;
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 897bbee..5d2653a 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -181,19 +181,18 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t out_len,
 		if (out_len < 2) /* Is there space for the algorithm IDs */
 			goto error;
 =

-		get_hash(tls, hash_type->tls_id, data, data_len,
-				sign_input, NULL, NULL);
+		get_hash(tls, tls->signature_hash, data, data_len,
+				sign_input, &sign_input_len);
 		sign_checksum_type =3D hash_type->l_id;
-		sign_input_len =3D hash_type->length;
 =

 		*ptr++ =3D hash_type->tls_id;
 		*ptr++ =3D 1;	/* RSA_sign */
 		out_len -=3D 2;
 	} else {
-		/* MD5 */
-		get_hash(tls, 1, data, data_len, sign_input + 0, NULL, NULL);
-		/* SHA1 */
-		get_hash(tls, 2, data, data_len, sign_input + 16, NULL, NULL);
+		get_hash(tls, HANDSHAKE_HASH_MD5, data, data_len,
+				sign_input + 0, NULL);
+		get_hash(tls, HANDSHAKE_HASH_SHA1, data, data_len,
+				sign_input + 16, NULL);
 		sign_checksum_type =3D L_CHECKSUM_NONE;
 		sign_input_len =3D 36;
 	}
@@ -221,7 +220,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
t8_t *in, size_t in_len,
 				tls_get_hash_t get_hash,
 				const uint8_t *data, size_t data_len)
 {
-	enum l_checksum_type hash_type;
+	enum l_checksum_type sign_checksum_type;
 	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
 	size_t expected_len;
 	unsigned int offset;
@@ -252,6 +251,8 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
t8_t *in, size_t in_len,
 	}
 =

 	if (tls->negotiated_version >=3D L_TLS_V12) {
+		enum handshake_hash_type hash;
+
 		/* Only RSA supported */
 		if (in[1] !=3D 1 /* RSA_sign */) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
@@ -261,14 +262,19 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t in_len,
 			return false;
 		}
 =

-		if (!get_hash(tls, in[0], data, data_len,
-				expected, &expected_len, &hash_type)) {
+		for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+			if (tls_handshake_hash_data[hash].tls_id =3D=3D in[0])
+				break;
+
+		if (hash =3D=3D __HANDSHAKE_HASH_COUNT) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
 					"Unknown hash type %i", in[0]);
-
 			return false;
 		}
 =

+		get_hash(tls, hash, data, data_len, expected, &expected_len);
+		sign_checksum_type =3D tls_handshake_hash_data[hash].l_id;
+
 		/*
 		 * Note: Next we let the l_key_verify's underlying kernel
 		 * operation prepend the OID to the hash to build the
@@ -287,12 +293,12 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t in_len,
 		 * encoding.
 		 */
 	} else {
-		/* MD5 */
-		get_hash(tls, 1, data, data_len, expected + 0, NULL, NULL);
-		/* SHA1 */
-		get_hash(tls, 2, data, data_len, expected + 16, NULL, NULL);
+		get_hash(tls, HANDSHAKE_HASH_MD5, data, data_len,
+				expected + 0, NULL);
+		get_hash(tls, HANDSHAKE_HASH_SHA1, data, data_len,
+				expected + 16, NULL);
 		expected_len =3D 36;
-		hash_type =3D L_CHECKSUM_NONE;
+		sign_checksum_type =3D L_CHECKSUM_NONE;
 =

 		/*
 		 * Note: Within the RSA padding for signatures PKCS#1 1.5
@@ -308,7 +314,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
t8_t *in, size_t in_len,
 	}
 =

 	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-				hash_type, expected, in + offset + 2,
+				sign_checksum_type, expected, in + offset + 2,
 				expected_len, tls->peer_pubkey_size);
 =

 	if (!success)
@@ -331,25 +337,15 @@ static struct tls_key_exchange_algorithm tls_rsa =3D {
 };
 =

 /* Used by both DHE and ECDHE */
-static bool tls_get_dh_params_hash(struct l_tls *tls, uint8_t tls_id,
+static bool tls_get_dh_params_hash(struct l_tls *tls,
+					enum handshake_hash_type type,
 					const uint8_t *data, size_t data_len,
-					uint8_t *out, size_t *out_len,
-					enum l_checksum_type *type)
+					uint8_t *out, size_t *out_len)
 {
-	unsigned int hash;
 	struct l_checksum *checksum;
-	ssize_t hash_len, ret;
+	ssize_t ret;
 =

-	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-		if (tls_handshake_hash_data[hash].tls_id =3D=3D tls_id)
-			break;
-
-	if (hash =3D=3D __HANDSHAKE_HASH_COUNT)
-		return false;
-
-	hash_len =3D tls_handshake_hash_data[hash].length;
-
-	checksum =3D l_checksum_new(tls_handshake_hash_data[hash].l_id);
+	checksum =3D l_checksum_new(tls_handshake_hash_data[type].l_id);
 	if (!checksum)
 		return false;
 =

@@ -362,17 +358,14 @@ static bool tls_get_dh_params_hash(struct l_tls *tls,=
 uint8_t tls_id,
 	l_checksum_update(checksum, tls->pending.client_random, 32);
 	l_checksum_update(checksum, tls->pending.server_random, 32);
 	l_checksum_update(checksum, data, data_len);
-	ret =3D l_checksum_get_digest(checksum, out, hash_len);
+	ret =3D l_checksum_get_digest(checksum, out, HANDSHAKE_HASH_MAX_SIZE);
 	l_checksum_free(checksum);
 =

-	if (ret !=3D (ssize_t) hash_len)
+	if (ret < 0)
 		return false;
 =

 	if (out_len)
-		*out_len =3D hash_len;
-
-	if (type)
-		*type =3D tls_handshake_hash_data[hash].l_id;
+		*out_len =3D ret;
 =

 	return true;
 }
diff --git a/ell/tls.c b/ell/tls.c
index 7a7db34..1e6884e 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1153,28 +1153,20 @@ static void tls_get_handshake_hash(struct l_tls *tl=
s,
 	l_checksum_free(hash);
 }
 =

-static bool tls_get_handshake_hash_by_id(struct l_tls *tls, uint8_t hash_i=
d,
+static bool tls_get_handshake_hash_by_type(struct l_tls *tls,
+					enum handshake_hash_type type,
 					const uint8_t *data, size_t data_len,
-					uint8_t *out, size_t *out_len,
-					enum l_checksum_type *type)
+					uint8_t *out, size_t *out_len)
 {
-	enum handshake_hash_type hash;
-
-	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-		if (tls_handshake_hash_data[hash].tls_id =3D=3D hash_id &&
-				tls->handshake_hash[hash]) {
-			tls_get_handshake_hash(tls, hash, out);
-
-			if (out_len)
-				*out_len =3D tls_handshake_hash_data[hash].length;
-
-			if (type)
-				*type =3D tls_handshake_hash_data[hash].l_id;
+	if (!tls->handshake_hash[type])
+		return false;
 =

-			return true;
-		}
+	if (out_len)
+		*out_len =3D l_checksum_digest_length(
+					tls_handshake_hash_data[type].l_id);
 =

-	return false;
+	tls_get_handshake_hash(tls, type, out);
+	return true;
 }
 =

 static bool tls_send_certificate_verify(struct l_tls *tls)
@@ -1188,7 +1180,8 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls,
 					buf + TLS_HANDSHAKE_HEADER_SIZE,
 					2048 - TLS_HANDSHAKE_HEADER_SIZE,
-					tls_get_handshake_hash_by_id, NULL, 0);
+					tls_get_handshake_hash_by_type,
+					NULL, 0);
 =

 	if (sign_len < 0)
 		return false;
@@ -2008,28 +2001,21 @@ static void tls_handle_server_hello_done(struct l_t=
ls *tls,
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 =

-static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_id,
+static bool tls_get_prev_digest_by_type(struct l_tls *tls,
+					enum handshake_hash_type type,
 					const uint8_t *data, size_t data_len,
-					uint8_t *out, size_t *out_len,
-					enum l_checksum_type *type)
+					uint8_t *out, size_t *out_len)
 {
-	enum handshake_hash_type hash;
 	size_t len;
 =

-	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-		if (tls_handshake_hash_data[hash].tls_id =3D=3D hash_id &&
-				tls->handshake_hash[hash]) {
-			len =3D tls_handshake_hash_data[hash].length;
-			memcpy(out, tls->prev_digest[hash], len);
-
-			if (out_len)
-				*out_len =3D len;
+	if (!tls->handshake_hash[type])
+		return false;
 =

-			if (type)
-				*type =3D tls_handshake_hash_data[hash].l_id;
+	len =3D l_checksum_digest_length(tls_handshake_hash_data[type].l_id);
+	memcpy(out, tls->prev_digest[type], len);
 =

-			return len;
-		}
+	if (out_len)
+		*out_len =3D len;
 =

 	return 0;
 }
@@ -2040,7 +2026,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 	int i;
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-						tls_get_prev_digest_by_id,
+						tls_get_prev_digest_by_type,
 						NULL, 0))
 		return;
 =

-- =

2.19.1


--===============6845473246524527085==--

