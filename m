Content-Type: multipart/mixed; boundary="===============0375967884797722111=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 17/17] icmp6: Ignore bad prefixes per RFC4862
Date: Sat, 14 May 2022 00:47:13 +0200
Message-ID: <20220513224713.1447773-17-andrew.zaborowski@intel.com>
In-Reply-To: 20220513224713.1447773-1-andrew.zaborowski@intel.com

--===============0375967884797722111==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

"Silently ignore" Prefix Information options with a preferred time
longer than valid time and those matching the link-local prefix as
mandated by RFC4862 Section 5.5.3.  These prefixes are also invalid
according to RFC4861.
---
 ell/icmp6.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index ab2fe9c..96ba1ec 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -45,6 +45,7 @@
 #include "time-private.h"
 #include "queue.h"
 #include "net.h"
+#include "net-private.h"
 #include "netlink.h"
 #include "rtnl.h"
 #include "missing.h"
@@ -817,7 +818,27 @@ struct l_icmp6_router *_icmp6_router_parse(const struc=
t nd_router_advert *ra,
 			i->onlink =3D true;
 			i->valid_lifetime =3D l_get_be32(opts + 4);
 			i->preferred_lifetime =3D l_get_be32(opts + 8);
-			memcpy(i->address, opts + 16, 16);
+
+			/*
+			 * Only the initial Prefix Length bits of the prefix
+			 * are valid.  The remaining bits "MUST" be ignored
+			 * by the receiver.
+			 */
+			memcpy(i->address, net_prefix_from_ipv6(opts + 16,
+							i->prefix_len), 16);
+
+			/*
+			 * For SLAAC (RFC4862) we need to "silently ignore"
+			 * routes with a preferred lifetime longer than valid
+			 * lifetime, and those with the link-local prefix.
+			 * Since it makes sense, do it regardless of SLAAC.
+			 */
+			if (i->preferred_lifetime > i->valid_lifetime)
+				break;
+
+			if (i->prefix_len >=3D 10 &&
+					IN6_IS_ADDR_LINKLOCAL(i->address))
+				break;
 =

 			n_routes +=3D 1;
 			break;
@@ -869,7 +890,14 @@ struct l_icmp6_router *_icmp6_router_parse(const struc=
t nd_router_advert *ra,
 			i->onlink =3D false;
 			i->preference =3D preference;
 			i->valid_lifetime =3D l_get_be32(opts + 4);
-			memcpy(i->address, opts + 8, (i->prefix_len + 7) / 8);
+
+			/*
+			 * Only the initial Prefix Length bits of the prefix
+			 * are valid.  The remaining bits "MUST" be ignored
+			 * by the receiver.
+			 */
+			memcpy(i->address, net_prefix_from_ipv6(opts + 8,
+							i->prefix_len), 16);
 =

 			n_routes +=3D 1;
 			break;
-- =

2.32.0

--===============0375967884797722111==--

