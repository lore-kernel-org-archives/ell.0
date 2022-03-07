Content-Type: multipart/mixed; boundary="===============7494371590735627238=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 10/12] netconfig: Add l_netconfig_apply_rtnl
Date: Mon, 07 Mar 2022 15:55:41 +0100
Message-ID: <20220307145543.1558788-10-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============7494371590735627238==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add l_netconfig_apply_rtnl and the getters for current lists of routes
and addresses for the netconfig user to be able to commit address and
route changes.
---
 ell/ell.sym     |  3 ++
 ell/netconfig.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netconfig.h | 11 ++++++++
 3 files changed, 87 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 1dcee15..a03dc69 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -739,6 +739,9 @@ global:
 	l_netconfig_stop;
 	l_netconfig_get_dhcp_client;
 	l_netconfig_set_event_handler;
+	l_netconfig_apply_rtnl;
+	l_netconfig_get_addresses;
+	l_netconfig_get_routes;
 local:
 	*;
 };
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 8927aa8..25f0cf2 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -375,3 +375,76 @@ LIB_EXPORT void l_netconfig_set_event_handler(struct l=
_netconfig *netconfig,
 	netconfig->handler.user_data =3D user_data;
 	netconfig->handler.destroy =3D destroy;
 }
+
+LIB_EXPORT void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
+					struct l_netlink *rtnl)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(netconfig->addresses.removed); entry;
+			entry =3D entry->next)
+		l_rtnl_ifaddr_delete(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+
+	for (entry =3D l_queue_get_entries(netconfig->addresses.added); entry;
+			entry =3D entry->next)
+		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+
+	/* We can use l_rtnl_ifaddr_add here since that uses NLM_F_REPLACE */
+	for (entry =3D l_queue_get_entries(netconfig->addresses.updated); entry;
+			entry =3D entry->next)
+		l_rtnl_ifaddr_add(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+
+	for (entry =3D l_queue_get_entries(netconfig->routes.removed); entry;
+			entry =3D entry->next)
+		l_rtnl_route_delete(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+
+	for (entry =3D l_queue_get_entries(netconfig->routes.added); entry;
+			entry =3D entry->next)
+		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+
+	/* We can use l_rtnl_route_add here since that uses NLM_F_REPLACE */
+	for (entry =3D l_queue_get_entries(netconfig->routes.updated); entry;
+			entry =3D entry->next)
+		l_rtnl_route_add(rtnl, netconfig->ifindex, entry->data,
+					NULL, NULL, NULL);
+}
+
+LIB_EXPORT struct l_queue *l_netconfig_get_addresses(
+						struct l_netconfig *netconfig,
+						struct l_queue **out_added,
+						struct l_queue **out_updated,
+						struct l_queue **out_removed)
+{
+	if (out_added)
+		*out_added =3D netconfig->addresses.added;
+
+	if (out_updated)
+		*out_updated =3D netconfig->addresses.updated;
+
+	if (out_removed)
+		*out_removed =3D netconfig->addresses.removed;
+
+	return netconfig->addresses.current;
+}
+
+LIB_EXPORT struct l_queue *l_netconfig_get_routes(struct l_netconfig *netc=
onfig,
+						struct l_queue **out_added,
+						struct l_queue **out_updated,
+						struct l_queue **out_removed)
+{
+	if (out_added)
+		*out_added =3D netconfig->routes.added;
+
+	if (out_updated)
+		*out_updated =3D netconfig->routes.updated;
+
+	if (out_removed)
+		*out_removed =3D netconfig->routes.removed;
+
+	return netconfig->routes.current;
+}
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 7773885..682f4aa 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -65,6 +65,17 @@ void l_netconfig_set_event_handler(struct l_netconfig *n=
etconfig,
 					void *user_data,
 					l_netconfig_destroy_cb_t destroy);
 =

+void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
+				struct l_netlink *rtnl);
+struct l_queue *l_netconfig_get_addresses(struct l_netconfig *netconfig,
+					struct l_queue **out_added,
+					struct l_queue **out_updated,
+					struct l_queue **out_removed);
+struct l_queue *l_netconfig_get_routes(struct l_netconfig *netconfig,
+					struct l_queue **out_added,
+					struct l_queue **out_updated,
+					struct l_queue **out_removed);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.32.0

--===============7494371590735627238==--

