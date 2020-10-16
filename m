Content-Type: multipart/mixed; boundary="===============5107233744306528461=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 06/14] dhcp-server: process DISCOVER and send OFFER
Date: Fri, 16 Oct 2020 10:39:06 -0700
Message-ID: <20201016173914.804408-6-prestwoj@gmail.com>
In-Reply-To: <20201016173914.804408-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5107233744306528461==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add handling of DISCOVER messages and ability to send offers.
---
 ell/dhcp-server.c | 321 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 321 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index f4624ea..2edf4b4 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -46,6 +46,14 @@
 =

 #define SERVER_PORT 67
 =

+static const uint8_t MAC_BCAST_ADDR[ETH_ALEN] __attribute__((aligned(2))) =
=3D {
+	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+};
+
+static const uint8_t MAC_ANY_ADDR[ETH_ALEN] __attribute__((aligned(2))) =
=3D {
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00
+};
+
 struct l_dhcp_server {
 	bool started;
 	int ifindex;
@@ -86,6 +94,14 @@ struct l_dhcp_server {
 	l_util_debug(server->debug_handler, server->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
 =

+static bool is_expired_lease(struct l_dhcp_lease *lease)
+{
+	if (lease->lifetime < time(NULL))
+		return true;
+
+	return false;
+}
+
 static bool match_lease_mac(const void *data, const void *user_data)
 {
 	const struct l_dhcp_lease *lease =3D data;
@@ -100,8 +116,313 @@ static struct l_dhcp_lease *find_lease_by_mac(struct =
l_dhcp_server *server,
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

+/* Clear the old lease and create the new one */
+static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
+				const uint8_t *mac,
+				struct l_dhcp_lease **lease_out)
+{
+	struct l_dhcp_lease *lease;
+
+	if (yiaddr =3D=3D 0)
+		return -ENXIO;
+
+	if (yiaddr < server->start_ip)
+		return -ENXIO;
+
+	if (yiaddr > server->end_ip)
+		return -ENXIO;
+
+	if (memcmp(mac, MAC_BCAST_ADDR, ETH_ALEN) =3D=3D 0)
+		return -ENXIO;
+
+	if (memcmp(mac, MAC_ANY_ADDR, ETH_ALEN) =3D=3D 0)
+		return -ENXIO;
+
+	lease =3D find_lease_by_mac(server, mac);
+
+	if (lease) {
+		l_queue_remove(server->lease_list, lease);
+
+		*lease_out =3D lease;
+
+		return 0;
+	}
+
+	*lease_out =3D l_new(struct l_dhcp_lease, 1);
+	if (!*lease_out)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int compare_lifetime(const void *a, const void *b, void *user_data)
+{
+	const struct l_dhcp_lease *lease1 =3D a;
+	const struct l_dhcp_lease *lease2 =3D b;
+
+	return lease2->lifetime - lease1->lifetime;
+}
+
+static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
+					uint32_t expire, const uint8_t *chaddr,
+					uint32_t yiaddr)
+{
+	struct l_dhcp_lease *lease =3D NULL;
+	int ret;
+
+	ret =3D get_lease(server, yiaddr, chaddr, &lease);
+	if (ret !=3D 0)
+		return NULL;
+
+	memset(lease, 0, sizeof(*lease));
+
+	memcpy(lease->mac, chaddr, ETH_ALEN);
+	lease->address =3D yiaddr;
+
+	if (expire =3D=3D 0)
+		lease->lifetime =3D time(NULL) + server->lease_seconds;
+	else
+		lease->lifetime =3D expire;
+
+	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
+
+	SERVER_DEBUG("added lease IP %s for "MAC " lifetime=3D%u",
+			IP_STR(yiaddr), MAC_STR(chaddr),
+			lease->lifetime);
+
+	return lease;
+}
+
+static bool match_lease_ip(const void *data, const void *user_data)
+{
+	const struct l_dhcp_lease *lease =3D data;
+
+	return lease->address =3D=3D L_PTR_TO_UINT(user_data);
+}
+
+static struct l_dhcp_lease *find_lease_by_nip(struct l_dhcp_server *server,
+						uint32_t nip)
+{
+	return l_queue_find(server->lease_list, match_lease_ip,
+				L_INT_TO_PTR(nip));
+}
+
+static bool check_requested_nip(struct l_dhcp_server *server,
+				uint32_t requested_nip)
+{
+	struct l_dhcp_lease *lease;
+
+	if (requested_nip =3D=3D 0)
+		return false;
+
+	if (requested_nip < server->start_ip)
+		return false;
+
+	if (requested_nip > server->end_ip)
+		return false;
+
+	lease =3D find_lease_by_nip(server, requested_nip);
+	if (!lease)
+		return true;
+
+	if (!is_expired_lease(lease))
+		return false;
+
+	return true;
+}
+
+/* Check if the IP is taken; if it is, add it to the lease table */
+static bool arp_check(uint32_t nip, const uint8_t *safe_mac)
+{
+	/* TODO: Add ARP checking */
+	return true;
+}
+
+static uint32_t find_free_or_expired_nip(struct l_dhcp_server *server,
+						const uint8_t *safe_mac)
+{
+	uint32_t ip_addr;
+	struct l_dhcp_lease *lease;
+
+	for (ip_addr =3D server->start_ip; ip_addr <=3D server->end_ip; ip_addr++=
) {
+		/* e.g. 192.168.55.0 */
+		if ((ip_addr & 0xff) =3D=3D 0)
+			continue;
+
+		/* e.g. 192.168.55.255 */
+		if ((ip_addr & 0xff) =3D=3D 0xff)
+			continue;
+
+		lease =3D find_lease_by_nip(server, ip_addr);
+		if (lease)
+			continue;
+
+		if (arp_check(ip_addr, safe_mac))
+			return ip_addr;
+	}
+
+	lease =3D l_queue_peek_tail(server->lease_list);
+	if (!lease)
+		return 0;
+
+	if (!is_expired_lease(lease))
+		return 0;
+
+	if (!arp_check(lease->address, safe_mac))
+		return 0;
+
+	return lease->address;
+}
+
+static void server_message_init(struct l_dhcp_server *server,
+				const struct dhcp_message *client_msg,
+				struct dhcp_message *reply)
+{
+	reply->xid =3D client_msg->xid;
+	memcpy(reply->chaddr, client_msg->chaddr, sizeof(client_msg->chaddr));
+	reply->flags =3D client_msg->flags;
+	reply->giaddr =3D client_msg->giaddr;
+	reply->ciaddr =3D client_msg->ciaddr;
+}
+
+static void add_server_options(struct l_dhcp_server *server,
+				struct dhcp_message_builder *builder)
+{
+	int i;
+
+	if (server->netmask)
+		_dhcp_message_builder_append(builder, L_DHCP_OPTION_SUBNET_MASK,
+						4, &server->netmask);
+
+	if (server->gateway)
+		_dhcp_message_builder_append(builder, L_DHCP_OPTION_ROUTER,
+						4, &server->gateway);
+
+	if (server->dns_list) {
+		for (i =3D 0; server->dns_list[i]; i++);
+
+		_dhcp_message_builder_append(builder,
+					L_DHCP_OPTION_DOMAIN_NAME_SERVER,
+					i * 4, server->dns_list);
+	}
+}
+
+static void send_offer(struct l_dhcp_server *server,
+			const struct dhcp_message *client_msg,
+			struct l_dhcp_lease *lease, uint32_t requested_nip)
+{
+	struct dhcp_message_builder builder;
+	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
+	L_AUTO_FREE_VAR(struct dhcp_message *, reply);
+	uint32_t lease_time =3D L_CPU_TO_BE32(server->lease_seconds);
+
+	reply =3D (struct dhcp_message *) l_new(uint8_t, len);
+
+	if (lease)
+		reply->yiaddr =3D lease->address;
+	else if (check_requested_nip(server, requested_nip))
+		reply->yiaddr =3D requested_nip;
+	else
+		reply->yiaddr =3D find_free_or_expired_nip(server,
+							client_msg->chaddr);
+
+	if (!reply->yiaddr) {
+		SERVER_DEBUG("Could not find lease or send offer");
+		return;
+	}
+
+	lease =3D add_lease(server, OFFER_TIME, client_msg->chaddr,
+				reply->yiaddr);
+	if (!lease) {
+		SERVER_DEBUG("No free IP addresses, OFFER abandoned");
+		return;
+	}
+
+	server_message_init(server, client_msg, reply);
+
+	_dhcp_message_builder_init(&builder, reply, len,
+					DHCP_MESSAGE_TYPE_OFFER);
+
+	_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_IP_ADDRESS_LEASE_TIME,
+					4, &lease_time);
+
+	_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SERVER_IDENTIFIER,
+					4, &server->address);
+
+	add_server_options(server, &builder);
+
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	SERVER_DEBUG("Sending OFFER of %s to "MAC, IP_STR(reply->yiaddr),
+			MAC_STR(reply->chaddr));
+
+	if (server->transport->l2_send(server->transport, server->address,
+					DHCP_PORT_SERVER,
+					reply->ciaddr, DHCP_PORT_CLIENT,
+					reply->chaddr, reply, len) < 0)
+		SERVER_DEBUG("Failed to send OFFER");
+}
+
 static void listener_event(const void *data, size_t len, void *user_data)
 {
+	struct l_dhcp_server *server =3D user_data;
+	const struct dhcp_message *message =3D data;
+	struct dhcp_message_iter iter;
+	uint8_t t, l;
+	const void *v;
+	struct l_dhcp_lease *lease;
+	uint8_t type =3D 0;
+	uint32_t server_id_opt =3D 0;
+	uint32_t requested_ip_opt =3D 0;
+
+	SERVER_DEBUG("");
+
+	if (!_dhcp_message_iter_init(&iter, message, len))
+		return;
+
+	while (_dhcp_message_iter_next(&iter, &t, &l, &v)) {
+		switch (t) {
+		case DHCP_OPTION_MESSAGE_TYPE:
+			if (l =3D=3D 1)
+				type =3D l_get_u8(v);
+
+			break;
+		case L_DHCP_OPTION_SERVER_IDENTIFIER:
+			if (l =3D=3D 4)
+				server_id_opt =3D L_GET_UNALIGNED(
+							(const uint32_t *) v);
+
+			if (server->address !=3D server_id_opt)
+				return;
+
+			break;
+		case L_DHCP_OPTION_REQUESTED_IP_ADDRESS:
+			if (l =3D=3D 4)
+				requested_ip_opt =3D L_GET_UNALIGNED(
+							(const uint32_t *) v);
+
+			break;
+		}
+	}
+
+	if (type =3D=3D 0)
+		return;
+
+	lease =3D find_lease_by_mac(server, message->chaddr);
+	if (!lease)
+		SERVER_DEBUG("No lease found for "MAC,
+					MAC_STR(message->chaddr));
+
+	switch (type) {
+	case DHCP_MESSAGE_TYPE_DISCOVER:
+		SERVER_DEBUG("Received DISCOVER, requested IP %s",
+					IP_STR(requested_ip_opt));
+
+		send_offer(server, message, lease, requested_ip_opt);
+
+		break;
+	}
 }
 =

 bool _dhcp_server_set_transport(struct l_dhcp_server *server,
-- =

2.26.2

--===============5107233744306528461==--

