Content-Type: multipart/mixed; boundary="===============6671816275093176021=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 5/5] unit: add DHCP expiration reuse test
Date: Mon, 23 Nov 2020 12:49:06 -0800
Message-ID: <20201123204906.4101813-5-prestwoj@gmail.com>
In-Reply-To: <20201123204906.4101813-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6671816275093176021==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test that the DHCP server reuses expired IPs once the limit
is reached.
---
 unit/test-dhcp.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 1f4bd8b..ad06c14 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -962,6 +962,47 @@ static void test_complete_run(const void *data)
 	l_dhcp_server_destroy(server);
 }
 =

+static void test_expired_ip_reuse(const void *data)
+{
+	uint8_t addr[6] =3D {0x01, 0x02, 0x03, 0x04, 0x05, 0x00};
+	struct l_dhcp_server *server =3D server_init();
+	struct dhcp_transport *srv_transport =3D
+					_dhcp_server_get_transport(server);
+	struct l_dhcp_client *client_new;
+	const struct l_dhcp_lease *lease;
+	const char *cli_addr;
+	int i;
+
+	l_dhcp_server_set_ip_range(server, "192.168.1.2", "192.168.1.11");
+	_dhcp_server_set_max_expired_clients(server, 10);
+
+	/*
+	 * Connect and release 10 clients, this should max out the expired
+	 * queue (since we are setting it to 10) and force the first client that
+	 * expired to be removed allowing 192.168.1.2 to be reused for a new
+	 * client
+	 */
+	for (i =3D 0; i < 10; i++) {
+		struct l_dhcp_client *client;
+
+		addr[5] =3D i;
+		client =3D client_init(addr);
+		client_connect(client, server);
+
+		l_dhcp_client_stop(client);
+		srv_transport->rx_cb(client_packet, client_packet_len, server);
+	}
+
+	addr[5] =3D i + 1;
+	client_new =3D client_init(addr);
+	client_connect(client_new, server);
+
+	lease =3D l_dhcp_client_get_lease(client_new);
+	assert(lease);
+	cli_addr =3D l_dhcp_lease_get_address(lease);
+	assert(!strcmp(cli_addr, "192.168.1.2"));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -986,6 +1027,7 @@ int main(int argc, char *argv[])
 	l_test_add("discover", test_discover, NULL);
 =

 	l_test_add("complete run", test_complete_run, NULL);
+	l_test_add("expired IP reuse", test_expired_ip_reuse, NULL);
 =

 	return l_test_run();
 }
-- =

2.26.2

--===============6671816275093176021==--

