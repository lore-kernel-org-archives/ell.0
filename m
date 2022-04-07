Content-Type: multipart/mixed; boundary="===============0884619306659696866=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] configure: Update to support Autoconf >= 2.69
Date: Wed, 06 Apr 2022 21:00:07 -0700
Message-ID: <20220407040007.99836-1-ossama.othman@intel.com>

--===============0884619306659696866==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Bootstrapping ELL against Autoconf 2.71 triggers warnings about use of
the deprecated Autoconf macros.  Replace use of the deprecated
AC_HELP_STRING and AC_LANG_C macros with AS_HELP_STRING and
AC_LANG([C]), respectively.

Bump the Autoconf prerequisite, accordingly, to support the updated
macros, from 2.60 to 2.69.  Only require Autoconf 2.69 as a
prerequisite since many Linux distributions do not yet ship with
Autoconf 2.71.

This also addresses a `configure' script generation error on Fedora 36.
---
 configure.ac | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index 9350e14..3bf220b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,5 +1,5 @@
-AC_PREREQ(2.60)
-AC_INIT(ell, 0.49)
+AC_PREREQ([2.69])
+AC_INIT([ell],[0.49])
 =

 AC_CONFIG_HEADERS(config.h)
 AC_CONFIG_AUX_DIR(build-aux)
@@ -16,7 +16,7 @@ AC_PREFIX_DEFAULT(/usr/local)
 =

 COMPILER_FLAGS
 =

-AC_LANG_C
+AC_LANG([C])
 =

 AC_PROG_CC
 AC_PROG_CC_PIE
@@ -31,14 +31,14 @@ AC_C_BIGENDIAN(little_endian=3Dno, little_endian=3Dyes,=
 little_endian=3Dno)
 LT_PREREQ(2.2)
 LT_INIT([disable-static])
 =

-AC_ARG_ENABLE(optimization, AC_HELP_STRING([--disable-optimization],
+AC_ARG_ENABLE(optimization, AS_HELP_STRING([--disable-optimization],
 			[disable code optimization through compiler]), [
 	if (test "${enableval}" =3D "no"); then
 		CFLAGS=3D"$CFLAGS -U_FORTIFY_SOURCE -O0"
 	fi
 ])
 =

-AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug],
+AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug],
 			[enable compiling with debugging information]), [
 	if (test "${enableval}" =3D "yes" &&
 				test "${ac_cv_prog_cc_g}" =3D "yes"); then
@@ -46,7 +46,7 @@ AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug],
 	fi
 ])
 =

-AC_ARG_ENABLE(pie, AC_HELP_STRING([--enable-pie],
+AC_ARG_ENABLE(pie, AS_HELP_STRING([--enable-pie],
 			[enable position independent executables flag]), [
 	if (test "${enableval}" =3D "yes" &&
 				test "${ac_cv_prog_cc_pie}" =3D "yes"); then
@@ -59,7 +59,7 @@ save_LIBS=3D$LIBS
 AC_CHECK_LIB(asan, _init)
 LIBS=3D$save_LIBS
 =

-AC_ARG_ENABLE(asan, AC_HELP_STRING([--enable-asan],
+AC_ARG_ENABLE(asan, AS_HELP_STRING([--enable-asan],
 			[enable linking with address sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
 				test "${ac_cv_lib_asan__init}" =3D "yes" &&
@@ -73,7 +73,7 @@ save_LIBS=3D$LIBS
 AC_CHECK_LIB(lsan, _init)
 LIBS=3D$save_LIBS
 =

-AC_ARG_ENABLE(lsan, AC_HELP_STRING([--enable-lsan],
+AC_ARG_ENABLE(lsan, AS_HELP_STRING([--enable-lsan],
 			[enable linking with leak sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
 				test "${ac_cv_lib_lsan__init}" =3D "yes" &&
@@ -87,7 +87,7 @@ save_LIBS=3D$LIBS
 AC_CHECK_LIB(ubsan, _init)
 LIBS=3D$save_LIBS
 =

-AC_ARG_ENABLE(ubsan, AC_HELP_STRING([--enable-ubsan],
+AC_ARG_ENABLE(ubsan, AS_HELP_STRING([--enable-ubsan],
 			[enable linking with undefined behavior sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
 				test "${ac_cv_lib_ubsan__init}" =3D "yes" &&
@@ -111,7 +111,7 @@ AC_CHECK_FUNC(epoll_create, dummy=3Dyes,
 =

 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
 =

-AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
+AC_ARG_ENABLE(glib, AS_HELP_STRING([--enable-glib],
 				[enable ell/glib main loop example]),
 					[enable_glib=3D${enableval}])
 =

-- =

2.32.0

--===============0884619306659696866==--

