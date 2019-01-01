Content-Type: multipart/mixed; boundary="===============0977354334495774322=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/17] tls: ECHDE_RSA key exchange implementation server side
Date: Tue, 01 Jan 2019 20:49:32 +0100
Message-ID: <20190101194939.5974-10-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0977354334495774322==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the handler for the ECDHE ClientKeyExchange message rx and a
builder for the ServerKeyExchange message tx, both specified in
RFC 8422.
---
 ell/tls-private.h |   1 +
 ell/tls-suites.c  | 122 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/tls.c         |  18 +++++++
 3 files changed, 141 insertions(+)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 0ed3eee..12d350a 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -66,6 +66,7 @@ struct tls_key_exchange_algorithm {
 	uint8_t id;
 =

 	bool certificate_check;
+	bool need_ecc;
 =

 	bool (*validate_cert_key_type)(struct l_cert *cert);
 =

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index da31982..cda192b 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -412,6 +412,47 @@ static bool tls_get_server_ecdh_params_hash(struct l_t=
ls *tls, uint8_t tls_id,
 	return true;
 }
 =

+static bool tls_send_ecdhe_server_key_xchg(struct l_tls *tls)
+{
+	uint8_t buf[1024];
+	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	struct tls_ecdhe_params *params;
+	ssize_t sign_len;
+
+	/*
+	 * RFC 8422, Section 5.4
+	 *
+	 * If we're getting here we can assume that tls->pending.key_xchg_params
+	 * is NULL, tls->priv_key is our signing key and tls->negotiated_curve
+	 * is non-NULL.
+	 */
+
+	params =3D l_new(struct tls_ecdhe_params, 1);
+	params->curve =3D l_ecc_curve_get(tls->negotiated_curve->l_group);
+	tls->pending.key_xchg_params =3D params;
+
+	if (!l_ecdh_generate_key_pair(params->curve,
+					&params->private, &params->public)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating ECDH key pair failed");
+		return false;
+	}
+
+	ptr +=3D tls_write_server_ecdh_params(tls, ptr);
+
+	sign_len =3D tls->pending.cipher_suite->key_xchg->sign(tls, ptr,
+					buf + sizeof(buf) - ptr,
+					tls_get_server_ecdh_params_hash);
+	if (sign_len < 0)
+		return false;
+
+	ptr +=3D sign_len;
+
+	tls_tx_handshake(tls, TLS_SERVER_KEY_EXCHANGE, buf, ptr - buf);
+
+	return true;
+}
+
 static void tls_handle_ecdhe_server_key_xchg(struct l_tls *tls,
 						const uint8_t *buf, size_t len)
 {
@@ -555,12 +596,93 @@ static bool tls_send_ecdhe_client_key_xchg(struct l_t=
ls *tls)
 	return true;
 }
 =

+static void tls_handle_ecdhe_client_key_xchg(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	struct tls_ecdhe_params *params =3D tls->pending.key_xchg_params;
+	uint8_t pre_master_secret[128];
+	ssize_t pre_master_secret_len;
+	struct l_ecc_point *other_public;
+	struct l_ecc_scalar *secret;
+
+	/* RFC 8422, Section 5.7 */
+
+	if (len < 2)
+		goto decode_error;
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
+	if (len !=3D tls->negotiated_curve->point_bytes)
+		goto decode_error;
+
+	/*
+	 * RFC 8422, Section 5.11: "A receiving party MUST check that the
+	 * x and y parameters from the peer's public value satisfy the
+	 * curve equation, y^2 =3D x^3 + ax + b mod p."
+	 * This happens in l_ecc_point_from_data when the L_ECC_POINT_TYPE_FULL
+	 * format is used.
+	 */
+	other_public =3D l_ecc_point_from_data(params->curve,
+						L_ECC_POINT_TYPE_FULL,
+						buf, len);
+	if (!other_public) {
+		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+				"ClientKeyExchange.exchange_keys.ecdh_Yc "
+				"decode error");
+		return;
+	}
+
+	if (!l_ecdh_generate_shared_secret(params->private, other_public,
+						&secret)) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Generating ECDH shared-secret failed");
+		return;
+	}
+
+	tls_free_ecdhe_params(tls);
+	l_ecc_point_free(other_public);
+	pre_master_secret_len =3D l_ecc_scalar_get_data(secret,
+						pre_master_secret,
+						sizeof(pre_master_secret));
+	l_ecc_scalar_free(secret);
+
+	if (pre_master_secret_len < 0) {
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"l_ecc_scalar_get_data(secret) failed");
+		return;
+	}
+
+	tls_generate_master_secret(tls, pre_master_secret,
+					pre_master_secret_len);
+	memset(pre_master_secret, 0, pre_master_secret_len);
+
+	return;
+
+decode_error:
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
+			"ClientKeyExchange decode error");
+}
+
 static struct tls_key_exchange_algorithm tls_ecdhe_rsa =3D {
 	.id =3D 1, /* RSA_sign */
 	.certificate_check =3D true,
+	.need_ecc =3D true,
 	.validate_cert_key_type =3D tls_rsa_validate_cert_key,
+	.send_server_key_exchange =3D tls_send_ecdhe_server_key_xchg,
 	.handle_server_key_exchange =3D tls_handle_ecdhe_server_key_xchg,
 	.send_client_key_exchange =3D tls_send_ecdhe_client_key_xchg,
+	.handle_client_key_exchange =3D tls_handle_ecdhe_client_key_xchg,
 	.free_params =3D tls_free_ecdhe_params,
 	.sign =3D tls_rsa_sign,
 	.verify =3D tls_rsa_verify,
diff --git a/ell/tls.c b/ell/tls.c
index df827f3..fc8ab41 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -476,6 +476,24 @@ static bool tls_cipher_suite_is_compatible(struct l_tl=
s *tls,
 		return false;
 	}
 =

+	/*
+	 * On the server we know what elliptic curve we'll be using as soon
+	 * as we've processed the ClientHello so for EC-based key exchange
+	 * methods require that a curve has been selected.
+	 */
+	if (suite->key_xchg->need_ecc && tls->server &&
+			!tls->negotiated_curve) {
+		if (error) {
+			*error =3D error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"No common supported elliptic curves "
+					"with the client, can't use %s",
+					suite->name);
+		}
+
+		return false;
+	}
+
 	return true;
 }
 =

-- =

2.19.1


--===============0977354334495774322==--

