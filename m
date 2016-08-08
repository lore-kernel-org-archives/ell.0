Content-Type: multipart/mixed; boundary="===============3026356313819456614=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 5/6] unit: Check return value of l_tls_set_auth_data
Date: Mon, 08 Aug 2016 10:25:44 -0700
Message-ID: <20160808172545.6648-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160808172545.6648-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3026356313819456614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 9ddb80c..0d23f16 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -356,6 +356,7 @@ static void tls_test_disconnected(enum l_tls_alert_desc=
 reason, bool remote,
 =

 static void test_tls_test(const void *data)
 {
+	bool auth_ok;
 	const struct tls_conn_test *test =3D data;
 	struct tls_test_state s[2] =3D {
 		{
@@ -388,12 +389,14 @@ static void test_tls_test(const void *data)
 	assert(s[0].tls);
 	assert(s[1].tls);
 =

-	l_tls_set_auth_data(s[0].tls, test->server_cert_path,
-				test->server_key_path,
-				test->server_key_passphrase);
-	l_tls_set_auth_data(s[1].tls, test->client_cert_path,
-				test->client_key_path,
-				test->client_key_passphrase);
+	auth_ok =3D l_tls_set_auth_data(s[0].tls, test->server_cert_path,
+					test->server_key_path,
+					test->server_key_passphrase);
+	assert(auth_ok);
+	auth_ok =3D l_tls_set_auth_data(s[1].tls, test->client_cert_path,
+					test->client_key_path,
+					test->client_key_passphrase);
+	assert(auth_ok);
 	l_tls_set_cacert(s[0].tls, test->server_ca_cert_path);
 	l_tls_set_cacert(s[1].tls, test->client_ca_cert_path);
 =

-- =

2.9.2


--===============3026356313819456614==--

