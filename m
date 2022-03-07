Content-Type: multipart/mixed; boundary="===============0502834869094605940=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 02/12] dhcp: Set lease expiry based on frame reception times
Date: Mon, 07 Mar 2022 15:55:33 +0100
Message-ID: <20220307145543.1558788-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============0502834869094605940==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the SO_TIMESTAMP socket option to request the packet rx timestamps
from the kernel and pass those values from dhcp-transport to
dhcp-client/server to use in lease expiry time calculation.

Apparently linux has a few different variants of SO_TIMESTAMP, use the
most basic one.  Additionally the rx times can be obtained without
SO_TIMESTAMP using the SIOCGSTAMP ioctl on each packet.  The advantage
would be that we'd only parse the timestamps for the frames where we
actually care about timing.  The disadvantage would be an extra syscall
for those frames, which we don't incur with SO_TIMESTAMP.
---
 ell/dhcp-private.h   |  2 +-
 ell/dhcp-server.c    | 29 +++++++++++++++++------------
 ell/dhcp-transport.c | 41 +++++++++++++++++++++++++++++++++++------
 ell/dhcp.c           | 12 ++++++++----
 4 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 1c12cbe..b695e4e 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -108,7 +108,7 @@ uint16_t _dhcp_checksum(const void *buf, size_t len);
 uint16_t _dhcp_checksumv(const struct iovec *iov, size_t iov_cnt);
 =

 typedef void (*dhcp_transport_rx_cb_t)(const void *, size_t, void *,
-					const uint8_t *);
+					const uint8_t *, uint64_t);
 =

 struct dhcp_transport {
 	int (*open)(struct dhcp_transport *s, uint32_t xid);
diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index ff0784f..5c0774b 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -299,7 +299,8 @@ static void lease_expired_cb(struct l_timeout *timeout,=
 void *user_data)
 =

 static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
 					bool offering, const uint8_t *client_id,
-					const uint8_t *chaddr, uint32_t yiaddr)
+					const uint8_t *chaddr, uint32_t yiaddr,
+					uint64_t timestamp)
 {
 	struct l_dhcp_lease *lease =3D NULL;
 	int ret;
@@ -328,7 +329,7 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_ser=
ver *server,
 		lease->client_id =3D l_memdup(client_id, client_id[0] + 1);
 =

 	lease->offering =3D offering;
-	lease->bound_time =3D l_time_now();
+	lease->bound_time =3D timestamp;
 =

 	if (!offering) {
 		lease->lifetime =3D server->lease_seconds;
@@ -572,7 +573,7 @@ static void copy_client_id(struct dhcp_message_builder =
*builder,
 static void send_offer(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
 			struct l_dhcp_lease *lease, uint32_t requested_ip,
-			const uint8_t *client_id)
+			const uint8_t *client_id, uint64_t timestamp)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -595,7 +596,7 @@ static void send_offer(struct l_dhcp_server *server,
 	}
 =

 	lease =3D add_lease(server, true, client_id, client_msg->chaddr,
-				reply->yiaddr);
+				reply->yiaddr, timestamp);
 	if (!lease) {
 		SERVER_DEBUG("add_lease() failed");
 		return;
@@ -668,7 +669,8 @@ static void send_nak(struct l_dhcp_server *server,
 static void send_ack(struct l_dhcp_server *server,
 			const struct dhcp_message *client_msg,
 			struct l_dhcp_lease *lease,
-			bool rapid_commit)
+			bool rapid_commit,
+			uint64_t timestamp)
 {
 	struct dhcp_message_builder builder;
 	size_t len =3D sizeof(struct dhcp_message) + DHCP_MIN_OPTIONS_SIZE;
@@ -706,7 +708,7 @@ static void send_ack(struct l_dhcp_server *server,
 		return;
 =

 	lease =3D add_lease(server, false, client_id, reply->chaddr,
-				reply->yiaddr);
+				reply->yiaddr, timestamp);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
@@ -714,7 +716,7 @@ static void send_ack(struct l_dhcp_server *server,
 }
 =

 static void listener_event(const void *data, size_t len, void *user_data,
-				const uint8_t *saddr)
+				const uint8_t *saddr, uint64_t timestamp)
 {
 	struct l_dhcp_server *server =3D user_data;
 	const struct dhcp_message *message =3D data;
@@ -803,12 +805,13 @@ static void listener_event(const void *data, size_t l=
en, void *user_data,
 				break;
 			}
 =

-			send_ack(server, message, lease, rapid_commit_opt);
+			send_ack(server, message, lease, rapid_commit_opt,
+					timestamp);
 			break;
 		}
 =

 		send_offer(server, message, lease, requested_ip_opt,
-				client_id_opt);
+				client_id_opt, timestamp);
 		break;
 	case DHCP_MESSAGE_TYPE_REQUEST:
 		SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FMT,
@@ -903,7 +906,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data,
 			}
 		}
 =

-		send_ack(server, message, lease, false);
+		send_ack(server, message, lease, false, timestamp);
 		break;
 	case DHCP_MESSAGE_TYPE_DECLINE:
 		SERVER_DEBUG("Received DECLINE");
@@ -1350,7 +1353,8 @@ LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discove=
r(
 		}
 	}
 =

-	lease =3D add_lease(server, true, client_id, mac, requested_ip_opt);
+	lease =3D add_lease(server, true, client_id, mac, requested_ip_opt,
+				l_time_now());
 	if (unlikely(!lease)) {
 		SERVER_DEBUG("add_lease() failed");
 		return NULL;
@@ -1373,7 +1377,8 @@ LIB_EXPORT bool l_dhcp_server_request(struct l_dhcp_s=
erver *server,
 			NIPQUAD(lease->address), MAC_STR(lease->mac));
 =

 	memcpy(mac, lease->mac, ETH_ALEN);
-	lease =3D add_lease(server, false, NULL, mac, lease->address);
+	lease =3D add_lease(server, false, NULL, mac, lease->address,
+				lease->bound_time);
 =

 	if (server->event_handler)
 		server->event_handler(server, L_DHCP_SERVER_EVENT_NEW_LEASE,
diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 7c73fee..d73930b 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -44,6 +44,7 @@
 #include "io.h"
 #include "util.h"
 #include "private.h"
+#include "time.h"
 #include "dhcp-private.h"
 =

 struct dhcp_default_transport {
@@ -112,10 +113,20 @@ static bool _dhcp_default_transport_read_handler(stru=
ct l_io *io,
 	struct dhcp_packet *p;
 	uint16_t c;
 	struct sockaddr_ll saddr;
-	socklen_t saddr_len =3D sizeof(saddr);
-
-	len =3D recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr *) &saddr,
-			&saddr_len);
+	uint64_t timestamp =3D 0;
+	struct cmsghdr *cmsg;
+	struct iovec iov =3D { .iov_base =3D buf, .iov_len =3D sizeof(buf) };
+	struct msghdr msg =3D {};
+	unsigned char control[32];
+
+	msg.msg_name =3D &saddr;
+	msg.msg_namelen =3D sizeof(saddr);
+	msg.msg_iov =3D &iov;
+	msg.msg_iovlen =3D 1;
+	msg.msg_control =3D control;
+	msg.msg_controllen =3D sizeof(control);
+
+	len =3D recvmsg(fd, &msg, 0);
 	if (len < 0)
 		return false;
 =

@@ -151,14 +162,28 @@ static bool _dhcp_default_transport_read_handler(stru=
ct l_io *io,
 =

 	len -=3D sizeof(struct udphdr) - sizeof(struct iphdr);
 =

+	for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg !=3D NULL;
+					cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
+		if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
+			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+		}
+	}
+
+	if (!timestamp)
+		timestamp =3D l_time_now();
+
 	if (transport->super.rx_cb) {
 		const uint8_t *src_mac =3D NULL;
 =

-		if (saddr_len >=3D sizeof(saddr) && saddr.sll_halen =3D=3D ETH_ALEN)
+		if (msg.msg_namelen >=3D sizeof(saddr) &&
+				saddr.sll_halen =3D=3D ETH_ALEN)
 			src_mac =3D saddr.sll_addr;
 =

 		transport->super.rx_cb(&p->dhcp, len, transport->super.rx_data,
-					src_mac);
+					src_mac, timestamp);
 	}
 =

 	return true;
@@ -443,6 +468,7 @@ static int kernel_raw_socket_open(uint32_t ifindex, uin=
t16_t port, uint32_t xid)
 		.len =3D L_ARRAY_SIZE(filter),
 		.filter =3D filter
 	};
+	int one =3D 1;
 =

 	s =3D socket(AF_PACKET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
 	if (s < 0)
@@ -452,6 +478,9 @@ static int kernel_raw_socket_open(uint32_t ifindex, uin=
t16_t port, uint32_t xid)
 						&fprog, sizeof(fprog)) < 0)
 		goto error;
 =

+	if (setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &one, sizeof(one)) < 0)
+		goto error;
+
 	memset(&addr, 0, sizeof(addr));
 	addr.sll_family =3D AF_PACKET;
 	addr.sll_protocol =3D htons(ETH_P_IP);
diff --git a/ell/dhcp.c b/ell/dhcp.c
index e2d18fc..2d04900 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -675,7 +675,7 @@ static void dhcp_client_address_add_cb(int error, uint1=
6_t type,
 static int dhcp_client_receive_ack(struct l_dhcp_client *client,
 					const uint8_t *saddr,
 					const struct dhcp_message *ack,
-					size_t len)
+					size_t len, uint64_t timestamp)
 {
 	struct dhcp_message_iter iter;
 	struct l_dhcp_lease *lease;
@@ -727,6 +727,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 		uint32_t l =3D l_dhcp_lease_get_lifetime(client->lease);
 		L_AUTO_FREE_VAR(char *, broadcast) =3D
 				l_dhcp_lease_get_broadcast(client->lease);
+		uint64_t et =3D timestamp + l * L_USEC_PER_SEC;
 =

 		prefix_len =3D l_dhcp_lease_get_prefix_length(client->lease);
 		if (!prefix_len)
@@ -735,6 +736,7 @@ static int dhcp_client_receive_ack(struct l_dhcp_client=
 *client,
 		a =3D l_rtnl_address_new(ip, prefix_len);
 		l_rtnl_address_set_noprefixroute(a, true);
 		l_rtnl_address_set_lifetimes(a, l, l);
+		l_rtnl_address_set_expiry(a, et, et);
 		l_rtnl_address_set_broadcast(a, broadcast);
 =

 		client->rtnl_add_cmdid =3D
@@ -817,7 +819,8 @@ static bool dhcp_client_handle_offer(struct l_dhcp_clie=
nt *client,
 }
 =

 static void dhcp_client_rx_message(const void *data, size_t len, void *use=
rdata,
-					const uint8_t *saddr)
+					const uint8_t *saddr,
+					uint64_t timestamp)
 {
 	struct l_dhcp_client *client =3D userdata;
 	const struct dhcp_message *message =3D data;
@@ -898,7 +901,8 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 		if (msg_type !=3D DHCP_MESSAGE_TYPE_ACK)
 			return;
 =

-		r =3D dhcp_client_receive_ack(client, saddr, message, len);
+		r =3D dhcp_client_receive_ack(client, saddr, message, len,
+						timestamp);
 		if (r < 0)
 			return;
 =

@@ -917,7 +921,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata,
 =

 		dhcp_client_event_notify(client, r);
 =

-		client->lease->bound_time =3D l_time_now();
+		client->lease->bound_time =3D timestamp;
 =

 		/*
 		 * Start T1, once it expires we will start the T2 timer.  If
-- =

2.32.0

--===============0502834869094605940==--

