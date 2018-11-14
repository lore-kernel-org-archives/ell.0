Content-Type: multipart/mixed; boundary="===============2033992819365925864=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/12] tls: Basic cipher/hash support checking
Date: Wed, 14 Nov 2018 14:19:00 +0100
Message-ID: <20181114131902.1695-10-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2033992819365925864==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use our _is_supported APIs to check each cipher suites compatibility
with the running kernel to try to avoid proposing cipher suites we can't
handle in the negotiation messages (this isn't perfect yet) and to try
to fail early on configuration errors and hopefully with an error
message (this can still be improved too.)
---
 ell/tls.c | 159 +++++++++++++++++++++++++++++++++++++++++++++---------
 ell/tls.h |   2 +-
 2 files changed, 136 insertions(+), 25 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 534d22c..4124e1c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -513,6 +513,88 @@ static struct tls_cipher_suite tls_cipher_suite_pref[]=
 =3D {
 	},
 };
 =

+static bool tls_cipher_suite_is_compatible(struct l_tls *tls,
+					const struct tls_cipher_suite *suite,
+					const char **error)
+{
+	static char error_buf[200];
+
+	if (suite->encryption &&
+			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
+		if (tls->negotiated_version &&
+				tls->negotiated_version < TLS_V12) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Cipher suite %s uses an AEAD "
+						"cipher but TLS < 1.2 was "
+						"negotiated", suite->name);
+			}
+
+			return false;
+		}
+
+		if (!l_aead_cipher_is_supported(suite->encryption->l_aead_id)) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Cipher suite %s's AEAD cipher "
+						"algorithm not supported by "
+						"the kernel", suite->name);
+			}
+
+			return false;
+		}
+	} else if (suite->encryption) { /* Block or stream cipher */
+		if (!l_cipher_is_supported(suite->encryption->l_id)) {
+			if (error) {
+				*error =3D error_buf;
+				snprintf(error_buf, sizeof(error_buf),
+						"Cipher suite %s's block/stream"
+						" cipher algorithm not "
+						"supported by the kernel",
+						suite->name);
+			}
+
+			return false;
+		}
+	}
+
+	if (suite->mac &&
+			!l_checksum_is_supported(suite->mac->hmac_type, true)) {
+		if (error) {
+			*error =3D error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"Cipher suite %s's HMAC algorithm not "
+					"supported by the kernel", suite->name);
+		}
+
+		return false;
+	}
+
+	if ((tls->negotiated_version && tls->negotiated_version < TLS_V12 &&
+			(!l_checksum_is_supported(L_CHECKSUM_MD5, true) ||
+			 !l_checksum_is_supported(L_CHECKSUM_SHA1, true))) ||
+			(tls->negotiated_version >=3D TLS_V12 &&
+			 !l_checksum_is_supported(
+					suite->prf_hmac !=3D L_CHECKSUM_NONE ?
+					suite->prf_hmac : L_CHECKSUM_SHA256,
+					true))) {
+		if (error) {
+			*error =3D error_buf;
+			snprintf(error_buf, sizeof(error_buf),
+					"Cipher suite %s's PRF algorithm not "
+					"supported by the kernel", suite->name);
+		}
+
+		return false;
+	}
+
+	/* TODO: Check suite->key_xchg->validate_cert_key_type(tls->cert) */
+
+	return true;
+}
+
 static struct tls_cipher_suite *tls_find_cipher_suite(const uint8_t *id)
 {
 	int i;
@@ -755,11 +837,12 @@ static void tls_tx_handshake(struct l_tls *tls, int t=
ype, uint8_t *buf,
 	tls_tx_record(tls, TLS_CT_HANDSHAKE, buf, length);
 }
 =

-static void tls_send_client_hello(struct l_tls *tls)
+static bool tls_send_client_hello(struct l_tls *tls)
 {
 	uint8_t buf[128 + L_ARRAY_SIZE(tls_compression_pref) +
 			2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
 	uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
+	uint8_t *len_ptr;
 	int i;
 =

 	/* Fill in the Client Hello body */
@@ -774,27 +857,38 @@ static void tls_send_client_hello(struct l_tls *tls)
 	*ptr++ =3D 0; /* No SessionID */
 =

 	/*
-	 * We can list all supported key exchange mechanisms regardless of the
-	 * certificate type we are actually presenting (if any).
-	 *
-	 * TODO: perhaps scan /proc/crypto for supported ciphers so we don't
-	 * include ones that will cause an internal error later in the
-	 * handshake.  We can add camellia whan this is done.
+	 * FIXME: We do need to filter the cipher suites by key exchange
+	 * mechanism compatibility with the certificate but we don't normally
+	 * have the certificate at this point because we're called from
+	 * l_tls_new.  We also don't know the TLS version that's going to
+	 * be negotiated yet.
 	 */
-	l_put_be16(L_ARRAY_SIZE(tls_cipher_suite_pref) * 2, ptr);
+	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

 	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_cipher_suite_pref); i++) {
+		if (!tls_cipher_suite_is_compatible(tls,
+						&tls_cipher_suite_pref[i],
+						NULL))
+			continue;
+
 		*ptr++ =3D tls_cipher_suite_pref[i].id[0];
 		*ptr++ =3D tls_cipher_suite_pref[i].id[1];
 	}
 =

+	if (ptr =3D=3D len_ptr + 2) {
+		TLS_DEBUG("No compatible cipher suites, check kernel config");
+		return false;
+	}
+
+	l_put_be16((ptr - len_ptr - 2), len_ptr);
 	*ptr++ =3D L_ARRAY_SIZE(tls_compression_pref);
 =

 	for (i =3D 0; i < (int) L_ARRAY_SIZE(tls_compression_pref); i++)
 		*ptr++ =3D tls_compression_pref[i].id;
 =

 	tls_tx_handshake(tls, TLS_CLIENT_HELLO, buf, ptr - buf);
+	return true;
 }
 =

 static void tls_send_server_hello(struct l_tls *tls)
@@ -1495,17 +1589,13 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 =

 	/* Select a cipher suite according to client's preference list */
 	while (cipher_suites_size) {
-		/*
-		 * TODO: filter supported cipher suites by the certificate/key
-		 * type that was submitted by tls_set_auth_data() if any.
-		 * Perhaps just call cipher_suite->verify_cert_type() on each
-		 * cipher suite passing a pre-parsed certificate ASN.1 struct.
-		 */
-		tls->pending.cipher_suite =3D
-					tls_find_cipher_suite(cipher_suites);
+		struct tls_cipher_suite *suite =3D
+			tls_find_cipher_suite(cipher_suites);
 =

-		if (tls->pending.cipher_suite)
-			break;
+		if (suite && tls_cipher_suite_is_compatible(tls, suite, NULL)) {
+			tls->pending.cipher_suite =3D suite;
+ 			break;
+		}
 =

 		cipher_suites +=3D 2;
 		cipher_suites_size -=3D 2;
@@ -1513,7 +1603,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 =

 	if (!cipher_suites_size) {
 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
-				"No common cipher suites");
+				"No common cipher suites matching negotiated "
+				"TLS version and our certificate's key type");
 		return;
 	}
 =

@@ -1575,6 +1666,7 @@ static void tls_handle_server_hello(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
 	uint8_t session_id_size, cipher_suite_id[2], compression_method_id;
+	const char *error;
 	int i;
 =

 	/* Do we have enough for ProtocolVersion + Random + SessionID len ? */
@@ -1629,6 +1721,14 @@ static void tls_handle_server_hello(struct l_tls *tl=
s,
 		return;
 	}
 =

+	if (!tls_cipher_suite_is_compatible(tls, tls->pending.cipher_suite,
+						&error)) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"Selected cipher suite not compatible: %s",
+				error);
+		return;
+	}
+
 	tls_set_prf_hmac(tls);
 =

 	TLS_DEBUG("Negotiated %s", tls->pending.cipher_suite->name);
@@ -2285,6 +2385,9 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 {
 	struct l_tls *tls;
 =

+	if (!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
+		return NULL;
+
 	tls =3D l_new(struct l_tls, 1);
 	tls->server =3D server;
 	tls->rx =3D app_data_handler;
@@ -2297,13 +2400,12 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 =

 	/* If we're the client, start the handshake right away */
 	if (!tls->server) {
-		if (!tls_init_handshake_hash(tls)) {
+		if (!tls_init_handshake_hash(tls) ||
+				!tls_send_client_hello(tls)) {
 			l_free(tls);
 =

 			return NULL;
 		}
-
-		tls_send_client_hello(tls);
 	}
 =

 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
@@ -2490,7 +2592,7 @@ LIB_EXPORT void l_tls_close(struct l_tls *tls)
 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
 }
 =

-LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
+LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
 {
 	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
 =

@@ -2499,8 +2601,17 @@ LIB_EXPORT void l_tls_set_cacert(struct l_tls *tls, =
const char *ca_cert_path)
 		tls->ca_cert_path =3D NULL;
 	}
 =

-	if (ca_cert_path)
+	if (ca_cert_path) {
+		if (!l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
+			TLS_DEBUG("keyctl restrict support missing, "
+					"check kernel configuration");
+			return false;
+		}
+
 		tls->ca_cert_path =3D l_strdup(ca_cert_path);
+	}
+
+	return true;
 }
 =

 LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_pa=
th,
diff --git a/ell/tls.h b/ell/tls.h
index e1a5a21..133e763 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -87,7 +87,7 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data, =
size_t len);
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 =

 /* If peer is to be authenticated, supply the CA certificate */
-void l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
+bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
 =

 /*
  * If we are to be authenticated, supply our certificate, private key and
-- =

2.19.1


--===============2033992819365925864==--

