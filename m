Content-Type: multipart/mixed; boundary="===============8461108486259292541=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 08/12] unit: Update dhcp{,6} receive handler arguments
Date: Mon, 07 Mar 2022 15:55:39 +0100
Message-ID: <20220307145543.1558788-8-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============8461108486259292541==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c  | 20 +++++++++++---------
 unit/test-dhcp6.c |  2 +-
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 28f763a..e734e03 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -721,7 +721,7 @@ static void test_discover(const void *data)
 	assert(dhcp_message_compare(discover_data_1, sizeof(discover_data_1),
 					client_packet, client_packet_len));
 =

-	transport->rx_cb(offer_data_1, sizeof(offer_data_1), client, NULL);
+	transport->rx_cb(offer_data_1, sizeof(offer_data_1), client, NULL, 0);
 =

 	assert(client_send_called);
 	client_send_called =3D false;
@@ -729,7 +729,7 @@ static void test_discover(const void *data)
 					client_packet, client_packet_len));
 =

 	event_handler_called =3D false;
-	transport->rx_cb(ack_data_1, sizeof(ack_data_1), client, NULL);
+	transport->rx_cb(ack_data_1, sizeof(ack_data_1), client, NULL, 0);
 	assert(!client_send_called);
 	assert(event_handler_called);
 =

@@ -839,26 +839,26 @@ static void client_connect(struct l_dhcp_client *clie=
nt,
 =

 	/* RX DISCOVER */
 	srv_transport->rx_cb(client_packet, client_packet_len, server,
-				cli_addr);
+				cli_addr, 0);
 	assert(l2_send_called);
 	l2_send_called =3D false;
 =

 	if (!rapid_commit) {
 		/* RX OFFER */
 		cli_transport->rx_cb(server_packet, server_packet_len, client,
-					NULL);
+					NULL, 0);
 		assert(client_send_called);
 		client_send_called =3D false;
 =

 		/* RX REQUEST */
 		srv_transport->rx_cb(client_packet, client_packet_len, server,
-					cli_addr);
+					cli_addr, 0);
 		assert(l2_send_called);
 		l2_send_called =3D false;
 	}
 =

 	/* RX ACK */
-	cli_transport->rx_cb(server_packet, server_packet_len, client, NULL);
+	cli_transport->rx_cb(server_packet, server_packet_len, client, NULL, 0);
 	assert(!client_send_called);
 =

 	assert(event_handler_called);
@@ -974,7 +974,8 @@ static void test_complete_run(const void *data)
 	l_dhcp_client_stop(client1);
 	assert(client_send_called);
 	client_send_called =3D false;
-	srv_transport->rx_cb(client_packet, client_packet_len, server, addr1);
+	srv_transport->rx_cb(client_packet, client_packet_len, server, addr1,
+				0);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.2"));
 	l_free(expired_client);
@@ -983,7 +984,8 @@ static void test_complete_run(const void *data)
 	l_dhcp_client_stop(client2);
 	assert(client_send_called);
 	client_send_called =3D false;
-	srv_transport->rx_cb(client_packet, client_packet_len, server, addr2);
+	srv_transport->rx_cb(client_packet, client_packet_len, server, addr2,
+				0);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.3"));
 	l_free(expired_client);
@@ -1032,7 +1034,7 @@ static void test_expired_ip_reuse(const void *data)
 		assert(client_send_called);
 		client_send_called =3D false;
 		srv_transport->rx_cb(client_packet, client_packet_len, server,
-					addr);
+					addr, 0);
 		l_free(expired_client);
 		expired_client =3D NULL;
 	}
diff --git a/unit/test-dhcp6.c b/unit/test-dhcp6.c
index d7cea7c..1f6522b 100644
--- a/unit/test-dhcp6.c
+++ b/unit/test-dhcp6.c
@@ -235,7 +235,7 @@ static void event_handler_lease_obtained(struct l_dhcp6=
_client *client,
 	memcpy(transaction_id, client_packet + 1, sizeof(transaction_id)); \
 	memcpy(client_packet, packet, sizeof(packet)); \
 	memcpy(client_packet + 1, transaction_id, sizeof(transaction_id)); \
-	transport->rx_cb(client_packet, sizeof(packet), client) \
+	transport->rx_cb(client_packet, sizeof(packet), 0, client) \
 =

 static void test_obtain_lease(const void *data)
 {
-- =

2.32.0

--===============8461108486259292541==--

