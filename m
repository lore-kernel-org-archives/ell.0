Content-Type: multipart/mixed; boundary="===============7500050689541598563=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] unit: Update expected peer identity strings in TLS
Date: Tue, 06 Aug 2019 15:45:12 +0200
Message-ID: <20190806134514.6340-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190806134514.6340-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7500050689541598563==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 03c5370..d701f42 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -326,7 +326,8 @@ static const struct tls_conn_test tls_conn_test_server_=
auth =3D {
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_expect_identity =3D NULL,
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 };
 =

 static const struct tls_conn_test tls_conn_test_client_auth_attempt =3D {
@@ -341,7 +342,8 @@ static const struct tls_conn_test tls_conn_test_client_=
auth =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "Bar Example Organization",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_cert_path =3D CERTDIR "cert-client.pem",
 	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.client_expect_identity =3D NULL,
@@ -353,29 +355,34 @@ static const struct tls_conn_test tls_conn_test_full_=
auth_attempt =3D {
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
 	.server_expect_identity =3D NULL,
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 };
 =

 static const struct tls_conn_test tls_conn_test_full_auth =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "Bar Example Organization",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_cert_path =3D CERTDIR "cert-client.pem",
 	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 };
 =

 static const struct tls_conn_test tls_conn_test_bad_client_suite =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "Bar Example Organization",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_cert_path =3D CERTDIR "cert-client.pem",
 	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 	.client_cipher_suites =3D (const char *[]) { "UNKNOWN", NULL },
 	.expect_client_start_fail =3D true,
 };
@@ -384,13 +391,15 @@ static const struct tls_conn_test tls_conn_test_suite=
_mismatch =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "Bar Example Organization",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.server_cipher_suites =3D
 		(const char *[]) { "TLS_RSA_WITH_AES_128_CBC_SHA256", NULL },
 	.client_cert_path =3D CERTDIR "cert-client.pem",
 	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 	.client_cipher_suites =3D
 		(const char *[]) { "TLS_RSA_WITH_AES_256_CBC_SHA256", NULL },
 	.expect_alert =3D true,
@@ -401,11 +410,13 @@ static const struct tls_conn_test tls_conn_test_versi=
on_mismatch =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "Bar Example Organization",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_cert_path =3D CERTDIR "cert-client.pem",
 	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "Foo Example Organization",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_PROTOCOL_VERSION,
 };
-- =

2.20.1


--===============7500050689541598563==--

