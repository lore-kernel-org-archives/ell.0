Content-Type: multipart/mixed; boundary="===============1958245250725280287=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] tls: Fix CA certificate presence check
Date: Mon, 14 Nov 2016 21:16:31 +0100
Message-ID: <1479154592-8116-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1958245250725280287==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 3879b50..388efa7 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1474,7 +1474,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 	 * against our CA if we have any.
 	 */
 =

-	if (ca_cert) {
+	if (tls->ca_cert_path) {
 		ca_cert =3D tls_cert_load_file(tls->ca_cert_path);
 		if (!ca_cert) {
 			tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR,
-- =

2.7.4


--===============1958245250725280287==--

