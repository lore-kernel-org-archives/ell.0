Content-Type: multipart/mixed; boundary="===============7470893456436906734=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] net: fix include error
Date: Thu, 12 Apr 2018 10:28:56 -0700
Message-ID: <1523554136-9237-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7470893456436906734==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

sys/socket.h needed to be included before linux/if_arp.h
to fix a build error.
---
 ell/net.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/net.c b/ell/net.c
index 77eadff..b5b5f9d 100644
--- a/ell/net.c
+++ b/ell/net.c
@@ -24,6 +24,7 @@
 #include <config.h>
 #endif
 =

+#include <sys/socket.h>
 #include <linux/if_arp.h>
 #include <unistd.h>
 #include <errno.h>
-- =

2.7.4


--===============7470893456436906734==--

