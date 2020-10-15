Content-Type: multipart/mixed; boundary="===============8582495020857682441=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 10/14] dhcp-server: initial implementation
Date: Thu, 15 Oct 2020 10:17:27 -0700
Message-ID: <20201015171731.396538-10-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8582495020857682441==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This was ported from connman to use ELL instead of GLib. The
only other functional changes were removing the options hash
and IP hash. This was done because there really isn't a need
for super quick access of both options and lease objects since
we are only talking about a maximum of 254 nodes (only 3 in
the options case), and likely much less in the real world.
---
 Makefile.am        |   1 +
 ell/dhcp-private.h |   4 +
 ell/dhcp-server.c  | 856 +++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.h         |  39 +++
 4 files changed, 900 insertions(+)
 create mode 100644 ell/dhcp-server.c

diff --git a/Makefile.am b/Makefile.am
index beba535..9bdf4dc 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -128,6 +128,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp6-transport.c \
 			ell/dhcp6-lease.c \
 			ell/dhcp-util.c \
+			ell/dhcp-server.c \
 			ell/cert.c \
 			ell/cert-private.h \
 			ell/ecc-private.h \
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index bca68d4..8816f53 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -21,6 +21,7 @@
  */
 =

 struct l_dhcp_client;
+struct l_dhcp_server;
 =

 enum {
 	DHCP_PORT_SERVER =3D 67,
@@ -147,6 +148,9 @@ bool _dhcp_client_set_transport(struct l_dhcp_client *c=
lient,
 					struct dhcp_transport *transport);
 void _dhcp_client_override_xid(struct l_dhcp_client *client, uint32_t xid);
 =

+bool _dhcp_server_set_transport(struct l_dhcp_server *server,
+					struct dhcp_transport *transport);
+
 struct l_dhcp_lease {
 	uint32_t address;
 	uint32_t server_address;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
new file mode 100644
index 0000000..d99a900
--- /dev/null
+++ b/ell/dhcp-server.c
@@ -0,0 +1,856 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2020  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <net/ethernet.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <time.h>
+
+#include "private.h"
+#include "time.h"
+#include "net.h"
+#include "dhcp.h"
+#include "dhcp-private.h"
+#include "queue.h"
+#include "util.h"
+#include "strv.h"
+
+/* 8 hours */
+#define DEFAULT_DHCP_LEASE_SEC (8*60*60)
+
+/* 5 minutes  */
+#define OFFER_TIME (5*60)
+
+#define SERVER_PORT 67
+
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
+struct l_dhcp_server {
+	bool started;
+	int ifindex;
+	char *ifname;
+	uint32_t start_ip;
+	uint32_t end_ip;
+	uint32_t address;
+	uint32_t netmask;
+	uint32_t gateway;
+	uint32_t *dns_list;
+	uint32_t lease_seconds;
+
+	struct l_queue *lease_list;
+
+	l_dhcp_debug_cb_t debug_handler;
+	void *debug_data;
+
+	l_dhcp_server_event_cb_t event_handler;
+	void *user_data;
+	l_dhcp_destroy_cb_t event_destroy;
+
+	struct dhcp_transport *transport;
+};
+
+#define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
+
+#define IP_STR(uint_ip) \
+({ \
+	struct in_addr _in; \
+	char *_out; \
+	_in.s_addr =3D uint_ip; \
+	_out =3D inet_ntoa(_in); \
+	_out; \
+})
+
+#define SERVER_DEBUG(fmt, args...)					\
+	l_util_debug(server->debug_handler, server->debug_data,		\
+			"%s:%i " fmt, __func__, __LINE__, ## args)
+
+static bool is_expired_lease(struct l_dhcp_lease *lease)
+{
+	if (lease->lifetime < time(NULL))
+		return true;
+
+	return false;
+}
+
+static bool match_lease_mac(const void *data, const void *user_data)
+{
+	const struct l_dhcp_lease *lease =3D data;
+	const uint8_t *mac =3D user_data;
+
+	return !memcmp(lease->mac, mac, 6);
+}
+
+static struct l_dhcp_lease *find_lease_by_mac(struct l_dhcp_server *server,
+						const uint8_t *mac)
+{
+	return l_queue_find(server->lease_list, match_lease_mac, mac);
+}
+
+static void remove_lease(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease)
+{
+	l_queue_remove(server->lease_list, lease);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+
+	_dhcp_lease_free(lease);
+}
+
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
+static void lease_set_expire(struct l_dhcp_server *server,
+			struct l_dhcp_lease *lease, uint32_t expire)
+{
+	l_queue_remove(server->lease_list, lease);
+
+	lease->lifetime =3D expire;
+
+	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
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
+	if (server->transport->send_raw(server->transport, server->address,
+					DHCP_PORT_SERVER,
+					reply->ciaddr, DHCP_PORT_CLIENT,
+					reply->chaddr, reply, len) < 0)
+		SERVER_DEBUG("Failed to send OFFER");
+}
+
+static void send_inform(struct l_dhcp_server *server,
+				const struct dhcp_message *client_msg)
+{
+	struct dhcp_message_builder builder;
+	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
+	L_AUTO_FREE_VAR(struct dhcp_message *, reply);
+
+	reply =3D (struct dhcp_message *) l_new(uint8_t, len);
+
+	server_message_init(server, client_msg, reply);
+
+	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_ACK);
+
+	add_server_options(server, &builder);
+
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	if (server->transport->send_raw(server->transport, server->address,
+					DHCP_PORT_SERVER, reply->ciaddr,
+					DHCP_PORT_CLIENT, reply->chaddr,
+					reply, len) < 0)
+		SERVER_DEBUG("Failed to send INFORM");
+}
+
+static void send_nak(struct l_dhcp_server *server,
+			const struct dhcp_message *client_msg)
+{
+	struct dhcp_message_builder builder;
+	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
+	L_AUTO_FREE_VAR(struct dhcp_message *, reply);
+
+	reply =3D (struct dhcp_message *) l_new(uint8_t, len);
+
+	server_message_init(server, client_msg, reply);
+
+	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_NAK);
+
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	if (server->transport->send_raw(server->transport, server->address,
+					DHCP_PORT_SERVER, reply->ciaddr,
+					DHCP_PORT_CLIENT, MAC_BCAST_ADDR,
+					reply, len) < 0)
+		SERVER_DEBUG("Failed to send NACK");
+}
+
+static void send_ack(struct l_dhcp_server *server,
+			const struct dhcp_message *client_msg, uint32_t dest)
+{
+	struct dhcp_message_builder builder;
+	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
+	L_AUTO_FREE_VAR(struct dhcp_message *, reply);
+	uint32_t lease_time =3D L_CPU_TO_BE32(server->lease_seconds);
+	struct l_dhcp_lease *lease;
+
+	reply =3D (struct dhcp_message *) l_new(uint8_t, len);
+
+	server_message_init(server, client_msg, reply);
+
+	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_ACK);
+
+	reply->yiaddr =3D dest;
+
+	_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_IP_ADDRESS_LEASE_TIME,
+					4, &lease_time);
+
+	add_server_options(server, &builder);
+
+	_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SERVER_IDENTIFIER,
+					4, &server->address);
+
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	SERVER_DEBUG("Sending ACK to %s", IP_STR(reply->yiaddr));
+
+	if (server->transport->send_raw(server->transport, server->address,
+					DHCP_PORT_SERVER, reply->ciaddr,
+					DHCP_PORT_CLIENT,
+					reply->chaddr, reply, len) < 0) {
+		SERVER_DEBUG("Failed to send ACK");
+		return;
+	}
+
+	lease =3D add_lease(server, 0, reply->chaddr, reply->yiaddr);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
+					server->user_data, lease);
+}
+
+static void listener_event(const void *data, size_t len, void *user_data)
+{
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
+	case DHCP_MESSAGE_TYPE_REQUEST:
+		SERVER_DEBUG("Received REQUEST, requested IP %s",
+				IP_STR(requested_ip_opt));
+
+		if (requested_ip_opt =3D=3D 0) {
+			requested_ip_opt =3D message->ciaddr;
+			if (requested_ip_opt =3D=3D 0)
+				break;
+		}
+
+		if (lease && requested_ip_opt =3D=3D lease->address) {
+			send_ack(server, message, lease->address);
+			break;
+		}
+
+		if (server_id_opt || !lease) {
+			send_nak(server, message);
+			break;
+		}
+		break;
+	case DHCP_MESSAGE_TYPE_DECLINE:
+		SERVER_DEBUG("Received DECLINE");
+
+		if (!server_id_opt || !requested_ip_opt || !lease)
+			break;
+
+		if (requested_ip_opt =3D=3D lease->address)
+			remove_lease(server, lease);
+
+		break;
+	case DHCP_MESSAGE_TYPE_RELEASE:
+		SERVER_DEBUG("Received RELEASE");
+
+		if (!server_id_opt || !lease)
+			break;
+
+		if (message->ciaddr =3D=3D lease->address)
+			lease_set_expire(server, lease, time(NULL));
+
+		break;
+	case DHCP_MESSAGE_TYPE_INFORM:
+		SERVER_DEBUG("Received INFORM");
+
+		send_inform(server, message);
+		break;
+	}
+}
+
+bool _dhcp_server_set_transport(struct l_dhcp_server *server,
+					struct dhcp_transport *transport)
+{
+	if (unlikely(!server))
+		return false;
+
+	if (server->transport)
+		_dhcp_transport_free(server->transport);
+
+	server->transport =3D transport;
+	return true;
+}
+
+LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(int ifindex)
+{
+	struct l_dhcp_server *server =3D l_new(struct l_dhcp_server, 1);
+	if (!server)
+		return NULL;
+
+	server->lease_list =3D l_queue_new();
+
+	server->started =3D false;
+
+	server->lease_seconds =3D DEFAULT_DHCP_LEASE_SEC;
+
+	server->ifindex =3D ifindex;
+	server->debug_handler =3D NULL;
+	server->debug_data =3D NULL;
+
+	return server;
+}
+
+LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_server *server)
+{
+	if (unlikely(!server))
+		return;
+
+	l_dhcp_server_stop(server);
+
+	if (server->event_destroy)
+		server->event_destroy(server->user_data);
+
+	_dhcp_transport_free(server->transport);
+	l_free(server->ifname);
+
+	l_queue_destroy(server->lease_list, _dhcp_lease_free);
+
+	if (server->dns_list)
+		l_free(server->dns_list);
+
+	l_free(server);
+}
+
+LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_server *server)
+{
+	if (unlikely(!server))
+		return false;
+
+	if (server->started)
+		return false;
+
+	if (!server->address)
+		server->address =3D l_net_get_ip_address(server->ifindex);
+
+	if (!server->ifname) {
+		server->ifname =3D l_net_get_name(server->ifindex);
+
+		if (!server->ifname)
+			return false;
+	}
+
+	if (!server->transport) {
+		server->transport =3D _dhcp_default_transport_new(server->ifindex,
+					server->ifname, DHCP_PORT_SERVER);
+		if (!server->transport)
+			return false;
+	}
+
+	SERVER_DEBUG("Starting DHCP server on %s", server->ifname);
+
+	if (server->transport->open)
+		if (server->transport->open(server->transport) < 0)
+			return false;
+
+	_dhcp_transport_set_rx_callback(server->transport, listener_event,
+						server);
+
+	server->started =3D true;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_stop(struct l_dhcp_server *server)
+{
+	if (unlikely(!server))
+		return false;
+
+	if (!server->started)
+		return true;
+
+	if (server->transport->close)
+		server->transport->close(server->transport);
+
+	server->started =3D false;
+
+	/* TODO: Add ability to save leases */
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_ip_range(struct l_dhcp_server *server,
+				const char *start_ip,
+				const char *end_ip)
+{
+	struct in_addr _host_addr;
+
+	if (unlikely(!server || !start_ip || !end_ip))
+		return false;
+
+	if (inet_aton((const char *)start_ip, &_host_addr) =3D=3D 0)
+		return false;
+
+	server->start_ip =3D _host_addr.s_addr;
+
+	if (inet_aton((const char *) end_ip, &_host_addr) =3D=3D 0)
+		return false;
+
+	server->end_ip =3D _host_addr.s_addr;
+
+	return true;
+}
+
+LIB_EXPORT void l_dhcp_server_set_debug(struct l_dhcp_server *server,
+				l_dhcp_debug_cb_t function,
+				void *user_data, l_dhcp_destroy_cb_t destory)
+{
+	if (unlikely(!server))
+		return;
+
+	server->debug_handler =3D function;
+	server->debug_data =3D user_data;
+}
+
+LIB_EXPORT void l_dhcp_server_set_lease_time(struct l_dhcp_server *server,
+					unsigned int lease_time)
+{
+	if (unlikely(!server))
+		return;
+
+	server->lease_seconds =3D lease_time;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_event_handler(struct l_dhcp_server *serv=
er,
+					l_dhcp_server_event_cb_t handler,
+					void *user_data,
+					l_dhcp_destroy_cb_t destroy)
+{
+	if (unlikely(!server))
+		return false;
+
+	server->event_handler =3D handler;
+	server->user_data =3D user_data;
+	server->event_destroy =3D destroy;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_ip_address(struct l_dhcp_server *server,
+						const char *ip)
+{
+	struct in_addr ia;
+
+	if (unlikely(!server))
+		return false;
+
+	if (inet_aton(ip, &ia) < 0)
+		return false;
+
+	server->address =3D ia.s_addr;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_interface_name(struct l_dhcp_server *ser=
ver,
+							const char *ifname)
+{
+	if (unlikely(!server || !ifname))
+		return false;
+
+	l_free(server->ifname);
+	server->ifname =3D l_strdup(ifname);
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_netmask(struct l_dhcp_server *server,
+						const char *mask)
+{
+	struct in_addr ia;
+
+	if (unlikely(!server || !mask))
+		return false;
+
+	if (inet_aton(mask, &ia) < 0)
+		return false;
+
+	server->netmask =3D ia.s_addr;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_gateway(struct l_dhcp_server *server,
+						const char *ip)
+{
+	struct in_addr ia;
+
+	if (unlikely(!server || !ip))
+		return false;
+
+	if (inet_aton(ip, &ia) < 0)
+		return false;
+
+	server->gateway =3D ia.s_addr;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char *=
*dns)
+{
+	unsigned int i;
+	uint32_t *dns_list;
+
+	if (unlikely(!server || !dns))
+		return false;
+
+	dns_list =3D l_new(uint32_t, l_strv_length(dns) + 1);
+
+	for (i =3D 0; dns[i]; i++) {
+		struct in_addr ia;
+
+		if (inet_aton(dns[i], &ia) < 0)
+			goto failed;
+
+		dns_list[i] =3D ia.s_addr;
+	}
+
+	if (server->dns_list)
+		l_free(server->dns_list);
+
+	server->dns_list =3D dns_list;
+
+	return true;
+
+failed:
+	l_free(dns_list);
+	return false;
+}
+
+LIB_EXPORT const struct l_dhcp_lease *l_dhcp_server_get_lease(
+						struct l_dhcp_server *server,
+						const uint8_t *mac)
+{
+	if (unlikely(!server || !mac))
+		return NULL;
+
+	return find_lease_by_mac(server, mac);
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index c78b605..2d630fe 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -31,6 +31,7 @@ extern "C" {
 =

 struct l_dhcp_client;
 struct l_dhcp_lease;
+struct l_dhcp_server;
 =

 /* RFC 2132 */
 enum l_dhcp_option {
@@ -56,12 +57,22 @@ enum l_dhcp_client_event {
 	L_DHCP_CLIENT_EVENT_NO_LEASE,
 };
 =

+enum l_dhcp_server_event {
+	L_DHCP_SERVER_EVENT_NEW_LEASE,
+	L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+};
+
 typedef void (*l_dhcp_client_event_cb_t)(struct l_dhcp_client *client,
 						enum l_dhcp_client_event event,
 						void *userdata);
 typedef void (*l_dhcp_debug_cb_t)(const char *str, void *user_data);
 typedef void (*l_dhcp_destroy_cb_t)(void *userdata);
 =

+typedef void (*l_dhcp_server_event_cb_t)(struct l_dhcp_server *server,
+					enum l_dhcp_server_event event,
+					void *user_data,
+					const struct l_dhcp_lease *lease);
+
 struct l_dhcp_client *l_dhcp_client_new(uint32_t ifindex);
 bool l_dhcp_client_add_request_option(struct l_dhcp_client *client,
 								uint8_t option);
@@ -89,6 +100,7 @@ bool l_dhcp_client_set_debug(struct l_dhcp_client *clien=
t,
 				l_dhcp_debug_cb_t function,
 				void *user_data, l_dhcp_destroy_cb_t destroy);
 =

+
 char *l_dhcp_lease_get_address(const struct l_dhcp_lease *lease);
 char *l_dhcp_lease_get_gateway(const struct l_dhcp_lease *lease);
 char *l_dhcp_lease_get_netmask(const struct l_dhcp_lease *lease);
@@ -101,6 +113,33 @@ const uint8_t *l_dhcp_lease_get_mac(const struct l_dhc=
p_lease *lease);
 uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
 uint32_t l_dhcp_lease_get_lifetime(const struct l_dhcp_lease *lease);
+
+struct l_dhcp_server *l_dhcp_server_new(int ifindex);
+void l_dhcp_server_destroy(struct l_dhcp_server *server);
+bool l_dhcp_server_start(struct l_dhcp_server *server);
+bool l_dhcp_server_stop(struct l_dhcp_server *server);
+bool l_dhcp_server_set_ip_range(struct l_dhcp_server *server,
+				const char *start_ip,
+				const char *end_ip);
+void l_dhcp_server_set_debug(struct l_dhcp_server *server,
+				l_dhcp_debug_cb_t function,
+				void *user_data, l_dhcp_destroy_cb_t destory);
+bool l_dhcp_server_set_event_handler(struct l_dhcp_server *server,
+					l_dhcp_server_event_cb_t handler,
+					void *user_data,
+					l_dhcp_destroy_cb_t destroy);
+void l_dhcp_server_set_lease_time(struct l_dhcp_server *server,
+					unsigned int lease_time);
+bool l_dhcp_server_set_interface_name(struct l_dhcp_server *server,
+					const char *ifname);
+bool l_dhcp_server_set_ip_address(struct l_dhcp_server *server,
+						const char *ip);
+bool l_dhcp_server_set_netmask(struct l_dhcp_server *server, const char *m=
ask);
+bool l_dhcp_server_set_gateway(struct l_dhcp_server *server, const char *i=
p);
+bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char **dns);
+const struct l_dhcp_lease *l_dhcp_server_get_lease(
+						struct l_dhcp_server *server,
+						const uint8_t *mac);
 #ifdef __cplusplus
 }
 #endif
-- =

2.26.2

--===============8582495020857682441==--

