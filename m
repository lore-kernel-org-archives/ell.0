Content-Type: multipart/mixed; boundary="===============3902293625617028756=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 11/17] netconfig: Wait for link-local address before DHCPv6
Date: Fri, 13 May 2022 16:55:04 +0200
Message-ID: <20220513145510.1408510-11-andrew.zaborowski@intel.com>
In-Reply-To: 20220513145510.1408510-1-andrew.zaborowski@intel.com

--===============3902293625617028756==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Keep one global rtnl instance instead of one per interface so that we
can have just one RTM_NEWADDR listener.  On l_netconfig_start dump
existing IPv6 addresses and wait until a link-local address is added so
it can be used as the source address for our DHCPv6 frames.
---
 ell/netconfig.c | 178 ++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 163 insertions(+), 15 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 4d11c75..6badb00 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -63,7 +63,7 @@ struct l_netconfig {
 	char **v6_dns_override;
 	char **v6_domain_names_override;
 =

-	struct l_netlink *rtnl;
+	unsigned int ifaddr6_dump_cmd_id;
 	bool started;
 	struct l_idle *do_static_work;
 	bool v4_configured;
@@ -114,6 +114,11 @@ union netconfig_addr {
 	struct in6_addr v6;
 };
 =

+static struct l_netlink *rtnl;
+static unsigned int rtnl_use_count;
+static struct l_queue *addr_wait_list;
+static unsigned int rtnl_id;
+
 static void netconfig_update_cleanup(struct l_netconfig *nc)
 {
 	l_queue_clear(nc->addresses.added, NULL);
@@ -843,13 +848,17 @@ static void netconfig_icmp6_event_handler(struct l_ic=
mp6_client *client,
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 {
 	struct l_netconfig *nc;
-	struct l_netlink *rtnl =3D l_netlink_new(NETLINK_ROUTE);
 =

-	if (!rtnl)
-		return NULL;
+	if (!rtnl) {
+		rtnl =3D l_netlink_new(NETLINK_ROUTE);
+
+		if (!rtnl)
+			return NULL;
+	}
+
+	rtnl_use_count++;
 =

 	nc =3D l_new(struct l_netconfig, 1);
-	nc->rtnl =3D rtnl;
 	nc->ifindex =3D ifindex;
 	nc->v4_enabled =3D true;
 =

@@ -907,8 +916,12 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig=
 *netconfig)
 	l_queue_destroy(netconfig->routes.added, NULL);
 	l_queue_destroy(netconfig->routes.updated, NULL);
 	l_queue_destroy(netconfig->routes.removed, NULL);
-	l_netlink_destroy(netconfig->rtnl);
 	l_free(netconfig);
+
+	rtnl_use_count--;
+
+	if (!rtnl_use_count)
+		l_netlink_destroy(l_steal_ptr(rtnl));
 }
 =

 /*
@@ -1203,6 +1216,115 @@ static void netconfig_do_static_config(struct l_idl=
e *idle, void *user_data)
 	}
 }
 =

+static void netconfig_rtnl_unregister(void *user_data)
+{
+	if (!addr_wait_list || !l_queue_isempty(addr_wait_list))
+		return;
+
+	l_queue_destroy(l_steal_ptr(addr_wait_list), NULL);
+	l_netlink_unregister(rtnl, rtnl_id);
+	rtnl_id =3D 0;
+}
+
+static void netconfig_addr_wait_unregister(struct l_netconfig *nc,
+						bool in_notify)
+{
+	if (nc->ifaddr6_dump_cmd_id) {
+		unsigned int cmd_id =3D nc->ifaddr6_dump_cmd_id;
+
+		nc->ifaddr6_dump_cmd_id =3D 0;
+		l_netlink_cancel(rtnl, cmd_id);
+	}
+
+	if (!l_queue_remove(addr_wait_list, nc))
+		return;
+
+	if (!l_queue_isempty(addr_wait_list))
+		return;
+
+	/* We can't do l_netlink_unregister() inside a notification */
+	if (in_notify)
+		l_idle_oneshot(netconfig_rtnl_unregister, NULL, NULL);
+	else
+		netconfig_rtnl_unregister(NULL);
+}
+
+static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
+					const struct ifaddrmsg *ifa,
+					uint32_t len)
+{
+	struct in6_addr in6;
+	_auto_(l_free) char *ip =3D NULL;
+
+	if (ifa->ifa_flags & IFA_F_TENTATIVE)
+		return;
+
+	if (!nc->started)
+		return;
+
+	l_rtnl_ifaddr6_extract(ifa, len, &ip);
+	inet_pton(AF_INET6, ip, &in6);
+
+	if (!IN6_IS_ADDR_LINKLOCAL(&in6))
+		return;
+
+	netconfig_addr_wait_unregister(nc, true);
+
+	l_dhcp6_client_set_link_local_address(nc->dhcp6_client, ip);
+
+	/*
+	 * Only now that we have a link-local address start actual DHCPv6
+	 * setup.
+	 */
+	if (l_dhcp6_client_start(nc->dhcp6_client))
+		return;
+
+	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+}
+
+static void netconfig_ifaddr_ipv6_notify(uint16_t type, const void *data,
+						uint32_t len, void *user_data)
+{
+	const struct ifaddrmsg *ifa =3D data;
+	uint32_t bytes =3D len - NLMSG_ALIGN(sizeof(struct ifaddrmsg));
+	const struct l_queue_entry *entry, *next;
+
+	switch (type) {
+	case RTM_NEWADDR:
+		/* Iterate safely since elements may be removed */
+		for (entry =3D l_queue_get_entries(addr_wait_list); entry;
+				entry =3D next) {
+			struct l_netconfig *nc =3D entry->data;
+
+			next =3D entry->next;
+			netconfig_ifaddr_ipv6_added(nc, ifa, bytes);
+		}
+
+		break;
+	}
+}
+
+static void netconfig_ifaddr_ipv6_dump_cb(int error, uint16_t type,
+						const void *data, uint32_t len,
+						void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	if (!nc->ifaddr6_dump_cmd_id || !nc->started)
+		return;
+
+	if (error) {
+		netconfig_addr_wait_unregister(nc, false);
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+		return;
+	}
+
+	if (type !=3D RTM_NEWADDR)
+		return;
+
+	netconfig_ifaddr_ipv6_notify(type, data, len, user_data);
+}
+
 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 {
 	if (unlikely(!netconfig || netconfig->started))
@@ -1245,14 +1367,38 @@ configure_ipv6:
 		goto done;
 	}
 =

-	if (!l_dhcp6_client_start(netconfig->dhcp6_client))
-		goto stop_ipv4;
+	/*
+	 * We only care about being on addr_wait_list if we're waiting for
+	 * the link-local address for DHCP6.  Add ourself to the list here
+	 * before we start the dump, instead of after it ends, to eliminate
+	 * the possibility of missing an RTM_NEWADDR between the end of
+	 * the dump command and registering for the events.
+	 */
+	if (!addr_wait_list) {
+		addr_wait_list =3D l_queue_new();
+
+		rtnl_id =3D l_netlink_register(rtnl, RTNLGRP_IPV6_IFADDR,
+						netconfig_ifaddr_ipv6_notify,
+						netconfig, NULL);
+		if (!rtnl_id)
+			goto unregister;
+	}
+
+	netconfig->ifaddr6_dump_cmd_id =3D l_rtnl_ifaddr6_dump(rtnl,
+						netconfig_ifaddr_ipv6_dump_cb,
+						netconfig, NULL);
+	if (!netconfig->ifaddr6_dump_cmd_id)
+		goto unregister;
+
+	l_queue_push_tail(addr_wait_list, netconfig);
 =

 done:
 	netconfig->started =3D true;
 	return true;
 =

-stop_ipv4:
+unregister:
+	netconfig_addr_wait_unregister(netconfig, false);
+
 	if (netconfig->v4_enabled) {
 		if (netconfig->v4_static_addr)
 			l_idle_remove(l_steal_ptr(netconfig->do_static_work));
@@ -1276,6 +1422,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *=
netconfig)
 	if (netconfig->signal_expired_work)
 		l_idle_remove(l_steal_ptr(netconfig->signal_expired_work));
 =

+	netconfig_addr_wait_unregister(netconfig, false);
+
 	netconfig_update_cleanup(netconfig);
 	l_queue_clear(netconfig->routes.current,
 			(l_queue_destroy_func_t) l_rtnl_route_free);
@@ -1339,34 +1487,34 @@ LIB_EXPORT void l_netconfig_apply_rtnl(struct l_net=
config *netconfig)
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_delete(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_ifaddr_delete(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.added); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_ifaddr_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->addresses.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_route_delete(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_route_delete(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.added); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_route_add(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_route_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->routes.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(netconfig->rtnl, netconfig->ifindex,
+		l_rtnl_route_add(rtnl, netconfig->ifindex,
 					entry->data, NULL, NULL, NULL);
 }
 =

-- =

2.32.0

--===============3902293625617028756==--

