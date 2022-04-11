Content-Type: multipart/mixed; boundary="===============1217565308216356480=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 05/11] rtnl: Minor cleanup
Date: Mon, 11 Apr 2022 16:20:50 +0200
Message-ID: <20220411142056.817784-5-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============1217565308216356480==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In l_rtnl_route_get_gateway return NULL if route is for an onlink prefix
(no gateway).  Remove empty lines and use L_IN_SET in one instance.
---
 ell/rtnl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index cbe9b87..58f2eb1 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -469,6 +469,9 @@ LIB_EXPORT bool l_rtnl_route_get_gateway(const struct l=
_rtnl_route *rt,
 	if (unlikely(!rt))
 		return false;
 =

+	if (address_is_null(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr))
+		return false;
+
 	return !address_to_string(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr,
 					out_buf);
 }
@@ -583,9 +586,8 @@ LIB_EXPORT bool l_rtnl_route_set_preference(struct l_rt=
nl_route *rt,
 	if (unlikely(!rt))
 		return false;
 =

-	if (preference !=3D ICMPV6_ROUTER_PREF_LOW &&
-			preference !=3D ICMPV6_ROUTER_PREF_HIGH &&
-			preference !=3D ICMPV6_ROUTER_PREF_MEDIUM)
+	if (!L_IN_SET(preference, ICMPV6_ROUTER_PREF_LOW,
+			ICMPV6_ROUTER_PREF_HIGH, ICMPV6_ROUTER_PREF_MEDIUM))
 		return false;
 =

 	rt->preference =3D preference;
@@ -602,7 +604,6 @@ LIB_EXPORT bool l_rtnl_route_get_prefsrc(const struct l=
_rtnl_route *rt,
 					&rt->prefsrc.in6_addr))
 		return false;
 =

-
 	return !address_to_string(rt->family, &rt->prefsrc.in_addr,
 						&rt->prefsrc.in6_addr,
 						out_address);
@@ -1079,7 +1080,6 @@ LIB_EXPORT void l_rtnl_ifaddr6_extract(const struct i=
faddrmsg *ifa, int len,
 =

 			if (!inet_ntop(AF_INET6, &in6_addr, address,
 							INET6_ADDRSTRLEN)) {
-
 				l_error("rtnl: Failed to extract IPv6 address");
 				break;
 			}
-- =

2.32.0

--===============1217565308216356480==--

