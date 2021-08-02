Content-Type: multipart/mixed; boundary="===============7208384222892462312=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/15] dhcp-server: Respect client's broadcast flag
Date: Mon, 02 Aug 2021 16:04:12 +0200
Message-ID: <20210802140424.170150-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7208384222892462312==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Follow notes in RFC2131 4.1, 4.3.2 and 4.4.4 when deciding whether we
can use unicast for a given message.  We want to prefer unicast when
possible but we should follow the spec on the broadcast flag and the
destination address.
---
 ell/dhcp-private.h |  3 ++
 ell/dhcp-server.c  | 90 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 72 insertions(+), 21 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index c422322..f761162 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -66,6 +66,9 @@ enum dhcp_option_overload {
 #define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
 #define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
 =

+/* RFC 2131, Figure 2 */
+#define DHCP_FLAG_BROADCAST (1 << 15)
+
 /* RFC 2131, Figure 1 */
 struct dhcp_message {
 	uint8_t op;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 0e18cf8..910aed7 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -420,6 +420,71 @@ static void server_message_init(struct l_dhcp_server *=
server,
 	reply->ciaddr =3D client_msg->ciaddr;
 }
 =

+static bool server_message_send(struct l_dhcp_server *server,
+				struct dhcp_message *reply, size_t len,
+				uint8_t type)
+{
+	uint32_t daddr;
+	uint16_t dport;
+	const uint8_t *dest_mac;
+
+	/*
+	 * RFC2131 Section 4.1: "If the 'giaddr' field in a DHCP message from
+	 * a client is non-zero, the server sends any return messages to the
+	 * 'DHCP server' port on the BOOTP relay agent whose address appears
+	 * in 'giaddr'. If the 'giaddr' field is zero and the 'ciaddr' field
+	 * is nonzero, then the server unicasts DHCPOFFER and DHCPACK messages
+	 * to the address in 'ciaddr'.  If 'giaddr' is zero and 'ciaddr' is
+	 * zero, and the broadcast bit is set, then the server broadcasts
+	 * DHCPOFFER and DHCPACK messages to 0xffffffff. If the broadcast bit
+	 * is not set and 'giaddr' is zero and 'ciaddr' is zero, then the
+	 * server unicasts DHCPOFFER and DHCPACK messages to the client's
+	 * hardware address and 'yiaddr' address.  In all cases, when 'giaddr'
+	 * is zero, the server broadcasts any DHCPNAK messages to 0xffffffff."
+	 *
+	 * 4.3.2: "If 'giaddr' is set in the DHCPREQUEST message, the client
+	 * is on a different subnet.  The server MUST set the broadcast bit in
+	 * the DHCPNAK, so that the relay agent will broadcast the DHCPNAK to
+	 * the client, because the client may not have a correct network
+	 * address or subnet mask, and the client may not be answering ARP
+	 * requests."
+	 */
+	if (reply->giaddr) {
+		dport =3D DHCP_PORT_SERVER;
+		daddr =3D reply->giaddr;
+		dest_mac =3D reply->chaddr;
+
+		if (type =3D=3D DHCP_MESSAGE_TYPE_NAK)
+			reply->flags |=3D L_CPU_TO_BE16(DHCP_FLAG_BROADCAST);
+	} else {
+		dport =3D DHCP_PORT_CLIENT;
+
+		if (type =3D=3D DHCP_MESSAGE_TYPE_NAK) {
+			daddr =3D 0xffffffff;
+			dest_mac =3D MAC_BCAST_ADDR;
+		} else if (reply->ciaddr) {
+			daddr =3D reply->ciaddr;
+			dest_mac =3D reply->chaddr;
+		} else if (L_BE16_TO_CPU(reply->flags) & DHCP_FLAG_BROADCAST) {
+			daddr =3D 0xffffffff;
+			dest_mac =3D MAC_BCAST_ADDR;
+		} else {
+			daddr =3D reply->yiaddr;
+			dest_mac =3D reply->chaddr;
+		}
+	}
+
+	if (server->transport->l2_send(server->transport, server->address,
+					DHCP_PORT_SERVER, daddr, dport,
+					dest_mac, reply, len) < 0) {
+		SERVER_DEBUG("Failed to send %s",
+				_dhcp_message_type_to_string(type));
+		return false;
+	}
+
+	return true;
+}
+
 static void add_server_options(struct l_dhcp_server *server,
 				struct dhcp_message_builder *builder)
 {
@@ -491,11 +556,7 @@ static void send_offer(struct l_dhcp_server *server,
 	SERVER_DEBUG("Sending OFFER of "NIPQUAD_FMT " to "MAC,
 			NIPQUAD(reply->yiaddr),	MAC_STR(reply->chaddr));
 =

-	if (server->transport->l2_send(server->transport, server->address,
-					DHCP_PORT_SERVER,
-					reply->ciaddr, DHCP_PORT_CLIENT,
-					reply->chaddr, reply, len) < 0)
-		SERVER_DEBUG("Failed to send OFFER");
+	server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_OFFER);
 }
 =

 static void send_inform(struct l_dhcp_server *server,
@@ -515,11 +576,7 @@ static void send_inform(struct l_dhcp_server *server,
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	if (server->transport->l2_send(server->transport, server->address,
-					DHCP_PORT_SERVER, reply->ciaddr,
-					DHCP_PORT_CLIENT, reply->chaddr,
-					reply, len) < 0)
-		SERVER_DEBUG("Failed to send INFORM");
+	server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_INFORM);
 }
 =

 static void send_nak(struct l_dhcp_server *server,
@@ -537,11 +594,7 @@ static void send_nak(struct l_dhcp_server *server,
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	if (server->transport->l2_send(server->transport, server->address,
-					DHCP_PORT_SERVER, reply->ciaddr,
-					DHCP_PORT_CLIENT, MAC_BCAST_ADDR,
-					reply, len) < 0)
-		SERVER_DEBUG("Failed to send NACK");
+	server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_NAK);
 }
 =

 static void send_ack(struct l_dhcp_server *server,
@@ -574,13 +627,8 @@ static void send_ack(struct l_dhcp_server *server,
 =

 	SERVER_DEBUG("Sending ACK to "NIPQUAD_FMT, NIPQUAD(reply->yiaddr));
 =

-	if (server->transport->l2_send(server->transport, server->address,
-					DHCP_PORT_SERVER, reply->ciaddr,
-					DHCP_PORT_CLIENT,
-					reply->chaddr, reply, len) < 0) {
-		SERVER_DEBUG("Failed to send ACK");
+	if (!server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_ACK))
 		return;
-	}
 =

 	lease =3D add_lease(server, false, reply->chaddr, reply->yiaddr);
 =

-- =

2.30.2

--===============7208384222892462312==--

