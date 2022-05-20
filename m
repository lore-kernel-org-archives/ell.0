Content-Type: multipart/mixed; boundary="===============3035120261195622346=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/15] netconfig: Add missing NULL check for routes from RA
Date: Fri, 20 May 2022 17:43:24 +0200
Message-ID: <20220520154338.2056273-1-andrew.zaborowski@intel.com>

--===============3035120261195622346==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes: 7a137bcac31e ("netconfig: Create routes from Router Advertisements")
---
 ell/netconfig.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index f39f88f..8026c81 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -573,8 +573,9 @@ static struct l_rtnl_route *netconfig_add_icmp6_route(s=
truct l_netconfig *nc,
 {
 	struct l_rtnl_route *rt;
 =

-	rt =3D netconfig_route_new(nc, AF_INET6, dst->address, dst->prefix_len,
-					gateway, RTPROT_RA);
+	rt =3D netconfig_route_new(nc, AF_INET6, dst ? dst->address : NULL,
+					dst ? dst->prefix_len : 0, gateway,
+					RTPROT_RA);
 	if (L_WARN_ON(!rt))
 		return NULL;
 =

-- =

2.32.0

--===============3035120261195622346==--

