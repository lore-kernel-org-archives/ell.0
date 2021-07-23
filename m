Content-Type: multipart/mixed; boundary="===============6391243406718260664=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/8] dhcp-server: Add "authoritative" mode
Date: Fri, 23 Jul 2021 20:23:24 +0200
Message-ID: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6391243406718260664==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

An authoritative DHCP server basically assumes that there are no other
DHCP servers on the network and replies to DHCPREQUEST messages
requesting IPs from outside of its subnet or with a wrong server ID
value.  This speeds up connections from clients who try to use IP
leases they have cached from other networks and who start their IP
configuration by trying DHCPREQUESTs for those leases.

The term is not defined in the DHCP standard but is used by various
implementations.  Default to authoritative being true.  When set to
false, handle a DHCPREQUEST message directed at other servers by taking
it as meaning the client is declining our own lease offer as mandated
by RFC 2131 on page 16.

Refactor the checks in DHCPREQUEST handling quoting parts of the RFC.
The new checks are stricter and I'm not preserving some of the checks
that didn't seem justified, for example in the
"if (server_id_opt || !lease) ... send_nak()" block it didn't seem to
make sense to only reply to clients who have no lease (offered or
active) and ignore those who do have a lease with a different IP
address, the opposite would make more sense.
---
 ell/dhcp-server.c | 109 ++++++++++++++++++++++++++++++++++++++++------
 ell/dhcp.h        |   2 +
 ell/ell.sym       |   1 +
 3 files changed, 98 insertions(+), 14 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index bae0f10..6415872 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -87,6 +87,8 @@ struct l_dhcp_server {
 	struct dhcp_transport *transport;
 =

 	struct l_acd *acd;
+
+	bool authoritative : 1;
 };
 =

 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
@@ -615,9 +617,6 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			if (l =3D=3D 4)
 				server_id_opt =3D l_get_u32(v);
 =

-			if (server->address !=3D server_id_opt)
-				return;
-
 			break;
 		case L_DHCP_OPTION_REQUESTED_IP_ADDRESS:
 			if (l =3D=3D 4)
@@ -640,6 +639,9 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		SERVER_DEBUG("Received DISCOVER, requested IP "NIPQUAD_FMT,
 					NIPQUAD(requested_ip_opt));
 =

+		if (server_id_opt && server_id_opt !=3D server->address)
+			break;
+
 		send_offer(server, message, lease, requested_ip_opt);
 =

 		break;
@@ -647,27 +649,92 @@ static void listener_event(const void *data, size_t l=
en, void *user_data)
 		SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FMT,
 				NIPQUAD(requested_ip_opt));
 =

-		if (requested_ip_opt =3D=3D 0) {
-			requested_ip_opt =3D message->ciaddr;
-			if (requested_ip_opt =3D=3D 0)
+		/*
+		 * RFC2131 Section 3.5: "Those servers not selected by the
+		 * DHCPREQUEST message use the message as notification that
+		 * the client has declined that server's offer."
+		 */
+		if (server_id_opt && server_id_opt !=3D server->address) {
+			if (server->authoritative) {
+				send_nak(server, message);
 				break;
-		}
+			}
 =

-		if (lease && requested_ip_opt =3D=3D lease->address) {
-			send_ack(server, message, lease->address);
+			if (!lease || !lease->offering)
+				break;
+
+			remove_lease(server, lease);
 			break;
 		}
 =

-		if (server_id_opt || !lease) {
-			send_nak(server, message);
+		/*
+		 * RFC2131 Section 3.5: "If the selected server is unable to
+		 * satisfy the DHCPREQUEST message (...), the server SHOULD
+		 * respond with a DHCPNAK message."
+		 *
+		 * But:
+		 * 4.3.2: "If the DHCP server has no record of this client,
+		 * then it MUST remain silent (...)"
+		 */
+		if (!lease) {
+			if (server_id_opt =3D=3D server->address ||
+					server->authoritative)
+				send_nak(server, message);
+
 			break;
 		}
+
+		/*
+		 * 4.3.2: "If the DHCPREQUEST message contains a 'server
+		 * identifier' option, the message is in response to a
+		 * DHCPOFFER message.  Otherwise, the message is a request
+		 * to verify or extend an existing lease."
+		 */
+		if (server_id_opt =3D=3D server->address) {
+			/*
+			 * Allow either no 'requested IP address' option or
+			 * a value identical with the one we offered because
+			 * the spec is unclear on whether it is to be
+			 * included:
+			 *
+			 * Section 4.3.2: "DHCPREQUEST generated during
+			 * SELECTING state: (...) 'requested IP address' MUST
+			 * be filled in with the yiaddr value from the chosen
+			 * DHCPOFFER."
+			 *
+			 * but section 3.5 suggests only in the INIT-REBOOT
+			 * state: "The 'requested IP address' option is to be
+			 * filled in only in a DHCPREQUEST message when the
+			 * client is verifying network parameters obtained
+			 * previously."
+			 */
+			if (!lease->offering ||
+					(requested_ip_opt &&
+					 requested_ip_opt !=3D lease->address)) {
+				send_nak(server, message);
+				break;
+			}
+		} else {
+			/*
+			 * 3.5: "If a server receives a DHCPREQUEST message
+			 * with an invalid 'requested IP address', the server
+			 * SHOULD respond to the client with a DHCPNAK message"
+			 */
+			if (lease->offering ||
+					(requested_ip_opt &&
+					 requested_ip_opt !=3D lease->address)) {
+				send_nak(server, message);
+				break;
+			}
+		}
+
+		send_ack(server, message, lease->address);
 		break;
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
 =

-		if (!server_id_opt || !requested_ip_opt || !lease ||
-				!lease->offering)
+		if (server_id_opt !=3D server->address || !requested_ip_opt ||
+				!lease || !lease->offering)
 			break;
 =

 		if (requested_ip_opt =3D=3D lease->address)
@@ -677,7 +744,8 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	case DHCP_MESSAGE_TYPE_RELEASE:
 		SERVER_DEBUG("Received RELEASE");
 =

-		if (!server_id_opt || !lease || lease->offering)
+		if (server_id_opt !=3D server->address || !lease ||
+				lease->offering)
 			break;
 =

 		if (message->ciaddr =3D=3D lease->address)
@@ -687,6 +755,9 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	case DHCP_MESSAGE_TYPE_INFORM:
 		SERVER_DEBUG("Received INFORM");
 =

+		if (server_id_opt && server_id_opt !=3D server->address)
+			break;
+
 		send_inform(server, message);
 		break;
 	}
@@ -732,6 +803,7 @@ LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(int =
ifindex)
 	server->expired_list =3D l_queue_new();
 =

 	server->started =3D false;
+	server->authoritative =3D true;
 =

 	server->lease_seconds =3D DEFAULT_DHCP_LEASE_SEC;
 	server->max_expired =3D MAX_EXPIRED_LEASES;
@@ -1053,6 +1125,15 @@ failed:
 	return false;
 }
 =

+LIB_EXPORT void l_dhcp_server_set_authoritative(struct l_dhcp_server *serv=
er,
+						bool authoritative)
+{
+	if (unlikely(!server))
+		return;
+
+	server->authoritative =3D authoritative;
+}
+
 LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discover(
 						struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 2804c78..830cbb1 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -141,6 +141,8 @@ bool l_dhcp_server_set_ip_address(struct l_dhcp_server =
*server,
 bool l_dhcp_server_set_netmask(struct l_dhcp_server *server, const char *m=
ask);
 bool l_dhcp_server_set_gateway(struct l_dhcp_server *server, const char *i=
p);
 bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char **dns);
+void l_dhcp_server_set_authoritative(struct l_dhcp_server *server,
+					bool authoritative);
 =

 struct l_dhcp_lease *l_dhcp_server_discover(struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
diff --git a/ell/ell.sym b/ell/ell.sym
index 4d41448..3be10dc 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -259,6 +259,7 @@ global:
 	l_dhcp_server_set_netmask;
 	l_dhcp_server_set_gateway;
 	l_dhcp_server_set_dns;
+	l_dhcp_server_set_authoritative;
 	l_dhcp_server_discover;
 	l_dhcp_server_request;
 	l_dhcp_server_decline;
-- =

2.30.2

--===============6391243406718260664==--

