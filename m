Content-Type: multipart/mixed; boundary="===============8259645180798729072=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 14/17] tls: DHE_RSA key exchange implementation client side
Date: Tue, 01 Jan 2019 20:49:36 +0100
Message-ID: <20190101194939.5974-14-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8259645180798729072==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a new key exchange definition with the callbacks needed to handle the
client side of the DHE_RSA key exchange.
---
 ell/tls-suites.c | 354 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 354 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index af8cbcd..ef1f2cc 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -688,6 +688,360 @@ static struct tls_key_exchange_algorithm tls_ecdhe_rs=
a =3D {
 	.verify =3D tls_rsa_verify,
 };
 =

+struct tls_dhe_params {
+	/*
+	 * We need both the raw contents here for tls_write_server_dh_params
+	 * and the l_key pointers to cache the l_keys created for the
+	 * ServerKeyExchange and not have to allocate them again during
+	 * ClientKeyExchange.  public_buf is used for both our and the
+	 * peer's DH public value while public is only used for the peer's
+	 * public value.
+	 */
+	struct l_key *prime;
+	uint8_t *prime_buf;
+	size_t prime_len;
+	struct l_key *generator;
+	uint8_t *generator_buf;
+	size_t generator_len;
+	struct l_key *private;
+	const uint8_t *private_buf;
+	size_t private_len;
+	struct l_key *public;
+	const uint8_t *public_buf;
+	size_t public_len;
+};
+
+#define TLS_DHE_MAX_SIZE 1024
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
+	l_free(params->prime_buf);
+	l_free(params->generator_buf);
+	l_key_free(params->prime);
+	l_key_free(params->generator);
+	l_key_free(params->private);
+	l_key_free(params->public);
+	l_free(params);
+}
+
+static bool tls_create_dhe_keys(struct l_tls *tls)
+{
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+
+	if (!params)
+		return false;
+
+	if (params->prime_buf && !params->prime) {
+		params->prime =3D l_key_new(L_KEY_RAW, params->prime_buf,
+						params->prime_len);
+		if (!params->prime) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"l_key_new(prime) failed");
+			return false;
+		}
+	}
+
+	if (params->generator_buf && !params->generator) {
+		params->generator =3D l_key_new(L_KEY_RAW, params->generator_buf,
+						params->generator_len);
+		if (!params->generator) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"l_key_new(generator) failed");
+			return false;
+		}
+	}
+
+	if (params->private_buf && !params->private) {
+		params->private =3D l_key_new(L_KEY_RAW, params->private_buf,
+						params->private_len);
+		if (!params->private) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"l_key_new(private) failed");
+			return false;
+		}
+	}
+
+	if (params->public_buf && !params->public) {
+		params->public =3D l_key_new(L_KEY_RAW, params->public_buf,
+						params->public_len);
+		if (!params->public) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"l_key_new(public) failed");
+			return false;
+		}
+	}
+
+	return true;
+}
+
+static bool tls_generate_dhe_private(struct l_tls *tls, uint8_t *buf, size=
_t len)
+{
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+
+	do {
+		unsigned int written =3D 0;
+
+		/* Leading zeros in the private value are fine */
+
+		do {
+			size_t chunk_len =3D
+				written + 256 <=3D len ? 256 : len - written;
+
+			if (!l_getrandom(buf + written, chunk_len)) {
+				TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+						"l_getrandom(buf, %zu) failed",
+						chunk_len);
+				return false;
+			}
+
+			written +=3D chunk_len;
+		} while (written < len);
+	} while (!l_key_validate_dh_payload(buf, len,
+						params->prime_buf,
+						params->prime_len));
+
+	return true;
+}
+
+static size_t tls_write_server_dh_params(struct l_tls *tls, uint8_t *buf)
+{
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+	uint8_t *ptr =3D buf;
+
+	/* RFC 5246, Section 7.4.3 */
+
+	l_put_be16(params->prime_len, ptr);
+	memcpy(ptr + 2, params->prime_buf, params->prime_len);
+	ptr +=3D 2 + params->prime_len;
+
+	l_put_be16(params->generator_len, ptr);
+	memcpy(ptr + 2, params->generator_buf, params->generator_len);
+	ptr +=3D 2 + params->generator_len;
+
+	l_put_be16(params->public_len, ptr);
+	memcpy(ptr + 2, params->public_buf, params->public_len);
+	ptr +=3D 2 + params->public_len;
+
+	return ptr - buf;
+}
+
+static bool tls_get_server_dh_params_hash(struct l_tls *tls, uint8_t tls_i=
d,
+						uint8_t *out, size_t *len,
+						enum l_checksum_type *type)
+{
+	unsigned int hash;
+	struct l_checksum *checksum;
+	uint8_t params[32 + TLS_DHE_MAX_SIZE * 3];
+	size_t params_len;
+	ssize_t hash_len, ret;
+
+	params_len =3D tls_write_server_dh_params(tls, params);
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
+	l_checksum_update(checksum, params, params_len);
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
+	struct tls_dhe_params *params;
+
+	params =3D l_new(struct tls_dhe_params, 1);
+	tls->pending.key_xchg_params =3D params;
+
+	if (len < 2)
+		goto decode_error;
+
+	params->prime_len =3D l_get_be16(buf);
+	if (len < 2 + params->prime_len + 2)
+		goto decode_error;
+
+	params->prime_buf =3D l_memdup(buf + 2, params->prime_len);
+	buf +=3D 2 + params->prime_len;
+	len -=3D 2 + params->prime_len;
+
+	params->generator_len =3D l_get_be16(buf);
+	if (len < 2 + params->generator_len + 2)
+		goto decode_error;
+
+	params->generator_buf =3D l_memdup(buf + 2, params->generator_len);;
+	buf +=3D 2 + params->generator_len;
+	len -=3D 2 + params->generator_len;
+
+	params->public_len =3D l_get_be16(buf);
+	if (len < 2 + params->public_len)
+		goto decode_error;
+
+	params->public_buf =3D buf + 2;
+	buf +=3D 2 + params->public_len;
+	len -=3D 2 + params->public_len;
+
+	/*
+	 * Validate the values received.  Without RFC 7919 we basically have
+	 * to blindly accept the provided prime value.  We have no way to
+	 * confirm that it's actually prime or that it's a "safe prime" or
+	 * that it forms a group without small sub-groups.  There's also no
+	 * way to whitelist all valid values.  But we do a basic sanity
+	 * check and require it to be 1024-bit or longer (see weakdh.org),
+	 * might need to move to 2048 bits actually.
+	 */
+
+	if (params->prime_len > TLS_DHE_MAX_SIZE ||
+			params->generator_len > params->prime_len) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH prime modulus or generator "
+				"too long");
+		return;
+	}
+
+	if (params->prime_len < 128 || params->prime_buf[0] =3D=3D 0x00 ||
+			!(params->prime_buf[params->prime_len - 1] & 1)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH prime modulus invalid");
+		return;
+	}
+
+	/*
+	 * RFC 7919 Section 3.0:
+	 * "the client MUST verify that dh_Ys is in the range
+	 * 1 < dh_Ys < dh_p - 1.  If dh_Ys is not in this range, the client
+	 * MUST terminate the connection with a fatal handshake_failure(40)
+	 * alert."
+	 */
+	if (params->public_len > params->prime_len ||
+			!l_key_validate_dh_payload(params->public_buf,
+							params->public_len,
+							params->prime_buf,
+							params->prime_len)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Server DH public value invalid");
+		return;
+	}
+
+	if (!tls_create_dhe_keys(tls))
+		return;
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
+}
+
+static bool tls_send_dhe_client_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[128 + TLS_DHE_MAX_SIZE];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	struct tls_dhe_params *params =3D tls->pending.key_xchg_params;
+	uint8_t pre_master_secret[params->prime_len];
+	size_t pre_master_secret_len;
+	unsigned int offset =3D 0;
+	uint8_t private_buf[params->prime_len];
+	uint8_t public_buf[params->prime_len];
+
+	if (!tls_generate_dhe_private(tls, private_buf, params->prime_len))
+		return false;
+
+	params->private_buf =3D private_buf;
+	params->private_len =3D params->prime_len;
+
+	if (!tls_create_dhe_keys(tls))
+		return false;
+
+	memset(private_buf, 0, params->private_len);
+	params->public_buf =3D public_buf;
+	params->public_len =3D params->prime_len;
+
+	if (!l_key_compute_dh_public(params->generator, params->private,
+					params->prime, public_buf,
+					&params->public_len)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"l_key_compute_dh_public failed");
+		return false;
+	}
+
+	while (params->public_buf[0] =3D=3D 0x00 && params->public_len) {
+		params->public_buf++;
+		params->public_len--;
+	}
+
+	l_put_be16(params->public_len, ptr);
+	memcpy(ptr + 2, params->public_buf, params->public_len);
+	ptr +=3D 2 + params->public_len;
+	pre_master_secret_len =3D params->prime_len;
+
+	if (!l_key_compute_dh_secret(params->public, params->private,
+					params->prime, pre_master_secret,
+					&pre_master_secret_len)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating DH shared-secret failed");
+		return false;
+	}
+
+	while (pre_master_secret[offset] =3D=3D 0x00 &&
+			offset < pre_master_secret_len)
+		offset++;
+
+	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
+
+	tls_free_dhe_params(tls);
+	tls_generate_master_secret(tls, pre_master_secret + offset,
+					pre_master_secret_len - offset);
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


--===============8259645180798729072==--

