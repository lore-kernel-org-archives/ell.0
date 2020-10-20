Content-Type: multipart/mixed; boundary="===============1152945083006764402=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v7 3/6] dhcp-server: handle DECLINE messages
Date: Tue, 20 Oct 2020 08:52:46 -0700
Message-ID: <20201020155249.1603105-3-prestwoj@gmail.com>
In-Reply-To: <20201020155249.1603105-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1152945083006764402==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Process DECLINE messages from clients and remove any pending
leases that were created during DISCOVER.
---
 ell/dhcp-server.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

v7:
 * Removed event from remove_lease since this is only called due to
   a DECLINE message and no NEW_LEASE event would have been called.

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 2008c56..5fe68fd 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -111,6 +111,14 @@ static struct l_dhcp_lease *find_lease_by_mac(struct l=
_dhcp_server *server,
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

+static void remove_lease(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease)
+{
+	l_queue_remove(server->lease_list, lease);
+
+	_dhcp_lease_free(lease);
+}
+
 /* Clear the old lease and create the new one */
 static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
 				const uint8_t *mac,
@@ -504,6 +512,16 @@ static void listener_event(const void *data, size_t le=
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

--===============1152945083006764402==--

