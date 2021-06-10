Content-Type: multipart/mixed; boundary="===============8067649794567998404=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dhcp-server: Simplify timeout handling
Date: Thu, 10 Jun 2021 23:20:33 +0200
Message-ID: <20210610212033.338502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8067649794567998404==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Remove max timeout interval checks no longer useful after
the l_timeout_modify_ms() parameter type change.
---
 ell/dhcp-server.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index b58b2f6..34512ae 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -225,15 +225,9 @@ static void set_next_expire_timer(struct l_dhcp_server=
 *server,
 		uint64_t expiry =3D get_lease_expiry_time(next);
 		uint64_t now =3D l_time_now();
 		uint64_t next_timeout =3D l_time_after(expiry, now) ?
-			expiry - now : 0;
-		uint64_t next_timeout_ms =3D l_time_to_msecs(next_timeout) ?: 1;
+			l_time_to_msecs(expiry - now) : 0;
 =

-		if (L_WARN_ON(next_timeout_ms >
-					server->lease_seconds * L_MSEC_PER_SEC))
-			next_timeout_ms =3D
-				server->lease_seconds * L_MSEC_PER_SEC;
-
-		l_timeout_modify_ms(server->next_expire, next_timeout_ms);
+		l_timeout_modify_ms(server->next_expire, next_timeout ?: 1);
 	} else
 		server->next_expire =3D l_timeout_create(
 						server->lease_seconds,
@@ -246,11 +240,6 @@ static void lease_expired_cb(struct l_timeout *timeout=
, void *user_data)
 	struct l_dhcp_server *server =3D user_data;
 	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->lease_list);
 =

-	if (!is_expired_lease(lease)) {
-		set_next_expire_timer(server, NULL);
-		return;
-	}
-
 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
-- =

2.30.2

--===============8067649794567998404==--

