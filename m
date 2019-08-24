Content-Type: multipart/mixed; boundary="===============1777895895006364407=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: Add TLS tests for cert's DNSName matching
Date: Sat, 24 Aug 2019 02:47:31 +0200
Message-ID: <20190824004731.24274-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190824004731.24274-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1777895895006364407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Note we switch around the server and client certificates in the test
cases for the Common Name because now the code only looks at the CN if
no DNSNames are present which is only the case in the client-cert.
---
 unit/test-tls.c | 170 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 119 insertions(+), 51 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 36f9934..f4c5cb1 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -621,36 +621,66 @@ static void test_tls_version_mismatch_test(const void=
 *data)
 }
 =

 static const struct tls_conn_test tls_conn_test_domain_match1 =3D {
-	.server_cert_path =3D CERTDIR "cert-server.pem",
-	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "/O=3DBar Example Organization"
-		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
-	.client_cert_path =3D CERTDIR "cert-client.pem",
-	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
-	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "/O=3DFoo Example Organization"
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
-	.client_domain_mask =3D (char *[]) { "Foo Example Organization", NULL },
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "Bar Example Organization", NULL },
 };
 =

 static const struct tls_conn_test tls_conn_test_domain_match2 =3D {
-	.server_cert_path =3D CERTDIR "cert-server.pem",
-	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "/O=3DBar Example Organization"
-		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
-	.client_cert_path =3D CERTDIR "cert-client.pem",
-	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "/O=3DFoo Example Organization"
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_domain_mask =3D (char *[]) {
+		"Bar Example Organization", "Foo Example Organization", NULL
+	},
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match3 =3D {
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_domain_mask =3D (char *[]) {
 		"Foo Example Organization", "Bar Example Organization", NULL
 	},
 };
 =

-static const struct tls_conn_test tls_conn_test_domain_match3 =3D {
+static const struct tls_conn_test tls_conn_test_domain_match4 =3D {
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "*", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match5 =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
@@ -661,12 +691,10 @@ static const struct tls_conn_test tls_conn_test_domai=
n_match3 =3D {
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
 	.client_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
-	.client_domain_mask =3D (char *[]) {
-		"Bar Example Organization", "Foo Example Organization", NULL
-	},
+	.client_domain_mask =3D (char *[]) { "foo.int.com", NULL },
 };
 =

-static const struct tls_conn_test tls_conn_test_domain_match4 =3D {
+static const struct tls_conn_test tls_conn_test_domain_match6 =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
@@ -677,10 +705,10 @@ static const struct tls_conn_test tls_conn_test_domai=
n_match4 =3D {
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
 	.client_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
-	.client_domain_mask =3D (char *[]) { "*", NULL },
+	.client_domain_mask =3D (char *[]) { "*.*", NULL },
 };
 =

-static const struct tls_conn_test tls_conn_test_domain_mismatch1 =3D {
+static const struct tls_conn_test tls_conn_test_domain_match7 =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
@@ -691,64 +719,96 @@ static const struct tls_conn_test tls_conn_test_domai=
n_mismatch1 =3D {
 	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
 	.client_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "*.*.*", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch1 =3D {
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_domain_mask =3D (char *[]) { "", NULL },
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
 };
 =

 static const struct tls_conn_test tls_conn_test_domain_mismatch2 =3D {
-	.server_cert_path =3D CERTDIR "cert-server.pem",
-	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "/O=3DBar Example Organization"
-		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
-	.client_cert_path =3D CERTDIR "cert-client.pem",
-	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
-	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "/O=3DFoo Example Organization"
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
-	.client_domain_mask =3D (char *[]) { "Bar Example Organization", NULL },
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "Foo Example Organization", NULL },
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
 };
 =

 static const struct tls_conn_test tls_conn_test_domain_mismatch3 =3D {
-	.server_cert_path =3D CERTDIR "cert-server.pem",
-	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "/O=3DBar Example Organization"
-		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
-	.client_cert_path =3D CERTDIR "cert-client.pem",
-	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
-	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "/O=3DFoo Example Organization"
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_domain_mask =3D (char *[]) {
-		"Foo Example Organization.com", NULL
+		"Bar Example Organization.com", NULL
 	},
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
 };
 =

 static const struct tls_conn_test tls_conn_test_domain_mismatch4 =3D {
-	.server_cert_path =3D CERTDIR "cert-server.pem",
-	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.server_expect_identity =3D "/O=3DBar Example Organization"
-		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
-	.client_cert_path =3D CERTDIR "cert-client.pem",
-	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
-	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
-	.client_expect_identity =3D "/O=3DFoo Example Organization"
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
 	.client_domain_mask =3D (char *[]) {
-		"Foo Example Organization.*", NULL
+		"Bar Example Organization.*", NULL
 	},
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
 };
 =

 static const struct tls_conn_test tls_conn_test_domain_mismatch5 =3D {
+	.server_cert_path =3D CERTDIR "cert-client.pem",
+	.server_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-server.pem",
+	.client_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_domain_mask =3D (char *[]) {
+		"*.Bar Example Organization", NULL
+	},
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch6 =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
@@ -760,7 +820,7 @@ static const struct tls_conn_test tls_conn_test_domain_=
mismatch5 =3D {
 	.client_expect_identity =3D "/O=3DFoo Example Organization"
 		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
 	.client_domain_mask =3D (char *[]) {
-		"*.Foo Example Organization", NULL
+		"foo.*", NULL
 	},
 	.expect_alert =3D true,
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
@@ -878,6 +938,12 @@ int main(int argc, char *argv[])
 			&tls_conn_test_domain_match3);
 	l_test_add("TLS connection domain match 4", test_tls_test,
 			&tls_conn_test_domain_match4);
+	l_test_add("TLS connection domain match 5", test_tls_test,
+			&tls_conn_test_domain_match5);
+	l_test_add("TLS connection domain match 6", test_tls_test,
+			&tls_conn_test_domain_match6);
+	l_test_add("TLS connection domain match 7", test_tls_test,
+			&tls_conn_test_domain_match7);
 	l_test_add("TLS connection domain mismatch 1", test_tls_test,
 			&tls_conn_test_domain_mismatch1);
 	l_test_add("TLS connection domain mismatch 2", test_tls_test,
@@ -888,6 +954,8 @@ int main(int argc, char *argv[])
 			&tls_conn_test_domain_mismatch4);
 	l_test_add("TLS connection domain mismatch 5", test_tls_test,
 			&tls_conn_test_domain_mismatch5);
+	l_test_add("TLS connection domain mismatch 6", test_tls_test,
+			&tls_conn_test_domain_mismatch6);
 =

 	for (i =3D 0; tls_cipher_suite_pref[i]; i++) {
 		struct tls_cipher_suite *suite =3D tls_cipher_suite_pref[i];
-- =

2.20.1


--===============1777895895006364407==--

