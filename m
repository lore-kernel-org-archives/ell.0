Content-Type: multipart/mixed; boundary="===============6540969981794705865=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 1/3] dhcp: Add priority to logging
Date: Tue, 17 May 2022 17:18:29 +0100
Message-ID: <20220517161831.126597-1-mjohnson459@gmail.com>

--===============6540969981794705865==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Most dhcp clients have some logging to show what state the lease is in
so this just makes iwd more in line with them. The logging won't be
enabled by default but requires a max logging level to be passed in when
logging is set up.
---
 ell/dhcp.c | 64 +++++++++++++++++++++++++++++-------------------------
 ell/dhcp.h |  2 +-
 2 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 2d04900..13e96cb 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -43,10 +43,12 @@
 #include "netlink.h"
 #include "rtnl.h"
 #include "acd.h"
+#include "log.h"
 =

-#define CLIENT_DEBUG(fmt, args...)					\
-	l_util_debug(client->debug_handler, client->debug_data,		\
-			"%s:%i " fmt, __func__, __LINE__, ## args)
+#define CLIENT_DEBUG(priority, fmt, args...)					\
+	if (priority <=3D client->debug_level)		\
+		l_util_debug(client->debug_handler, client->debug_data,		\
+				"%s:%i " fmt, __func__, __LINE__, ## args)
 #define CLIENT_ENTER_STATE(s)						\
 	l_util_debug(client->debug_handler, client->debug_data,		\
 			"%s:%i Entering state: " #s,			\
@@ -192,6 +194,7 @@ struct l_dhcp_client {
 	l_dhcp_destroy_cb_t event_destroy;
 	l_dhcp_debug_cb_t debug_handler;
 	l_dhcp_destroy_cb_t debug_destroy;
+	int debug_level;
 	struct l_acd *acd;
 	void *debug_data;
 	bool have_addr : 1;
@@ -343,7 +346,7 @@ static int dhcp_client_send_discover(struct l_dhcp_clie=
nt *client)
 	L_AUTO_FREE_VAR(struct dhcp_message *, discover);
 	int err;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	discover =3D (struct dhcp_message *) l_new(uint8_t, len);
 =

@@ -393,7 +396,7 @@ static int dhcp_client_send_request(struct l_dhcp_clien=
t *client)
 	L_AUTO_FREE_VAR(struct dhcp_message *, request);
 	int err;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	request =3D (struct dhcp_message *) l_new(uint8_t, len);
 =

@@ -425,14 +428,14 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
 		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
-			CLIENT_DEBUG("Failed to append server ID");
+			CLIENT_DEBUG(L_LOG_WARNING, "Failed to append server ID");
 			return -EINVAL;
 		}
 =

 		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_REQUESTED_IP_ADDRESS,
 					4, &client->lease->address)) {
-			CLIENT_DEBUG("Failed to append requested IP");
+			CLIENT_DEBUG(L_LOG_WARNING, "Failed to append requested IP");
 			return -EINVAL;
 		}
 =

@@ -455,7 +458,7 @@ static int dhcp_client_send_request(struct l_dhcp_clien=
t *client)
 						L_DHCP_OPTION_HOST_NAME,
 						strlen(client->hostname),
 						client->hostname)) {
-			CLIENT_DEBUG("Failed to append host name");
+			CLIENT_DEBUG(L_LOG_WARNING, "Failed to append host name");
 			return -EINVAL;
 		}
 	}
@@ -486,7 +489,7 @@ static void dhcp_client_send_release(struct l_dhcp_clie=
nt *client)
 	int err;
 	struct sockaddr_in si;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	memset(&si, 0, sizeof(si));
 	si.sin_family =3D AF_INET;
@@ -507,7 +510,7 @@ static void dhcp_client_send_release(struct l_dhcp_clie=
nt *client)
 	if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
-		CLIENT_DEBUG("Failed to append server ID");
+		CLIENT_DEBUG(L_LOG_WARNING, "Failed to append server ID");
 		return;
 	}
 =

@@ -523,13 +526,13 @@ static void dhcp_client_timeout_resend(struct l_timeo=
ut *timeout,
 	unsigned int next_timeout =3D 0;
 	int r;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	switch (client->state) {
 	case DHCP_STATE_SELECTING:
 		r =3D dhcp_client_send_discover(client);
 		if (r < 0) {
-			CLIENT_DEBUG("Sending discover failed: %s",
+			CLIENT_DEBUG(L_LOG_WARNING, "Sending discover failed: %s",
 								strerror(-r));
 			goto error;
 		}
@@ -540,7 +543,7 @@ static void dhcp_client_timeout_resend(struct l_timeout=
 *timeout,
 	case DHCP_STATE_REBINDING:
 		r =3D dhcp_client_send_request(client);
 		if (r < 0) {
-			CLIENT_DEBUG("Sending Request failed: %s",
+			CLIENT_DEBUG(L_LOG_WARNING, "Sending Request failed: %s",
 								strerror(-r));
 			goto error;
 		}
@@ -593,7 +596,7 @@ static void dhcp_client_lease_expired(struct l_timeout =
*timeout,
 {
 	struct l_dhcp_client *client =3D user_data;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	l_dhcp_client_stop(client);
 	dhcp_client_event_notify(client, L_DHCP_CLIENT_EVENT_LEASE_EXPIRED);
@@ -604,7 +607,7 @@ static void dhcp_client_t2_expired(struct l_timeout *ti=
meout, void *user_data)
 	struct l_dhcp_client *client =3D user_data;
 	uint32_t next_timeout =3D client->lease->lifetime - client->lease->t2;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	/*
 	 * If we got here, then resend_timeout is active, with a timeout
@@ -625,14 +628,14 @@ static void dhcp_client_t1_expired(struct l_timeout *=
timeout, void *user_data)
 	uint32_t next_timeout;
 	int r;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	CLIENT_ENTER_STATE(DHCP_STATE_RENEWING);
 	client->attempt =3D 1;
 =

 	r =3D dhcp_client_send_request(client);
 	if  (r < 0) {
-		CLIENT_DEBUG("Sending request failed: %s", strerror(-r));
+		CLIENT_DEBUG(L_LOG_WARNING, "Sending request failed: %s", strerror(-r));
 		goto error;
 	}
 =

@@ -665,7 +668,7 @@ static void dhcp_client_address_add_cb(int error, uint1=
6_t type,
 	if (error < 0 && error !=3D -EEXIST) {
 		l_rtnl_address_free(client->rtnl_configured_address);
 		client->rtnl_configured_address =3D NULL;
-		CLIENT_DEBUG("Unable to set address on ifindex: %u: %d(%s)",
+		CLIENT_DEBUG(L_LOG_WARNING, "Unable to set address on ifindex: %u: %d(%s=
)",
 				client->ifindex, error,
 				strerror(-error));
 		return;
@@ -681,7 +684,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 	struct l_dhcp_lease *lease;
 	int r;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	if (ack->yiaddr =3D=3D 0)
 		return -ENOMSG;
@@ -691,7 +694,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 =

 	lease =3D _dhcp_lease_parse_options(&iter);
 	if (!lease) {
-		CLIENT_DEBUG("Failed to parse DHCP options.");
+		CLIENT_DEBUG(L_LOG_WARNING, "Failed to parse DHCP options.");
 =

 		return -ENOMSG;
 	}
@@ -746,7 +749,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 		if (client->rtnl_add_cmdid)
 			client->rtnl_configured_address =3D a;
 		else {
-			CLIENT_DEBUG("Configuring address via RTNL failed");
+			CLIENT_DEBUG(L_LOG_WARNING, "Configuring address via RTNL failed");
 			l_rtnl_address_free(a);
 		}
 	}
@@ -761,7 +764,7 @@ static int dhcp_client_receive_offer(struct l_dhcp_clie=
nt *client,
 	struct dhcp_message_iter iter;
 	struct l_dhcp_lease *lease;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	if (offer->yiaddr =3D=3D 0)
 		return -ENOMSG;
@@ -785,7 +788,7 @@ static int dhcp_client_receive_offer(struct l_dhcp_clie=
nt *client,
 			return -ENOMSG;
 		}
 =

-		CLIENT_DEBUG("Server sent another offer, using it instead");
+		CLIENT_DEBUG(L_LOG_INFO, "Server sent another offer, using it instead");
 =

 		_dhcp_lease_free(client->lease);
 	}
@@ -832,7 +835,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 	int r, e;
 	struct in_addr ia;
 =

-	CLIENT_DEBUG("");
+	CLIENT_DEBUG(L_LOG_DEBUG, "");
 =

 	if (len < sizeof(struct dhcp_message))
 		return;
@@ -890,7 +893,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 	case DHCP_STATE_REBINDING:
 	receive_rapid_commit:
 		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_NAK) {
-			CLIENT_DEBUG("Received NAK, Stopping...");
+			CLIENT_DEBUG(L_LOG_INFO, "Received NAK, Stopping...");
 			l_dhcp_client_stop(client);
 =

 			dhcp_client_event_notify(client,
@@ -914,7 +917,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 			e =3D client->transport->bind(client->transport,
 						client->lease->address);
 			if (e < 0) {
-				CLIENT_DEBUG("Failed to bind dhcp socket. "
+				CLIENT_DEBUG(L_LOG_WARNING, "Failed to bind dhcp socket. "
 					"Error %d: %s", e, strerror(-e));
 			}
 		}
@@ -940,7 +943,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 			uint32_t next_timeout =3D
 					dhcp_fuzz_secs(client->lease->t1);
 =

-			CLIENT_DEBUG("T1 expiring in %u ms", next_timeout);
+			CLIENT_DEBUG(L_LOG_INFO, "T1 expiring in %u ms", next_timeout);
 			client->timeout_lease =3D
 				l_timeout_create_ms(next_timeout,
 							dhcp_client_t1_expired,
@@ -953,7 +956,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		client->acd =3D l_acd_new(client->ifindex);
 =

-		if (client->debug_handler)
+		if (client->debug_handler && client->debug_level =3D=3D L_LOG_DEBUG)
 			l_acd_set_debug(client->acd, client->debug_handler,
 					client->debug_data,
 					client->debug_destroy);
@@ -976,7 +979,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		/* For unit testing we don't want this to be a fatal error */
 		if (!l_acd_start(client->acd, buf)) {
-			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
+			CLIENT_DEBUG(L_LOG_WARNING, "Failed to start ACD on %s, continuing",
 						buf);
 			l_acd_destroy(client->acd);
 			client->acd =3D NULL;
@@ -1290,7 +1293,7 @@ LIB_EXPORT bool l_dhcp_client_set_event_handler(struc=
t l_dhcp_client *client,
 LIB_EXPORT bool l_dhcp_client_set_debug(struct l_dhcp_client *client,
 						l_dhcp_debug_cb_t function,
 						void *user_data,
-						l_dhcp_destroy_cb_t destroy)
+						l_dhcp_destroy_cb_t destroy, int priority)
 {
 	if (unlikely(!client))
 		return false;
@@ -1301,6 +1304,7 @@ LIB_EXPORT bool l_dhcp_client_set_debug(struct l_dhcp=
_client *client,
 	client->debug_handler =3D function;
 	client->debug_destroy =3D destroy;
 	client->debug_data =3D user_data;
+	client->debug_level =3D priority;
 =

 	return true;
 }
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 946bf63..b9c3480 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -102,7 +102,7 @@ bool l_dhcp_client_set_event_handler(struct l_dhcp_clie=
nt *client,
 =

 bool l_dhcp_client_set_debug(struct l_dhcp_client *client,
 				l_dhcp_debug_cb_t function,
-				void *user_data, l_dhcp_destroy_cb_t destroy);
+				void *user_data, l_dhcp_destroy_cb_t destroy, int priority);
 =

 =

 char *l_dhcp_lease_get_address(const struct l_dhcp_lease *lease);
-- =

2.25.1

--===============6540969981794705865==--

