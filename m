Content-Type: multipart/mixed; boundary="===============2784949212636296537=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Add runtime check for TLS suite cipher support
Date: Fri, 15 Feb 2019 14:01:37 -0800
Message-ID: <20190215220137.7592-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2784949212636296537==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Skip TLS suite tests where the currently running kernel does not have
support for the necessary cipher. Checksums types already have runtime
validation.
---
 unit/test-tls.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 01496d2..03c5370 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -709,9 +709,24 @@ int main(int argc, char *argv[])
 	l_test_add("TLS connection version mismatch",
 			test_tls_version_mismatch_test, NULL);
 =

-	for (i =3D 0; tls_cipher_suite_pref[i]; i++)
-		l_test_add(tls_cipher_suite_pref[i]->name, test_tls_suite_test,
-				tls_cipher_suite_pref[i]->name);
+	for (i =3D 0; tls_cipher_suite_pref[i]; i++) {
+		struct tls_cipher_suite *suite =3D tls_cipher_suite_pref[i];
+		struct tls_bulk_encryption_algorithm *alg =3D suite->encryption;
+		bool supported;
+
+		if (alg->cipher_type =3D=3D TLS_CIPHER_AEAD)
+			supported =3D l_aead_cipher_is_supported(alg->l_aead_id);
+		else
+			supported =3D l_cipher_is_supported(alg->l_id);
+
+		if (supported) {
+			l_test_add(suite->name, test_tls_suite_test,
+					suite->name);
+		} else {
+			printf("Skipping %s due to missing cipher support\n",
+				suite->name);
+		}
+	}
 =

 done:
 	return l_test_run();
-- =

2.20.1


--===============2784949212636296537==--

