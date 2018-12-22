Content-Type: multipart/mixed; boundary="===============6387147155246441403=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/11] tls: ECHDE_RSA key exchange implementation client side
Date: Sat, 22 Dec 2018 05:16:34 +0100
Message-ID: <20181222041635.6533-10-andrew.zaborowski@intel.com>
In-Reply-To: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6387147155246441403==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the handler for the ECDHE ServerKeyExchange message rx and a
builder for the ClientKeyExchange message tx, both specified in
RFC 8422.
---
 ell/tls-extensions.c |  11 ++++
 ell/tls-private.h    |   2 +
 ell/tls-suites.c     | 145 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 158 insertions(+)

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
index bb7d58d..3f68a1d 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -305,6 +305,8 @@ void tls_generate_master_secret(struct l_tls *tls,
 				const uint8_t *pre_master_secret,
 				int pre_master_secret_len);
 =

+const struct tls_named_curve *tls_find_curve(uint16_t id);
+
 int tls_parse_certificate_list(const void *data, size_t len,
 				struct l_certchain **out_certchain);
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d280f32..4ec6d54 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -453,6 +453,149 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_t=
ls *tls)
 	return true;
 }
 =

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
 static void tls_handle_ecdhe_client_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
@@ -536,8 +679,10 @@ static struct tls_key_exchange_algorithm tls_ecdhe_rsa=
 =3D {
 	.certificate_check =3D true,
 	.need_ecc =3D true,
 	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.send_client_key_exchange =3D tls_send_ecdhe_client_key_xchg,
 	.handle_client_key_exchange =3D tls_handle_ecdhe_client_key_xchg,
 	.send_server_key_exchange =3D tls_send_ecdhe_server_key_xchg,
+	.handle_server_key_exchange =3D tls_handle_ecdhe_server_key_xchg,
 	.free_params =3D tls_free_ecdhe_params,
 	.sign =3D tls_rsa_sign,
 	.verify =3D tls_rsa_verify,
-- =

2.19.1


--===============6387147155246441403==--

