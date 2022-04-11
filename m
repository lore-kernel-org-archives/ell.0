Content-Type: multipart/mixed; boundary="===============8567684703419123524=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/11] netconfig: Support IPv6 static configurations
Date: Mon, 11 Apr 2022 16:20:53 +0200
Message-ID: <20220411142056.817784-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============8567684703419123524==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/netconfig.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 90 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index d0f87b3..6641398 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -62,11 +62,13 @@ struct l_netconfig {
 	struct l_idle *do_static_work;
 	bool v4_configured;
 	struct l_dhcp_client *dhcp_client;
+	bool v6_configured;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
 	struct l_rtnl_route *v4_subnet_route;
 	struct l_rtnl_route *v4_default_route;
+	struct l_rtnl_address *v6_address;
 =

 	struct {
 		struct l_queue *current;
@@ -159,6 +161,50 @@ static void netconfig_add_v4_routes(struct l_netconfig=
 *nc, const char *ip,
 	l_queue_push_tail(nc->routes.added, nc->v4_default_route);
 }
 =

+static void netconfig_add_v6_static_routes(struct l_netconfig *nc,
+						const char *ip,
+						uint8_t prefix_len)
+{
+	struct in6_addr in6_addr;
+	char network[INET6_ADDRSTRLEN];
+	struct l_rtnl_route *v6_subnet_route;
+	struct l_rtnl_route *v6_default_route;
+
+	/* Subnet route */
+
+	if (L_WARN_ON(inet_pton(AF_INET6, ip, &in6_addr) !=3D 1))
+		return;
+
+	/* Zero out host address bits to produce network address */
+	if (prefix_len & 7)
+		in6_addr.s6_addr[prefix_len / 8] &=3D 0xff00 >> (prefix_len & 7);
+
+	if (prefix_len <=3D 120)
+		memset(in6_addr.s6_addr + (prefix_len + 7) / 8, 0,
+			16 - (prefix_len + 7) / 8);
+
+	if (L_WARN_ON(!inet_ntop(AF_INET6, &in6_addr, network,
+					INET6_ADDRSTRLEN)))
+		return;
+
+	v6_subnet_route =3D l_rtnl_route_new_prefix(network, prefix_len);
+	l_rtnl_route_set_protocol(v6_subnet_route, RTPROT_STATIC);
+	l_rtnl_route_set_priority(v6_subnet_route, nc->route_priority);
+	l_queue_push_tail(nc->routes.current, v6_subnet_route);
+	l_queue_push_tail(nc->routes.added, v6_subnet_route);
+
+	/* Gateway route */
+
+	if (!nc->v6_gateway_override)
+		return;
+
+	v6_default_route =3D l_rtnl_route_new_gateway(nc->v6_gateway_override);
+	l_rtnl_route_set_protocol(v6_default_route, RTPROT_STATIC);
+	L_WARN_ON(!l_rtnl_route_set_prefsrc(v6_default_route, ip));
+	l_queue_push_tail(nc->routes.current, v6_default_route);
+	l_queue_push_tail(nc->routes.added, v6_default_route);
+}
+
 static void netconfig_add_dhcp_address_routes(struct l_netconfig *nc)
 {
 	const struct l_dhcp_lease *lease =3D
@@ -683,7 +729,7 @@ LIB_EXPORT bool l_netconfig_check_config(struct l_netco=
nfig *netconfig)
 	return netconfig_check_config(netconfig);
 }
 =

-static void netconfig_add_static_address_routes(struct l_netconfig *nc)
+static void netconfig_add_v4_static_address_routes(struct l_netconfig *nc)
 {
 	char ip[INET_ADDRSTRLEN];
 	uint32_t prefix_len;
@@ -697,6 +743,29 @@ static void netconfig_add_static_address_routes(struct=
 l_netconfig *nc)
 	netconfig_add_v4_routes(nc, ip, prefix_len, NULL, RTPROT_STATIC);
 }
 =

+/*
+ * Just mirror the IPv4 behaviour with static IPv6 configuration.  It would
+ * be more logical to let the user choose between static IPv6 address and
+ * DHCPv6, and, completely independently, choose between static routes
+ * (if a static prefix length and/or gateway address is set) and ICMPv6.
+ * Yet a mechanism identical with IPv4 is easier to understand for a typic=
al
+ * user so providing a static address just disables all automatic
+ * configuration.
+ */
+static void netconfig_add_v6_static_address_routes(struct l_netconfig *nc)
+{
+	char ip[INET6_ADDRSTRLEN];
+	uint32_t prefix_len;
+
+	nc->v6_address =3D l_rtnl_address_clone(nc->v6_static_addr);
+	l_queue_push_tail(nc->addresses.current, nc->v6_address);
+	l_queue_push_tail(nc->addresses.added, nc->v6_address);
+
+	l_rtnl_address_get_address(nc->v6_static_addr, ip);
+	prefix_len =3D l_rtnl_address_get_prefix_length(nc->v6_static_addr);
+	netconfig_add_v6_static_routes(nc, ip, prefix_len);
+}
+
 static void netconfig_do_static_config(struct l_idle *idle, void *user_dat=
a)
 {
 	struct l_netconfig *nc =3D user_data;
@@ -704,10 +773,16 @@ static void netconfig_do_static_config(struct l_idle =
*idle, void *user_data)
 	l_idle_remove(l_steal_ptr(nc->do_static_work));
 =

 	if (nc->v4_static_addr && !nc->v4_configured) {
-		netconfig_add_static_address_routes(nc);
+		netconfig_add_v4_static_address_routes(nc);
 		nc->v4_configured =3D true;
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
 	}
+
+	if (nc->v6_static_addr && !nc->v6_configured) {
+		netconfig_add_v6_static_address_routes(nc);
+		nc->v6_configured =3D true;
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
+	}
 }
 =

 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
@@ -733,6 +808,18 @@ LIB_EXPORT bool l_netconfig_start(struct l_netconfig *=
netconfig)
 		}
 	}
 =

+	if (netconfig->v6_enabled) {
+		if (netconfig->v6_static_addr && !netconfig->do_static_work) {
+			/*
+			 * We're basically ready to configure the interface
+			 * but do this in an idle callback.
+			 */
+			netconfig->do_static_work =3D l_idle_create(
+						netconfig_do_static_config,
+						netconfig, NULL);
+		}
+	}
+
 	netconfig->started =3D true;
 	return true;
 }
@@ -755,6 +842,7 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *ne=
tconfig)
 	netconfig->v4_address =3D NULL;
 	netconfig->v4_subnet_route =3D NULL;
 	netconfig->v4_default_route =3D NULL;
+	netconfig->v6_address =3D NULL;
 =

 	l_dhcp_client_stop(netconfig->dhcp_client);
 }
-- =

2.32.0

--===============8567684703419123524==--

