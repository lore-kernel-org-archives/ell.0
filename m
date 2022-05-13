Content-Type: multipart/mixed; boundary="===============3709676473505845277=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 04/17] netconfig: Create routes from Router Advertisements
Date: Sat, 14 May 2022 00:47:00 +0200
Message-ID: <20220513224713.1447773-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220513224713.1447773-1-andrew.zaborowski@intel.com

--===============3709676473505845277==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If IPv6 is enabled, create the ICMP6 client and handle Router
Advertisements received by creating, updating and removing routes per
the data in the Router Advertisements.  Timeouts aren't handled yet.
---
 ell/netconfig.c | 293 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 278 insertions(+), 15 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 9375d13..6ad6394 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -27,14 +27,19 @@
 #include <linux/types.h>
 #include <netinet/ip.h>
 #include <arpa/inet.h>
+#include <netinet/icmp6.h>
 =

 #include "private.h"
 #include "useful.h"
 #include "log.h"
 #include "dhcp.h"
 #include "dhcp-private.h"
+#include "icmp6.h"
+#include "icmp6-private.h"
+#include "dhcp6.h"
 #include "netlink.h"
 #include "rtnl.h"
+#include "rtnl-private.h"
 #include "queue.h"
 #include "time.h"
 #include "idle.h"
@@ -64,6 +69,8 @@ struct l_netconfig {
 	bool v4_configured;
 	struct l_dhcp_client *dhcp_client;
 	bool v6_configured;
+	struct l_icmp6_client *icmp6_client;
+	struct l_dhcp6_client *dhcp6_client;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -128,6 +135,33 @@ static void netconfig_emit_event(struct l_netconfig *n=
c, uint8_t family,
 		netconfig_update_cleanup(nc);
 }
 =

+static struct l_rtnl_route *netconfig_route_new(struct l_netconfig *nc,
+						uint8_t family,
+						const void *dst,
+						uint8_t prefix_len,
+						const void *gw,
+						uint8_t protocol)
+{
+	struct l_rtnl_route *rt =3D l_new(struct l_rtnl_route, 1);
+
+	rt->family =3D family;
+	rt->scope =3D (family =3D=3D AF_INET && dst) ?
+		RT_SCOPE_LINK : RT_SCOPE_UNIVERSE;
+	rt->protocol =3D protocol;
+	rt->lifetime =3D 0xffffffff;
+	rt->priority =3D nc->route_priority;
+
+	if (dst) {
+		memcpy(&rt->dst, dst, family =3D=3D AF_INET ? 4 : 16);
+		rt->dst_prefix_len =3D prefix_len;
+	}
+
+	if (gw)
+		memcpy(&rt->gw, gw, family =3D=3D AF_INET ? 4 : 16);
+
+	return rt;
+}
+
 static void netconfig_add_v4_routes(struct l_netconfig *nc, const char *ip,
 					uint8_t prefix_len, const char *gateway,
 					uint8_t rtm_protocol)
@@ -141,12 +175,9 @@ static void netconfig_add_v4_routes(struct l_netconfig=
 *nc, const char *ip,
 		return;
 =

 	in_addr.s_addr &=3D htonl(0xfffffffflu << (32 - prefix_len));
-	if (L_WARN_ON(!inet_ntop(AF_INET, &in_addr, network, INET_ADDRSTRLEN)))
-		return;
-
-	nc->v4_subnet_route =3D l_rtnl_route_new_prefix(network, prefix_len);
-	l_rtnl_route_set_protocol(nc->v4_subnet_route, rtm_protocol);
-	l_rtnl_route_set_priority(nc->v4_subnet_route, nc->route_priority);
+	nc->v4_subnet_route =3D netconfig_route_new(nc, AF_INET, network,
+							prefix_len, NULL,
+							rtm_protocol);
 	l_queue_push_tail(nc->routes.current, nc->v4_subnet_route);
 	l_queue_push_tail(nc->routes.added, nc->v4_subnet_route);
 =

@@ -163,6 +194,7 @@ static void netconfig_add_v4_routes(struct l_netconfig =
*nc, const char *ip,
 	nc->v4_default_route =3D l_rtnl_route_new_gateway(gateway);
 	l_rtnl_route_set_protocol(nc->v4_default_route, rtm_protocol);
 	L_WARN_ON(!l_rtnl_route_set_prefsrc(nc->v4_default_route, ip));
+	l_rtnl_route_set_priority(nc->v4_default_route, nc->route_priority);
 	l_queue_push_tail(nc->routes.current, nc->v4_default_route);
 	l_queue_push_tail(nc->routes.added, nc->v4_default_route);
 }
@@ -173,7 +205,6 @@ static void netconfig_add_v6_static_routes(struct l_net=
config *nc,
 {
 	struct in6_addr in6_addr;
 	const void *prefix;
-	char network[INET6_ADDRSTRLEN];
 	struct l_rtnl_route *v6_subnet_route;
 	struct l_rtnl_route *v6_default_route;
 =

@@ -188,17 +219,13 @@ static void netconfig_add_v6_static_routes(struct l_n=
etconfig *nc,
 	 */
 	prefix =3D net_prefix_from_ipv6(in6_addr.s6_addr, prefix_len);
 =

-	if (L_WARN_ON(!inet_ntop(AF_INET6, prefix, network, INET6_ADDRSTRLEN)))
-		return;
-
 	/*
 	 * One reason we add a subnet route instead of letting the kernel
 	 * do it, by not specifying IFA_F_NOPREFIXROUTE for the address,
 	 * is that that would force a 0 metric for the route.
 	 */
-	v6_subnet_route =3D l_rtnl_route_new_prefix(network, prefix_len);
-	l_rtnl_route_set_protocol(v6_subnet_route, RTPROT_STATIC);
-	l_rtnl_route_set_priority(v6_subnet_route, nc->route_priority);
+	v6_subnet_route =3D netconfig_route_new(nc, AF_INET6, prefix, prefix_len,
+						NULL, RTPROT_STATIC);
 	l_queue_push_tail(nc->routes.current, v6_subnet_route);
 	l_queue_push_tail(nc->routes.added, v6_subnet_route);
 =

@@ -214,6 +241,19 @@ static void netconfig_add_v6_static_routes(struct l_ne=
tconfig *nc,
 	l_queue_push_tail(nc->routes.added, v6_default_route);
 }
 =

+static bool netconfig_route_exists(struct l_queue *list,
+					const struct l_rtnl_route *route)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(list); entry;
+			entry =3D entry->next)
+		if ((const struct l_rtnl_route *) entry->data =3D=3D route)
+			return true;
+
+	return false;
+}
+
 static void netconfig_add_dhcp_address_routes(struct l_netconfig *nc)
 {
 	const struct l_dhcp_lease *lease =3D
@@ -360,6 +400,204 @@ static void netconfig_dhcp_event_handler(struct l_dhc=
p_client *client,
 	}
 }
 =

+static struct l_rtnl_route *netconfig_find_icmp6_route(
+						struct l_netconfig *nc,
+						const uint8_t *gateway,
+						const struct route_info *dst)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(nc->routes.current); entry;
+			entry =3D entry->next) {
+		struct l_rtnl_route *route =3D entry->data;
+		const uint8_t *route_gateway;
+		const uint8_t *route_dst;
+		uint8_t route_prefix_len =3D 0;
+
+		if (l_rtnl_route_get_family(route) !=3D AF_INET6 ||
+				l_rtnl_route_get_protocol(route) !=3D RTPROT_RA)
+			continue;
+
+		route_gateway =3D l_rtnl_route_get_gateway_in_addr(route);
+		if ((gateway || route_gateway) &&
+				(!gateway || !route_gateway ||
+				 memcmp(gateway, route_gateway, 16)))
+			continue;
+
+		route_dst =3D l_rtnl_route_get_dst_in_addr(route,
+							&route_prefix_len);
+		if ((dst || route_prefix_len) &&
+				(!dst || !route_prefix_len ||
+				 dst->prefix_len !=3D route_prefix_len ||
+				 memcmp(dst->address, route_dst, 16)))
+			continue;
+
+		return route;
+	}
+
+	return NULL;
+}
+
+static struct l_rtnl_route *netconfig_add_icmp6_route(struct l_netconfig *=
nc,
+						const uint8_t *gateway,
+						const struct route_info *dst,
+						uint8_t preference)
+{
+	struct l_rtnl_route *rt;
+
+	rt =3D netconfig_route_new(nc, AF_INET6, dst->address, dst->prefix_len,
+					gateway, RTPROT_RA);
+	if (L_WARN_ON(!rt))
+		return NULL;
+
+	l_rtnl_route_set_preference(rt, preference);
+	l_queue_push_tail(nc->routes.current, rt);
+	l_queue_push_tail(nc->routes.added, rt);
+	return rt;
+}
+
+static void netconfig_set_icmp6_route_data(struct l_netconfig *nc,
+						struct l_rtnl_route *rt,
+						uint64_t start_time,
+						uint32_t preferred_lifetime,
+						uint32_t valid_lifetime,
+						uint32_t mtu, bool updated)
+{
+	uint64_t expiry =3D start_time + valid_lifetime * L_USEC_PER_SEC;
+	uint64_t old_expiry =3D l_rtnl_route_get_expiry(rt);
+	bool differs =3D false;
+
+	if (mtu !=3D l_rtnl_route_get_mtu(rt)) {
+		l_rtnl_route_set_mtu(rt, mtu);
+		differs =3D true;
+	}
+
+	/*
+	 * valid_lifetime of 0 from a route_info means the route is being
+	 * removed so we wouldn't be here.  valid_lifetime of 0xffffffff
+	 * means no timeout.  Check if the lifetime is changing between
+	 * finite and infinite, or two finite values that result in expiry
+	 * time difference of more than a second -- to avoid emitting
+	 * updates for changes resulting only from the valid_lifetime one
+	 * second resolution and RA transmission jitter.  As RFC4861
+	 * Section 6.2.7 puts it: "Due to link propagation delays and
+	 * potentially poorly synchronized clocks between the routers such
+	 * comparison SHOULD allow some time skew."  The RFC talks about
+	 * routers processing one another's RAs but the same logic applies
+	 * here.
+	 */
+	if (valid_lifetime =3D=3D 0xffffffff)
+		expiry =3D 0;
+
+	if ((expiry || old_expiry) &&
+			(!expiry || !old_expiry ||
+			 l_time_diff(expiry, old_expiry) > L_USEC_PER_SEC)) {
+		l_rtnl_route_set_lifetime(rt, valid_lifetime);
+		l_rtnl_route_set_expiry(rt, expiry);
+		differs =3D true;
+	}
+
+	if (updated && differs && !netconfig_route_exists(nc->routes.added, rt))
+		l_queue_push_tail(nc->routes.updated, rt);
+}
+
+static void netconfig_remove_icmp6_route(struct l_netconfig *nc,
+						struct l_rtnl_route *route)
+{
+	l_queue_remove(nc->routes.current, route);
+	l_queue_push_tail(nc->routes.removed, route);
+}
+
+static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
+						enum l_icmp6_client_event event,
+						void *event_data,
+						void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+	const struct l_icmp6_router *r;
+	struct l_rtnl_route *default_route;
+	unsigned int i;
+
+	if (event !=3D L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
+		return;
+
+	r =3D event_data;
+
+	/*
+	 * Note: If this is the first RA received, the l_dhcp6_client
+	 * will have received the event before us and will be acting
+	 * on it by now.
+	 */
+
+	if (nc->v4_gateway_override)
+		return;
+
+	/* Process the default gateway information */
+	default_route =3D netconfig_find_icmp6_route(nc, r->address, NULL);
+
+	if (!default_route && r->lifetime) {
+		default_route =3D netconfig_add_icmp6_route(nc, r->address, NULL,
+								r->pref);
+		if (unlikely(!default_route))
+			return;
+
+		/*
+		 * r->lifetime is 16-bit only so there's no risk it gets
+		 * confused for the special 0xffffffff value in
+		 * netconfig_set_icmp6_route_data.
+		 */
+		netconfig_set_icmp6_route_data(nc, default_route, r->start_time,
+						r->lifetime, r->lifetime,
+						r->mtu, false);
+	} else if (default_route && r->lifetime)
+		netconfig_set_icmp6_route_data(nc, default_route, r->start_time,
+						r->lifetime, r->lifetime,
+						r->mtu, true);
+	else if (default_route && !r->lifetime)
+		netconfig_remove_icmp6_route(nc, default_route);
+
+	/*
+	 * Process the onlink and offlink routes, from the Router
+	 * Advertisement's Prefix Information options and Route
+	 * Information options respectively.
+	 */
+	for (i =3D 0; i < r->n_routes; i++) {
+		const struct route_info *info =3D &r->routes[i];
+		const uint8_t *gateway =3D info->onlink ? NULL : r->address;
+		struct l_rtnl_route *route =3D
+			netconfig_find_icmp6_route(nc, gateway, info);
+
+		if (!route && info->valid_lifetime) {
+			route =3D netconfig_add_icmp6_route(nc, gateway, info,
+							info->preference);
+			if (unlikely(!route))
+				continue;
+
+			netconfig_set_icmp6_route_data(nc, route, r->start_time,
+						info->preferred_lifetime,
+						info->valid_lifetime,
+						gateway ? r->mtu : 0, false);
+		} else if (route && info->valid_lifetime)
+			netconfig_set_icmp6_route_data(nc, route, r->start_time,
+						info->preferred_lifetime,
+						info->valid_lifetime,
+						gateway ? r->mtu : 0, true);
+		else if (route && !info->valid_lifetime)
+			netconfig_remove_icmp6_route(nc, route);
+	}
+
+	/*
+	 * Note: we may be emitting this before L_NETCONFIG_EVENT_CONFIGURE.
+	 * We should probably instead save the affected routes in separate
+	 * lists and add them to the _CONFIGURE event, suppressing any _UPDATE
+	 * events while nc->v6_configured is false.
+	 */
+	if (!l_queue_isempty(nc->routes.added) ||
+			!l_queue_isempty(nc->routes.updated) ||
+			!l_queue_isempty(nc->routes.removed))
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
+}
+
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 {
 	struct l_netconfig *nc;
@@ -382,6 +620,13 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_=
t ifindex)
 					netconfig_dhcp_event_handler,
 					nc, NULL);
 =

+	nc->dhcp6_client =3D l_dhcp6_client_new(ifindex);
+
+	nc->icmp6_client =3D l_dhcp6_client_get_icmp6(nc->dhcp6_client);
+	l_icmp6_client_add_event_handler(nc->icmp6_client,
+					netconfig_icmp6_event_handler,
+					nc, NULL);
+
 	return nc;
 }
 =

@@ -402,6 +647,7 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig =
*netconfig)
 	l_netconfig_set_domain_names_override(netconfig, AF_INET6, NULL);
 =

 	l_dhcp_client_destroy(netconfig->dhcp_client);
+	l_dhcp6_client_destroy(netconfig->dhcp6_client);
 	l_netconfig_set_event_handler(netconfig, NULL, NULL, NULL);
 	l_queue_destroy(netconfig->addresses.current, NULL);
 	l_queue_destroy(netconfig->addresses.added, NULL);
@@ -735,19 +981,35 @@ configure_ipv6:
 	if (!netconfig->v6_enabled)
 		goto done;
 =

-	if (netconfig->v6_static_addr && !netconfig->do_static_work) {
+	if (netconfig->v6_static_addr) {
 		/*
 		 * We're basically ready to configure the interface
 		 * but do this in an idle callback.
 		 */
-		netconfig->do_static_work =3D l_idle_create(
+		if (!netconfig->do_static_work)
+			netconfig->do_static_work =3D l_idle_create(
 						netconfig_do_static_config,
 						netconfig, NULL);
+
+		goto done;
 	}
 =

+	if (!l_dhcp6_client_start(netconfig->dhcp6_client))
+		goto stop_ipv4;
+
 done:
 	netconfig->started =3D true;
 	return true;
+
+stop_ipv4:
+	if (netconfig->v4_enabled) {
+		if (netconfig->v4_static_addr)
+			l_idle_remove(l_steal_ptr(netconfig->do_static_work));
+		else
+			l_dhcp_client_stop(netconfig->dhcp_client);
+	}
+
+	return false;
 }
 =

 LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
@@ -771,6 +1033,7 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *n=
etconfig)
 	netconfig->v6_address =3D NULL;
 =

 	l_dhcp_client_stop(netconfig->dhcp_client);
+	l_dhcp6_client_stop(netconfig->dhcp6_client);
 }
 =

 LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhcp_client(
-- =

2.32.0

--===============3709676473505845277==--

