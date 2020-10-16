Content-Type: multipart/mixed; boundary="===============3703979596537434029=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v4 02/11] dhcp-server: add transport framework
Date: Fri, 16 Oct 2020 13:23:46 -0700
Message-ID: <20201016202355.1248245-2-prestwoj@gmail.com>
In-Reply-To: <20201016202355.1248245-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3703979596537434029==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp-private.h |  4 ++++
 ell/dhcp-server.c  | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 4276479..62abfca 100644
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
@@ -141,6 +142,9 @@ bool _dhcp_client_set_transport(struct l_dhcp_client *c=
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
index 97479ae..b59ec69 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -61,6 +61,8 @@ struct l_dhcp_server {
 	l_dhcp_server_event_cb_t event_handler;
 	void *user_data;
 	l_dhcp_destroy_cb_t event_destroy;
+
+	struct dhcp_transport *transport;
 };
 =

 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
@@ -79,6 +81,23 @@ struct l_dhcp_server {
 	l_util_debug(server->debug_handler, server->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
 =

+static void listener_event(const void *data, size_t len, void *user_data)
+{
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
 LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(int ifindex)
 {
 	struct l_dhcp_server *server =3D l_new(struct l_dhcp_server, 1);
@@ -108,6 +127,7 @@ LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_ser=
ver *server)
 	if (server->event_destroy)
 		server->event_destroy(server->user_data);
 =

+	_dhcp_transport_free(server->transport);
 	l_free(server->ifname);
 =

 	l_queue_destroy(server->lease_list,
@@ -170,8 +190,22 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_serv=
er *server)
 			return false;
 	}
 =

+	if (!server->transport) {
+		server->transport =3D _dhcp_default_transport_new(server->ifindex,
+					server->ifname, DHCP_PORT_SERVER);
+		if (!server->transport)
+			return false;
+	}
+
 	SERVER_DEBUG("Starting DHCP server on %s", server->ifname);
 =

+	if (server->transport->open)
+		if (server->transport->open(server->transport, 0) < 0)
+			return false;
+
+	_dhcp_transport_set_rx_callback(server->transport, listener_event,
+						server);
+
 	server->started =3D true;
 =

 	return true;
@@ -185,6 +219,9 @@ LIB_EXPORT bool l_dhcp_server_stop(struct l_dhcp_server=
 *server)
 	if (!server->started)
 		return true;
 =

+	if (server->transport->close)
+		server->transport->close(server->transport);
+
 	server->started =3D false;
 =

 	/* TODO: Add ability to save leases */
-- =

2.26.2

--===============3703979596537434029==--

