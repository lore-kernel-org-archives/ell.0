Content-Type: multipart/mixed; boundary="===============4311084987995908752=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 1/5] dhcp-server: add timer for tracking expired leases
Date: Mon, 23 Nov 2020 12:49:02 -0800
Message-ID: <20201123204906.4101813-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4311084987995908752==
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
 ell/dhcp-server.c | 160 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 128 insertions(+), 32 deletions(-)

v3:
 * Reworked to avoid needed a separate struct for server/lease pairs
 * Moved nearly all timer/add/remove logic into get_lease. This now
   handles (re)new leases, expired leases, and released leases and
   sets the timer as needed.

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index fd38c66..ac711b9 100644
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
@@ -44,6 +45,8 @@
 /* 5 minutes  */
 #define OFFER_TIME (5*60)
 =

+#define MAX_EXPIRED_LEASES 50
+
 static const uint8_t MAC_BCAST_ADDR[ETH_ALEN] =3D {
 	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
 };
@@ -59,8 +62,13 @@ struct l_dhcp_server {
 	uint32_t gateway;
 	uint32_t *dns_list;
 	uint32_t lease_seconds;
+	unsigned int max_expired;
 =

 	struct l_queue *lease_list;
+	struct l_queue *expired_list;
+
+	/* Next lease expiring */
+	struct l_timeout *next_expire;
 =

 	l_dhcp_debug_cb_t debug_handler;
 	void *debug_data;
@@ -156,16 +164,75 @@ static int get_lease(struct l_dhcp_server *server, ui=
nt32_t yiaddr,
 	return 0;
 }
 =

-static int compare_lifetime(const void *a, const void *b, void *user_data)
+static int compare_lifetime_or_offering(const void *a, const void *b,
+					void *user_data)
 {
 	const struct l_dhcp_lease *lease1 =3D a;
 	const struct l_dhcp_lease *lease2 =3D b;
 =

+	/*
+	 * Ensures offered but not active leases stay at the head of the queue.
+	 * This lets us peek at the tail to find the next expiring (active)
+	 */
+	if (lease1->offering)
+		return 1;
+
 	return lease2->lifetime - lease1->lifetime;
 }
 =

+static void lease_expired_cb(struct l_timeout *timeout, void *user_data);
+
+static void set_next_expire_timer(struct l_dhcp_server *server,
+					struct l_dhcp_lease *expired)
+{
+	struct l_dhcp_lease *next;
+	unsigned int next_timeout;
+
+	/*
+	 * If this is an expiring lease put it into the expired queue, removing
+	 * a lease if we have reached the max
+	 */
+	if (expired) {
+		l_queue_remove(server->lease_list, expired);
+
+		if (l_queue_length(server->expired_list) > server->max_expired)
+			_dhcp_lease_free(l_queue_pop_head(
+							server->expired_list));
+
+		l_queue_push_tail(server->expired_list, expired);
+	}
+
+	next =3D l_queue_peek_tail(server->lease_list);
+	if (!next || next->offering) {
+		server->next_expire =3D NULL;
+		return;
+	}
+
+	next_timeout =3D l_time_to_secs(l_time_diff(l_time_now(),
+							next->lifetime));
+
+	if (server->next_expire)
+		l_timeout_modify(server->next_expire, next_timeout);
+	else
+		server->next_expire =3D l_timeout_create(server->lease_seconds,
+							lease_expired_cb,
+							server, NULL);
+}
+
+static void lease_expired_cb(struct l_timeout *timeout, void *user_data)
+{
+	struct l_dhcp_server *server =3D user_data;
+	struct l_dhcp_lease *lease =3D l_queue_peek_tail(server->expired_list);
+
+	if (server->event_handler)
+		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
+					server->user_data, lease);
+
+	set_next_expire_timer(server, lease);
+}
+
 static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
-					uint32_t expire, const uint8_t *chaddr,
+					bool offering, const uint8_t *chaddr,
 					uint32_t yiaddr)
 {
 	struct l_dhcp_lease *lease =3D NULL;
@@ -180,13 +247,28 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 	memcpy(lease->mac, chaddr, ETH_ALEN);
 	lease->address =3D yiaddr;
 =

-	if (expire =3D=3D 0)
-		lease->lifetime =3D l_time_to_secs(l_time_now()) +
-						server->lease_seconds;
-	else
-		lease->lifetime =3D expire;
-
-	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
+	lease->offering =3D offering;
+	lease->lifetime =3D l_time_to_secs(l_time_now());
+
+	if (!offering) {
+		lease->lifetime +=3D server->lease_seconds;
+
+		/*
+		 * Insert into queue by lifetime (skipping any offered leases
+		 * at the head)
+		 */
+		l_queue_insert(server->lease_list, lease,
+					compare_lifetime_or_offering, NULL);
+		/*
+		 * This is a new (or renewed lease) so pass NULL for expired so
+		 * the queue's are not modified, only the next_expired timer
+		 */
+		set_next_expire_timer(server, NULL);
+	} else {
+		lease->lifetime +=3D OFFER_TIME;
+		/* Push offered leases to head, active leases after those */
+		l_queue_push_head(server->lease_list, lease);
+	}
 =

 	SERVER_DEBUG("added lease IP %s for "MAC " lifetime=3D%u",
 			IP_STR(yiaddr), MAC_STR(chaddr),
@@ -196,17 +278,21 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_s=
erver *server,
 }
 =

 static void lease_release(struct l_dhcp_server *server,
-			struct l_dhcp_lease *lease, uint32_t expire)
+			struct l_dhcp_lease *lease)
 {
-	l_queue_remove(server->lease_list, lease);
-
-	lease->lifetime =3D expire;
-
-	l_queue_insert(server->lease_list, lease, compare_lifetime, NULL);
+	/*
+	 * If the client released the lease after the server timeout expired
+	 * there is nothing to do. Otherwise the client is releasing the
+	 * lease early which may require re-setting the lease expire timer
+	 */
+	if (is_expired_lease(lease))
+		return;
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_LEASE_EXPIRED,
 					server->user_data, lease);
+
+	set_next_expire_timer(server, lease);
 }
 =

 static bool match_lease_ip(const void *data, const void *user_data)
@@ -216,11 +302,10 @@ static bool match_lease_ip(const void *data, const vo=
id *user_data)
 	return lease->address =3D=3D L_PTR_TO_UINT(user_data);
 }
 =

-static struct l_dhcp_lease *find_lease_by_ip(struct l_dhcp_server *server,
+static struct l_dhcp_lease *find_lease_by_ip(struct l_queue *lease_list,
 						uint32_t nip)
 {
-	return l_queue_find(server->lease_list, match_lease_ip,
-				L_UINT_TO_PTR(nip));
+	return l_queue_find(lease_list, match_lease_ip, L_UINT_TO_PTR(nip));
 }
 =

 static bool check_requested_ip(struct l_dhcp_server *server,
@@ -237,7 +322,7 @@ static bool check_requested_ip(struct l_dhcp_server *se=
rver,
 	if (htonl(requested_nip) > server->end_ip)
 		return false;
 =

-	lease =3D find_lease_by_ip(server, requested_nip);
+	lease =3D find_lease_by_ip(server->lease_list, requested_nip);
 	if (!lease)
 		return true;
 =

@@ -272,7 +357,17 @@ static uint32_t find_free_or_expired_ip(struct l_dhcp_=
server *server,
 		if ((ip_addr & 0xff) =3D=3D 0xff)
 			continue;
 =

-		lease =3D find_lease_by_ip(server, ip_nl);
+		/*
+		 * Search both active and expired leases. If this exausts all
+		 * IP's in the range pop the expired list (oldest expired lease)
+		 * and use that IP. If the expired list is empty we have reached
+		 * our maximum number of clients.
+		 */
+		lease =3D find_lease_by_ip(server->lease_list, ip_nl);
+		if (lease)
+			continue;
+
+		lease =3D find_lease_by_ip(server->expired_list, ip_nl);
 		if (lease)
 			continue;
 =

@@ -280,16 +375,10 @@ static uint32_t find_free_or_expired_ip(struct l_dhcp=
_server *server,
 			return ip_nl;
 	}
 =

-	lease =3D l_queue_peek_tail(server->lease_list);
+	lease =3D l_queue_pop_head(server->expired_list);
 	if (!lease)
 		return 0;
 =

-	if (!is_expired_lease(lease))
-		return 0;
-
-	if (!arp_check(lease->address, safe_mac))
-		return 0;
-
 	return lease->address;
 }
 =

@@ -350,8 +439,7 @@ static void send_offer(struct l_dhcp_server *server,
 		return;
 	}
 =

-	lease =3D add_lease(server, l_time_to_secs(l_time_now()) + OFFER_TIME,
-				client_msg->chaddr, reply->yiaddr);
+	lease =3D add_lease(server, true, client_msg->chaddr, reply->yiaddr);
 	if (!lease) {
 		SERVER_DEBUG("No free IP addresses, OFFER abandoned");
 		return;
@@ -467,7 +555,7 @@ static void send_ack(struct l_dhcp_server *server,
 		return;
 	}
 =

-	lease =3D add_lease(server, 0, reply->chaddr, reply->yiaddr);
+	lease =3D add_lease(server, false, reply->chaddr, reply->yiaddr);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
@@ -567,8 +655,7 @@ static void listener_event(const void *data, size_t len=
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
@@ -607,10 +694,12 @@ LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(in=
t ifindex)
 		return NULL;
 =

 	server->lease_list =3D l_queue_new();
+	server->expired_list =3D l_queue_new();
 =

 	server->started =3D false;
 =

 	server->lease_seconds =3D DEFAULT_DHCP_LEASE_SEC;
+	server->max_expired =3D MAX_EXPIRED_LEASES;
 =

 	server->ifindex =3D ifindex;
 	server->debug_handler =3D NULL;
@@ -634,6 +723,8 @@ LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_ser=
ver *server)
 =

 	l_queue_destroy(server->lease_list,
 				(l_queue_destroy_func_t) _dhcp_lease_free);
+	l_queue_destroy(server->expired_list,
+				(l_queue_destroy_func_t) _dhcp_lease_free);
 =

 	if (server->dns_list)
 		l_free(server->dns_list);
@@ -720,6 +811,11 @@ LIB_EXPORT bool l_dhcp_server_stop(struct l_dhcp_serve=
r *server)
 =

 	server->started =3D false;
 =

+	if (server->next_expire) {
+		l_timeout_remove(server->next_expire);
+		server->next_expire =3D NULL;
+	}
+
 	/* TODO: Add ability to save leases */
 =

 	return true;
-- =

2.26.2

--===============4311084987995908752==--

