Content-Type: multipart/mixed; boundary="===============2597269140925692963=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/6] rtnl: Add l_rtnl_route_get_dst
Date: Mon, 07 Feb 2022 16:07:13 +0100
Message-ID: <20220207150717.60511-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220207150717.60511-1-andrew.zaborowski@intel.com

--===============2597269140925692963==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 14 ++++++++++++++
 ell/rtnl.h  |  2 ++
 3 files changed, 17 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 60c5525..203a91b 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -634,6 +634,7 @@ global:
 	l_rtnl_route_free;
 	l_rtnl_route_get_family;
 	l_rtnl_route_get_gateway;
+	l_rtnl_route_get_dst;
 	l_rtnl_route_get_lifetime;
 	l_rtnl_route_set_lifetime;
 	l_rtnl_route_get_mtu;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index dda27cf..5f0940b 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -410,6 +410,20 @@ LIB_EXPORT bool l_rtnl_route_get_gateway(const struct =
l_rtnl_route *rt,
 					out_buf);
 }
 =

+LIB_EXPORT bool l_rtnl_route_get_dst(const struct l_rtnl_route *rt, char *=
out_buf,
+					uint8_t *out_prefix_len)
+{
+	if (unlikely(!rt))
+		return false;
+
+	if (address_to_string(rt->family, &rt->dst.in_addr, &rt->dst.in6_addr,
+					out_buf) !=3D 0)
+		return false;
+
+	*out_prefix_len =3D rt->dst_prefix_len;
+	return true;
+}
+
 LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t,
 						uint64_t reference_time)
 {
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 8028d8d..1e232df 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -72,6 +72,8 @@ void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
+bool l_rtnl_route_get_dst(const struct l_rtnl_route *rt, char *out_buf,
+				uint8_t *out_prefix_len);
 uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt,
 					uint64_t reference_time);
 bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt,
-- =

2.32.0

--===============2597269140925692963==--

