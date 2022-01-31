Content-Type: multipart/mixed; boundary="===============4994998342774315997=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2] dhcp: handle multiple offers from the same server
Date: Mon, 31 Jan 2022 14:03:50 -0800
Message-ID: <20220131220350.3984579-1-prestwoj@gmail.com>

--===============4994998342774315997==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It was found that some DHCP servers send multiple offers on occation. Wheth=
er
this is a bug or not its been seen in products and ELL should handle this
gracefully.

The issue comes down to these DHCP servers expecting a request associated w=
ith
the last offer they send. The existing behavior in ELL is to ignore all off=
ers
after the initial, and continue resending requests for the original offer. =
When
this happens the DHCP server never responds with an ACK.

The spec briefly outlines multiple DHCP offers but in the context of multip=
le
DHCP servers rather than multiple offers from the same DHCP server. In any
case its left up to the DHCP client to choose whatever offer it wants, so t=
his
is what ELL will do.

Now only the last offer will be used while in the REQUESTING state. If anot=
her
offer comes in before the ACK, that offer will be used and a new request wi=
ll
be sent out. Note this is only the case when the offers contain the same
server ID as the first offer sent (this eliminates the multi DHCP server ca=
se
and will maintain existing behavior, where the first offer is selected alwa=
ys).
---
 ell/dhcp.c | 62 ++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 49 insertions(+), 13 deletions(-)

v2:
 - Added a debug print in the multiple offer case

diff --git a/ell/dhcp.c b/ell/dhcp.c
index be03697..e2d18fc 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -757,6 +757,7 @@ static int dhcp_client_receive_offer(struct l_dhcp_clie=
nt *client,
 					size_t len)
 {
 	struct dhcp_message_iter iter;
+	struct l_dhcp_lease *lease;
 =

 	CLIENT_DEBUG("");
 =

@@ -766,15 +767,55 @@ static int dhcp_client_receive_offer(struct l_dhcp_cl=
ient *client,
 	if (!_dhcp_message_iter_init(&iter, offer, len))
 		return -EINVAL;
 =

-	client->lease =3D _dhcp_lease_parse_options(&iter);
-	if (!client->lease)
+	lease =3D _dhcp_lease_parse_options(&iter);
+	if (!lease)
 		return -ENOMSG;
 =

+	/*
+	 * Received another offer. In the case of multiple DHCP servers we want
+	 * to ignore it and continue using the first offer. If this is from the
+	 * same server its likely a buggy DHCP implementation and we should
+	 * use the last offer it sends.
+	 */
+	if (client->lease) {
+		if (client->lease->server_address !=3D lease->server_address) {
+			_dhcp_lease_free(lease);
+			return -ENOMSG;
+		}
+
+		CLIENT_DEBUG("Server sent another offer, using it instead");
+
+		_dhcp_lease_free(client->lease);
+	}
+
+	client->lease =3D lease;
+
 	client->lease->address =3D offer->yiaddr;
 =

 	return 0;
 }
 =

+static bool dhcp_client_handle_offer(struct l_dhcp_client *client,
+					const struct dhcp_message *message,
+					size_t len)
+{
+	if (dhcp_client_receive_offer(client, message, len) < 0)
+		return false;
+
+	CLIENT_ENTER_STATE(DHCP_STATE_REQUESTING);
+	client->attempt =3D 1;
+
+	if (dhcp_client_send_request(client) < 0) {
+		l_dhcp_client_stop(client);
+
+		return false;
+	}
+
+	l_timeout_modify_ms(client->timeout_resend, dhcp_fuzz_secs(4));
+
+	return true;
+}
+
 static void dhcp_client_rx_message(const void *data, size_t len, void *use=
rdata,
 					const uint8_t *saddr)
 {
@@ -832,21 +873,16 @@ static void dhcp_client_rx_message(const void *data, =
size_t len, void *userdata,
 		if (msg_type !=3D DHCP_MESSAGE_TYPE_OFFER)
 			return;
 =

-		if (dhcp_client_receive_offer(client, message, len) < 0)
+		if (!dhcp_client_handle_offer(client, message, len))
 			return;
 =

-		CLIENT_ENTER_STATE(DHCP_STATE_REQUESTING);
-		client->attempt =3D 1;
-
-		if (dhcp_client_send_request(client) < 0) {
-			l_dhcp_client_stop(client);
-
-			return;
-		}
-
-		l_timeout_modify_ms(client->timeout_resend, dhcp_fuzz_secs(4));
 		break;
 	case DHCP_STATE_REQUESTING:
+		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_OFFER) {
+			dhcp_client_handle_offer(client, message, len);
+			return;
+		}
+		/* Fall through */
 	case DHCP_STATE_RENEWING:
 	case DHCP_STATE_REBINDING:
 	receive_rapid_commit:
-- =

2.31.1

--===============4994998342774315997==--

