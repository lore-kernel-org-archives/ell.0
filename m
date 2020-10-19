Content-Type: multipart/mixed; boundary="===============6653582670919833559=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v5 08/12] dhcp-server: add INFORM message handling
Date: Mon, 19 Oct 2020 16:28:10 -0700
Message-ID: <20201019232814.1541221-8-prestwoj@gmail.com>
In-Reply-To: <20201019232814.1541221-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6653582670919833559==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows clients to request local configuration details
if their IP is already configured.
---
 ell/dhcp-server.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 482a8b8..3e269e0 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -386,6 +386,30 @@ static void send_offer(struct l_dhcp_server *server,
 		SERVER_DEBUG("Failed to send OFFER");
 }
 =

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
+	if (server->transport->l2_send(server->transport, server->address,
+					DHCP_PORT_SERVER, reply->ciaddr,
+					DHCP_PORT_CLIENT, reply->chaddr,
+					reply, len) < 0)
+		SERVER_DEBUG("Failed to send INFORM");
+}
+
 static void send_nak(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg)
 {
@@ -549,6 +573,11 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 			lease_set_expire(server, lease, time(NULL));
 =

 		break;
+	case DHCP_MESSAGE_TYPE_INFORM:
+		SERVER_DEBUG("Received INFORM");
+
+		send_inform(server, message);
+		break;
 	}
 }
 =

-- =

2.26.2

--===============6653582670919833559==--

