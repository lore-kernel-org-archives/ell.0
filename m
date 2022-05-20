Content-Type: multipart/mixed; boundary="===============0458544762393425995=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 05/15] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Fri, 20 May 2022 17:43:28 +0200
Message-ID: <20220520154338.2056273-5-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============0458544762393425995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since we'll need to keep an internal RTNL socket for DHCPv6
functionality anyway, change l_netconfig_apply_rtnl's signature to not
require an rtnl parameter.
---
 ell/netconfig.c | 24 ++++++++++++++++--------
 ell/netconfig.h |  3 +--
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 2a1b3ed..f1cbbb9 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -64,6 +64,7 @@ struct l_netconfig {
 	char **v6_dns_override;
 	char **v6_domain_names_override;
 =

+	struct l_netlink *rtnl;
 	bool started;
 	struct l_idle *do_static_work;
 	bool v4_configured;
@@ -1166,6 +1167,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *=
netconfig)
 =

 	l_dhcp_client_stop(netconfig->dhcp_client);
 	l_dhcp6_client_stop(netconfig->dhcp6_client);
+
+	l_rtnl_put(&netconfig->rtnl);
 }
 =

 LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhcp_client(
@@ -1211,41 +1214,46 @@ LIB_EXPORT void l_netconfig_set_event_handler(struc=
t l_netconfig *netconfig,
 	netconfig->handler.destroy =3D destroy;
 }
 =

-LIB_EXPORT void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
-					struct l_netlink *rtnl)
+LIB_EXPORT void l_netconfig_apply_rtnl(struct l_netconfig *netconfig)
 {
 	const struct l_queue_entry *entry;
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_delete(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_ifaddr_delete(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.added); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_ifaddr_add(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_ifaddr_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->addresses.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_ifaddr_add(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_route_delete(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_route_delete(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.added); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_route_add(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_route_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->routes.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
+		l_rtnl_route_add(l_rtnl_get(&netconfig->rtnl),
+					netconfig->ifindex, entry->data,
 					NULL, NULL, NULL);
 }
 =

diff --git a/ell/netconfig.h b/ell/netconfig.h
index 7796a2f..fddbac1 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -85,8 +85,7 @@ void l_netconfig_set_event_handler(struct l_netconfig *ne=
tconfig,
 					void *user_data,
 					l_netconfig_destroy_cb_t destroy);
 =

-void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
-				struct l_netlink *rtnl);
+void l_netconfig_apply_rtnl(struct l_netconfig *netconfig);
 const struct l_queue_entry *l_netconfig_get_addresses(
 				struct l_netconfig *netconfig,
 				const struct l_queue_entry **out_added,
-- =

2.32.0

--===============0458544762393425995==--

