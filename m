Content-Type: multipart/mixed; boundary="===============7741435107070897338=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/15] dhcp-server: Support RFC4039 Rapid Commit
Date: Mon, 02 Aug 2021 16:04:21 +0200
Message-ID: <20210802140424.170150-12-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7741435107070897338==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle the RFC4039 Rapid Commit option in a DHCPDISCOVERY by directly
creating an active lease and replying with a DHCPACK, i.e. skipping the
DHCPOFFER and DHCPREQUEST roundtrip.
---
 ell/dhcp-server.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 506bb7d..971bc54 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -658,7 +658,8 @@ static void send_nak(struct l_dhcp_server *server,
 =

 static void send_ack(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
-			struct l_dhcp_lease *lease)
+			struct l_dhcp_lease *lease,
+			bool rapid_commit)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -684,6 +685,10 @@ static void send_ack(struct l_dhcp_server *server,
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
@@ -712,6 +717,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	bool server_id_match =3D true;
 	uint32_t requested_ip_opt =3D 0;
 	L_AUTO_FREE_VAR(uint8_t *, client_id_opt) =3D NULL;
+	bool rapid_commit_opt =3D false;
 =

 	SERVER_DEBUG("");
 =

@@ -745,6 +751,9 @@ static void listener_event(const void *data, size_t len=
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

@@ -772,6 +781,19 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 		if (!server_id_match)
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
@@ -868,7 +890,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			}
 		}
 =

-		send_ack(server, message, lease);
+		send_ack(server, message, lease, false);
 		break;
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
-- =

2.30.2

--===============7741435107070897338==--

