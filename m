Content-Type: multipart/mixed; boundary="===============7649110529104394960=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] Re-enable -Wmissing-field-initializers warning.
Date: Tue, 23 Oct 2018 12:57:40 -0700
Message-ID: <20181023195740.30204-3-ossama.othman@intel.com>
In-Reply-To: <20181023195740.30204-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7649110529104394960==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The L_PLUGIN_DEFINE() macro was the sole part of ELL that triggered
the missing field initializer warning.  Now that it no longer triggers
that warning drop the -Wno-missing-field-initializers option from the
maintainer mode CFLAGS so that exposure of such problems to the user
can be prevented in the future.
---
 acinclude.m4 | 1 -
 1 file changed, 1 deletion(-)

diff --git a/acinclude.m4 b/acinclude.m4
index dd07ec2..f68ef6f 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -54,7 +54,6 @@ AC_DEFUN([COMPILER_FLAGS], [
 	if (test "$USE_MAINTAINER_MODE" =3D "yes"); then
 		CFLAGS+=3D" -Werror -Wextra"
 		CFLAGS+=3D" -Wno-unused-parameter"
-		CFLAGS+=3D" -Wno-missing-field-initializers"
 		CFLAGS+=3D" -Wdeclaration-after-statement"
 		CFLAGS+=3D" -Wmissing-declarations"
 		CFLAGS+=3D" -Wredundant-decls"
-- =

2.17.1


--===============7649110529104394960==--

