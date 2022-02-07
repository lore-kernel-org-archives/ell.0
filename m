Content-Type: multipart/mixed; boundary="===============0703601837517385866=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 4/6] netconfig: Add netconfig API
Date: Mon, 07 Feb 2022 16:07:15 +0100
Message-ID: <20220207150717.60511-4-andrew.zaborowski@intel.com>
In-Reply-To: 20220207150717.60511-1-andrew.zaborowski@intel.com

--===============0703601837517385866==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This adds the netconfig class that will encapsulate static IP
configuration, DHCP, DHCP6, ICMP6, SLAAC logic and free the user of
manually handling DHCP/DHCP6 events to implement netconfig policies.
The user will still need to handle committing received DNS and mdns
information.

In this patch only IPv4 DHCP is implemented and no configurable settings
are added.

When events are emitted for address and/or route changes, the changes
are split into "added", "updated" and "removed" lists so that the user
can decide apply those changes without first removing all addresses and
routes from the interface and the re-adding the complete new list.
They can also decide to let another entity apply the changes.
---
 Makefile.am     |   6 +-
 ell/ell.h       |   1 +
 ell/ell.sym     |   8 ++
 ell/netconfig.c | 375 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netconfig.h |  73 ++++++++++
 5 files changed, 461 insertions(+), 2 deletions(-)
 create mode 100644 ell/netconfig.c
 create mode 100644 ell/netconfig.h

diff --git a/Makefile.am b/Makefile.am
index 4e650c9..8aaefdf 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -60,7 +60,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/icmp6.h \
 			ell/acd.h \
 			ell/tester.h \
-			ell/cleanup.h
+			ell/cleanup.h \
+			ell/netconfig.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -146,7 +147,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/icmp6.c \
 			ell/icmp6-private.h \
 			ell/acd.c \
-			ell/tester.c
+			ell/tester.c \
+			ell/netconfig.c
 =

 ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index d47d5cf..d4489ac 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -65,3 +65,4 @@
 #include <ell/path.h>
 #include <ell/acd.h>
 #include <ell/tester.h>
+#include <ell/netconfig.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 203a91b..6c27800 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -720,6 +720,14 @@ global:
 	l_tester_post_teardown_complete;
 	l_tester_post_teardown_failed;
 	l_tester_wait;
+	/* netconfig */
+	l_netconfig_new;
+	l_netconfig_destroy;
+	l_netconfig_set_route_priority;
+	l_netconfig_start;
+	l_netconfig_stop;
+	l_netconfig_get_dhcp_client;
+	l_netconfig_set_event_handler;
 local:
 	*;
 };
diff --git a/ell/netconfig.c b/ell/netconfig.c
new file mode 100644
index 0000000..e3ac751
--- /dev/null
+++ b/ell/netconfig.c
@@ -0,0 +1,375 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2022  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <linux/types.h>
+#include <netinet/ip.h>
+#include <arpa/inet.h>
+
+#include "private.h"
+#include "useful.h"
+#include "log.h"
+#include "dhcp.h"
+#include "dhcp-private.h"
+#include "netlink.h"
+#include "rtnl.h"
+#include "queue.h"
+#include "time.h"
+#include "netconfig.h"
+
+struct l_netconfig {
+	uint32_t ifindex;
+	bool v4_enabled;
+	uint32_t route_priority;
+
+	bool v4_configured;
+	struct l_dhcp_client *dhcp_client;
+	/* These objects, if not NULL, are owned by @addresses and @routes */
+	struct l_rtnl_address *v4_address;
+	struct l_rtnl_route *v4_subnet_route;
+	struct l_rtnl_route *v4_default_route;
+
+	struct {
+		struct l_queue *current;
+
+		/*
+		 * Temporary lists for use by the UPDATED handler to avoid
+		 * having to remove all entries on the interface and re-add
+		 * them from @current.  Entries in @updated are those that
+		 * RTM_NEWADDR/RTM_NEWROUTE will correctly identify as
+		 * existing objects and replace (with NLM_F_REPLACE) or
+		 * error out (without it) rather than create duplicates,
+		 * for example those that only have their lifetime updated.
+		 *
+		 * Any entries in @added and @updated are owned by @current.
+		 */
+		struct l_queue *added;
+		struct l_queue *updated;
+		struct l_queue *removed;
+	} addresses, routes;
+
+	struct {
+		l_netconfig_event_cb_t callback;
+		void *user_data;
+		l_netconfig_destroy_cb_t destroy;
+	} handler;
+};
+
+static void netconfig_update_cleanup(struct l_netconfig *nc)
+{
+	l_queue_clear(nc->addresses.added, NULL);
+	l_queue_clear(nc->addresses.updated, NULL);
+	l_queue_clear(nc->addresses.removed,
+			(l_queue_destroy_func_t) l_rtnl_address_free);
+	l_queue_clear(nc->routes.added, NULL);
+	l_queue_clear(nc->routes.updated, NULL);
+	l_queue_clear(nc->routes.removed,
+			(l_queue_destroy_func_t) l_rtnl_route_free);
+}
+
+static void netconfig_emit_event(struct l_netconfig *nc, uint8_t family,
+					enum l_netconfig_event event)
+{
+	if (!nc->handler.callback)
+		return;
+
+	nc->handler.callback(nc, family, event, nc->handler.user_data);
+
+	if (L_IN_SET(event, L_NETCONFIG_EVENT_UPDATED,
+			L_NETCONFIG_EVENT_CONFIGURED,
+			L_NETCONFIG_EVENT_UNCONFIGURED))
+		netconfig_update_cleanup(nc);
+}
+
+static void netconfig_add_dhcp_address_routes(struct l_netconfig *nc)
+{
+	const struct l_dhcp_lease *lease =3D
+		l_dhcp_client_get_lease(nc->dhcp_client);
+	_auto_(l_free) char *ip =3D NULL;
+	_auto_(l_free) char *broadcast =3D NULL;
+	_auto_(l_free) char *gateway =3D NULL;
+	char network[INET_ADDRSTRLEN];
+	struct in_addr in_addr;
+	uint32_t prefix_len;
+
+	/* Address */
+
+	ip =3D l_dhcp_lease_get_address(lease);
+	broadcast =3D l_dhcp_lease_get_broadcast(lease);
+
+	prefix_len =3D l_dhcp_lease_get_prefix_length(lease);
+	if (!prefix_len)
+		prefix_len =3D 24;
+
+	nc->v4_address =3D l_rtnl_address_new(ip, prefix_len);
+	if (L_WARN_ON(!nc->v4_address))
+		return;
+
+	l_rtnl_address_set_noprefixroute(nc->v4_address, true);
+
+	if (broadcast)
+		l_rtnl_address_set_broadcast(nc->v4_address, broadcast);
+
+	l_queue_push_tail(nc->addresses.current, nc->v4_address);
+	l_queue_push_tail(nc->addresses.added, nc->v4_address);
+
+	/* Subnet route */
+
+	if (L_WARN_ON(inet_pton(AF_INET, ip, &in_addr) !=3D 1))
+		return;
+
+	in_addr.s_addr &=3D htonl(0xfffffffflu << (32 - prefix_len));
+	if (L_WARN_ON(!inet_ntop(AF_INET, &in_addr, network, INET_ADDRSTRLEN)))
+		return;
+
+	nc->v4_subnet_route =3D l_rtnl_route_new_prefix(network, prefix_len);
+	l_rtnl_route_set_protocol(nc->v4_subnet_route, RTPROT_DHCP);
+	l_rtnl_route_set_priority(nc->v4_subnet_route, nc->route_priority);
+	l_queue_push_tail(nc->routes.current, nc->v4_subnet_route);
+	l_queue_push_tail(nc->routes.added, nc->v4_subnet_route);
+
+	/* Gateway route */
+
+	if (!(gateway =3D l_dhcp_lease_get_gateway(lease)))
+		return;
+
+	nc->v4_default_route =3D l_rtnl_route_new_gateway(gateway);
+	l_rtnl_route_set_protocol(nc->v4_default_route, RTPROT_DHCP);
+	L_WARN_ON(!l_rtnl_route_set_prefsrc(nc->v4_default_route, ip));
+	l_queue_push_tail(nc->routes.current, nc->v4_default_route);
+	l_queue_push_tail(nc->routes.added, nc->v4_default_route);
+}
+
+static void netconfig_set_dhcp_lifetimes(struct l_netconfig *nc, bool upda=
ted)
+{
+	const struct l_dhcp_lease *lease =3D
+		l_dhcp_client_get_lease(nc->dhcp_client);
+	uint32_t lifetime =3D l_dhcp_lease_get_lifetime(lease);
+	uint64_t now =3D l_time_now();
+
+	l_rtnl_address_set_lifetimes(nc->v4_address, 0, lifetime, now);
+
+	if (updated)
+		l_queue_push_tail(nc->addresses.updated, nc->v4_address);
+
+	l_rtnl_route_set_lifetime(nc->v4_subnet_route, lifetime, now);
+
+	if (updated)
+		l_queue_push_tail(nc->routes.updated, nc->v4_subnet_route);
+
+	if (!nc->v4_default_route)
+		return;
+
+	l_rtnl_route_set_lifetime(nc->v4_default_route, lifetime, now);
+
+	if (updated)
+		l_queue_push_tail(nc->routes.updated, nc->v4_default_route);
+}
+
+static void netconfig_remove_dhcp_address_routes(struct l_netconfig *nc)
+{
+	l_queue_remove(nc->addresses.current, nc->v4_address);
+	l_queue_push_tail(nc->addresses.removed, nc->v4_address);
+	nc->v4_address =3D NULL;
+
+	l_queue_remove(nc->routes.current, nc->v4_subnet_route);
+	l_queue_push_tail(nc->routes.removed, nc->v4_subnet_route);
+	nc->v4_subnet_route =3D NULL;
+
+	if (nc->v4_default_route) {
+		l_queue_remove(nc->routes.current, nc->v4_default_route);
+		l_queue_push_tail(nc->routes.removed, nc->v4_default_route);
+		nc->v4_default_route =3D NULL;
+	}
+}
+
+static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
+						enum l_dhcp_client_event event,
+						void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	switch (event) {
+	case L_DHCP_CLIENT_EVENT_IP_CHANGED:
+		L_WARN_ON(!nc->v4_configured);
+		netconfig_remove_dhcp_address_routes(nc);
+		netconfig_add_dhcp_address_routes(nc);
+		netconfig_set_dhcp_lifetimes(nc, false);
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATED);
+		break;
+	case L_DHCP_CLIENT_EVENT_LEASE_OBTAINED:
+	{
+		L_WARN_ON(nc->v4_configured);
+		netconfig_add_dhcp_address_routes(nc);
+		netconfig_set_dhcp_lifetimes(nc, false);
+		nc->v4_configured =3D true;
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURED);
+		break;
+	}
+	case L_DHCP_CLIENT_EVENT_LEASE_RENEWED:
+		L_WARN_ON(!nc->v4_configured);
+		netconfig_set_dhcp_lifetimes(nc, true);
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATED);
+		break;
+	case L_DHCP_CLIENT_EVENT_LEASE_EXPIRED:
+		L_WARN_ON(!nc->v4_configured);
+		netconfig_remove_dhcp_address_routes(nc);
+		nc->v4_configured =3D false;
+
+		if (l_dhcp_client_start(nc->dhcp_client))
+			/* TODO: also start a new timeout */
+			netconfig_emit_event(nc, AF_INET,
+						L_NETCONFIG_EVENT_UNCONFIGURED);
+		else
+			netconfig_emit_event(nc, AF_INET,
+						L_NETCONFIG_EVENT_FAILED);
+
+		break;
+	case L_DHCP_CLIENT_EVENT_NO_LEASE:
+		L_WARN_ON(nc->v4_configured);
+
+		/*
+		 * The requested address is no longer available, try to restart
+		 * the client.
+		 *
+		 * TODO: this may need to be delayed so we don't flood the
+		 * network with DISCOVERs and NAKs.  Also add a retry limit or
+		 * better yet a configurable timeout.
+		 */
+		if (!l_dhcp_client_start(nc->dhcp_client))
+			netconfig_emit_event(nc, AF_INET,
+						L_NETCONFIG_EVENT_FAILED);
+
+		break;
+	}
+}
+
+LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
+{
+	struct l_netconfig *nc;
+
+	nc =3D l_new(struct l_netconfig, 1);
+	nc->ifindex =3D ifindex;
+	nc->v4_enabled =3D true;
+
+	nc->addresses.current =3D l_queue_new();
+	nc->addresses.added =3D l_queue_new();
+	nc->addresses.updated =3D l_queue_new();
+	nc->addresses.removed =3D l_queue_new();
+	nc->routes.current =3D l_queue_new();
+	nc->routes.added =3D l_queue_new();
+	nc->routes.updated =3D l_queue_new();
+	nc->routes.removed =3D l_queue_new();
+
+	nc->dhcp_client =3D l_dhcp_client_new(ifindex);
+	l_dhcp_client_set_event_handler(nc->dhcp_client,
+					netconfig_dhcp_event_handler,
+					nc, NULL);
+
+	return nc;
+}
+
+LIB_EXPORT void l_netconfig_destroy(struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return;
+
+	l_netconfig_stop(netconfig);
+
+	l_dhcp_client_destroy(netconfig->dhcp_client);
+	l_netconfig_set_event_handler(netconfig, NULL, NULL, NULL);
+	l_queue_destroy(netconfig->addresses.current, NULL);
+	l_queue_destroy(netconfig->addresses.added, NULL);
+	l_queue_destroy(netconfig->addresses.updated, NULL);
+	l_queue_destroy(netconfig->addresses.removed, NULL);
+	l_queue_destroy(netconfig->routes.current, NULL);
+	l_queue_destroy(netconfig->routes.added, NULL);
+	l_queue_destroy(netconfig->routes.updated, NULL);
+	l_queue_destroy(netconfig->routes.removed, NULL);
+	l_free(netconfig);
+}
+
+LIB_EXPORT void l_netconfig_set_route_priority(struct l_netconfig *netconf=
ig,
+						uint32_t priority)
+{
+	if (unlikely(!netconfig))
+		return;
+
+	netconfig->route_priority =3D priority;
+}
+
+LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return false;
+
+	if (netconfig->v4_enabled &&
+			!l_dhcp_client_start(netconfig->dhcp_client))
+		return false;
+
+	return true;
+}
+
+LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return;
+
+	netconfig_update_cleanup(netconfig);
+	l_queue_clear(netconfig->routes.current,
+			(l_queue_destroy_func_t) l_rtnl_route_free);
+	l_queue_clear(netconfig->addresses.current,
+			(l_queue_destroy_func_t) l_rtnl_address_free);
+	netconfig->v4_address =3D NULL;
+	netconfig->v4_subnet_route =3D NULL;
+	netconfig->v4_default_route =3D NULL;
+
+	l_dhcp_client_stop(netconfig->dhcp_client);
+}
+
+LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhcp_client(
+						struct l_netconfig *netconfig)
+{
+	if (unlikely(!netconfig))
+		return NULL;
+
+	return netconfig->dhcp_client;
+}
+
+LIB_EXPORT void l_netconfig_set_event_handler(struct l_netconfig *netconfi=
g,
+					l_netconfig_event_cb_t handler,
+					void *user_data,
+					l_netconfig_destroy_cb_t destroy)
+{
+	if (unlikely(!netconfig))
+		return;
+
+	if (netconfig->handler.destroy)
+		netconfig->handler.destroy(netconfig->handler.user_data);
+
+	netconfig->handler.callback =3D handler;
+	netconfig->handler.user_data =3D user_data;
+	netconfig->handler.destroy =3D destroy;
+}
diff --git a/ell/netconfig.h b/ell/netconfig.h
new file mode 100644
index 0000000..eab48b0
--- /dev/null
+++ b/ell/netconfig.h
@@ -0,0 +1,73 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2022  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_NETCONFIG_H
+#define __ELL_NETCONFIG_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stdbool.h>
+
+struct l_dhcp_client;
+struct l_dhcp6_client;
+struct l_icmp6_client;
+struct l_netlink;
+struct l_queue;
+struct l_netconfig;
+
+/// should this be called netconfig_client instead of just netconfig?
+enum l_netconfig_event {
+	L_NETCONFIG_EVENT_CONFIGURED,
+	L_NETCONFIG_EVENT_UPDATED,
+	L_NETCONFIG_EVENT_UNCONFIGURED,
+	L_NETCONFIG_EVENT_FAILED,
+};
+
+typedef void (*l_netconfig_event_cb_t)(struct l_netconfig *netconfig,
+					uint8_t family,
+					enum l_netconfig_event event,
+					void *user_data);
+typedef void (*l_netconfig_destroy_cb_t)(void *user_data);
+
+struct l_netconfig *l_netconfig_new(uint32_t ifindex);
+void l_netconfig_destroy(struct l_netconfig *netconfig);
+void l_netconfig_set_route_priority(struct l_netconfig *netconfig,
+					uint32_t priority);
+
+bool l_netconfig_start(struct l_netconfig *netconfig);
+void l_netconfig_stop(struct l_netconfig *netconfig);
+
+struct l_dhcp_client *l_netconfig_get_dhcp_client(
+						struct l_netconfig *netconfig);
+
+void l_netconfig_set_event_handler(struct l_netconfig *netconfig,
+					l_netconfig_event_cb_t handler,
+					void *user_data,
+					l_netconfig_destroy_cb_t destroy);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_NETCONFIG_H */
-- =

2.32.0

--===============0703601837517385866==--

