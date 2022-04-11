Content-Type: multipart/mixed; boundary="===============2669034487620592888=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/11] rtnl: Add l_rtnl_route_new_static
Date: Mon, 11 Apr 2022 16:20:48 +0200
Message-ID: <20220411142056.817784-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============2669034487620592888==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a constructor for prefix routes through a specific gateway/router.
---
Name follows suggestion in
https://lists.01.org/hyperkitty/list/ell(a)lists.01.org/message/ZPJRBKRROCG=
ZFVLLFUCL6GYHHG2JQZLW/
---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 31 +++++++++++++++++++++++++++++++
 ell/rtnl.h  |  2 ++
 3 files changed, 34 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index ec995fc..3816e3f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -639,6 +639,7 @@ global:
 	l_rtnl_address_set_scope;
 	l_rtnl_route_new_gateway;
 	l_rtnl_route_new_prefix;
+	l_rtnl_route_new_static;
 	l_rtnl_route_free;
 	l_rtnl_route_get_family;
 	l_rtnl_route_get_gateway;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index afbff9d..dbaf97b 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -419,6 +419,37 @@ LIB_EXPORT struct l_rtnl_route *l_rtnl_route_new_prefi=
x(const char *ip,
 	return rt;
 }
 =

+LIB_EXPORT struct l_rtnl_route *l_rtnl_route_new_static(const char *gw,
+							const char *ip,
+							uint8_t prefix_len)
+{
+	struct in_addr gw_addr4;
+	struct in6_addr gw_addr6;
+	struct in_addr dst_addr4;
+	struct in6_addr dst_addr6;
+	int family;
+	struct l_rtnl_route *rt;
+
+	if ((family =3D address_get(gw, &gw_addr4, &gw_addr6)) < 0)
+		return NULL;
+
+	if (address_get(ip, &dst_addr4, &dst_addr6) !=3D family)
+		return NULL;
+
+	if (prefix_len =3D=3D 0 || prefix_len > (family =3D=3D AF_INET ? 32 : 128=
))
+		return NULL;
+
+	rt =3D l_rtnl_route_new_gateway(gw);
+	rt->dst_prefix_len =3D prefix_len;
+
+	if (family =3D=3D AF_INET6)
+		memcpy(&rt->dst.in6_addr, &dst_addr6, sizeof(dst_addr6));
+	else
+		memcpy(&rt->dst.in_addr, &dst_addr4, sizeof(dst_addr4));
+
+	return rt;
+}
+
 LIB_EXPORT void l_rtnl_route_free(struct l_rtnl_route *rt)
 {
 	l_free(rt);
diff --git a/ell/rtnl.h b/ell/rtnl.h
index bbd410e..55c4997 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -71,6 +71,8 @@ bool l_rtnl_address_set_scope(struct l_rtnl_address *addr=
, uint8_t scope);
 struct l_rtnl_route *l_rtnl_route_new_gateway(const char *gw);
 struct l_rtnl_route *l_rtnl_route_new_prefix(const char *ip,
 							uint8_t prefix_len);
+struct l_rtnl_route *l_rtnl_route_new_static(const char *gw, const char *i=
p,
+							uint8_t prefix_len);
 void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
-- =

2.32.0

--===============2669034487620592888==--

