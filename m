Content-Type: multipart/mixed; boundary="===============0679352975019014092=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/4] tls: change APIs to use l_cert/l_certchain/l_key
Date: Tue, 01 Oct 2019 11:27:30 -0700
Message-ID: <20191001182733.16176-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0679352975019014092==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_tls_set_auth_data/l_tls_set_cacert both expected file paths to be
passed in, and the certs/keys would be loaded internally. This prevents
the caller from loading certs any way but from files. This makes
loading certs/keys from data impossible if using TLS. For example,
a certificate may be embedded inside a file which has additional data.

To handle both file/data cases its now up to the caller to load the
cert/key as an l_cert/l_certchain/l_key/l_queue and pass that structure
in directly.

The structure being passed in will now be owned by l_tls, and will be
freed on l_tls_free.
---
 ell/tls.c | 42 +++++++++++++-----------------------------
 ell/tls.h | 11 +++++++----
 2 files changed, 20 insertions(+), 33 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index d0e2a66..9121797 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2591,7 +2591,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	}
 =

 	l_tls_set_cacert(tls, NULL);
-	l_tls_set_auth_data(tls, NULL, NULL, NULL);
+	l_tls_set_auth_data(tls, NULL, NULL);
 	l_tls_set_domain_mask(tls, NULL);
 =

 	tls_reset_handshake(tls);
@@ -2806,9 +2806,9 @@ LIB_EXPORT void l_tls_close(struct l_tls *tls)
 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
 }
 =

-LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_pa=
th)
+LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_cer=
ts)
 {
-	TLS_DEBUG("ca-cert-path=3D%s", ca_cert_path);
+	TLS_DEBUG("ca-certs=3D%p", ca_certs);
 =

 	if (tls->ca_certs) {
 		l_queue_destroy(tls->ca_certs,
@@ -2816,29 +2816,24 @@ LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls,=
 const char *ca_cert_path)
 		tls->ca_certs =3D NULL;
 	}
 =

-	if (ca_cert_path) {
+	if (ca_certs) {
 		if (!l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
 			TLS_DEBUG("keyctl restrict support missing, "
 					"check kernel configuration");
 			return false;
 		}
 =

-		tls->ca_certs =3D l_pem_load_certificate_list(ca_cert_path);
-		if (!tls->ca_certs) {
-			TLS_DEBUG("Error loading %s", ca_cert_path);
-			return false;
-		}
+		tls->ca_certs =3D ca_certs;
 	}
 =

 	return true;
 }
 =

-LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_pa=
th,
-					const char *priv_key_path,
-					const char *priv_key_passphrase)
+LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls,
+					struct l_certchain *certchain,
+					struct l_key *priv_key)
 {
-	TLS_DEBUG("cert-path=3D%s priv-key-path=3D%s priv-key-passphrase=3D%p",
-			cert_path, priv_key_path, priv_key_passphrase);
+	TLS_DEBUG("certchain=3D%p priv-key=3D%p", certchain, priv_key);
 =

 	if (tls->cert) {
 		l_certchain_free(tls->cert);
@@ -2851,24 +2846,13 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
 		tls->priv_key_size =3D 0;
 	}
 =

-	if (cert_path) {
-		tls->cert =3D l_pem_load_certificate_chain(cert_path);
-		if (!tls->cert) {
-			TLS_DEBUG("Error loading %s", cert_path);
-			return false;
-		}
-	}
+	if (certchain)
+		tls->cert =3D certchain;
 =

-	if (priv_key_path) {
+	if (priv_key) {
 		bool is_public =3D true;
 =

-		tls->priv_key =3D l_pem_load_private_key(priv_key_path,
-							priv_key_passphrase,
-							NULL);
-		if (!tls->priv_key) {
-			TLS_DEBUG("Error loading %s", priv_key_path);
-			return false;
-		}
+		tls->priv_key =3D priv_key;
 =

 		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
diff --git a/ell/tls.h b/ell/tls.h
index a361c37..ec497e1 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -33,6 +33,9 @@ enum l_tls_version {
 };
 =

 struct l_tls;
+struct l_key;
+struct l_certchain;
+struct l_queue;
 =

 enum l_tls_alert_desc {
 	TLS_ALERT_CLOSE_NOTIFY		=3D 0,
@@ -96,7 +99,7 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data, =
size_t len);
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 =

 /* If peer is to be authenticated, supply the CA certificates */
-bool l_tls_set_cacert(struct l_tls *tls, const char *ca_cert_path);
+bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_certs);
 =

 /*
  * If we are to be authenticated, supply our certificate, private key and
@@ -109,9 +112,9 @@ bool l_tls_set_cacert(struct l_tls *tls, const char *ca=
_cert_path);
  * one certificate of each type so they can be used depending on which
  * is compatible with the negotiated parameters.
  */
-bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
-				const char *priv_key_path,
-				const char *priv_key_passphrase);
+bool l_tls_set_auth_data(struct l_tls *tls,
+				struct l_certchain *certchain,
+				struct l_key *priv_key);
 =

 void l_tls_set_version_range(struct l_tls *tls,
 				enum l_tls_version min_version,
-- =

2.17.1

--===============0679352975019014092==--

