Content-Type: multipart/mixed; boundary="===============2309375811514191450=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v6 2/6] dhcp-server: add REQUEST processing
Date: Mon, 19 Oct 2020 18:32:38 -0700
Message-ID: <20201020013242.1575694-2-prestwoj@gmail.com>
In-Reply-To: <20201020013242.1575694-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2309375811514191450==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle REQUEST packets and implement ACK/NAK responses.
---
 ell/dhcp-server.c | 91 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 91 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 1af7465..2008c56 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -44,6 +44,10 @@
 /* 5 minutes  */
 #define OFFER_TIME (5*60)
 =

+static const uint8_t MAC_BCAST_ADDR[ETH_ALEN] =3D {
+	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+};
+
 struct l_dhcp_server {
 	bool started;
 	int ifindex;
@@ -357,6 +361,73 @@ static void send_offer(struct l_dhcp_server *server,
 		SERVER_DEBUG("Failed to send OFFER");
 }
 =

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
+	if (server->transport->l2_send(server->transport, server->address,
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
+	if (server->transport->l2_send(server->transport, server->address,
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
 static void listener_event(const void *data, size_t len, void *user_data)
 {
 	struct l_dhcp_server *server =3D user_data;
@@ -412,6 +483,26 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 =

 		send_offer(server, message, lease, requested_ip_opt);
 =

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
 		break;
 	}
 }
-- =

2.26.2

--===============2309375811514191450==--

