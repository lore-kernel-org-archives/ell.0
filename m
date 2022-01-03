Content-Type: multipart/mixed; boundary="===============4729210662146975710=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/4] rtnl: Add l_rtnl_route_set_gateway
Date: Mon, 03 Jan 2022 15:18:27 +0100
Message-ID: <20220103141830.311011-1-andrew.zaborowski@intel.com>

--===============4729210662146975710==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow creating prefix routes for off-link prefixes, i.e. ones that
should be routed through a gateway.
---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 16 ++++++++++++++++
 ell/rtnl.h  |  1 +
 3 files changed, 18 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 51db458..e581add 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -633,6 +633,7 @@ global:
 	l_rtnl_route_free;
 	l_rtnl_route_get_family;
 	l_rtnl_route_get_gateway;
+	l_rtnl_route_set_gateway;
 	l_rtnl_route_get_lifetime;
 	l_rtnl_route_set_lifetime;
 	l_rtnl_route_get_mtu;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 4a1a248..ee6dc9a 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -403,6 +403,22 @@ LIB_EXPORT bool l_rtnl_route_get_gateway(const struct =
l_rtnl_route *rt,
 					out_buf);
 }
 =

+LIB_EXPORT bool l_rtnl_route_set_gateway(struct l_rtnl_route *rt,
+						const char *address)
+{
+	if (unlikely(!rt))
+		return false;
+
+	switch (rt->family) {
+	case AF_INET:
+		return inet_pton(AF_INET, address, &rt->gw.in_addr) =3D=3D 1;
+	case AF_INET6:
+		return inet_pton(AF_INET6, address, &rt->gw.in6_addr) =3D=3D 1;
+	default:
+		return  false;
+	}
+}
+
 LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t)
 {
 	if (unlikely(!rt))
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 274816c..70cbaec 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -69,6 +69,7 @@ void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
+bool l_rtnl_route_set_gateway(struct l_rtnl_route *rt, const char *address=
);
 uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
 uint32_t l_rtnl_route_get_mtu(const struct l_rtnl_route *rt);
-- =

2.32.0

--===============4729210662146975710==--

