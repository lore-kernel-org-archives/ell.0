Content-Type: multipart/mixed; boundary="===============1929887996213382709=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/13] netconfig: Handle DHCPv6 events
Date: Fri, 22 Apr 2022 20:59:47 +0200
Message-ID: <20220422185952.105279-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220422185952.105279-1-andrew.zaborowski@intel.com

--===============1929887996213382709==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use l_dhcp6_client to support IPv6 address assignment through DHCPv6.
---
 ell/netconfig.c | 132 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 132 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 9b3e11e..b8f5d3f 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -357,6 +357,135 @@ static void netconfig_dhcp_event_handler(struct l_dhc=
p_client *client,
 	}
 }
 =

+static void netconfig_add_dhcp6_address(struct l_netconfig *nc)
+{
+	const struct l_dhcp6_lease *lease =3D
+		l_dhcp6_client_get_lease(nc->dhcp6_client);
+	_auto_(l_free) char *ip =3D NULL;
+	uint32_t prefix_len;
+
+	if (L_WARN_ON(!lease))
+		return;
+
+	ip =3D l_dhcp6_lease_get_address(lease);
+	prefix_len =3D l_dhcp6_lease_get_prefix_length(lease);
+	nc->v6_address =3D l_rtnl_address_new(ip, prefix_len);
+
+	if (L_WARN_ON(!nc->v6_address))
+		return;
+
+	/*
+	 * Assume we already have a route from a Router Advertisement
+	 * covering the address from DHCPv6 + prefix length from DHCPv6.
+	 * We might want to emit a warning of some sort or
+	 * L_NETCONFIG_EVENT_FAILED if we don't since this would
+	 * basically be fatal for IPv6 connectivity.
+	 */
+	l_rtnl_address_set_noprefixroute(nc->v6_address, true);
+
+	l_queue_push_tail(nc->addresses.current, nc->v6_address);
+	l_queue_push_tail(nc->addresses.added, nc->v6_address);
+}
+
+static void netconfig_set_dhcp6_address_lifetimes(struct l_netconfig *nc,
+							bool updated)
+{
+	const struct l_dhcp6_lease *lease =3D
+		l_dhcp6_client_get_lease(nc->dhcp6_client);
+	uint32_t p, v;
+	uint64_t start_time;
+
+	if (L_WARN_ON(!lease))
+		return;
+
+	p =3D l_dhcp6_lease_get_preferred_lifetime(lease);
+	v =3D l_dhcp6_lease_get_valid_lifetime(lease);
+	start_time =3D l_dhcp6_lease_get_start_time(lease);
+
+	l_rtnl_address_set_lifetimes(nc->v6_address, p, v);
+	l_rtnl_address_set_expiry(nc->v6_address,
+					start_time + p * L_USEC_PER_SEC,
+					start_time + v * L_USEC_PER_SEC);
+
+	if (updated)
+		l_queue_push_tail(nc->addresses.updated, nc->v6_address);
+}
+
+static void netconfig_remove_dhcp6_address(struct l_netconfig *nc)
+{
+	l_queue_remove(nc->addresses.current, nc->v6_address);
+	l_queue_push_tail(nc->addresses.removed, nc->v6_address);
+	nc->v6_address =3D NULL;
+}
+
+static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
+						enum l_dhcp6_client_event event,
+						void *user_data)
+{
+	struct l_netconfig *nc =3D user_data;
+
+	switch (event) {
+	case L_DHCP6_CLIENT_EVENT_LEASE_OBTAINED:
+		if (L_WARN_ON(nc->v6_configured))
+			break;
+
+		netconfig_add_dhcp6_address(nc);
+		netconfig_set_dhcp6_address_lifetimes(nc, false);
+		nc->v6_configured =3D true;
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
+		break;
+	case L_DHCP6_CLIENT_EVENT_IP_CHANGED:
+		if (L_WARN_ON(!nc->v6_configured))
+			break;
+
+		netconfig_remove_dhcp6_address(nc);
+		netconfig_add_dhcp6_address(nc);
+		netconfig_set_dhcp6_address_lifetimes(nc, false);
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
+		break;
+	case L_DHCP6_CLIENT_EVENT_LEASE_EXPIRED:
+		if (L_WARN_ON(!nc->v6_configured))
+			break;
+
+		netconfig_remove_dhcp6_address(nc);
+		nc->v6_configured =3D false;
+
+		if (l_dhcp6_client_start(nc->dhcp6_client))
+			/* TODO: also start a new timeout */
+			netconfig_emit_event(nc, AF_INET6,
+						L_NETCONFIG_EVENT_UNCONFIGURE);
+		else
+			netconfig_emit_event(nc, AF_INET6,
+						L_NETCONFIG_EVENT_FAILED);
+
+		break;
+	case L_DHCP6_CLIENT_EVENT_LEASE_RENEWED:
+		if (L_WARN_ON(!nc->v6_configured))
+			break;
+
+		netconfig_set_dhcp6_address_lifetimes(nc, true);
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
+		break;
+	case L_DHCP6_CLIENT_EVENT_NO_LEASE:
+		if (L_WARN_ON(nc->v6_configured))
+			break;
+
+		/*
+		 * The requested address is no longer available, try to restart
+		 * the client.
+		 *
+		 * TODO: this may need to be delayed so we don't flood the
+		 * network with SOLICITs and DECLINEs.  Also add a retry limit
+		 * or better yet a configurable timeout.
+		 */
+		if (!l_dhcp6_client_start(nc->dhcp6_client))
+			netconfig_emit_event(nc, AF_INET6,
+						L_NETCONFIG_EVENT_FAILED);
+
+		break;
+	}
+}
+
 static struct l_rtnl_route *netconfig_find_icmp6_route(
 						struct l_netconfig *nc,
 						const uint8_t *gateway,
@@ -563,6 +692,9 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t=
 ifindex)
 					nc, NULL);
 =

 	nc->dhcp6_client =3D l_dhcp6_client_new(ifindex);
+	l_dhcp6_client_set_event_handler(nc->dhcp6_client,
+					netconfig_dhcp6_event_handler,
+					nc, NULL);
 =

 	nc->icmp6_client =3D l_dhcp6_client_get_icmp6(nc->dhcp6_client);
 	l_icmp6_client_add_event_handler(nc->icmp6_client,
-- =

2.32.0

--===============1929887996213382709==--

