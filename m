Content-Type: multipart/mixed; boundary="===============5372226531883735701=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 15/15] netconfig: Start ACD before committing static IPv4
Date: Fri, 20 May 2022 17:43:38 +0200
Message-ID: <20220520154338.2056273-15-andrew.zaborowski@intel.com>
In-Reply-To: 20220520154338.2056273-1-andrew.zaborowski@intel.com

--===============5372226531883735701==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When the IPv4 is configured to be static we can use ACD in order to
check that the IP is available and not already in use.  If a
conflict is found netconfig will be reset and no IP will be set on
the interface.  The ACD client is left with the default
'defend once' policy, and probes are not turned off.  This will
increase connection time, but for static IP it is considered the
safe approach.
---
 ell/netconfig.c | 71 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 64 insertions(+), 7 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index f86fcfb..c1a686e 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -53,6 +53,7 @@
 #include "strv.h"
 #include "net.h"
 #include "net-private.h"
+#include "acd.h"
 #include "netconfig.h"
 =

 struct l_netconfig {
@@ -82,6 +83,7 @@ struct l_netconfig {
 	struct l_dhcp6_client *dhcp6_client;
 	struct l_idle *signal_expired_work;
 	struct l_queue *icmp_route_data;
+	struct l_acd *acd;
 =

 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -380,8 +382,8 @@ static void netconfig_set_dhcp_lifetimes(struct l_netco=
nfig *nc, bool updated)
 		l_queue_push_tail(nc->routes.updated, nc->v4_default_route);
 }
 =

-static void netconfig_remove_dhcp_address_routes(struct l_netconfig *nc,
-							bool expired)
+static void netconfig_remove_v4_address_routes(struct l_netconfig *nc,
+						bool expired)
 {
 	struct l_queue *routes =3D
 		expired ? nc->routes.expired : nc->routes.removed;
@@ -457,7 +459,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_=
client *client,
 		if (L_WARN_ON(!nc->v4_configured))
 			break;
 =

-		netconfig_remove_dhcp_address_routes(nc, false);
+		netconfig_remove_v4_address_routes(nc, false);
 		netconfig_add_dhcp_address_routes(nc);
 		netconfig_set_dhcp_lifetimes(nc, false);
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_UPDATE);
@@ -483,7 +485,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_=
client *client,
 		if (L_WARN_ON(!nc->v4_configured))
 			break;
 =

-		netconfig_remove_dhcp_address_routes(nc, true);
+		netconfig_remove_v4_address_routes(nc, true);
 		nc->v4_configured =3D false;
 =

 		if (l_dhcp_client_start(nc->dhcp_client))
@@ -1318,16 +1320,69 @@ static void netconfig_add_v6_static_address_routes(=
struct l_netconfig *nc)
 	netconfig_add_v6_static_routes(nc, ip, prefix_len);
 }
 =

-static void netconfig_do_static_config(struct l_idle *idle, void *user_dat=
a)
+static void netconfig_ipv4_acd_event(enum l_acd_event event, void *user_da=
ta)
 {
 	struct l_netconfig *nc =3D user_data;
 =

-	l_idle_remove(l_steal_ptr(nc->do_static_work));
+	switch (event) {
+	case L_ACD_EVENT_AVAILABLE:
+		if (L_WARN_ON(nc->v4_configured))
+			break;
 =

-	if (nc->v4_static_addr && !nc->v4_configured) {
 		netconfig_add_v4_static_address_routes(nc);
 		nc->v4_configured =3D true;
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
+		break;
+	case L_ACD_EVENT_CONFLICT:
+		if (L_WARN_ON(nc->v4_configured))
+			break;
+
+		/*
+		 * Conflict found, no IP was actually set or routes added so
+		 * just emit the event.
+		 */
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_FAILED);
+		break;
+	case L_ACD_EVENT_LOST:
+		if (L_WARN_ON(!nc->v4_configured))
+			break;
+
+		/*
+		 * Set IP but lost it some time later.  Reset IPv4 in this
+		 * case and emit the FAILED event since we have no way to
+		 * recover from here.
+		 */
+		netconfig_remove_v4_address_routes(nc, false);
+		nc->v4_configured =3D false;
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_FAILED);
+		break;
+	}
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
+		char ip[INET_ADDRSTRLEN];
+
+		l_rtnl_address_get_address(nc->v4_static_addr, ip);
+
+		nc->acd =3D l_acd_new(nc->ifindex);
+                l_acd_set_event_handler(nc->acd, netconfig_ipv4_acd_event,=
 nc,
+					NULL);
+
+		if (!l_acd_start(nc->acd, ip)) {
+			l_acd_destroy(l_steal_ptr(nc->acd));
+
+			/* Configure right now as a fallback */
+			netconfig_add_v4_static_address_routes(nc);
+			nc->v4_configured =3D true;
+			netconfig_emit_event(nc, AF_INET,
+						L_NETCONFIG_EVENT_CONFIGURE);
+		}
 	}
 =

 	if (nc->v6_static_addr && !nc->v6_configured) {
@@ -1590,6 +1645,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *=
netconfig)
 	l_dhcp_client_stop(netconfig->dhcp_client);
 	l_dhcp6_client_stop(netconfig->dhcp6_client);
 =

+	l_acd_destroy(l_steal_ptr(netconfig->acd));
+
 	l_rtnl_put(&netconfig->rtnl);
 }
 =

-- =

2.32.0

--===============5372226531883735701==--

