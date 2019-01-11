Content-Type: multipart/mixed; boundary="===============8626322522737465316=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] tls: Pass optional data parameter to sign/verify callbacks
Date: Fri, 11 Jan 2019 14:14:29 +0100
Message-ID: <20190111131430.12428-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8626322522737465316==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add parameters to optinally provide a buffer with the data to be
signed/verified to the signature algorithm .sign and .verify functions,
in addition to the current get_hash callback parameter.  Currently .sign
and .verify would receive the get_hash callback and call it when
necessary to obtain the hash of the data being signed.

In the case of the handshake messages signature the hash data is part of
the handshake state so there was no need for additional parameters.
When we're hashing the ServerKeyExchange parameters though there's no
need to keep a buffer of the data around for longer than we're building
or processing the message so there's no point copying it to the
handshake state structs.  So instead we pass that buffer to
.sign/.verify which then passes it to the get_hash callbacks.

This removes some duplication and in case of ECDHE gets rid of two
instances of rebuilding the ServerECDHParams struct unnecessarily.
---
This is to illustrate the possible cleanup in DHE to avoid putting a
pointer to a stack structure in the handshake state.
---
 ell/tls-private.h |   3 +
 ell/tls-suites.c  | 198 ++++++++++++++++++++--------------------------
 ell/tls.c         |   6 +-
 3 files changed, 91 insertions(+), 116 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index c82a4d5..134203f 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -59,6 +59,7 @@ struct tls_hash_algorithm {
 extern const struct tls_hash_algorithm tls_handshake_hash_data[];
 =

 typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
+				const uint8_t *data, size_t data_len,
 				uint8_t *out, size_t *len,
 				enum l_checksum_type *type);
 =

@@ -80,8 +81,10 @@ struct tls_key_exchange_algorithm {
 						const uint8_t *buf, size_t len);
 =

 	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
+			const uint8_t *data, size_t data_len,
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
+			const uint8_t *data, size_t data_len,
 			tls_get_hash_t get_hash);
 =

 	void (*free_params)(struct l_tls *tls);
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index cb1416a..d3c7f8f 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -157,6 +157,7 @@ static void tls_handle_rsa_client_key_xchg(struct l_tls=
 *tls,
 }
 =

 static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
+				const uint8_t *data, size_t data_len,
 				tls_get_hash_t get_hash)
 {
 	ssize_t result =3D -EMSGSIZE;
@@ -180,7 +181,8 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t =
*out, size_t len,
 		if (len < 2)	/* Is there space for the algorithm IDs */
 			goto error;
 =

-		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
+		get_hash(tls, hash_type->tls_id, data, data_len,
+				sign_input, NULL, NULL);
 		sign_checksum_type =3D hash_type->l_id;
 		sign_input_len =3D hash_type->length;
 =

@@ -188,8 +190,10 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t=
 *out, size_t len,
 		*ptr++ =3D 1;	/* RSA_sign */
 		len -=3D 2;
 	} else {
-		get_hash(tls, 1, sign_input + 0, NULL, NULL);	/* MD5 */
-		get_hash(tls, 2, sign_input + 16, NULL, NULL);	/* SHA1 */
+		/* MD5 */
+		get_hash(tls, 1, data, data_len, sign_input + 0, NULL, NULL);
+		/* SHA1 */
+		get_hash(tls, 2, data, data_len, sign_input + 16, NULL, NULL);
 		sign_checksum_type =3D L_CHECKSUM_NONE;
 		sign_input_len =3D 36;
 	}
@@ -214,6 +218,7 @@ error:
 }
 =

 static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
+				const uint8_t *data, size_t data_len,
 				tls_get_hash_t get_hash)
 {
 	enum l_checksum_type hash_type;
@@ -255,8 +260,8 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
t8_t *in, size_t len,
 			return false;
 		}
 =

-		if (!get_hash(tls, in[0], expected, &expected_len,
-				&hash_type)) {
+		if (!get_hash(tls, in[0], data, data_len,
+				expected, &expected_len, &hash_type)) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
 					"Unknown hash type %i", in[0]);
 =

@@ -281,8 +286,10 @@ static bool tls_rsa_verify(struct l_tls *tls, const ui=
nt8_t *in, size_t len,
 		 * encoding.
 		 */
 	} else {
-		get_hash(tls, 1, expected + 0, NULL, NULL);	/* MD5 */
-		get_hash(tls, 2, expected + 16, NULL, NULL);	/* SHA1 */
+		/* MD5 */
+		get_hash(tls, 1, data, data_len, expected + 0, NULL, NULL);
+		/* SHA1 */
+		get_hash(tls, 2, data, data_len, expected + 16, NULL, NULL);
 		expected_len =3D 36;
 		hash_type =3D L_CHECKSUM_NONE;
 =

@@ -322,59 +329,16 @@ static struct tls_key_exchange_algorithm tls_rsa =3D {
 	.verify =3D tls_rsa_verify,
 };
 =

-struct tls_ecdhe_params {
-	const struct l_ecc_curve *curve;
-	struct l_ecc_scalar *private;
-	struct l_ecc_point *public;
-};
-
-static void tls_free_ecdhe_params(struct l_tls *tls)
-{
-	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
-
-	if (!params)
-		return;
-
-	tls->pending.key_xchg_params =3D NULL;
-
-	l_ecc_scalar_free(params->private);
-	l_ecc_point_free(params->public);
-	l_free(params);
-}
-
-static size_t tls_write_ecpoint(uint8_t *buf,
-				const struct tls_named_group *curve,
-				const struct l_ecc_point *point)
-{
-	/* RFC 8422, Section 5.4.1 */
-	buf[0] =3D 1 + curve->ec.point_bytes;	/* length */
-	buf[1] =3D 4;				/* form: uncompressed */
-	return 2 + l_ecc_point_get_data(point, buf + 2, curve->ec.point_bytes);
-}
-
-static size_t tls_write_server_ecdh_params(struct l_tls *tls, uint8_t *buf)
-{
-	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
-
-	/* RFC 8422, Section 5.4 */
-	buf[0] =3D 3;				/* curve_type: named_curve */
-	l_put_be16(tls->negotiated_curve->id, buf + 1);
-	return 3 + tls_write_ecpoint(buf + 3, tls->negotiated_curve,
-					params->public);
-}
-
-static bool tls_get_server_ecdh_params_hash(struct l_tls *tls, uint8_t tls=
_id,
-						uint8_t *out, size_t *len,
-						enum l_checksum_type *type)
+/* Used by both DHE and ECDHE */
+static bool tls_get_dh_params_hash(struct l_tls *tls, uint8_t tls_id,
+					const uint8_t *data, size_t data_len,
+					uint8_t *out, size_t *len,
+					enum l_checksum_type *type)
 {
 	unsigned int hash;
 	struct l_checksum *checksum;
-	uint8_t params[1024];
-	size_t params_len;
 	ssize_t hash_len, ret;
 =

-	params_len =3D tls_write_server_ecdh_params(tls, params);
-
 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		if (tls_handshake_hash_data[hash].tls_id =3D=3D tls_id)
 			break;
@@ -396,7 +360,7 @@ static bool tls_get_server_ecdh_params_hash(struct l_tl=
s *tls, uint8_t tls_id,
 	 */
 	l_checksum_update(checksum, tls->pending.client_random, 32);
 	l_checksum_update(checksum, tls->pending.server_random, 32);
-	l_checksum_update(checksum, params, params_len);
+	l_checksum_update(checksum, data, data_len);
 	ret =3D l_checksum_get_digest(checksum, out, hash_len);
 	l_checksum_free(checksum);
 =

@@ -412,12 +376,54 @@ static bool tls_get_server_ecdh_params_hash(struct l_=
tls *tls, uint8_t tls_id,
 	return true;
 }
 =

+struct tls_ecdhe_params {
+	const struct l_ecc_curve *curve;
+	struct l_ecc_scalar *private;
+	struct l_ecc_point *public;
+};
+
+static void tls_free_ecdhe_params(struct l_tls *tls)
+{
+	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
+
+	if (!params)
+		return;
+
+	tls->pending.key_xchg_params =3D NULL;
+
+	l_ecc_scalar_free(params->private);
+	l_ecc_point_free(params->public);
+	l_free(params);
+}
+
+static size_t tls_write_ecpoint(uint8_t *buf,
+				const struct tls_named_group *curve,
+				const struct l_ecc_point *point)
+{
+	/* RFC 8422, Section 5.4.1 */
+	buf[0] =3D 1 + curve->ec.point_bytes;	/* length */
+	buf[1] =3D 4;				/* form: uncompressed */
+	return 2 + l_ecc_point_get_data(point, buf + 2, curve->ec.point_bytes);
+}
+
+static size_t tls_write_server_ecdh_params(struct l_tls *tls, uint8_t *buf)
+{
+	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
+
+	/* RFC 8422, Section 5.4 */
+	buf[0] =3D 3;				/* curve_type: named_curve */
+	l_put_be16(tls->negotiated_curve->id, buf + 1);
+	return 3 + tls_write_ecpoint(buf + 3, tls->negotiated_curve,
+					params->public);
+}
+
 static bool tls_send_ecdhe_server_key_xchg(struct l_tls *tls)
 {
 	uint8_t buf[1024];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
 	struct tls_ecdhe_params *params;
 	ssize_t sign_len;
+	const uint8_t *server_ecdh_params_ptr;
 =

 	/*
 	 * RFC 8422, Section 5.4
@@ -438,11 +444,14 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_t=
ls *tls)
 		return false;
 	}
 =

+	server_ecdh_params_ptr =3D ptr;
 	ptr +=3D tls_write_server_ecdh_params(tls, ptr);
 =

 	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
-					buf + sizeof(buf) - ptr,
-					tls_get_server_ecdh_params_hash);
+						buf + sizeof(buf) - ptr,
+						server_ecdh_params_ptr,
+						ptr - server_ecdh_params_ptr,
+						tls_get_dh_params_hash);
 	if (sign_len < 0)
 		return false;
 =

@@ -458,6 +467,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 {
 	struct tls_ecdhe_params *params;
 	uint16_t namedcurve;
+	const uint8_t *server_ecdh_params_ptr =3D buf;
 =

 	/* RFC 8422, Section 5.4 */
 =

@@ -525,7 +535,9 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	}
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-					tls_get_server_ecdh_params_hash))
+						server_ecdh_params_ptr,
+						buf - server_ecdh_params_ptr,
+						tls_get_dh_params_hash))
 		return;
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
@@ -698,8 +710,6 @@ struct tls_dhe_params {
 	struct l_key *generator;
 	struct l_key *private;
 	struct l_key *public;
-	const uint8_t *server_dh_params_buf;
-	size_t server_dh_params_len;
 };
 =

 static void tls_free_dhe_params(struct l_tls *tls)
@@ -718,47 +728,6 @@ static void tls_free_dhe_params(struct l_tls *tls)
 	l_free(params);
 }
 =

-static bool tls_get_server_dh_params_hash(struct l_tls *tls, uint8_t tls_i=
d,
-						uint8_t *out, size_t *len,
-						enum l_checksum_type *type)
-{
-	unsigned int hash;
-	struct l_checksum *checksum;
-	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
-	ssize_t hash_len, ret;
-
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
-	if (!checksum)
-		return false;
-
-	l_checksum_update(checksum, tls->pending.client_random, 32);
-	l_checksum_update(checksum, tls->pending.server_random, 32);
-	l_checksum_update(checksum, params->server_dh_params_buf,
-				params->server_dh_params_len);
-	ret =3D l_checksum_get_digest(checksum, out, hash_len);
-	l_checksum_free(checksum);
-
-	if (ret !=3D (ssize_t) hash_len)
-		return false;
-
-	if (len)
-		*len =3D hash_len;
-
-	if (type)
-		*type =3D tls_handshake_hash_data[hash].l_id;
-
-	return true;
-}
-
 static bool tls_send_dhe_server_key_xchg(struct l_tls *tls)
 {
 	uint8_t buf[1024 + TLS_DHE_MAX_SIZE * 3];
@@ -770,6 +739,7 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls *=
tls)
 	size_t public_len;
 	unsigned int zeros =3D 0;
 	ssize_t sign_len;
+	const uint8_t *server_dh_params_ptr;
 =

 	params =3D l_new(struct tls_dhe_params, 1);
 	prime_buf =3D tls->negotiated_ff_group->ff.prime;
@@ -803,7 +773,7 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls *=
tls)
 	while (zeros < public_len && public_buf[zeros] =3D=3D 0x00)
 		zeros++;
 =

-	params->server_dh_params_buf =3D ptr;
+	server_dh_params_ptr =3D ptr;
 =

 	/* RFC 5246, Section 7.4.3 */
 =

@@ -819,16 +789,17 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls=
 *tls)
 	memcpy(ptr + 2, public_buf + zeros, public_len - zeros);
 	ptr +=3D 2 + public_len - zeros;
 =

-	params->server_dh_params_len =3D ptr - params->server_dh_params_buf;
-	tls->pending.key_xchg_params =3D params;
-
 	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
-					buf + sizeof(buf) - ptr,
-					tls_get_server_dh_params_hash);
+						buf + sizeof(buf) - ptr,
+						server_dh_params_ptr,
+						ptr - server_dh_params_ptr,
+						tls_get_dh_params_hash);
 	if (sign_len < 0)
-		return false;
+		goto free_params;
 =

 	ptr +=3D sign_len;
+	tls->pending.key_xchg_params =3D params;
+
 	tls_tx_handshake(tls, TLS_SERVER_KEY_EXCHANGE, buf, ptr - buf);
 	return true;
 =

@@ -849,13 +820,12 @@ static void tls_handle_dhe_server_key_xchg(struct l_t=
ls *tls,
 	size_t generator_len;
 	const uint8_t *public_buf;
 	size_t public_len;
+	const uint8_t *server_dh_params_ptr =3D buf;
 =

 	if (len < 2)
 		goto decode_error;
 =

 	params =3D l_new(struct tls_dhe_params, 1);
-	params->server_dh_params_buf =3D buf;
-
 	params->prime_len =3D l_get_be16(buf);
 	if (len < 2 + params->prime_len + 2)
 		goto decode_error;
@@ -886,8 +856,6 @@ static void tls_handle_dhe_server_key_xchg(struct l_tls=
 *tls,
 	buf +=3D 2 + public_len;
 	len -=3D 2 + public_len;
 =

-	params->server_dh_params_len =3D buf - params->server_dh_params_buf;
-
 	/*
 	 * Validate the values received.  Without requiring RFC 7919 from
 	 * the server, and there are many servers that don't implement it
@@ -958,7 +926,9 @@ static void tls_handle_dhe_server_key_xchg(struct l_tls=
 *tls,
 	tls->pending.key_xchg_params =3D params;
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-						tls_get_server_dh_params_hash))
+						server_dh_params_ptr,
+						buf - server_dh_params_ptr,
+						tls_get_dh_params_hash))
 		return;
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
diff --git a/ell/tls.c b/ell/tls.c
index f9e1e95..6e8c968 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1143,6 +1143,7 @@ static void tls_get_handshake_hash(struct l_tls *tls,
 }
 =

 static bool tls_get_handshake_hash_by_id(struct l_tls *tls, uint8_t hash_i=
d,
+					const uint8_t *data, size_t data_len,
 					uint8_t *out, size_t *len,
 					enum l_checksum_type *type)
 {
@@ -1176,7 +1177,7 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls,
 					buf + TLS_HANDSHAKE_HEADER_SIZE,
 					2048 - TLS_HANDSHAKE_HEADER_SIZE,
-					tls_get_handshake_hash_by_id);
+					NULL, 0, tls_get_handshake_hash_by_id);
 =

 	if (sign_len < 0)
 		return false;
@@ -1997,6 +1998,7 @@ static void tls_handle_server_hello_done(struct l_tls=
 *tls,
 }
 =

 static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_id,
+					const uint8_t *data, size_t data_len,
 					uint8_t *out, size_t *out_len,
 					enum l_checksum_type *type)
 {
@@ -2026,7 +2028,7 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 {
 	int i;
 =

-	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
+	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len, NULL, 0,
 						tls_get_prev_digest_by_id))
 		return;
 =

-- =

2.19.1


--===============8626322522737465316==--

