Content-Type: multipart/mixed; boundary="===============2433000358561473122=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dhcp: Track lease lifetime and bind time separately
Date: Sat, 05 Jun 2021 00:19:07 +0200
Message-ID: <20210604221907.202641-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210604221907.202641-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2433000358561473122==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

dhcp-server has been confusing lease->lifetime with the expiry time and
also reducing the expiry timestamp resolution and maximum to 32-bit
second count.  To fix both problems, add microsecond-resultion 64-bit
l_dhcp_lease::bound_time (compatible with ell/time.h utils) and use
l_dhcp_lease::lifetime exclusively for the life time in seconds.  Both
fields have the same usage between client and server now.  A public
getter for the bound time isn't added for now for lack of evidence that
it's going to be useful.
---
 ell/dhcp-private.h |  1 +
 ell/dhcp-server.c  | 45 +++++++++++++++++++++++++++++----------------
 ell/dhcp.c         |  2 ++
 3 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 204e54e..c422322 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -158,6 +158,7 @@ struct l_dhcp_lease {
 	uint32_t lifetime;
 	uint32_t t1;
 	uint32_t t2;
+	uint64_t bound_time;
 	uint32_t router;
 	uint32_t *dns;
 	char *domain_name;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 3d6a6a8..4c31834 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -30,6 +30,7 @@
 #include <arpa/inet.h>
 #include <time.h>
 #include <errno.h>
+#include <limits.h>
 =

 #include "private.h"
 #include "time.h"
@@ -102,12 +103,14 @@ struct l_dhcp_server {
 	l_util_debug(server->debug_handler, server->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
 =

-static bool is_expired_lease(struct l_dhcp_lease *lease)
+static uint64_t get_lease_expiry_time(const struct l_dhcp_lease *lease)
 {
-	if (lease->lifetime < l_time_to_secs(l_time_now()))
-		return true;
+	return lease->bound_time + lease->lifetime * L_USEC_PER_SEC;
+}
 =

-	return false;
+static bool is_expired_lease(const struct l_dhcp_lease *lease)
+{
+	return !l_time_after(get_lease_expiry_time(lease), l_time_now());
 }
 =

 static bool match_lease_mac(const void *data, const void *user_data)
@@ -169,11 +172,12 @@ static int get_lease(struct l_dhcp_server *server, ui=
nt32_t yiaddr,
 	return 0;
 }
 =

-static int compare_lifetime_or_offering(const void *a, const void *b,
+static int compare_expiry_or_offering(const void *a, const void *b,
 					void *user_data)
 {
 	const struct l_dhcp_lease *lease1 =3D a;
 	const struct l_dhcp_lease *lease2 =3D b;
+	int64_t diff;
 =

 	/*
 	 * Ensures offered but not active leases stay at the head of the queue.
@@ -182,7 +186,9 @@ static int compare_lifetime_or_offering(const void *a, =
const void *b,
 	if (lease1->offering)
 		return 1;
 =

-	return lease2->lifetime - lease1->lifetime;
+	diff =3D (int64_t) lease2->bound_time - lease1->bound_time +
+		((int64_t) lease2->lifetime - lease1->lifetime) * L_USEC_PER_SEC;
+	return diff >=3D 0 ? diff > 0 ? 1 : 0 : -1;
 }
 =

 static void lease_expired_cb(struct l_timeout *timeout, void *user_data);
@@ -214,14 +220,16 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
 	}
 =

 	if (server->next_expire) {
-		uint32_t now =3D l_time_to_secs(l_time_now());
+		uint64_t expiry =3D get_lease_expiry_time(next);
+		uint64_t now =3D l_time_now();
+		uint64_t next_timeout =3D l_time_after(expiry, now) ?
+			expiry - now : 0;
+		uint64_t next_timeout_ms =3D l_time_to_msecs(next_timeout) ?: 1;
 =

-		if (l_time_after(next->lifetime, now)) {
-			unsigned int next_timeout =3D next->lifetime - now;
+		if (next_timeout_ms > ULONG_MAX)
+			next_timeout_ms =3D ULONG_MAX;
 =

-			l_timeout_modify(server->next_expire, next_timeout);
-		} else
-			l_timeout_modify_ms(server->next_expire, 1);
+		l_timeout_modify_ms(server->next_expire, next_timeout_ms);
 	} else
 		server->next_expire =3D l_timeout_create(
 						server->lease_seconds,
@@ -234,6 +242,11 @@ static void lease_expired_cb(struct l_timeout *timeout=
, void *user_data)
 	struct l_dhcp_server *server =3D user_data;
 	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->lease_list);
 =

+	if (!is_expired_lease(lease)) {
+		set_next_expire_timer(server, NULL);
+		return;
+	}
+
 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
@@ -258,24 +271,24 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 	lease->address =3D yiaddr;
 =

 	lease->offering =3D offering;
-	lease->lifetime =3D l_time_to_secs(l_time_now());
+	lease->bound_time =3D l_time_now();
 =

 	if (!offering) {
-		lease->lifetime +=3D server->lease_seconds;
+		lease->lifetime =3D server->lease_seconds;
 =

 		/*
 		 * Insert into queue by lifetime (skipping any offered leases
 		 * at the head)
 		 */
 		l_queue_insert(server->lease_list, lease,
-					compare_lifetime_or_offering, NULL);
+					compare_expiry_or_offering, NULL);
 		/*
 		 * This is a new (or renewed lease) so pass NULL for expired so
 		 * the queue's are not modified, only the next_expired timer
 		 */
 		set_next_expire_timer(server, NULL);
 	} else {
-		lease->lifetime +=3D OFFER_TIME;
+		lease->lifetime =3D OFFER_TIME;
 		/* Push offered leases to head, active leases after those */
 		l_queue_push_head(server->lease_list, lease);
 	}
diff --git a/ell/dhcp.c b/ell/dhcp.c
index a4afa95..fff1645 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -860,6 +860,8 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 =

 		dhcp_client_event_notify(client, r);
 =

+		client->lease->bound_time =3D l_time_now();
+
 		/*
 		 * Start T1, once it expires we will start the T2 timer.  If
 		 * we renew the lease, we will end up back here.
-- =

2.30.2

--===============2433000358561473122==--

