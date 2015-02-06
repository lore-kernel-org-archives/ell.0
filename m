Content-Type: multipart/mixed; boundary="===============2359715240258728671=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 2/2] unit: Add unit test for the cipher infrastructure
Date: Fri, 06 Feb 2015 14:39:23 +0200
Message-ID: <1423226363-5025-3-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423226363-5025-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2359715240258728671==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It quickly encrypt, verify that the buffer has different content, and
again decrypt and verify now it has the same content.
---
 Makefile.am        |   5 ++-
 unit/test-cipher.c | 107 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 111 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-cipher.c

diff --git a/Makefile.am b/Makefile.am
index 910d5e0..e32054f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -107,7 +107,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-gvariant-util \
 			unit/test-gvariant-message \
 			unit/test-siphash \
-			unit/test-hwdb
+			unit/test-hwdb \
+			unit/test-cipher
 =

 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(unit_tests)
@@ -157,6 +158,8 @@ unit_test_siphash_LDADD =3D ell/libell-private.la
 =

 unit_test_hwdb_LDADD =3D ell/libell-private.la
 =

+unit_test_cipher_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-cipher.c b/unit/test-cipher.c
new file mode 100644
index 0000000..41a4447
--- /dev/null
+++ b/unit/test-cipher.c
@@ -0,0 +1,107 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <assert.h>
+
+#include <ell/ell.h>
+
+#define FIXED_STR  "The quick brown fox jumps over the lazy dog. " \
+		   "Jackdaws love my big sphinx of quartz. "       \
+		   "Pack my box with five dozen liquor jugs. "     \
+		   "How razorback-jumping frogs can level six piqued gymnasts!"
+#define FIXED_LEN  (strlen(FIXED_STR))
+
+#define KEY_STR "This key has exactly _32_ bytes!"
+#define KEY_LEN (strlen(KEY_STR))
+
+static void test_unsupported(const void *data)
+{
+	struct l_cipher *cipher;
+
+	cipher =3D l_cipher_new(42, KEY_STR, KEY_LEN);
+	assert(!cipher);
+}
+
+static void test_aes(const void *data)
+{
+	struct l_cipher *cipher;
+	char buf[256] =3D {};
+	int r;
+
+	cipher =3D l_cipher_new(L_CIPHER_AES, KEY_STR, KEY_LEN);
+	assert(cipher);
+
+	memcpy(buf, FIXED_STR, FIXED_LEN);
+
+	l_cipher_encrypt(cipher, buf, buf, 256);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(r);
+
+	l_cipher_decrypt(cipher, buf, buf, 256);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(!r);
+
+	l_cipher_free(cipher);
+}
+
+static void test_arc4(const void *data)
+{
+	struct l_cipher *cipher;
+	char buf[256] =3D {};
+	int r;
+
+	cipher =3D l_cipher_new(L_CIPHER_ARC4, KEY_STR, KEY_LEN);
+	assert(cipher);
+
+	memcpy(buf, FIXED_STR, FIXED_LEN);
+
+	l_cipher_encrypt(cipher, buf, buf, 256);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(r);
+
+	l_cipher_decrypt(cipher, buf, buf, 256);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(!r);
+
+	l_cipher_free(cipher);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("unsupported", test_unsupported, NULL);
+
+	l_test_add("aes", test_aes, NULL);
+
+	l_test_add("arc4", test_arc4, NULL);
+
+	return l_test_run();
+}
-- =

2.0.5


--===============2359715240258728671==--

