Content-Type: multipart/mixed; boundary="===============6767460345865872076=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/12] netconfig: Add DHCP override and static IP API
Date: Thu, 21 Apr 2022 17:45:16 +0200
Message-ID: <20220421154525.1416984-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220421154525.1416984-1-andrew.zaborowski@intel.com

--===============6767460345865872076==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add API to override things like DNS, domain names, etc. received from
DHCP or disable DHCP completely by setting a static address.
---
 ell/ell.sym     |   8 ++
 ell/netconfig.c | 349 +++++++++++++++++++++++++++++++++++++++++++++++-
 ell/netconfig.h |  16 +++
 3 files changed, 368 insertions(+), 5 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 96869d5..60dd257 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -738,6 +738,14 @@ global:
 	/* netconfig */
 	l_netconfig_new;
 	l_netconfig_destroy;
+	l_netconfig_set_family_enabled;
+	l_netconfig_set_hostname;
+	l_netconfig_set_route_priority;
+	l_netconfig_set_static_addr;
+	l_netconfig_set_gateway_override;
+	l_netconfig_set_dns_override;
+	l_netconfig_set_domain_names_override;
+	l_netconfig_check_config;
 	l_netconfig_start;
 	l_netconfig_stop;
 	l_netconfig_get_dhcp_client;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index fe5e6d9..c8a5510 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -37,16 +37,32 @@
 #include "rtnl.h"
 #include "queue.h"
 #include "time.h"
+#include "idle.h"
+#include "strv.h"
+#include "net.h"
 #include "netconfig.h"
 =

 struct l_netconfig {
 	uint32_t ifindex;
-	bool v4_enabled;
-	bool started;
 	uint32_t route_priority;
 =

+	bool v4_enabled;
+	struct l_rtnl_address *v4_static_addr;
+	char *v4_gateway_override;
+	char **v4_dns_override;
+	char **v4_domain_names_override;
+
+	bool v6_enabled;
+	struct l_rtnl_address *v6_static_addr;
+	char *v6_gateway_override;
+	char **v6_dns_override;
+	char **v6_domain_names_override;
+
+	bool started;
+	struct l_idle *do_static_work;
 	bool v4_configured;
 	struct l_dhcp_client *dhcp_client;
+
 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
 	struct l_rtnl_route *v4_subnet_route;
@@ -128,6 +144,11 @@ static void netconfig_add_v4_routes(struct l_netconfig=
 *nc, const char *ip,
 =

 	/* Gateway route */
 =

+	if (nc->v4_gateway_override) {
+		gateway =3D nc->v4_gateway_override;
+		rtm_protocol =3D RTPROT_STATIC;
+	}
+
 	if (!gateway)
 		return;
 =

@@ -316,6 +337,15 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig=
 *netconfig)
 =

 	l_netconfig_stop(netconfig);
 =

+	l_netconfig_set_static_addr(netconfig, AF_INET, NULL);
+	l_netconfig_set_gateway_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_dns_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_domain_names_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_static_addr(netconfig, AF_INET6, NULL);
+	l_netconfig_set_gateway_override(netconfig, AF_INET6, NULL);
+	l_netconfig_set_dns_override(netconfig, AF_INET6, NULL);
+	l_netconfig_set_domain_names_override(netconfig, AF_INET6, NULL);
+
 	l_dhcp_client_destroy(netconfig->dhcp_client);
 	l_netconfig_set_event_handler(netconfig, NULL, NULL, NULL);
 	l_queue_destroy(netconfig->addresses.current, NULL);
@@ -329,17 +359,323 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconf=
ig *netconfig)
 	l_free(netconfig);
 }
 =

+/*
+ * The following l_netconfig_set_* functions configure the l_netconfig's
+ * client settings.  The setters can be called independently, without
+ * following a specific order.  Most of the setters will not validate the
+ * values passed, l_netconfig_start() will fail if settings are incorrect
+ * or inconsistent between themselves, e.g. if the static local IP and
+ * gateway IP are not in the same subnet.  Alternatively
+ * l_netconfig_check_config() can be called at any point to validate the
+ * current configuration.  The configuration can only be changed while
+ * the l_netconfig state machine is stopped, i.e. before
+ * l_netconfig_start() and after l_netconfig_stop().
+ *
+ * l_netconfig_set_hostname, l_netconfig_set_static_addr,
+ * l_netconfig_set_gateway_override, l_netconfig_set_dns_override and
+ * l_netconfig_set_domain_names_override can be passed NULL to unset a
+ * value that had been set before (revert to auto).  This is why the
+ * family parameter is needed even when it could otherwise be derived
+ * from the new value that is passed.
+ */
+LIB_EXPORT bool l_netconfig_set_family_enabled(struct l_netconfig *netconf=
ig,
+						uint8_t family, bool enabled)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	switch (family) {
+	case AF_INET:
+		netconfig->v4_enabled =3D enabled;
+		return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT bool l_netconfig_set_hostname(struct l_netconfig *netconfig,
+						const char *hostname)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	return l_dhcp_client_set_hostname(netconfig->dhcp_client, hostname);
+}
+
+LIB_EXPORT bool l_netconfig_set_route_priority(struct l_netconfig *netconf=
ig,
+						uint32_t priority)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	netconfig->route_priority =3D priority;
+	return true;
+}
+
+LIB_EXPORT bool l_netconfig_set_static_addr(struct l_netconfig *netconfig,
+					uint8_t family,
+					const struct l_rtnl_address *addr)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	if (addr && l_rtnl_address_get_family(addr) !=3D family)
+		return false;
+
+	switch (family) {
+	case AF_INET:
+		l_rtnl_address_free(l_steal_ptr(netconfig->v4_static_addr));
+
+		if (!addr)
+			break;
+
+		netconfig->v4_static_addr =3D l_rtnl_address_clone(addr);
+		l_rtnl_address_set_lifetimes(netconfig->v4_static_addr, 0, 0);
+
+		/*
+		 * We could leave the decision about this flag up to the
+		 * caller but for simplicity override to true.
+		 */
+		l_rtnl_address_set_noprefixroute(netconfig->v4_static_addr,
+							true);
+		return true;
+	case AF_INET6:
+		l_rtnl_address_free(l_steal_ptr(netconfig->v6_static_addr));
+
+		if (!addr)
+			break;
+
+		netconfig->v6_static_addr =3D l_rtnl_address_clone(addr);
+		l_rtnl_address_set_lifetimes(netconfig->v6_static_addr, 0, 0);
+		l_rtnl_address_set_noprefixroute(netconfig->v6_static_addr,
+							true);
+		return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT bool l_netconfig_set_gateway_override(struct l_netconfig *netco=
nfig,
+							uint8_t family,
+							const char *gateway_str)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	switch (family) {
+	case AF_INET:
+		l_free(l_steal_ptr(netconfig->v4_gateway_override));
+
+		if (!gateway_str)
+			break;
+
+		netconfig->v4_gateway_override =3D l_strdup(gateway_str);
+		return true;
+	case AF_INET6:
+		l_free(l_steal_ptr(netconfig->v6_gateway_override));
+
+		if (!gateway_str)
+			break;
+
+		netconfig->v6_gateway_override =3D l_strdup(gateway_str);
+		return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT bool l_netconfig_set_dns_override(struct l_netconfig *netconfig,
+						uint8_t family, char **dns_list)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	switch (family) {
+	case AF_INET:
+		l_strv_free(l_steal_ptr(netconfig->v4_dns_override));
+
+		if (!dns_list)
+			break;
+
+		netconfig->v4_dns_override =3D l_strv_copy(dns_list);
+		return true;
+	case AF_INET6:
+		l_strv_free(l_steal_ptr(netconfig->v6_dns_override));
+
+		if (!dns_list)
+			break;
+
+		netconfig->v6_dns_override =3D l_strv_copy(dns_list);
+		return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT bool l_netconfig_set_domain_names_override(
+						struct l_netconfig *netconfig,
+						uint8_t family, char **names)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	switch (family) {
+	case AF_INET:
+		l_strv_free(l_steal_ptr(netconfig->v4_domain_names_override));
+
+		if (!names)
+			break;
+
+		netconfig->v4_domain_names_override =3D l_strv_copy(names);
+		return true;
+	case AF_INET6:
+		l_strv_free(l_steal_ptr(netconfig->v6_domain_names_override));
+
+		if (!names)
+			break;
+
+		netconfig->v6_domain_names_override =3D l_strv_copy(names);
+		return true;
+	}
+
+	return false;
+}
+
+static bool netconfig_check_v4_config(struct l_netconfig *netconfig)
+{
+	struct in_addr local;
+	struct in_addr gateway;
+	uint8_t prefix_len =3D 0;
+	unsigned int dns_num =3D 0;
+	_auto_(l_free) struct in_addr *dns_list =3D NULL;
+
+	if (!netconfig->v4_enabled)
+		return true;
+
+	if (netconfig->v4_static_addr) {
+		char str[INET_ADDRSTRLEN];
+
+		prefix_len =3D l_rtnl_address_get_prefix_length(
+						netconfig->v4_static_addr);
+		if (prefix_len > 30)
+			return false;
+
+		l_rtnl_address_get_address(netconfig->v4_static_addr, str);
+		inet_pton(AF_INET, str, &local);
+	}
+
+	if (netconfig->v4_gateway_override) {
+		if (inet_pton(AF_INET, netconfig->v4_gateway_override,
+				&gateway) !=3D 1)
+			return false;
+	}
+
+	if (netconfig->v4_dns_override &&
+			(dns_num =3D l_strv_length(netconfig->v4_dns_override))) {
+		unsigned int i;
+
+		dns_list =3D l_new(struct in_addr, dns_num);
+
+		for (i =3D 0; i < dns_num; i++)
+			if (inet_pton(AF_INET, netconfig->v4_dns_override[i],
+					&dns_list[i]) !=3D 1)
+				return false;
+	}
+
+	/*
+	 * If using a static IP, we can validate right now that the gateway is
+	 * in the local subnet.
+	 */
+	if (netconfig->v4_static_addr && netconfig->v4_gateway_override)
+		if (!l_net_prefix_matches(&local, &gateway, prefix_len))
+			return false;
+
+	/*
+	 * If using a static IP and there's no gateway all the DNSes must be on
+	 * the local subnet too.
+	 */
+	if (netconfig->v4_static_addr && !netconfig->v4_gateway_override &&
+			netconfig->v4_dns_override) {
+		unsigned int i;
+
+		for (i =3D 0; i < dns_num; i++)
+			if (!l_net_prefix_matches(&local, &dns_list[i],
+							prefix_len))
+				return false;
+	}
+
+	return true;
+}
+
+static bool netconfig_check_config(struct l_netconfig *netconfig)
+{
+	/* TODO: error reporting through a debug log handler or otherwise */
+
+	return netconfig_check_v4_config(netconfig);
+}
+
+LIB_EXPORT bool l_netconfig_check_config(struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	return netconfig_check_config(netconfig);
+}
+
+static void netconfig_add_static_address_routes(struct l_netconfig *nc)
+{
+	char ip[INET_ADDRSTRLEN];
+	uint32_t prefix_len;
+
+	nc->v4_address =3D l_rtnl_address_clone(nc->v4_static_addr);
+	l_queue_push_tail(nc->addresses.current, nc->v4_address);
+	l_queue_push_tail(nc->addresses.added, nc->v4_address);
+
+	l_rtnl_address_get_address(nc->v4_static_addr, ip);
+	prefix_len =3D l_rtnl_address_get_prefix_length(nc->v4_static_addr);
+	netconfig_add_v4_routes(nc, ip, prefix_len, NULL, RTPROT_STATIC);
+}
+
+static void netconfig_do_static_config(struct l_idle *idle, void *user_dat=
a)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	l_idle_remove(l_steal_ptr(nc->do_static_work));
+
+	if (nc->v4_static_addr && !nc->v4_configured) {
+		netconfig_add_static_address_routes(nc);
+		nc->v4_configured =3D true;
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
+	}
+}
+
 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 {
 	if (unlikely(!netconfig || netconfig->started))
 		return false;
 =

-	if (netconfig->v4_enabled &&
-			!l_dhcp_client_start(netconfig->dhcp_client))
+	if (!netconfig_check_config(netconfig))
 		return false;
 =

-	netconfig->started =3D true;
+	if (!netconfig->v4_enabled)
+		goto done;
+
+	if (netconfig->v4_static_addr) {
+		/*
+		 * We're basically ready to configure the interface
+		 * but do this in an idle callback.
+		 */
+		netconfig->do_static_work =3D l_idle_create(
+						netconfig_do_static_config,
+						netconfig, NULL);
+		goto done;
+	}
 =

+	if (!l_dhcp_client_start(netconfig->dhcp_client))
+		return false;
+
+done:
+	netconfig->started =3D true;
 	return true;
 }
 =

@@ -350,6 +686,9 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *ne=
tconfig)
 =

 	netconfig->started =3D false;
 =

+	if (netconfig->do_static_work)
+		l_idle_remove(l_steal_ptr(netconfig->do_static_work));
+
 	netconfig_update_cleanup(netconfig);
 	l_queue_clear(netconfig->routes.current,
 			(l_queue_destroy_func_t) l_rtnl_route_free);
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 682f4aa..f90ec81 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -53,6 +53,22 @@ typedef void (*l_netconfig_destroy_cb_t)(void *user_data=
);
 =

 struct l_netconfig *l_netconfig_new(uint32_t ifindex);
 void l_netconfig_destroy(struct l_netconfig *netconfig);
+bool l_netconfig_set_family_enabled(struct l_netconfig *netconfig,
+					uint8_t family, bool enabled);
+bool l_netconfig_set_hostname(struct l_netconfig *netconfig,
+				const char *hostname);
+bool l_netconfig_set_route_priority(struct l_netconfig *netconfig,
+					uint32_t priority);
+bool l_netconfig_set_static_addr(struct l_netconfig *netconfig, uint8_t fa=
mily,
+					const struct l_rtnl_address *addr);
+bool l_netconfig_set_gateway_override(struct l_netconfig *netconfig,
+					uint8_t family,
+					const char *gateway_str);
+bool l_netconfig_set_dns_override(struct l_netconfig *netconfig, uint8_t f=
amily,
+					char **dns_list);
+bool l_netconfig_set_domain_names_override(struct l_netconfig *netconfig,
+						uint8_t family, char **names);
+bool l_netconfig_check_config(struct l_netconfig *netconfig);
 =

 bool l_netconfig_start(struct l_netconfig *netconfig);
 void l_netconfig_stop(struct l_netconfig *netconfig);
-- =

2.32.0

--===============6767460345865872076==--

