Content-Type: multipart/mixed; boundary="===============6183977395402067195=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] netlink: Include <stdint.h> for fixed width types
Date: Mon, 24 Apr 2017 12:40:28 -0700
Message-ID: <1493062828-21327-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6183977395402067195==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The prototypes in the ELL netlink.h header use the C99 fixed width
integer types.  Include <stdint.h> to make netlink.h self-contained.
---
 ell/netlink.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/netlink.h b/ell/netlink.h
index d7baa89..b40933f 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -24,6 +24,7 @@
 #define __ELL_NETLINK_H
 =

 #include <stdbool.h>
+#include <stdint.h>
 =

 #ifdef __cplusplus
 extern "C" {
-- =

2.7.4


--===============6183977395402067195==--

