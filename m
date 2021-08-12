Content-Type: multipart/mixed; boundary="===============0200203922295160840=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] dhcp: Add public l_dhcp_lease_{new,free}
Date: Thu, 12 Aug 2021 22:51:09 +0200
Message-ID: <20210812205112.86584-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0200203922295160840==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the constructor & destructor for struct l_dhcp_lease public, this
is to be used with the new l_dhcp_client_set_lease() method.
---
 ell/dhcp-lease.c   |  8 ++++----
 ell/dhcp-private.h |  2 --
 ell/dhcp-server.c  | 18 +++++++++---------
 ell/dhcp.c         |  4 ++--
 ell/dhcp.h         |  2 ++
 ell/ell.sym        |  2 ++
 6 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index c596c6b..a28a3f3 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -35,14 +35,14 @@
 #include "utf8.h"
 #include "net.h"
 =

-struct l_dhcp_lease *_dhcp_lease_new(void)
+LIB_EXPORT struct l_dhcp_lease *l_dhcp_lease_new(void)
 {
 	struct l_dhcp_lease *ret =3D l_new(struct l_dhcp_lease, 1);
 =

 	return ret;
 }
 =

-void _dhcp_lease_free(struct l_dhcp_lease *lease)
+LIB_EXPORT void l_dhcp_lease_free(struct l_dhcp_lease *lease)
 {
 	if (!lease)
 		return;
@@ -56,7 +56,7 @@ void _dhcp_lease_free(struct l_dhcp_lease *lease)
 =

 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter)
 {
-	struct l_dhcp_lease *lease =3D _dhcp_lease_new();
+	struct l_dhcp_lease *lease =3D l_dhcp_lease_new();
 	uint8_t t, l;
 	const void *v;
 =

@@ -183,7 +183,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 =

 	return lease;
 error:
-	_dhcp_lease_free(lease);
+	l_dhcp_lease_free(lease);
 	return NULL;
 }
 =

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index bc10765..5864dc3 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -175,8 +175,6 @@ struct l_dhcp_lease {
 	bool offering : 1;
 };
 =

-struct l_dhcp_lease *_dhcp_lease_new(void);
-void _dhcp_lease_free(struct l_dhcp_lease *lease);
 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter);
 =

 struct dhcp_message_builder {
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 05f9b73..5d9f3f6 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -257,12 +257,12 @@ static void set_next_expire_timer(struct l_dhcp_serve=
r *server,
 		if (!expired->offering) {
 			if (l_queue_length(server->expired_list) >
 					server->max_expired)
-				_dhcp_lease_free(l_queue_pop_head(
+				l_dhcp_lease_free(l_queue_pop_head(
 							server->expired_list));
 =

 			l_queue_push_tail(server->expired_list, expired);
 		} else
-			_dhcp_lease_free(expired);
+			l_dhcp_lease_free(expired);
 	}
 =

 	next =3D l_queue_peek_tail(server->lease_list);
@@ -356,7 +356,7 @@ static bool remove_lease(struct l_dhcp_server *server,
 	if (!l_queue_remove(server->lease_list, lease))
 		return false;
 =

-	_dhcp_lease_free(lease);
+	l_dhcp_lease_free(lease);
 	set_next_expire_timer(server, NULL);
 	return true;
 }
@@ -449,7 +449,7 @@ static uint32_t find_free_or_expired_ip(struct l_dhcp_s=
erver *server,
 		return 0;
 =

 	ip_addr =3D lease->address;
-	_dhcp_lease_free(lease);
+	l_dhcp_lease_free(lease);
 	return ip_addr;
 }
 =

@@ -997,9 +997,9 @@ LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_ser=
ver *server)
 	l_free(server->ifname);
 =

 	l_queue_destroy(server->lease_list,
-				(l_queue_destroy_func_t) _dhcp_lease_free);
+				(l_queue_destroy_func_t) l_dhcp_lease_free);
 	l_queue_destroy(server->expired_list,
-				(l_queue_destroy_func_t) _dhcp_lease_free);
+				(l_queue_destroy_func_t) l_dhcp_lease_free);
 =

 	if (server->dns_list)
 		l_free(server->dns_list);
@@ -1414,7 +1414,7 @@ LIB_EXPORT bool l_dhcp_server_lease_remove(struct l_d=
hcp_server *server,
 			!l_queue_remove(server->expired_list, lease)))
 		return false;
 =

-	_dhcp_lease_free(lease);
+	l_dhcp_lease_free(lease);
 	set_next_expire_timer(server, NULL);
 	return true;
 }
@@ -1440,11 +1440,11 @@ static bool dhcp_expire_by_mac(void *data, void *us=
er_data)
 =

 	if (!lease->offering) {
 		if (l_queue_length(server->expired_list) > server->max_expired)
-			_dhcp_lease_free(l_queue_pop_head(server->expired_list));
+			l_dhcp_lease_free(l_queue_pop_head(server->expired_list));
 =

 		l_queue_push_tail(server->expired_list, lease);
 	} else
-		_dhcp_lease_free(lease);
+		l_dhcp_lease_free(lease);
 =

 	expire_data->expired_cnt++;
 	return true;
diff --git a/ell/dhcp.c b/ell/dhcp.c
index 32e4a7c..e06ab05 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -705,7 +705,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 				client->lease->router !=3D lease->router)
 			r =3D L_DHCP_CLIENT_EVENT_IP_CHANGED;
 =

-		_dhcp_lease_free(client->lease);
+		l_dhcp_lease_free(client->lease);
 	}
 =

 	client->lease =3D lease;
@@ -1218,7 +1218,7 @@ LIB_EXPORT bool l_dhcp_client_stop(struct l_dhcp_clie=
nt *client)
 	client->start_t =3D 0;
 	CLIENT_ENTER_STATE(DHCP_STATE_INIT);
 =

-	_dhcp_lease_free(client->lease);
+	l_dhcp_lease_free(client->lease);
 	client->lease =3D NULL;
 =

 	if (client->acd) {
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 5873c90..4f18f01 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -104,6 +104,8 @@ bool l_dhcp_client_set_debug(struct l_dhcp_client *clie=
nt,
 				l_dhcp_debug_cb_t function,
 				void *user_data, l_dhcp_destroy_cb_t destroy);
 =

+struct l_dhcp_lease *l_dhcp_lease_new(void);
+void l_dhcp_lease_free(struct l_dhcp_lease *lease);
 =

 char *l_dhcp_lease_get_address(const struct l_dhcp_lease *lease);
 char *l_dhcp_lease_get_gateway(const struct l_dhcp_lease *lease);
diff --git a/ell/ell.sym b/ell/ell.sym
index b29d98d..66ebf46 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -223,6 +223,8 @@ global:
 	l_dbus_remove_signal_watch;
 	l_dbus_name_acquire;
 	/* dhcp */
+	l_dhcp_lease_new;
+	l_dhcp_lease_free;
 	l_dhcp_lease_get_address;
 	l_dhcp_lease_get_gateway;
 	l_dhcp_lease_get_mac;
-- =

2.30.2

--===============0200203922295160840==--

