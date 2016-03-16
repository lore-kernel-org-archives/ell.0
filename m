Content-Type: multipart/mixed; boundary="===============1804933708912206922=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] build: Add sanitizer options
Date: Wed, 16 Mar 2016 11:47:50 -0700
Message-ID: <1458154072-14292-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1804933708912206922==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Build using Address Sanitizer (asan), Leak Sanitizer (lsan), or
Undefined Behavior Sanitizer (ubsan) by using one of these options for
the configure script:

  --enable-asan
  --enable-lsan
  --enable-ubsan

For each of these to work, the compiler must support the requested
sanitizer and the requisite libraries must be installed (libasan,
liblsan, libubsan).
---
 acinclude.m4 | 36 ++++++++++++++++++++++++++++++++++++
 configure.ac | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+)

diff --git a/acinclude.m4 b/acinclude.m4
index 0ba4287..8aab4ee 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -10,6 +10,42 @@ AC_DEFUN([AC_PROG_CC_PIE], [
 	])
 ])
 =

+AC_DEFUN([AC_PROG_CC_ASAN], [
+	AC_CACHE_CHECK([whether ${CC-cc} accepts -fsanitize=3Daddress], ac_cv_pro=
g_cc_asan, [
+		echo 'void f(){}' > conftest.c
+		if test -z "`${CC-cc} -fsanitize=3Daddress -c conftest.c 2>&1`"; then
+			ac_cv_prog_cc_asan=3Dyes
+		else
+			ac_cv_prog_cc_asan=3Dno
+		fi
+		rm -rf conftest*
+	])
+])
+
+AC_DEFUN([AC_PROG_CC_LSAN], [
+	AC_CACHE_CHECK([whether ${CC-cc} accepts -fsanitize=3Dleak], ac_cv_prog_c=
c_lsan, [
+		echo 'void f(){}' > conftest.c
+		if test -z "`${CC-cc} -fsanitize=3Dleak -c conftest.c 2>&1`"; then
+			ac_cv_prog_cc_lsan=3Dyes
+		else
+			ac_cv_prog_cc_lsan=3Dno
+		fi
+		rm -rf conftest*
+	])
+])
+
+AC_DEFUN([AC_PROG_CC_UBSAN], [
+	AC_CACHE_CHECK([whether ${CC-cc} accepts -fsanitize=3Dundefined], ac_cv_p=
rog_cc_ubsan, [
+		echo 'void f(){}' > conftest.c
+		if test -z "`${CC-cc} -fsanitize=3Dundefined -c conftest.c 2>&1`"; then
+			ac_cv_prog_cc_ubsan=3Dyes
+		else
+			ac_cv_prog_cc_ubsan=3Dno
+		fi
+		rm -rf conftest*
+	])
+])
+
 AC_DEFUN([COMPILER_FLAGS], [
 	if (test "${CFLAGS}" =3D ""); then
 		CFLAGS=3D"-Wall -O2 -fsigned-char"
diff --git a/configure.ac b/configure.ac
index 39755fe..e4ca5b2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -20,6 +20,9 @@ AC_LANG_C
 =

 AC_PROG_CC
 AC_PROG_CC_PIE
+AC_PROG_CC_ASAN
+AC_PROG_CC_LSAN
+AC_PROG_CC_UBSAN
 AC_PROG_INSTALL
 =

 AC_C_CHAR_UNSIGNED
@@ -54,6 +57,48 @@ AC_ARG_ENABLE(pie, AC_HELP_STRING([--enable-pie],
 	fi
 ])
 =

+save_LIBS=3D$LIBS
+AC_CHECK_LIB(asan, __sanitizer_cov_init)
+LIBS=3D$save_LIBS
+
+AC_ARG_ENABLE(asan, AC_HELP_STRING([--enable-asan],
+			[enable linking with address sanitizer]), [
+	if (test "${enableval}" =3D "yes" &&
+				test "${ac_cv_lib_asan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_prog_cc_asan}" =3D "yes"); then
+		CFLAGS=3D"$CFLAGS -fsanitize=3Daddress";
+		LDFLAGS=3D"$LDFLAGS -fsanitize=3Daddress"
+	fi
+])
+
+save_LIBS=3D$LIBS
+AC_CHECK_LIB(lsan, __sanitizer_cov_init)
+LIBS=3D$save_LIBS
+
+AC_ARG_ENABLE(lsan, AC_HELP_STRING([--enable-lsan],
+			[enable linking with leak sanitizer]), [
+	if (test "${enableval}" =3D "yes" &&
+				test "${ac_cv_lib_lsan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_prog_cc_lsan}" =3D "yes"); then
+		CFLAGS=3D"$CFLAGS -fsanitize=3Dleak";
+		LDFLAGS=3D"$LDFLAGS -fsanitize=3Dleak"
+	fi
+])
+
+save_LIBS=3D$LIBS
+AC_CHECK_LIB(ubsan, __sanitizer_cov_init)
+LIBS=3D$save_LIBS
+
+AC_ARG_ENABLE(ubsan, AC_HELP_STRING([--enable-ubsan],
+			[enable linking with undefined behavior sanitizer]), [
+	if (test "${enableval}" =3D "yes" &&
+				test "${ac_cv_lib_ubsan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_prog_cc_ubsan}" =3D "yes"); then
+		CFLAGS=3D"$CFLAGS -fsanitize=3Dundefined";
+		LDFLAGS=3D"$LDFLAGS -fsanitize=3Dundefined"
+	fi
+])
+
 AC_CHECK_FUNC(signalfd, dummy=3Dyes,
 			AC_MSG_ERROR(signalfd support is required))
 =

-- =

2.7.3


--===============1804933708912206922==--

