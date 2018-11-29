Content-Type: multipart/mixed; boundary="===============3383925849242471197=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] build: Add -ldl to LIBS as needed.
Date: Thu, 29 Nov 2018 13:46:10 -0800
Message-ID: <20181129214610.30694-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3383925849242471197==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

ELL requires the libdl library but does not add it to the LIBS build
variable.  Add it to LIBS, as needed, so that the libdl dependency will
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

Lastly, only add "-ldl" to the library flags in ELL's pkg-config file
(ell.pc) when necessary.
---
 Makefile.am   | 2 +-
 configure.ac  | 2 +-
 ell/ell.pc.in | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index d115360..bd276eb 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -215,7 +215,7 @@ unit_test_io_LDADD =3D ell/libell-private.la
 unit_test_ringbuf_LDADD =3D ell/libell-private.la
 =

 unit_test_plugin_LDFLAGS =3D -Wl,-export-dynamic
-unit_test_plugin_LDADD =3D ell/libell-private.la -ldl
+unit_test_plugin_LDADD =3D ell/libell-private.la
 =

 unit_test_checksum_LDADD =3D ell/libell-private.la
 =

diff --git a/configure.ac b/configure.ac
index 5a962ac..487bff6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -106,7 +106,7 @@ AC_CHECK_FUNC(timerfd_create, dummy=3Dyes,
 AC_CHECK_FUNC(epoll_create, dummy=3Dyes,
 			AC_MSG_ERROR(epoll support is required))
 =

-AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
+AC_SEARCH_LIBS(dlopen, dl, dummy=3Dyes,
 			AC_MSG_ERROR(dynamic linking loader is required))
 =

 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
diff --git a/ell/ell.pc.in b/ell/ell.pc.in
index 4fc933b..65ea88e 100644
--- a/ell/ell.pc.in
+++ b/ell/ell.pc.in
@@ -6,5 +6,5 @@ includedir=3D@includedir@
 Name: ELL
 Description: Embedded Linux library
 Version: @VERSION@
-Libs: -L${libdir} -lell -ldl
+Libs: -L${libdir} -lell @LIBS@
 Cflags: -I${includedir}
-- =

2.17.1


--===============3383925849242471197==--

