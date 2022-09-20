Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C639F1C33
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:10 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id n10so4244818wrw.12
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=OtK7kWrHD4n3tNmGYWwa7daNLr6uxs5H43rd9QcxanI=;
        b=vGQOqiaTdeEtcvwxYmNR3XEq5rI4tRiwpap9AxsnnSQWuPlNWa0wf/9m3BtI2MM5sJ
         9vCo8t6k0s4dSrbanJEwLo66Z7VIjxL5GjsHqyu54l2eTkOKbyLudmTfJLUNBNLKcgPx
         BSh8e3L+UJ1TEkEv05vgt1wpgS7SAQakWNV7Z/Yr1DGDJVdzTYGobEN0V5+eh+3N0yNT
         BVlE/3B4gajUGQeJ6q1fZE7Gzw+B3N3mru3hnzbJWBtVTgnrwYmDtJKFadm5fX37Q7hN
         9AsC/GE1Blx9Outu9tZQMyzz6f+jLyclvuJK4iIYCE61PbVsBKQZYQt4iuu+Dl07RXkD
         g1Ug==
X-Gm-Message-State: ACrzQf1/sTX8OKWS2wXwpV0cOITfOhef+jMIQ6iTp0p/KpfZcORBDylY
	t3SwUauiP3D8dLWfy7ZJB+zJH+8lbcaF5NMt
X-Google-Smtp-Source: AMsMyM6CBHvdUSDPy6IW568ALo2xTTGW+xqNEJZIyPYiXMk26qWeCNdJcv5D2NL1lzZscX0u9p4wJA==
X-Received: by 2002:a5d:588f:0:b0:22a:fe0c:afb8 with SMTP id n15-20020a5d588f000000b0022afe0cafb8mr7011701wrf.431.1663680728675;
        Tue, 20 Sep 2022 06:32:08 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.07
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:08 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 5/6] icmp6,netconfig: Skip SLLAO if RS sent from optimistic address
Date: Tue, 20 Sep 2022 15:32:00 +0200
Message-Id: <20220920133201.3303119-5-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
References: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Make sure we don't include de Source Link-Local Address Option in our
Router Solicitations until the source link-local address completes DAD.
Extand the recently added l_icmp6_client_set_link_local_address() with a
parameter to tell us whether the address is optimistic.  Don't change
the l_dhcp6_client_set_link_local_address signature to avoid breaking
existing users.
---
 ell/dhcp6.c     |  2 +-
 ell/icmp6.c     | 29 +++++++++++++++++++++--------
 ell/icmp6.h     |  3 ++-
 ell/netconfig.c | 30 ++++++++++++++++++++++++++----
 4 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index e234eb0..2792ff2 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1623,7 +1623,7 @@ LIB_EXPORT bool l_dhcp6_client_set_link_local_address(
 		return false;
 
 	if (!client->nora)
-		l_icmp6_client_set_link_local_address(client->icmp6, ll);
+		l_icmp6_client_set_link_local_address(client->icmp6, ll, false);
 
 	return true;
 }
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 5ddc494..f087ba3 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -206,7 +206,8 @@ static uint16_t icmp6_checksum(const struct iovec *iov, unsigned int iov_len)
 
 static int icmp6_send_router_solicitation(int s, int ifindex,
 					const uint8_t src_mac[static 6],
-					const struct in6_addr *src_ip)
+					const struct in6_addr *src_ip,
+					bool src_ip_optimistic)
 {
 	struct nd_router_solicit rs = {
 		.nd_rs_type = ND_ROUTER_SOLICIT,
@@ -247,11 +248,17 @@ static int icmp6_send_router_solicitation(int s, int ifindex,
 
 	memcpy(&ip_hdr.ip6_src, src_ip, 16);
 
-	if (l_memeqzero(src_ip, 16)) {
+	if (l_memeqzero(src_ip, 16) || src_ip_optimistic) {
 		/*
-		 * radvd will discard and warn about RSs from the unspecified
-		 * address with the SLLAO, omit that option by dropping the
-		 * last two iov buffers.
+		 * RFC 4429 Section 3.2: "A node MUST NOT send a Router
+		 * Solicitation with a SLLAO from an Optimistic Address.
+		 * Router Solicitations SHOULD be sent from a non-Optimistic
+		 * or the Unspecified Address; however, they MAY be sent from
+		 * an Optimistic Address as long as the SLLAO is not included."
+		 *
+		 * Additionally radvd will also discard and warn about RSs
+		 * from the unspecified address with the SLLAO.  Omit that
+		 * option by dropping the last two iov buffers.
 		 */
 		msg.msg_iovlen -= 2;
 		ip_hdr.ip6_plen = htons(ntohs(ip_hdr.ip6_plen) - rs_sllao_size);
@@ -347,6 +354,7 @@ struct l_icmp6_client {
 	uint64_t retransmit_time;
 	struct l_io *io;
 	struct in6_addr src_ip;
+	bool src_ip_optimistic;
 
 	struct l_icmp6_router *ra;
 	struct l_netlink *rtnl;
@@ -547,7 +555,8 @@ static void icmp6_client_timeout_send(struct l_timeout *timeout,
 
 	r = icmp6_send_router_solicitation(l_io_get_fd(client->io),
 						client->ifindex, client->mac,
-						&client->src_ip);
+						&client->src_ip,
+						client->src_ip_optimistic);
 	if (r < 0) {
 		CLIENT_DEBUG("Error sending Router Solicitation: %s",
 				strerror(-r));
@@ -766,7 +775,7 @@ LIB_EXPORT bool l_icmp6_client_set_route_priority(
 
 LIB_EXPORT bool l_icmp6_client_set_link_local_address(
 						struct l_icmp6_client *client,
-						const char *ll)
+						const char *ll, bool optimistic)
 {
 	if (unlikely(!client))
 		return false;
@@ -777,7 +786,11 @@ LIB_EXPORT bool l_icmp6_client_set_link_local_address(
 	 * is fine.  Once we have a confirmed link-local address we use that
 	 * as the source address.
 	 */
-	return inet_pton(AF_INET6, ll, &client->src_ip) == 1;
+	if (inet_pton(AF_INET6, ll, &client->src_ip) != 1)
+		return false;
+
+	client->src_ip_optimistic = optimistic;
+	return true;
 }
 
 struct l_icmp6_router *_icmp6_router_new()
diff --git a/ell/icmp6.h b/ell/icmp6.h
index ffbb8a8..ad3d661 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -66,7 +66,8 @@ bool l_icmp6_client_set_rtnl(struct l_icmp6_client *client,
 bool l_icmp6_client_set_route_priority(struct l_icmp6_client *client,
 						uint32_t priority);
 bool l_icmp6_client_set_link_local_address(struct l_icmp6_client *client,
-						const char *ll);
+						const char *ll,
+						bool optimistic);
 
 char *l_icmp6_router_get_address(const struct l_icmp6_router *r);
 bool l_icmp6_router_get_managed(const struct l_icmp6_router *r);
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 765703b..c558cad 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -93,6 +93,7 @@ struct l_netconfig {
 	unsigned int orig_optimistic_dad;
 	uint8_t mac[ETH_ALEN];
 	struct l_timeout *ra_timeout;
+	bool have_lla;
 	enum {
 		NETCONFIG_V6_METHOD_UNSET,
 		NETCONFIG_V6_METHOD_DHCP,
@@ -702,7 +703,7 @@ static bool netconfig_check_start_dhcp6(struct l_netconfig *nc)
 		return true;
 
 	/* Don't start DHCPv6 while waiting for the link-local address */
-	if (l_queue_find(addr_wait_list, netconfig_match, nc))
+	if (!nc->have_lla)
 		return true;
 
 	return l_dhcp6_client_start(nc->dhcp6_client);
@@ -1844,6 +1845,7 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 {
 	struct in6_addr in6;
 	_auto_(l_free) char *ip = NULL;
+	bool new_lla;
 
 	if ((ifa->ifa_flags & IFA_F_TENTATIVE) &&
 			!(ifa->ifa_flags & IFA_F_OPTIMISTIC))
@@ -1858,16 +1860,28 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 	if (!IN6_IS_ADDR_LINKLOCAL(&in6))
 		return;
 
-	netconfig_addr_wait_unregister(nc, true);
+	new_lla = !nc->have_lla;
+	nc->have_lla = true;
+
+	if (!(ifa->ifa_flags & IFA_F_TENTATIVE))
+		netconfig_addr_wait_unregister(nc, true);
+	else if (nc->ifaddr6_dump_cmd_id) {
+		struct l_netlink *rtnl = l_rtnl_get();
+		unsigned int cmd_id = nc->ifaddr6_dump_cmd_id;
+
+		nc->ifaddr6_dump_cmd_id = 0;
+		l_netlink_cancel(rtnl, cmd_id);
+	}
 
 	l_dhcp6_client_set_link_local_address(nc->dhcp6_client, ip);
-	l_icmp6_client_set_link_local_address(nc->icmp6_client, ip);
+	l_icmp6_client_set_link_local_address(nc->icmp6_client, ip,
+					!!(ifa->ifa_flags & IFA_F_OPTIMISTIC));
 
 	/*
 	 * Only now that we have a link-local address see if we can start
 	 * actual DHCPv6 setup.
 	 */
-	if (netconfig_check_start_dhcp6(nc))
+	if (new_lla && netconfig_check_start_dhcp6(nc))
 		return;
 
 	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
@@ -2022,6 +2036,13 @@ configure_ipv6:
 	 * before we start the dump, instead of after it ends, to eliminate
 	 * the possibility of missing an RTM_NEWADDR between the end of
 	 * the dump command and registering for the events.
+	 *
+	 * We stay on that list until we receive a non-tentative LL address.
+	 * Note that we may set .have_lla earlier, specifically when we
+	 * receive a tentative LL address that is also optimistic.  We will
+	 * however stay on addr_wait_list because we want to notify
+	 * l_icmp6_client again when the LL address completes DAD and becomes
+	 * non-tentative.
 	 */
 	if (!addr_wait_list) {
 		addr_wait_list = l_queue_new();
@@ -2041,6 +2062,7 @@ configure_ipv6:
 		goto unregister;
 
 	l_queue_push_tail(addr_wait_list, netconfig);
+	netconfig->have_lla = false;
 
 	if (!l_net_get_mac_address(netconfig->ifindex, netconfig->mac))
 		goto unregister;
-- 
2.34.1

