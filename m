Content-Type: multipart/mixed; boundary="===============2034489619966693551=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 15/15] unit: Test DHCP rapid commit
Date: Mon, 02 Aug 2021 16:04:24 +0200
Message-ID: <20210802140424.170150-15-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2034489619966693551==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 079f037..11ee10e 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -823,7 +823,7 @@ static struct l_dhcp_client *client_init(const uint8_t =
*mac)
 }
 =

 static void client_connect(struct l_dhcp_client *client,
-				struct l_dhcp_server *server)
+				struct l_dhcp_server *server, bool rapid_commit)
 {
 	struct dhcp_transport *srv_transport =3D
 					_dhcp_server_get_transport(server);
@@ -839,15 +839,17 @@ static void client_connect(struct l_dhcp_client *clie=
nt,
 	assert(l2_send_called);
 	l2_send_called =3D false;
 =

-	/* RX OFFER */
-	cli_transport->rx_cb(server_packet, server_packet_len, client);
-	assert(client_send_called);
-	client_send_called =3D false;
+	if (!rapid_commit) {
+		/* RX OFFER */
+		cli_transport->rx_cb(server_packet, server_packet_len, client);
+		assert(client_send_called);
+		client_send_called =3D false;
 =

-	/* RX REQUEST */
-	srv_transport->rx_cb(client_packet, client_packet_len, server);
-	assert(l2_send_called);
-	l2_send_called =3D false;
+		/* RX REQUEST */
+		srv_transport->rx_cb(client_packet, client_packet_len, server);
+		assert(l2_send_called);
+		l2_send_called =3D false;
+	}
 =

 	/* RX ACK */
 	cli_transport->rx_cb(server_packet, server_packet_len, client);
@@ -885,6 +887,7 @@ static struct l_dhcp_server *server_init()
 =

 static void test_complete_run(const void *data)
 {
+	bool rapid_commit =3D L_PTR_TO_UINT(data);
 	static const uint8_t addr1[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
 	static const uint8_t addr2[6] =3D { 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c };
 	struct dhcp_transport *srv_transport;
@@ -902,6 +905,7 @@ static void test_complete_run(const void *data)
 	char **dns_list;
 =

 	server =3D server_init();
+	l_dhcp_server_set_enable_rapid_commit(server, rapid_commit);
 =

 	assert(l_dhcp_server_set_ip_range(server, "192.168.1.2",
 						"192.168.1.100"));
@@ -910,7 +914,7 @@ static void test_complete_run(const void *data)
 =

 	client1 =3D client_init(addr1);
 =

-	client_connect(client1, server);
+	client_connect(client1, server, rapid_commit);
 =

 	cli_lease =3D l_dhcp_client_get_lease(client1);
 	assert(cli_lease);
@@ -943,7 +947,7 @@ static void test_complete_run(const void *data)
 =

 	client2 =3D client_init(addr2);
 =

-	client_connect(client2, server);
+	client_connect(client2, server, rapid_commit);
 =

 	cli_lease =3D l_dhcp_client_get_lease(client2);
 	assert(cli_lease);
@@ -999,6 +1003,7 @@ static void test_expired_ip_reuse(const void *data)
 =

 	l_dhcp_server_set_ip_range(server, "192.168.1.2", "192.168.1.11");
 	_dhcp_server_set_max_expired_clients(server, 10);
+	l_dhcp_server_set_enable_rapid_commit(server, false);
 =

 	/*
 	 * Connect and release 10 clients, this should max out the expired
@@ -1011,7 +1016,7 @@ static void test_expired_ip_reuse(const void *data)
 =

 		addr[5] =3D i;
 		client =3D client_init(addr);
-		client_connect(client, server);
+		client_connect(client, server, false);
 		l_free(new_client);
 		new_client =3D NULL;
 =

@@ -1025,7 +1030,7 @@ static void test_expired_ip_reuse(const void *data)
 =

 	addr[5] =3D i + 1;
 	client_new =3D client_init(addr);
-	client_connect(client_new, server);
+	client_connect(client_new, server, false);
 	l_free(new_client);
 	new_client =3D NULL;
 =

@@ -1064,7 +1069,8 @@ int main(int argc, char *argv[])
 =

 	l_test_add("discover", test_discover, NULL);
 =

-	l_test_add("complete run", test_complete_run, NULL);
+	l_test_add("complete run", test_complete_run, L_UINT_TO_PTR(false));
+	l_test_add("rapid commit", test_complete_run, L_UINT_TO_PTR(true));
 	l_test_add("expired IP reuse", test_expired_ip_reuse, NULL);
 =

 	return l_test_run();
-- =

2.30.2

--===============2034489619966693551==--

