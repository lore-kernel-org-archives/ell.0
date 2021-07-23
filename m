Content-Type: multipart/mixed; boundary="===============1261884411731697837=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/8] dhcp-server: Copy client identifier from the client
 message
Date: Fri, 23 Jul 2021 20:23:29 +0200
Message-ID: <20210723182331.135123-6-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1261884411731697837==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As mandated by RFC 6842 copy the client identifier option from the
client message we're replying to into the reply message.
---
 ell/dhcp-server.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 2d90f8b..21adcab 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -524,6 +524,16 @@ static void add_server_options(struct l_dhcp_server *s=
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
@@ -569,6 +579,7 @@ static void send_offer(struct l_dhcp_server *server,
 					4, &server->address);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, client_id);
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

@@ -579,7 +590,8 @@ static void send_offer(struct l_dhcp_server *server,
 }
 =

 static void send_inform(struct l_dhcp_server *server,
-				const struct dhcp_message *client_msg)
+				const struct dhcp_message *client_msg,
+				const uint8_t *client_id)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -592,6 +604,7 @@ static void send_inform(struct l_dhcp_server *server,
 	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_ACK);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, client_id);
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

@@ -599,7 +612,8 @@ static void send_inform(struct l_dhcp_server *server,
 }
 =

 static void send_nak(struct l_dhcp_server *server,
-			const struct dhcp_message *client_msg)
+			const struct dhcp_message *client_msg,
+			const uint8_t *client_id)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -610,7 +624,7 @@ static void send_nak(struct l_dhcp_server *server,
 	server_message_init(server, client_msg, reply);
 =

 	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_NAK);
-
+	copy_client_id(&builder, client_id);
 	_dhcp_message_builder_finalize(&builder, &len);
 =

 	server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_NAK);
@@ -638,6 +652,7 @@ static void send_ack(struct l_dhcp_server *server,
 					4, &lease_time);
 =

 	add_server_options(server, &builder);
+	copy_client_id(&builder, lease->client_id);
 =

 	_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &server->address);
@@ -733,7 +748,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		 */
 		if (server_id_opt && server_id_opt !=3D server->address) {
 			if (server->authoritative) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 =

@@ -756,7 +771,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		if (!lease) {
 			if (server_id_opt =3D=3D server->address ||
 					server->authoritative)
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 =

 			break;
 		}
@@ -788,7 +803,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			if (!lease->offering ||
 					(requested_ip_opt &&
 					 requested_ip_opt !=3D lease->address)) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 		} else {
@@ -800,7 +815,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			if (lease->offering ||
 					(requested_ip_opt &&
 					 requested_ip_opt !=3D lease->address)) {
-				send_nak(server, message);
+				send_nak(server, message, client_id_opt);
 				break;
 			}
 		}
@@ -835,7 +850,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		if (server_id_opt && server_id_opt !=3D server->address)
 			break;
 =

-		send_inform(server, message);
+		send_inform(server, message, client_id_opt);
 		break;
 	}
 }
-- =

2.30.2

--===============1261884411731697837==--

