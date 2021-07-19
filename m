Content-Type: multipart/mixed; boundary="===============7146247790668060443=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dhcp-server: Time out lease offers
Date: Mon, 19 Jul 2021 16:00:20 +0200
Message-ID: <20210719140020.555503-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210719140020.555503-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7146247790668060443==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle lease->lifetime for leases in the offering state just like the
active ones.  Add missing set_next_expire_timer calls.  Fix typos in
an add_lease comment that I'm moving.
---
 ell/dhcp-server.c | 68 ++++++++++++++++++++++++++---------------------
 1 file changed, 38 insertions(+), 30 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index fa5a7db..bae0f10 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -126,16 +126,6 @@ static struct l_dhcp_lease *find_lease_by_mac(struct l=
_dhcp_server *server,
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

-static bool remove_lease(struct l_dhcp_server *server,
-				struct l_dhcp_lease *lease)
-{
-	if (!l_queue_remove(server->lease_list, lease))
-		return false;
-
-	_dhcp_lease_free(lease);
-	return true;
-}
-
 /* Clear the old lease and create the new one */
 static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
 				const uint8_t *mac,
@@ -198,6 +188,9 @@ static void set_next_expire_timer(struct l_dhcp_server =
*server,
 					struct l_dhcp_lease *expired)
 {
 	struct l_dhcp_lease *next;
+	uint64_t expiry;
+	uint64_t now;
+	uint64_t next_timeout;
 =

 	/*
 	 * If this is an expiring lease put it into the expired queue, removing
@@ -206,32 +199,35 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
 	if (expired) {
 		l_queue_remove(server->lease_list, expired);
 =

-		if (l_queue_length(server->expired_list) > server->max_expired)
-			_dhcp_lease_free(l_queue_pop_head(
+		if (!expired->offering) {
+			if (l_queue_length(server->expired_list) >
+					server->max_expired)
+				_dhcp_lease_free(l_queue_pop_head(
 							server->expired_list));
 =

-		l_queue_push_tail(server->expired_list, expired);
+			l_queue_push_tail(server->expired_list, expired);
+		} else
+			_dhcp_lease_free(expired);
 	}
 =

 	next =3D l_queue_peek_tail(server->lease_list);
-	if (!next || next->offering) {
+	if (!next) {
 		l_timeout_remove(server->next_expire);
 		server->next_expire =3D NULL;
 		return;
 	}
 =

-	if (server->next_expire) {
-		uint64_t expiry =3D get_lease_expiry_time(next);
-		uint64_t now =3D l_time_now();
-		uint64_t next_timeout =3D l_time_after(expiry, now) ?
-			l_time_to_msecs(expiry - now) : 0;
+	expiry =3D get_lease_expiry_time(next);
+	now =3D l_time_now();
+	next_timeout =3D l_time_after(expiry, now) ?
+		l_time_to_msecs(expiry - now) : 0;
 =

+	if (server->next_expire)
 		l_timeout_modify_ms(server->next_expire, next_timeout ?: 1);
-	} else
-		server->next_expire =3D l_timeout_create(
-						server->lease_seconds,
-						lease_expired_cb,
-						server, NULL);
+	else
+		server->next_expire =3D l_timeout_create(next_timeout ?: 1,
+							lease_expired_cb,
+							server, NULL);
 }
 =

 static void lease_expired_cb(struct l_timeout *timeout, void *user_data)
@@ -239,7 +235,7 @@ static void lease_expired_cb(struct l_timeout *timeout,=
 void *user_data)
 	struct l_dhcp_server *server =3D user_data;
 	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->lease_list);
 =

-	if (server->event_handler)
+	if (!lease->offering && server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
 =

@@ -276,17 +272,18 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 		 */
 		l_queue_insert(server->lease_list, lease,
 					compare_expiry_or_offering, NULL);
-		/*
-		 * This is a new (or renewed lease) so pass NULL for expired so
-		 * the queue's are not modified, only the next_expired timer
-		 */
-		set_next_expire_timer(server, NULL);
 	} else {
 		lease->lifetime =3D OFFER_TIME;
 		/* Push offered leases to head, active leases after those */
 		l_queue_push_head(server->lease_list, lease);
 	}
 =

+	/*
+	 * This is a new (or renewed) lease so pass NULL for expired so the
+	 * queues are not modified, only the next_expire timer.
+	 */
+	set_next_expire_timer(server, NULL);
+
 	SERVER_DEBUG("added lease IP "NIPQUAD_FMT " for "MAC " lifetime=3D%u",
 			NIPQUAD(yiaddr), MAC_STR(chaddr),
 			server->lease_seconds);
@@ -294,6 +291,17 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_se=
rver *server,
 	return lease;
 }
 =

+static bool remove_lease(struct l_dhcp_server *server,
+				struct l_dhcp_lease *lease)
+{
+	if (!l_queue_remove(server->lease_list, lease))
+		return false;
+
+	_dhcp_lease_free(lease);
+	set_next_expire_timer(server, NULL);
+	return true;
+}
+
 static void lease_release(struct l_dhcp_server *server,
 			struct l_dhcp_lease *lease)
 {
-- =

2.30.2

--===============7146247790668060443==--

