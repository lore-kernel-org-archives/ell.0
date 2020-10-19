Content-Type: multipart/mixed; boundary="===============3849377487906260106=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v5 11/12] unit: add complete client/server dhcp test
Date: Mon, 19 Oct 2020 16:28:13 -0700
Message-ID: <20201019232814.1541221-11-prestwoj@gmail.com>
In-Reply-To: <20201019232814.1541221-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3849377487906260106==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 191 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 191 insertions(+)

v5:
 * Added second client in full test

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 955ed29..6b7c606 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -36,6 +36,8 @@
 static bool verbose =3D true;
 static uint8_t client_packet[1024];
 static size_t client_packet_len;
+static uint8_t server_packet[1024];
+static size_t server_packet_len;
 =

 static void test_request_option(const void *data)
 {
@@ -736,6 +738,193 @@ static void test_discover(const void *data)
 	l_dhcp_client_destroy(client);
 }
 =

+static bool l2_send_called =3D false;
+
+static int fake_transport_server_l2_send(struct dhcp_transport *s,
+					uint32_t source_ip,
+					uint16_t source_port,
+					uint32_t dest_ip,
+					uint16_t dest_port,
+					const uint8_t *dest_arp,
+					const void *data, size_t len)
+{
+	assert(len <=3D sizeof(server_packet));
+	memcpy(server_packet, data, len);
+	server_packet_len =3D len;
+
+	l2_send_called =3D true;
+
+	return 0;
+}
+
+static void do_debug(const char *str, void *user_data)
+{
+	const char *prefix =3D user_data;
+
+	l_info("%s%s", prefix, str);
+}
+
+static void test_complete_run(const void *data)
+{
+	static const uint8_t addr1[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
+	static const uint8_t addr2[6] =3D { 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c };
+
+	char *dns[] =3D { "192.168.1.1", "192.168.1.254", NULL };
+	struct l_dhcp_client *client1;
+	struct l_dhcp_client *client2;
+	struct l_dhcp_server *server;
+	struct dhcp_transport *cli_transport1 =3D l_new(struct dhcp_transport, 1);
+	struct dhcp_transport *cli_transport2 =3D l_new(struct dhcp_transport, 1);
+
+	struct dhcp_transport *srv_transport =3D l_new(struct dhcp_transport, 1);
+	const struct l_dhcp_lease *cli_lease;
+	/* client IP address */
+	char *cli_addr;
+	/* servers IP address */
+	char *srv_addr;
+	char *tmp_addr;
+	char **dns_list;
+
+	server =3D l_dhcp_server_new(41);
+
+	assert(l_dhcp_server_set_interface_name(server, "fake"));
+	assert(l_dhcp_server_set_ip_address(server, "192.168.1.1"));
+	assert(l_dhcp_server_set_ip_range(server, "192.168.1.2",
+						"192.168.1.100"));
+	assert(l_dhcp_server_set_netmask(server, "255.255.255.0"));
+	assert(l_dhcp_server_set_gateway(server, "192.168.1.1"));
+	assert(l_dhcp_server_set_dns(server, dns));
+
+	if (verbose)
+		l_dhcp_server_set_debug(server, do_debug, "[DHCP SERV] ", NULL);
+
+	srv_transport->ifindex =3D 41;
+	srv_transport->l2_send =3D fake_transport_server_l2_send;
+
+	assert(_dhcp_server_set_transport(server, srv_transport));
+
+	assert(l_dhcp_server_start(server));
+
+	client1 =3D l_dhcp_client_new(42);
+
+	assert(l_dhcp_client_set_address(client1, ARPHRD_ETHER, addr1, 6));
+	assert(l_dhcp_client_set_interface_name(client1, "fake"));
+	assert(l_dhcp_client_set_hostname(client1, "<hostname>"));
+	_dhcp_client_override_xid(client1, 0x4d7c67c6);
+	assert(l_dhcp_client_set_event_handler(client1,
+				event_handler_lease_obtained, NULL, NULL));
+
+	if (verbose)
+		l_dhcp_client_set_debug(client1, do_debug, "[DHCP1] ", NULL);
+
+	cli_transport1->send =3D fake_transport_send;
+	cli_transport1->l2_send =3D fake_transport_l2_send;
+	cli_transport1->ifindex =3D 42;
+
+	assert(_dhcp_client_set_transport(client1, cli_transport1));
+
+	assert(l_dhcp_client_start(client1));
+
+	client2 =3D l_dhcp_client_new(43);
+	assert(l_dhcp_client_set_address(client2, ARPHRD_ETHER, addr2, 6));
+	assert(l_dhcp_client_set_interface_name(client2, "fake"));
+	assert(l_dhcp_client_set_hostname(client2, "<hostname>"));
+	_dhcp_client_override_xid(client2, 0x5d7c67c6);
+	assert(l_dhcp_client_set_event_handler(client2,
+				event_handler_lease_obtained, NULL, NULL));
+
+	if (verbose)
+		l_dhcp_client_set_debug(client2, do_debug, "[DHCP2] ", NULL);
+
+	cli_transport2->send =3D fake_transport_send;
+	cli_transport2->l2_send =3D fake_transport_l2_send;
+	cli_transport2->ifindex =3D 42;
+
+	assert(_dhcp_client_set_transport(client2, cli_transport2));
+
+	/* RX DISCOVER */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX OFFER */
+	cli_transport1->rx_cb(server_packet, server_packet_len, client1);
+
+	/* RX REQUEST */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX ACK */
+	cli_transport1->rx_cb(server_packet, server_packet_len, client1);
+
+	assert(event_handler_called);
+
+	cli_lease =3D l_dhcp_client_get_lease(client1);
+	assert(cli_lease);
+	cli_addr =3D l_dhcp_lease_get_address(cli_lease);
+	assert(cli_addr);
+	assert(!strcmp(cli_addr, "192.168.1.2"));
+	srv_addr =3D l_dhcp_lease_get_server_id(cli_lease);
+	assert(!strcmp(srv_addr, "192.168.1.1"));
+	l_free(srv_addr);
+	l_free(cli_addr);
+
+	tmp_addr =3D l_dhcp_lease_get_gateway(cli_lease);
+	assert(!strcmp(tmp_addr, "192.168.1.1"));
+	l_free(tmp_addr);
+
+	tmp_addr =3D l_dhcp_lease_get_netmask(cli_lease);
+	assert(!strcmp(tmp_addr, "255.255.255.0"));
+	l_free(tmp_addr);
+
+	dns_list =3D l_dhcp_lease_get_dns(cli_lease);
+	assert(dns_list && dns_list[0] && dns_list[1]);
+	assert(!strcmp(dns_list[0], "192.168.1.1"));
+	assert(!strcmp(dns_list[1], "192.168.1.254"));
+	l_strv_free(dns_list);
+
+	/* Second client connect */
+	assert(l_dhcp_client_start(client2));
+
+	/* RX DISCOVER */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX OFFER */
+	cli_transport2->rx_cb(server_packet, server_packet_len, client2);
+
+	/* RX REQUEST */
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(l2_send_called);
+	l2_send_called =3D false;
+
+	/* RX ACK */
+	cli_transport2->rx_cb(server_packet, server_packet_len, client2);
+
+	assert(event_handler_called);
+
+	cli_lease =3D l_dhcp_client_get_lease(client2);
+	assert(cli_lease);
+	cli_addr =3D l_dhcp_lease_get_address(cli_lease);
+	assert(cli_addr);
+	assert(!strcmp(cli_addr, "192.168.1.3"));
+	srv_addr =3D l_dhcp_lease_get_server_id(cli_lease);
+	assert(!strcmp(srv_addr, "192.168.1.1"));
+	l_free(srv_addr);
+	l_free(cli_addr);
+
+
+	l_dhcp_client_stop(client1);
+	l_dhcp_client_stop(client2);
+	l_dhcp_client_destroy(client1);
+	l_dhcp_client_destroy(client2);
+
+	l_dhcp_server_stop(server);
+	l_dhcp_server_destroy(server);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -759,5 +948,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("discover", test_discover, NULL);
 =

+	l_test_add("complete run", test_complete_run, NULL);
+
 	return l_test_run();
 }
-- =

2.26.2

--===============3849377487906260106==--

