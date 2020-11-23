Content-Type: multipart/mixed; boundary="===============1324475586018569056=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 3/5] unit: add client expire checks to test-dhcp
Date: Mon, 23 Nov 2020 12:49:04 -0800
Message-ID: <20201123204906.4101813-3-prestwoj@gmail.com>
In-Reply-To: <20201123204906.4101813-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1324475586018569056==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Verifies the proper events fire when clients release their lease.
---
 unit/test-dhcp.c | 43 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 877d649..2f41609 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -764,6 +764,24 @@ static void do_debug(const char *str, void *user_data)
 	l_info("%s%s", prefix, str);
 }
 =

+static char *new_client;
+static char *expired_client;
+
+static void server_event(struct l_dhcp_server *server,
+					enum l_dhcp_server_event event,
+					void *user_data,
+					const struct l_dhcp_lease *lease)
+{
+	switch (event) {
+	case L_DHCP_SERVER_EVENT_NEW_LEASE:
+		new_client =3D l_dhcp_lease_get_address(lease);
+		break;
+	case L_DHCP_SERVER_EVENT_LEASE_EXPIRED:
+		expired_client =3D l_dhcp_lease_get_address(lease);
+		break;
+	}
+}
+
 static void test_complete_run(const void *data)
 {
 	static const uint8_t addr1[6] =3D { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
@@ -794,6 +812,8 @@ static void test_complete_run(const void *data)
 	assert(l_dhcp_server_set_netmask(server, "255.255.255.0"));
 	assert(l_dhcp_server_set_gateway(server, "192.168.1.1"));
 	assert(l_dhcp_server_set_dns(server, dns));
+	assert(l_dhcp_server_set_event_handler(server, server_event,
+						NULL, NULL));
 =

 	if (verbose)
 		l_dhcp_server_set_debug(server, do_debug, "[DHCP SERV] ", NULL);
@@ -865,6 +885,11 @@ static void test_complete_run(const void *data)
 	cli_addr =3D l_dhcp_lease_get_address(cli_lease);
 	assert(cli_addr);
 	assert(!strcmp(cli_addr, "192.168.1.2"));
+	assert(new_client);
+	assert(!strcmp(new_client, cli_addr));
+	l_free(new_client);
+	new_client =3D NULL;
+
 	srv_addr =3D l_dhcp_lease_get_server_id(cli_lease);
 	assert(!strcmp(srv_addr, "192.168.1.1"));
 	l_free(srv_addr);
@@ -910,14 +935,30 @@ static void test_complete_run(const void *data)
 	cli_addr =3D l_dhcp_lease_get_address(cli_lease);
 	assert(cli_addr);
 	assert(!strcmp(cli_addr, "192.168.1.3"));
+	assert(new_client);
+	assert(!strcmp(new_client, cli_addr));
+	l_free(new_client);
+	new_client =3D NULL;
 	srv_addr =3D l_dhcp_lease_get_server_id(cli_lease);
 	assert(!strcmp(srv_addr, "192.168.1.1"));
 	l_free(srv_addr);
 	l_free(cli_addr);
 =

-
 	l_dhcp_client_stop(client1);
+
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(expired_client);
+	assert(!strcmp(expired_client, "192.168.1.2"));
+	l_free(expired_client);
+	expired_client =3D NULL;
+
 	l_dhcp_client_stop(client2);
+	srv_transport->rx_cb(client_packet, client_packet_len, server);
+	assert(expired_client);
+	assert(!strcmp(expired_client, "192.168.1.3"));
+	l_free(expired_client);
+	expired_client =3D NULL;
+
 	l_dhcp_client_destroy(client1);
 	l_dhcp_client_destroy(client2);
 =

-- =

2.26.2

--===============1324475586018569056==--

