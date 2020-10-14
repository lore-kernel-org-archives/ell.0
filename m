Content-Type: multipart/mixed; boundary="===============3296622136554980970=="
MIME-Version: 1.0
From: Ross Burton <ross@burtonini.com>
Subject: [PATCH 2/2] build: don't check for or use libdl
Date: Wed, 14 Oct 2020 11:46:43 +0100
Message-ID: <20201014104643.3993077-2-ross@burtonini.com>
In-Reply-To: <20201014104643.3993077-1-ross@burtonini.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3296622136554980970==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Ross Burton <ross.burton@arm.com>

Commit e129cb4 removed the plugin interface entirely, so there's no need
to look for dlopen() or pass -ldl when building.
---
 configure.ac  | 3 ---
 ell/ell.pc.in | 2 +-
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 490784f..b8347e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -108,9 +108,6 @@ AC_CHECK_FUNC(timerfd_create, dummy=3Dyes,
 AC_CHECK_FUNC(epoll_create, dummy=3Dyes,
 			AC_MSG_ERROR(epoll support is required))
 =

-AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
-			AC_MSG_ERROR(dynamic linking loader is required))
-
 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
 =

 AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
diff --git a/ell/ell.pc.in b/ell/ell.pc.in
index 4fc933b..414ea75 100644
--- a/ell/ell.pc.in
+++ b/ell/ell.pc.in
@@ -6,5 +6,5 @@ includedir=3D@includedir@
 Name: ELL
 Description: Embedded Linux library
 Version: @VERSION@
-Libs: -L${libdir} -lell -ldl
+Libs: -L${libdir} -lell
 Cflags: -I${includedir}
-- =

2.28.0

--===============3296622136554980970==--

