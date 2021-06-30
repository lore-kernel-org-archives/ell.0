Content-Type: multipart/mixed; boundary="===============1154655519807732644=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] rtnl: Add l_rtnl_route_get_gateway
Date: Wed, 30 Jun 2021 20:51:07 +0200
Message-ID: <20210630185108.263533-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210630185108.263533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1154655519807732644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 10 ++++++++++
 ell/rtnl.h  |  1 +
 3 files changed, 12 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index d7027e3..add7fef 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -607,6 +607,7 @@ global:
 	l_rtnl_route_new_prefix;
 	l_rtnl_route_free;
 	l_rtnl_route_get_family;
+	l_rtnl_route_get_gateway;
 	l_rtnl_route_get_lifetime;
 	l_rtnl_route_set_lifetime;
 	l_rtnl_route_get_mtu;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 957e749..3805ab5 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -389,6 +389,16 @@ LIB_EXPORT uint8_t l_rtnl_route_get_family(const struc=
t l_rtnl_route *rt)
 	return rt->family;
 }
 =

+LIB_EXPORT bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt,
+						char *out_buf)
+{
+	if (unlikely(!rt))
+		return false;
+
+	return !address_to_string(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr,
+					out_buf);
+}
+
 LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t)
 {
 	if (unlikely(!rt))
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 2ddd916..9ea24f5 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -61,6 +61,7 @@ struct l_rtnl_route *l_rtnl_route_new_prefix(const char *=
ip,
 							uint8_t prefix_len);
 void l_rtnl_route_free(struct l_rtnl_route *rt);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
+bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
 uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
 uint32_t l_rtnl_route_get_mtu(const struct l_rtnl_route *rt);
-- =

2.30.2

--===============1154655519807732644==--

