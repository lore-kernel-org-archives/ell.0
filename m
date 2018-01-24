Content-Type: multipart/mixed; boundary="===============4461839467302725051=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/4] unit: Add kernel bug information to AEAD encryption
 failure output
Date: Wed, 24 Jan 2018 13:51:29 -0800
Message-ID: <20180124215129.13337-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180124215129.13337-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4461839467302725051==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index c99650c..4765c3e 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -26,6 +26,7 @@
 =

 #include <assert.h>
 #include <alloca.h>
+#include <stdio.h>
 =

 #include <ell/ell.h>
 =

@@ -203,6 +204,12 @@ static void test_aes_ccm(const void *data)
 =

 	success =3D l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
 					nonce, noncelen, encbuf, encbuflen);
+	if (!success) {
+		printf("* Some kernel versions before v4.9 have a known AEAD\n"
+			"* bug. If the system running this test is using a\n"
+			"* v4.8 or earlier kernel, a failure here is likely\n"
+			"* due to that kernel bug.\n");
+	}
 	assert(success);
 =

 	r =3D memcmp(encbuf, ct, ctlen);
-- =

2.16.1


--===============4461839467302725051==--

