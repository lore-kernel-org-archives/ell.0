Content-Type: multipart/mixed; boundary="===============4411396917030657390=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/7] acd: add ARP sockets, listener, and probing
Date: Thu, 03 Dec 2020 12:41:39 -0800
Message-ID: <20201203204144.480090-2-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4411396917030657390==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add support for opening the network socket, listening for
messages, and sending ARP probes.
---
 ell/acd.c | 226 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 226 insertions(+)

diff --git a/ell/acd.c b/ell/acd.c
index 11bee06..f8f3df4 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -22,17 +22,52 @@
 #include <config.h>
 #endif
 =

+#include <unistd.h>
 #include <sys/socket.h>
+#include <netpacket/packet.h>
+#include <netinet/if_ether.h>
+#include <net/if_arp.h>
 #include <arpa/inet.h>
 =

 #include "private.h"
 #include "acd.h"
 #include "util.h"
+#include "io.h"
+#include "net.h"
+#include "timeout.h"
+#include "random.h"
+
+/* IPv4 Address Conflict Detection (RFC 5227) */
+#define PROBE_WAIT		1
+#define PROBE_NUM		3
+#define PROBE_MIN		1
+#define PROBE_MAX		2
+
+#define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_STR(a) a[0], a[1], a[2], a[3], a[4], a[5]
+
+#define IP_STR(uint_ip) \
+({ \
+	struct in_addr _in; \
+	char *_out; \
+	_in.s_addr =3D uint_ip; \
+	_out =3D inet_ntoa(_in); \
+	_out; \
+})
+
+#define ACD_DEBUG(fmt, args...)					\
+	l_util_debug(acd->debug_handler, acd->debug_data,		\
+			"%s:%i " fmt, __func__, __LINE__, ## args)
 =

 struct l_acd {
 	int ifindex;
 =

 	uint32_t ip;
+	uint8_t mac[ETH_ALEN];
+
+	struct l_io *io;
+	struct l_timeout *timeout;
+	unsigned int retries;
 =

 	l_acd_event_func_t event_func;
 	l_acd_destroy_func_t destroy;
@@ -43,6 +78,158 @@ struct l_acd {
 	void *debug_data;
 };
 =

+static int acd_open_socket(int ifindex)
+{
+	struct sockaddr_ll dest;
+	int fd;
+
+	fd =3D socket(PF_PACKET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (fd < 0)
+		return -errno;
+
+	memset(&dest, 0, sizeof(dest));
+
+	dest.sll_family =3D AF_PACKET;
+	dest.sll_protocol =3D htons(ETH_P_ARP);
+	dest.sll_ifindex =3D ifindex;
+	dest.sll_halen =3D ETH_ALEN;
+	memset(dest.sll_addr, 0xFF, ETH_ALEN);
+
+	if (bind(fd, (struct sockaddr *)&dest, sizeof(dest)) < 0) {
+		int err =3D errno;
+		close(fd);
+		return -err;
+	}
+
+	return fd;
+}
+
+static int acd_send_packet(struct l_acd *acd, uint32_t source_ip)
+{
+	struct sockaddr_ll dest;
+	struct ether_arp p;
+	uint32_t ip_source;
+	uint32_t ip_target;
+	int n;
+	int fd =3D l_io_get_fd(acd->io);
+
+	memset(&dest, 0, sizeof(dest));
+
+	dest.sll_family =3D AF_PACKET;
+	dest.sll_protocol =3D htons(ETH_P_ARP);
+	dest.sll_ifindex =3D acd->ifindex;
+	dest.sll_halen =3D ETH_ALEN;
+	memset(dest.sll_addr, 0xFF, ETH_ALEN);
+
+	ip_source =3D htonl(source_ip);
+	ip_target =3D htonl(acd->ip);
+	p.arp_hrd =3D htons(ARPHRD_ETHER);
+	p.arp_pro =3D htons(ETHERTYPE_IP);
+	p.arp_hln =3D ETH_ALEN;
+	p.arp_pln =3D 4;
+	p.arp_op =3D htons(ARPOP_REQUEST);
+
+	ACD_DEBUG("sending packet with target IP %s", IP_STR(ip_target));
+
+	memcpy(&p.arp_sha, acd->mac, ETH_ALEN);
+	memcpy(&p.arp_spa, &ip_source, sizeof(p.arp_spa));
+	memcpy(&p.arp_tpa, &ip_target, sizeof(p.arp_tpa));
+
+	n =3D sendto(fd, &p, sizeof(p), 0,
+			(struct sockaddr*) &dest, sizeof(dest));
+	if (n < 0)
+		n =3D -errno;
+
+	return n;
+}
+
+static uint32_t acd_random_delay_ms(uint32_t max_sec)
+{
+	uint32_t rand;
+
+	l_getrandom(&rand, sizeof(rand));
+
+	return rand % (max_sec * 1000);
+}
+
+static void probe_wait_timeout(struct l_timeout *timeout, void *user_data)
+{
+	struct l_acd *acd =3D user_data;
+	uint32_t delay;
+
+	ACD_DEBUG("Sending ACD Probe");
+
+	l_timeout_remove(acd->timeout);
+	acd->timeout =3D NULL;
+
+	if (acd_send_packet(acd, 0) < 0) {
+		ACD_DEBUG("Failed to send ACD probe");
+		return;
+	}
+
+	acd->retries++;
+
+	if (acd->retries < PROBE_NUM) {
+		/*
+		 * RFC 5227 - Section 2.1.1
+		 *
+		 * "... and should then send PROBE_NUM probe packets, each of
+		 * these probe packets spaced randomly and uniformly, PROBE_MIN
+		 * to PROBE_MAX seconds apart."
+		 */
+		delay =3D acd_random_delay_ms(PROBE_MAX - PROBE_MIN);
+		delay +=3D PROBE_MIN * 1000;
+		acd->timeout =3D l_timeout_create_ms(delay, probe_wait_timeout,
+							acd, NULL);
+	} else
+		ACD_DEBUG("Done probing");
+
+}
+
+static bool acd_read_handler(struct l_io *io, void *user_data)
+{
+	struct l_acd *acd =3D user_data;
+	struct ether_arp arp;
+	ssize_t len;
+	int source_conflict;
+	int target_conflict;
+	bool probe;
+	uint32_t ip;
+
+	memset(&arp, 0, sizeof(arp));
+	len =3D read(l_io_get_fd(acd->io), &arp, sizeof(arp));
+	if (len < 0)
+		return false;
+
+	if (len !=3D sizeof(arp))
+		return true;
+
+	if (arp.arp_op !=3D htons(ARPOP_REPLY) &&
+			arp.arp_op !=3D htons(ARPOP_REQUEST))
+		return true;
+
+	if (memcmp(arp.arp_sha, acd->mac, ETH_ALEN) =3D=3D 0)
+		return true;
+
+	ip =3D htonl(acd->ip);
+	source_conflict =3D !memcmp(arp.arp_spa, &ip, sizeof(uint32_t));
+	probe =3D l_memeqzero(arp.arp_spa, sizeof(uint32_t));
+	target_conflict =3D probe &&
+		!memcmp(arp.arp_tpa, &ip, sizeof(uint32_t));
+
+	if (!source_conflict && !target_conflict) {
+		ACD_DEBUG("No target or source conflict detected for %s",
+				IP_STR(ip));
+		return true;
+	}
+
+	ACD_DEBUG("%s conflict detected for %s",
+			target_conflict ? "Target" : "Source",
+			IP_STR(ip));
+
+	return true;
+}
+
 LIB_EXPORT struct l_acd *l_acd_new(int ifindex)
 {
 	struct l_acd *acd =3D l_new(struct l_acd, 1);
@@ -55,6 +242,8 @@ LIB_EXPORT struct l_acd *l_acd_new(int ifindex)
 LIB_EXPORT bool l_acd_start(struct l_acd *acd, const char *ip)
 {
 	struct in_addr ia;
+	int fd;
+	uint32_t delay;
 =

 	if (unlikely(!acd || !ip))
 		return false;
@@ -62,8 +251,35 @@ LIB_EXPORT bool l_acd_start(struct l_acd *acd, const ch=
ar *ip)
 	if (inet_pton(AF_INET, ip, &ia) !=3D 1)
 		return false;
 =

+	fd =3D acd_open_socket(acd->ifindex);
+	if (fd < 0)
+		return false;
+
+	if (l_memeqzero(acd->mac, ETH_ALEN) &&
+			!l_net_get_mac_address(acd->ifindex, acd->mac)) {
+		close(fd);
+		return false;
+	}
+
+	acd->io =3D l_io_new(fd);
+	l_io_set_close_on_destroy(acd->io, true);
+	l_io_set_read_handler(acd->io, acd_read_handler, acd, NULL);
+
 	acd->ip =3D ntohl(ia.s_addr);
 =

+	delay =3D acd_random_delay_ms(PROBE_WAIT);
+
+	ACD_DEBUG("Waiting %ums to send probe", delay);
+
+	/*
+	 * RFC 5227 - Section 2.1.1
+	 * "When ready to begin probing, the host should then wait for a random
+	 *  time interval selected uniformly in the range zero to PROBE_WAIT
+	 *  seconds..."
+	 */
+	acd->timeout =3D l_timeout_create_ms(delay, probe_wait_timeout,
+							acd, NULL);
+
 	return true;
 }
 =

@@ -87,6 +303,16 @@ LIB_EXPORT bool l_acd_stop(struct l_acd *acd)
 	if (unlikely(!acd))
 		return false;
 =

+	if (acd->timeout) {
+		l_timeout_remove(acd->timeout);
+		acd->timeout =3D NULL;
+	}
+
+	if (acd->io) {
+		l_io_destroy(acd->io);
+		acd->io =3D NULL;
+	}
+
 	return true;
 }
 =

-- =

2.26.2

--===============4411396917030657390==--

