Content-Type: multipart/mixed; boundary="===============7229774930979308414=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 15/20] dhcp-server: add RELEASE message support
Date: Fri, 16 Oct 2020 08:36:30 -0700
Message-ID: <20201016153635.660391-15-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7229774930979308414==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle RELEASE messages from clients. If there is a valid lease
set the expire time to now which releases the IP but also allows
the client to reconnect and maintain the same IP so long as
it hadn't been leased out again.
---
 ell/dhcp-server.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index d2a1661..c74cd0b 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -205,6 +205,20 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_se=
rver *server,
 	return lease;
 }
 =

+static void lease_set_expire(struct l_dhcp_server *server,
+			struct l_dhcp_lease *lease, uint32_t expire)
+{
+	l_queue_remove(server->lease_list, lease);
+
+	lease->lifetime =3D expire;
+
+	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+}
+
 static bool match_lease_ip(const void *data, const void *user_data)
 {
 	const struct l_dhcp_lease *lease =3D data;
@@ -530,6 +544,16 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 		if (requested_ip_opt =3D=3D lease->address)
 			remove_lease(server, lease);
 =

+		break;
+	case DHCP_MESSAGE_TYPE_RELEASE:
+		SERVER_DEBUG("Received RELEASE");
+
+		if (!server_id_opt || !lease)
+			break;
+
+		if (message->ciaddr =3D=3D lease->address)
+			lease_set_expire(server, lease, time(NULL));
+
 		break;
 	}
 }
-- =

2.26.2

--===============7229774930979308414==--

