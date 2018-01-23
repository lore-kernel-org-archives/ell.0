Content-Type: multipart/mixed; boundary="===============7702051743689198426=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/4] unit: Skip TLS tests that are not supported by the
 running kernel
Date: Tue, 23 Jan 2018 13:02:23 -0800
Message-ID: <20180123210223.28042-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180123210223.28042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7702051743689198426==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 5dc921d..d568097 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -32,6 +32,7 @@
 #include "ell/cipher.h"
 #include "ell/checksum.h"
 #include "ell/tls-private.h"
+#include "ell/key-private.h"
 =

 static void test_tls10_prf(const void *data)
 {
@@ -453,7 +454,8 @@ int main(int argc, char *argv[])
 	l_test_add("TLS 1.2 PRF with SHA512", test_tls12_prf,
 			&tls12_prf_sha512_0);
 =

-	l_test_add("Certificate chains", test_certificates, NULL);
+	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT))
+		l_test_add("Certificate chains", test_certificates, NULL);
 =

 	if (!l_getrandom_is_supported()) {
 		printf("getrandom missing, skipping TLS connection tests...\n");
@@ -468,6 +470,13 @@ int main(int argc, char *argv[])
 		goto done;
 	}
 =

+	if (!l_key_is_supported(L_KEY_FEATURE_RESTRICT |
+				L_KEY_FEATURE_CRYPTO)) {
+		printf("Kernel lacks key restrictions or crypto, "
+			"skipping TLS connection tests...\n");
+		goto done;
+	}
+
 	l_test_add("TLS connection no auth", test_tls_test,
 			&tls_conn_test_no_auth);
 	l_test_add("TLS connection server auth", test_tls_test,
-- =

2.16.1


--===============7702051743689198426==--

