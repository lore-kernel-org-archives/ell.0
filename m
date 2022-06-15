Content-Type: multipart/mixed; boundary="===============5387573485178479294=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 03/14] netconfig: Drop rtnl parameter to l_netconfig_apply_rtnl
Date: Thu, 16 Jun 2022 00:47:28 +0200
Message-ID: <20220615224739.1936538-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220615224739.1936538-1-andrew.zaborowski@intel.com

--===============5387573485178479294==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the newly added l_rtnl_get() to get the global rtnl socket and use
that in l_netconfig_apply_rtnl.  We'd have needed an internal RTNL
instance anyway, for the link-local address tracking for DHCPv6.
---
 ell/netconfig.c | 27 +++++++++++++--------------
 ell/netconfig.h |  3 +--
 2 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index c7251c2..8c07338 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1223,42 +1223,41 @@ LIB_EXPORT void l_netconfig_set_event_handler(struc=
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
+		l_rtnl_ifaddr_delete(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->addresses.added); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_ifaddr_add(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_ifaddr_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->addresses.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_ifaddr_add(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.removed); entry;
 			entry =3D entry->next)
-		l_rtnl_route_delete(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_delete(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	for (entry =3D l_queue_get_entries(netconfig->routes.added); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_add(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 =

 	/* We can use l_rtnl_route_add here since that uses NLM_F_REPLACE */
 	for (entry =3D l_queue_get_entries(netconfig->routes.updated); entry;
 			entry =3D entry->next)
-		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
-					NULL, NULL, NULL);
+		l_rtnl_route_add(l_rtnl_get(), netconfig->ifindex,
+					entry->data, NULL, NULL, NULL);
 }
 =

 LIB_EXPORT const struct l_queue_entry *l_netconfig_get_addresses(
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

2.34.1

--===============5387573485178479294==--

