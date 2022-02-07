Content-Type: multipart/mixed; boundary="===============5738601059009263513=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/6] rtnl: Track expiry times instead of lifetimes
Date: Mon, 07 Feb 2022 16:07:12 +0100
Message-ID: <20220207150717.60511-1-andrew.zaborowski@intel.com>

--===============5738601059009263513==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Internally within rtnl.c store expiry times of addresses and routes
instead of their lifetime periods so that at any time the current
lifetime left can be returned.  This is an incompatible API change to
the lifetime getters and setters as they now take a reference_time
parameter, which in the setter case should normally be the timestamp of
when the address or route was received from DHCP.  These setters and
getters don't seem to have been used outside of ell.
---
 ell/dhcp.c  |  3 ++-
 ell/dhcp6.c |  3 ++-
 ell/rtnl.c  | 71 ++++++++++++++++++++++++++++++++++-------------------
 ell/rtnl.h  | 15 +++++++----
 4 files changed, 60 insertions(+), 32 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index e2d18fc..89f1306 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -680,6 +680,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 	struct dhcp_message_iter iter;
 	struct l_dhcp_lease *lease;
 	int r;
+	uint64_t now =3D l_time_now();
 =

 	CLIENT_DEBUG("");
 =

@@ -734,7 +735,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 =

 		a =3D l_rtnl_address_new(ip, prefix_len);
 		l_rtnl_address_set_noprefixroute(a, true);
-		l_rtnl_address_set_lifetimes(a, l, l);
+		l_rtnl_address_set_lifetimes(a, l, l, now);
 		l_rtnl_address_set_broadcast(a, broadcast);
 =

 		client->rtnl_add_cmdid =3D
diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 40c6f3a..0a660d6 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -967,6 +967,7 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_cli=
ent *client)
 	uint32_t t1 =3D _dhcp6_lease_get_t1(client->lease);
 	uint32_t t2 =3D _dhcp6_lease_get_t2(client->lease);
 	enum l_dhcp6_client_event event;
+	uint64_t now =3D l_time_now();
 =

 	client->lease_start_t =3D l_time_now();
 =

@@ -1007,7 +1008,7 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_c=
lient *client)
 =

 		a =3D l_rtnl_address_new(ip, prefix_len);
 		l_rtnl_address_set_noprefixroute(a, true);
-		l_rtnl_address_set_lifetimes(a, p, v);
+		l_rtnl_address_set_lifetimes(a, p, v, now);
 =

 		client->rtnl_add_cmdid =3D
 			l_rtnl_ifaddr_add(client->rtnl, client->ifindex, a,
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 4a1a248..dda27cf 100644
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

@@ -51,8 +52,8 @@ struct l_rtnl_address {
 	};
 	struct in_addr broadcast;
 	char label[IFNAMSIZ];
-	uint32_t preferred_lifetime;
-	uint32_t valid_lifetime;
+	uint64_t preferred_expiry_time;
+	uint64_t valid_expiry_time;
 	uint32_t flags;
 };
 =

@@ -108,8 +109,8 @@ static inline void _rtnl_address_init(struct l_rtnl_add=
ress *addr,
 	addr->scope =3D RT_SCOPE_UNIVERSE;
 	addr->flags =3D IFA_F_PERMANENT;
 	memset(addr->label, 0, sizeof(addr->label));
-	addr->preferred_lifetime =3D 0;
-	addr->valid_lifetime =3D 0;
+	addr->preferred_expiry_time =3D 0;
+	addr->valid_expiry_time =3D 0;
 =

 	l_rtnl_address_set_broadcast(addr, NULL);
 }
@@ -255,32 +256,40 @@ LIB_EXPORT bool l_rtnl_address_set_noprefixroute(stru=
ct l_rtnl_address *addr,
 }
 =

 LIB_EXPORT uint32_t l_rtnl_address_get_valid_lifetime(
-					const struct l_rtnl_address *addr)
+					const struct l_rtnl_address *addr,
+					uint64_t reference_time)
 {
 	if (unlikely(!addr))
 		return false;
 =

-	return addr->valid_lifetime;
+	return addr->valid_expiry_time > reference_time ?
+		l_time_to_secs(addr->valid_expiry_time - reference_time) : 0;
 }
 =

 LIB_EXPORT uint32_t l_rtnl_address_get_preferred_lifetime(
-					const struct l_rtnl_address *addr)
+					const struct l_rtnl_address *addr,
+					uint64_t reference_time)
 {
 	if (unlikely(!addr))
 		return false;
 =

-	return addr->preferred_lifetime;
+	return addr->preferred_expiry_time > reference_time ?
+		l_time_to_secs(addr->preferred_expiry_time - reference_time) :
+		0;
 }
 =

 LIB_EXPORT bool l_rtnl_address_set_lifetimes(struct l_rtnl_address *addr,
 						uint32_t preferred_lifetime,
-						uint32_t valid_lifetime)
+						uint32_t valid_lifetime,
+						uint64_t reference_time)
 {
 	if (unlikely(!addr))
 		return false;
 =

-	addr->preferred_lifetime =3D preferred_lifetime;
-	addr->valid_lifetime =3D valid_lifetime;
+	addr->preferred_expiry_time =3D reference_time +
+		preferred_lifetime * L_USEC_PER_SEC;
+	addr->valid_expiry_time =3D reference_time +
+		valid_lifetime * L_USEC_PER_SEC;
 =

 	return true;
 }
@@ -312,7 +321,7 @@ struct l_rtnl_route {
 		struct in6_addr in6_addr;
 		struct in_addr in_addr;
 	} prefsrc;
-	uint32_t lifetime;
+	uint64_t expiry_time;
 	uint32_t mtu;
 	uint32_t priority;
 	uint8_t preference;
@@ -332,7 +341,6 @@ LIB_EXPORT struct l_rtnl_route *l_rtnl_route_new_gatewa=
y(const char *gw)
 	rt->family =3D family;
 	rt->scope =3D RT_SCOPE_UNIVERSE;
 	rt->protocol =3D RTPROT_UNSPEC;
-	rt->lifetime =3D 0xffffffff;
 =

 	if (family =3D=3D AF_INET6)
 		memcpy(&rt->gw.in6_addr, &in6_addr, sizeof(in6_addr));
@@ -365,7 +373,6 @@ LIB_EXPORT struct l_rtnl_route *l_rtnl_route_new_prefix=
(const char *ip,
 	rt =3D l_new(struct l_rtnl_route, 1);
 	rt->family =3D family;
 	rt->protocol =3D RTPROT_UNSPEC;
-	rt->lifetime =3D 0xffffffff;
 	rt->dst_prefix_len =3D prefix_len;
 =

 	/* IPV6 prefix routes are usually global, IPV4 are link-local */
@@ -403,20 +410,26 @@ LIB_EXPORT bool l_rtnl_route_get_gateway(const struct=
 l_rtnl_route *rt,
 					out_buf);
 }
 =

-LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t)
+LIB_EXPORT uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *r=
t,
+						uint64_t reference_time)
 {
 	if (unlikely(!rt))
 		return 0;
 =

-	return rt->lifetime;
+	if (!rt->expiry_time)
+		return 0xffffffff;
+
+	return rt->expiry_time > reference_time ?
+		l_time_to_secs(rt->expiry_time - reference_time) : 0;
 }
 =

-LIB_EXPORT bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_=
t lt)
+LIB_EXPORT bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_=
t lt,
+						uint64_t reference_time)
 {
 	if (unlikely(!rt))
 		return false;
 =

-	rt->lifetime =3D lt;
+	rt->expiry_time =3D reference_time + lt * L_USEC_PER_SEC;
 	return true;
 }
 =

@@ -1130,12 +1143,15 @@ static uint32_t _rtnl_ifaddr_change(struct l_netlin=
k *rtnl, uint16_t nlmsg_type,
 		buf +=3D rta_add_data(buf, IFA_LABEL,
 					addr->label, strlen(addr->label) + 1);
 =

-	if (addr->preferred_lifetime || addr->valid_lifetime) {
+	if (addr->preferred_expiry_time || addr->valid_expiry_time) {
 		struct ifa_cacheinfo cinfo;
+		uint64_t now =3D l_time_now();
 =

 		memset(&cinfo, 0, sizeof(cinfo));
-		cinfo.ifa_prefered =3D addr->preferred_lifetime;
-		cinfo.ifa_valid =3D addr->valid_lifetime;
+		cinfo.ifa_prefered =3D
+			l_rtnl_address_get_preferred_lifetime(addr, now);
+		cinfo.ifa_valid =3D
+			l_rtnl_address_get_valid_lifetime(addr, now);
 =

 		buf +=3D rta_add_data(buf, IFA_CACHEINFO, &cinfo, sizeof(cinfo));
 	}
@@ -1156,6 +1172,7 @@ LIB_EXPORT struct l_rtnl_address *l_rtnl_ifaddr_extra=
ct(
 	struct rtattr *attr;
 	struct ifa_cacheinfo *cinfo;
 	struct l_rtnl_address *addr;
+	uint64_t now =3D l_time_now();
 =

 	if (unlikely(!ifa))
 		return NULL;
@@ -1193,8 +1210,8 @@ LIB_EXPORT struct l_rtnl_address *l_rtnl_ifaddr_extra=
ct(
 			break;
 		case IFA_CACHEINFO:
 			cinfo =3D RTA_DATA(attr);
-			addr->preferred_lifetime =3D cinfo->ifa_prefered;
-			addr->valid_lifetime =3D cinfo->ifa_valid;
+			l_rtnl_address_set_lifetimes(addr, cinfo->ifa_prefered,
+							cinfo->ifa_valid, now);
 			break;
 		}
 	}
@@ -1288,8 +1305,12 @@ static uint32_t _rtnl_route_change(struct l_netlink =
*rtnl,
 	if (rt->preference)
 		rta_buf +=3D rta_add_u8(rta_buf, RTA_PREF, rt->preference);
 =

-	if (rt->lifetime !=3D 0xffffffff)
-		rta_buf +=3D rta_add_u32(rta_buf, RTA_EXPIRES, rt->lifetime);
+	if (rt->expiry_time) {
+		uint64_t now =3D l_time_now();
+
+		rta_buf +=3D rta_add_u32(rta_buf, RTA_EXPIRES,
+					l_rtnl_route_get_lifetime(rt, now));
+	}
 =

 	return l_netlink_send(rtnl, nlmsg_type, flags, rtmmsg,
 				rta_buf - (void *) rtmmsg, cb, user_data,
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 274816c..8028d8d 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -54,12 +54,15 @@ const char *l_rtnl_address_get_label(const struct l_rtn=
l_address *addr);
 bool l_rtnl_address_set_label(struct l_rtnl_address *addr, const char *lab=
el);
 bool l_rtnl_address_set_noprefixroute(struct l_rtnl_address *addr,
 							bool noprefixroute);
-uint32_t l_rtnl_address_get_valid_lifetime(const struct l_rtnl_address *ad=
dr);
+uint32_t l_rtnl_address_get_valid_lifetime(const struct l_rtnl_address *ad=
dr,
+						uint64_t reference_time);
 uint32_t l_rtnl_address_get_preferred_lifetime(
-					const struct l_rtnl_address *addr);
+					const struct l_rtnl_address *addr,
+					uint64_t reference_time);
 bool l_rtnl_address_set_lifetimes(struct l_rtnl_address *addr,
 						uint32_t preferred_lifetime,
-						uint32_t valid_lifetime);
+						uint32_t valid_lifetime,
+						uint64_t reference_time);
 bool l_rtnl_address_set_scope(struct l_rtnl_address *addr, uint8_t scope);
 =

 struct l_rtnl_route *l_rtnl_route_new_gateway(const char *gw);
@@ -69,8 +72,10 @@ void l_rtnl_route_free(struct l_rtnl_route *rt);
 DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
-uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt);
-bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt);
+uint32_t l_rtnl_route_get_lifetime(const struct l_rtnl_route *rt,
+					uint64_t reference_time);
+bool l_rtnl_route_set_lifetime(struct l_rtnl_route *rt, uint32_t lt,
+				uint64_t reference_time);
 uint32_t l_rtnl_route_get_mtu(const struct l_rtnl_route *rt);
 bool l_rtnl_route_set_mtu(struct l_rtnl_route *rt, uint32_t mtu);
 uint8_t l_rtnl_route_get_preference(const struct l_rtnl_route *rt);
-- =

2.32.0

--===============5738601059009263513==--

