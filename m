Content-Type: multipart/mixed; boundary="===============0860805298181172947=="
MIME-Version: 1.0
From: Ross Burton <ross@burtonini.com>
Subject: [PATCH 2/2] build: Add -ldl to LIBS as needed.
Date: Tue, 15 Sep 2020 19:00:41 +0100
Message-ID: <20200915180041.2361066-2-ross@burtonini.com>
In-Reply-To: <20200915180041.2361066-1-ross@burtonini.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0860805298181172947==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Ossama Othman <ossama.othman@intel.com>

ELL requires the libdl library but does not add it to the LIBS build
variable.  Add it to LIBS only if it is required to resolve dlopen()
and related functions at link-time so that the libdl dependency will
be embedded into the libell shared library binary:

Pre-change:
$ ldd ell/.libs/libell.so.0.0.2
        linux-vdso.so.1 (0x00007ffec6fd2000)
        libc.so.6 =3D> /lib/x86_64-linux-gnu/libc.so.6 (0x00007fb7db3bf000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fb7db9f5000)

Post-change:
$ ldd ell/.libs/libell.so.0.0.2
        linux-vdso.so.1 (0x00007fffb95d1000)
        libdl.so.2 =3D> /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f02bef2f00=
0)
        libc.so.6 =3D> /lib/x86_64-linux-gnu/libc.so.6 (0x00007f02beb3e000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f02bf378000)

This also obviates the need to explicitly add libdl to LDFLAGS for the
ELL plugin unit test.

Lastly, only add "-ldl" to the private library flags in ELL's
pkg-config file (ell.pc) since it is an ELL dependency that is only
exposed to the user if the platform in question doesn't support
inter-library dependencies, or when linking against the static ELL
library, e.g.:

$ pkg-config --libs ell
-L/usr/local/lib -lell

$ pkg-config --static --libs ell
-L/usr/local/lib -lell -ldl
---
 Makefile.am   | 2 +-
 configure.ac  | 2 +-
 ell/ell.pc.in | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 395edc3..6c3b39f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -247,7 +247,7 @@ unit_test_io_LDADD =3D ell/libell-private.la
 unit_test_ringbuf_LDADD =3D ell/libell-private.la
 =

 unit_test_plugin_LDFLAGS =3D -Wl,-export-dynamic
-unit_test_plugin_LDADD =3D ell/libell-private.la -ldl
+unit_test_plugin_LDADD =3D ell/libell-private.la
 =

 unit_test_checksum_LDADD =3D ell/libell-private.la
 =

diff --git a/configure.ac b/configure.ac
index 490784f..a9d62ed 100644
--- a/configure.ac
+++ b/configure.ac
@@ -108,7 +108,7 @@ AC_CHECK_FUNC(timerfd_create, dummy=3Dyes,
 AC_CHECK_FUNC(epoll_create, dummy=3Dyes,
 			AC_MSG_ERROR(epoll support is required))
 =

-AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
+AC_SEARCH_LIBS(dlopen, dl, dummy=3Dyes,
 			AC_MSG_ERROR(dynamic linking loader is required))
 =

 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
diff --git a/ell/ell.pc.in b/ell/ell.pc.in
index 4fc933b..d9aae8d 100644
--- a/ell/ell.pc.in
+++ b/ell/ell.pc.in
@@ -6,5 +6,6 @@ includedir=3D@includedir@
 Name: ELL
 Description: Embedded Linux library
 Version: @VERSION@
-Libs: -L${libdir} -lell -ldl
+Libs: -L${libdir} -lell
+Libs.private: @LIBS@
 Cflags: -I${includedir}
-- =

2.28.0

--===============0860805298181172947==--

