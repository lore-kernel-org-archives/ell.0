Content-Type: multipart/mixed; boundary="===============6284576341934606839=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 10/20] dhcp-server: basic DHCP server skeleton
Date: Fri, 16 Oct 2020 08:36:25 -0700
Message-ID: <20201016153635.660391-10-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6284576341934606839==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am       |   1 +
 ell/dhcp-server.c | 343 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.h        |  39 ++++++
 3 files changed, 383 insertions(+)
 create mode 100644 ell/dhcp-server.c

v2:
 * Broke up the initial server implementation into several
   following commits.

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
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
new file mode 100644
index 0000000..f558493
--- /dev/null
+++ b/ell/dhcp-server.c
@@ -0,0 +1,343 @@
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
+	l_free(server->ifname);
+
+	l_queue_destroy(server->lease_list,
+				(l_queue_destroy_func_t) _dhcp_lease_free);
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
+	if (!server->address) {
+		struct in_addr ia;
+
+		if (!l_net_get_address(server->ifindex, &ia))
+			return false;
+
+		server->address =3D ia.s_addr;
+	}
+
+	if (!server->ifname) {
+		server->ifname =3D l_net_get_name(server->ifindex);
+
+		if (!server->ifname)
+			return false;
+	}
+
+	SERVER_DEBUG("Starting DHCP server on %s", server->ifname);
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

--===============6284576341934606839==--

