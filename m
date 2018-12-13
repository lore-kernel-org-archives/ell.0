Content-Type: multipart/mixed; boundary="===============0680015490756265194=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/9] unit: Test TLS 1.0, 1.1 and 1.2
Date: Thu, 13 Dec 2018 20:57:42 +0100
Message-ID: <20181213195746.32144-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0680015490756265194==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 04fd3ea..f39d95a 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -417,7 +417,8 @@ static void tls_debug_cb(const char *str, void *user_da=
ta)
 	l_info("%s %s", (const char *) user_data, str);
 }
 =

-static void test_tls_test(const void *data)
+static void test_tls_with_ver(const void *data,
+				uint16_t server_ver, uint16_t client_ver)
 {
 	bool auth_ok;
 	const struct tls_conn_test *test =3D data;
@@ -452,6 +453,12 @@ static void test_tls_test(const void *data)
 	assert(s[0].tls);
 	assert(s[1].tls);
 =

+	if (server_ver)
+		l_tls_set_version_range(s[0].tls, server_ver, server_ver);
+
+	if (client_ver)
+		l_tls_set_version_range(s[1].tls, client_ver, client_ver);
+
 	if (getenv("TLS_SERVER_DEBUG"))
 		l_tls_set_debug(s[0].tls, tls_debug_cb, "server", NULL);
 =

@@ -491,6 +498,18 @@ static void test_tls_test(const void *data)
 	l_tls_free(s[1].tls);
 }
 =

+static void test_tls_test(const void *data)
+{
+	/*
+	 * 1.2 should get negotiated in the first case.  If the three
+	 * scenarios succeed that's already good but can be checked with:
+	 * $ TLS_DEBUG=3D1 unit/test-tls 2>&1 | grep "Negotiated"
+	 */
+	test_tls_with_ver(data, 0, 0);
+	test_tls_with_ver(data, 0, L_TLS_V11);
+	test_tls_with_ver(data, L_TLS_V10, 0);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
-- =

2.19.1


--===============0680015490756265194==--

