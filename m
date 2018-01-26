Content-Type: multipart/mixed; boundary="===============0112095353283151887=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 3/3] unit: test more_tofollow flag in l_tls_write_cb_t
Date: Fri, 26 Jan 2018 09:57:42 -0800
Message-ID: <20180126175742.11881-3-tim.a.kourt@linux.intel.com>
In-Reply-To: <20180126175742.11881-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0112095353283151887==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 130 ++++++++++++++++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 126 insertions(+), 4 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index d568097..16dd6c5 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -306,15 +306,17 @@ static const struct tls_conn_test tls_conn_test_full_=
auth =3D {
 =

 #define identity_compare(a, b) ((!(a) && !(b)) || ((a) && (b) && !strcmp(a=
, b)))
 =

+#define TX_RECORD_MAX_LEN 4096
+
 struct tls_test_state {
 	struct l_tls *tls;
 =

-	bool ready, success;
+	bool ready, success, is_block_processed;
 =

 	uint8_t raw_buf[16384];
 	int raw_buf_len;
 =

-	uint8_t plaintext_buf[128];
+	uint8_t plaintext_buf[TX_RECORD_MAX_LEN * 3];
 	int plaintext_buf_len;
 =

 	const char *send_data;
@@ -322,7 +324,8 @@ struct tls_test_state {
 	const char *expect_peer;
 };
 =

-static void tls_test_new_data(const uint8_t *data, size_t len, void *user_=
data)
+static void tls_test_new_data(const uint8_t *data, size_t len,
+				bool more_tofollow, void *user_data)
 {
 	struct tls_test_state *s =3D user_data;
 =

@@ -338,7 +341,8 @@ static void tls_test_new_data(const uint8_t *data, size=
_t len, void *user_data)
 		s->success =3D true;
 }
 =

-static void tls_test_write(const uint8_t *data, size_t len, void *user_dat=
a)
+static void tls_test_write(const uint8_t *data, size_t len,
+				bool more_tofollow, void *user_data)
 {
 	struct tls_test_state *s =3D user_data;
 =

@@ -430,6 +434,121 @@ static void test_tls_test(const void *data)
 	l_tls_free(s[1].tls);
 }
 =

+static void tls_test_data_block_recieved(const uint8_t *data, size_t len,
+						bool more_tofollow,
+						void *user_data)
+{
+	struct tls_test_state *s =3D user_data;
+
+	assert(s->ready);
+	assert(s->plaintext_buf_len + len <=3D strlen(s->expect_data));
+
+	memcpy(s->plaintext_buf + s->plaintext_buf_len, data, len);
+	s->plaintext_buf_len +=3D len;
+
+	if (more_tofollow)
+		return;
+
+	assert(s->plaintext_buf_len =3D=3D (int) strlen(s->expect_data));
+	assert(!memcmp(s->plaintext_buf, s->expect_data, s->plaintext_buf_len));
+
+	s->success =3D true;
+}
+
+static void tls_test_data_block_send(const uint8_t *data, size_t len,
+					bool more_tofollow, void *user_data)
+{
+	struct tls_test_state *s =3D user_data;
+
+	assert(s->raw_buf_len + len <=3D sizeof(s->raw_buf));
+
+	memcpy(s->raw_buf + s->raw_buf_len, data, len);
+	s->raw_buf_len +=3D len;
+
+	s->is_block_processed =3D !more_tofollow;
+}
+
+static void test_tls_test_data_block_transfer(const void *data)
+{
+	bool auth_ok;
+	const struct tls_conn_test *test =3D data;
+	char client_to_server_buf[TX_RECORD_MAX_LEN * 2 + 2];
+	char server_to_client_buf[TX_RECORD_MAX_LEN + 2];
+	struct tls_test_state s[2] =3D {
+		{
+			.ready =3D false,
+			.success =3D false,
+			.is_block_processed =3D false,
+			.raw_buf_len =3D 0,
+			.plaintext_buf_len =3D 0,
+			.send_data =3D client_to_server_buf,
+			.expect_data =3D server_to_client_buf,
+			.expect_peer =3D test->server_expect_identity,
+		},
+		{
+			.ready =3D false,
+			.success =3D false,
+			.is_block_processed =3D false,
+			.raw_buf_len =3D 0,
+			.plaintext_buf_len =3D 0,
+			.send_data =3D server_to_client_buf,
+			.expect_data =3D client_to_server_buf,
+			.expect_peer =3D test->client_expect_identity,
+		},
+	};
+
+	memset(&client_to_server_buf, 'C', sizeof(client_to_server_buf) - 1);
+	memset(&server_to_client_buf, 'S', sizeof(server_to_client_buf) - 1);
+
+	client_to_server_buf[sizeof(client_to_server_buf) - 1] =3D '\0';
+	server_to_client_buf[sizeof(server_to_client_buf) - 1] =3D '\0';
+
+	/* Server */
+	s[0].tls =3D l_tls_new(true, tls_test_data_block_recieved,
+				tls_test_data_block_send,
+				tls_test_ready,
+				tls_test_disconnected, &s[0]);
+	/* Client */
+	s[1].tls =3D l_tls_new(false, tls_test_data_block_recieved,
+				tls_test_data_block_send,
+				tls_test_ready,
+				tls_test_disconnected, &s[1]);
+
+	assert(s[0].tls);
+	assert(s[1].tls);
+
+	auth_ok =3D l_tls_set_auth_data(s[0].tls, test->server_cert_path,
+					test->server_key_path,
+					test->server_key_passphrase);
+	assert(auth_ok);
+	auth_ok =3D l_tls_set_auth_data(s[1].tls, test->client_cert_path,
+					test->client_key_path,
+					test->client_key_passphrase);
+	assert(auth_ok);
+	l_tls_set_cacert(s[0].tls, test->server_ca_cert_path);
+	l_tls_set_cacert(s[1].tls, test->client_ca_cert_path);
+
+	while (1) {
+		if (s[0].is_block_processed) {
+			l_tls_handle_rx(s[1].tls, s[0].raw_buf,
+					s[0].raw_buf_len);
+			s[0].raw_buf_len =3D 0;
+			s[0].is_block_processed =3D false;
+		} else if (s[1].is_block_processed) {
+			l_tls_handle_rx(s[0].tls, s[1].raw_buf,
+					s[1].raw_buf_len);
+			s[1].raw_buf_len =3D 0;
+			s[1].is_block_processed =3D false;
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
@@ -489,6 +608,9 @@ int main(int argc, char *argv[])
 			&tls_conn_test_full_auth_attempt);
 	l_test_add("TLS connection full auth", test_tls_test,
 			&tls_conn_test_full_auth);
+	l_test_add("TLS connection data block transfer",
+			test_tls_test_data_block_transfer,
+			&tls_conn_test_full_auth);
 =

 done:
 	return l_test_run();
-- =

2.9.4


--===============0112095353283151887==--

