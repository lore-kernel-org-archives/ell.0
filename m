Content-Type: multipart/mixed; boundary="===============4779648386647167007=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] unit: Added a minimal C++ build test.
Date: Wed, 23 Jan 2019 11:06:10 -0800
Message-ID: <20190123190610.3787-3-ossama.othman@intel.com>
In-Reply-To: <20190123190610.3787-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4779648386647167007==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore              |  1 +
 Makefile.am             |  6 ++++++
 configure.ac            |  3 +++
 unit/test-cxx-build.cpp | 42 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 52 insertions(+)
 create mode 100644 unit/test-cxx-build.cpp

diff --git a/.gitignore b/.gitignore
index 75ab7b2..f10c973 100644
--- a/.gitignore
+++ b/.gitignore
@@ -58,6 +58,7 @@ unit/test-dhcp
 unit/test-dir-watch
 unit/test-ecc
 unit/test-ecdh
+unit/test-cxx-build
 unit/cert-*.pem
 unit/cert-*.csr
 unit/cert-*.srl
diff --git a/Makefile.am b/Makefile.am
index 3eecbe0..e7da974 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -292,6 +292,12 @@ unit_test_ecc_LDADD =3D ell/libell-private.la
 unit_test_ecdh_LDADD =3D ell/libell-private.la
 unit_test_ecdh_LDFLAGS =3D -Wl,-wrap,l_getrandom
 =

+if HAVE_CXX
+unit_tests +=3D unit/test-cxx-build
+unit_test_cxx_build_SOURCES =3D unit/test-cxx-build.cpp
+unit_test_cxx_build_LDADD =3D ell/libell-private.la
+endif
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/configure.ac b/configure.ac
index 1eeebec..f2d1c4f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -125,6 +125,9 @@ fi
 AM_CONDITIONAL(GLIB, test "${enable_glib}" =3D "yes")
 =

 if (test "$USE_MAINTAINER_MODE" =3D "yes"); then
+	AC_PROG_CXX
+	AM_CONDITIONAL([HAVE_CXX], [test -n "$CXX"])
+
 	AC_CHECK_PROG(have_openssl, [openssl], [yes], [no])
 	AC_CHECK_PROG(have_xxd, [xxd], [yes], [no])
 fi
diff --git a/unit/test-cxx-build.cpp b/unit/test-cxx-build.cpp
new file mode 100644
index 0000000..2233815
--- /dev/null
+++ b/unit/test-cxx-build.cpp
@@ -0,0 +1,42 @@
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
+#include <ell/ell.h>
+
+int main()
+{
+	if (!l_main_init())
+		return -1;
+
+	l_log_set_stderr();
+	l_debug_enable("*");
+
+	l_debug("hello");
+
+	l_main_exit();
+
+	return 0;
+}
-- =

2.17.1


--===============4779648386647167007==--

