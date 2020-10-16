Content-Type: multipart/mixed; boundary="===============2460008754550081013=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 14/14] dhcp: Add support for setting address
Date: Fri, 16 Oct 2020 10:39:14 -0700
Message-ID: <20201016173914.804408-14-prestwoj@gmail.com>
In-Reply-To: <20201016173914.804408-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2460008754550081013==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add optional support for the dhcp client to set the DHCP
address automatically. This is done by providing an RTNL
object with l_dhcp_client_set_rtnl.
---
 ell/dhcp.c | 84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.h |  4 +++
 2 files changed, 88 insertions(+)

v3:
 * Fixed issue with assuming a prefix length of 24
 * Set broadcast address

diff --git a/ell/dhcp.c b/ell/dhcp.c
index d75d86f..1e261c2 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -29,6 +29,7 @@
 #include <linux/types.h>
 #include <net/if_arp.h>
 #include <errno.h>
+#include <arpa/inet.h>
 =

 #include "private.h"
 #include "random.h"
@@ -38,6 +39,8 @@
 #include "timeout.h"
 #include "dhcp.h"
 #include "dhcp-private.h"
+#include "netlink.h"
+#include "rtnl.h"
 =

 #define CLIENT_DEBUG(fmt, args...)					\
 	l_util_debug(client->debug_handler, client->debug_data,		\
@@ -178,6 +181,9 @@ struct l_dhcp_client {
 	struct l_timeout *timeout_resend;
 	struct l_timeout *timeout_lease;
 	struct l_dhcp_lease *lease;
+	struct l_netlink *rtnl;
+	uint32_t rtnl_add_cmdid;
+	struct l_rtnl_address *rtnl_configured_address;
 	uint8_t attempt;
 	l_dhcp_client_event_cb_t event_handler;
 	void *event_data;
@@ -583,6 +589,24 @@ error:
 	l_dhcp_client_stop(client);
 }
 =

+static void dhcp_client_address_add_cb(int error, uint16_t type,
+						const void *data, uint32_t len,
+						void *user_data)
+{
+	struct l_dhcp_client *client =3D user_data;
+
+	client->rtnl_add_cmdid =3D 0;
+
+	if (error < 0 && error !=3D -EEXIST) {
+		l_rtnl_address_free(client->rtnl_configured_address);
+		client->rtnl_configured_address =3D NULL;
+		CLIENT_DEBUG("Unable to set address on ifindex: %u: %d(%s)",
+				client->ifindex, error,
+				strerror(-error));
+		return;
+	}
+}
+
 static int dhcp_client_receive_ack(struct l_dhcp_client *client,
 					const struct dhcp_message *ack,
 					size_t len)
@@ -626,6 +650,40 @@ static int dhcp_client_receive_ack(struct l_dhcp_clien=
t *client,
 			client->state =3D=3D DHCP_STATE_REBOOTING)
 		r =3D L_DHCP_CLIENT_EVENT_LEASE_OBTAINED;
 =

+	if (client->rtnl) {
+		struct l_rtnl_address *a;
+		L_AUTO_FREE_VAR(char *, ip) =3D
+			l_dhcp_lease_get_address(client->lease);
+		uint8_t prefix_len;
+		uint32_t l =3D l_dhcp_lease_get_lifetime(client->lease);
+		char *netmask =3D l_dhcp_lease_get_netmask(client->lease);
+		char *broadcast =3D l_dhcp_lease_get_broadcast(client->lease);
+		struct in_addr in_addr;
+
+		if (inet_pton(AF_INET, netmask, &in_addr) > 0)
+			prefix_len =3D __builtin_popcountl(in_addr.s_addr);
+		else
+			prefix_len =3D 24;
+
+		l_free(netmask);
+
+		a =3D l_rtnl_address_new(ip, prefix_len);
+		l_rtnl_address_set_noprefixroute(a, true);
+		l_rtnl_address_set_lifetimes(a, l, l);
+		l_rtnl_address_set_broadcast(a, broadcast);
+
+		l_free(broadcast);
+
+		client->rtnl_add_cmdid =3D
+			l_rtnl_ifaddr_add(client->rtnl, client->ifindex, a,
+						dhcp_client_address_add_cb,
+						client, NULL);
+		if (client->rtnl_add_cmdid)
+			client->rtnl_configured_address =3D a;
+		else
+			CLIENT_DEBUG("Configuring address via RTNL failed");
+	}
+
 	return r;
 }
 =

@@ -989,6 +1047,19 @@ LIB_EXPORT bool l_dhcp_client_stop(struct l_dhcp_clie=
nt *client)
 	if (unlikely(!client))
 		return false;
 =

+	if (client->rtnl_add_cmdid) {
+		l_netlink_cancel(client->rtnl, client->rtnl_add_cmdid);
+		client->rtnl_add_cmdid =3D 0;
+	}
+
+	if (client->rtnl_configured_address) {
+		l_rtnl_ifaddr_delete(client->rtnl, client->ifindex,
+					client->rtnl_configured_address,
+					NULL, NULL, NULL);
+		l_rtnl_address_free(client->rtnl_configured_address);
+		client->rtnl_configured_address =3D NULL;
+	}
+
 	l_timeout_remove(client->timeout_resend);
 	client->timeout_resend =3D NULL;
 =

@@ -1042,3 +1113,16 @@ LIB_EXPORT bool l_dhcp_client_set_debug(struct l_dhc=
p_client *client,
 =

 	return true;
 }
+
+LIB_EXPORT bool l_dhcp_client_set_rtnl(struct l_dhcp_client *client,
+					struct l_netlink *rtnl)
+{
+	if (unlikely(!client))
+		return false;
+
+	if (unlikely(client->state !=3D DHCP_STATE_INIT))
+		return false;
+
+	client->rtnl =3D rtnl;
+	return true;
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 0dc349e..e586740 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -31,6 +31,7 @@ extern "C" {
 =

 struct l_dhcp_client;
 struct l_dhcp_lease;
+struct l_netlink;
 struct l_dhcp_server;
 =

 /* RFC 2132 */
@@ -85,6 +86,9 @@ bool l_dhcp_client_set_interface_name(struct l_dhcp_clien=
t *client,
 bool l_dhcp_client_set_hostname(struct l_dhcp_client *client,
 							const char *hostname);
 =

+bool l_dhcp_client_set_rtnl(struct l_dhcp_client *client,
+					struct l_netlink *rtnl);
+
 const struct l_dhcp_lease *l_dhcp_client_get_lease(
 					const struct l_dhcp_client *client);
 =

-- =

2.26.2

--===============2460008754550081013==--

