Content-Type: multipart/mixed; boundary="===============1255361287969898314=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/11] tls: Add ServerKeyExchange callbacks to key exchange
 struct
Date: Sat, 22 Dec 2018 05:16:32 +0100
Message-ID: <20181222041635.6533-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1255361287969898314==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

TLS Key Exchange algorithms using ephemeral keys (DHE_* and ECDHE_*)
need to use the ServerKeyExchange message during the handshake unlike
our current RSA key exchanhe, provide callbacks for sending and receiving
those messages.
---
 ell/tls-private.h |  4 ++++
 ell/tls.c         | 61 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 442dc02..c2a311b 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -73,6 +73,10 @@ struct tls_key_exchange_algorithm {
 	void (*handle_client_key_exchange)(struct l_tls *tls,
 						const uint8_t *buf, size_t len);
 =

+	bool (*send_server_key_exchange)(struct l_tls *tls);
+	void (*handle_server_key_exchange)(struct l_tls *tls,
+						const uint8_t *buf, size_t len);
+
 	ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
 			tls_get_hash_t get_hash);
 	bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
diff --git a/ell/tls.c b/ell/tls.c
index 1910b92..0aa04a1 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1517,6 +1517,11 @@ static void tls_handle_client_hello(struct l_tls *tl=
s,
 		if (!tls_send_certificate(tls))
 			return;
 =

+	if (tls->pending.cipher_suite->key_xchg->send_server_key_exchange)
+		if (!tls->pending.cipher_suite->key_xchg->
+				send_server_key_exchange(tls))
+			return;
+
 	/* TODO: don't bother if configured to not authenticate client */
 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
 			tls->ca_certs)
@@ -1757,7 +1762,8 @@ static void tls_handle_certificate(struct l_tls *tls,
 =

 	tls->peer_pubkey_size /=3D 8;
 =

-	if (tls->server)
+	if (tls->server || tls->pending.cipher_suite->key_xchg->
+			handle_server_key_exchange)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
@@ -2134,6 +2140,27 @@ static void tls_handle_handshake(struct l_tls *tls, =
int type,
 =

 		break;
 =

+	case TLS_SERVER_KEY_EXCHANGE:
+		if (tls->server) {
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in server mode");
+			break;
+		}
+
+		if (tls->state !=3D TLS_HANDSHAKE_WAIT_KEY_EXCHANGE) {
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
+			break;
+		}
+
+		tls->pending.cipher_suite->key_xchg->handle_server_key_exchange(
+								tls, buf, len);
+
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
+
+		break;
+
 	case TLS_CERTIFICATE_REQUEST:
 		if (tls->server) {
 			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
@@ -2240,19 +2267,33 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 		}
 =

 		/*
-		 * On the client, the server's certificate is only now
-		 * verified, based on the following logic:
+		 * On the client, the server's certificate is now verified
+		 * regardless of the key exchange method, based on the
+		 * following logic:
+		 *
 		 *  - tls->ca_certs is non-NULL so tls_handle_certificate
 		 *    (always called on the client) must have veritifed the
 		 *    server's certificate chain to be valid and additionally
 		 *    trusted by our CA.
-		 *  - the correct receival of this Finished message confirms
-		 *    that the peer owns the end-entity certificate because
-		 *    it was able to decrypt the master secret which we had
-		 *    encrypted with the public key from that certificate, and
-		 *    the posession of the master secret in turn is verified
-		 *    by both the successful decryption and the MAC of this
-		 *    message (either should be enough).
+		 *
+		 *  - the peer owns the end-entity certificate because:
+		 *    either:
+		 *
+		 *    * (RSA key exchange algorithm case) the correct
+		 *      receival of this Finished message confirms the
+		 *      posession of the master secret, it is verified by
+		 *      both the successful decryption and the MAC of this
+		 *      message (either should be enough) because we entered
+		 *      the TLS_HANDSHAKE_WAIT_FINISHED state only after
+		 *      encryption and MAC were enabled in ChangeCipherSpec.
+		 *      To obtain the master secret the server must have been
+		 *      able to decrypt the pre_master_secret which we had
+		 *      encrypted with the public key from that certificate.
+		 *
+		 *    * (ECDHE and DHE key exchange algorithms) server was
+		 *      able to sign the client random together with the
+		 *      ServerKeyExchange parameters using its certified key
+		 *      pair.
 		 */
 		if (!tls->server && tls->cipher_suite[0]->key_xchg->
 				certificate_check && tls->ca_certs)
-- =

2.19.1


--===============1255361287969898314==--

