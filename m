Content-Type: multipart/mixed; boundary="===============0710472968332442968=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] tls: fixed intentation in X509 definitions
Date: Fri, 16 Nov 2018 16:04:51 -0800
Message-ID: <20181117000451.30494-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0710472968332442968==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Someones editor must have been misbehaving
---
 ell/tls.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 9dc97ff..2d2dd4b 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2549,23 +2549,23 @@ const char *tls_handshake_state_to_str(enum tls_han=
dshake_state state)
 /* X509 Certificates and Certificate Chains */
 =

 #define X509_CERTIFICATE_POS			0
-#define   X509_TBSCERTIFICATE_POS		  0
-#define     X509_TBSCERT_VERSION_POS		    0
-#define     X509_TBSCERT_SERIAL_POS		    1
-#define     X509_TBSCERT_SIGNATURE_POS		    2
-#define       X509_ALGORITHM_ID_ALGORITHM_POS	      0
-#define       X509_ALGORITHM_ID_PARAMS_POS	      1
-#define     X509_TBSCERT_ISSUER_DN_POS		    3
-#define     X509_TBSCERT_VALIDITY_POS		    4
-#define     X509_TBSCERT_SUBJECT_DN_POS		    5
-#define     X509_TBSCERT_SUBJECT_KEY_POS	    6
-#define       X509_SUBJECT_KEY_ALGORITHM_POS	      0
-#define       X509_SUBJECT_KEY_VALUE_POS	      1
-#define     X509_TBSCERT_ISSUER_UID_POS		    7
-#define     X509_TBSCERT_SUBJECT_UID_POS	    8
-#define     X509_TBSCERT_EXTENSIONS_POS		    9
-#define   X509_SIGNATURE_ALGORITHM_POS		  1
-#define   X509_SIGNATURE_VALUE_POS		  2
+#define X509_TBSCERTIFICATE_POS			0
+#define X509_TBSCERT_VERSION_POS		0
+#define X509_TBSCERT_SERIAL_POS			1
+#define X509_TBSCERT_SIGNATURE_POS		2
+#define X509_ALGORITHM_ID_ALGORITHM_POS		0
+#define X509_ALGORITHM_ID_PARAMS_POS		1
+#define X509_TBSCERT_ISSUER_DN_POS		3
+#define X509_TBSCERT_VALIDITY_POS		4
+#define X509_TBSCERT_SUBJECT_DN_POS		5
+#define X509_TBSCERT_SUBJECT_KEY_POS		6
+#define X509_SUBJECT_KEY_ALGORITHM_POS		0
+#define X509_SUBJECT_KEY_VALUE_POS		1
+#define X509_TBSCERT_ISSUER_UID_POS		7
+#define X509_TBSCERT_SUBJECT_UID_POS		8
+#define X509_TBSCERT_EXTENSIONS_POS		9
+#define X509_SIGNATURE_ALGORITHM_POS		1
+#define X509_SIGNATURE_VALUE_POS		2
 =

 struct tls_cert *tls_cert_load_file(const char *filename)
 {
-- =

2.17.1


--===============0710472968332442968==--

