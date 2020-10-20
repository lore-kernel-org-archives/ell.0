Content-Type: multipart/mixed; boundary="===============3255039669289166632=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v6 3/6] dhcp-server: handle DECLINE messages
Date: Mon, 19 Oct 2020 18:32:39 -0700
Message-ID: <20201020013242.1575694-3-prestwoj@gmail.com>
In-Reply-To: <20201020013242.1575694-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3255039669289166632==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Process DECLINE messages from clients and remove any pending
leases that were created during DISCOVER.
---
 ell/dhcp-server.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 2008c56..7d2d6f0 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -111,6 +111,18 @@ static struct l_dhcp_lease *find_lease_by_mac(struct l=
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
@@ -504,6 +516,16 @@ static void listener_event(const void *data, size_t le=
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

--===============3255039669289166632==--

