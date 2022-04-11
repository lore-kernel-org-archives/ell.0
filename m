Content-Type: multipart/mixed; boundary="===============5568409147933035105=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 04/11] rtnl: Add l_rtnl_route getters for raw address data
Date: Mon, 11 Apr 2022 16:20:49 +0200
Message-ID: <20220411142056.817784-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============5568409147933035105==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add l_rtnl_route_get_gateway_in_addr and l_rtnl_route_get_dst_in_addr
for raw struct in_addr / struct in6_addr addresses, as opposed to string
representations.  This is to be used to avoid unneeded string
conversions in both directions.
---
 ell/ell.sym |  2 ++
 ell/rtnl.c  | 30 ++++++++++++++++++++++++++++++
 ell/rtnl.h  |  3 +++
 3 files changed, 35 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 3816e3f..9b3a6e1 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -643,7 +643,9 @@ global:
 	l_rtnl_route_free;
 	l_rtnl_route_get_family;
 	l_rtnl_route_get_gateway;
+	l_rtnl_route_get_gateway_in_addr;
 	l_rtnl_route_get_dst;
+	l_rtnl_route_get_dst_in_addr;
 	l_rtnl_route_get_lifetime;
 	l_rtnl_route_set_lifetime;
 	l_rtnl_route_get_expiry;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index dbaf97b..cbe9b87 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -473,6 +473,21 @@ LIB_EXPORT bool l_rtnl_route_get_gateway(const struct =
l_rtnl_route *rt,
 					out_buf);
 }
 =

+LIB_EXPORT const void *l_rtnl_route_get_gateway_in_addr(
+						const struct l_rtnl_route *rt)
+{
+	if (unlikely(!rt))
+		return NULL;
+
+	if (address_is_null(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr))
+		return NULL;
+
+	if (rt->family =3D=3D AF_INET)
+		return &rt->gw.in_addr;
+	else
+		return &rt->gw.in6_addr;
+}
+
 LIB_EXPORT bool l_rtnl_route_get_dst(const struct l_rtnl_route *rt,
 						char *out_buf,
 						uint8_t *out_prefix_len)
@@ -488,6 +503,21 @@ LIB_EXPORT bool l_rtnl_route_get_dst(const struct l_rt=
nl_route *rt,
 	return true;
 }
 =

+LIB_EXPORT const void *l_rtnl_route_get_dst_in_addr(
+						const struct l_rtnl_route *rt,
+						uint8_t *out_prefix_len)
+{
+	if (unlikely(!rt))
+		return NULL;
+
+	*out_prefix_len =3D rt->dst_prefix_len;
+
+	if (rt->family =3D=3D AF_INET)
+		return &rt->dst.in_addr;
+	else
+		return &rt->dst.in6_addr;
+}
+
 LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t)
 {
 	if (unlikely(!rt))
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 55c4997..2617b1c 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -77,8 +77,11 @@ void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
+const void *l_rtnl_route_get_gateway_in_addr(const struct l_rtnl_route *rt=
);
 bool l_rtnl_route_get_dst(const struct l_rtnl_route *rt, char *out_buf,
 				uint8_t *out_prefix_len);
+const void *l_rtnl_route_get_dst_in_addr(const struct l_rtnl_route *rt,
+						uint8_t *out_prefix_len);
 uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
 uint64_t l_rtnl_route_get_expiry(const struct l_rtnl_route *rt);
-- =

2.32.0

--===============5568409147933035105==--

