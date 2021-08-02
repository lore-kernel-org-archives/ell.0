Content-Type: multipart/mixed; boundary="===============8502932241422988003=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/15] dhcp-server: Copy client identifier from the client
 message
Date: Mon, 02 Aug 2021 16:04:14 +0200
Message-ID: <20210802140424.170150-5-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8502932241422988003==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As mandated by RFC 6842 copy the client identifier option from the
client message we're replying to into the reply message.
---
 ell/dhcp-server.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index e4d9d72..5c511f7 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -525,6 +525,16 @@ static void add_server_options(struct l_dhcp_server *s=
erver,
 	}
 }
 =

+/* Copy the client identifier option from the client message per RFC6842 */
+static void copy_client_id(struct dhcp_message_builder *builder,
+				const uint8_t *client_id)
+{
+	if (client_id)
+		_dhcp_message_builder_append(builder,
+						DHCP_OPTION_CLIENT_IDENTIFIER,
+						client_id[0], client_id + 1);
+}
+
 static void send_offer(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
 			struct l_dhcp_lease *lease, uint32_t requested_ip,
@@ -570,6 +580,7 @@ static void send_offer(struct l_dhcp_server *server,
 					4, &server->address);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, client_id);
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

@@ -580,7 +591,8 @@ static void send_offer(struct l_dhcp_server *server,
 }
 =

 static void send_inform(struct l_dhcp_server *server,
-				const struct dhcp_message *client_msg)
+				const struct dhcp_message *client_msg,
+				const uint8_t *client_id)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -593,6 +605,7 @@ static void send_inform(struct l_dhcp_server *server,
 	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_ACK);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, client_id);
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

@@ -600,7 +613,8 @@ static void send_inform(struct l_dhcp_server *server,
 }
 =

 static void send_nak(struct l_dhcp_server *server,
-			const struct dhcp_message *client_msg)
+			const struct dhcp_message *client_msg,
+			const uint8_t *client_id)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -611,7 +625,7 @@ static void send_nak(struct l_dhcp_server *server,
 	server_message_init(server, client_msg, reply);
 =

 	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_NAK);
-
+	copy_client_id(&builder, client_id);
 	_dhcp_message_builder_finalize(&builder, &len);
 =

 	server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_NAK);
@@ -640,6 +654,7 @@ static void send_ack(struct l_dhcp_server *server,
 					4, &lease_time);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, client_id);
 =

 	_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &server->address);
@@ -738,7 +753,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		 */
 		if (!server_id_match) {
 			if (server->authoritative) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 =

@@ -760,7 +775,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		 */
 		if (!lease) {
 			if (server_id_opt || server->authoritative)
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 =

 			break;
 		}
@@ -792,7 +807,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			if (!lease->offering ||
 					(requested_ip_opt &&
 					 requested_ip_opt !=3D lease->address)) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 		} else {
@@ -804,7 +819,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			if (lease->offering ||
 					(requested_ip_opt &&
 					 requested_ip_opt !=3D lease->address)) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 		}
@@ -839,7 +854,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		if (!server_id_match)
 			break;
 =

-		send_inform(server, message);
+		send_inform(server, message, client_id_opt);
 		break;
 	}
 }
-- =

2.30.2

--===============8502932241422988003==--

