Content-Type: multipart/mixed; boundary="===============0688199131581733487=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 9/9] unit: Test many TLS cipher suite and version combinations
Date: Wed, 19 Dec 2018 01:58:00 +0100
Message-ID: <20181219005800.12013-9-andrew.zaborowski@intel.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0688199131581733487==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 131 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 123 insertions(+), 8 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 2b5d16b..fb97c44 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -302,11 +302,16 @@ struct tls_conn_test {
 	const char *server_key_passphrase;
 	const char *server_ca_cert_path;
 	const char *server_expect_identity;
+	const char **server_cipher_suites;
 	const char *client_cert_path;
 	const char *client_key_path;
 	const char *client_key_passphrase;
 	const char *client_ca_cert_path;
 	const char *client_expect_identity;
+	const char **client_cipher_suites;
+	bool expect_alert;
+	bool expect_client_start_fail;
+	enum l_tls_alert_desc alert_desc;
 };
 =

 static const struct tls_conn_test tls_conn_test_no_auth =3D {
@@ -362,6 +367,49 @@ static const struct tls_conn_test tls_conn_test_full_a=
uth =3D {
 	.client_expect_identity =3D "Foo Example Organization",
 };
 =

+static const struct tls_conn_test tls_conn_test_bad_client_suite =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "Bar Example Organization",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+	.client_cipher_suites =3D (const char *[]) { "UNKNOWN", NULL },
+	.expect_client_start_fail =3D true,
+};
+
+static const struct tls_conn_test tls_conn_test_suite_mismatch =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "Bar Example Organization",
+	.server_cipher_suites =3D
+		(const char *[]) { "TLS_RSA_WITH_AES_128_CBC_SHA256", NULL },
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+	.client_cipher_suites =3D
+		(const char *[]) { "TLS_RSA_WITH_AES_256_CBC_SHA256", NULL },
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_INSUFFICIENT_SECURITY,
+};
+
+static const struct tls_conn_test tls_conn_test_version_mismatch =3D {
+	.server_cert_path =3D CERTDIR "cert-server.pem",
+	.server_key_path =3D CERTDIR "cert-server-key-pkcs8.pem",
+	.server_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.server_expect_identity =3D "Bar Example Organization",
+	.client_cert_path =3D CERTDIR "cert-client.pem",
+	.client_key_path =3D CERTDIR "cert-client-key-pkcs8.pem",
+	.client_ca_cert_path =3D CERTDIR "cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+	.expect_alert =3D true,
+	.alert_desc =3D TLS_ALERT_PROTOCOL_VERSION,
+};
+
 #define identity_compare(a, b) ((!(a) && !(b)) || ((a) && (b) && !strcmp(a=
, b)))
 =

 struct tls_test_state {
@@ -378,6 +426,9 @@ struct tls_test_state {
 	const char *send_data;
 	const char *expect_data;
 	const char *expect_peer;
+
+	bool expect_alert;
+	enum l_tls_alert_desc alert_desc;
 };
 =

 static void tls_test_new_data(const uint8_t *data, size_t len, void *user_=
data)
@@ -411,6 +462,7 @@ static void tls_test_ready(const char *peer_identity, v=
oid *user_data)
 	struct tls_test_state *s =3D user_data;
 =

 	assert(!s->ready);
+	assert(!s->expect_alert);
 	assert((!s->expect_peer && !peer_identity) ||
 			(s->expect_peer && peer_identity &&
 			 !strcmp(s->expect_peer, peer_identity)));
@@ -423,7 +475,11 @@ static void tls_test_ready(const char *peer_identity, =
void *user_data)
 static void tls_test_disconnected(enum l_tls_alert_desc reason, bool remot=
e,
 					void *user_data)
 {
-	assert(false);
+	struct tls_test_state *s =3D user_data;
+
+	assert(s->expect_alert);
+	assert(reason =3D=3D s->alert_desc);
+	s->success =3D true;
 }
 =

 static void tls_debug_cb(const char *str, void *user_data)
@@ -431,11 +487,10 @@ static void tls_debug_cb(const char *str, void *user_=
data)
 	l_info("%s %s", (const char *) user_data, str);
 }
 =

-static void test_tls_with_ver(const void *data,
+static void test_tls_with_ver(const struct tls_conn_test *test,
 				uint16_t server_ver, uint16_t client_ver)
 {
 	bool auth_ok;
-	const struct tls_conn_test *test =3D data;
 	struct tls_test_state s[2] =3D {
 		{
 			.ready =3D false,
@@ -445,6 +500,8 @@ static void test_tls_with_ver(const void *data,
 			.send_data =3D "server to client",
 			.expect_data =3D "client to server",
 			.expect_peer =3D test->server_expect_identity,
+			.expect_alert =3D test->expect_alert,
+			.alert_desc =3D test->alert_desc,
 		},
 		{
 			.ready =3D false,
@@ -454,6 +511,8 @@ static void test_tls_with_ver(const void *data,
 			.send_data =3D "client to server",
 			.expect_data =3D "server to client",
 			.expect_peer =3D test->client_expect_identity,
+			.expect_alert =3D test->expect_alert,
+			.alert_desc =3D test->alert_desc,
 		},
 	};
 =

@@ -473,6 +532,12 @@ static void test_tls_with_ver(const void *data,
 	if (client_ver)
 		l_tls_set_version_range(s[1].tls, client_ver, client_ver);
 =

+	if (test->server_cipher_suites)
+		tls_set_cipher_suites(s[0].tls, test->server_cipher_suites);
+
+	if (test->client_cipher_suites)
+		tls_set_cipher_suites(s[1].tls, test->client_cipher_suites);
+
 	if (getenv("TLS_SERVER_DEBUG"))
 		l_tls_set_debug(s[0].tls, tls_debug_cb, "server", NULL);
 =

@@ -491,9 +556,12 @@ static void test_tls_with_ver(const void *data,
 	assert(l_tls_set_cacert(s[1].tls, test->client_ca_cert_path));
 =

 	assert(l_tls_start(s[0].tls));
-	assert(l_tls_start(s[1].tls));
+	assert(!!l_tls_start(s[1].tls) =3D=3D !test->expect_client_start_fail);
 =

-	while (1) {
+	if (test->expect_client_start_fail)
+		goto done;
+
+	while (!(test->expect_alert && s[0].success && s[1].success)) {
 		if (s[0].raw_buf_len) {
 			l_tls_handle_rx(s[1].tls, s[0].raw_buf,
 					s[0].raw_buf_len);
@@ -508,24 +576,60 @@ static void test_tls_with_ver(const void *data,
 =

 	assert(s[0].success && s[1].success);
 =

+done:
 	l_tls_free(s[0].tls);
 	l_tls_free(s[1].tls);
 }
 =

 static void test_tls_test(const void *data)
 {
+	const struct tls_conn_test *test =3D data;
+
 	/*
 	 * 1.2 should get negotiated in the first case.  If the three
 	 * scenarios succeed that's already good but can be checked with:
 	 * $ TLS_DEBUG=3D1 unit/test-tls 2>&1 | grep "Negotiated"
 	 */
-	test_tls_with_ver(data, 0, 0);
-	test_tls_with_ver(data, 0, L_TLS_V11);
-	test_tls_with_ver(data, L_TLS_V10, 0);
+	test_tls_with_ver(test, 0, 0);
+	test_tls_with_ver(test, 0, L_TLS_V11);
+	test_tls_with_ver(test, L_TLS_V10, 0);
+}
+
+static void test_tls_version_mismatch_test(const void *data)
+{
+	test_tls_with_ver(&tls_conn_test_version_mismatch,
+				L_TLS_V11, L_TLS_V12);
+	test_tls_with_ver(&tls_conn_test_version_mismatch,
+				L_TLS_V12, L_TLS_V10);
+	test_tls_with_ver(&tls_conn_test_version_mismatch,
+				L_TLS_V10, L_TLS_V11);
+}
+
+static void test_tls_suite_test(const void *data)
+{
+	const char *suite_name =3D data;
+	const char *client_cipher_suites[] =3D { suite_name, NULL };
+	struct tls_conn_test test =3D tls_conn_test_full_auth;
+
+	test.client_cipher_suites =3D client_cipher_suites;
+	test_tls_with_ver(&test, 0, 0);
 }
 =

 int main(int argc, char *argv[])
 {
+	const char *suite_names[] =3D {
+		"TLS_RSA_WITH_RC4_128_MD5",
+		"TLS_RSA_WITH_RC4_128_SHA",
+		"TLS_RSA_WITH_3DES_EDE_CBC_SHA",
+		"TLS_RSA_WITH_AES_128_CBC_SHA",
+		"TLS_RSA_WITH_AES_256_CBC_SHA",
+		"TLS_RSA_WITH_AES_128_CBC_SHA256",
+		"TLS_RSA_WITH_AES_256_CBC_SHA256",
+		"TLS_RSA_WITH_AES_128_GCM_SHA256",
+		"TLS_RSA_WITH_AES_256_GCM_SHA384",
+		NULL
+	}, **name;
+
 	l_test_init(&argc, &argv);
 =

 	if (!l_checksum_is_supported(L_CHECKSUM_MD5, false) ||
@@ -584,6 +688,17 @@ int main(int argc, char *argv[])
 	l_test_add("TLS connection full auth", test_tls_test,
 			&tls_conn_test_full_auth);
 =

+	l_test_add("TLS connection bad client cipher suite", test_tls_test,
+			&tls_conn_test_bad_client_suite);
+	l_test_add("TLS connection cipher suite mismatch", test_tls_test,
+			&tls_conn_test_suite_mismatch);
+
+	l_test_add("TLS connection version mismatch",
+			test_tls_version_mismatch_test, NULL);
+
+	for (name =3D suite_names; *name; name++)
+		l_test_add(*name, test_tls_suite_test, *name);
+
 done:
 	return l_test_run();
 }
-- =

2.19.1


--===============0688199131581733487==--

