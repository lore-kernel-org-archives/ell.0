Content-Type: multipart/mixed; boundary="===============7822057065312246834=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple RAs
Date: Thu, 06 Jan 2022 16:05:28 +0100
Message-ID: <20220106150529.458775-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220106150529.458775-1-andrew.zaborowski@intel.com

--===============7822057065312246834==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add tracking of default/non-default routers and prefix routes in
separate lists that are updated with new information from new RAs.
This is gets us closer to what RFC4861 mandates.

There's no single client->routes list now, there are two lists, one for
the routers and one for prefix routes.  According to the RFC there's no
relation between the prefix routes and which router's RA they were
received in (same prefixes can be received from multiple routers).

The DHCP6 behaviour should be unchanged for now, it'll still only use
the first router that sent an announcement.  The public API is also
unchnaged for now except for new events.
---
There are some rought corners in this code but the commit is already a
little big.  For example the route_info structure we use for prefix
routes is actually sent to clients in event_data but the structure is
private so it's useless to the clients as is.

Also icmp6 may end up using a lot of timeouts since we have to track
router timeouts and prefix route timeouts.  In this case it would be
pretty easy to convert all those timeouts into one that only tracks the
soonest expiry event so I'd be happy to do that.  We can't really avoid
tracking the lifetimes if we want to correctly implement the RFC.
---
 ell/dhcp6.c         |  15 +-
 ell/icmp6-private.h |  13 ++
 ell/icmp6.c         | 339 ++++++++++++++++++++++++++++++++++++--------
 ell/icmp6.h         |   6 +
 4 files changed, 313 insertions(+), 60 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 40c6f3a..a740bbb 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1471,8 +1471,9 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_c=
lient *icmp6,
 {
 	struct l_dhcp6_client *client =3D user_data;
 =

-	l_timeout_remove(client->timeout_send);
-	client->timeout_send =3D NULL;
+	/* We only process the first RA received for now */
+	if (!client->timeout_send)
+		return;
 =

 	switch (event) {
 	case L_ICMP6_CLIENT_EVENT_ROUTER_FOUND:
@@ -1482,6 +1483,9 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_c=
lient *icmp6,
 		bool managed =3D l_icmp6_router_get_managed(r);
 		bool other =3D l_icmp6_router_get_other(r);
 =

+		l_timeout_remove(client->timeout_send);
+		client->timeout_send =3D NULL;
+
 		CLIENT_DEBUG("Received RA, managed: %s, other: %s",
 				managed ? "yes" : "no",
 				other ? "yes" : "no");
@@ -1498,6 +1502,13 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_=
client *icmp6,
 =

 		break;
 	}
+	case L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_ADDED:
+	case L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED:
+	case L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_CHANGED:
+	case L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_ADDED:
+	case L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVED:
+	case L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_CHANGED:
+		break;
 	}
 }
 =

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index 3846bad..3ad268c 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -20,12 +20,20 @@
  *
  */
 =

+struct l_rtnl_route;
+struct l_timeout;
+struct l_icmp6_client;
+
 struct route_info {
 	uint8_t address[16];
 	uint8_t prefix_len;
 	uint8_t preference;
 	uint32_t preferred_lifetime;
 	uint32_t valid_lifetime;
+	struct l_rtnl_route *route;
+	uint64_t expiry;
+	struct l_timeout *timeout;
+	struct l_icmp6_client *client;
 };
 =

 struct l_icmp6_router {
@@ -37,6 +45,11 @@ struct l_icmp6_router {
 	uint32_t mtu;
 	uint32_t n_prefixes;
 	struct route_info *prefixes;
+	struct l_rtnl_route *default_route;
+	uint64_t default_expiry;
+	struct l_timeout *default_timeout;
+	struct l_icmp6_client *client;
+	uint64_t ra_timestamp;
 };
 =

 struct l_icmp6_router *_icmp6_router_new();
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 6a2d705..f720bc5 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -250,10 +250,10 @@ struct l_icmp6_client {
 	uint64_t retransmit_time;
 	struct l_io *io;
 =

-	struct l_icmp6_router *ra;
+	struct l_queue *routers;
 	struct l_netlink *rtnl;
 	uint32_t route_priority;
-	struct l_queue *routes;
+	struct l_queue *prefix_routes;
 =

 	struct l_queue *event_handlers;
 =

@@ -292,53 +292,242 @@ static bool icmp6_client_remove_route(void *data, vo=
id *user_data)
 	return true;
 }
 =

-static void icmp6_client_setup_routes(struct l_icmp6_client *client)
+static void icmp6_router_timeout(struct l_timeout *timeout, void *user_dat=
a)
 {
-	struct l_icmp6_router *ra =3D client->ra;
-	struct l_rtnl_route *rt;
-	char buf[INET6_ADDRSTRLEN];
-	unsigned int i;
+	struct l_icmp6_router *r =3D user_data;
 =

-	rt =3D l_rtnl_route_new_gateway(inet_ntop(AF_INET6, ra->address,
-							buf, sizeof(buf)));
-	if (!rt) {
-		CLIENT_DEBUG("Unable to parse RA 'from' address");
-		return;
-	}
+	icmp6_client_remove_route(l_steal_ptr(r->default_route), r->client);
+	l_timeout_remove(l_steal_ptr(r->default_timeout));
+	r->default_expiry =3D 0;
 =

-	l_rtnl_route_set_preference(rt, ra->pref);
-	l_rtnl_route_set_protocol(rt, RTPROT_RA);
-	l_rtnl_route_set_mtu(rt, ra->mtu);
-	l_rtnl_route_set_priority(rt, client->route_priority);
-	l_queue_push_tail(client->routes, rt);
+	icmp6_client_event_notify(r->client,
+				L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED, r);
+}
 =

-	if (client->rtnl)
-		l_rtnl_route_add(client->rtnl, client->ifindex, rt,
-					NULL, NULL, NULL);
+static bool icmp6_route_info_free(void *data, void *user_data) {
+	struct route_info *info =3D data;
 =

-	for (i =3D 0; i < ra->n_prefixes; i++) {
-		struct route_info *info =3D &ra->prefixes[i];
+	icmp6_client_remove_route(info->route, info->client);
+	l_timeout_remove(info->timeout);
+	l_free(info);
+	return true;
+}
+
+static void icmp6_prefix_timeout(struct l_timeout *timeout, void *user_dat=
a)
+{
+	struct route_info *info =3D user_data;
 =

-		if (info->valid_lifetime =3D=3D 0)
-			continue;
+	l_queue_remove(info->client->prefix_routes, info);
+	icmp6_client_event_notify(info->client,
+				L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVED,
+				info);
+	icmp6_route_info_free(info, NULL);
+}
 =

-		if (!inet_ntop(AF_INET6, info->address, buf, sizeof(buf)))
-			continue;
+/* Mostly RFC4861 Section 6.3.4 */
+static void icmp6_router_update(struct l_icmp6_client *client,
+				struct l_icmp6_router *r,
+				struct l_icmp6_router *new_ra)
+{
+	bool changed =3D false;
+	enum l_icmp6_client_event event =3D -1;
 =

-		rt =3D l_rtnl_route_new_prefix(buf, info->prefix_len);
-		if (!rt)
-			continue;
+	if (r) {
+		uint64_t new_expiry =3D 0;
 =

-		l_rtnl_route_set_preference(rt, info->preference);
-		l_rtnl_route_set_protocol(rt, RTPROT_RA);
-		l_rtnl_route_set_mtu(rt, ra->mtu);
-		l_rtnl_route_set_priority(rt, client->route_priority);
-		l_queue_push_tail(client->routes, rt);
+		r->lifetime =3D new_ra->lifetime;
 =

+		if (r->lifetime)
+			new_expiry =3D new_ra->ra_timestamp +
+				r->lifetime * L_USEC_PER_SEC;
+
+		if (r->default_expiry !=3D new_expiry) {
+			r->default_expiry =3D new_expiry;
+			changed =3D true;
+		}
+
+		if (new_ra->mtu) {
+			r->mtu =3D new_ra->mtu;
+			changed =3D true;
+		}
+	} else
+		r =3D new_ra;
+
+	if (r->default_route && !r->lifetime) {
+		icmp6_client_remove_route(l_steal_ptr(r->default_route),
+						client);
+		l_timeout_remove(l_steal_ptr(r->default_timeout));
+		r->default_expiry =3D 0;
+
+		event =3D L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED;
+	} else if (!r->default_route && r->lifetime) {
+		char buf[INET6_ADDRSTRLEN];
+
+		if (!inet_ntop(AF_INET6, r->address, buf, sizeof(buf))) {
+			CLIENT_DEBUG("Unable to parse RA 'from' address");
+			return;
+		}
+
+		r->default_route =3D l_rtnl_route_new_gateway(buf);
+		if (!r->default_route) {
+			CLIENT_DEBUG("l_rtnl_route_new_gateway error");
+			return;
+		}
+
+		r->default_timeout =3D l_timeout_create(r->lifetime,
+							icmp6_router_timeout,
+							r, NULL);
+
+		changed =3D true;
+		event =3D L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_ADDED;
+	} else if (r->default_route && changed) {
+		/* No way to update a route other than delete and re-add */
 		if (client->rtnl)
-			l_rtnl_route_add(client->rtnl, client->ifindex, rt,
+			l_rtnl_route_delete(client->rtnl, client->ifindex,
+						r->default_route,
 						NULL, NULL, NULL);
+
+		l_timeout_modify(r->default_timeout, r->lifetime);
+
+		event =3D L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_CHANGED;
 	}
+
+	if (r->default_route && changed) {
+		l_rtnl_route_set_preference(r->default_route, r->pref);
+		l_rtnl_route_set_protocol(r->default_route, RTPROT_RA);
+		l_rtnl_route_set_mtu(r->default_route, r->mtu);
+		l_rtnl_route_set_priority(r->default_route,
+						client->route_priority);
+		l_rtnl_route_set_lifetime(r->default_route, r->lifetime);
+
+		if (client->rtnl)
+			l_rtnl_route_add(client->rtnl, client->ifindex,
+						r->default_route,
+						NULL, NULL, NULL);
+	}
+
+	if (event !=3D (enum l_icmp6_client_event) -1)
+		icmp6_client_event_notify(client, event, r);
+}
+
+/* Mostly RFC4861 Section 6.3.4 */
+static void icmp6_onlink_prefix_update(struct l_icmp6_client *client,
+					struct l_icmp6_router *ra,
+					struct route_info *info,
+					struct route_info *new_info)
+{
+	bool changed =3D false;
+	enum l_icmp6_client_event event =3D -1;
+
+	if (info) {
+		uint64_t new_expiry =3D 0;
+
+		info->valid_lifetime =3D new_info->valid_lifetime;
+
+		if (!L_IN_SET(info->valid_lifetime, 0, 0xffffffff))
+			new_expiry =3D ra->ra_timestamp +
+				info->valid_lifetime * L_USEC_PER_SEC;
+
+		if (info->expiry !=3D new_expiry) {
+			info->expiry =3D new_expiry;
+			changed =3D true;
+		}
+
+		if (info->route && ra->mtu &&
+				l_rtnl_route_get_mtu(info->route) !=3D ra->mtu)
+			changed =3D true;
+	} else
+		info =3D new_info;
+
+	if (info->route && !info->valid_lifetime) {
+		icmp6_client_event_notify(client,
+				L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVED,
+				info);
+		icmp6_route_info_free(info, NULL);
+		return;
+	} else if (!info->route && !info->valid_lifetime) {
+		return;
+	} else if (!info->route && info->valid_lifetime) {
+		char buf[INET6_ADDRSTRLEN];
+
+		info =3D l_memdup(info, sizeof(*info));
+
+		if (!inet_ntop(AF_INET6, info->address, buf, sizeof(buf))) {
+			CLIENT_DEBUG("Unable to parse prefix address");
+			return;
+		}
+
+		info->route =3D l_rtnl_route_new_prefix(buf, info->prefix_len);
+		if (!info->route) {
+			CLIENT_DEBUG("l_rtnl_route_new_prefix error");
+			return;
+		}
+
+		if (info->valid_lifetime !=3D 0xffffffff)
+			info->timeout =3D l_timeout_create(info->valid_lifetime,
+							icmp6_prefix_timeout,
+							info, NULL);
+
+		changed =3D true;
+		event =3D L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_ADDED;
+	} else if (changed) {
+		/* No way to update a route other than delete and re-add */
+		if (client->rtnl)
+			l_rtnl_route_delete(client->rtnl, client->ifindex,
+						info->route, NULL, NULL, NULL);
+
+		if (info->valid_lifetime !=3D 0xffffffff) {
+			if (info->timeout)
+				l_timeout_modify(info->timeout,
+							info->valid_lifetime);
+			else
+				info->timeout =3D l_timeout_create(
+							info->valid_lifetime,
+							icmp6_prefix_timeout,
+							info, NULL);
+		} else
+			l_timeout_remove(l_steal_ptr(info->timeout));
+
+		event =3D L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_CHANGED;
+	}
+
+	info->client =3D client;
+	l_queue_push_head(client->prefix_routes, info);
+
+	if (!changed)
+		return;
+
+	l_rtnl_route_set_preference(info->route, info->preference);
+	l_rtnl_route_set_protocol(info->route, RTPROT_RA);
+	l_rtnl_route_set_mtu(info->route, ra->mtu);
+	l_rtnl_route_set_priority(info->route, client->route_priority);
+
+	if (info->valid_lifetime !=3D 0xffffffff)
+		l_rtnl_route_set_lifetime(info->route,
+						info->valid_lifetime);
+
+	if (client->rtnl)
+		l_rtnl_route_add(client->rtnl, client->ifindex,
+					info->route, NULL, NULL, NULL);
+
+	if (event !=3D (enum l_icmp6_client_event) -1)
+		icmp6_client_event_notify(client, event, info);
+}
+
+static bool icmp6_router_match_address(const void *a, const void *b)
+{
+	const struct l_icmp6_router *r =3D a;
+
+	return !memcmp(r->address, b, 16);
+}
+
+static bool icmp6_route_match_prefix(const void *a, const void *b)
+{
+	const struct route_info *info_a =3D a;
+	const struct route_info *info_b =3D b;
+
+	return info_a->prefix_len =3D=3D info_b->prefix_len &&
+		!memcmp(info_a->address, info_b->address, 16);
 }
 =

 static int icmp6_client_handle_message(struct l_icmp6_client *client,
@@ -347,31 +536,53 @@ static int icmp6_client_handle_message(struct l_icmp6=
_client *client,
 						const struct in6_addr *src)
 {
 	struct l_icmp6_router *r =3D _icmp6_router_parse(ra, len, src->s6_addr);
+	struct l_icmp6_router *old_ra;
+	unsigned int i;
 =

 	if (!r)
 		return -EBADMSG;
 =

-	if (!client->ra) {
-		client->ra =3D r;
+	old_ra =3D l_queue_remove_if(client->routers, icmp6_router_match_address,
+					r->address);
+	if (old_ra) {
+		/* Move to the head of the queue */
+		l_queue_push_head(client->routers, old_ra);
+	} else {
+		r->ra_timestamp =3D l_time_now();
+		r->client =3D client;
+		l_queue_push_head(client->routers, r);
+
 		icmp6_client_event_notify(client,
 					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND,
 					NULL);
 =

 		/* DHCP6 client may have stopped us */
-		if (!client->ra)
+		if (!client->io)
 			return -ECANCELED;
+	}
 =

-		icmp6_client_setup_routes(client);
-		return 0;
+	icmp6_router_update(client, old_ra, r);
+
+	if (!client->io)
+		goto done;
+
+	for (i =3D 0; i < r->n_prefixes; i++) {
+		struct route_info *info =3D &r->prefixes[i];
+		struct route_info *old_info =3D
+			l_queue_remove_if(client->prefix_routes,
+						icmp6_route_match_prefix, info);
+
+		icmp6_onlink_prefix_update(client, r, old_info, info);
+
+		if (!client->io)
+			goto done;
 	}
 =

-	/*
-	 * TODO: Figure out if the RA has updated info and update routes
-	 * accordingly.
-	 */
-	_icmp6_router_free(client->ra);
-	client->ra =3D r;
-	return 0;
+done:
+	if (old_ra)
+		_icmp6_router_free(r);
+
+	return client->io ? -ECANCELED : 0;
 }
 =

 static bool icmp6_client_read_handler(struct l_io *io, void *userdata)
@@ -451,7 +662,8 @@ LIB_EXPORT struct l_icmp6_client *l_icmp6_client_new(ui=
nt32_t ifindex)
 	struct l_icmp6_client *client =3D l_new(struct l_icmp6_client, 1);
 =

 	client->ifindex =3D ifindex;
-	client->routes =3D l_queue_new();
+	client->routers =3D l_queue_new();
+	client->prefix_routes =3D l_queue_new();
 =

 	return client;
 }
@@ -472,9 +684,12 @@ LIB_EXPORT void l_icmp6_client_free(struct l_icmp6_cli=
ent *client)
 		return;
 =

 	l_icmp6_client_stop(client);
-	l_queue_destroy(client->routes, NULL);
 	l_icmp6_client_set_debug(client, NULL, NULL, NULL);
 	l_queue_destroy(client->event_handlers, icmp6_event_handler_destroy);
+
+	l_queue_destroy(client->routers, NULL);
+	l_queue_destroy(client->prefix_routes, NULL);
+
 	l_free(client);
 }
 =

@@ -522,6 +737,12 @@ LIB_EXPORT bool l_icmp6_client_start(struct l_icmp6_cl=
ient *client)
 	return true;
 }
 =

+static bool icmp6_router_free_cb(void *data, void *user_data)
+{
+	_icmp6_router_free(data);
+	return true;
+}
+
 LIB_EXPORT bool l_icmp6_client_stop(struct l_icmp6_client *client)
 {
 	if (unlikely(!client))
@@ -535,18 +756,15 @@ LIB_EXPORT bool l_icmp6_client_stop(struct l_icmp6_cl=
ient *client)
 	l_io_destroy(client->io);
 	client->io =3D NULL;
 =

-	l_queue_foreach_remove(client->routes,
-					icmp6_client_remove_route, client);
+	l_queue_foreach_remove(client->routers,
+				icmp6_router_free_cb, NULL);
+	l_queue_foreach_remove(client->prefix_routes,
+				icmp6_route_info_free, NULL);
 =

 	client->retransmit_time =3D 0;
 	l_timeout_remove(client->timeout_send);
 	client->timeout_send =3D NULL;
 =

-	if (client->ra) {
-		_icmp6_router_free(client->ra);
-		client->ra =3D NULL;
-	}
-
 	return true;
 }
 =

@@ -556,7 +774,7 @@ LIB_EXPORT const struct l_icmp6_router *l_icmp6_client_=
get_router(
 	if (unlikely(!client))
 		return NULL;
 =

-	return client->ra;
+	return l_queue_peek_head(client->routers);
 }
 =

 LIB_EXPORT bool l_icmp6_client_add_event_handler(struct l_icmp6_client *cl=
ient,
@@ -653,6 +871,11 @@ struct l_icmp6_router *_icmp6_router_new()
 =

 void _icmp6_router_free(struct l_icmp6_router *r)
 {
+	if (r->default_route) {
+		icmp6_client_remove_route(r->default_route, r->client);
+		l_timeout_remove(r->default_timeout);
+	}
+
 	l_free(r->prefixes);
 	l_free(r);
 }
diff --git a/ell/icmp6.h b/ell/icmp6.h
index 9ce2e24..3e5fa71 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -35,6 +35,12 @@ struct l_netlink;
 =

 enum l_icmp6_client_event {
 	L_ICMP6_CLIENT_EVENT_ROUTER_FOUND =3D 0,
+	L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_ADDED,
+	L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED,
+	L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_CHANGED,
+	L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_ADDED,
+	L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_REMOVED,
+	L_ICMP6_CLIENT_EVENT_ONLINK_PREFIX_CHANGED,
 };
 =

 typedef void (*l_icmp6_debug_cb_t)(const char *str, void *user_data);
-- =

2.32.0

--===============7822057065312246834==--

