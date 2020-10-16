Content-Type: multipart/mixed; boundary="===============7688762280144453247=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 03/20] dhcp: update client code to use builder APIs
Date: Fri, 16 Oct 2020 08:36:18 -0700
Message-ID: <20201016153635.660391-3-prestwoj@gmail.com>
In-Reply-To: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7688762280144453247==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp.c | 148 ++++++++++++++++-------------------------------------
 1 file changed, 43 insertions(+), 105 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 097bf3d..2541637 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -301,61 +301,6 @@ int _dhcp_option_append(uint8_t **buf, size_t *buflen,=
 uint8_t code,
 	return 0;
 }
 =

-static int dhcp_append_prl(const unsigned long *reqopts,
-					uint8_t **buf, size_t *buflen)
-{
-	uint8_t optlen =3D 0;
-	unsigned int i;
-	unsigned int j;
-
-	if (!buf || !buflen)
-		return -EINVAL;
-
-	for (i =3D 0; i < 256 / BITS_PER_LONG; i++)
-		optlen +=3D __builtin_popcountl(reqopts[i]);
-
-	/*
-	 * This function assumes that there's enough space to put the PRL
-	 * into the buffer without resorting to file or sname overloading
-	 */
-	if (*buflen < optlen + 2U)
-		return -ENOBUFS;
-
-	i =3D 0;
-	(*buf)[i++] =3D DHCP_OPTION_PARAMETER_REQUEST_LIST;
-	(*buf)[i++] =3D optlen;
-
-	for (j =3D 0; j < 256; j++) {
-		if (reqopts[j / BITS_PER_LONG] & 1UL << (j % BITS_PER_LONG))
-			(*buf)[i++] =3D j;
-	}
-
-	*buf +=3D optlen + 2;
-	*buflen -=3D (optlen + 2);
-
-	return 0;
-}
-
-static int dhcp_message_init(struct dhcp_message *message,
-				enum dhcp_op_code op,
-				uint8_t type, uint32_t xid,
-				uint8_t **opt, size_t *optlen)
-{
-	int err;
-
-	message->op =3D op;
-	message->xid =3D L_CPU_TO_BE32(xid);
-	message->magic =3D L_CPU_TO_BE32(DHCP_MAGIC);
-	*opt =3D (uint8_t *)(message + 1);
-
-	err =3D _dhcp_option_append(opt, optlen,
-					DHCP_OPTION_MESSAGE_TYPE, 1, &type);
-	if (err < 0)
-		return err;
-
-	return 0;
-}
-
 static void dhcp_message_set_address_type(struct dhcp_message *message,
 						uint8_t addr_type,
 						uint8_t addr_len)
@@ -504,16 +449,13 @@ static uint32_t dhcp_rebind_renew_retry_time(uint64_t=
 start_t, uint32_t expiry)
 =

 static int client_message_init(struct l_dhcp_client *client,
 					struct dhcp_message *message,
-					uint8_t type,
-					uint8_t **opt, size_t *optlen)
+					struct dhcp_message_builder *builder)
 {
-	int err;
 	uint16_t max_size;
 =

-	err =3D dhcp_message_init(message, DHCP_OP_CODE_BOOTREQUEST,
-				type, client->xid, opt, optlen);
-	if (err < 0)
-		return err;
+	message->op =3D DHCP_OP_CODE_BOOTREQUEST;
+	message->xid =3D L_CPU_TO_BE32(client->xid);
+	message->magic =3D L_CPU_TO_BE32(DHCP_MAGIC);
 =

 	dhcp_message_set_address_type(message, client->addr_type,
 							client->addr_len);
@@ -534,20 +476,19 @@ static int client_message_init(struct l_dhcp_client *=
client,
 	 */
 	message->secs =3D L_CPU_TO_BE16(dhcp_attempt_secs(client->start_t));
 =

-	err =3D dhcp_append_prl(client->request_options, opt, optlen);
-	if (err < 0)
-		return err;
+	if (!_dhcp_message_builder_append_prl(builder,
+						client->request_options))
+		return -EINVAL;
 =

 	/*
 	 * Set the maximum DHCP message size to the minimum legal value.  This
 	 * helps some buggy DHCP servers to not send bigger packets
 	 */
 	max_size =3D L_CPU_TO_BE16(576);
-	err =3D _dhcp_option_append(opt, optlen,
+	if (!_dhcp_message_builder_append(builder,
 					DHCP_OPTION_MAXIMUM_MESSAGE_SIZE,
-					2, &max_size);
-	if (err < 0)
-		return err;
+					2, &max_size))
+		return -EINVAL;
 =

 	return 0;
 }
@@ -561,7 +502,7 @@ static void dhcp_client_event_notify(struct l_dhcp_clie=
nt *client,
 =

 static int dhcp_client_send_discover(struct l_dhcp_client *client)
 {
-	uint8_t *opt;
+	struct dhcp_message_builder builder;
 	size_t optlen =3D DHCP_MIN_OPTIONS_SIZE;
 	size_t len =3D sizeof(struct dhcp_message) + optlen;
 	L_AUTO_FREE_VAR(struct dhcp_message *, discover);
@@ -571,26 +512,21 @@ static int dhcp_client_send_discover(struct l_dhcp_cl=
ient *client)
 =

 	discover =3D (struct dhcp_message *) l_new(uint8_t, len);
 =

-	err =3D client_message_init(client, discover,
-					DHCP_MESSAGE_TYPE_DISCOVER,
-					&opt, &optlen);
+	_dhcp_message_builder_init(&builder, discover, len,
+					DHCP_MESSAGE_TYPE_DISCOVER);
+
+	err =3D client_message_init(client, discover, &builder);
 	if (err < 0)
 		return err;
 =

-	if (client->hostname) {
-		err =3D _dhcp_option_append(&opt, &optlen,
+	if (client->hostname)
+		if (!_dhcp_message_builder_append(&builder,
 						L_DHCP_OPTION_HOST_NAME,
 						strlen(client->hostname),
-						client->hostname);
-		if (err < 0)
-			return err;
-	}
-
-	err =3D _dhcp_option_append(&opt, &optlen, DHCP_OPTION_END, 0, NULL);
-	if (err < 0)
-		return err;
+						client->hostname))
+			return -EINVAL;
 =

-	len =3D dhcp_message_optimize(discover, opt);
+	_dhcp_message_builder_finalize(&builder, &len);
 =

 	return client->transport->broadcast(client->transport,
 					INADDR_ANY, DHCP_PORT_CLIENT,
@@ -600,7 +536,7 @@ static int dhcp_client_send_discover(struct l_dhcp_clie=
nt *client)
 =

 static int dhcp_client_send_request(struct l_dhcp_client *client)
 {
-	uint8_t *opt;
+	struct dhcp_message_builder builder;
 	size_t optlen =3D DHCP_MIN_OPTIONS_SIZE;
 	size_t len =3D sizeof(struct dhcp_message) + optlen;
 	L_AUTO_FREE_VAR(struct dhcp_message *, request);
@@ -610,9 +546,11 @@ static int dhcp_client_send_request(struct l_dhcp_clie=
nt *client)
 =

 	request =3D (struct dhcp_message *) l_new(uint8_t, len);
 =

-	err =3D client_message_init(client, request,
-					DHCP_MESSAGE_TYPE_REQUEST,
-					&opt, &optlen);
+	_dhcp_message_builder_init(&builder, request, len,
+					DHCP_MESSAGE_TYPE_REQUEST);
+
+
+	err =3D client_message_init(client, request, &builder);
 	if (err < 0)
 		return err;
 =

@@ -633,17 +571,20 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
 		 *
 		 * NOTE: 'SELECTING' is meant to be 'REQUESTING' in the RFC
 		 */
-		err =3D _dhcp_option_append(&opt, &optlen,
+		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
-					4, &client->lease->server_address);
-		if (err < 0)
-			return err;
+					4, &client->lease->server_address)) {
+			CLIENT_DEBUG("Failed to append server ID");
+			return -EINVAL;
+		}
 =

-		err =3D _dhcp_option_append(&opt, &optlen,
+		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_REQUESTED_IP_ADDRESS,
-					4, &client->lease->address);
-		if (err < 0)
-			return err;
+					4, &client->lease->address)) {
+			CLIENT_DEBUG("Failed to append requested IP");
+			return -EINVAL;
+		}
+
 		break;
 	case DHCP_STATE_RENEWING:
 	case DHCP_STATE_REBINDING:
@@ -659,19 +600,16 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
 	}
 =

 	if (client->hostname) {
-		err =3D _dhcp_option_append(&opt, &optlen,
+		if (!_dhcp_message_builder_append(&builder,
 						L_DHCP_OPTION_HOST_NAME,
 						strlen(client->hostname),
-						client->hostname);
-		if (err < 0)
-			return err;
+						client->hostname)) {
+			CLIENT_DEBUG("Failed to append host name");
+			return -EINVAL;
+		}
 	}
 =

-	err =3D _dhcp_option_append(&opt, &optlen, DHCP_OPTION_END, 0, NULL);
-	if (err < 0)
-		return err;
-
-	len =3D dhcp_message_optimize(request, opt);
+	_dhcp_message_builder_finalize(&builder, &len);
 =

 	/*
 	 * RFC2131, Section 4.1:
-- =

2.26.2

--===============7688762280144453247==--

