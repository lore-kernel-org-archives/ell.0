Content-Type: multipart/mixed; boundary="===============7873411325004915804=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 14/17] netconfig: Ratelimit route lifetime updates
Date: Fri, 13 May 2022 16:55:07 +0200
Message-ID: <20220513145510.1408510-14-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============7873411325004915804==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Optimize away prefix route updates when the expiry time is far enough
in the future that we expect to receive at least 10 Router
Advertisements before then.  For that purpose start keeping an extra
record for each route where we save the last time this route was
included in an RA and the maximum interval between two RAs with this
route seen so far.  By working with the maximum intervals we avoid
worrying about different RA content policies where some routes may be
skipped in some RAs and there even might be multiple routers sending
RAs with subsets of the same prefixes.

This new mechanism can be made configurable if desired but it's always
enabled for now.
---
There's some renaming in this patch that makes it much bigger.

 ell/netconfig.c | 183 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 122 insertions(+), 61 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 6e6f199..023bcc3 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -79,6 +79,7 @@ struct l_netconfig {
 	struct l_icmp6_client *icmp6_client;
 	struct l_dhcp6_client *dhcp6_client;
 	struct l_idle *signal_expired_work;
+	struct l_queue *icmp_route_data;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -116,6 +117,13 @@ struct l_netconfig {
 	} handler;
 };
 =

+struct netconfig_route_data {
+	struct l_rtnl_route *route;
+	uint64_t last_ra_time;
+	uint64_t kernel_expiry;
+	uint64_t max_ra_interval;
+};
+
 union netconfig_addr {
 	struct in_addr v4;
 	struct in6_addr v6;
@@ -642,10 +650,9 @@ static uint64_t now;
 static bool netconfig_check_route_expired(void *data, void *user_data)
 {
 	struct l_netconfig *nc =3D user_data;
-	struct l_rtnl_route *route =3D data;
-	uint64_t expiry_time =3D l_rtnl_route_get_expiry(route);
+	struct netconfig_route_data *rd =3D data;
 =

-	if (!expiry_time || now < expiry_time)
+	if (!rd->kernel_expiry || now < rd->kernel_expiry)
 		return false;
 =

 	/*
@@ -659,11 +666,12 @@ static bool netconfig_check_route_expired(void *data,=
 void *user_data)
 	 * If for some reason the route is still on the added list, drop it
 	 * from there and there's nothing to notify the user of.
 	 */
-	if (!l_queue_remove(nc->routes.added, route))
-		l_queue_push_tail(nc->routes.expired, route);
+	if (!l_queue_remove(nc->routes.added, rd->route))
+		l_queue_push_tail(nc->routes.expired, rd->route);
 =

-	l_queue_remove(nc->routes.updated, route);
-	l_queue_remove(nc->routes.removed, route);
+	l_queue_remove(nc->routes.current, rd->route);
+	l_queue_remove(nc->routes.updated, rd->route);
+	l_queue_remove(nc->routes.removed, rd->route);
 	return true;
 }
 =

@@ -671,7 +679,7 @@ static void netconfig_expire_routes(struct l_netconfig =
*nc)
 {
 	now =3D l_time_now();
 =

-	if (l_queue_foreach_remove(nc->routes.current,
+	if (l_queue_foreach_remove(nc->icmp_route_data,
 					netconfig_check_route_expired, nc) &&
 			!l_queue_isempty(nc->routes.expired) &&
 			!nc->signal_expired_work)
@@ -680,31 +688,27 @@ static void netconfig_expire_routes(struct l_netconfi=
g *nc)
 						nc, NULL);
 }
 =

-static struct l_rtnl_route *netconfig_find_icmp6_route(
+static struct netconfig_route_data *netconfig_find_icmp6_route(
 						struct l_netconfig *nc,
 						const uint8_t *gateway,
 						const struct route_info *dst)
 {
 	const struct l_queue_entry *entry;
 =

-	for (entry =3D l_queue_get_entries(nc->routes.current); entry;
+	for (entry =3D l_queue_get_entries(nc->icmp_route_data); entry;
 			entry =3D entry->next) {
-		struct l_rtnl_route *route =3D entry->data;
+		struct netconfig_route_data *rd =3D entry->data;
 		const uint8_t *route_gateway;
 		const uint8_t *route_dst;
 		uint8_t route_prefix_len =3D 0;
 =

-		if (l_rtnl_route_get_family(route) !=3D AF_INET6 ||
-				l_rtnl_route_get_protocol(route) !=3D RTPROT_RA)
-			continue;
-
-		route_gateway =3D l_rtnl_route_get_gateway_in_addr(route);
+		route_gateway =3D l_rtnl_route_get_gateway_in_addr(rd->route);
 		if ((gateway || route_gateway) &&
 				(!gateway || !route_gateway ||
 				 memcmp(gateway, route_gateway, 16)))
 			continue;
 =

-		route_dst =3D l_rtnl_route_get_dst_in_addr(route,
+		route_dst =3D l_rtnl_route_get_dst_in_addr(rd->route,
 							&route_prefix_len);
 		if ((dst || route_prefix_len) &&
 				(!dst || !route_prefix_len ||
@@ -712,17 +716,19 @@ static struct l_rtnl_route *netconfig_find_icmp6_rout=
e(
 				 memcmp(dst->address, route_dst, 16)))
 			continue;
 =

-		return route;
+		return rd;
 	}
 =

 	return NULL;
 }
 =

-static struct l_rtnl_route *netconfig_add_icmp6_route(struct l_netconfig *=
nc,
+static struct netconfig_route_data *netconfig_add_icmp6_route(
+						struct l_netconfig *nc,
 						const uint8_t *gateway,
 						const struct route_info *dst,
 						uint8_t preference)
 {
+	struct netconfig_route_data *rd;
 	struct l_rtnl_route *rt;
 =

 	rt =3D netconfig_route_new(nc, AF_INET6, dst->address, dst->prefix_len,
@@ -733,25 +739,73 @@ static struct l_rtnl_route *netconfig_add_icmp6_route=
(struct l_netconfig *nc,
 	l_rtnl_route_set_preference(rt, preference);
 	l_queue_push_tail(nc->routes.current, rt);
 	l_queue_push_tail(nc->routes.added, rt);
-	return rt;
+
+	rd =3D l_new(struct netconfig_route_data, 1);
+	rd->route =3D rt;
+	l_queue_push_tail(nc->icmp_route_data, rd);
+	return rd;
+}
+
+static bool netconfig_check_route_need_update(
+					const struct netconfig_route_data *rd,
+					const struct l_icmp6_router *ra,
+					uint64_t new_expiry,
+					uint64_t old_expiry)
+{
+	/*
+	 * Decide whether the route is close enough to its expiry time that,
+	 * based on the expected Router Advertisement frequency, we should
+	 * notify the user and have them update the route's lifetime in the
+	 * kernel.  This is an optimization to avoid triggering a syscall and
+	 * potentially multiple context-switches in case we expect to have
+	 * many more opportunities to update the lifetime before we even get
+	 * close to the last expiry time we passed to the kernel.  Without
+	 * this we might be wasting a lot of cycles over time if the RAs are
+	 * frequent.
+	 *
+	 * Always update if we have no RA interval information or if the
+	 * expiry is moved forward.
+	 */
+	if (!rd->max_ra_interval || new_expiry < rd->kernel_expiry)
+		return true;
+
+	return rd->kernel_expiry < ra->start_time + rd->max_ra_interval * 10;
 }
 =

 static void netconfig_set_icmp6_route_data(struct l_netconfig *nc,
-						struct l_rtnl_route *rt,
-						uint64_t start_time,
+						struct netconfig_route_data *rd,
+						const struct l_icmp6_router *ra,
 						uint32_t preferred_lifetime,
 						uint32_t valid_lifetime,
 						uint32_t mtu, bool updated)
 {
-	uint64_t expiry =3D start_time + valid_lifetime * L_USEC_PER_SEC;
-	uint64_t old_expiry =3D l_rtnl_route_get_expiry(rt);
+	uint64_t expiry =3D ra->start_time + valid_lifetime * L_USEC_PER_SEC;
+	uint64_t old_expiry =3D l_rtnl_route_get_expiry(rd->route);
 	bool differs =3D false;
 =

-	if (mtu !=3D l_rtnl_route_get_mtu(rt)) {
-		l_rtnl_route_set_mtu(rt, mtu);
+	if (mtu !=3D l_rtnl_route_get_mtu(rd->route)) {
+		l_rtnl_route_set_mtu(rd->route, mtu);
 		differs =3D true;
 	}
 =

+	/*
+	 * The route's lifetime is pretty useless on its own but keep it
+	 * updated with the value from the last RA.  Routers can send the same
+	 * lifetime in every RA, keep decreasing the lifetimes linearly or
+	 * implement any other policy, regardless of whether the resulting
+	 * expiry time varies or not.
+	 */
+	l_rtnl_route_set_lifetime(rd->route, valid_lifetime);
+
+	if (rd->last_ra_time) {
+		uint64_t interval =3D ra->start_time - rd->last_ra_time;
+
+		if (interval > rd->max_ra_interval)
+			rd->max_ra_interval =3D interval;
+	}
+
+	rd->last_ra_time =3D ra->start_time;
+
 	/*
 	 * valid_lifetime of 0 from a route_info means the route is being
 	 * removed so we wouldn't be here.  valid_lifetime of 0xffffffff
@@ -772,23 +826,29 @@ static void netconfig_set_icmp6_route_data(struct l_n=
etconfig *nc,
 	if ((expiry || old_expiry) &&
 			(!expiry || !old_expiry ||
 			 l_time_diff(expiry, old_expiry) > L_USEC_PER_SEC)) {
-		l_rtnl_route_set_lifetime(rt, valid_lifetime);
-		l_rtnl_route_set_expiry(rt, expiry);
-		differs =3D true;
+		l_rtnl_route_set_expiry(rd->route, expiry);
+
+		differs =3D differs || !expiry || !old_expiry ||
+			netconfig_check_route_need_update(rd, ra,
+							expiry, old_expiry);
 	}
 =

-	if (updated && differs && !netconfig_route_exists(nc->routes.added, rt))
-		l_queue_push_tail(nc->routes.updated, rt);
+	if (updated && differs && !netconfig_route_exists(nc->routes.added,
+								rd->route)) {
+		l_queue_push_tail(nc->routes.updated, rd->route);
+		rd->kernel_expiry =3D expiry;
+	}
 }
 =

 static void netconfig_remove_icmp6_route(struct l_netconfig *nc,
-						struct l_rtnl_route *route)
+						struct netconfig_route_data *rd)
 {
-	l_queue_remove(nc->routes.current, route);
-	l_queue_remove(nc->routes.updated, route);
+	l_queue_remove(nc->icmp_route_data, rd);
+	l_queue_remove(nc->routes.current, rd->route);
+	l_queue_remove(nc->routes.updated, rd->route);
 =

-	if (!l_queue_remove(nc->routes.added, route))
-		l_queue_push_tail(nc->routes.removed, route);
+	if (!l_queue_remove(nc->routes.added, rd->route))
+		l_queue_push_tail(nc->routes.removed, rd->route);
 }
 =

 static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
@@ -798,7 +858,7 @@ static void netconfig_icmp6_event_handler(struct l_icmp=
6_client *client,
 {
 	struct l_netconfig *nc =3D user_data;
 	const struct l_icmp6_router *r;
-	struct l_rtnl_route *default_route;
+	struct netconfig_route_data *default_rd;
 	unsigned int i;
 =

 	if (event !=3D L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
@@ -818,12 +878,12 @@ static void netconfig_icmp6_event_handler(struct l_ic=
mp6_client *client,
 	netconfig_expire_routes(nc);
 =

 	/* Process the default gateway information */
-	default_route =3D netconfig_find_icmp6_route(nc, r->address, NULL);
+	default_rd =3D netconfig_find_icmp6_route(nc, r->address, NULL);
 =

-	if (!default_route && r->lifetime) {
-		default_route =3D netconfig_add_icmp6_route(nc, r->address, NULL,
+	if (!default_rd && r->lifetime) {
+		default_rd =3D netconfig_add_icmp6_route(nc, r->address, NULL,
 								r->pref);
-		if (unlikely(!default_route))
+		if (unlikely(!default_rd))
 			return;
 =

 		/*
@@ -831,15 +891,13 @@ static void netconfig_icmp6_event_handler(struct l_ic=
mp6_client *client,
 		 * confused for the special 0xffffffff value in
 		 * netconfig_set_icmp6_route_data.
 		 */
-		netconfig_set_icmp6_route_data(nc, default_route, r->start_time,
-						r->lifetime, r->lifetime,
-						r->mtu, false);
-	} else if (default_route && r->lifetime)
-		netconfig_set_icmp6_route_data(nc, default_route, r->start_time,
-						r->lifetime, r->lifetime,
-						r->mtu, true);
-	else if (default_route && !r->lifetime)
-		netconfig_remove_icmp6_route(nc, default_route);
+		netconfig_set_icmp6_route_data(nc, default_rd, r, r->lifetime,
+						r->lifetime, r->mtu, false);
+	} else if (default_rd && r->lifetime)
+		netconfig_set_icmp6_route_data(nc, default_rd, r, r->lifetime,
+						r->lifetime, r->mtu, true);
+	else if (default_rd && !r->lifetime)
+		netconfig_remove_icmp6_route(nc, default_rd);
 =

 	/*
 	 * Process the onlink and offlink routes, from the Router
@@ -849,26 +907,26 @@ static void netconfig_icmp6_event_handler(struct l_ic=
mp6_client *client,
 	for (i =3D 0; i < r->n_routes; i++) {
 		const struct route_info *info =3D &r->routes[i];
 		const uint8_t *gateway =3D info->onlink ? NULL : r->address;
-		struct l_rtnl_route *route =3D
+		struct netconfig_route_data *rd =3D
 			netconfig_find_icmp6_route(nc, gateway, info);
 =

-		if (!route && info->valid_lifetime) {
-			route =3D netconfig_add_icmp6_route(nc, gateway, info,
+		if (!rd && info->valid_lifetime) {
+			rd =3D netconfig_add_icmp6_route(nc, gateway, info,
 							info->preference);
-			if (unlikely(!route))
+			if (unlikely(!rd))
 				continue;
 =

-			netconfig_set_icmp6_route_data(nc, route, r->start_time,
+			netconfig_set_icmp6_route_data(nc, rd, r,
 						info->preferred_lifetime,
 						info->valid_lifetime,
 						gateway ? r->mtu : 0, false);
-		} else if (route && info->valid_lifetime)
-			netconfig_set_icmp6_route_data(nc, route, r->start_time,
+		} else if (rd && info->valid_lifetime)
+			netconfig_set_icmp6_route_data(nc, rd, r,
 						info->preferred_lifetime,
 						info->valid_lifetime,
 						gateway ? r->mtu : 0, true);
-		else if (route && !info->valid_lifetime)
-			netconfig_remove_icmp6_route(nc, route);
+		else if (rd && !info->valid_lifetime)
+			netconfig_remove_icmp6_route(nc, rd);
 	}
 =

 	/*
@@ -933,6 +991,7 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t=
 ifindex)
 	nc->routes.added =3D l_queue_new();
 	nc->routes.updated =3D l_queue_new();
 	nc->routes.removed =3D l_queue_new();
+	nc->icmp_route_data =3D l_queue_new();
 =

 	nc->dhcp_client =3D l_dhcp_client_new(ifindex);
 	l_dhcp_client_set_event_handler(nc->dhcp_client,
@@ -982,6 +1041,7 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig=
 *netconfig)
 	l_queue_destroy(netconfig->routes.added, NULL);
 	l_queue_destroy(netconfig->routes.updated, NULL);
 	l_queue_destroy(netconfig->routes.removed, NULL);
+	l_queue_destroy(netconfig->icmp_route_data, NULL);
 	l_free(netconfig);
 =

 	rtnl_use_count--;
@@ -1518,10 +1578,11 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig=
 *netconfig)
 	netconfig_addr_wait_unregister(netconfig, false);
 =

 	netconfig_update_cleanup(netconfig);
-	l_queue_clear(netconfig->routes.current,
-			(l_queue_destroy_func_t) l_rtnl_route_free);
 	l_queue_clear(netconfig->addresses.current,
 			(l_queue_destroy_func_t) l_rtnl_address_free);
+	l_queue_clear(netconfig->routes.current,
+			(l_queue_destroy_func_t) l_rtnl_route_free);
+	l_queue_clear(netconfig->icmp_route_data, l_free);
 	netconfig->v4_address =3D NULL;
 	netconfig->v4_subnet_route =3D NULL;
 	netconfig->v4_default_route =3D NULL;
-- =

2.32.0

--===============7873411325004915804==--

