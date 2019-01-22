Content-Type: multipart/mixed; boundary="===============2838666524468228238=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/9] tls: Pass optional data parameter to sign/verify callbacks
Date: Tue, 22 Jan 2019 07:08:59 +0100
Message-ID: <20190122060905.27452-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2838666524468228238==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add parameters to optionally provide a buffer with the data to be
signed/verified to the signature algorithm .sign and .verify methods,
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
 ell/tls-private.h |  13 +--
 ell/tls-suites.c  | 223 ++++++++++++++++++++--------------------------
 ell/tls.c         |  13 +--
 3 files changed, 113 insertions(+), 136 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index d4b3ba4..1adc389 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -52,7 +52,8 @@ struct tls_hash_algorithm {
 extern const struct tls_hash_algorithm tls_handshake_hash_data[];
 =

 typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
-				uint8_t *out, size_t *len,
+				const uint8_t *data, size_t data_len,
+				uint8_t *out, size_t *out_len,
 				enum l_checksum_type *type);
 =

 struct tls_key_exchange_algorithm {
@@ -72,10 +73,12 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

-	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
-			tls_get_hash_t get_hash);
-	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
-			tls_get_hash_t get_hash);
+	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t out_len,
+			tls_get_hash_t get_hash,
+			const uint8_t *data, size_t data_len);
+	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t in_len,
+			tls_get_hash_t get_hash,
+			const uint8_t *data, size_t data_len);
 =

 	void (*free_params)(struct l_tls *tls);
 };
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index ff61544..897bbee 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -156,8 +156,9 @@ static void tls_handle_rsa_client_key_xchg(struct l_tls=
 *tls,
 	memset(random_secret, 0, 46);
 }
 =

-static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t len,
-				tls_get_hash_t get_hash)
+static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_t *out, size_t out_le=
n,
+				tls_get_hash_t get_hash,
+				const uint8_t *data, size_t data_len)
 {
 	ssize_t result =3D -EMSGSIZE;
 	enum l_checksum_type sign_checksum_type;
@@ -177,24 +178,27 @@ static ssize_t tls_rsa_sign(struct l_tls *tls, uint8_=
t *out, size_t len,
 			&tls_handshake_hash_data[tls->signature_hash];
 =

 		/* Build the DigitallySigned struct */
-		if (len < 2)	/* Is there space for the algorithm IDs */
+		if (out_len < 2) /* Is there space for the algorithm IDs */
 			goto error;
 =

-		get_hash(tls, hash_type->tls_id, sign_input, NULL, NULL);
+		get_hash(tls, hash_type->tls_id, data, data_len,
+				sign_input, NULL, NULL);
 		sign_checksum_type =3D hash_type->l_id;
 		sign_input_len =3D hash_type->length;
 =

 		*ptr++ =3D hash_type->tls_id;
 		*ptr++ =3D 1;	/* RSA_sign */
-		len -=3D 2;
+		out_len -=3D 2;
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
 =

-	if (len < tls->priv_key_size + 2)
+	if (out_len < tls->priv_key_size + 2)
 		goto error;
 =

 	l_put_be16(tls->priv_key_size, ptr);
@@ -213,8 +217,9 @@ error:
 	return result;
 }
 =

-static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t le=
n,
-				tls_get_hash_t get_hash)
+static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in=
_len,
+				tls_get_hash_t get_hash,
+				const uint8_t *data, size_t data_len)
 {
 	enum l_checksum_type hash_type;
 	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
@@ -227,19 +232,20 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 	if (tls->negotiated_version < L_TLS_V12)
 		offset =3D 0;
 =

-	if (len < offset + 2 ||
-			(size_t) l_get_be16(in + offset) + offset + 2 !=3D len) {
+	if (in_len < offset + 2 ||
+			(size_t) l_get_be16(in + offset) + offset + 2 !=3D
+			in_len) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
 				"short (%zi) or signature length doesn't match",
-				len);
+				in_len);
 =

 		return false;
 	}
 =

 	/* Only the default hash type supported */
-	if (len !=3D offset + 2 + tls->peer_pubkey_size) {
+	if (in_len !=3D offset + 2 + tls->peer_pubkey_size) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"Signature length %zi not equal %zi", len,
+				"Signature length %zi not equal %zi", in_len,
 				offset + 2 + tls->peer_pubkey_size);
 =

 		return false;
@@ -255,8 +261,8 @@ static bool tls_rsa_verify(struct l_tls *tls, const uin=
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

@@ -281,8 +287,10 @@ static bool tls_rsa_verify(struct l_tls *tls, const ui=
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

@@ -322,6 +330,53 @@ static struct tls_key_exchange_algorithm tls_rsa =3D {
 	.verify =3D tls_rsa_verify,
 };
 =

+/* Used by both DHE and ECDHE */
+static bool tls_get_dh_params_hash(struct l_tls *tls, uint8_t tls_id,
+					const uint8_t *data, size_t data_len,
+					uint8_t *out, size_t *out_len,
+					enum l_checksum_type *type)
+{
+	unsigned int hash;
+	struct l_checksum *checksum;
+	ssize_t hash_len, ret;
+
+	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+		if (tls_handshake_hash_data[hash].tls_id =3D=3D tls_id)
+			break;
+
+	if (hash =3D=3D __HANDSHAKE_HASH_COUNT)
+		return false;
+
+	hash_len =3D tls_handshake_hash_data[hash].length;
+
+	checksum =3D l_checksum_new(tls_handshake_hash_data[hash].l_id);
+	if (!checksum)
+		return false;
+
+	/*
+	 * The ServerKeyExchange signature hash input format for RSA_sign is
+	 * not really specified in either RFC 8422 or RFC 5246 explicitly
+	 * but we use this format by analogy to DHE_RSA which uses RSA_sign
+	 * as well.  Also matches ecdsa, ed25519 and ed448 formats.
+	 */
+	l_checksum_update(checksum, tls->pending.client_random, 32);
+	l_checksum_update(checksum, tls->pending.server_random, 32);
+	l_checksum_update(checksum, data, data_len);
+	ret =3D l_checksum_get_digest(checksum, out, hash_len);
+	l_checksum_free(checksum);
+
+	if (ret !=3D (ssize_t) hash_len)
+		return false;
+
+	if (out_len)
+		*out_len =3D hash_len;
+
+	if (type)
+		*type =3D tls_handshake_hash_data[hash].l_id;
+
+	return true;
+}
+
 struct tls_ecdhe_params {
 	const struct l_ecc_curve *curve;
 	struct l_ecc_scalar *private;
@@ -363,61 +418,13 @@ static size_t tls_write_server_ecdh_params(struct l_t=
ls *tls, uint8_t *buf)
 					params->public);
 }
 =

-static bool tls_get_server_ecdh_params_hash(struct l_tls *tls, uint8_t tls=
_id,
-						uint8_t *out, size_t *len,
-						enum l_checksum_type *type)
-{
-	unsigned int hash;
-	struct l_checksum *checksum;
-	uint8_t params[1024];
-	size_t params_len;
-	ssize_t hash_len, ret;
-
-	params_len =3D tls_write_server_ecdh_params(tls, params);
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
-	/*
-	 * The ServerKeyExchange signature hash input format for RSA_sign is
-	 * not really specified in either RFC 8422 or RFC 5246 explicitly
-	 * but we use this format by analogy to DHE_RSA which uses RSA_sign
-	 * as well.  Also matches ecdsa, ed25519 and ed448 formats.
-	 */
-	l_checksum_update(checksum, tls->pending.client_random, 32);
-	l_checksum_update(checksum, tls->pending.server_random, 32);
-	l_checksum_update(checksum, params, params_len);
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
@@ -438,11 +445,14 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_t=
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
+						tls_get_dh_params_hash,
+						server_ecdh_params_ptr,
+						ptr - server_ecdh_params_ptr);
 	if (sign_len < 0)
 		return false;
 =

@@ -458,6 +468,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 {
 	struct tls_ecdhe_params *params;
 	uint16_t namedcurve;
+	const uint8_t *server_ecdh_params_ptr =3D buf;
 =

 	/* RFC 8422, Section 5.4 */
 =

@@ -525,7 +536,9 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	}
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-					tls_get_server_ecdh_params_hash))
+						tls_get_dh_params_hash,
+						server_ecdh_params_ptr,
+						buf - server_ecdh_params_ptr))
 		return;
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
@@ -698,8 +711,6 @@ struct tls_dhe_params {
 	struct l_key *generator;
 	struct l_key *private;
 	struct l_key *public;
-	const uint8_t *server_dh_params_buf;
-	size_t server_dh_params_len;
 };
 =

 static void tls_free_dhe_params(struct l_tls *tls)
@@ -718,47 +729,6 @@ static void tls_free_dhe_params(struct l_tls *tls)
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
@@ -770,6 +740,7 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls *=
tls)
 	size_t public_len;
 	unsigned int zeros =3D 0;
 	ssize_t sign_len;
+	const uint8_t *server_dh_params_ptr;
 =

 	params =3D l_new(struct tls_dhe_params, 1);
 	prime_buf =3D tls->negotiated_ff_group->ff.prime;
@@ -803,7 +774,7 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls *=
tls)
 	while (zeros < public_len && public_buf[zeros] =3D=3D 0x00)
 		zeros++;
 =

-	params->server_dh_params_buf =3D ptr;
+	server_dh_params_ptr =3D ptr;
 =

 	/* RFC 5246, Section 7.4.3 */
 =

@@ -819,16 +790,17 @@ static bool tls_send_dhe_server_key_xchg(struct l_tls=
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
+						tls_get_dh_params_hash,
+						server_dh_params_ptr,
+						ptr - server_dh_params_ptr);
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

@@ -849,13 +821,12 @@ static void tls_handle_dhe_server_key_xchg(struct l_t=
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
@@ -886,8 +857,6 @@ static void tls_handle_dhe_server_key_xchg(struct l_tls=
 *tls,
 	buf +=3D 2 + public_len;
 	len -=3D 2 + public_len;
 =

-	params->server_dh_params_len =3D buf - params->server_dh_params_buf;
-
 	/*
 	 * Validate the values received.  Without requiring RFC 7919 from
 	 * the server, and there are many servers that don't implement it
@@ -958,7 +927,9 @@ static void tls_handle_dhe_server_key_xchg(struct l_tls=
 *tls,
 	tls->pending.key_xchg_params =3D params;
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-						tls_get_server_dh_params_hash))
+						tls_get_dh_params_hash,
+						server_dh_params_ptr,
+						buf - server_dh_params_ptr))
 		return;
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
diff --git a/ell/tls.c b/ell/tls.c
index 1f5a757..7a7db34 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1154,7 +1154,8 @@ static void tls_get_handshake_hash(struct l_tls *tls,
 }
 =

 static bool tls_get_handshake_hash_by_id(struct l_tls *tls, uint8_t hash_i=
d,
-					uint8_t *out, size_t *len,
+					const uint8_t *data, size_t data_len,
+					uint8_t *out, size_t *out_len,
 					enum l_checksum_type *type)
 {
 	enum handshake_hash_type hash;
@@ -1164,8 +1165,8 @@ static bool tls_get_handshake_hash_by_id(struct l_tls=
 *tls, uint8_t hash_id,
 				tls->handshake_hash[hash]) {
 			tls_get_handshake_hash(tls, hash, out);
 =

-			if (len)
-				*len =3D tls_handshake_hash_data[hash].length;
+			if (out_len)
+				*out_len =3D tls_handshake_hash_data[hash].length;
 =

 			if (type)
 				*type =3D tls_handshake_hash_data[hash].l_id;
@@ -1187,7 +1188,7 @@ static bool tls_send_certificate_verify(struct l_tls =
*tls)
 	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls,
 					buf + TLS_HANDSHAKE_HEADER_SIZE,
 					2048 - TLS_HANDSHAKE_HEADER_SIZE,
-					tls_get_handshake_hash_by_id);
+					tls_get_handshake_hash_by_id, NULL, 0);
 =

 	if (sign_len < 0)
 		return false;
@@ -2008,6 +2009,7 @@ static void tls_handle_server_hello_done(struct l_tls=
 *tls,
 }
 =

 static bool tls_get_prev_digest_by_id(struct l_tls *tls, uint8_t hash_id,
+					const uint8_t *data, size_t data_len,
 					uint8_t *out, size_t *out_len,
 					enum l_checksum_type *type)
 {
@@ -2038,7 +2040,8 @@ static void tls_handle_certificate_verify(struct l_tl=
s *tls,
 	int i;
 =

 	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
-						tls_get_prev_digest_by_id))
+						tls_get_prev_digest_by_id,
+						NULL, 0))
 		return;
 =

 	/* Stop maintaining handshake message hashes other than the PRF hash */
-- =

2.19.1


--===============2838666524468228238==--

