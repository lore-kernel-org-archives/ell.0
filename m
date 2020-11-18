Content-Type: multipart/mixed; boundary="===============8160225534845669291=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/6] dhcp: release lease when client stops
Date: Wed, 18 Nov 2020 11:00:51 -0800
Message-ID: <20201118190056.3584080-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8160225534845669291==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

RFC 2131 does not explicitly require this but clients MAY
release their IP address when they are done using it, e.g.
when shutting down. This is also described as a "graceful shutdown"
so its probably best the DHCP client does this.
---
 ell/dhcp.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 57 insertions(+), 9 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index e6fbda7..5f4d99a 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -367,6 +367,19 @@ static int dhcp_client_send_discover(struct l_dhcp_cli=
ent *client)
 					discover, len);
 }
 =

+static int dhcp_client_send_unicast(struct l_dhcp_client *client,
+					struct dhcp_message *request,
+					unsigned int len)
+{
+	struct sockaddr_in si;
+
+	memset(&si, 0, sizeof(si));
+	si.sin_family =3D AF_INET;
+	si.sin_port =3D L_CPU_TO_BE16(DHCP_PORT_SERVER);
+	si.sin_addr.s_addr =3D client->lease->server_address;
+	return client->transport->send(client->transport, &si, request, len);
+}
+
 static int dhcp_client_send_request(struct l_dhcp_client *client)
 {
 	struct dhcp_message_builder builder;
@@ -450,15 +463,8 @@ static int dhcp_client_send_request(struct l_dhcp_clie=
nt *client)
 	 * 'server identifier' option for any unicast requests to the DHCP
 	 * server.
 	 */
-	if (client->state =3D=3D DHCP_STATE_RENEWING) {
-		struct sockaddr_in si;
-		memset(&si, 0, sizeof(si));
-		si.sin_family =3D AF_INET;
-		si.sin_port =3D L_CPU_TO_BE16(DHCP_PORT_SERVER);
-		si.sin_addr.s_addr =3D client->lease->server_address;
-		return client->transport->send(client->transport,
-							&si, request, len);
-	}
+	if (client->state =3D=3D DHCP_STATE_RENEWING)
+		return dhcp_client_send_unicast(client, request, len);
 =

 	return client->transport->l2_send(client->transport,
 					INADDR_ANY, DHCP_PORT_CLIENT,
@@ -466,6 +472,45 @@ static int dhcp_client_send_request(struct l_dhcp_clie=
nt *client)
 					NULL, request, len);
 }
 =

+static void dhcp_client_send_release(struct l_dhcp_client *client)
+{
+	struct dhcp_message_builder builder;
+	size_t optlen =3D DHCP_MIN_OPTIONS_SIZE;
+	size_t len =3D sizeof(struct dhcp_message) + optlen;
+	L_AUTO_FREE_VAR(struct dhcp_message *, request);
+	int err;
+	struct sockaddr_in si;
+
+	CLIENT_DEBUG("");
+
+	memset(&si, 0, sizeof(si));
+	si.sin_family =3D AF_INET;
+	si.sin_port =3D L_CPU_TO_BE16(DHCP_PORT_SERVER);
+	si.sin_addr.s_addr =3D client->lease->server_address;
+
+	request =3D (struct dhcp_message *) l_new(uint8_t, len);
+
+	_dhcp_message_builder_init(&builder, request, len,
+					DHCP_MESSAGE_TYPE_RELEASE);
+
+	err =3D client_message_init(client, request, &builder);
+	if (err < 0)
+		return;
+
+	request->ciaddr =3D client->lease->address;
+
+	if (!_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_SERVER_IDENTIFIER,
+					4, &client->lease->server_address)) {
+		CLIENT_DEBUG("Failed to append server ID");
+		return;
+	}
+
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	dhcp_client_send_unicast(client, request, len);
+}
+
 static void dhcp_client_timeout_resend(struct l_timeout *timeout,
 								void *user_data)
 {
@@ -1063,6 +1108,9 @@ LIB_EXPORT bool l_dhcp_client_stop(struct l_dhcp_clie=
nt *client)
 	if (unlikely(!client))
 		return false;
 =

+	if (client->state =3D=3D DHCP_STATE_BOUND)
+		dhcp_client_send_release(client);
+
 	if (client->rtnl_add_cmdid) {
 		l_netlink_cancel(client->rtnl, client->rtnl_add_cmdid);
 		client->rtnl_add_cmdid =3D 0;
-- =

2.26.2

--===============8160225534845669291==--

