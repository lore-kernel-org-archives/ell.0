Content-Type: multipart/mixed; boundary="===============5707912136225625149=="
MIME-Version: 1.0
From: Peter Seiderer <ps.report@gmx.net>
Subject: [PATCH v1] ell/rtnl: fix compile with older toolchains
Date: Thu, 09 Apr 2020 22:38:18 +0200
Message-ID: <20200409203818.19519-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5707912136225625149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Older toolchains need to include sys/types.h and sys/socket.h before
linux/if.h, RTA_PREF was introduces with linux-4.1.x.

Fixes:

  In file included from ell/rtnl.c:28:0:
  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:185:1=
9: error: field 'ifru_addr' has incomplete type
  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:186:1=
9: error: field 'ifru_dstaddr' has incomplete type
  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:187:1=
9: error: field 'ifru_broadaddr' has incomplete type
  .../host/arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:188:1=
9: error: field 'ifru_netmask' has incomplete type
  .../arm-buildroot-linux-gnueabi/sysroot/usr/include/linux/if.h:189:20: er=
ror: field 'ifru_hwaddr' has incomplete type
  ell/rtnl.c: In function 'l_rtnl_route_extract':
  ell/rtnl.c:120:8: error: 'RTA_PREF' undeclared (first use in this functio=
n)
---
 configure.ac | 2 ++
 ell/rtnl.c   | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 0351f89..3be35a4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -113,6 +113,8 @@ AC_CHECK_LIB(dl, dlopen, dummy=3Dyes,
 =

 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
 =

+AC_CHECK_DECLS([RTA_PREF], [], [], [[#include <linux/rtnetlink.h>]])
+
 AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
 				[enable ell/glib main loop example]),
 					[enable_glib=3D${enableval}])
diff --git a/ell/rtnl.c b/ell/rtnl.c
index dc83937..3493d34 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -25,8 +25,9 @@
 #endif
 =

 #define _GNU_SOURCE
-#include <linux/if.h>
+#include <sys/types.h>
 #include <sys/socket.h>
+#include <linux/if.h>
 #include <arpa/inet.h>
 =

 #include "util.h"
@@ -35,6 +36,10 @@
 #include "rtnl.h"
 #include "private.h"
 =

+#if defined HAVE_DECL_RTA_PREF && !HAVE_DECL_RTA_PREF
+#define RTA_PREF 20
+#endif
+
 static size_t rta_add_u8(void *rta_buf, unsigned short type, uint8_t value)
 {
 	struct rtattr *rta =3D rta_buf;
-- =

2.26.0


--===============5707912136225625149==--

