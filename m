Content-Type: multipart/mixed; boundary="===============5533350192150095290=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 16/20] dhcp-server: add INFORM message handling
Date: Fri, 16 Oct 2020 08:36:31 -0700
Message-ID: <20201016153635.660391-16-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5533350192150095290==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows clients to request local configuration details
if their IP is already configured.
---
 ell/dhcp-server.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index c74cd0b..16f78f1 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -390,6 +390,30 @@ static void send_offer(struct l_dhcp_server *server,
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
@@ -555,6 +579,11 @@ static void listener_event(const void *data, size_t le=
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

--===============5533350192150095290==--

