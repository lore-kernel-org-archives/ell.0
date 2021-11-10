Content-Type: multipart/mixed; boundary="===============0702491579510944554=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 1/3] rtnl: Fix address conversion buffer overflow.
Date: Tue, 09 Nov 2021 16:14:46 -0800
Message-ID: <20211110001448.175980-2-ossama.othman@intel.com>
In-Reply-To: 20211110001448.175980-1-ossama.othman@intel.com

--===============0702491579510944554==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some l_rtnl functions that return a stringified address could
potentially overrun a user supplied buffer of insufficient length.
Add a buffer length argument to prevent ELL from making incorrect
assumptions.  Impacted functions are l_rtnl_address_get_address(),
l_rtnl_route_get_gateway(), and l_rtnl_route_get_prefsrc().
---
 ell/rtnl.c | 28 +++++++++++++++++-----------
 ell/rtnl.h |  8 +++++---
 2 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 4a1a248..bfda632 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -58,21 +58,24 @@ struct l_rtnl_address {
 =

 static inline int address_to_string(int family, const struct in_addr *v4,
 					const struct in6_addr *v6,
-					char *out_address)
+					char *out_buf, size_t buflen)
 {
+	const void *src =3D NULL;
+
 	switch (family) {
 	case AF_INET:
-		if (!inet_ntop(family, v4, out_address, INET_ADDRSTRLEN))
-			return -errno;
+                src =3D v4;
 		break;
 	case AF_INET6:
-		if (!inet_ntop(family, v6, out_address, INET6_ADDRSTRLEN))
-			return -errno;
+                src =3D v6;
 		break;
 	default:
 		return  false;
 	}
 =

+	if (!inet_ntop(family, src, out_buf, buflen))
+		return -errno;
+
 	return 0;
 }
 =

@@ -162,14 +165,15 @@ LIB_EXPORT void l_rtnl_address_free(struct l_rtnl_add=
ress *addr)
 }
 =

 LIB_EXPORT bool l_rtnl_address_get_address(const struct l_rtnl_address *ad=
dr,
-						char *out_buf)
+						char *out_buf,
+						size_t buflen)
 {
 	if (unlikely(!addr))
 		return false;
 =

 	return !address_to_string(addr->family, &addr->in_addr,
 						&addr->in6_addr,
-						out_buf);
+						out_buf, buflen);
 }
 =

 LIB_EXPORT uint8_t l_rtnl_address_get_family(const struct l_rtnl_address *=
addr)
@@ -394,13 +398,14 @@ LIB_EXPORT uint8_t l_rtnl_route_get_family(const stru=
ct l_rtnl_route *rt)
 }
 =

 LIB_EXPORT bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt,
-						char *out_buf)
+						char *out_buf,
+						size_t buflen)
 {
 	if (unlikely(!rt))
 		return false;
 =

 	return !address_to_string(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr,
-					out_buf);
+					out_buf, buflen);
 }
 =

 LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t)
@@ -461,7 +466,8 @@ LIB_EXPORT bool l_rtnl_route_set_preference(struct l_rt=
nl_route *rt,
 }
 =

 LIB_EXPORT bool l_rtnl_route_get_prefsrc(const struct l_rtnl_route *rt,
-						char *out_address)
+						char *out_buf,
+						size_t buflen)
 {
 	if (unlikely(!rt))
 		return false;
@@ -473,7 +479,7 @@ LIB_EXPORT bool l_rtnl_route_get_prefsrc(const struct l=
_rtnl_route *rt,
 =

 	return !address_to_string(rt->family, &rt->prefsrc.in_addr,
 						&rt->prefsrc.in6_addr,
-						out_address);
+						out_buf, buflen);
 }
 =

 LIB_EXPORT bool l_rtnl_route_set_prefsrc(struct l_rtnl_route *rt,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 274816c..802692b 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -43,7 +43,7 @@ struct l_rtnl_address *l_rtnl_address_clone(const struct =
l_rtnl_address *orig);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
 DEFINE_CLEANUP_FUNC(l_rtnl_address_free);
 bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
-				char *out_buf);
+				char *out_buf, size_t buflen);
 uint8_t l_rtnl_address_get_family(const struct l_rtnl_address *addr);
 uint8_t l_rtnl_address_get_prefix_length(const struct l_rtnl_address *addr=
);
 bool l_rtnl_address_get_broadcast(const struct l_rtnl_address *addr,
@@ -68,14 +68,16 @@ struct l_rtnl_route *l_rtnl_route_new_prefix(const char=
 *ip,
 void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
-bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
+bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf,
+					size_t buflen);
 uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
 uint32_t l_rtnl_route_get_mtu(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_mtu(struct l_rtnl_route *rt, uint32_t mtu);
 uint8_t l_rtnl_route_get_preference(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_preference(struct l_rtnl_route *rt, uint8_t preferen=
ce);
-bool l_rtnl_route_get_prefsrc(const struct l_rtnl_route *rt, char *out_add=
ress);
+bool l_rtnl_route_get_prefsrc(const struct l_rtnl_route *rt, char *out_buf,
+					size_t buflen);
 bool l_rtnl_route_set_prefsrc(struct l_rtnl_route *rt, const char *address=
);
 uint32_t l_rtnl_route_get_priority(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_priority(struct l_rtnl_route *rt, uint32_t priority);
-- =

2.32.0

--===============0702491579510944554==--

