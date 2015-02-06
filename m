Content-Type: multipart/mixed; boundary="===============1654004342281619303=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC 2/2] unit: Add a unit test for the random infrastructure
Date: Fri, 06 Feb 2015 13:37:15 +0200
Message-ID: <1423222635-6053-3-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423222635-6053-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1654004342281619303==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It will run a test against supported rng types. The content "randomly"
generated will be checked to validate the test.
---
 Makefile.am        |  5 ++-
 unit/test-random.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 95 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-random.c

diff --git a/Makefile.am b/Makefile.am
index 206fc10..9aa89f0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -107,7 +107,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-gvariant-util \
 			unit/test-gvariant-message \
 			unit/test-siphash \
-			unit/test-hwdb
+			unit/test-hwdb \
+			unit/test-random
 =

 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(unit_tests)
@@ -157,6 +158,8 @@ unit_test_siphash_LDADD =3D ell/libell-private.la
 =

 unit_test_hwdb_LDADD =3D ell/libell-private.la
 =

+unit_test_random_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-random.c b/unit/test-random.c
new file mode 100644
index 0000000..7975de6
--- /dev/null
+++ b/unit/test-random.c
@@ -0,0 +1,91 @@
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
+#define SEED "\x0\x1\x2\x3\x4\x5\x6\x7"
+#define SEED_SIZE 1
+
+static void test_unsupported(const void *data)
+{
+	struct l_random *random;
+
+	random =3D l_random_new(42);
+	assert(!random);
+}
+
+static void test_stdrng(const void *data)
+{
+	unsigned char rand[64] =3D {};
+	unsigned char test[64] =3D {};
+	struct l_random *random;
+	int r;
+
+	random =3D l_random_new(L_RANDOM_STDRNG);
+	assert(random);
+
+	l_random_seed(random, SEED, SEED_SIZE);
+
+	l_random_generate(random, rand, 64);
+
+	r =3D memcmp(rand, test, 64);
+	assert(r);
+
+	l_random_free(random);
+}
+
+static void test_urandom(const void *data)
+{
+	unsigned char rand[64] =3D {};
+	unsigned char test[64] =3D {};
+	struct l_random *random;
+	int r;
+
+	random =3D l_random_new(L_RANDOM_URANDOM);
+	assert(random);
+
+	l_random_generate(random, rand, 64);
+
+	r =3D memcmp(rand, test, 64);
+	assert(r);
+
+	l_random_free(random);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("unsupported", test_unsupported, NULL);
+
+	l_test_add("stdrng", test_stdrng, NULL);
+
+	l_test_add("urandom", test_urandom, NULL);
+
+	return l_test_run();
+}
-- =

2.0.5


--===============1654004342281619303==--

