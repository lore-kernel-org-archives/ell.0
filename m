Content-Type: multipart/mixed; boundary="===============2384615681829799540=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] build: Fix up sanitizer library detection
Date: Fri, 27 Jul 2018 14:27:50 -0700
Message-ID: <20180727212752.20497-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2384615681829799540==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The exported symbol names in libasan/liblsan/libubsan have changed over
time, which broke library detection. We really only care if the
sanitizer libraries are present, but the configure scripts require a
symbol name.  '_init' is present in new and old sanitizer libraries.
---
 configure.ac | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/configure.ac b/configure.ac
index 0e7cee2..cec3499 100644
--- a/configure.ac
+++ b/configure.ac
@@ -56,13 +56,13 @@ AC_ARG_ENABLE(pie, AC_HELP_STRING([--enable-pie],
 ])
 =

 save_LIBS=3D$LIBS
-AC_CHECK_LIB(asan, __sanitizer_cov_init)
+AC_CHECK_LIB(asan, _init)
 LIBS=3D$save_LIBS
 =

 AC_ARG_ENABLE(asan, AC_HELP_STRING([--enable-asan],
 			[enable linking with address sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
-				test "${ac_cv_lib_asan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_lib_asan__init}" =3D "yes" &&
 				test "${ac_cv_prog_cc_asan}" =3D "yes"); then
 		CFLAGS=3D"$CFLAGS -fsanitize=3Daddress";
 		LDFLAGS=3D"$LDFLAGS -fsanitize=3Daddress"
@@ -70,13 +70,13 @@ AC_ARG_ENABLE(asan, AC_HELP_STRING([--enable-asan],
 ])
 =

 save_LIBS=3D$LIBS
-AC_CHECK_LIB(lsan, __sanitizer_cov_init)
+AC_CHECK_LIB(lsan, _init)
 LIBS=3D$save_LIBS
 =

 AC_ARG_ENABLE(lsan, AC_HELP_STRING([--enable-lsan],
 			[enable linking with leak sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
-				test "${ac_cv_lib_lsan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_lib_lsan__init}" =3D "yes" &&
 				test "${ac_cv_prog_cc_lsan}" =3D "yes"); then
 		CFLAGS=3D"$CFLAGS -fsanitize=3Dleak";
 		LDFLAGS=3D"$LDFLAGS -fsanitize=3Dleak"
@@ -84,13 +84,13 @@ AC_ARG_ENABLE(lsan, AC_HELP_STRING([--enable-lsan],
 ])
 =

 save_LIBS=3D$LIBS
-AC_CHECK_LIB(ubsan, __sanitizer_cov_init)
+AC_CHECK_LIB(ubsan, _init)
 LIBS=3D$save_LIBS
 =

 AC_ARG_ENABLE(ubsan, AC_HELP_STRING([--enable-ubsan],
 			[enable linking with undefined behavior sanitizer]), [
 	if (test "${enableval}" =3D "yes" &&
-				test "${ac_cv_lib_ubsan___sanitizer_cov_init}" =3D "yes" &&
+				test "${ac_cv_lib_ubsan__init}" =3D "yes" &&
 				test "${ac_cv_prog_cc_ubsan}" =3D "yes"); then
 		CFLAGS=3D"$CFLAGS -fsanitize=3Dundefined";
 		LDFLAGS=3D"$LDFLAGS -fsanitize=3Dundefined"
-- =

2.18.0


--===============2384615681829799540==--

