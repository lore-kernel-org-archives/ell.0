Content-Type: multipart/mixed; boundary="===============7878349653566210827=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 17/17] unit: TLS connection end-to-end tests.
Date: Fri, 24 Jul 2015 05:27:52 +0200
Message-ID: <1437708472-28124-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7878349653566210827==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a test of 6 scenarios where two struct l_tls instances negotiate
a connection and exchange some data.  They use the example certificates
and private keys added earlier.
---
 unit/test-tls.c | 203 ++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 203 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 49d754f..b07603e 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -165,6 +165,196 @@ static void test_tls12_prf(const void *data)
 	assert(!memcmp(out_buf, test->expected, test->out_len));
 }
 =

+struct tls_conn_test {
+	const char *server_cert_path;
+	const char *server_key_path;
+	const char *server_key_passphrase;
+	const char *server_ca_cert_path;
+	const char *server_expect_identity;
+	const char *client_cert_path;
+	const char *client_key_path;
+	const char *client_key_passphrase;
+	const char *client_ca_cert_path;
+	const char *client_expect_identity;
+};
+
+static const struct tls_conn_test tls_conn_test_no_auth =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_expect_identity =3D NULL,
+	.client_expect_identity =3D NULL,
+};
+
+static const struct tls_conn_test tls_conn_test_server_auth =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_expect_identity =3D NULL,
+	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+};
+
+static const struct tls_conn_test tls_conn_test_client_auth_attempt =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.server_expect_identity =3D NULL,
+	.client_expect_identity =3D NULL,
+};
+
+static const struct tls_conn_test tls_conn_test_client_auth =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.server_expect_identity =3D "Bar Example Organization",
+	.client_cert_path =3D TESTDATADIR "/cert-client.pem",
+	.client_key_path =3D TESTDATADIR "/cert-client-key.pem",
+	.client_expect_identity =3D NULL,
+};
+
+static const struct tls_conn_test tls_conn_test_full_auth_attempt =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.server_expect_identity =3D NULL,
+	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+};
+
+static const struct tls_conn_test tls_conn_test_full_auth =3D {
+	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.server_expect_identity =3D "Bar Example Organization",
+	.client_cert_path =3D TESTDATADIR "/cert-client.pem",
+	.client_key_path =3D TESTDATADIR "/cert-client-key.pem",
+	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
+	.client_expect_identity =3D "Foo Example Organization",
+};
+
+#define identity_compare(a, b) ((!(a) && !(b)) || ((a) && (b) && !strcmp(a=
, b)))
+
+struct tls_test_state {
+	struct l_tls *tls;
+
+	bool ready, success;
+
+	uint8_t raw_buf[16384];
+	int raw_buf_len;
+
+	uint8_t plaintext_buf[128];
+	int plaintext_buf_len;
+
+	const char *send_data;
+	const char *expect_data;
+	const char *expect_peer;
+};
+
+static void tls_test_new_data(void *user_data, const uint8_t *data, size_t=
 len)
+{
+	struct tls_test_state *s =3D user_data;
+
+	assert(s->ready);
+	assert(s->plaintext_buf_len + len <=3D strlen(s->expect_data));
+
+	memcpy(s->plaintext_buf + s->plaintext_buf_len, data, len);
+	s->plaintext_buf_len +=3D len;
+
+	if (s->plaintext_buf_len =3D=3D (int) strlen(s->expect_data) &&
+			!memcmp(s->plaintext_buf, s->expect_data,
+				s->plaintext_buf_len))
+		s->success =3D true;
+}
+
+static void tls_test_write(void *user_data, const uint8_t *data, size_t le=
n)
+{
+	struct tls_test_state *s =3D user_data;
+
+	assert(s->raw_buf_len + len <=3D sizeof(s->raw_buf));
+
+	memcpy(s->raw_buf + s->raw_buf_len, data, len);
+	s->raw_buf_len +=3D len;
+}
+
+static void tls_test_ready(void *user_data, const char *peer_identity)
+{
+	struct tls_test_state *s =3D user_data;
+
+	assert(!s->ready);
+	assert(identity_compare(s->expect_peer, peer_identity));
+	s->ready =3D true;
+
+	l_tls_write(s->tls, (const uint8_t *) s->send_data,
+			strlen(s->send_data));
+}
+
+static void tls_test_disconnected(void *user_data, enum l_tls_alert_desc r=
eason,
+					bool remote)
+{
+	assert(false);
+}
+
+static void test_tls_test(const void *data)
+{
+	const struct tls_conn_test *test =3D data;
+	struct tls_test_state s[2] =3D {
+		{
+			.ready =3D false,
+			.success =3D false,
+			.raw_buf_len =3D 0,
+			.plaintext_buf_len =3D 0,
+			.send_data =3D "server to client",
+			.expect_data =3D "client to server",
+			.expect_peer =3D test->server_expect_identity,
+		},
+		{
+			.ready =3D false,
+			.success =3D false,
+			.raw_buf_len =3D 0,
+			.plaintext_buf_len =3D 0,
+			.send_data =3D "client to server",
+			.expect_data =3D "server to client",
+			.expect_peer =3D test->client_expect_identity,
+		},
+	};
+
+	/* Server */
+	s[0].tls =3D l_tls_new(true, tls_test_new_data, tls_test_write,
+				tls_test_ready, tls_test_disconnected, &s[0]);
+	/* Client */
+	s[1].tls =3D l_tls_new(false, tls_test_new_data, tls_test_write,
+				tls_test_ready, tls_test_disconnected, &s[1]);
+
+	assert(s[0].tls);
+	assert(s[1].tls);
+
+	l_tls_set_auth_data(s[0].tls, test->server_cert_path,
+				test->server_key_path,
+				test->server_key_passphrase);
+	l_tls_set_auth_data(s[1].tls, test->client_cert_path,
+				test->client_key_path,
+				test->client_key_passphrase);
+	l_tls_set_cacert(s[0].tls, test->server_ca_cert_path);
+	l_tls_set_cacert(s[1].tls, test->client_ca_cert_path);
+
+	while (1) {
+		if (s[0].raw_buf_len) {
+			l_tls_handle_rx(s[1].tls, s[0].raw_buf,
+					s[0].raw_buf_len);
+			s[0].raw_buf_len =3D 0;
+		} else if (s[1].raw_buf_len) {
+			l_tls_handle_rx(s[0].tls, s[1].raw_buf,
+					s[1].raw_buf_len);
+			s[1].raw_buf_len =3D 0;
+		} else
+			break;
+	}
+
+	assert(s[0].success && s[1].success);
+
+	l_tls_free(s[0].tls);
+	l_tls_free(s[1].tls);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -178,5 +368,18 @@ int main(int argc, char *argv[])
 	l_test_add("TLS 1.2 PRF with SHA512", test_tls12_prf,
 			&tls12_prf_sha512_0);
 =

+	l_test_add("TLS connection no auth", test_tls_test,
+			&tls_conn_test_no_auth);
+	l_test_add("TLS connection server auth", test_tls_test,
+			&tls_conn_test_server_auth);
+	l_test_add("TLS connection client auth attempt", test_tls_test,
+			&tls_conn_test_client_auth_attempt);
+	l_test_add("TLS connection client auth", test_tls_test,
+			&tls_conn_test_client_auth);
+	l_test_add("TLS connection full auth attempt", test_tls_test,
+			&tls_conn_test_full_auth_attempt);
+	l_test_add("TLS connection full auth", test_tls_test,
+			&tls_conn_test_full_auth);
+
 	return l_test_run();
 }
-- =

2.1.4


--===============7878349653566210827==--

