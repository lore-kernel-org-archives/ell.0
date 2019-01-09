Content-Type: multipart/mixed; boundary="===============4977735332723936292=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] tls: DHE_RSA key exchange implementation client side
Date: Wed, 09 Jan 2019 11:43:47 +0100
Message-ID: <20190109104349.11763-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190109104349.11763-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4977735332723936292==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a new key exchange definition with the callbacks needed to handle the
client side of the DHE_RSA key exchange.
---
 ell/tls-suites.c | 261 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 261 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index af8cbcd..14ea470 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -688,6 +688,267 @@ static struct tls_key_exchange_algorithm tls_ecdhe_rs=
a =3D {
 	.verify =3D tls_rsa_verify,
 };
 =

+/* Maximum FF DH prime modulus size in bytes */
+#define TLS_DHE_MAX_SIZE 1024
+
+struct tls_dhe_params {
+	size_t prime_len;
+	struct l_key *prime;
+	struct l_key *generator;
+	struct l_key *private;
+	struct l_key *public;
+	const uint8_t *server_dh_params_buf;
+	size_t server_dh_params_len;
+};
+
+static void tls_free_dhe_params(struct l_tls *tls)
+{
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+
+	if (!params)
+		return;
+
+	tls->pending.key_xchg_params =3D NULL;
+
+	l_key_free(params->prime);
+	l_key_free(params->generator);
+	l_key_free(params->private);
+	l_key_free(params->public);
+	l_free(params);
+}
+
+static bool tls_get_server_dh_params_hash(struct l_tls *tls, uint8_t tls_i=
d,
+						uint8_t *out, size_t *len,
+						enum l_checksum_type *type)
+{
+	unsigned int hash;
+	struct l_checksum *checksum;
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
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
+	l_checksum_update(checksum, tls->pending.client_random, 32);
+	l_checksum_update(checksum, tls->pending.server_random, 32);
+	l_checksum_update(checksum, params->server_dh_params_buf,
+				params->server_dh_params_len);
+	ret =3D l_checksum_get_digest(checksum, out, hash_len);
+	l_checksum_free(checksum);
+
+	if (ret !=3D (ssize_t) hash_len)
+		return false;
+
+	if (len)
+		*len =3D hash_len;
+
+	if (type)
+		*type =3D tls_handshake_hash_data[hash].l_id;
+
+	return true;
+}
+
+static void tls_handle_dhe_server_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	struct tls_dhe_params *params =3D NULL;
+	const uint8_t *prime_buf;
+	const uint8_t *generator_buf;
+	size_t generator_len;
+	const uint8_t *public_buf;
+	size_t public_len;
+
+	if (len < 2)
+		goto decode_error;
+
+	params =3D l_new(struct tls_dhe_params, 1);
+	params->server_dh_params_buf =3D buf;
+
+	params->prime_len =3D l_get_be16(buf);
+	if (len < 2 + params->prime_len + 2)
+		goto decode_error;
+
+	prime_buf =3D buf + 2;
+	buf +=3D 2 + params->prime_len;
+	len -=3D 2 + params->prime_len;
+
+	/* Strip leading zeros for the length checks later */
+	while (params->prime_len && prime_buf[0] =3D=3D 0x00) {
+		prime_buf++;
+		params->prime_len--;
+	}
+
+	generator_len =3D l_get_be16(buf);
+	if (len < 2 + generator_len + 2)
+		goto decode_error;
+
+	generator_buf =3D buf + 2;
+	buf +=3D 2 + generator_len;
+	len -=3D 2 + generator_len;
+
+	public_len =3D l_get_be16(buf);
+	if (len < 2 + public_len)
+		goto decode_error;
+
+	public_buf =3D buf + 2;
+	buf +=3D 2 + public_len;
+	len -=3D 2 + public_len;
+
+	params->server_dh_params_len =3D buf - params->server_dh_params_buf;
+
+	/*
+	 * Validate the values received.  Without RFC 7919 we basically have
+	 * to blindly accept the provided prime value.  We have no way to
+	 * confirm that it's actually prime or that it's a "safe prime" or
+	 * that it forms a group without small sub-groups.  There's also no
+	 * way to whitelist all valid values.  But we do a basic sanity
+	 * check and require it to be 1024-bit or longer (see weakdh.org),
+	 * might need to move to 2048 bits actually.
+	 * The generator must also be at least within the min & max interval
+	 * for the private/public values.
+	 */
+
+	if (params->prime_len > TLS_DHE_MAX_SIZE || params->prime_len < 128 ||
+			!(prime_buf[params->prime_len - 1] & 1)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH prime modulus invalid");
+		goto free_params;
+	}
+
+	if (!l_key_validate_dh_payload(generator_buf, generator_len,
+					prime_buf, params->prime_len)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH generator value invalid");
+		goto free_params;
+	}
+
+	/*
+	 * RFC 7919 Section 3.0:
+	 * "the client MUST verify that dh_Ys is in the range
+	 * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the client
+	 * MUST terminate the connection with a fatal handshake_failure(40)
+	 * alert."
+	 */
+	if (!l_key_validate_dh_payload(public_buf, public_len,
+					prime_buf, params->prime_len)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH public value invalid");
+		goto free_params;
+	}
+
+	params->prime =3D l_key_new(L_KEY_RAW, prime_buf, params->prime_len);
+	params->generator =3D l_key_new(L_KEY_RAW, generator_buf, generator_len);
+	params->public =3D l_key_new(L_KEY_RAW, public_buf, public_len);
+
+	if (!params->prime || !params->generator || !params->public) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0, "l_key_new failed");
+		goto free_params;
+	}
+
+	/* Do this now so we don't need prime_buf in send_client_key_xchg */
+	params->private =3D l_key_generate_dh_private(prime_buf, params->prime_le=
n);
+	if (!params->private) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"l_key_generate_dh_private failed");
+		goto free_params;
+	}
+
+	tls->pending.key_xchg_params =3D params;
+
+	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
+						tls_get_server_dh_params_hash))
+		return;
+
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
+	return;
+
+decode_error:
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"ServerKeyExchange decode error");
+
+free_params:
+	if (params) {
+		l_key_free(params->prime);
+		l_key_free(params->generator);
+		l_key_free(params->public);
+		l_free(params);
+	}
+}
+
+static bool tls_send_dhe_client_key_xchg(struct l_tls *tls)
+{
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+	uint8_t buf[128 + params->prime_len];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t public_buf[params->prime_len];
+	size_t public_len;
+	unsigned int zeros =3D 0;
+	uint8_t pre_master_secret[params->prime_len];
+	size_t pre_master_secret_len;
+
+	public_len =3D params->prime_len;
+
+	if (!l_key_compute_dh_public(params->generator, params->private,
+					params->prime, public_buf,
+					&public_len)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"l_key_compute_dh_public failed");
+		return false;
+	}
+
+	while (zeros < public_len && public_buf[zeros] =3D=3D 0x00)
+		zeros++;
+
+	l_put_be16(public_len - zeros, ptr);
+	memcpy(ptr + 2, public_buf + zeros, public_len - zeros);
+	ptr +=3D 2 + public_len - zeros;
+
+	pre_master_secret_len =3D params->prime_len;
+	zeros =3D 0;
+
+	if (!l_key_compute_dh_secret(params->public, params->private,
+					params->prime, pre_master_secret,
+					&pre_master_secret_len)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating DH shared-secret failed");
+		return false;
+	}
+
+	while (zeros < pre_master_secret_len &&
+			pre_master_secret[zeros] =3D=3D 0x00)
+		zeros++;
+
+	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
+
+	tls_free_dhe_params(tls);
+	tls_generate_master_secret(tls, pre_master_secret + zeros,
+					pre_master_secret_len - zeros);
+	memset(pre_master_secret, 0, pre_master_secret_len);
+	return true;
+}
+
+static struct tls_key_exchange_algorithm tls_dhe_rsa =3D {
+	.id =3D 1, /* RSA_sign */
+	.certificate_check =3D true,
+	.need_ecc =3D true,
+	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.handle_server_key_exchange =3D tls_handle_dhe_server_key_xchg,
+	.send_client_key_exchange =3D tls_send_dhe_client_key_xchg,
+	.free_params =3D tls_free_dhe_params,
+	.sign =3D tls_rsa_sign,
+	.verify =3D tls_rsa_verify,
+};
+
 static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
 	.cipher_type =3D TLS_CIPHER_STREAM,
 	.l_id =3D L_CIPHER_ARC4,
-- =

2.19.1


--===============4977735332723936292==--

