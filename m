Content-Type: multipart/mixed; boundary="===============8382777018376453814=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v7 4/6] dhcp-server: add RELEASE message support
Date: Tue, 20 Oct 2020 08:52:47 -0700
Message-ID: <20201020155249.1603105-4-prestwoj@gmail.com>
In-Reply-To: <20201020155249.1603105-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8382777018376453814==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle RELEASE messages from clients. If there is a valid lease
set the expire time to now which releases the IP but also allows
the client to reconnect and maintain the same IP so long as
it hadn't been leased out again.
---
 ell/dhcp-server.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

v7:
 * Renamed lease_set_expire to lease_release

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 5fe68fd..777265d 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -195,6 +195,20 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_se=
rver *server,
 	return lease;
 }
 =

+static void lease_release(struct l_dhcp_server *server,
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
@@ -521,6 +535,17 @@ static void listener_event(const void *data, size_t le=
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
+			lease_release(server, lease,
+						l_time_to_secs(l_time_now()));
+
 		break;
 	}
 }
-- =

2.26.2

--===============8382777018376453814==--

