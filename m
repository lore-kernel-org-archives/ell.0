Content-Type: multipart/mixed; boundary="===============1473447709917372374=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/12] unit: Print TLS debug info if TLS_DEBUG set
Date: Wed, 14 Nov 2018 14:19:02 +0100
Message-ID: <20181114131902.1695-12-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1473447709917372374==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index d969ee7..005aede 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -364,6 +364,11 @@ static void tls_test_disconnected(enum l_tls_alert_des=
c reason, bool remote,
 	assert(false);
 }
 =

+static void tls_debug_cb(const char *str, void *user_data)
+{
+	l_info("%s %s", (const char *) user_data, str);
+}
+
 static void test_tls_test(const void *data)
 {
 	bool auth_ok;
@@ -399,6 +404,11 @@ static void test_tls_test(const void *data)
 	assert(s[0].tls);
 	assert(s[1].tls);
 =

+	if (getenv("TLS_SERVER_DEBUG"))
+		l_tls_set_debug(s[0].tls, tls_debug_cb, "server", NULL);
+	if (getenv("TLS_DEBUG"))
+		l_tls_set_debug(s[1].tls, tls_debug_cb, "client", NULL);
+
 	auth_ok =3D l_tls_set_auth_data(s[0].tls, test->server_cert_path,
 					test->server_key_path,
 					test->server_key_passphrase);
-- =

2.19.1


--===============1473447709917372374==--

