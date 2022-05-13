Content-Type: multipart/mixed; boundary="===============6392206425462263480=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/17] netconfig: Expire addresses and routes
Date: Fri, 13 May 2022 16:55:01 +0200
Message-ID: <20220513145510.1408510-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============6392206425462263480==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Start differentiating between routes/addresses being removed and those
expiring.  Generally if we're committing the routes through RTNL, the
lifetimes are submitted to the kernel and the kernel should expire them
for us on the kernel side.  In that case there's no need to send an
RTM_DELROUTE/RTM_DELADDR.  That should apply to routes received in
Router Advertisements as well as addresses and routes from expiring DHCP
leases and DHCPv6 leases.

For routes/addresses being removed because a router is going offline and
signals that by setting the lifetime to 0 in an RA, or as a result of
L_DHCP_CLIENT_EVENT_IP_CHANGED and similar, us or the user do need to
send RTM_DELROUTE/RTM_DELADDR.  To differentiate between the two cases
(removal and expiry) pass two separate lists to the user.

Add checks for expired IPv6 routes in the ICMPv6 event handler to avoid
using timers for that.  We have no bound on the number of routes (yet)
so we avoid keeping potentially many timers or keeping one timer
tracking multiple expiry times which would add a little complexity (but
might be acceptable.)
---
 ell/netconfig.c | 166 ++++++++++++++++++++++++++++++++++++++++++------
 ell/netconfig.h |   6 +-
 2 files changed, 152 insertions(+), 20 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 724cb38..e915a12 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -71,6 +71,7 @@ struct l_netconfig {
 	bool v6_configured;
 	struct l_icmp6_client *icmp6_client;
 	struct l_dhcp6_client *dhcp6_client;
+	struct l_idle *signal_expired_work;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -91,10 +92,14 @@ struct l_netconfig {
 		 * for example those that only have their lifetime updated.
 		 *
 		 * Any entries in @added and @updated are owned by @current.
+		 * Entries in @removed need to be removed with an
+		 * RTM_DELADD/RTM_DELROUTE while those in @expired are only
+		 * informative as the kernel will have removed them already.
 		 */
 		struct l_queue *added;
 		struct l_queue *updated;
 		struct l_queue *removed;
+		struct l_queue *expired;
 	} addresses, routes;
 =

 	struct {
@@ -115,10 +120,14 @@ static void netconfig_update_cleanup(struct l_netconf=
ig *nc)
 	l_queue_clear(nc->addresses.updated, NULL);
 	l_queue_clear(nc->addresses.removed,
 			(l_queue_destroy_func_t) l_rtnl_address_free);
+	l_queue_clear(nc->addresses.expired,
+			(l_queue_destroy_func_t) l_rtnl_address_free);
 	l_queue_clear(nc->routes.added, NULL);
 	l_queue_clear(nc->routes.updated, NULL);
 	l_queue_clear(nc->routes.removed,
 			(l_queue_destroy_func_t) l_rtnl_route_free);
+	l_queue_clear(nc->routes.expired,
+			(l_queue_destroy_func_t) l_rtnl_route_free);
 }
 =

 static void netconfig_emit_event(struct l_netconfig *nc, uint8_t family,
@@ -162,6 +171,24 @@ static struct l_rtnl_route *netconfig_route_new(struct=
 l_netconfig *nc,
 	return rt;
 }
 =

+static void netconfig_signal_expired(struct l_idle *idle, void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	l_idle_remove(l_steal_ptr(nc->signal_expired_work));
+
+	/*
+	 * If the idle work was scheduled from within l_netconfig_get_routes
+	 * or netconfig_icmp6_event_handler, the user is likely to have
+	 * already received an event and had a chance to process the expired
+	 * routes list.  In that case there's no need to emit a new event,
+	 * and the list will have been emptied in netconfig_update_cleanup()
+	 * anyway.
+	 */
+	if (!l_queue_isempty(nc->routes.expired))
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
+}
+
 static void netconfig_add_v4_routes(struct l_netconfig *nc, const char *ip,
 					uint8_t prefix_len, const char *gateway,
 					uint8_t rtm_protocol)
@@ -237,6 +264,19 @@ static void netconfig_add_v6_static_routes(struct l_ne=
tconfig *nc,
 	l_queue_push_tail(nc->routes.added, v6_default_route);
 }
 =

+static bool netconfig_address_exists(struct l_queue *list,
+					const struct l_rtnl_address *address)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(list); entry;
+			entry =3D entry->next)
+		if ((const struct l_rtnl_address *) entry->data =3D=3D address)
+			return true;
+
+	return false;
+}
+
 static bool netconfig_route_exists(struct l_queue *list,
 					const struct l_rtnl_route *route)
 {
@@ -293,13 +333,15 @@ static void netconfig_set_dhcp_lifetimes(struct l_net=
config *nc, bool updated)
 	l_rtnl_address_set_lifetimes(nc->v4_address, 0, lifetime);
 	l_rtnl_address_set_expiry(nc->v4_address, 0, expiry);
 =

-	if (updated)
+	if (updated && !netconfig_address_exists(nc->addresses.added,
+							nc->v4_address))
 		l_queue_push_tail(nc->addresses.updated, nc->v4_address);
 =

 	l_rtnl_route_set_lifetime(nc->v4_subnet_route, lifetime);
 	l_rtnl_route_set_expiry(nc->v4_subnet_route, expiry);
 =

-	if (updated)
+	if (updated && !netconfig_route_exists(nc->routes.added,
+						nc->v4_subnet_route))
 		l_queue_push_tail(nc->routes.updated, nc->v4_subnet_route);
 =

 	if (!nc->v4_default_route)
@@ -308,23 +350,42 @@ static void netconfig_set_dhcp_lifetimes(struct l_net=
config *nc, bool updated)
 	l_rtnl_route_set_lifetime(nc->v4_default_route, lifetime);
 	l_rtnl_route_set_expiry(nc->v4_default_route, expiry);
 =

-	if (updated)
+	if (updated && !netconfig_route_exists(nc->routes.added,
+						nc->v4_default_route))
 		l_queue_push_tail(nc->routes.updated, nc->v4_default_route);
 }
 =

-static void netconfig_remove_dhcp_address_routes(struct l_netconfig *nc)
+static void netconfig_remove_dhcp_address_routes(struct l_netconfig *nc,
+							bool expired)
 {
+	struct l_queue *routes =3D
+		expired ? nc->routes.expired : nc->routes.removed;
+
 	l_queue_remove(nc->addresses.current, nc->v4_address);
-	l_queue_push_tail(nc->addresses.removed, nc->v4_address);
+	l_queue_remove(nc->addresses.updated, nc->v4_address);
+
+	if (!l_queue_remove(nc->addresses.added, nc->v4_address))
+		l_queue_push_tail(
+			expired ? nc->addresses.expired : nc->addresses.removed,
+			nc->v4_address);
+
 	nc->v4_address =3D NULL;
 =

 	l_queue_remove(nc->routes.current, nc->v4_subnet_route);
-	l_queue_push_tail(nc->routes.removed, nc->v4_subnet_route);
+	l_queue_remove(nc->routes.updated, nc->v4_subnet_route);
+
+	if (!l_queue_remove(nc->routes.added, nc->v4_subnet_route))
+		l_queue_push_tail(routes, nc->v4_subnet_route);
+
 	nc->v4_subnet_route =3D NULL;
 =

 	if (nc->v4_default_route) {
 		l_queue_remove(nc->routes.current, nc->v4_default_route);
-		l_queue_push_tail(nc->routes.removed, nc->v4_default_route);
+		l_queue_remove(nc->routes.updated, nc->v4_default_route);
+
+		if (!l_queue_remove(nc->routes.added, nc->v4_default_route))
+			l_queue_push_tail(routes, nc->v4_default_route);
+
 		nc->v4_default_route =3D NULL;
 	}
 }
@@ -340,7 +401,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_=
client *client,
 		if (L_WARN_ON(!nc->v4_configured))
 			break;
 =

-		netconfig_remove_dhcp_address_routes(nc);
+		netconfig_remove_dhcp_address_routes(nc, false);
 		netconfig_add_dhcp_address_routes(nc);
 		netconfig_set_dhcp_lifetimes(nc, false);
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATE);
@@ -365,7 +426,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_=
client *client,
 		if (L_WARN_ON(!nc->v4_configured))
 			break;
 =

-		netconfig_remove_dhcp_address_routes(nc);
+		netconfig_remove_dhcp_address_routes(nc, true);
 		nc->v4_configured =3D false;
 =

 		if (l_dhcp_client_start(nc->dhcp_client))
@@ -446,14 +507,21 @@ static void netconfig_set_dhcp6_address_lifetimes(str=
uct l_netconfig *nc,
 					start_time + p * L_USEC_PER_SEC,
 					start_time + v * L_USEC_PER_SEC);
 =

-	if (updated)
+	if (updated && !netconfig_address_exists(nc->addresses.added,
+							nc->v6_address))
 		l_queue_push_tail(nc->addresses.updated, nc->v6_address);
 }
 =

-static void netconfig_remove_dhcp6_address(struct l_netconfig *nc)
+static void netconfig_remove_dhcp6_address(struct l_netconfig *nc, bool ex=
pired)
 {
 	l_queue_remove(nc->addresses.current, nc->v6_address);
-	l_queue_push_tail(nc->addresses.removed, nc->v6_address);
+	l_queue_remove(nc->addresses.updated, nc->v6_address);
+
+	if (!l_queue_remove(nc->addresses.added, nc->v6_address))
+		l_queue_push_tail(
+			expired ? nc->addresses.expired : nc->addresses.removed,
+			nc->v6_address);
+
 	nc->v6_address =3D NULL;
 }
 =

@@ -477,7 +545,7 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp=
6_client *client,
 		if (L_WARN_ON(!nc->v6_configured))
 			break;
 =

-		netconfig_remove_dhcp6_address(nc);
+		netconfig_remove_dhcp6_address(nc, false);
 		netconfig_add_dhcp6_address(nc);
 		netconfig_set_dhcp6_address_lifetimes(nc, false);
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
@@ -486,7 +554,7 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp=
6_client *client,
 		if (L_WARN_ON(!nc->v6_configured))
 			break;
 =

-		netconfig_remove_dhcp6_address(nc);
+		netconfig_remove_dhcp6_address(nc, true);
 		nc->v6_configured =3D false;
 =

 		if (l_dhcp6_client_start(nc->dhcp6_client))
@@ -525,6 +593,49 @@ static void netconfig_dhcp6_event_handler(struct l_dhc=
p6_client *client,
 	}
 }
 =

+static uint64_t now;
+
+static bool netconfig_check_route_expired(void *data, void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+	struct l_rtnl_route *route =3D data;
+	uint64_t expiry_time =3D l_rtnl_route_get_expiry(route);
+
+	if (!expiry_time || now < expiry_time)
+		return false;
+
+	/*
+	 * Since we set lifetimes on the routes we submit to the kernel with
+	 * RTM_NEWROUTE, we count on them being deleted automatically so no
+	 * need to send an RTM_DELROUTE.  We signal the fact that the route
+	 * expired to the user by having it on the expired list but there's
+	 * nothing that the user needs to do with the routes on that list
+	 * like they do with the added, updated and removed lists.
+	 *
+	 * If for some reason the route is still on the added list, drop it
+	 * from there and there's nothing to notify the user of.
+	 */
+	if (!l_queue_remove(nc->routes.added, route))
+		l_queue_push_tail(nc->routes.expired, route);
+
+	l_queue_remove(nc->routes.updated, route);
+	l_queue_remove(nc->routes.removed, route);
+	return true;
+}
+
+static void netconfig_expire_routes(struct l_netconfig *nc)
+{
+	now =3D l_time_now();
+
+	if (l_queue_foreach_remove(nc->routes.current,
+					netconfig_check_route_expired, nc) &&
+			!l_queue_isempty(nc->routes.expired) &&
+			!nc->signal_expired_work)
+		nc->signal_expired_work =3D l_idle_create(
+						netconfig_signal_expired,
+						nc, NULL);
+}
+
 static struct l_rtnl_route *netconfig_find_icmp6_route(
 						struct l_netconfig *nc,
 						const uint8_t *gateway,
@@ -630,7 +741,10 @@ static void netconfig_remove_icmp6_route(struct l_netc=
onfig *nc,
 						struct l_rtnl_route *route)
 {
 	l_queue_remove(nc->routes.current, route);
-	l_queue_push_tail(nc->routes.removed, route);
+	l_queue_remove(nc->routes.updated, route);
+
+	if (!l_queue_remove(nc->routes.added, route))
+		l_queue_push_tail(nc->routes.removed, route);
 }
 =

 static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
@@ -657,6 +771,8 @@ static void netconfig_icmp6_event_handler(struct l_icmp=
6_client *client,
 	if (nc->v4_gateway_override)
 		return;
 =

+	netconfig_expire_routes(nc);
+
 	/* Process the default gateway information */
 	default_route =3D netconfig_find_icmp6_route(nc, r->address, NULL);
 =

@@ -719,7 +835,8 @@ static void netconfig_icmp6_event_handler(struct l_icmp=
6_client *client,
 	 */
 	if (!l_queue_isempty(nc->routes.added) ||
 			!l_queue_isempty(nc->routes.updated) ||
-			!l_queue_isempty(nc->routes.removed))
+			!l_queue_isempty(nc->routes.removed) ||
+			!l_queue_isempty(nc->routes.expired))
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 }
 =

@@ -1156,6 +1273,9 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *=
netconfig)
 	if (netconfig->do_static_work)
 		l_idle_remove(l_steal_ptr(netconfig->do_static_work));
 =

+	if (netconfig->signal_expired_work)
+		l_idle_remove(l_steal_ptr(netconfig->signal_expired_work));
+
 	netconfig_update_cleanup(netconfig);
 	l_queue_clear(netconfig->routes.current,
 			(l_queue_destroy_func_t) l_rtnl_route_free);
@@ -1236,7 +1356,8 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_ge=
t_addresses(
 					struct l_netconfig *netconfig,
 					const struct l_queue_entry **out_added,
 					const struct l_queue_entry **out_updated,
-					const struct l_queue_entry **out_removed)
+					const struct l_queue_entry **out_removed,
+					const struct l_queue_entry **out_expired)
 {
 	if (out_added)
 		*out_added =3D l_queue_get_entries(netconfig->addresses.added);
@@ -1247,6 +1368,9 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_ge=
t_addresses(
 	if (out_removed)
 		*out_removed =3D l_queue_get_entries(netconfig->addresses.removed);
 =

+	if (out_expired)
+		*out_expired =3D l_queue_get_entries(netconfig->addresses.expired);
+
 	return l_queue_get_entries(netconfig->addresses.current);
 }
 =

@@ -1254,8 +1378,11 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_g=
et_routes(
 					struct l_netconfig *netconfig,
 					const struct l_queue_entry **out_added,
 					const struct l_queue_entry **out_updated,
-					const struct l_queue_entry **out_removed)
+					const struct l_queue_entry **out_removed,
+					const struct l_queue_entry **out_expired)
 {
+	netconfig_expire_routes(netconfig);
+
 	if (out_added)
 		*out_added =3D l_queue_get_entries(netconfig->routes.added);
 =

@@ -1265,5 +1392,8 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_ge=
t_routes(
 	if (out_removed)
 		*out_removed =3D l_queue_get_entries(netconfig->routes.removed);
 =

+	if (out_expired)
+		*out_expired =3D l_queue_get_entries(netconfig->routes.expired);
+
 	return l_queue_get_entries(netconfig->routes.current);
 }
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 874491f..cf11c67 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -86,12 +86,14 @@ const struct l_queue_entry *l_netconfig_get_addresses(
 				struct l_netconfig *netconfig,
 				const struct l_queue_entry **out_added,
 				const struct l_queue_entry **out_updated,
-				const struct l_queue_entry **out_removed);
+				const struct l_queue_entry **out_removed,
+				const struct l_queue_entry **out_expired);
 const struct l_queue_entry *l_netconfig_get_routes(
 				struct l_netconfig *netconfig,
 				const struct l_queue_entry **out_added,
 				const struct l_queue_entry **out_updated,
-				const struct l_queue_entry **out_removed);
+				const struct l_queue_entry **out_removed,
+				const struct l_queue_entry **out_expired);
 =

 #ifdef __cplusplus
 }
-- =

2.32.0

--===============6392206425462263480==--

