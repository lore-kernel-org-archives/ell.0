Content-Type: multipart/mixed; boundary="===============5104255868063531937=="
MIME-Version: 1.0
From: John <johnz@posteo.net>
Subject: [PATCH] dhcp.c: include net/ethernet.h before linux headers
Date: Thu, 17 May 2018 13:09:06 +0200
Message-ID: <20180517110906.24911-1-johnz@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5104255868063531937==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

to fix compilation on systems with MUSL libc since MUSL a few argp
structs exists in MUSL libc headers and kernel headers. Including libc
headers before lets libc_compat.h take care of that.
---
 ell/dhcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index ad95850..6c90370 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -25,9 +25,9 @@
 #endif
 =

 #include <netinet/ip.h>
+#include <net/ethernet.h>
 #include <linux/types.h>
 #include <linux/if_arp.h>
-#include <net/ethernet.h>
 #include <errno.h>
 #include <time.h>
 =

-- =

2.17.0


--===============5104255868063531937==--

