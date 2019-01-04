Content-Type: multipart/mixed; boundary="===============0208427672373409255=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/12] tls: ECHDE_RSA key exchange implementation client side
Date: Fri, 04 Jan 2019 02:26:36 +0100
Message-ID: <20190104012640.4022-8-andrew.zaborowski@intel.com>
In-Reply-To: <20190104012640.4022-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0208427672373409255==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a new key exchange definition with the callbacks needed to handle the
client side of the ECDHE_RSA key exchange, defined in RFC 8422.  Key
Exchange method-specific state is kept in a struct allocated by the
method and pointed to by a void pointer in the l_tls struct so that the
internals of the method are kept in tls-suites.c
---
 ell/tls-extensions.c |  11 ++
 ell/tls-private.h    |   5 +
 ell/tls-suites.c     | 246 +++++++++++++++++++++++++++++++++++++++++++
 ell/tls.c            |   4 +
 4 files changed, 266 insertions(+)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 3d75037..be2fa10 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -148,3 +148,14 @@ const struct tls_hello_extension tls_extensions[] =3D {
 	},
 	{}
 };
+
+const struct tls_named_curve *tls_find_curve(uint16_t id)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < L_ARRAY_SIZE(tls_curve_pref); i++)
+		if (tls_curve_pref[i].id =3D=3D id)
+			return &tls_curve_pref[i];
+
+	return NULL;
+}
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 375af2b..0ed3eee 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -81,6 +81,8 @@ struct tls_key_exchange_algorithm {
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
 			tls_get_hash_t get_hash);
+
+	void (*free_params)(struct l_tls *tls);
 };
 =

 struct tls_mac_algorithm {
@@ -246,6 +248,7 @@ struct l_tls {
 		 * 6.3 v1.2 + two IVs of 32 bytes.
 		 */
 		uint8_t key_block[192];
+		void *key_xchg_params;
 	} pending;
 =

 	enum tls_cipher_type cipher_type[2];
@@ -301,6 +304,8 @@ void tls_generate_master_secret(struct l_tls *tls,
 				const uint8_t *pre_master_secret,
 				int pre_master_secret_len);
 =

+const struct tls_named_curve *tls_find_curve(uint16_t id);
+
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index a3aed4c..da31982 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -34,6 +34,8 @@
 #include "tls-private.h"
 #include "key.h"
 #include "random.h"
+#include "ecc.h"
+#include "ecdh.h"
 =

 static bool tls_rsa_validate_cert_key(struct l_cert *cert)
 {
@@ -320,6 +322,250 @@ static struct tls_key_exchange_algorithm tls_rsa =3D {
 	.verify =3D tls_rsa_verify,
 };
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
+				const struct tls_named_curve *curve,
+				const struct l_ecc_point *point)
+{
+	/* RFC 8422, Section 5.4.1 */
+	buf[0] =3D 1 + curve->point_bytes;	/* length */
+	buf[1] =3D 4;				/* form: uncompressed */
+	return 2 + l_ecc_point_get_data(point, buf + 2, curve->point_bytes);
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
+static bool tls_get_server_ecdh_params_hash(struct l_tls *tls, uint8_t tls=
_id,
+						uint8_t *out, size_t *len,
+						enum l_checksum_type *type)
+{
+	unsigned int hash;
+	struct l_checksum *checksum;
+	uint8_t params[1024];
+	size_t params_len;
+	ssize_t hash_len, ret;
+
+	params_len =3D tls_write_server_ecdh_params(tls, params);
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
+static void tls_handle_ecdhe_server_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	struct tls_ecdhe_params *params;
+	uint16_t namedcurve;
+
+	/* RFC 8422, Section 5.4 */
+
+	if (len < 5)
+		goto decode_error;
+
+	if (*buf !=3D 3) {
+		TLS_DISCONNECT(TLS_ALERT_ILLEGAL_PARAM, 0,
+				"Unsupported (deprecated?) ECCurveType %u",
+				*buf);
+		return;
+	}
+
+	namedcurve =3D l_get_be16(buf + 1);
+	buf +=3D 3;
+	len -=3D 3;
+
+	tls->negotiated_curve =3D tls_find_curve(namedcurve);
+
+	if (!tls->negotiated_curve) {
+		TLS_DISCONNECT(TLS_ALERT_ILLEGAL_PARAM, 0,
+				"Unsupported NamedCurve %u", namedcurve);
+		return;
+	}
+
+	TLS_DEBUG("Negotiated %s", tls->negotiated_curve->name);
+
+	if (*buf++ !=3D 1 + tls->negotiated_curve->point_bytes)
+		goto decode_error;
+
+	if (*buf !=3D 4) {	/* uncompressed */
+		TLS_DISCONNECT(TLS_ALERT_ILLEGAL_PARAM, 0,
+				"Unsupported (deprecated?) PointConversionForm "
+				"%u", *buf);
+		return;
+	}
+
+	buf++;
+	len -=3D 2;
+
+	if (len < tls->negotiated_curve->point_bytes)
+		goto decode_error;
+
+	/*
+	 * RFC 8422, Section 5.11: "A receiving party MUST check that the
+	 * x and y parameters from the peer's public value satisfy the
+	 * curve equation, y^2 =3D x^3 + ax + b mod p."
+	 * This happens in l_ecc_point_from_data when the L_ECC_POINT_TYPE_FULL
+	 * format is used.
+	 */
+	params =3D l_new(struct tls_ecdhe_params, 1);
+	params->curve =3D l_ecc_curve_get(tls->negotiated_curve->l_group);
+	params->public =3D l_ecc_point_from_data(params->curve,
+						L_ECC_POINT_TYPE_FULL,
+						buf, len);
+	tls->pending.key_xchg_params =3D params;
+	buf +=3D tls->negotiated_curve->point_bytes;
+	len -=3D tls->negotiated_curve->point_bytes;
+
+	if (!params->public) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ServerKeyExchange.params.public decode error");
+		return;
+	}
+
+	if (!tls->pending.cipher_suite->key_xchg->verify(tls, buf, len,
+					tls_get_server_ecdh_params_hash))
+		return;
+
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
+
+	return;
+
+decode_error:
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"ServerKeyExchange decode error");
+}
+
+static bool tls_send_ecdhe_client_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[1024];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t pre_master_secret[128];
+	ssize_t pre_master_secret_len;
+	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
+	struct l_ecc_point *our_public;
+	struct l_ecc_scalar *secret;
+
+	/* RFC 8422, Section 5.7 */
+
+	if (!l_ecdh_generate_key_pair(params->curve,
+					&params->private, &our_public)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating ECDH key pair failed");
+		return false;
+	}
+
+	ptr +=3D tls_write_ecpoint(ptr, tls->negotiated_curve, our_public);
+	l_ecc_point_free(our_public);
+
+	/*
+	 * Neither 5.4 or 5.7 "Actions" paragraphs say when the ECDH shared
+	 * secret is calculated but we can either do this in
+	 * tls_handle_ecdhe_server_key_xchg or here.  In both cases we only
+	 * need to store the public key in the client's key_xchg_params and
+	 * can free all of the params after sending the ClientKeyExchange.
+	 * By doing this calculation here we're aligned with RSA and also
+	 * with the server mode where the shared secret can only be
+	 * calculated after the ClientKeyExchange is received.
+	 */
+	if (!l_ecdh_generate_shared_secret(params->private, params->public,
+						&secret)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating ECDH shared-secret failed");
+		return false;
+	}
+
+	tls_free_ecdhe_params(tls);
+	pre_master_secret_len =3D l_ecc_scalar_get_data(secret,
+						pre_master_secret,
+						sizeof(pre_master_secret));
+	l_ecc_scalar_free(secret);
+
+	if (pre_master_secret_len < 0) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"l_ecc_scalar_get_data(secret) failed");
+		return false;
+	}
+
+	tls_tx_handshake(tls, TLS_CLIENT_KEY_EXCHANGE, buf, ptr - buf);
+
+	tls_generate_master_secret(tls, pre_master_secret,
+					pre_master_secret_len);
+	memset(pre_master_secret, 0, pre_master_secret_len);
+
+	return true;
+}
+
+static struct tls_key_exchange_algorithm tls_ecdhe_rsa =3D {
+	.id =3D 1, /* RSA_sign */
+	.certificate_check =3D true,
+	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.handle_server_key_exchange =3D tls_handle_ecdhe_server_key_xchg,
+	.send_client_key_exchange =3D tls_send_ecdhe_client_key_xchg,
+	.free_params =3D tls_free_ecdhe_params,
+	.sign =3D tls_rsa_sign,
+	.verify =3D tls_rsa_verify,
+};
+
 static struct tls_bulk_encryption_algorithm tls_rc4 =3D {
 	.cipher_type =3D TLS_CIPHER_STREAM,
 	.l_id =3D L_CIPHER_ARC4,
diff --git a/ell/tls.c b/ell/tls.c
index 24f3144..798341b 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -186,6 +186,10 @@ static void tls_reset_handshake(struct l_tls *tls)
 =

 	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
 =

+	if (tls->pending.cipher_suite &&
+			tls->pending.cipher_suite->key_xchg->free_params)
+		tls->pending.cipher_suite->key_xchg->free_params(tls);
+
 	l_cert_free(tls->peer_cert);
 	l_key_free(tls->peer_pubkey);
 =

-- =

2.19.1


--===============0208427672373409255==--

