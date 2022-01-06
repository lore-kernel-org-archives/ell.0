Content-Type: multipart/mixed; boundary="===============2626533561844213845=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 5/5] icmp6: Set limits on route list sizes
Date: Thu, 06 Jan 2022 16:05:29 +0100
Message-ID: <20220106150529.458775-5-andrew.zaborowski@intel.com>
In-Reply-To: 20220106150529.458775-1-andrew.zaborowski@intel.com

--===============2626533561844213845==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It seems to be easy for someone to DOS the ICMP6 stacks on a local
network by sending a lot of RAs.
---
 ell/icmp6.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index f720bc5..b7c0fcc 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -410,6 +410,8 @@ static void icmp6_router_update(struct l_icmp6_client *=
client,
 		icmp6_client_event_notify(client, event, r);
 }
 =

+#define ICMP6_MAX_ROUTES 50
+
 /* Mostly RFC4861 Section 6.3.4 */
 static void icmp6_onlink_prefix_update(struct l_icmp6_client *client,
 					struct l_icmp6_router *ra,
@@ -494,6 +496,14 @@ static void icmp6_onlink_prefix_update(struct l_icmp6_=
client *client,
 	info->client =3D client;
 	l_queue_push_head(client->prefix_routes, info);
 =

+	/* Prevent the queue from growing too long (possible DOS) */
+	if (l_queue_length(client->prefix_routes) > ICMP6_MAX_ROUTES) {
+		CLIENT_DEBUG("Too many prefix routes, removing oldest");
+
+		icmp6_prefix_timeout(NULL,
+				l_queue_peek_tail(client->prefix_routes));
+	}
+
 	if (!changed)
 		return;
 =

@@ -552,6 +562,26 @@ static int icmp6_client_handle_message(struct l_icmp6_=
client *client,
 		r->client =3D client;
 		l_queue_push_head(client->routers, r);
 =

+		/* Prevent the queue from growing too long (possible DOS) */
+		if (l_queue_length(client->routers) > ICMP6_MAX_ROUTES) {
+			struct l_icmp6_router *r2 =3D
+				l_queue_peek_tail(client->routers);
+			enum l_icmp6_client_event event =3D
+				L_ICMP6_CLIENT_EVENT_DEFAULT_ROUTER_REMOVED;
+
+			CLIENT_DEBUG("Too many routers, removing oldest");
+			l_queue_remove(client->routers, r2);
+
+			if (r2->default_route)
+				icmp6_client_event_notify(client, event, r2);
+
+			_icmp6_router_free(r2);
+
+			/* Client may have stopped us */
+			if (!client->io)
+				return -ECANCELED;
+		}
+
 		icmp6_client_event_notify(client,
 					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND,
 					NULL);
-- =

2.32.0

--===============2626533561844213845==--

