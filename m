Content-Type: multipart/mixed; boundary="===============2560405784632052767=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/6] dhcp-server: add timer for tracking expired leases
Date: Wed, 18 Nov 2020 11:00:54 -0800
Message-ID: <20201118190056.3584080-4-prestwoj@gmail.com>
In-Reply-To: <20201118190056.3584080-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2560405784632052767==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Currently dhcp-server has a limitation where it only calls the
lease expired callback if a client actually releases the lease
itself.

This patchs adds a single timer to the server object which tracks
the soonest expiring lease. When this lease expires the event is
triggered and the timeout is reset to the (new) soonest expiring
lease.
---
 ell/dhcp-server.c | 135 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 129 insertions(+), 6 deletions(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index fc6bdbf..f418ed5 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -37,6 +37,7 @@
 #include "queue.h"
 #include "util.h"
 #include "strv.h"
+#include "timeout.h"
 =

 /* 8 hours */
 #define DEFAULT_DHCP_LEASE_SEC (8*60*60)
@@ -62,6 +63,9 @@ struct l_dhcp_server {
 =

 	struct l_queue *lease_list;
 =

+	/* Next lease expiring */
+	struct l_timeout *next_expire;
+
 	l_dhcp_debug_cb_t debug_handler;
 	void *debug_data;
 	l_dhcp_destroy_cb_t debug_destroy;
@@ -164,6 +168,81 @@ static int compare_lifetime(const void *a, const void =
*b, void *user_data)
 	return lease2->lifetime - lease1->lifetime;
 }
 =

+struct lease_expire_data {
+	struct l_dhcp_lease *lease;
+	struct l_dhcp_server *server;
+};
+
+static void next_expiring_lease(void *data, void *user_data)
+{
+	struct l_dhcp_lease *lease =3D data;
+	struct l_dhcp_lease **next =3D user_data;
+
+	/* Don't count leases which are in offer stage */
+	if (lease->offering)
+		return;
+
+	/* Sanity check that the lease lifetime hasn't passed */
+	if (l_time_after(l_time_now(), lease->lifetime))
+		return;
+
+	/* Does this lease expire before our current candidate? */
+	if (l_time_before(lease->lifetime, (*next)->lifetime))
+		*next =3D lease;
+}
+
+static void lease_expired_cb(struct l_timeout *timeout, void *user_data);
+
+static void set_next_expire_timer(struct l_dhcp_server *server,
+					struct l_dhcp_lease *expired)
+{
+	struct lease_expire_data *data;
+	struct l_dhcp_lease *next;
+	unsigned int next_timeout;
+
+	/*
+	 * Head of the queue isn't an active lease, or its the lease which
+	 * triggered this timeout.
+	 */
+	next =3D l_queue_peek_head(server->lease_list);
+	if (next =3D=3D expired || !next || (next && is_expired_lease(next))) {
+		server->next_expire =3D NULL;
+		return;
+	}
+
+	/*
+	 * Find the next lease that is expiring. Start at a known good lease
+	 * (head) and find a lease which expires soonest.
+	 */
+	l_queue_foreach(server->lease_list, next_expiring_lease, &next);
+
+	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(), next->lifetime)=
);
+
+	/* data gets freed by destroy, so we can reuse the pointer here */
+	data =3D l_new(struct lease_expire_data, 1);
+
+	data->server =3D server;
+	data->lease =3D next;
+
+	l_timeout_remove(server->next_expire);
+
+	server->next_expire =3D l_timeout_create(next_timeout, lease_expired_cb,
+						data, l_free);
+}
+
+static void lease_expired_cb(struct l_timeout *timeout, void *user_data)
+{
+	struct lease_expire_data *data =3D user_data;
+	struct l_dhcp_server *server =3D data->server;
+	struct l_dhcp_lease *lease =3D data->lease;
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+
+	set_next_expire_timer(server, lease);
+}
+
 static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
 					uint32_t expire, const uint8_t *chaddr,
 					uint32_t yiaddr)
@@ -180,11 +259,35 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 	memcpy(lease->mac, chaddr, ETH_ALEN);
 	lease->address =3D yiaddr;
 =

-	if (expire =3D=3D 0)
+	/*
+	 * Somewhat convoluted but a zero expire time means this is an actual
+	 * lease that was offered and accepted. Anything else is a lease that
+	 * was offered but not yet accepted/ACK'ed.
+	 *
+	 * If we do not yet have a lease expire timer (first lease) we set one
+	 * now.
+	 */
+	if (expire =3D=3D 0) {
 		lease->lifetime =3D l_time_to_secs(l_time_now()) +
 						server->lease_seconds;
-	else
+		lease->offering =3D false;
+
+		if (!server->next_expire) {
+			struct lease_expire_data *data =3D l_new(
+						struct lease_expire_data, 1);
+
+			data->lease =3D lease;
+			data->server =3D server;
+
+			server->next_expire =3D l_timeout_create(
+							server->lease_seconds,
+							lease_expired_cb,
+							data, l_free);
+		}
+	} else {
 		lease->lifetime =3D expire;
+		lease->offering =3D true;
+	}
 =

 	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
 =

@@ -196,17 +299,38 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 }
 =

 static void lease_release(struct l_dhcp_server *server,
-			struct l_dhcp_lease *lease, uint32_t expire)
+			struct l_dhcp_lease *lease)
 {
+	/*
+	 * If the client released the lease after the server timeout expired
+	 * there is nothing to do. Otherwise the client is releasing the
+	 * lease early which may require re-setting the lease expire timer
+	 */
+	if (is_expired_lease(lease))
+		return;
+
 	l_queue_remove(server->lease_list, lease);
 =

-	lease->lifetime =3D expire;
+	/*
+	 * We want to ensure that this lease does not get counted as active
+	 * when resetting the expire time. Since the expiration is seconds
+	 * based, setting the lifetime to 'now' could easily be counted as an
+	 * active lease due to rounding errors. This is why its being set to
+	 * 'now' minus one second.
+	 */
+	lease->lifetime =3D l_time_to_secs(l_time_now()) - 1;
 =

 	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
+
+	/*
+	 * Since this is not a lease which timed out we don't pass the lease
+	 * object. This could result in the lease timeout not re-arming.
+	 */
+	set_next_expire_timer(server, NULL);
 }
 =

 static bool match_lease_ip(const void *data, const void *user_data)
@@ -567,8 +691,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			break;
 =

 		if (message->ciaddr =3D=3D lease->address)
-			lease_release(server, lease,
-						l_time_to_secs(l_time_now()));
+			lease_release(server, lease);
 =

 		break;
 	case DHCP_MESSAGE_TYPE_INFORM:
-- =

2.26.2

--===============2560405784632052767==--

