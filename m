Content-Type: multipart/mixed; boundary="===============1740214917904969251=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 06/14] dhcp-transport: add send_raw operation
Date: Thu, 15 Oct 2020 10:17:23 -0700
Message-ID: <20201015171731.396538-6-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1740214917904969251==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be used for DHCP server where send() will not
work due to the client not yet having an IP.

The implementation was ported from connman:
<connman>/gdhcp/common.c: dhcp_send_raw_packet()
---
 ell/dhcp-private.h   |  7 +++++
 ell/dhcp-transport.c | 72 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index bd2f01f..2b8e940 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -100,6 +100,13 @@ struct dhcp_transport {
 	int (*send)(struct dhcp_transport *transport,
 					const struct sockaddr_in *dest,
 					const void *data, size_t len);
+	int (*send_raw)(struct dhcp_transport *s,
+					uint32_t source_ip,
+					int source_port,
+					uint32_t dest_ip,
+					int dest_port,
+					const uint8_t *dest_arp,
+					void *data, size_t len);
 	void (*close)(struct dhcp_transport *transport);
 	uint32_t ifindex;
 	dhcp_transport_rx_cb_t rx_cb;
diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 13e9953..5c2a31d 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -472,6 +472,77 @@ static void _dhcp_default_transport_close(struct dhcp_=
transport *s)
 	}
 }
 =

+#define EXTEND_FOR_BUGGY_SERVERS 80
+
+static int _dhcp_default_transport_send_raw(struct dhcp_transport *s,
+						uint32_t source_ip,
+						int source_port,
+						uint32_t dest_ip,
+						int dest_port,
+						const uint8_t *dest_arp,
+						void *data, size_t len)
+{
+	struct sockaddr_ll dest;
+	size_t alloc_len =3D sizeof(struct dhcp_packet) -
+					sizeof(struct dhcp_message) + len;
+	L_AUTO_FREE_VAR(struct dhcp_packet *, packet);
+	int fd;
+	int n;
+
+	enum {
+		IP_UPD_DHCP_SIZE =3D sizeof(struct dhcp_packet) -
+						EXTEND_FOR_BUGGY_SERVERS,
+		UPD_DHCP_SIZE =3D IP_UPD_DHCP_SIZE -
+				offsetof(struct dhcp_packet, udp),
+	};
+
+	packet =3D (struct dhcp_packet *)l_new(uint8_t, alloc_len);
+
+	fd =3D socket(PF_PACKET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (fd < 0)
+		return -errno;
+
+	memset(&dest, 0, sizeof(dest));
+
+	memcpy(&packet->dhcp, data, len);
+
+	dest.sll_family =3D AF_PACKET;
+	dest.sll_protocol =3D htons(ETH_P_IP);
+	dest.sll_ifindex =3D s->ifindex;
+	dest.sll_halen =3D 6;
+	memcpy(dest.sll_addr, dest_arp, 6);
+
+	if (bind(fd, (struct sockaddr *)&dest, sizeof(dest)) < 0) {
+		close(fd);
+		return -errno;
+	}
+
+	packet->ip.protocol =3D IPPROTO_UDP;
+	packet->ip.saddr =3D source_ip;
+	packet->ip.daddr =3D dest_ip;
+	packet->udp.source =3D htons(source_port);
+	packet->udp.dest =3D htons(dest_port);
+	packet->udp.len =3D htons(UPD_DHCP_SIZE);
+	packet->ip.tot_len =3D packet->udp.len;
+	packet->udp.check =3D _dhcp_checksum(packet, IP_UPD_DHCP_SIZE);
+	packet->ip.tot_len =3D htons(IP_UPD_DHCP_SIZE);
+	packet->ip.ihl =3D sizeof(packet->ip) >> 2;
+	packet->ip.version =3D IPVERSION;
+	packet->ip.ttl =3D IPDEFTTL;
+	packet->ip.check =3D _dhcp_checksum(&packet->ip, sizeof(packet->ip));
+
+	n =3D sendto(fd, packet, alloc_len, 0, (struct sockaddr *) &dest,
+			sizeof(dest));
+	if (n < 0) {
+		close(fd);
+		return n;
+	}
+
+	close(fd);
+
+	return 0;
+}
+
 struct dhcp_transport *_dhcp_default_transport_new(uint32_t ifindex,
 							const char *ifname,
 							uint16_t port)
@@ -484,6 +555,7 @@ struct dhcp_transport *_dhcp_default_transport_new(uint=
32_t ifindex,
 	transport->super.close =3D _dhcp_default_transport_close;
 	transport->super.send =3D _dhcp_default_transport_send;
 	transport->super.broadcast =3D _dhcp_default_transport_broadcast;
+	transport->super.send_raw =3D _dhcp_default_transport_send_raw;
 =

 	transport->super.ifindex =3D ifindex;
 	l_strlcpy(transport->ifname, ifname, IFNAMSIZ);
-- =

2.26.2

--===============1740214917904969251==--

