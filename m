Content-Type: multipart/mixed; boundary="===============4977802113780020835=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v4 10/11] unit: add complete client/server dhcp test
Date: Fri, 16 Oct 2020 13:23:54 -0700
Message-ID: <20201016202355.1248245-10-prestwoj@gmail.com>
In-Reply-To: <20201016202355.1248245-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4977802113780020835==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 161 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 161 insertions(+)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 955ed29..a481247 100644
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
@@ -736,6 +738,163 @@ static void test_discover(const void *data)
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
+static void server_event_handler(struct l_dhcp_server *server,
+					enum l_dhcp_server_event event,
+					void *userdata,
+					const struct l_dhcp_lease *lease)
+{
+	const uint8_t expected_mac[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
+	const uint8_t *mac;
+	char *ip;
+
+	switch (event) {
+	case L_DHCP_SERVER_EVENT_NEW_LEASE:
+		mac =3D l_dhcp_lease_get_mac(lease);
+		ip =3D l_dhcp_lease_get_address(lease);
+
+		assert(!memcmp(mac, expected_mac, sizeof(expected_mac)));
+		assert(!strcmp(ip, "192.168.1.2"));
+
+		l_free(ip);
+		break;
+	case L_DHCP_SERVER_EVENT_LEASE_EXPIRED:
+		break;
+	}
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
+	static const uint8_t addr[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
+	char *dns[] =3D { "192.168.1.1", "192.168.1.254", NULL };
+	struct l_dhcp_client *client;
+	struct l_dhcp_server *server;
+	struct dhcp_transport *cli_transport =3D l_new(struct dhcp_transport, 1);
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
+	assert(l_dhcp_server_set_event_handler(server, server_event_handler,
+						NULL, NULL));
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
+	client =3D l_dhcp_client_new(42);
+
+	assert(l_dhcp_client_set_address(client, ARPHRD_ETHER, addr, 6));
+	assert(l_dhcp_client_set_interface_name(client, "fake"));
+	assert(l_dhcp_client_set_hostname(client, "<hostname>"));
+	_dhcp_client_override_xid(client, 0x4d7c67c6);
+	assert(l_dhcp_client_set_event_handler(client,
+				event_handler_lease_obtained, NULL, NULL));
+
+	if (verbose)
+		l_dhcp_client_set_debug(client, do_debug, "[DHCP] ", NULL);
+
+	cli_transport->send =3D fake_transport_send;
+	cli_transport->l2_send =3D fake_transport_l2_send;
+	cli_transport->ifindex =3D 42;
+
+	assert(_dhcp_client_set_transport(client, cli_transport));
+
+	assert(l_dhcp_client_start(client));
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
+	cli_lease =3D l_dhcp_client_get_lease(client);
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
+	l_dhcp_client_stop(client);
+	l_dhcp_client_destroy(client);
+
+	l_dhcp_server_stop(server);
+	l_dhcp_server_destroy(server);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -759,5 +918,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("discover", test_discover, NULL);
 =

+	l_test_add("complete run", test_complete_run, NULL);
+
 	return l_test_run();
 }
-- =

2.26.2

--===============4977802113780020835==--

