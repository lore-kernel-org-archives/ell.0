Content-Type: multipart/mixed; boundary="===============6403568531724625997=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/8] dhcp-server: Support RFC4039 Rapid Commit
Date: Fri, 23 Jul 2021 20:23:30 +0200
Message-ID: <20210723182331.135123-7-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6403568531724625997==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle the RFC4039 Rapid Commit option in a DHCPDISCOVERY by directly
creating an active lease and replying with a DHCPACK, i.e. skipping the
DHCPOFFER and DHCPREQUEST roundtrip.

Currently enabled unconditionally, the support can be made optional if
needed in the future.
---
 ell/dhcp-private.h |  1 +
 ell/dhcp-server.c  | 26 ++++++++++++++++++++++++--
 ell/dhcp-util.c    |  4 +++-
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index f9c0c6f..5a09f5e 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -65,6 +65,7 @@ enum dhcp_option_overload {
 #define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* Section 9.8 */
 #define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
 #define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
+#define DHCP_OPTION_RAPID_COMMIT 80 /* RFC 4039 Section 4 */
 =

 /* RFC 2131, Figure 2 */
 #define DHCP_FLAG_BROADCAST (1 << 15)
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 21adcab..265d52e 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -632,7 +632,8 @@ static void send_nak(struct l_dhcp_server *server,
 =

 static void send_ack(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
-			const struct l_dhcp_lease *lease)
+			const struct l_dhcp_lease *lease,
+			bool rapid_commit)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -657,6 +658,10 @@ static void send_ack(struct l_dhcp_server *server,
 	_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &server->address);
 =

+	if (rapid_commit)
+		_dhcp_message_builder_append(&builder, DHCP_OPTION_RAPID_COMMIT,
+						0, "");
+
 	_dhcp_message_builder_finalize(&builder, &len);
 =

 	SERVER_DEBUG("Sending ACK to "NIPQUAD_FMT, NIPQUAD(reply->yiaddr));
@@ -684,6 +689,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	uint32_t server_id_opt =3D 0;
 	uint32_t requested_ip_opt =3D 0;
 	L_AUTO_FREE_VAR(uint8_t *, client_id_opt) =3D NULL;
+	bool rapid_commit_opt =3D false;
 =

 	SERVER_DEBUG("");
 =

@@ -715,6 +721,9 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			client_id_opt[0] =3D l;
 			memcpy(client_id_opt + 1, v, l);
 			break;
+		case DHCP_OPTION_RAPID_COMMIT:
+			rapid_commit_opt =3D true;
+			break;
 		}
 	}
 =

@@ -734,6 +743,19 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 		if (server_id_opt && server_id_opt !=3D server->address)
 			break;
 =

+		if (rapid_commit_opt) {
+			lease =3D l_dhcp_server_discover(server, requested_ip_opt,
+							client_id_opt,
+							message->chaddr);
+			if (!lease) {
+				send_nak(server, message, client_id_opt);
+				break;
+			}
+
+			send_ack(server, message, lease, rapid_commit_opt);
+			break;
+		}
+
 		send_offer(server, message, lease, requested_ip_opt,
 				client_id_opt);
 		break;
@@ -820,7 +842,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			}
 		}
 =

-		send_ack(server, message, lease);
+		send_ack(server, message, lease, false);
 		break;
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
index d4d715a..e5c88b2 100644
--- a/ell/dhcp-util.c
+++ b/ell/dhcp-util.c
@@ -73,7 +73,9 @@ bool _dhcp_message_builder_append(struct dhcp_message_bui=
lder *builder,
 =

 		builder->pos[0] =3D code;
 		builder->pos[1] =3D optlen;
-		memcpy(builder->pos + 2, optval, optlen);
+
+		if (optlen)
+			memcpy(builder->pos + 2, optval, optlen);
 =

 		builder->pos +=3D optlen + 2;
 		break;
-- =

2.30.2

--===============6403568531724625997==--

