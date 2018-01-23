Content-Type: multipart/mixed; boundary="===============8016716934627619627=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/4] unit: Skip key tests that are not supported by the
 running kernel
Date: Tue, 23 Jan 2018 13:02:21 -0800
Message-ID: <20180123210223.28042-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180123210223.28042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8016716934627619627==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index f2526f5..8851580 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -27,6 +27,7 @@
 #include <assert.h>
 =

 #include <ell/ell.h>
+#include "ell/key-private.h"
 =

 #define KEY1_STR "This key has exactly _32_ bytes!"
 #define KEY1_LEN (strlen(KEY1_STR))
@@ -618,15 +619,21 @@ int main(int argc, char *argv[])
 =

 	l_test_add("user key", test_user, NULL);
 =

-	l_test_add("Diffie-Hellman 1", test_dh, &dh_valid1);
-	l_test_add("Diffie-Hellman 2", test_dh, &dh_valid2);
-	l_test_add("Diffie-Hellman 3", test_dh, &dh_degenerate);
+	if (l_key_is_supported(L_KEY_FEATURE_DH)) {
+		l_test_add("Diffie-Hellman 1", test_dh, &dh_valid1);
+		l_test_add("Diffie-Hellman 2", test_dh, &dh_valid2);
+		l_test_add("Diffie-Hellman 3", test_dh, &dh_degenerate);
+	}
 =

 	l_test_add("simple keyring", test_simple_keyring, NULL);
-	l_test_add("trusted keyring", test_trusted_keyring, NULL);
-	l_test_add("trust chain", test_trust_chain, NULL);
 =

-	l_test_add("key crypto", test_key_crypto, NULL);
+	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
+		l_test_add("trusted keyring", test_trusted_keyring, NULL);
+		l_test_add("trust chain", test_trust_chain, NULL);
+	}
+
+	if (l_key_is_supported(L_KEY_FEATURE_CRYPTO))
+		l_test_add("key crypto", test_key_crypto, NULL);
 =

 	return l_test_run();
 }
-- =

2.16.1


--===============8016716934627619627==--

