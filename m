Content-Type: multipart/mixed; boundary="===============0346231892418915721=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/8] unit: Add TLS tests for cert's DNSName matching
Date: Fri, 23 Aug 2019 02:41:38 +0200
Message-ID: <20190823004138.5480-8-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0346231892418915721==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 36f9934..2e88235 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -680,6 +680,48 @@ static const struct tls_conn_test tls_conn_test_domain=
_match4 =3D {
 	.client_domain_mask =3D (char *[]) { "*", NULL },
 };
 =

+static const struct tls_conn_test tls_conn_test_domain_match5 =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "foo.int.com", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match6 =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "*.*", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match7 =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_domain_mask =3D (char *[]) { "*.*.*", NULL },
+};
+
 static const struct tls_conn_test tls_conn_test_domain_mismatch1 =3D {
 	.server_cert_path =3D CERTDIR "cert-server.pem",
 	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
@@ -766,6 +808,24 @@ static const struct tls_conn_test tls_conn_test_domain=
_mismatch5 =3D {
 	.alert_desc =3D TLS_ALERT_BAD_CERT,
 };
 =

+static const struct tls_conn_test tls_conn_test_domain_mismatch6 =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "/O=3DBar Example Organization"
+		"/CN=3DBar Example Organization/emailAddress=3Dbar(a)mail.example",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "/O=3DFoo Example Organization"
+		"/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)mail.example",
+	.client_domain_mask =3D (char *[]) {
+		"foo.*", NULL
+	},
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
 static void test_tls_suite_test(const void *data)
 {
 	const char *suite_name =3D data;
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


--===============0346231892418915721==--

