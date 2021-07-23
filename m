Content-Type: multipart/mixed; boundary="===============9001539574165869795=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/8] dhcp-server: Look up leases by client identifier option
Date: Fri, 23 Jul 2021 20:23:28 +0200
Message-ID: <20210723182331.135123-5-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9001539574165869795==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If the client identifier option is present in the client message, that
should be used for lease lookups, overriding the MAC value, according to
RFC2131.  Parse that option and save the value for lookups.
---
 ell/dhcp-lease.c   |  9 ++++++
 ell/dhcp-private.h |  1 +
 ell/dhcp-server.c  | 72 ++++++++++++++++++++++++++++++++--------------
 ell/dhcp.h         |  1 +
 4 files changed, 62 insertions(+), 21 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index ffed6d6..c596c6b 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -49,6 +49,7 @@ void _dhcp_lease_free(struct l_dhcp_lease *lease)
 =

 	l_free(lease->dns);
 	l_free(lease->domain_name);
+	l_free(lease->client_id);
 =

 	l_free(lease);
 }
@@ -137,6 +138,14 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct =
dhcp_message_iter *iter)
 			if (l_net_hostname_is_localhost(lease->domain_name))
 				goto error;
 =

+			break;
+		case DHCP_OPTION_CLIENT_IDENTIFIER:
+			if (l < 1 || l > 253 || lease->client_id)
+				goto error;
+
+			lease->client_id =3D l_malloc(l + 1);
+			lease->client_id[0] =3D l;
+			memcpy(lease->client_id + 1, v, l);
 			break;
 		default:
 			break;
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index f761162..f9c0c6f 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -167,6 +167,7 @@ struct l_dhcp_lease {
 	char *domain_name;
 	/* for server */
 	uint8_t mac[6];
+	uint8_t *client_id;
 =

 	/* set for an offered lease, but not ACK'ed */
 	bool offering : 1;
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index fb26e29..2d90f8b 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -114,6 +114,15 @@ static bool is_expired_lease(const struct l_dhcp_lease=
 *lease)
 	return !l_time_after(get_lease_expiry_time(lease), l_time_now());
 }
 =

+static bool match_lease_client_id(const void *data, const void *user_data)
+{
+	const struct l_dhcp_lease *lease =3D data;
+	const uint8_t *client_id =3D user_data;
+
+	return lease->client_id &&
+		!memcmp(lease->client_id, client_id, client_id[0] + 1);
+}
+
 static bool match_lease_mac(const void *data, const void *user_data)
 {
 	const struct l_dhcp_lease *lease =3D data;
@@ -122,16 +131,21 @@ static bool match_lease_mac(const void *data, const v=
oid *user_data)
 	return !memcmp(lease->mac, mac, 6);
 }
 =

-static struct l_dhcp_lease *find_lease_by_mac(struct l_dhcp_server *server,
+static struct l_dhcp_lease *find_lease_by_id(struct l_dhcp_server *server,
+						const uint8_t *client_id,
 						const uint8_t *mac)
 {
+	if (client_id)
+		return l_queue_find(server->lease_list, match_lease_client_id,
+					client_id);
+
 	return l_queue_find(server->lease_list, match_lease_mac, mac);
 }
 =

 /* Clear the old lease and create the new one */
 static int get_lease(struct l_dhcp_server *server, uint32_t yiaddr,
-				const uint8_t *mac,
-				struct l_dhcp_lease **lease_out)
+			const uint8_t *client_id, const uint8_t *mac,
+			struct l_dhcp_lease **lease_out)
 {
 	struct l_dhcp_lease *lease;
 =

@@ -150,7 +164,7 @@ static int get_lease(struct l_dhcp_server *server, uint=
32_t yiaddr,
 	if (l_memeqzero(mac, ETH_ALEN))
 		return -ENXIO;
 =

-	lease =3D find_lease_by_mac(server, mac);
+	lease =3D find_lease_by_id(server, client_id, mac);
 =

 	if (lease) {
 		l_queue_remove(server->lease_list, lease);
@@ -245,13 +259,13 @@ static void lease_expired_cb(struct l_timeout *timeou=
t, void *user_data)
 }
 =

 static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
-					bool offering, const uint8_t *chaddr,
-					uint32_t yiaddr)
+					bool offering, const uint8_t *client_id,
+					const uint8_t *chaddr, uint32_t yiaddr)
 {
 	struct l_dhcp_lease *lease =3D NULL;
 	int ret;
 =

-	ret =3D get_lease(server, yiaddr, chaddr, &lease);
+	ret =3D get_lease(server, yiaddr, client_id, chaddr, &lease);
 	if (ret !=3D 0)
 		return NULL;
 =

@@ -262,6 +276,9 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_ser=
ver *server,
 	lease->subnet_mask =3D server->netmask;
 	lease->router =3D server->gateway;
 =

+	if (client_id)
+		lease->client_id =3D l_memdup(client_id, client_id[0] + 1);
+
 	lease->offering =3D offering;
 	lease->bound_time =3D l_time_now();
 =

@@ -509,7 +526,8 @@ static void add_server_options(struct l_dhcp_server *se=
rver,
 =

 static void send_offer(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
-			struct l_dhcp_lease *lease, uint32_t requested_ip)
+			struct l_dhcp_lease *lease, uint32_t requested_ip,
+			const uint8_t *client_id)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -531,7 +549,8 @@ static void send_offer(struct l_dhcp_server *server,
 		return;
 	}
 =

-	lease =3D add_lease(server, true, client_msg->chaddr, reply->yiaddr);
+	lease =3D add_lease(server, true, client_id, client_msg->chaddr,
+				reply->yiaddr);
 	if (!lease) {
 		SERVER_DEBUG("add_lease() failed");
 		return;
@@ -598,13 +617,13 @@ static void send_nak(struct l_dhcp_server *server,
 }
 =

 static void send_ack(struct l_dhcp_server *server,
-			const struct dhcp_message *client_msg, uint32_t dest)
+			const struct dhcp_message *client_msg,
+			const struct l_dhcp_lease *lease)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
 	L_AUTO_FREE_VAR(struct dhcp_message *, reply);
 	uint32_t lease_time =3D L_CPU_TO_BE32(server->lease_seconds);
-	struct l_dhcp_lease *lease;
 =

 	reply =3D (struct dhcp_message *) l_new(uint8_t, len);
 =

@@ -612,7 +631,7 @@ static void send_ack(struct l_dhcp_server *server,
 =

 	_dhcp_message_builder_init(&builder, reply, len, DHCP_MESSAGE_TYPE_ACK);
 =

-	reply->yiaddr =3D dest;
+	reply->yiaddr =3D lease->address;
 =

 	_dhcp_message_builder_append(&builder,
 					L_DHCP_OPTION_IP_ADDRESS_LEASE_TIME,
@@ -630,7 +649,8 @@ static void send_ack(struct l_dhcp_server *server,
 	if (!server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_ACK))
 		return;
 =

-	lease =3D add_lease(server, false, reply->chaddr, reply->yiaddr);
+	lease =3D add_lease(server, false, lease->client_id, reply->chaddr,
+				reply->yiaddr);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
@@ -648,6 +668,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 	uint8_t type =3D 0;
 	uint32_t server_id_opt =3D 0;
 	uint32_t requested_ip_opt =3D 0;
+	L_AUTO_FREE_VAR(uint8_t *, client_id_opt) =3D NULL;
 =

 	SERVER_DEBUG("");
 =

@@ -671,13 +692,21 @@ static void listener_event(const void *data, size_t l=
en, void *user_data)
 				requested_ip_opt =3D l_get_u32(v);
 =

 			break;
+		case DHCP_OPTION_CLIENT_IDENTIFIER:
+			if (l < 1 || l > 253 || client_id_opt)
+				break;
+
+			client_id_opt =3D l_malloc(l + 1);
+			client_id_opt[0] =3D l;
+			memcpy(client_id_opt + 1, v, l);
+			break;
 		}
 	}
 =

 	if (type =3D=3D 0)
 		return;
 =

-	lease =3D find_lease_by_mac(server, message->chaddr);
+	lease =3D find_lease_by_id(server, client_id_opt, message->chaddr);
 	if (!lease)
 		SERVER_DEBUG("No lease found for "MAC,
 					MAC_STR(message->chaddr));
@@ -690,8 +719,8 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		if (server_id_opt && server_id_opt !=3D server->address)
 			break;
 =

-		send_offer(server, message, lease, requested_ip_opt);
-
+		send_offer(server, message, lease, requested_ip_opt,
+				client_id_opt);
 		break;
 	case DHCP_MESSAGE_TYPE_REQUEST:
 		SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FMT,
@@ -776,7 +805,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 			}
 		}
 =

-		send_ack(server, message, lease->address);
+		send_ack(server, message, lease);
 		break;
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
@@ -1185,6 +1214,7 @@ LIB_EXPORT void l_dhcp_server_set_authoritative(struc=
t l_dhcp_server *server,
 LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discover(
 						struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
+						const uint8_t *client_id,
 						const uint8_t *mac)
 {
 	struct l_dhcp_lease *lease;
@@ -1192,7 +1222,7 @@ LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discove=
r(
 	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
 			NIPQUAD(requested_ip_opt), MAC_STR(mac));
 =

-	if ((lease =3D find_lease_by_mac(server, mac)))
+	if ((lease =3D find_lease_by_id(server, client_id, mac)))
 		requested_ip_opt =3D lease->address;
 	else if (!check_requested_ip(server, requested_ip_opt)) {
 		requested_ip_opt =3D find_free_or_expired_ip(server, mac);
@@ -1203,7 +1233,7 @@ LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discove=
r(
 		}
 	}
 =

-	lease =3D add_lease(server, true, mac, requested_ip_opt);
+	lease =3D add_lease(server, true, client_id, mac, requested_ip_opt);
 	if (unlikely(!lease)) {
 		SERVER_DEBUG("add_lease() failed");
 		return NULL;
@@ -1223,7 +1253,7 @@ LIB_EXPORT bool l_dhcp_server_request(struct l_dhcp_s=
erver *server,
 	SERVER_DEBUG("Requested IP " NIPQUAD_FMT " for " MAC,
 			NIPQUAD(lease->address), MAC_STR(lease->mac));
 =

-	lease =3D add_lease(server, false, lease->mac, lease->address);
+	lease =3D add_lease(server, false, NULL, lease->mac, lease->address);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
@@ -1276,7 +1306,7 @@ LIB_EXPORT bool l_dhcp_server_lease_remove(struct l_d=
hcp_server *server,
 LIB_EXPORT void l_dhcp_server_expire_by_mac(struct l_dhcp_server *server,
 						const uint8_t *mac)
 {
-	struct l_dhcp_lease *lease =3D find_lease_by_mac(server, mac);
+	struct l_dhcp_lease *lease =3D find_lease_by_id(server, NULL, mac);
 =

 	if (likely(lease))
 		lease_release(server, lease);
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 830cbb1..58deb7e 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -146,6 +146,7 @@ void l_dhcp_server_set_authoritative(struct l_dhcp_serv=
er *server,
 =

 struct l_dhcp_lease *l_dhcp_server_discover(struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
+						const uint8_t *client_id,
 						const uint8_t *mac);
 bool l_dhcp_server_request(struct l_dhcp_server *server,
 				struct l_dhcp_lease *lease);
-- =

2.30.2

--===============9001539574165869795==--

