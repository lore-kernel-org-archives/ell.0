Content-Type: multipart/mixed; boundary="===============5013616868488024235=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 4/5] unit: refactor test-dhcp to reuse code for other tests
Date: Mon, 23 Nov 2020 12:49:05 -0800
Message-ID: <20201123204906.4101813-4-prestwoj@gmail.com>
In-Reply-To: <20201123204906.4101813-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5013616868488024235==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add client_init, client_connect, and server_init functions to
make future tests easier to write.
---
 unit/test-dhcp.c | 166 +++++++++++++++++++++++------------------------
 1 file changed, 81 insertions(+), 85 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 2f41609..1f4bd8b 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -782,33 +782,69 @@ static void server_event(struct l_dhcp_server *server,
 	}
 }
 =

-static void test_complete_run(const void *data)
+static struct l_dhcp_client *client_init(const uint8_t *mac)
 {
-	static const uint8_t addr1[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
-	static const uint8_t addr2[6] =3D { 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c };
+	struct l_dhcp_client *client =3D l_dhcp_client_new(42);
+	struct dhcp_transport *transport =3D l_new(struct dhcp_transport, 1);
 =

-	char *dns[] =3D { "192.168.1.1", "192.168.1.254", NULL };
-	struct l_dhcp_client *client1;
-	struct l_dhcp_client *client2;
-	struct l_dhcp_server *server;
-	struct dhcp_transport *cli_transport1 =3D l_new(struct dhcp_transport, 1);
-	struct dhcp_transport *cli_transport2 =3D l_new(struct dhcp_transport, 1);
+	assert(l_dhcp_client_set_address(client, ARPHRD_ETHER, mac, 6));
+	assert(l_dhcp_client_set_interface_name(client, "fake"));
+	assert(l_dhcp_client_set_hostname(client, "<hostname>"));
+	_dhcp_client_override_xid(client, 0x4d7c67c6);
+	assert(l_dhcp_client_set_event_handler(client,
+				event_handler_lease_obtained, NULL, NULL));
 =

-	struct dhcp_transport *srv_transport =3D l_new(struct dhcp_transport, 1);
-	const struct l_dhcp_lease *cli_lease;
-	/* client IP address */
-	char *cli_addr;
-	/* servers IP address */
-	char *srv_addr;
-	char *tmp_addr;
-	char **dns_list;
+	if (verbose)
+		l_dhcp_client_set_debug(client, do_debug, "[DHCP1] ", NULL);
 =

-	server =3D l_dhcp_server_new(41);
+	transport->send =3D fake_transport_send;
+	transport->l2_send =3D fake_transport_l2_send;
+	transport->ifindex =3D 42;
+
+	assert(_dhcp_client_set_transport(client, transport));
+
+	return client;
+}
+
+static bool client_connect(struct l_dhcp_client *client,
+				struct l_dhcp_server *server)
+{
+	struct dhcp_transport *srv_transport =3D
+					_dhcp_server_get_transport(server);
+	struct dhcp_transport *cli_transport =3D
+					_dhcp_client_get_transport(client);
+	if (!l_dhcp_client_start(client))
+		return false;
+
+	/* RX DISCOVER */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX OFFER */
+	cli_transport->rx_cb(server_packet, server_packet_len, client);
+
+	/* RX REQUEST */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX ACK */
+	cli_transport->rx_cb(server_packet, server_packet_len, client);
+
+	assert(event_handler_called);
+
+	return true;
+}
+
+static struct l_dhcp_server *server_init()
+{
+	char *dns[] =3D { "192.168.1.1", "192.168.1.254", NULL };
+	struct l_dhcp_server *server =3D l_dhcp_server_new(41);
+	struct dhcp_transport *srv_transport =3D l_new(struct dhcp_transport, 1);
 =

 	assert(l_dhcp_server_set_interface_name(server, "fake"));
 	assert(l_dhcp_server_set_ip_address(server, "192.168.1.1"));
-	assert(l_dhcp_server_set_ip_range(server, "192.168.1.2",
-						"192.168.1.100"));
 	assert(l_dhcp_server_set_netmask(server, "255.255.255.0"));
 	assert(l_dhcp_server_set_gateway(server, "192.168.1.1"));
 	assert(l_dhcp_server_set_dns(server, dns));
@@ -825,60 +861,37 @@ static void test_complete_run(const void *data)
 =

 	assert(l_dhcp_server_start(server));
 =

-	client1 =3D l_dhcp_client_new(42);
-
-	assert(l_dhcp_client_set_address(client1, ARPHRD_ETHER, addr1, 6));
-	assert(l_dhcp_client_set_interface_name(client1, "fake"));
-	assert(l_dhcp_client_set_hostname(client1, "<hostname>"));
-	_dhcp_client_override_xid(client1, 0x4d7c67c6);
-	assert(l_dhcp_client_set_event_handler(client1,
-				event_handler_lease_obtained, NULL, NULL));
-
-	if (verbose)
-		l_dhcp_client_set_debug(client1, do_debug, "[DHCP1] ", NULL);
-
-	cli_transport1->send =3D fake_transport_send;
-	cli_transport1->l2_send =3D fake_transport_l2_send;
-	cli_transport1->ifindex =3D 42;
-
-	assert(_dhcp_client_set_transport(client1, cli_transport1));
-
-	assert(l_dhcp_client_start(client1));
-
-	client2 =3D l_dhcp_client_new(43);
-	assert(l_dhcp_client_set_address(client2, ARPHRD_ETHER, addr2, 6));
-	assert(l_dhcp_client_set_interface_name(client2, "fake"));
-	assert(l_dhcp_client_set_hostname(client2, "<hostname>"));
-	_dhcp_client_override_xid(client2, 0x5d7c67c6);
-	assert(l_dhcp_client_set_event_handler(client2,
-				event_handler_lease_obtained, NULL, NULL));
+	return server;
+}
 =

-	if (verbose)
-		l_dhcp_client_set_debug(client2, do_debug, "[DHCP2] ", NULL);
+static void test_complete_run(const void *data)
+{
+	static const uint8_t addr1[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
+	static const uint8_t addr2[6] =3D { 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c };
+	struct dhcp_transport *srv_transport;
 =

-	cli_transport2->send =3D fake_transport_send;
-	cli_transport2->l2_send =3D fake_transport_l2_send;
-	cli_transport2->ifindex =3D 42;
+	struct l_dhcp_client *client1;
+	struct l_dhcp_client *client2;
+	struct l_dhcp_server *server;
 =

-	assert(_dhcp_client_set_transport(client2, cli_transport2));
+	const struct l_dhcp_lease *cli_lease;
+	/* client IP address */
+	char *cli_addr;
+	/* servers IP address */
+	char *srv_addr;
+	char *tmp_addr;
+	char **dns_list;
 =

-	/* RX DISCOVER */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
-	assert(l2_send_called);
-	l2_send_called =3D false;
+	server =3D server_init();
 =

-	/* RX OFFER */
-	cli_transport1->rx_cb(server_packet, server_packet_len, client1);
+	assert(l_dhcp_server_set_ip_range(server, "192.168.1.2",
+						"192.168.1.100"));
 =

-	/* RX REQUEST */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
-	assert(l2_send_called);
-	l2_send_called =3D false;
+	srv_transport =3D _dhcp_server_get_transport(server);
 =

-	/* RX ACK */
-	cli_transport1->rx_cb(server_packet, server_packet_len, client1);
+	client1 =3D client_init(addr1);
 =

-	assert(event_handler_called);
+	client_connect(client1, server);
 =

 	cli_lease =3D l_dhcp_client_get_lease(client1);
 	assert(cli_lease);
@@ -909,26 +922,9 @@ static void test_complete_run(const void *data)
 	assert(!strcmp(dns_list[1], "192.168.1.254"));
 	l_strv_free(dns_list);
 =

-	/* Second client connect */
-	assert(l_dhcp_client_start(client2));
+	client2 =3D client_init(addr2);
 =

-	/* RX DISCOVER */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
-	assert(l2_send_called);
-	l2_send_called =3D false;
-
-	/* RX OFFER */
-	cli_transport2->rx_cb(server_packet, server_packet_len, client2);
-
-	/* RX REQUEST */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
-	assert(l2_send_called);
-	l2_send_called =3D false;
-
-	/* RX ACK */
-	cli_transport2->rx_cb(server_packet, server_packet_len, client2);
-
-	assert(event_handler_called);
+	client_connect(client2, server);
 =

 	cli_lease =3D l_dhcp_client_get_lease(client2);
 	assert(cli_lease);
-- =

2.26.2

--===============5013616868488024235==--

