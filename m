Content-Type: multipart/mixed; boundary="===============1664424299647541444=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 4/8] netconfig: In netconfig_find_icmp6_route check protocol
 is RTPROT_RA
Date: Fri, 15 Apr 2022 20:32:07 +0200
Message-ID: <20220415183211.987345-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220415183211.987345-1-andrew.zaborowski@intel.com

--===============1664424299647541444==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since we're interested only in routes from icmp6 (Router Advertisements)
we can check that the route's protocol is RTPROT_RA before following
with other checks.
---
I'll merge this into the original ICMP6 handling patch if/when I'm resending
that one.

 ell/netconfig.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index eb74aa5..5db159d 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -371,7 +371,8 @@ static struct l_rtnl_route *netconfig_find_icmp6_route(
 		const uint8_t *route_dst;
 		uint8_t route_prefix_len =3D 0;
 =

-		if (l_rtnl_route_get_family(route) !=3D AF_INET6)
+		if (l_rtnl_route_get_family(route) !=3D AF_INET6 ||
+				l_rtnl_route_get_protocol(route) !=3D RTPROT_RA)
 			continue;
 =

 		route_gateway =3D l_rtnl_route_get_gateway_in_addr(route);
-- =

2.32.0

--===============1664424299647541444==--

