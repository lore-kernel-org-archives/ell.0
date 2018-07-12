Content-Type: multipart/mixed; boundary="===============7194473529542275415=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH] dhcp: include if_arp.h from libc instead of linux headers
Date: Thu, 12 Jul 2018 10:30:29 +0200
Message-ID: <81df296b-695f-2c6e-2d8b-653f6b1684e6@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7194473529542275415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Compilation with musl libc fails due to redefinition of 'struct
arp{req,req_old,hdr}' in linux/if_arp.h, since it is already defined and
included in net/if_arp.h (through net/ethernet.h -> net/if_ether.h).

The only symbols used from if_arp.h is ARPHRD_ETHER, so it should be
safe to avoid the compile error by including the if_arp.h header from
the c-library instead.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@geanix.com>
---
  ell/dhcp.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 6c90370..0d99f74 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -27,7 +27,7 @@
  #include <netinet/ip.h>
  #include <net/ethernet.h>
  #include <linux/types.h>
-#include <linux/if_arp.h>
+#include <net/if_arp.h>
  #include <errno.h>
  #include <time.h>
  -- 2.18.0


--===============7194473529542275415==--

