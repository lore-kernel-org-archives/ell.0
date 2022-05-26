Content-Type: multipart/mixed; boundary="===============2963979211534782546=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/3] tls: Add l_tls_reset function
Date: Thu, 26 May 2022 17:56:56 +0200
Message-ID: <20220526155657.63641-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220526155657.63641-1-andrew.zaborowski@intel.com

--===============2963979211534782546==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add API to reset the tunnel to initial state without triggering any
callbacks or sending an alert like l_tls_close() does.
---
 ell/ell.sym |  1 +
 ell/tls.c   | 20 ++++++++++++++++++++
 ell/tls.h   |  3 +++
 3 files changed, 24 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 3b11f41..0e0c194 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -513,6 +513,7 @@ global:
 	l_tls_write;
 	l_tls_start;
 	l_tls_close;
+	l_tls_reset;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
diff --git a/ell/tls.c b/ell/tls.c
index c072afb..fa00075 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2858,6 +2858,26 @@ LIB_EXPORT void l_tls_close(struct l_tls *tls)
 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
 }
 =

+LIB_EXPORT void l_tls_reset(struct l_tls *tls)
+{
+	/*
+	 * Similar to l_tls_close but without sending the alert or a
+	 * disconnect callback.
+	 */
+
+	tls_reset_handshake(tls);
+	tls_cleanup_handshake(tls);
+
+	tls_reset_cipher_spec(tls, 0);
+	tls_reset_cipher_spec(tls, 1);
+
+	tls->negotiated_version =3D 0;
+	tls->ready =3D false;
+	tls->record_flush =3D true;
+	tls->record_buf_len =3D 0;
+	tls->message_buf_len =3D 0;
+}
+
 LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_cer=
ts)
 {
 	if (tls->ca_certs) {
diff --git a/ell/tls.h b/ell/tls.h
index 683c54c..a4fd414 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -92,6 +92,9 @@ bool l_tls_start(struct l_tls *tls);
 /* Properly disconnect a connected session */
 void l_tls_close(struct l_tls *tls);
 =

+/* Reset to initial state without a graceful disconnect or callback */
+void l_tls_reset(struct l_tls *tls);
+
 /* Submit plaintext data to be encrypted and transmitted */
 void l_tls_write(struct l_tls *tls, const uint8_t *data, size_t len);
 =

-- =

2.32.0

--===============2963979211534782546==--

