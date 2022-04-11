Content-Type: multipart/mixed; boundary="===============0000048742256427753=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 07/11] icmp6: Emit L_ICMP6_CLIENT_EVENT_ROUTER_FOUND for all
 RAs
Date: Mon, 11 Apr 2022 16:20:52 +0200
Message-ID: <20220411142056.817784-7-andrew.zaborowski@intel.com>
In-Reply-To: 20220411142056.817784-1-andrew.zaborowski@intel.com

--===============0000048742256427753==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Emit an L_ICMP6_CLIENT_EVENT_ROUTER_FOUND event for ever Router
Advertisement received instead of only the first one.
---
 ell/dhcp6.c | 10 +++++++---
 ell/icmp6.c | 17 ++++++++---------
 2 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 424fad0..01d7eb3 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1473,9 +1473,6 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_c=
lient *icmp6,
 {
 	struct l_dhcp6_client *client =3D user_data;
 =

-	l_timeout_remove(client->timeout_send);
-	client->timeout_send =3D NULL;
-
 	switch (event) {
 	case L_ICMP6_CLIENT_EVENT_ROUTER_FOUND:
 	{
@@ -1488,6 +1485,13 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_=
client *icmp6,
 				managed ? "yes" : "no",
 				other ? "yes" : "no");
 =

+		/* We only process the first RA received for now */
+		if (!client->timeout_send)
+			return;
+
+		l_timeout_remove(client->timeout_send);
+		client->timeout_send =3D NULL;
+
 		if (!managed && !other) {
 			l_dhcp6_client_stop(client);
 			dhcp6_client_event_notify(client,
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 4128f01..82ca997 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -378,16 +378,16 @@ static int icmp6_client_handle_message(struct l_icmp6=
_client *client,
 	if (!r)
 		return -EBADMSG;
 =

-	if (!client->ra) {
-		client->ra =3D r;
-		icmp6_client_event_notify(client,
+	icmp6_client_event_notify(client,
 					L_ICMP6_CLIENT_EVENT_ROUTER_FOUND,
-					NULL);
+					r);
 =

-		/* DHCP6 client may have stopped us */
-		if (!client->ra)
-			return -ECANCELED;
+	/* DHCP6 client may have stopped us */
+	if (!client->io)
+		return -ECANCELED;
 =

+	if (!client->ra) {
+		client->ra =3D r;
 		icmp6_client_setup_routes(client);
 		return 0;
 	}
@@ -396,8 +396,7 @@ static int icmp6_client_handle_message(struct l_icmp6_c=
lient *client,
 	 * TODO: Figure out if the RA has updated info and update routes
 	 * accordingly.
 	 */
-	_icmp6_router_free(client->ra);
-	client->ra =3D r;
+	_icmp6_router_free(r);
 	return 0;
 }
 =

-- =

2.32.0

--===============0000048742256427753==--

