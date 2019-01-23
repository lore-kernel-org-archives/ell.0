Content-Type: multipart/mixed; boundary="===============8722125033684491622=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 2/2] unit: add unit/test-time.c
Date: Wed, 23 Jan 2019 14:11:59 -0800
Message-ID: <20190123221159.24449-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190123221159.24449-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8722125033684491622==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A few basic sanity checks for time module.
---
 .gitignore       |  1 +
 Makefile.am      |  5 +++-
 unit/test-time.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 65 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-time.c

diff --git a/.gitignore b/.gitignore
index 75ab7b2..520c509 100644
--- a/.gitignore
+++ b/.gitignore
@@ -58,6 +58,7 @@ unit/test-dhcp
 unit/test-dir-watch
 unit/test-ecc
 unit/test-ecdh
+unit/test-time
 unit/cert-*.pem
 unit/cert-*.csr
 unit/cert-*.srl
diff --git a/Makefile.am b/Makefile.am
index 1c089ec..5bc13bd 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -170,7 +170,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-dhcp \
 			unit/test-dir-watch \
 			unit/test-ecc \
-			unit/test-ecdh
+			unit/test-ecdh \
+			unit/test-time
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
@@ -294,6 +295,8 @@ unit_test_ecc_LDADD =3D ell/libell-private.la
 unit_test_ecdh_LDADD =3D ell/libell-private.la
 unit_test_ecdh_LDFLAGS =3D -Wl,-wrap,l_getrandom
 =

+unit_test_time_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-time.c b/unit/test-time.c
new file mode 100644
index 0000000..36d17bc
--- /dev/null
+++ b/unit/test-time.c
@@ -0,0 +1,60 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019 Intel Corporation. All rights reserved.
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
+static void test_before_after_diff(const void *data)
+{
+	uint64_t small =3D 10;
+	uint64_t big =3D 100;
+
+	assert(l_time_after(big, small));
+	assert(l_time_before(small, big));
+	assert(l_time_diff(small, big) =3D=3D l_time_diff(big, small));
+}
+
+static void test_offset(const void *data)
+{
+	uint64_t max =3D ULONG_MAX;
+	uint64_t max_minus =3D ULONG_MAX - 1000;
+
+	assert(l_time_offset(max, 1) =3D=3D ULONG_MAX);
+	assert(l_time_offset(max, max) =3D=3D ULONG_MAX);
+	assert(l_time_offset(max_minus, 1000) =3D=3D max);
+	assert(l_time_offset(max_minus, 1001) =3D=3D ULONG_MAX);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("Test before/after/diff", test_before_after_diff, NULL);
+	l_test_add("Test offset", test_offset, NULL);
+
+	return l_test_run();
+}
-- =

2.17.1


--===============8722125033684491622==--

