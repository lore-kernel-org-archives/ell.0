Content-Type: multipart/mixed; boundary="===============3197223215295230263=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: In test-dhcp update rx callback parameters
Date: Sat, 07 Aug 2021 01:52:59 +0200
Message-ID: <20210806235259.304436-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210806235259.304436-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3197223215295230263==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 11ee10e..e502be7 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -721,7 +721,7 @@ static void test_discover(const void *data)
 	assert(dhcp_message_compare(discover_data_1, sizeof(discover_data_1),
 					client_packet, client_packet_len));
 =

-	transport->rx_cb(offer_data_1, sizeof(offer_data_1), client);
+	transport->rx_cb(offer_data_1, sizeof(offer_data_1), client, NULL);
 =

 	assert(client_send_called);
 	client_send_called =3D false;
@@ -729,7 +729,7 @@ static void test_discover(const void *data)
 					client_packet, client_packet_len));
 =

 	event_handler_called =3D false;
-	transport->rx_cb(ack_data_1, sizeof(ack_data_1), client);
+	transport->rx_cb(ack_data_1, sizeof(ack_data_1), client, NULL);
 	assert(!client_send_called);
 	assert(event_handler_called);
 =

@@ -829,30 +829,36 @@ static void client_connect(struct l_dhcp_client *clie=
nt,
 					_dhcp_server_get_transport(server);
 	struct dhcp_transport *cli_transport =3D
 					_dhcp_client_get_transport(client);
+	uint8_t cli_addr[ETH_ALEN];
+	const struct dhcp_message *msg =3D (struct dhcp_message *) client_packet;
 =

 	assert(l_dhcp_client_start(client));
 	assert(client_send_called);
 	client_send_called =3D false;
+	memcpy(cli_addr, msg->chaddr, ETH_ALEN);
 =

 	/* RX DISCOVER */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	srv_transport->rx_cb(client_packet, client_packet_len, server,
+				cli_addr);
 	assert(l2_send_called);
 	l2_send_called =3D false;
 =

 	if (!rapid_commit) {
 		/* RX OFFER */
-		cli_transport->rx_cb(server_packet, server_packet_len, client);
+		cli_transport->rx_cb(server_packet, server_packet_len, client,
+					NULL);
 		assert(client_send_called);
 		client_send_called =3D false;
 =

 		/* RX REQUEST */
-		srv_transport->rx_cb(client_packet, client_packet_len, server);
+		srv_transport->rx_cb(client_packet, client_packet_len, server,
+					cli_addr);
 		assert(l2_send_called);
 		l2_send_called =3D false;
 	}
 =

 	/* RX ACK */
-	cli_transport->rx_cb(server_packet, server_packet_len, client);
+	cli_transport->rx_cb(server_packet, server_packet_len, client, NULL);
 	assert(!client_send_called);
 =

 	assert(event_handler_called);
@@ -966,7 +972,7 @@ static void test_complete_run(const void *data)
 	l_dhcp_client_stop(client1);
 	assert(client_send_called);
 	client_send_called =3D false;
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	srv_transport->rx_cb(client_packet, client_packet_len, server, addr1);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.2"));
 	l_free(expired_client);
@@ -975,7 +981,7 @@ static void test_complete_run(const void *data)
 	l_dhcp_client_stop(client2);
 	assert(client_send_called);
 	client_send_called =3D false;
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	srv_transport->rx_cb(client_packet, client_packet_len, server, addr2);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.3"));
 	l_free(expired_client);
@@ -1023,7 +1029,8 @@ static void test_expired_ip_reuse(const void *data)
 		l_dhcp_client_destroy(client);
 		assert(client_send_called);
 		client_send_called =3D false;
-		srv_transport->rx_cb(client_packet, client_packet_len, server);
+		srv_transport->rx_cb(client_packet, client_packet_len, server,
+					addr);
 		l_free(expired_client);
 		expired_client =3D NULL;
 	}
-- =

2.30.2

--===============3197223215295230263==--

