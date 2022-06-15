Content-Type: multipart/mixed; boundary="===============6022892529801767914=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 10/14] netconfig: Write gateway MAC from DHCP to ARP cache
Date: Thu, 16 Jun 2022 00:47:35 +0200
Message-ID: <20220615224739.1936538-10-andrew.zaborowski@intel.com>
In-Reply-To: 20220615224739.1936538-1-andrew.zaborowski@intel.com

--===============6022892529801767914==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Write the MAC directly to the ARP table to save an ARP query for the
gateway's MAC when it is known from the freshly obtained lease.  For
practical reasons do this outside of l_netconfig_apply_rtnl().
---
 ell/netconfig.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 8d0425d..d7b4fd7 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <linux/types.h>
+#include <linux/if_ether.h>
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <netinet/icmp6.h>
@@ -413,6 +414,37 @@ static void netconfig_remove_dhcp_address_routes(struc=
t l_netconfig *nc,
 	}
 }
 =

+static void netconfig_set_neighbor_entry_cb(int error,
+						uint16_t type, const void *data,
+						uint32_t len, void *user_data)
+{
+	/* Not critical.  TODO: log warning */
+}
+
+static int netconfig_dhcp_gateway_to_arp(struct l_netconfig *nc)
+{
+	const struct l_dhcp_lease *lease =3D
+		l_dhcp_client_get_lease(nc->dhcp_client);
+	_auto_(l_free) char *server_id =3D l_dhcp_lease_get_server_id(lease);
+	_auto_(l_free) char *gw =3D l_dhcp_lease_get_gateway(lease);
+	const uint8_t *server_mac =3D l_dhcp_lease_get_server_mac(lease);
+	struct in_addr in_gw;
+
+	if (!gw || strcmp(server_id, gw) || !server_mac)
+		return -ENOENT;
+
+	/* Gateway MAC is known, write it into ARP cache to save ARP traffic */
+	in_gw.s_addr =3D l_dhcp_lease_get_gateway_u32(lease);
+
+	if (!l_rtnl_neighbor_set_hwaddr(l_rtnl_get(), nc->ifindex, AF_INET,
+					&in_gw, server_mac, ETH_ALEN,
+					netconfig_set_neighbor_entry_cb, nc,
+					NULL))
+		return -EIO;
+
+	return 0;
+}
+
 static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
 						enum l_dhcp_client_event event,
 						void *user_data)
@@ -437,6 +469,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_=
client *client,
 		netconfig_set_dhcp_lifetimes(nc, false);
 		nc->v4_configured =3D true;
 		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
+		netconfig_dhcp_gateway_to_arp(nc);
 		break;
 	case L_DHCP_CLIENT_EVENT_LEASE_RENEWED:
 		if (L_WARN_ON(!nc->v4_configured))
-- =

2.34.1

--===============6022892529801767914==--

