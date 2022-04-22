Content-Type: multipart/mixed; boundary="===============6708965299589728929=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 07/13] netconfig: Avoid returning internal l_queues
Date: Fri, 22 Apr 2022 20:59:46 +0200
Message-ID: <20220422185952.105279-7-andrew.zaborowski@intel.com>
In-Reply-To: 20220422185952.105279-1-andrew.zaborowski@intel.com

--===============6708965299589728929==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Return const struct l_queue_entry pointers instead.
---
 ell/netconfig.c | 35 ++++++++++++++++++-----------------
 ell/netconfig.h | 20 +++++++++++---------
 2 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 1581ea9..9b3e11e 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1097,37 +1097,38 @@ LIB_EXPORT void l_netconfig_apply_rtnl(struct l_net=
config *netconfig,
 					NULL, NULL, NULL);
 }
 =

-LIB_EXPORT struct l_queue *l_netconfig_get_addresses(
-						struct l_netconfig *netconfig,
-						struct l_queue **out_added,
-						struct l_queue **out_updated,
-						struct l_queue **out_removed)
+LIB_EXPORT const struct l_queue_entry *l_netconfig_get_addresses(
+					struct l_netconfig *netconfig,
+					const struct l_queue_entry **out_added,
+					const struct l_queue_entry **out_updated,
+					const struct l_queue_entry **out_removed)
 {
 	if (out_added)
-		*out_added =3D netconfig->addresses.added;
+		*out_added =3D l_queue_get_entries(netconfig->addresses.added);
 =

 	if (out_updated)
-		*out_updated =3D netconfig->addresses.updated;
+		*out_updated =3D l_queue_get_entries(netconfig->addresses.updated);
 =

 	if (out_removed)
-		*out_removed =3D netconfig->addresses.removed;
+		*out_removed =3D l_queue_get_entries(netconfig->addresses.removed);
 =

-	return netconfig->addresses.current;
+	return l_queue_get_entries(netconfig->addresses.current);
 }
 =

-LIB_EXPORT struct l_queue *l_netconfig_get_routes(struct l_netconfig *netc=
onfig,
-						struct l_queue **out_added,
-						struct l_queue **out_updated,
-						struct l_queue **out_removed)
+LIB_EXPORT const struct l_queue_entry *l_netconfig_get_routes(
+					struct l_netconfig *netconfig,
+					const struct l_queue_entry **out_added,
+					const struct l_queue_entry **out_updated,
+					const struct l_queue_entry **out_removed)
 {
 	if (out_added)
-		*out_added =3D netconfig->routes.added;
+		*out_added =3D l_queue_get_entries(netconfig->routes.added);
 =

 	if (out_updated)
-		*out_updated =3D netconfig->routes.updated;
+		*out_updated =3D l_queue_get_entries(netconfig->routes.updated);
 =

 	if (out_removed)
-		*out_removed =3D netconfig->routes.removed;
+		*out_removed =3D l_queue_get_entries(netconfig->routes.removed);
 =

-	return netconfig->routes.current;
+	return l_queue_get_entries(netconfig->routes.current);
 }
diff --git a/ell/netconfig.h b/ell/netconfig.h
index a50a895..7796a2f 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -33,7 +33,7 @@ struct l_dhcp_client;
 struct l_dhcp6_client;
 struct l_icmp6_client;
 struct l_netlink;
-struct l_queue;
+struct l_queue_entry;
 struct l_netconfig;
 struct l_rtnl_address;
 struct l_rtnl_route;
@@ -87,14 +87,16 @@ void l_netconfig_set_event_handler(struct l_netconfig *=
netconfig,
 =

 void l_netconfig_apply_rtnl(struct l_netconfig *netconfig,
 				struct l_netlink *rtnl);
-struct l_queue *l_netconfig_get_addresses(struct l_netconfig *netconfig,
-					struct l_queue **out_added,
-					struct l_queue **out_updated,
-					struct l_queue **out_removed);
-struct l_queue *l_netconfig_get_routes(struct l_netconfig *netconfig,
-					struct l_queue **out_added,
-					struct l_queue **out_updated,
-					struct l_queue **out_removed);
+const struct l_queue_entry *l_netconfig_get_addresses(
+				struct l_netconfig *netconfig,
+				const struct l_queue_entry **out_added,
+				const struct l_queue_entry **out_updated,
+				const struct l_queue_entry **out_removed);
+const struct l_queue_entry *l_netconfig_get_routes(
+				struct l_netconfig *netconfig,
+				const struct l_queue_entry **out_added,
+				const struct l_queue_entry **out_updated,
+				const struct l_queue_entry **out_removed);
 =

 #ifdef __cplusplus
 }
-- =

2.32.0

--===============6708965299589728929==--

