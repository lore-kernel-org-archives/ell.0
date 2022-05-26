Content-Type: multipart/mixed; boundary="===============8441626623945608871=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/3] tls: Flush record buffers on l_tls_close
Date: Thu, 26 May 2022 17:56:55 +0200
Message-ID: <20220526155657.63641-1-andrew.zaborowski@intel.com>

--===============8441626623945608871==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We probably don't want to handle data fragments we received before an
l_tls_close if the TLS tunnel gets restarted in the future.
---
 ell/tls.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index c246f1f..c072afb 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2852,6 +2852,9 @@ LIB_EXPORT bool l_tls_start(struct l_tls *tls)
 =

 LIB_EXPORT void l_tls_close(struct l_tls *tls)
 {
+	tls->record_buf_len =3D 0;
+	tls->message_buf_len =3D 0;
+
 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
 }
 =

-- =

2.32.0

--===============8441626623945608871==--

