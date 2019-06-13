Content-Type: multipart/mixed; boundary="===============5851200314871393640=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] acinclude: Correct CFLAGS variable name typo.
Date: Thu, 13 Jun 2019 09:52:23 -0700
Message-ID: <20190613165223.11171-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5851200314871393640==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The "-Wvariadic-macros" compiler command line option was appended to
the "CFALGS" variables instead of "CFLAGS", which prevented it from
being used when building ELL.  Change "CFALGS" to "CFLAGS".
---
 acinclude.m4 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/acinclude.m4 b/acinclude.m4
index cad86ec..1bd01d0 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -60,7 +60,7 @@ AC_DEFUN([COMPILER_FLAGS], [
 		CFLAGS+=3D" -Wredundant-decls"
 		CFLAGS+=3D" -Wswitch-enum"
 		CFLAGS+=3D" -Wtype-limits"
-		CFALGS+=3D" -Wvariadic-macros"
+		CFLAGS+=3D" -Wvariadic-macros"
 		CFLAGS+=3D" -Wformat -Wformat-security"
 		if ( $CC -v 2>/dev/null | grep "gcc version" ); then
 			CFLAGS+=3D" -Wcast-align"
-- =

2.20.1


--===============5851200314871393640==--

