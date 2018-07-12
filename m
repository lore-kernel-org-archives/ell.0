Content-Type: multipart/mixed; boundary="===============7613007753293081029=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCHv2] dhcp: include if_arp.h from libc instead of linux headers
Date: Thu, 12 Jul 2018 19:31:25 +0200
Message-ID: <20180712173125.1075-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7613007753293081029==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Compilation with musl libc fails due to redefinition of 'struct
arp{req,req_old,hdr}' in linux/if_arp.h, since it is already defined and
included in net/if_arp.h (through net/ethernet.h -> net/if_ether.h).

The only symbols used from if_arp.h is ARPHRD_ETHER, so it should be
safe to avoid the compile error by including the if_arp.h header from
the c-library instead.

---

Changes in v2:
- Rebased on master
- Removed signed-of-by

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
 =

-- =

2.18.0


--===============7613007753293081029==--

