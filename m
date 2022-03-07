Content-Type: multipart/mixed; boundary="===============5375285067107600504=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 01/12] rtnl: Track route & address expiry times
Date: Mon, 07 Mar 2022 15:55:32 +0100
Message-ID: <20220307145543.1558788-1-andrew.zaborowski@intel.com>

--===============5375285067107600504==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Store expiry times of addresses and routes in addition to the lifetimes
so that at any time the current lifetime left can be calculated.
The expiry time is normally the creation or renewal time + lifetime.
---
 ell/ell.sym |  4 +++
 ell/rtnl.c  | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 ell/rtnl.h  | 12 +++++++--
 3 files changed, 83 insertions(+), 9 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 01aec31..1641506 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -630,6 +630,8 @@ global:
 	l_rtnl_address_get_valid_lifetime;
 	l_rtnl_address_get_preferred_lifetime;
 	l_rtnl_address_set_lifetimes;
+	l_rtnl_address_get_expiry;
+	l_rtnl_address_set_expiry;
 	l_rtnl_address_set_scope;
 	l_rtnl_route_new_gateway;
 	l_rtnl_route_new_prefix;
@@ -639,6 +641,8 @@ global:
 	l_rtnl_route_get_dst;
 	l_rtnl_route_get_lifetime;
 	l_rtnl_route_set_lifetime;
+	l_rtnl_route_get_expiry;
+	l_rtnl_route_set_expiry;
 	l_rtnl_route_get_mtu;
 	l_rtnl_route_set_mtu;
 	l_rtnl_route_get_preference;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index d93c3f3..afbff9d 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -38,6 +38,7 @@
 #include "netlink.h"
 #include "log.h"
 #include "util.h"
+#include "time.h"
 #include "rtnl.h"
 #include "private.h"
 =

@@ -53,6 +54,8 @@ struct l_rtnl_address {
 	char label[IFNAMSIZ];
 	uint32_t preferred_lifetime;
 	uint32_t valid_lifetime;
+	uint32_t preferred_expiry_time;
+	uint32_t valid_expiry_time;
 	uint32_t flags;
 };
 =

@@ -110,6 +113,8 @@ static inline void _rtnl_address_init(struct l_rtnl_add=
ress *addr,
 	memset(addr->label, 0, sizeof(addr->label));
 	addr->preferred_lifetime =3D 0;
 	addr->valid_lifetime =3D 0;
+	addr->preferred_expiry_time =3D 0;
+	addr->valid_expiry_time =3D 0;
 =

 	l_rtnl_address_set_broadcast(addr, NULL);
 }
@@ -276,15 +281,48 @@ LIB_EXPORT bool l_rtnl_address_set_lifetimes(struct l=
_rtnl_address *addr,
 						uint32_t preferred_lifetime,
 						uint32_t valid_lifetime)
 {
+	uint64_t now =3D l_time_now();
+
 	if (unlikely(!addr))
 		return false;
 =

 	addr->preferred_lifetime =3D preferred_lifetime;
 	addr->valid_lifetime =3D valid_lifetime;
+	addr->preferred_expiry_time =3D preferred_lifetime ?
+		now + preferred_lifetime * L_USEC_PER_SEC : 0;
+	addr->valid_expiry_time =3D valid_lifetime ?
+		now + valid_lifetime * L_USEC_PER_SEC : 0;
+	return true;
+}
+
+LIB_EXPORT bool l_rtnl_address_get_expiry(const struct l_rtnl_address *add=
r,
+						uint64_t *preferred_expiry_time,
+						uint64_t *valid_expiry_time)
+{
+	if (unlikely(!addr))
+		return false;
+
+	if (preferred_expiry_time)
+		*preferred_expiry_time =3D addr->preferred_expiry_time;
+
+	if (valid_expiry_time)
+		*valid_expiry_time =3D addr->valid_expiry_time;
 =

 	return true;
 }
 =

+LIB_EXPORT bool l_rtnl_address_set_expiry(struct l_rtnl_address *addr,
+						uint64_t preferred_expiry_time,
+						uint64_t valid_expiry_time)
+{
+	if (unlikely(!addr))
+		return false;
+
+	addr->preferred_expiry_time =3D preferred_expiry_time;
+	addr->valid_expiry_time =3D valid_expiry_time;
+	return true;
+}
+
 LIB_EXPORT bool l_rtnl_address_set_scope(struct l_rtnl_address *addr,
 								uint8_t scope)
 {
@@ -313,6 +351,7 @@ struct l_rtnl_route {
 		struct in_addr in_addr;
 	} prefsrc;
 	uint32_t lifetime;
+	uint64_t expiry_time;
 	uint32_t mtu;
 	uint32_t priority;
 	uint8_t preference;
@@ -432,6 +471,23 @@ LIB_EXPORT bool l_rtnl_route_set_lifetime(struct l_rtn=
l_route *rt, uint32_t lt)
 		return false;
 =

 	rt->lifetime =3D lt;
+	rt->expiry_time =3D lt ? l_time_now() + lt * L_USEC_PER_SEC : 0;
+
+	return true;
+}
+
+LIB_EXPORT uint64_t l_rtnl_route_get_expiry(const struct l_rtnl_route *rt)
+{
+	return rt->expiry_time;
+}
+
+LIB_EXPORT bool l_rtnl_route_set_expiry(struct l_rtnl_route *rt,
+					uint64_t expiry_time)
+{
+	if (unlikely(!rt))
+		return false;
+
+	rt->expiry_time =3D expiry_time;
 	return true;
 }
 =

@@ -1102,6 +1158,7 @@ static uint32_t _rtnl_ifaddr_change(struct l_netlink =
*rtnl, uint16_t nlmsg_type,
 	size_t bufsize;
 	uint32_t id;
 	int flags =3D 0;
+	uint64_t now =3D l_time_now();
 =

 	if  (nlmsg_type =3D=3D RTM_NEWADDR)
 		flags =3D NLM_F_CREATE | NLM_F_REPLACE;
@@ -1145,12 +1202,15 @@ static uint32_t _rtnl_ifaddr_change(struct l_netlin=
k *rtnl, uint16_t nlmsg_type,
 		buf +=3D rta_add_data(buf, IFA_LABEL,
 					addr->label, strlen(addr->label) + 1);
 =

-	if (addr->preferred_lifetime || addr->valid_lifetime) {
+	if (addr->preferred_expiry_time > now ||
+			addr->valid_expiry_time > now) {
 		struct ifa_cacheinfo cinfo;
 =

 		memset(&cinfo, 0, sizeof(cinfo));
-		cinfo.ifa_prefered =3D addr->preferred_lifetime;
-		cinfo.ifa_valid =3D addr->valid_lifetime;
+		cinfo.ifa_prefered =3D addr->preferred_expiry_time > now ?
+			l_time_to_secs(addr->preferred_expiry_time - now) : 0;
+		cinfo.ifa_valid =3D  addr->valid_expiry_time > now ?
+			l_time_to_secs(addr->valid_expiry_time - now) : 0;
 =

 		buf +=3D rta_add_data(buf, IFA_CACHEINFO, &cinfo, sizeof(cinfo));
 	}
@@ -1208,8 +1268,8 @@ LIB_EXPORT struct l_rtnl_address *l_rtnl_ifaddr_extra=
ct(
 			break;
 		case IFA_CACHEINFO:
 			cinfo =3D RTA_DATA(attr);
-			addr->preferred_lifetime =3D cinfo->ifa_prefered;
-			addr->valid_lifetime =3D cinfo->ifa_valid;
+			l_rtnl_address_set_lifetimes(addr, cinfo->ifa_prefered,
+							cinfo->ifa_valid);
 			break;
 		}
 	}
@@ -1248,6 +1308,7 @@ static uint32_t _rtnl_route_change(struct l_netlink *=
rtnl,
 	size_t bufsize;
 	void *rta_buf;
 	uint16_t flags;
+	uint64_t now =3D l_time_now();
 =

 	bufsize =3D NLMSG_ALIGN(sizeof(struct rtmsg)) +
 			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_OIF */
@@ -1303,8 +1364,9 @@ static uint32_t _rtnl_route_change(struct l_netlink *=
rtnl,
 	if (rt->preference)
 		rta_buf +=3D rta_add_u8(rta_buf, RTA_PREF, rt->preference);
 =

-	if (rt->lifetime !=3D 0xffffffff)
-		rta_buf +=3D rta_add_u32(rta_buf, RTA_EXPIRES, rt->lifetime);
+	if (rt->expiry_time > now)
+		rta_buf +=3D rta_add_u32(rta_buf, RTA_EXPIRES,
+					l_time_to_secs(rt->expiry_time - now));
 =

 	return l_netlink_send(rtnl, nlmsg_type, flags, rtmmsg,
 				rta_buf - (void *) rtmmsg, cb, user_data,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index ebc6da8..bbd410e 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -60,6 +60,12 @@ uint32_t l_rtnl_address_get_preferred_lifetime(
 bool l_rtnl_address_set_lifetimes(struct l_rtnl_address *addr,
 						uint32_t preferred_lifetime,
 						uint32_t valid_lifetime);
+bool l_rtnl_address_get_expiry(const struct l_rtnl_address *addr,
+				uint64_t *preferred_expiry_time,
+				uint64_t *valid_expiry_time);
+bool l_rtnl_address_set_expiry(struct l_rtnl_address *addr,
+				uint64_t preferred_expiry_time,
+				uint64_t valid_expiry_time);
 bool l_rtnl_address_set_scope(struct l_rtnl_address *addr, uint8_t scope);
 =

 struct l_rtnl_route *l_rtnl_route_new_gateway(const char *gw);
@@ -69,10 +75,12 @@ void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
-uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
-bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
 bool l_rtnl_route_get_dst(const struct l_rtnl_route *rt, char *out_buf,
 				uint8_t *out_prefix_len);
+uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
+bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
+uint64_t l_rtnl_route_get_expiry(const struct l_rtnl_route *rt);
+bool l_rtnl_route_set_expiry(struct l_rtnl_route *rt, uint64_t expiry_time=
);
 uint32_t l_rtnl_route_get_mtu(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_mtu(struct l_rtnl_route *rt, uint32_t mtu);
 uint8_t l_rtnl_route_get_preference(const struct l_rtnl_route *rt);
-- =

2.32.0

--===============5375285067107600504==--

