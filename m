Content-Type: multipart/mixed; boundary="===============1328665324526179550=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 06/13] netconfig: Use an internal rtnl socket for
 l_netconfig_apply_rtnl
Date: Fri, 06 May 2022 01:15:32 +0200
Message-ID: <20220505231539.888792-6-andrew.zaborowski@intel.com>
In-Reply-To: 20220505231539.888792-1-andrew.zaborowski@intel.com

--===============1328665324526179550==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since we'll need to keep an internal RTNL socket for DHCPv6
functionality anyway, change l_netconfig_apply_rtnl's signature to not
require an rtnl parameter.
---
 ell/netconfig.c | 34 ++++++++++++++++++++--------------
 ell/netconfig.h |  3 +--
 2 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 2c5d4ef..12c71a4 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -62,6 +62,7 @@ struct l_netconfig {
 	char **v6_dns_override;
 	char **v6_domain_names_override;
 =

+	struct l_netlink *rtnl;
 	bool started;
 	struct l_idle *do_static_work;
 	bool v4_configured;
@@ -717,8 +718,13 @@ static void netconfig_icmp6_event_handler(struct l_icm=
p6_client *client,
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 {
 	struct l_netconfig *nc;
+	struct l_netlink *rtnl =3D l_netlink_new(NETLINK_ROUTE);
+
+	if (!rtnl)
+		return NULL;
 =

 	nc =3D l_new(struct l_netconfig, 1);
+	nc->rtnl =3D rtnl;
 	nc->ifindex =3D ifindex;
 	nc->v4_enabled =3D true;
 =

@@ -776,6 +782,7 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig =
*netconfig)
 	l_queue_destroy(netconfig->routes.added, NULL);
 	l_queue_destroy(netconfig->routes.updated, NULL);
 	l_queue_destroy(netconfig->routes.removed, NULL);
+	l_netlink_destroy(netconfig->rtnl);
 	l_free(netconfig);
 }
 =

@@ -1170,42 +1177,41 @@ LIB_EXPORT void l_netconfig_set_event_handler(struc=
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
-					NULL, NULL, NULL);
+		l_rtnl_ifaddr_delete(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.added); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_ifaddr_add(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_ifaddr_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->addresses.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_ifaddr_add(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_route_delete(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_delete(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.added); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_add(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_route_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->routes.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_add(netconfig->rtnl, netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 }
 =

 LIB_EXPORT const struct l_queue_entry *l_netconfig_get_addresses(
diff --git a/ell/netconfig.h b/ell/netconfig.h
index d58dda1..874491f 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -81,8 +81,7 @@ void l_netconfig_set_event_handler(struct l_netconfig *ne=
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

--===============1328665324526179550==--

