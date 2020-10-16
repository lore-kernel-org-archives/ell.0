Content-Type: multipart/mixed; boundary="===============7236398841868579746=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 14/20] dhcp-server: handle DECLINE messages
Date: Fri, 16 Oct 2020 08:36:29 -0700
Message-ID: <20201016153635.660391-14-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7236398841868579746==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Process DECLINE messages from clients and remove any pending
leases that were created during DISCOVER.
---
 ell/dhcp-server.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 4eb9aec..d2a1661 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -116,6 +116,18 @@ static struct l_dhcp_lease *find_lease_by_mac(struct l=
_dhcp_server *server,
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

+static void remove_lease(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease)
+{
+	l_queue_remove(server->lease_list, lease);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+
+	_dhcp_lease_free(lease);
+}
+
 /* Clear the old lease and create the new one */
 static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
 				const uint8_t *mac,
@@ -509,6 +521,16 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 			break;
 		}
 		break;
+	case DHCP_MESSAGE_TYPE_DECLINE:
+		SERVER_DEBUG("Received DECLINE");
+
+		if (!server_id_opt || !requested_ip_opt || !lease)
+			break;
+
+		if (requested_ip_opt =3D=3D lease->address)
+			remove_lease(server, lease);
+
+		break;
 	}
 }
 =

-- =

2.26.2

--===============7236398841868579746==--

