Content-Type: multipart/mixed; boundary="===============1315651856971844600=="
MIME-Version: 1.0
From: Davide Caratti <davide.caratti@gmail.com>
Subject: [PATCH 1/2] ell: avoid using inet_ntoa()
Date: Wed, 16 Jun 2021 21:22:14 +0200
Message-ID: <144affac0389b92896ae152643610b6ec497a398.1623871292.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1315651856971844600==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

static checkers (like rpminspect) complain about use of inet_ntoa(), as
it relies on a static buffer. Fix this as follows:

 - use inet_ntop() with a buffer of size INET_ADDRSTRLEN allocated in
   the stack, similarly to what it is already done for IPv6 addresses
 - convert IP_STR() to use NIPQUAD() / NIPQUAD_FMT, similarly to what
   is done with MAC addresses
---
 ell/acd.c         | 28 +++++++++++++---------------
 ell/dhcp-lease.c  |  3 ++-
 ell/dhcp-server.c | 37 ++++++++++++++++++-------------------
 ell/dhcp.c        |  6 ++++--
 ell/rtnl.c        |  7 +++++--
 5 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index 6989f82..4216898 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -55,14 +55,11 @@
 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
 =

-#define IP_STR(uint_ip) \
-({ \
-	struct in_addr _in; \
-	char *_out; \
-	_in.s_addr =3D uint_ip; \
-	_out =3D inet_ntoa(_in); \
-	_out; \
-})
+#define NIPQUAD_FMT "%u.%u.%u.%u"
+#define NIPQUAD(u32_ip)	((unsigned char *) &u32_ip)[0], \
+			((unsigned char *) &u32_ip)[1], \
+			((unsigned char *) &u32_ip)[2], \
+			((unsigned char *) &u32_ip)[3]
 =

 #define ACD_DEBUG(fmt, args...)					\
 	l_util_debug(acd->debug_handler, acd->debug_data,		\
@@ -146,7 +143,8 @@ static int acd_send_packet(struct l_acd *acd, uint32_t =
source_ip)
 	p.arp_pln =3D 4;
 	p.arp_op =3D htons(ARPOP_REQUEST);
 =

-	ACD_DEBUG("sending packet with target IP %s", IP_STR(acd->ip));
+	ACD_DEBUG("sending packet with target IP "NIPQUAD_FMT,
+			NIPQUAD(acd->ip));
 =

 	memcpy(&p.arp_sha, acd->mac, ETH_ALEN);
 	memcpy(&p.arp_spa, &source_ip, sizeof(p.arp_spa));
@@ -165,8 +163,8 @@ static void announce_wait_timeout(struct l_timeout *tim=
eout, void *user_data)
 	struct l_acd *acd =3D user_data;
 =

 	if (acd->state =3D=3D ACD_STATE_PROBE) {
-		ACD_DEBUG("No conflicts found for %s, announcing address",
-				IP_STR(acd->ip));
+		ACD_DEBUG("No conflicts found for "NIPQUAD_FMT ", announcing address",
+				NIPQUAD(acd->ip));
 =

 		acd->state =3D ACD_STATE_ANNOUNCED;
 =

@@ -284,17 +282,17 @@ static bool acd_read_handler(struct l_io *io, void *u=
ser_data)
 		!memcmp(arp.arp_tpa, &acd->ip, sizeof(uint32_t));
 =

 	if (!source_conflict && !target_conflict) {
-		ACD_DEBUG("No target or source conflict detected for %s",
-				IP_STR(acd->ip));
+		ACD_DEBUG("No target or source conflict detected for "NIPQUAD_FMT,
+				NIPQUAD(acd->ip));
 		return true;
 	}
 =

 	switch (acd->state) {
 	case ACD_STATE_PROBE:
 		/* No reason to continue probing */
-		ACD_DEBUG("%s conflict detected for %s",
+		ACD_DEBUG("%s conflict detected for "NIPQUAD_FMT,
 				target_conflict ? "Target" : "Source",
-				IP_STR(acd->ip));
+				NIPQUAD(acd->ip));
 =

 		if (acd->event_func)
 			acd->event_func(L_ACD_EVENT_CONFLICT, acd->user_data);
diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 44c815f..94b67b4 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -178,12 +178,13 @@ error:
 static inline char *get_ip(uint32_t ip)
 {
 	struct in_addr addr;
+	char buf[INET_ADDRSTRLEN];
 =

 	if (ip =3D=3D 0)
 		return NULL;
 =

 	addr.s_addr =3D ip;
-	return l_strdup(inet_ntoa(addr));
+	return l_strdup(inet_ntop(AF_INET, &addr, buf, INET_ADDRSTRLEN));
 }
 =

 LIB_EXPORT char *l_dhcp_lease_get_address(const struct l_dhcp_lease *lease)
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 34512ae..4a6b3f6 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -92,14 +92,11 @@ struct l_dhcp_server {
 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
 =

-#define IP_STR(uint_ip) \
-({ \
-	struct in_addr _in; \
-	char *_out; \
-	_in.s_addr =3D uint_ip; \
-	_out =3D inet_ntoa(_in); \
-	_out; \
-})
+#define NIPQUAD_FMT "%u.%u.%u.%u"
+#define NIPQUAD(u32_ip)	((unsigned char *) &u32_ip)[0], \
+			((unsigned char *) &u32_ip)[1], \
+			((unsigned char *) &u32_ip)[2], \
+			((unsigned char *) &u32_ip)[3]
 =

 #define SERVER_DEBUG(fmt, args...)					\
 	l_util_debug(server->debug_handler, server->debug_data,		\
@@ -286,8 +283,8 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_ser=
ver *server,
 		l_queue_push_head(server->lease_list, lease);
 	}
 =

-	SERVER_DEBUG("added lease IP %s for "MAC " lifetime=3D%u",
-			IP_STR(yiaddr), MAC_STR(chaddr),
+	SERVER_DEBUG("added lease IP "NIPQUAD_FMT " for "MAC " lifetime=3D%u",
+			NIPQUAD(yiaddr), MAC_STR(chaddr),
 			server->lease_seconds);
 =

 	return lease;
@@ -477,8 +474,8 @@ static void send_offer(struct l_dhcp_server *server,
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	SERVER_DEBUG("Sending OFFER of %s to "MAC, IP_STR(reply->yiaddr),
-			MAC_STR(reply->chaddr));
+	SERVER_DEBUG("Sending OFFER of "NIPQUAD_FMT " to "MAC,
+			NIPQUAD(reply->yiaddr),	MAC_STR(reply->chaddr));
 =

 	if (server->transport->l2_send(server->transport, server->address,
 					DHCP_PORT_SERVER,
@@ -561,7 +558,7 @@ static void send_ack(struct l_dhcp_server *server,
 =

 	_dhcp_message_builder_finalize(&builder, &len);
 =

-	SERVER_DEBUG("Sending ACK to %s", IP_STR(reply->yiaddr));
+	SERVER_DEBUG("Sending ACK to "NIPQUAD_FMT, NIPQUAD(reply->yiaddr));
 =

 	if (server->transport->l2_send(server->transport, server->address,
 					DHCP_PORT_SERVER, reply->ciaddr,
@@ -628,15 +625,15 @@ static void listener_event(const void *data, size_t l=
en, void *user_data)
 =

 	switch (type) {
 	case DHCP_MESSAGE_TYPE_DISCOVER:
-		SERVER_DEBUG("Received DISCOVER, requested IP %s",
-					IP_STR(requested_ip_opt));
+		SERVER_DEBUG("Received DISCOVER, requested IP "NIPQUAD_FMT,
+					NIPQUAD(requested_ip_opt));
 =

 		send_offer(server, message, lease, requested_ip_opt);
 =

 		break;
 	case DHCP_MESSAGE_TYPE_REQUEST:
-		SERVER_DEBUG("Received REQUEST, requested IP %s",
-				IP_STR(requested_ip_opt));
+		SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FMT,
+				NIPQUAD(requested_ip_opt));
 =

 		if (requested_ip_opt =3D=3D 0) {
 			requested_ip_opt =3D message->ciaddr;
@@ -760,6 +757,7 @@ LIB_EXPORT void l_dhcp_server_destroy(struct l_dhcp_ser=
ver *server)
 =

 LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_server *server)
 {
+	char buf[INET_ADDRSTRLEN];
 	struct in_addr ia;
 =

 	if (unlikely(!server))
@@ -846,11 +844,12 @@ LIB_EXPORT bool l_dhcp_server_start(struct l_dhcp_ser=
ver *server)
 	l_acd_set_defend_policy(server->acd, L_ACD_DEFEND_POLICY_INFINITE);
 =

 	ia.s_addr =3D server->address;
+	inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN);
 =

 	/* In case of unit testing we don't want this to be a fatal error */
-	if (!l_acd_start(server->acd, inet_ntoa(ia))) {
+	if (!l_acd_start(server->acd, buf)) {
 		SERVER_DEBUG("Failed to start ACD on %s, continuing without",
-				IP_STR(server->address));
+				buf);
 =

 		l_acd_destroy(server->acd);
 		server->acd =3D NULL;
diff --git a/ell/dhcp.c b/ell/dhcp.c
index fff1645..bd346cc 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -778,6 +778,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 	struct l_dhcp_client *client =3D userdata;
 	const struct dhcp_message *message =3D data;
 	struct dhcp_message_iter iter;
+	char buf[INET_ADDRSTRLEN];
 	uint8_t msg_type =3D 0;
 	uint8_t t, l;
 	const void *v;
@@ -911,11 +912,12 @@ static void dhcp_client_rx_message(const void *data, =
size_t len, void *userdata)
 		l_acd_set_skip_probes(client->acd, true);
 =

 		ia.s_addr =3D client->lease->address;
+		inet_ntop(AF_INET, &ia, buf, INET_ADDRSTRLEN);
 =

 		/* For unit testing we don't want this to be a fatal error */
-		if (!l_acd_start(client->acd, inet_ntoa(ia))) {
+		if (!l_acd_start(client->acd, buf)) {
 			CLIENT_DEBUG("Failed to start ACD on %s, continuing",
-						inet_ntoa(ia));
+						buf);
 			l_acd_destroy(client->acd);
 			client->acd =3D NULL;
 		}
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 957e749..2983013 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -752,6 +752,7 @@ LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netlink=
 *rtnl, int ifindex,
 LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int by=
tes,
 				char **label, char **ip, char **broadcast)
 {
+	char buf[INET_ADDRSTRLEN];
 	struct in_addr in_addr;
 	struct rtattr *attr;
 =

@@ -763,7 +764,8 @@ LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifa=
ddrmsg *ifa, int bytes,
 				break;
 =

 			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
-			*ip =3D l_strdup(inet_ntoa(in_addr));
+			*ip =3D l_strdup(inet_ntop(AF_INET, &in_addr, buf,
+							INET_ADDRSTRLEN));
 =

 			break;
 		case IFA_BROADCAST:
@@ -771,7 +773,8 @@ LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifa=
ddrmsg *ifa, int bytes,
 				break;
 =

 			in_addr =3D *((struct in_addr *) RTA_DATA(attr));
-			*broadcast =3D l_strdup(inet_ntoa(in_addr));
+			*broadcast =3D l_strdup(inet_ntop(AF_INET, &in_addr, buf,
+							INET_ADDRSTRLEN));
 =

 			break;
 		case IFA_LABEL:
-- =

2.31.1

--===============1315651856971844600==--

