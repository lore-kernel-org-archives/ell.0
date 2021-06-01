Content-Type: multipart/mixed; boundary="===============5110376520864359697=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] dhcp-server: Expire the lease from the right list
Date: Tue, 01 Jun 2021 04:03:44 +0200
Message-ID: <20210601020346.35502-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210601020346.35502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5110376520864359697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We were trying to expire the oldest lease from server->expired_list but
we should be expiring the oldest lease in server->lease_list.  We were
never adding any new entries to server->expired_list and it would be
always empty.
---
 ell/dhcp-server.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 9e39fe6..9226ba4 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -229,7 +229,7 @@ static void set_next_expire_timer(struct l_dhcp_server =
*server,
 static void lease_expired_cb(struct l_timeout *timeout, void *user_data)
 {
 	struct l_dhcp_server *server =3D user_data;
-	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->expired_list);
+	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->lease_list);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
-- =

2.30.2

--===============5110376520864359697==--

