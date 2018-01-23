Content-Type: multipart/mixed; boundary="===============4843514081970447080=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] unit: Add missing newlines and spaces in text output
Date: Tue, 23 Jan 2018 13:02:22 -0800
Message-ID: <20180123210223.28042-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180123210223.28042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4843514081970447080==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 2426005..5dc921d 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -456,15 +456,15 @@ int main(int argc, char *argv[])
 	l_test_add("Certificate chains", test_certificates, NULL);
 =

 	if (!l_getrandom_is_supported()) {
-		printf("getrandom missing, skipping TLS connection tests...");
+		printf("getrandom missing, skipping TLS connection tests...\n");
 		goto done;
 	}
 =

 	if (!l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC) ||
 			!l_cipher_is_supported(L_CIPHER_AES_CBC) ||
 			!l_cipher_is_supported(L_CIPHER_ARC4)) {
-		printf("Needed ciphers missing,"
-				"skipping TLS connection tests...");
+		printf("Needed ciphers missing, "
+				"skipping TLS connection tests...\n");
 		goto done;
 	}
 =

-- =

2.16.1


--===============4843514081970447080==--

