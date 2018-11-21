Content-Type: multipart/mixed; boundary="===============7500936950553904230=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/16] tls: Support loading multiple root CAs
Date: Wed, 21 Nov 2018 16:08:50 +0100
Message-ID: <20181121150903.24437-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7500936950553904230==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If a file with multiple concatenated certificates is supplied to
set_cecert, load all of them and verify received certificate chains
aginst any of them instead of just the first one.  This is also what
wpa_supplicant does for files supplied with the ca_cert=3D setting and
it's actually useful.  Some enterprise CAs have multiple root
certificates and provision clients with a file that contains all of them
concatenated and it does happen that they switch from a certificate
chain using one root to a new chain with a different root for their wifi
APs in which case our network config files break while wpa_supplicant
configs keep working.
---
 ell/tls-private.h |  2 +-
 ell/tls.c         | 35 ++++++++++++++++++-----------------
 ell/tls.h         |  2 +-
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 9c909e1..e48aaa0 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -145,7 +145,7 @@ struct l_tls {
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
 =

-	struct l_cert *ca_cert;
+	struct l_queue *ca_certs;
 	struct l_certchain *cert;
 	struct l_key *priv_key;
 	size_t priv_key_size;
diff --git a/ell/tls.c b/ell/tls.c
index 72d9b3e..4f29cec 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -959,7 +959,7 @@ static bool tls_send_certificate(struct l_tls *tls)
 		return false;
 	}
 =

-	if (tls->cert && !l_certchain_find(tls->cert, tls->ca_cert)) {
+	if (tls->cert && !l_certchain_find(tls->cert, tls->ca_certs)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_UNKNOWN_CA,
 				"Can't find certificate chain to local "
 				"CA cert");
@@ -1657,14 +1657,14 @@ static void tls_handle_client_hello(struct l_tls *t=
ls,
 =

 	/* TODO: don't bother if configured to not authenticate client */
 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_cert)
+			tls->ca_certs)
 		if (!tls_send_certificate_request(tls))
 			return;
 =

 	tls_send_server_hello_done(tls);
 =

 	if (tls->pending.cipher_suite->key_xchg->certificate_check &&
-			tls->ca_cert)
+			tls->ca_certs)
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CERTIFICATE);
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
@@ -1824,13 +1824,13 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 =

 	/*
 	 * Validate the certificate chain's consistency and validate it
-	 * against our CA if we have any.
+	 * against our CAs if we have any.
 	 */
-	if (!l_certchain_verify(certchain, tls->ca_cert)) {
+	if (!l_certchain_verify(certchain, tls->ca_certs)) {
 		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
 				"Peer certchain verification failed "
-				"consistency check%s",
-				tls->ca_cert ? " or against local CA cert" : "");
+				"consistency check%s", tls->ca_certs ?
+				" or against local CA certs" : "");
 =

 		goto done;
 	}
@@ -2139,10 +2139,10 @@ static void tls_handle_certificate_verify(struct l_=
tls *tls,
 	 *   - If we received an (expected) Certificate Verify, we must have
 	 *     sent a Certificate Request.
 	 *   - If we sent a Certificate Request that's because
-	 *     tls->ca_cert is non-NULL.
-	 *   - If tls->ca_cert is non-NULL then tls_handle_certificate
+	 *     tls->ca_certs is non-NULL.
+	 *   - If tls->ca_certs is non-NULL then tls_handle_certificate
 	 *     will have checked the whole certificate chain to be valid and
-	 *     additionally trusted by our CA if known.
+	 *     additionally trusted by our CAs if known.
 	 *   - Additionally cipher_suite->key_xchg->verify has just confirmed
 	 *     that the peer owns the end-entity certificate because it was
 	 *     able to sign the contents of the handshake messages and that
@@ -2352,7 +2352,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		/*
 		 * On the client, the server's certificate is only now
 		 * verified, based on the following logic:
-		 *  - tls->ca_cert is non-NULL so tls_handle_certificate
+		 *  - tls->ca_certs is non-NULL so tls_handle_certificate
 		 *    (always called on the client) must have veritifed the
 		 *    server's certificate chain to be valid and additionally
 		 *    trusted by our CA.
@@ -2365,7 +2365,7 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		 *    message (either should be enough).
 		 */
 		if (!tls->server && tls->cipher_suite[0]->key_xchg->
-				certificate_check && tls->ca_cert)
+				certificate_check && tls->ca_certs)
 			tls->peer_authenticated =3D true;
 =

 		tls_finished(tls);
@@ -2598,9 +2598,10 @@ LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, =
const char *ca_cert_path)
 {
 	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
 =

-	if (tls->ca_cert) {
-		l_cert_free(tls->ca_cert);
-		tls->ca_cert =3D NULL;
+	if (tls->ca_certs) {
+		l_queue_destroy(tls->ca_certs,
+				(l_queue_destroy_func_t) l_cert_free);
+		tls->ca_certs =3D NULL;
 	}
 =

 	if (ca_cert_path) {
@@ -2610,8 +2611,8 @@ LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, c=
onst char *ca_cert_path)
 			return false;
 		}
 =

-		tls->ca_cert =3D tls_cert_load_file(ca_cert_path);
-		if (!tls->ca_cert) {
+		tls->ca_certs =3D l_pem_load_certificate_list(ca_cert_path);
+		if (!tls->ca_certs) {
 			TLS_DEBUG("Error loading %s", ca_cert_path);
 			return false;
 		}
diff --git a/ell/tls.h b/ell/tls.h
index 133e763..505f0e0 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -86,7 +86,7 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data, =
size_t len);
 /* Submit TLS payload from underlying transport to be decrypted */
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 =

-/* If peer is to be authenticated, supply the CA certificate */
+/* If peer is to be authenticated, supply the CA certificates */
 bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
 =

 /*
-- =

2.19.1


--===============7500936950553904230==--

