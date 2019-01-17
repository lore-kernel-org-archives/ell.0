Content-Type: multipart/mixed; boundary="===============5796900524340053084=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] unit: Drop list of cipher suites from test-tls
Date: Thu, 17 Jan 2019 18:19:15 +0100
Message-ID: <20190117171916.27960-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190117171916.27960-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5796900524340053084==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Drop the incomplete list of cipher suite names to test and use the
authoritative array of suites declared in tls-private.h.
---
 unit/test-tls.c | 18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index b372474..ebca9aa 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -620,18 +620,7 @@ static void test_tls_suite_test(const void *data)
 =

 int main(int argc, char *argv[])
 {
-	const char *suite_names[] =3D {
-		"TLS_RSA_WITH_RC4_128_MD5",
-		"TLS_RSA_WITH_RC4_128_SHA",
-		"TLS_RSA_WITH_3DES_EDE_CBC_SHA",
-		"TLS_RSA_WITH_AES_128_CBC_SHA",
-		"TLS_RSA_WITH_AES_256_CBC_SHA",
-		"TLS_RSA_WITH_AES_128_CBC_SHA256",
-		"TLS_RSA_WITH_AES_256_CBC_SHA256",
-		"TLS_RSA_WITH_AES_128_GCM_SHA256",
-		"TLS_RSA_WITH_AES_256_GCM_SHA384",
-		NULL
-	}, **name;
+	unsigned int i;
 =

 	l_test_init(&argc, &argv);
 =

@@ -699,8 +688,9 @@ int main(int argc, char *argv[])
 	l_test_add("TLS connection version mismatch",
 			test_tls_version_mismatch_test, NULL);
 =

-	for (name =3D suite_names; *name; name++)
-		l_test_add(*name, test_tls_suite_test, *name);
+	for (i =3D 0; tls_cipher_suite_pref[i]; i++)
+		l_test_add(tls_cipher_suite_pref[i]->name, test_tls_suite_test,
+				tls_cipher_suite_pref[i]->name);
 =

 done:
 	return l_test_run();
-- =

2.19.1


--===============5796900524340053084==--

