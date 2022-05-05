Content-Type: multipart/mixed; boundary="===============2581439763830989477=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 02/13] netconfig: Support IPv6 static configurations
Date: Fri, 06 May 2022 01:15:28 +0200
Message-ID: <20220505231539.888792-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220505231539.888792-1-andrew.zaborowski@intel.com

--===============2581439763830989477==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/netconfig.c | 153 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 124 insertions(+), 29 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 04d23b3..6736913 100644
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
@@ -94,6 +96,11 @@ struct l_netconfig {
 	} handler;
 };
 =

+union netconfig_addr {
+	struct in_addr v4;
+	struct in6_addr v6;
+};
+
 static void netconfig_update_cleanup(struct l_netconfig *nc)
 {
 	l_queue_clear(nc->addresses.added, NULL);
@@ -159,6 +166,50 @@ static void netconfig_add_v4_routes(struct l_netconfig=
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
+	l_net_clear_host_bits(in6_addr.s6_addr, prefix_len, 16);
+
+	if (L_WARN_ON(!inet_ntop(AF_INET6, &in6_addr, network,
+					INET6_ADDRSTRLEN)))
+		return;
+
+	/*
+	 * One reason we add a subnet route instead of letting the kernel
+	 * do it, by not specifying IFA_F_NOPREFIXROUTE for the address,
+	 * is that that would force a 0 metric for the route.
+	 */
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
@@ -388,6 +439,9 @@ LIB_EXPORT bool l_netconfig_set_family_enabled(struct l=
_netconfig *netconfig,
 	case AF_INET:
 		netconfig->v4_enabled =3D enabled;
 		return true;
+	case AF_INET6:
+		netconfig->v6_enabled =3D enabled;
+		return true;
 	}
 =

 	return false;
@@ -536,43 +590,39 @@ LIB_EXPORT bool l_netconfig_set_domain_names_override(
 	return true;
 }
 =

-static bool netconfig_check_v4_config(struct l_netconfig *netconfig)
+static bool netconfig_check_family_config(struct l_netconfig *nc,
+						uint8_t family)
 {
-	struct in_addr local;
-	struct in_addr gateway;
-	uint8_t prefix_len =3D 0;
+	struct l_rtnl_address *static_addr =3D (family =3D=3D AF_INET) ?
+		nc->v4_static_addr : nc->v6_static_addr;
+	char *gateway_override =3D (family =3D=3D AF_INET) ?
+		nc->v4_gateway_override : nc->v6_gateway_override;
+	char **dns_override =3D (family =3D=3D AF_INET) ?
+		nc->v4_dns_override : nc->v6_dns_override;
 	unsigned int dns_num =3D 0;
-	_auto_(l_free) struct in_addr *dns_list =3D NULL;
-
-	if (!netconfig->v4_enabled)
-		return true;
 =

-	if (netconfig->v4_static_addr) {
-		char str[INET_ADDRSTRLEN];
+	if (static_addr && family =3D=3D AF_INET) {
+		uint8_t prefix_len =3D
+			l_rtnl_address_get_prefix_length(static_addr);
 =

-		prefix_len =3D l_rtnl_address_get_prefix_length(
-						netconfig->v4_static_addr);
 		if (prefix_len > 30)
 			return false;
-
-		l_rtnl_address_get_address(netconfig->v4_static_addr, str);
-		inet_pton(AF_INET, str, &local);
 	}
 =

-	if (netconfig->v4_gateway_override) {
-		if (inet_pton(AF_INET, netconfig->v4_gateway_override,
-				&gateway) !=3D 1)
+	if (gateway_override) {
+		union netconfig_addr gateway;
+
+		if (inet_pton(family, gateway_override, &gateway) !=3D 1)
 			return false;
 	}
 =

-	if (netconfig->v4_dns_override &&
-			(dns_num =3D l_strv_length(netconfig->v4_dns_override))) {
+	if (dns_override && (dns_num =3D l_strv_length(dns_override))) {
 		unsigned int i;
-
-		dns_list =3D l_new(struct in_addr, dns_num);
+		_auto_(l_free) union netconfig_addr *dns_list =3D
+			l_new(union netconfig_addr, dns_num);
 =

 		for (i =3D 0; i < dns_num; i++)
-			if (inet_pton(AF_INET, netconfig->v4_dns_override[i],
+			if (inet_pton(family, dns_override[i],
 					&dns_list[i]) !=3D 1)
 				return false;
 	}
@@ -580,11 +630,12 @@ static bool netconfig_check_v4_config(struct l_netcon=
fig *netconfig)
 	return true;
 }
 =

-static bool netconfig_check_config(struct l_netconfig *netconfig)
+static bool netconfig_check_config(struct l_netconfig *nc)
 {
 	/* TODO: error reporting through a debug log handler or otherwise */
 =

-	return netconfig_check_v4_config(netconfig);
+	return netconfig_check_family_config(nc, AF_INET) &&
+		netconfig_check_family_config(nc, AF_INET6);
 }
 =

 LIB_EXPORT bool l_netconfig_check_config(struct l_netconfig *netconfig)
@@ -595,7 +646,7 @@ LIB_EXPORT bool l_netconfig_check_config(struct l_netco=
nfig *netconfig)
 	return netconfig_check_config(netconfig);
 }
 =

-static void netconfig_add_static_address_routes(struct l_netconfig *nc)
+static void netconfig_add_v4_static_address_routes(struct l_netconfig *nc)
 {
 	char ip[INET_ADDRSTRLEN];
 	uint32_t prefix_len;
@@ -609,6 +660,29 @@ static void netconfig_add_static_address_routes(struct=
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
@@ -616,10 +690,16 @@ static void netconfig_do_static_config(struct l_idle =
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
@@ -631,7 +711,7 @@ LIB_EXPORT bool l_netconfig_start(struct l_netconfig *n=
etconfig)
 		return false;
 =

 	if (!netconfig->v4_enabled)
-		goto done;
+		goto configure_ipv6;
 =

 	if (netconfig->v4_static_addr) {
 		/*
@@ -641,12 +721,26 @@ LIB_EXPORT bool l_netconfig_start(struct l_netconfig =
*netconfig)
 		netconfig->do_static_work =3D l_idle_create(
 						netconfig_do_static_config,
 						netconfig, NULL);
-		goto done;
+		goto configure_ipv6;
 	}
 =

 	if (!l_dhcp_client_start(netconfig->dhcp_client))
 		return false;
 =

+configure_ipv6:
+	if (!netconfig->v6_enabled)
+		goto done;
+
+	if (netconfig->v6_static_addr && !netconfig->do_static_work) {
+		/*
+		 * We're basically ready to configure the interface
+		 * but do this in an idle callback.
+		 */
+		netconfig->do_static_work =3D l_idle_create(
+						netconfig_do_static_config,
+						netconfig, NULL);
+	}
+
 done:
 	netconfig->started =3D true;
 	return true;
@@ -670,6 +764,7 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *ne=
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

--===============2581439763830989477==--

