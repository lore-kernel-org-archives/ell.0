Content-Type: multipart/mixed; boundary="===============7872555254877173343=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 05/12] netconfig: Create routes from Router Advertisements
Date: Thu, 21 Apr 2022 17:45:18 +0200
Message-ID: <20220421154525.1416984-5-andrew.zaborowski@intel.com>
In-Reply-To: 20220421154525.1416984-1-andrew.zaborowski@intel.com

--===============7872555254877173343==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If IPv6 is enabled, create the ICMP6 client and handle Router
Advertisements received by creating, updating and removing routes per
the data in the Router Advertisements.  Timeouts aren't handled yet.
---
 ell/netconfig.c | 208 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 206 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 53df690..fd4de2c 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -27,12 +27,16 @@
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
 #include "queue.h"
@@ -63,6 +67,8 @@ struct l_netconfig {
 	bool v4_configured;
 	struct l_dhcp_client *dhcp_client;
 	bool v6_configured;
+	struct l_icmp6_client *icmp6_client;
+	struct l_dhcp6_client *dhcp6_client;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -351,6 +357,189 @@ static void netconfig_dhcp_event_handler(struct l_dhc=
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
+				 memcmp(dst->address, route_dst,
+					 (dst->prefix_len + 7) / 8)))
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
+	char buf1[INET6_ADDRSTRLEN];
+	char buf2[INET6_ADDRSTRLEN];
+
+	if (gateway && !dst)
+		rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, gateway,
+							buf1, sizeof(buf1)));
+	else if (dst && !gateway)
+		rt =3D l_rtnl_route_new_prefix(inet_ntop(AF_INET6, dst->address,
+							buf2, sizeof(buf2)),
+						dst->prefix_len);
+	else
+		rt =3D l_rtnl_route_new_static(inet_ntop(AF_INET6, gateway,
+							buf1, sizeof(buf1)),
+						inet_ntop(AF_INET6,
+							dst->address,
+							buf2, sizeof(buf2)),
+						dst->prefix_len);
+
+	if (L_WARN_ON(!rt))
+		return NULL;
+
+	l_rtnl_route_set_preference(rt, preference);
+	l_rtnl_route_set_protocol(rt, RTPROT_RA);
+	l_rtnl_route_set_priority(rt, nc->route_priority);
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
+
+	l_rtnl_route_set_mtu(rt, mtu);
+	l_rtnl_route_set_lifetime(rt, valid_lifetime);
+	l_rtnl_route_set_expiry(rt, expiry);
+
+	if (updated)
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
@@ -373,6 +562,13 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_=
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

@@ -393,6 +589,7 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig =
*netconfig)
 	l_netconfig_set_domain_names_override(netconfig, AF_INET6, NULL);
 =

 	l_dhcp_client_destroy(netconfig->dhcp_client);
+	l_dhcp6_client_destroy(netconfig->dhcp6_client);
 	l_netconfig_set_event_handler(netconfig, NULL, NULL, NULL);
 	l_queue_destroy(netconfig->addresses.current, NULL);
 	l_queue_destroy(netconfig->addresses.added, NULL);
@@ -835,16 +1032,22 @@ configure_ipv6:
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
+		return false;
+
 done:
 	netconfig->started =3D true;
 	return true;
@@ -871,6 +1074,7 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *n=
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

--===============7872555254877173343==--

