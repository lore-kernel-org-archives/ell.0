Content-Type: multipart/mixed; boundary="===============8597989526336256156=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] unit: Add graceful fail of pem, tls and key tests
Date: Wed, 26 Feb 2020 09:54:16 -0800
Message-ID: <20200226175416.31769-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8597989526336256156==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Unit tests for PEM, TLS and KEY require the pkcs8_key_parser module
to be running in the kernel, however not all kernels have this
running by default. This checks for this possibility and aborts
these tests with exit(1) rather than an assert, and includes instruction
to correct the issue.
---
 unit/test-key.c |  9 +++++++++
 unit/test-pem.c |  9 +++++++++
 unit/test-tls.c | 12 +++++++++++-
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 697ff47..240a02c 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -569,6 +569,15 @@ static void test_key_crypto(const void *data)
 =

 	privkey =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
 						NULL, NULL);
+	if (!privkey) {
+		l_info("* Some kernel versions do not automatically load\n"
+			"* the pkcs8_key_parser module. If the system running\n"
+			"* test has not loaded this module, a failure here is\n"
+			"* likely. Running \"modprobe pkcs8_key_parser\" may\n"
+			"* correct this issue.\n");
+		exit(1);
+	}
+
 	assert(privkey);
 	success =3D l_key_get_info(privkey, rsa, hash, &keybits, &is_public);
 	assert(success);
diff --git a/unit/test-pem.c b/unit/test-pem.c
index d39003e..a1e8110 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -216,6 +216,15 @@ static void test_priv_key_from_data(const void *data)
 	key =3D l_pem_load_private_key_from_data(raw_private_key,
 						strlen(raw_private_key),
 						"abc", &is_encrypted);
+	if (!key) {
+		l_info("* Some kernel versions do not automatically load\n"
+			"* the pkcs8_key_parser module. If the system running\n"
+			"* test has not loaded this module, a failure here is\n"
+			"* likely. Running \"modprobe pkcs8_key_parser\" may\n"
+			"* correct this issue.\n");
+		exit(1);
+	}
+
 	assert(key);
 	assert(is_encrypted);
 =

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 1d47787..3519376 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -562,8 +562,18 @@ static void test_tls_with_ver(const struct tls_conn_te=
st *test,
 			l_pem_load_private_key(test->server_key_path,
 						test->server_key_passphrase,
 						NULL);
-		assert(server_cert);
+		if (!server_key) {
+			l_info("* Some kernel versions do not automatically\n"
+				"* load the pkcs8_key_parser module. If the\n"
+				"* system running test has not loaded this\n"
+				"* module, a failure here is likely. Running\n"
+				"* \"modprobe pkcs8_key_parser\" may correct\n"
+				"* this issue.\n");
+			exit(1);
+		}
+
 		assert(server_key);
+		assert(server_cert);
 =

 		assert(l_tls_set_auth_data(s[0].tls, server_cert, server_key));
 	}
-- =

2.21.1

--===============8597989526336256156==--

