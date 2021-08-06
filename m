Content-Type: multipart/mixed; boundary="===============7449351095771399465=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] dhcp-server: Fix double free in
 l_dhcp_server_expire_by_mac
Date: Sat, 07 Aug 2021 01:52:57 +0200
Message-ID: <20210806235259.304436-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7449351095771399465==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When using l_queue_foreach_remove() on lease_list we can't call
lease_release() because that will try to do l_queue_remove() on the same
queue, in addition to all the things we need it to do.
---
 ell/dhcp-server.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index f92807a..84dc41d 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -1418,25 +1418,42 @@ LIB_EXPORT bool l_dhcp_server_lease_remove(struct l=
_dhcp_server *server,
 struct dhcp_expire_by_mac_data {
 	struct l_dhcp_server *server;
 	const uint8_t *mac;
+	unsigned int expired_cnt;
 };
 =

 static bool dhcp_expire_by_mac(void *data, void *user_data)
 {
 	struct l_dhcp_lease *lease =3D data;
 	struct dhcp_expire_by_mac_data *expire_data =3D user_data;
+	struct l_dhcp_server *server =3D expire_data->server;
 =

 	if (!match_lease_mac(lease, expire_data->mac))
 		return false;
 =

-	lease_release(expire_data->server, lease);
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+
+	if (!lease->offering) {
+		if (l_queue_length(server->expired_list) > server->max_expired)
+			_dhcp_lease_free(l_queue_pop_head(server->expired_list));
+
+		l_queue_push_tail(server->expired_list, lease);
+	} else
+		_dhcp_lease_free(lease);
+
+	expire_data->expired_cnt++;
 	return true;
 }
 =

 LIB_EXPORT void l_dhcp_server_expire_by_mac(struct l_dhcp_server *server,
 						const uint8_t *mac)
 {
-	struct dhcp_expire_by_mac_data expire_data =3D { server, mac };
+	struct dhcp_expire_by_mac_data expire_data =3D { server, mac, 0 };
 =

 	l_queue_foreach_remove(server->lease_list, dhcp_expire_by_mac,
 				&expire_data);
+
+	if (expire_data.expired_cnt)
+		set_next_expire_timer(server, NULL);
 }
-- =

2.30.2

--===============7449351095771399465==--

