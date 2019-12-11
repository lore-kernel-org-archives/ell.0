Content-Type: multipart/mixed; boundary="===============9202334467205799902=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 3/5] unit: Add tests for net
Date: Wed, 11 Dec 2019 15:21:19 -0800
Message-ID: <20191211232121.23129-3-tim.a.kourt@linux.intel.com>
In-Reply-To: <20191211232121.23129-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9202334467205799902==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am     |  5 ++++-
 unit/test-net.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 70 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-net.c

diff --git a/Makefile.am b/Makefile.am
index ead9fd5..3ead678 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -178,7 +178,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-ecc \
 			unit/test-ecdh \
 			unit/test-time \
-			unit/test-path
+			unit/test-path \
+			unit/test-net
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
@@ -304,6 +305,8 @@ unit_test_time_LDADD =3D ell/libell-private.la
 =

 unit_test_path_LDADD =3D ell/libell-private.la
 =

+unit_test_net_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-net.c b/unit/test-net.c
new file mode 100644
index 0000000..2f7bf48
--- /dev/null
+++ b/unit/test-net.c
@@ -0,0 +1,66 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019  Intel Corporation. All rights reserved.
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
+static void test_net_hostname_is_localhost(const void *data)
+{
+	assert(l_net_hostname_is_localhost("localhost"));
+	assert(l_net_hostname_is_localhost("localhost."));
+	assert(l_net_hostname_is_localhost("localhost.localdomain"));
+	assert(l_net_hostname_is_localhost("localhost.localdomain."));
+	assert(l_net_hostname_is_localhost("other.localhost"));
+	assert(l_net_hostname_is_localhost("other.localhost."));
+	assert(l_net_hostname_is_localhost("other.localhost.localdomain"));
+	assert(l_net_hostname_is_localhost("other.localhost.localdomain."));
+
+	assert(l_net_hostname_is_localhost("LOCALHOST"));
+
+	assert(!l_net_hostname_is_localhost("notsolocalhost"));
+	assert(!l_net_hostname_is_localhost("localhost.com"));
+	assert(!l_net_hostname_is_localhost(""));
+}
+
+static void test_net_hostname_is_root(const void *data)
+{
+	assert(l_net_hostname_is_root(""));
+	assert(l_net_hostname_is_root("."));
+	assert(!l_net_hostname_is_root("notsoroot"));
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("net/hostname_is_localhost", test_net_hostname_is_localhost,
+									NULL);
+	l_test_add("net/hostname_is_root", test_net_hostname_is_root,
+									NULL);
+
+	return l_test_run();
+}
-- =

2.13.6

--===============9202334467205799902==--

