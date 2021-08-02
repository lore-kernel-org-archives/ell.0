Content-Type: multipart/mixed; boundary="===============5524569474297963561=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 14/15] unit: Stricter checks in unit-dhcp
Date: Mon, 02 Aug 2021 16:04:23 +0200
Message-ID: <20210802140424.170150-14-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5524569474297963561==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When the client state machine is expected to have generated a packet and
the transport l2_send callback is expected to have filled in
client_packet/client_packet_len, make sure this has actually happened.
Without this the test passes with rapid-commit enabled even though the
code looks like it's requiring 4 messages -- the DHCPDISCOVER is being
re-sent and the server generates a second DHCPACK.
---
 unit/test-dhcp.c | 40 ++++++++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 6 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index e03eaca..079f037 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -655,13 +655,17 @@ static bool dhcp_message_compare(const uint8_t *expec=
ted, size_t expected_len,
 	return r;
 }
 =

+static bool client_send_called =3D false;
+
 static int fake_transport_send(struct dhcp_transport *transport,
 				const struct sockaddr_in *dest,
 				const void *data, size_t len)
 {
 	assert(len <=3D sizeof(client_packet));
+	assert(!client_send_called);
 	memcpy(client_packet, data, len);
 	client_packet_len =3D len;
+	client_send_called =3D true;
 =

 	return len;
 }
@@ -673,8 +677,10 @@ static int fake_transport_l2_send(struct dhcp_transpor=
t *transprot,
 					const void *data, size_t len)
 {
 	assert(len <=3D sizeof(client_packet));
+	assert(!client_send_called);
 	memcpy(client_packet, data, len);
 	client_packet_len =3D len;
+	client_send_called =3D true;
 =

 	return len;
 }
@@ -710,16 +716,21 @@ static void test_discover(const void *data)
 =

 	assert(l_dhcp_client_start(client));
 =

+	assert(client_send_called);
+	client_send_called =3D false;
 	assert(dhcp_message_compare(discover_data_1, sizeof(discover_data_1),
 					client_packet, client_packet_len));
 =

 	transport->rx_cb(offer_data_1, sizeof(offer_data_1), client);
 =

+	assert(client_send_called);
+	client_send_called =3D false;
 	assert(dhcp_message_compare(request_data_1, sizeof(request_data_1),
 					client_packet, client_packet_len));
 =

 	event_handler_called =3D false;
 	transport->rx_cb(ack_data_1, sizeof(ack_data_1), client);
+	assert(!client_send_called);
 	assert(event_handler_called);
 =

 	lease =3D l_dhcp_client_get_lease(client);
@@ -736,6 +747,8 @@ static void test_discover(const void *data)
 	assert(lease->t2 =3D=3D 0x00012750);
 =

 	l_dhcp_client_destroy(client);
+	assert(client_send_called);
+	client_send_called =3D false;
 }
 =

 static bool l2_send_called =3D false;
@@ -749,6 +762,7 @@ static int fake_transport_server_l2_send(struct dhcp_tr=
ansport *s,
 					const void *data, size_t len)
 {
 	assert(len <=3D sizeof(server_packet));
+	assert(!l2_send_called);
 	memcpy(server_packet, data, len);
 	server_packet_len =3D len;
 =

@@ -774,9 +788,11 @@ static void server_event(struct l_dhcp_server *server,
 {
 	switch (event) {
 	case L_DHCP_SERVER_EVENT_NEW_LEASE:
+		assert(!new_client);
 		new_client =3D l_dhcp_lease_get_address(lease);
 		break;
 	case L_DHCP_SERVER_EVENT_LEASE_EXPIRED:
+		assert(!expired_client);
 		expired_client =3D l_dhcp_lease_get_address(lease);
 		break;
 	}
@@ -806,15 +822,17 @@ static struct l_dhcp_client *client_init(const uint8_=
t *mac)
 	return client;
 }
 =

-static bool client_connect(struct l_dhcp_client *client,
+static void client_connect(struct l_dhcp_client *client,
 				struct l_dhcp_server *server)
 {
 	struct dhcp_transport *srv_transport =3D
 					_dhcp_server_get_transport(server);
 	struct dhcp_transport *cli_transport =3D
 					_dhcp_client_get_transport(client);
-	if (!l_dhcp_client_start(client))
-		return false;
+
+	assert(l_dhcp_client_start(client));
+	assert(client_send_called);
+	client_send_called =3D false;
 =

 	/* RX DISCOVER */
 	srv_transport->rx_cb(client_packet, client_packet_len, server);
@@ -823,6 +841,8 @@ static bool client_connect(struct l_dhcp_client *client,
 =

 	/* RX OFFER */
 	cli_transport->rx_cb(server_packet, server_packet_len, client);
+	assert(client_send_called);
+	client_send_called =3D false;
 =

 	/* RX REQUEST */
 	srv_transport->rx_cb(client_packet, client_packet_len, server);
@@ -831,10 +851,9 @@ static bool client_connect(struct l_dhcp_client *clien=
t,
 =

 	/* RX ACK */
 	cli_transport->rx_cb(server_packet, server_packet_len, client);
+	assert(!client_send_called);
 =

 	assert(event_handler_called);
-
-	return true;
 }
 =

 static struct l_dhcp_server *server_init()
@@ -941,7 +960,8 @@ static void test_complete_run(const void *data)
 	l_free(cli_addr);
 =

 	l_dhcp_client_stop(client1);
-
+	assert(client_send_called);
+	client_send_called =3D false;
 	srv_transport->rx_cb(client_packet, client_packet_len, server);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.2"));
@@ -949,6 +969,8 @@ static void test_complete_run(const void *data)
 	expired_client =3D NULL;
 =

 	l_dhcp_client_stop(client2);
+	assert(client_send_called);
+	client_send_called =3D false;
 	srv_transport->rx_cb(client_packet, client_packet_len, server);
 	assert(expired_client);
 	assert(!strcmp(expired_client, "192.168.1.3"));
@@ -956,7 +978,9 @@ static void test_complete_run(const void *data)
 	expired_client =3D NULL;
 =

 	l_dhcp_client_destroy(client1);
+	assert(!client_send_called);
 	l_dhcp_client_destroy(client2);
+	assert(!client_send_called);
 =

 	l_dhcp_server_stop(server);
 	l_dhcp_server_destroy(server);
@@ -992,6 +1016,8 @@ static void test_expired_ip_reuse(const void *data)
 		new_client =3D NULL;
 =

 		l_dhcp_client_destroy(client);
+		assert(client_send_called);
+		client_send_called =3D false;
 		srv_transport->rx_cb(client_packet, client_packet_len, server);
 		l_free(expired_client);
 		expired_client =3D NULL;
@@ -1010,6 +1036,8 @@ static void test_expired_ip_reuse(const void *data)
 	l_free(cli_addr);
 =

 	l_dhcp_client_destroy(client_new);
+	assert(client_send_called);
+	client_send_called =3D false;
 	l_dhcp_server_destroy(server);
 }
 =

-- =

2.30.2

--===============5524569474297963561==--

