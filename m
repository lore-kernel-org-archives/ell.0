Content-Type: multipart/mixed; boundary="===============5841757857194423686=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 1/3] dhcp: Add priority to logging
Date: Tue, 17 May 2022 17:56:36 +0100
Message-ID: <20220517165638.139029-1-mjohnson459@gmail.com>

--===============5841757857194423686==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Most dhcp clients have some logging to show what state the lease is in
so this just makes iwd more in line with them. The logging won't be
enabled by default but requires a max logging level to be passed in when
logging is set up.
---
 ell/dhcp.c | 48 +++++++++++++++++++++++++++++-------------------
 ell/dhcp.h |  2 +-
 2 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 2d04900..f8e6fb0 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -43,10 +43,18 @@
 #include "netlink.h"
 #include "rtnl.h"
 #include "acd.h"
+#include "log.h"
 =

+#define CLIENT_LOG(priority, fmt, args...)				\
+	if (priority <=3D client->debug_level)				\
+		l_util_debug(client->debug_handler, client->debug_data,	\
+				"%s:%i " fmt, __func__, __LINE__, ## args)
 #define CLIENT_DEBUG(fmt, args...)					\
-	l_util_debug(client->debug_handler, client->debug_data,		\
-			"%s:%i " fmt, __func__, __LINE__, ## args)
+	CLIENT_LOG(L_LOG_DEBUG, fmt, ## args)
+#define CLIENT_INFO(fmt, args...)					\
+	CLIENT_LOG(L_LOG_INFO, fmt, ## args)
+#define CLIENT_WARN(fmt, args...)					\
+	CLIENT_LOG(L_LOG_WARNING, fmt, ## args)
 #define CLIENT_ENTER_STATE(s)						\
 	l_util_debug(client->debug_handler, client->debug_data,		\
 			"%s:%i Entering state: " #s,			\
@@ -192,6 +200,7 @@ struct l_dhcp_client {
 	l_dhcp_destroy_cb_t event_destroy;
 	l_dhcp_debug_cb_t debug_handler;
 	l_dhcp_destroy_cb_t debug_destroy;
+	int debug_level;
 	struct l_acd *acd;
 	void *debug_data;
 	bool have_addr : 1;
@@ -425,14 +434,14 @@ static int dhcp_client_send_request(struct l_dhcp_cli=
ent *client)
 		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
-			CLIENT_DEBUG("Failed to append server ID");
+			CLIENT_WARN("Failed to append server ID");
 			return -EINVAL;
 		}
 =

 		if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_REQUESTED_IP_ADDRESS,
 					4, &client->lease->address)) {
-			CLIENT_DEBUG("Failed to append requested IP");
+			CLIENT_WARN("Failed to append requested IP");
 			return -EINVAL;
 		}
 =

@@ -455,7 +464,7 @@ static int dhcp_client_send_request(struct l_dhcp_clien=
t *client)
 						L_DHCP_OPTION_HOST_NAME,
 						strlen(client->hostname),
 						client->hostname)) {
-			CLIENT_DEBUG("Failed to append host name");
+			CLIENT_WARN("Failed to append host name");
 			return -EINVAL;
 		}
 	}
@@ -507,7 +516,7 @@ static void dhcp_client_send_release(struct l_dhcp_clie=
nt *client)
 	if (!_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_SERVER_IDENTIFIER,
 					4, &client->lease->server_address)) {
-		CLIENT_DEBUG("Failed to append server ID");
+		CLIENT_WARN("Failed to append server ID");
 		return;
 	}
 =

@@ -529,7 +538,7 @@ static void dhcp_client_timeout_resend(struct l_timeout=
 *timeout,
 	case DHCP_STATE_SELECTING:
 		r =3D dhcp_client_send_discover(client);
 		if (r < 0) {
-			CLIENT_DEBUG("Sending discover failed: %s",
+			CLIENT_WARN("Sending discover failed: %s",
 								strerror(-r));
 			goto error;
 		}
@@ -540,7 +549,7 @@ static void dhcp_client_timeout_resend(struct l_timeout=
 *timeout,
 	case DHCP_STATE_REBINDING:
 		r =3D dhcp_client_send_request(client);
 		if (r < 0) {
-			CLIENT_DEBUG("Sending Request failed: %s",
+			CLIENT_WARN("Sending Request failed: %s",
 								strerror(-r));
 			goto error;
 		}
@@ -632,7 +641,7 @@ static void dhcp_client_t1_expired(struct l_timeout *ti=
meout, void *user_data)
 =

 	r =3D dhcp_client_send_request(client);
 	if  (r < 0) {
-		CLIENT_DEBUG("Sending request failed: %s", strerror(-r));
+		CLIENT_WARN("Sending request failed: %s", strerror(-r));
 		goto error;
 	}
 =

@@ -665,7 +674,7 @@ static void dhcp_client_address_add_cb(int error, uint1=
6_t type,
 	if (error < 0 && error !=3D -EEXIST) {
 		l_rtnl_address_free(client->rtnl_configured_address);
 		client->rtnl_configured_address =3D NULL;
-		CLIENT_DEBUG("Unable to set address on ifindex: %u: %d(%s)",
+		CLIENT_WARN("Unable to set address on ifindex: %u: %d(%s)",
 				client->ifindex, error,
 				strerror(-error));
 		return;
@@ -691,7 +700,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 =

 	lease =3D _dhcp_lease_parse_options(&iter);
 	if (!lease) {
-		CLIENT_DEBUG("Failed to parse DHCP options.");
+		CLIENT_WARN("Failed to parse DHCP options.");
 =

 		return -ENOMSG;
 	}
@@ -746,7 +755,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 		if (client->rtnl_add_cmdid)
 			client->rtnl_configured_address =3D a;
 		else {
-			CLIENT_DEBUG("Configuring address via RTNL failed");
+			CLIENT_WARN("Configuring address via RTNL failed");
 			l_rtnl_address_free(a);
 		}
 	}
@@ -785,7 +794,7 @@ static int dhcp_client_receive_offer(struct l_dhcp_clie=
nt *client,
 			return -ENOMSG;
 		}
 =

-		CLIENT_DEBUG("Server sent another offer, using it instead");
+		CLIENT_INFO("Server sent another offer, using it instead");
 =

 		_dhcp_lease_free(client->lease);
 	}
@@ -890,7 +899,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 	case DHCP_STATE_REBINDING:
 	receive_rapid_commit:
 		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_NAK) {
-			CLIENT_DEBUG("Received NAK, Stopping...");
+			CLIENT_INFO("Received NAK, Stopping...");
 			l_dhcp_client_stop(client);
 =

 			dhcp_client_event_notify(client,
@@ -914,7 +923,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 			e =3D client->transport->bind(client->transport,
 						client->lease->address);
 			if (e < 0) {
-				CLIENT_DEBUG("Failed to bind dhcp socket. "
+				CLIENT_WARN("Failed to bind dhcp socket. "
 					"Error %d: %s", e, strerror(-e));
 			}
 		}
@@ -940,7 +949,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 			uint32_t next_timeout =3D
 					dhcp_fuzz_secs(client->lease->t1);
 =

-			CLIENT_DEBUG("T1 expiring in %u ms", next_timeout);
+			CLIENT_INFO("T1 expiring in %u ms", next_timeout);
 			client->timeout_lease =3D
 				l_timeout_create_ms(next_timeout,
 							dhcp_client_t1_expired,
@@ -953,7 +962,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		client->acd =3D l_acd_new(client->ifindex);
 =

-		if (client->debug_handler)
+		if (client->debug_handler && client->debug_level =3D=3D L_LOG_DEBUG)
 			l_acd_set_debug(client->acd, client->debug_handler,
 					client->debug_data,
 					client->debug_destroy);
@@ -976,7 +985,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		/* For unit testing we don't want this to be a fatal error */
 		if (!l_acd_start(client->acd, buf)) {
-			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
+			CLIENT_WARN("Failed to start ACD on %s, continuing",
 						buf);
 			l_acd_destroy(client->acd);
 			client->acd =3D NULL;
@@ -1290,7 +1299,7 @@ LIB_EXPORT bool l_dhcp_client_set_event_handler(struc=
t l_dhcp_client *client,
 LIB_EXPORT bool l_dhcp_client_set_debug(struct l_dhcp_client *client,
 						l_dhcp_debug_cb_t function,
 						void *user_data,
-						l_dhcp_destroy_cb_t destroy)
+						l_dhcp_destroy_cb_t destroy, int priority)
 {
 	if (unlikely(!client))
 		return false;
@@ -1301,6 +1310,7 @@ LIB_EXPORT bool l_dhcp_client_set_debug(struct l_dhcp=
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

--===============5841757857194423686==--

