Content-Type: multipart/mixed; boundary="===============0834134914859307221=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/5] icmp6: Allow multiple event handlers and clean up
Date: Thu, 06 Jan 2022 16:05:25 +0100
Message-ID: <20220106150529.458775-1-andrew.zaborowski@intel.com>

--===============0834134914859307221==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow registering multiple event handlers and rename
l_icmp6_client_set_event_handler to l_icmp6_client_add_event_handler
accordingly.  The use case is for a client like IWD to be able to track
routing information.

This also fixes a bug where the destroy callback passed to
l_icmp6_client_set_event_handler wasn't actually used except if
l_icmp6_client_set_event_handler was called again.

While there, add an event_data parameter to the event callback, rename
the "userdata" parameters to "user_data" for consistency and clean up an
extra empty line.
---
 ell/dhcp6.c |  4 ++--
 ell/ell.sym |  2 +-
 ell/icmp6.c | 56 +++++++++++++++++++++++++++++++++++++++--------------
 ell/icmp6.h |  8 ++++----
 4 files changed, 48 insertions(+), 22 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 3e38ff2..40c6f3a 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1467,7 +1467,7 @@ static void dhcp6_client_send_initial(struct l_dhcp6_=
client *client)
 =

 static void dhcp6_client_icmp6_event(struct l_icmp6_client *icmp6,
 					enum l_icmp6_client_event event,
-					void *user_data)
+					void *event_data, void *user_data)
 {
 	struct l_dhcp6_client *client =3D user_data;
 =

@@ -1521,7 +1521,7 @@ LIB_EXPORT struct l_dhcp6_client *l_dhcp6_client_new(=
uint32_t ifindex)
 	client->request_na =3D true;
 =

 	client->icmp6 =3D l_icmp6_client_new(ifindex);
-	l_icmp6_client_set_event_handler(client->icmp6,
+	l_icmp6_client_add_event_handler(client->icmp6,
 						dhcp6_client_icmp6_event,
 						client, NULL);
 =

diff --git a/ell/ell.sym b/ell/ell.sym
index 51db458..8da344e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -679,7 +679,7 @@ global:
 	l_icmp6_client_start;
 	l_icmp6_client_stop;
 	l_icmp6_client_get_router;
-	l_icmp6_client_set_event_handler;
+	l_icmp6_client_add_event_handler;
 	l_icmp6_client_set_debug;
 	l_icmp6_client_set_address;
 	l_icmp6_client_set_nodelay;
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 42fe67d..6b1652c 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -237,6 +237,12 @@ static int icmp6_receive(int s, void *buf, size_t buf_=
len, struct in6_addr *src)
 	return 0;
 }
 =

+struct icmp6_event_handler_entry {
+	l_icmp6_client_event_cb_t handle;
+	void *user_data;
+	l_icmp6_destroy_cb_t destroy;
+};
+
 struct l_icmp6_client {
 	uint32_t ifindex;
 	uint8_t mac[6];
@@ -249,9 +255,7 @@ struct l_icmp6_client {
 	uint32_t route_priority;
 	struct l_queue *routes;
 =

-	l_icmp6_client_event_cb_t event_handler;
-	void *event_data;
-	l_icmp6_destroy_cb_t event_destroy;
+	struct l_queue *event_handlers;
 =

 	l_icmp6_debug_cb_t debug_handler;
 	l_icmp6_destroy_cb_t debug_destroy;
@@ -262,10 +266,17 @@ struct l_icmp6_client {
 };
 =

 static inline void icmp6_client_event_notify(struct l_icmp6_client *client,
-						enum l_icmp6_client_event event)
+						enum l_icmp6_client_event event,
+						void *event_data)
 {
-	if (client->event_handler)
-		client->event_handler(client, event, client->event_data);
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(client->event_handlers); entry;
+			entry =3D entry->next) {
+		struct icmp6_event_handler_entry *handler =3D entry->data;
+
+		handler->handle(client, event, event_data, handler->user_data);
+	}
 }
 =

 static bool icmp6_client_remove_route(void *data, void *user_data)
@@ -343,7 +354,8 @@ static int icmp6_client_handle_message(struct l_icmp6_c=
lient *client,
 	if (!client->ra) {
 		client->ra =3D r;
 		icmp6_client_event_notify(client,
-					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND);
+					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND,
+					NULL);
 =

 		/* DHCP6 client may have stopped us */
 		if (!client->ra)
@@ -446,6 +458,16 @@ LIB_EXPORT struct l_icmp6_client *l_icmp6_client_new(u=
int32_t ifindex)
 	return client;
 }
 =

+static void icmp6_event_handler_destroy(void *data)
+{
+	struct icmp6_event_handler_entry *handler =3D data;
+
+	if (handler->destroy)
+		handler->destroy(handler->user_data);
+
+	l_free(handler);
+}
+
 LIB_EXPORT void l_icmp6_client_free(struct l_icmp6_client *client)
 {
 	if (unlikely(!client))
@@ -453,6 +475,7 @@ LIB_EXPORT void l_icmp6_client_free(struct l_icmp6_clie=
nt *client)
 =

 	l_icmp6_client_stop(client);
 	l_queue_destroy(client->routes, NULL);
+	l_queue_destroy(client->event_handlers, icmp6_event_handler_destroy);
 	l_free(client);
 }
 =

@@ -537,20 +560,24 @@ LIB_EXPORT const struct l_icmp6_router *l_icmp6_clien=
t_get_router(
 	return client->ra;
 }
 =

-LIB_EXPORT bool l_icmp6_client_set_event_handler(struct l_icmp6_client *cl=
ient,
+LIB_EXPORT bool l_icmp6_client_add_event_handler(struct l_icmp6_client *cl=
ient,
 					l_icmp6_client_event_cb_t handler,
-					void *userdata,
+					void *user_data,
 					l_icmp6_destroy_cb_t destroy)
 {
+	struct icmp6_event_handler_entry *handler_entry;
+
 	if (unlikely(!client))
 		return false;
 =

-	if (client->event_destroy)
-		client->event_destroy(client->event_data);
+	if (!client->event_handlers)
+		client->event_handlers =3D l_queue_new();
 =

-	client->event_handler =3D handler;
-	client->event_data =3D userdata;
-	client->event_destroy =3D destroy;
+	handler_entry =3D l_new(struct icmp6_event_handler_entry, 1);
+	handler_entry->handle =3D handler;
+	handler_entry->user_data =3D user_data;
+	handler_entry->destroy =3D destroy;
+	l_queue_push_head(client->event_handlers, handler_entry);
 =

 	return true;
 }
@@ -683,7 +710,6 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 		opts_len -=3D l;
 	}
 =

-
 	r =3D _icmp6_router_new();
 	memcpy(r->address, src, sizeof(r->address));
 	r->prefixes =3D l_new(struct route_info, n_prefixes);
diff --git a/ell/icmp6.h b/ell/icmp6.h
index b2231c9..9ce2e24 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -38,10 +38,10 @@ enum l_icmp6_client_event {
 };
 =

 typedef void (*l_icmp6_debug_cb_t)(const char *str, void *user_data);
-typedef void (*l_icmp6_destroy_cb_t)(void *userdata);
+typedef void (*l_icmp6_destroy_cb_t)(void *user_data);
 typedef void (*l_icmp6_client_event_cb_t)(struct l_icmp6_client *client,
 					enum l_icmp6_client_event event,
-					void *userdata);
+					void *event_data, void *user_data);
 =

 struct l_icmp6_client *l_icmp6_client_new(uint32_t ifindex);
 void l_icmp6_client_free(struct l_icmp6_client *client);
@@ -51,9 +51,9 @@ bool l_icmp6_client_stop(struct l_icmp6_client *client);
 =

 const struct l_icmp6_router *l_icmp6_client_get_router(
 						struct l_icmp6_client *client);
-bool l_icmp6_client_set_event_handler(struct l_icmp6_client *client,
+bool l_icmp6_client_add_event_handler(struct l_icmp6_client *client,
 					l_icmp6_client_event_cb_t handler,
-					void *userdata,
+					void *user_data,
 					l_icmp6_destroy_cb_t destroy);
 bool l_icmp6_client_set_debug(struct l_icmp6_client *client,
 				l_icmp6_debug_cb_t function,
-- =

2.32.0

--===============0834134914859307221==--

