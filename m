Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D63E14C79
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:13 +0000 (UTC)
Received: by mail-wr1-f53.google.com with SMTP id n10so16952285wrw.12
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=H7jxvWWBX6+C16MQTakbhla6Q7eS935FTbw2fTJrUUw=;
        b=zhgbtR6lDhh0hF9AZlWx+aCl4MNQZOawWh3XdlPjFdNt3vn4qM/h9RXsC8tpFO/3u2
         QB6XJ0wEc8K1F6uLt0nnrgm9tguSDwy/zrinwYBcWlYcj84rGHlbfZPTdioAwYFegp6v
         UK+nrbTdMTZFe44/RbE7nz28ucvcL1K5NqohomPBnCu9Ov2TFpiLi6a6v1LQ8IZoj4v5
         pfttU5X7ZrG+K/veVAoRyYcnQMOnwyq4/1y3yA3TTm0ANoIxLfUPNVg6UG2d+pPZhpM2
         QvXJUkZXjooiJWJ6+636otVUM1fQ1LJqwNDsA5jrqKRVDFweZuqDP9oWkn6PvMp2rKQV
         RFVg==
X-Gm-Message-State: ACrzQf0e3rpMyN7GOIHmJFdshVsUnGYIYhhU9g2uZbF/VrdvhFX7CgkS
	Cg7scUhLjWXUb6ZBRFFd/0VhFKfL7YmBNQ==
X-Google-Smtp-Source: AMsMyM4XajttosKGb1eqDM5cV8y97KsTYa4gOnVsu2CT5Tf725zm2MIrehWAAB7CeaD+7r6Br2kr6A==
X-Received: by 2002:a5d:64ee:0:b0:226:db9b:e381 with SMTP id g14-20020a5d64ee000000b00226db9be381mr11185956wri.52.1663594271547;
        Mon, 19 Sep 2022 06:31:11 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.10
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:10 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/7] icmp6: Switch socket from AF_INET6 to AF_PACKET
Date: Mon, 19 Sep 2022 15:31:01 +0200
Message-Id: <20220919133105.3129080-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220919133105.3129080-1-andrew.zaborowski@intel.com>
References: <20220919133105.3129080-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In order to be able to send our Router Solicitations before the
interface has a confirmed link-local address we have to be able to
supply our own IPv6 header and skip source address selection and routing
in the kernel.  It is at least tricky to do with an AF_INET6 raw socket
as some socket features, like SO_DONTROUTE/MSG_DONTROUTE, are not
supported and others don't suppress the source address selection/checks.
Additionally since we need to use the IPv6 unspecified address, which is
represented as all 0 bytes, some syscalls interpret it as no value
supplied.

Build/parse the IPv6 header on our own and send/receive using an
AF_PACKET socket.

Once we have the link-local address, we switch to sending from that
address.  Add l_icmp6_client_set_link_local_address for the user to give
it to us as they're likely to need it for DHCPv6.
---
 ell/dhcp6.c     |   3 +
 ell/ell.sym     |   1 +
 ell/icmp6.c     | 324 ++++++++++++++++++++++++++++++------------------
 ell/icmp6.h     |   2 +
 ell/netconfig.c |   1 +
 5 files changed, 213 insertions(+), 118 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 01d7eb3..15b451d 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1619,6 +1619,9 @@ LIB_EXPORT bool l_dhcp6_client_set_link_local_address(
 	if (inet_pton(AF_INET6, ll, &client->ll_address) != 1)
 		return false;
 
+	if (!client->nora)
+		l_icmp6_client_set_link_local_address(client->icmp6, ll);
+
 	return true;
 }
 
diff --git a/ell/ell.sym b/ell/ell.sym
index ed66352..a28eb55 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -703,6 +703,7 @@ global:
 	l_icmp6_client_set_nodelay;
 	l_icmp6_client_set_rtnl;
 	l_icmp6_client_set_route_priority;
+	l_icmp6_client_set_link_local_address;
 	l_icmp6_router_get_address;
 	l_icmp6_router_get_managed;
 	l_icmp6_router_get_other;
diff --git a/ell/icmp6.c b/ell/icmp6.c
index c38df17..a2765ea 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -24,6 +24,7 @@
 #include <config.h>
 #endif
 
+#define _GNU_SOURCE
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -31,12 +32,16 @@
 #include <netinet/icmp6.h>
 #include <linux/ipv6.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_packet.h>
+#include <linux/filter.h>
 #include <sys/types.h>
 #include <sys/ioctl.h>
 #include <net/if.h>
+#include <net/ethernet.h>
 #include <unistd.h>
 #include <errno.h>
 #include <sys/time.h>
+#include <stddef.h>
 
 #include "private.h"
 #include "useful.h"
@@ -75,135 +80,186 @@
 			{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
 #define IN6ADDR_LINKLOCAL_ALLROUTERS_INIT \
 			{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+#define LLADDR_LINKLOCAL_ALLNODES_INIT	\
+			{ 0x33,0x33,0,0,0,1 }
+#define LLADDR_LINKLOCAL_ALLROUTERS_INIT \
+			{ 0x33,0x33,0,0,0,2 }
 
-static const struct in6_addr in6addr_linklocal_allnodes_init =
-					IN6ADDR_LINKLOCAL_ALLNODES_INIT;
-
-static int add_mreq(int s, int ifindex, const struct in6_addr *mc_addr)
-{
-	struct ipv6_mreq mreq = {
-		.ipv6mr_interface = ifindex,
-		.ipv6mr_multiaddr = *mc_addr,
-	};
-
-	return setsockopt(s, IPPROTO_IPV6,
-				IPV6_JOIN_GROUP, &mreq, sizeof(mreq));
-}
-
-static int icmp6_open_router_common(const struct icmp6_filter *filter,
-					int ifindex)
+static int icmp6_open_router_solicitation(int ifindex)
 {
 	int s;
-	int r;
-	int yes = 1;
-	int no = 0;
-	int nhops = 255;
+	struct sockaddr_ll addr;
+	struct sock_filter filter[] = {
+		/* A <- packet length */
+		BPF_STMT(BPF_LD | BPF_W | BPF_LEN, 0),
+		/* A >= sizeof(nd_router_advert) ? */
+		BPF_JUMP(BPF_JMP | BPF_JGE | BPF_K, sizeof(struct ip6_hdr) +
+				sizeof(struct nd_router_advert), 1, 0),
+		/* ignore */
+		BPF_STMT(BPF_RET | BPF_K, 0),
+		/* A <- IP version + Traffic class */
+		BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 0),
+		/* A <- A & 0xf0 (Mask off version) */
+		BPF_STMT(BPF_ALU | BPF_AND | BPF_K, 0xf0),
+		/* A == IPv6 ? */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 6 << 4, 1, 0),
+		/* ignore */
+		BPF_STMT(BPF_RET | BPF_K, 0),
+		/* A <- Next Header */
+		BPF_STMT(BPF_LD | BPF_B | BPF_ABS,
+				offsetof(struct ip6_hdr, ip6_nxt)),
+		/* A == ICMPv6 ? */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, IPPROTO_ICMPV6, 1, 0),
+		/* ignore */
+		BPF_STMT(BPF_RET | BPF_K, 0),
+		/* A <- ICMPv6 Type */
+		BPF_STMT(BPF_LD | BPF_B | BPF_ABS, sizeof(struct ip6_hdr) +
+				offsetof(struct icmp6_hdr, icmp6_type)),
+		/* A == Router Advertisement ? */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, ND_ROUTER_ADVERT, 1, 0),
+		/* ignore */
+		BPF_STMT(BPF_RET | BPF_K, 0),
+		/* A <- Payload Length */
+		BPF_STMT(BPF_LD | BPF_H | BPF_ABS,
+				offsetof(struct ip6_hdr, ip6_plen)),
+		/* A >= sizeof(nd_router_advert) ? */
+		BPF_JUMP(BPF_JMP | BPF_JGE | BPF_K,
+				sizeof(struct nd_router_advert), 1, 0),
+		/* ignore */
+		BPF_STMT(BPF_RET | BPF_K, 0),
+		/* return all */
+		BPF_STMT(BPF_RET | BPF_K, 65535),
+	};
+	const struct sock_fprog fprog = {
+		.len = L_ARRAY_SIZE(filter),
+		.filter = filter
+	};
+	int one = 1;
 
-	s = socket(AF_INET6, SOCK_RAW | SOCK_CLOEXEC, IPPROTO_ICMPV6);
+	s = socket(AF_PACKET, SOCK_DGRAM | SOCK_CLOEXEC, htons(ETH_P_IPV6));
 	if (s < 0)
 		return -errno;
 
-	r = setsockopt(s, IPPROTO_ICMPV6,
-			ICMP6_FILTER, filter, sizeof(struct icmp6_filter));
-	if (r < 0)
-		goto fail;
-
-	r = setsockopt(s, IPPROTO_IPV6, IPV6_MULTICAST_LOOP, &no, sizeof(no));
-	if (r < 0)
-		goto fail;
-
-	r = setsockopt(s, IPPROTO_IPV6,
-				IPV6_MULTICAST_IF, &ifindex, sizeof(ifindex));
-	if (r < 0)
-		goto fail;
+	if (setsockopt(s, SOL_SOCKET, SO_ATTACH_FILTER,
+						&fprog, sizeof(fprog)) < 0)
+		goto error;
 
-	r = setsockopt(s, IPPROTO_IPV6,
-				IPV6_RECVHOPLIMIT, &yes, sizeof(yes));
-	if (r < 0)
-		goto fail;
+	if (setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &one, sizeof(one)) < 0)
+		goto error;
 
-	r = setsockopt(s, IPPROTO_IPV6, IPV6_MULTICAST_HOPS,
-							&nhops, sizeof(nhops));
-	if (r < 0)
-		goto fail;
+	memset(&addr, 0, sizeof(addr));
+	addr.sll_family = AF_PACKET;
+	addr.sll_protocol = htons(ETH_P_IPV6);
+	addr.sll_ifindex = ifindex;
 
-	r = setsockopt(s, SOL_SOCKET, SO_BINDTOIFINDEX,
-						&ifindex, sizeof(ifindex));
-	if (r < 0 && errno == ENOPROTOOPT) {
-		struct ifreq ifr = {
-			.ifr_ifindex = ifindex,
-		};
-
-		r = ioctl(s, SIOCGIFNAME, &ifr);
-		if (r < 0)
-			goto fail;
-
-		r = setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE,
-				ifr.ifr_name, strlen(ifr.ifr_name) + 1);
-	}
-
-	if (r < 0)
-		goto fail;
-
-	r = setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &yes, sizeof(yes));
-	if (r < 0)
-		goto fail;
+	if (bind(s, (struct sockaddr *) &addr, sizeof(addr)) < 0)
+		goto error;
 
 	return s;
 
-fail:
-	close(s);
+error:
+	L_TFR(close(s));
 	return -errno;
 }
 
-static int icmp6_open_router_solicitation(int ifindex)
+static uint16_t icmp6_checksum(const struct iovec *iov, unsigned int iov_len)
 {
-	struct icmp6_filter filter;
-	int s;
-	int r;
+	const struct ip6_hdr *ip_hdr = iov[0].iov_base;
+	uint32_t sum = 0;
+	const uint16_t *ptr;
+	const uint16_t *buf_end;
+	/* Skip the real IPv6 header */
+	unsigned int buf_offset = sizeof(struct ip6_hdr);
 
-	ICMP6_FILTER_SETBLOCKALL(&filter);
-	ICMP6_FILTER_SETPASS(ND_ROUTER_ADVERT, &filter);
+	/*
+	 * ICMPv6 checksum according to RFC 4443 Section 2.3, this includes
+	 * the IPv6 payload + the IPv6 pseudo-header according to RFC 2460
+	 * Section 8.1, i.e. the two IPv6 addresses + the payload length +
+	 * the header type.  The caller must ensure that the IPv6 header is
+	 * all in one buffer and that all buffer starts and lengths are
+	 * 16-bit-aligned.
+	 *
+	 * We can skip all zero words such as the upper 16 bits of the
+	 * payload length.  No need to byteswap as the carry bits from
+	 * either byte (high or low) accumulate in the other byte in
+	 * exactly the same way.
+	 */
+	buf_end = (void *) &ip_hdr->ip6_src + 32;
+	for (ptr = (void *) &ip_hdr->ip6_src; ptr < buf_end; )
+		sum += *ptr++;
 
-	s = icmp6_open_router_common(&filter, ifindex);
-	if (s < 0)
-		return s;
+	sum += ip_hdr->ip6_plen + htons(ip_hdr->ip6_nxt);
 
-	r = add_mreq(s, ifindex, &in6addr_linklocal_allnodes_init);
-	if (r < 0) {
-		close(s);
-		return -errno;
+	for (; iov_len; iov++, iov_len--) {
+		buf_end = iov->iov_base + iov->iov_len;
+		for (ptr = iov->iov_base + buf_offset; ptr < buf_end; )
+			sum += *ptr++;
+
+		buf_offset = 0;
 	}
 
-	return s;
+	while (sum >> 16)
+		sum = (sum & 0xffff) + (sum >> 16);
+
+	return ~sum;
 }
 
-static int icmp6_send_router_solicitation(int s, const uint8_t mac[static 6])
+static int icmp6_send_router_solicitation(int s, int ifindex,
+					const uint8_t src_mac[static 6],
+					const struct in6_addr *src_ip)
 {
-	struct sockaddr_in6 dst = {
-		.sin6_family = AF_INET6,
-		.sin6_addr = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT,
-	};
 	struct nd_router_solicit rs = {
 		.nd_rs_type = ND_ROUTER_SOLICIT,
+		.nd_rs_code = 0,
 	};
-	struct nd_opt_hdr rs_opt = {
+	struct nd_opt_hdr rs_sllao = {
 		.nd_opt_type = ND_OPT_SOURCE_LINKADDR,
 		.nd_opt_len = 1,
 	};
-	struct iovec iov[3] = {
+	const size_t rs_sllao_size = sizeof(rs_sllao) + 6;
+	struct ip6_hdr ip_hdr = {
+		.ip6_flow = htonl(6 << 28),
+		.ip6_hops = 255,
+		.ip6_nxt = IPPROTO_ICMPV6,
+		.ip6_plen = htons(sizeof(rs) + rs_sllao_size),
+		.ip6_dst = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT,
+	};
+	struct iovec iov[4] = {
+		{ .iov_base = &ip_hdr, .iov_len = sizeof(ip_hdr) },
 		{ .iov_base = &rs, .iov_len = sizeof(rs) },
-		{ .iov_base = &rs_opt, .iov_len = sizeof(rs_opt) },
-		{ .iov_base = (void *) mac, .iov_len = 6 } };
-
+		{ .iov_base = &rs_sllao, .iov_len = sizeof(rs_sllao) },
+		{ .iov_base = (void *) src_mac, .iov_len = 6 } };
+
+	struct sockaddr_ll dst = {
+		.sll_family = AF_PACKET,
+		.sll_protocol = htons(ETH_P_IPV6),
+		.sll_ifindex = ifindex,
+		.sll_addr = LLADDR_LINKLOCAL_ALLROUTERS_INIT,
+		.sll_halen = 6,
+	};
 	struct msghdr msg = {
 		.msg_name = &dst,
 		.msg_namelen = sizeof(dst),
 		.msg_iov = iov,
-		.msg_iovlen = 3,
+		.msg_iovlen = L_ARRAY_SIZE(iov),
 	};
 	int r;
 
+	memcpy(&ip_hdr.ip6_src, src_ip, 16);
+
+	if (l_memeqzero(src_ip, 16)) {
+		/*
+		 * radvd will discard and warn about RSs from the unspecified
+		 * address with the SLLAO, omit that option by dropping the
+		 * last two iov buffers.
+		 */
+		msg.msg_iovlen -= 2;
+		ip_hdr.ip6_plen = htons(ntohs(ip_hdr.ip6_plen) - rs_sllao_size);
+	}
+
+	/* Don't byteswap the checksum */
+	rs.nd_rs_cksum = icmp6_checksum(msg.msg_iov, msg.msg_iovlen);
+
 	r = sendmsg(s, &msg, 0);
 	if (r < 0)
 		return -errno;
@@ -211,22 +267,23 @@ static int icmp6_send_router_solicitation(int s, const uint8_t mac[static 6])
 	return 0;
 }
 
-static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr *src,
-				uint64_t *out_timestamp)
+static int icmp6_receive(int s, void *buf, ssize_t *buf_len,
+				struct in6_addr *src, uint64_t *out_timestamp)
 {
 	char c_msg_buf[CMSG_SPACE(sizeof(int)) +
 			CMSG_SPACE(sizeof(struct timeval))];
-	struct iovec iov = {
-		.iov_base = buf,
-		.iov_len = buf_len,
+	struct ip6_hdr ip_hdr;
+	struct iovec iov[2] = {
+		{ .iov_base = &ip_hdr, .iov_len = sizeof(ip_hdr) },
+		{ .iov_base = buf, .iov_len = *buf_len - sizeof(ip_hdr) },
 	};
-	struct sockaddr_in6 saddr;
+	struct sockaddr_ll saddr;
 	struct msghdr msg = {
 		.msg_name = (void *)&saddr,
-		.msg_namelen = sizeof(struct sockaddr_in6),
+		.msg_namelen = sizeof(struct sockaddr_ll),
 		.msg_flags = 0,
-		.msg_iov = &iov,
-		.msg_iovlen = 1,
+		.msg_iov = iov,
+		.msg_iovlen = L_ARRAY_SIZE(iov),
 		.msg_control = c_msg_buf,
 		.msg_controllen = sizeof(c_msg_buf),
 	};
@@ -238,22 +295,30 @@ static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr *src,
 	if (l < 0)
 		return -errno;
 
-	if ((size_t) l != buf_len)
+	if (l != *buf_len)
 		return -EINVAL;
 
-	if (msg.msg_namelen != sizeof(struct sockaddr_in6) ||
-			saddr.sin6_family != AF_INET6)
-		return -EPFNOSUPPORT;
+	if (ntohs(ip_hdr.ip6_plen) > iov[1].iov_len)
+		return -EMSGSIZE;
+
+	iov[1].iov_len = ntohs(ip_hdr.ip6_plen);
+
+	/*
+	 * Unlikely but align length for icmp6_checksum().  We know we have
+	 * at least sizeof(struct ip6_hdr) extra bytes in buf so we can
+	 * append this 0 byte no problem.
+	 */
+	if (iov[1].iov_len & 1)
+		((uint8_t *) buf)[iov[1].iov_len++] = 0x00;
+
+	if (icmp6_checksum(iov, L_ARRAY_SIZE(iov)))
+		return -EBADMSG;
+
+	if (ip_hdr.ip6_hops != 255)
+		return -EMULTIHOP;
 
 	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
-		if (cmsg->cmsg_level == SOL_IPV6 &&
-				cmsg->cmsg_type == IPV6_HOPLIMIT &&
-				cmsg->cmsg_len == CMSG_LEN(sizeof(int))) {
-			int hops = l_get_u32(CMSG_DATA(cmsg));
-
-			if (hops != 255)
-				return -EMULTIHOP;
-		} else if (cmsg->cmsg_level == SOL_SOCKET &&
+		if (cmsg->cmsg_level == SOL_SOCKET &&
 				cmsg->cmsg_type == SCM_TIMESTAMP &&
 				cmsg->cmsg_len ==
 				CMSG_LEN(sizeof(struct timeval))) {
@@ -263,7 +328,8 @@ static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr *src,
 		}
 	}
 
-	memcpy(src, &saddr.sin6_addr, sizeof(saddr.sin6_addr));
+	*buf_len = ntohs(ip_hdr.ip6_plen);
+	memcpy(src, &ip_hdr.ip6_src, 16);
 	*out_timestamp = timestamp ?: l_time_now();
 	return 0;
 }
@@ -280,6 +346,7 @@ struct l_icmp6_client {
 	struct l_timeout *timeout_send;
 	uint64_t retransmit_time;
 	struct l_io *io;
+	struct in6_addr src_ip;
 
 	struct l_icmp6_router *ra;
 	struct l_netlink *rtnl;
@@ -432,12 +499,16 @@ static bool icmp6_client_read_handler(struct l_io *io, void *userdata)
 		return false;
 	}
 
-	ra = l_malloc(l);
-	if (icmp6_receive(s, ra, l, &src, &timestamp) < 0)
-		goto done;
+	if ((size_t) l < sizeof(struct ip6_hdr) +
+			sizeof(struct nd_router_advert)) {
+		CLIENT_DEBUG("Message too small - ignore");
+		return true;
+	}
 
-	if ((size_t) l < sizeof(struct nd_router_advert)) {
-		CLIENT_DEBUG("Message to small - ignore");
+	ra = l_malloc(l);
+	r = icmp6_receive(s, ra, &l, &src, &timestamp);
+	if (r < 0) {
+		CLIENT_DEBUG("icmp6_receive(): %s (%i)", strerror(-r), -r);
 		goto done;
 	}
 
@@ -475,7 +546,8 @@ static void icmp6_client_timeout_send(struct l_timeout *timeout,
 						SOLICITATION_INTERVAL);
 
 	r = icmp6_send_router_solicitation(l_io_get_fd(client->io),
-								client->mac);
+						client->ifindex, client->mac,
+						&client->src_ip);
 	if (r < 0) {
 		CLIENT_DEBUG("Error sending Router Solicitation: %s",
 				strerror(-r));
@@ -692,6 +764,22 @@ LIB_EXPORT bool l_icmp6_client_set_route_priority(
 	return true;
 }
 
+LIB_EXPORT bool l_icmp6_client_set_link_local_address(
+						struct l_icmp6_client *client,
+						const char *ll)
+{
+	if (unlikely(!client))
+		return false;
+
+	/*
+	 * client->src_ip is all 0s initially which results in our Router
+	 * Solicitations being sent from the IPv6 Unspecified Address, which
+	 * is fine.  Once we have a confirmed link-local address we use that
+	 * as the source address.
+	 */
+	return inet_pton(AF_INET6, ll, &client->src_ip) == 1;
+}
+
 struct l_icmp6_router *_icmp6_router_new()
 {
 	struct l_icmp6_router *r = l_new(struct l_icmp6_router, 1);
diff --git a/ell/icmp6.h b/ell/icmp6.h
index 615dba4..ffbb8a8 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -65,6 +65,8 @@ bool l_icmp6_client_set_rtnl(struct l_icmp6_client *client,
 						struct l_netlink *rtnl);
 bool l_icmp6_client_set_route_priority(struct l_icmp6_client *client,
 						uint32_t priority);
+bool l_icmp6_client_set_link_local_address(struct l_icmp6_client *client,
+						const char *ll);
 
 char *l_icmp6_router_get_address(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_managed(const struct l_icmp6_router *r);
diff --git a/ell/netconfig.c b/ell/netconfig.c
index bbe1dec..72c67a9 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1532,6 +1532,7 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 	netconfig_addr_wait_unregister(nc, true);
 
 	l_dhcp6_client_set_link_local_address(nc->dhcp6_client, ip);
+	l_icmp6_client_set_link_local_address(nc->icmp6_client, ip);
 
 	/*
 	 * Only now that we have a link-local address start actual DHCPv6
-- 
2.34.1

