Content-Type: multipart/mixed; boundary="===============7304855003874883883=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] unit: Add l_tls_set_domain_mask tests
Date: Fri, 23 Aug 2019 02:41:32 +0200
Message-ID: <20190823004138.5480-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7304855003874883883==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 169 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 169 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index d701f42..36f9934 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -309,6 +309,7 @@ struct tls_conn_test {
 	const char *client_ca_cert_path;
 	const char *client_expect_identity;
 	const char **client_cipher_suites;
+	char **client_domain_mask;
 	bool expect_alert;
 	bool expect_client_start_fail;
 	enum l_tls_alert_desc alert_desc;
@@ -566,6 +567,9 @@ static void test_tls_with_ver(const struct tls_conn_tes=
t *test,
 	assert(l_tls_set_cacert(s[0].tls, test->server_ca_cert_path));
 	assert(l_tls_set_cacert(s[1].tls, test->client_ca_cert_path));
 =

+	if (test->client_domain_mask)
+		l_tls_set_domain_mask(s[1].tls, test->client_domain_mask);
+
 	assert(l_tls_start(s[0].tls));
 	assert(!!l_tls_start(s[1].tls) =3D=3D !test->expect_client_start_fail);
 =

@@ -616,6 +620,152 @@ static void test_tls_version_mismatch_test(const void=
 *data)
 				L_TLS_V10, L_TLS_V11);
 }
 =

+static const struct tls_conn_test tls_conn_test_domain_match1 =3D {
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
+	.client_domain_mask =3D (char *[]) { "Foo Example Organization", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match2 =3D {
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
+		"Foo Example Organization", "Bar Example Organization", NULL
+	},
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match3 =3D {
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
+		"Bar Example Organization", "Foo Example Organization", NULL
+	},
+};
+
+static const struct tls_conn_test tls_conn_test_domain_match4 =3D {
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
+	.client_domain_mask =3D (char *[]) { "*", NULL },
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch1 =3D {
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
+	.client_domain_mask =3D (char *[]) { "", NULL },
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch2 =3D {
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
+	.client_domain_mask =3D (char *[]) { "Bar Example Organization", NULL },
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch3 =3D {
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
+		"Foo Example Organization.com", NULL
+	},
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch4 =3D {
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
+		"Foo Example Organization.*", NULL
+	},
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_domain_mismatch5 =3D {
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
+		"*.Foo Example Organization", NULL
+	},
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_BAD_CERT,
+};
+
 static void test_tls_suite_test(const void *data)
 {
 	const char *suite_name =3D data;
@@ -720,6 +870,25 @@ int main(int argc, char *argv[])
 	l_test_add("TLS connection version mismatch",
 			test_tls_version_mismatch_test, NULL);
 =

+	l_test_add("TLS connection domain match 1", test_tls_test,
+			&tls_conn_test_domain_match1);
+	l_test_add("TLS connection domain match 2", test_tls_test,
+			&tls_conn_test_domain_match2);
+	l_test_add("TLS connection domain match 3", test_tls_test,
+			&tls_conn_test_domain_match3);
+	l_test_add("TLS connection domain match 4", test_tls_test,
+			&tls_conn_test_domain_match4);
+	l_test_add("TLS connection domain mismatch 1", test_tls_test,
+			&tls_conn_test_domain_mismatch1);
+	l_test_add("TLS connection domain mismatch 2", test_tls_test,
+			&tls_conn_test_domain_mismatch2);
+	l_test_add("TLS connection domain mismatch 3", test_tls_test,
+			&tls_conn_test_domain_mismatch3);
+	l_test_add("TLS connection domain mismatch 4", test_tls_test,
+			&tls_conn_test_domain_mismatch4);
+	l_test_add("TLS connection domain mismatch 5", test_tls_test,
+			&tls_conn_test_domain_mismatch5);
+
 	for (i =3D 0; tls_cipher_suite_pref[i]; i++) {
 		struct tls_cipher_suite *suite =3D tls_cipher_suite_pref[i];
 		struct tls_bulk_encryption_algorithm *alg =3D suite->encryption;
-- =

2.20.1


--===============7304855003874883883==--

