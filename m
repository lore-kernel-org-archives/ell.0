Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 537B94C7C
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:15 +0000 (UTC)
Received: by mail-wr1-f43.google.com with SMTP id g3so26640419wrq.13
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=SF2WDjAspdgiG2bVwk0/aRVX3/lQbIhweVUga6gjKNs=;
        b=KrTmnmcdKfM5A3KKocX9OCS5JiVEfOSBDhvQveTtBAzUaRMrkYrzPagCBnNJoBAquf
         zVYfWCmHUpnfm9+f26VDzM2MYDid7wkPsXIXpltXdU3FQKi7VLffPqx82N+AuOZI6xd2
         HqZyB0TeNDnZ0HDhufjRIIhnR4ec8OXt6RkHssLQ9vuz+JmPwEoKnP8fXNN5WAmUCpcq
         sE50+ZVVo91UhMuXvJ/ICggN7oewF9P7Ba6OHVLs9jf1sePLtrlQPfjFw6sdfZircb/b
         oTCdpsuxz6DkvGwsKnzwC7CluePb34sArryc58dEi7p6SHrdIl9eALrZLNcYDtopvW77
         HVJQ==
X-Gm-Message-State: ACrzQf2k0tUIVbT4l4VAB34ndBKLLhAKG/lT3XxTj2oL3kiw1QOReCRt
	ztCqoq49Nj/zRICaQQkPC7fWMoKhXW6iuA==
X-Google-Smtp-Source: AMsMyM6zP62rzFfCz+zq+83U6Idk+Ni6WWaOdTk6p98EL8oafLy/g6zGPXoCVfWmKaXU5D2OGJvGbw==
X-Received: by 2002:a5d:6d0e:0:b0:22a:7bb2:14ae with SMTP id e14-20020a5d6d0e000000b0022a7bb214aemr11376651wrq.379.1663594273216;
        Mon, 19 Sep 2022 06:31:13 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.12
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:12 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 5/7] netconfig: Decouple icmp6 start from dhcp6 start
Date: Mon, 19 Sep 2022 15:31:03 +0200
Message-Id: <20220919133105.3129080-5-andrew.zaborowski@intel.com>
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

In preparation for supporting generating SLAAC addresses, start the
l_icmp6_client directly from the netconfig state machine.
l_dhcp6_client still takes care of creating and destroying
l_icmp6_client because it needs it for its own public API, but netconfig
starts/stops/handles events locally.  This also allows a slight
optimization described in RFC4862 where if we're lucky, we will
send the Router Solicitation simultaneously with the Neighbor
Solicitation for the link-local addresses so as to avoid waiting the sum
of the RA response time + DAD timeout and instead wait the longer of the
two periods.
---
 ell/dhcp6.c     |   3 ++
 ell/netconfig.c | 102 ++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 93 insertions(+), 12 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 15b451d..e234eb0 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1473,6 +1473,9 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_client *icmp6,
 {
 	struct l_dhcp6_client *client = user_data;
 
+	if (client->nora)
+		return;
+
 	switch (event) {
 	case L_ICMP6_CLIENT_EVENT_ROUTER_FOUND:
 	{
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 72c67a9..3ac0319 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -24,12 +24,13 @@
 #include <config.h>
 #endif
 
+#include <net/if.h>
 #include <linux/types.h>
 #include <linux/if_ether.h>
+#include <linux/if_arp.h>
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <netinet/icmp6.h>
-#include <net/if.h>
 #include <errno.h>
 #include <sys/types.h>
 #include <sys/stat.h>
@@ -56,6 +57,7 @@
 #include "net.h"
 #include "net-private.h"
 #include "acd.h"
+#include "timeout.h"
 #include "netconfig.h"
 
 struct l_netconfig {
@@ -87,6 +89,8 @@ struct l_netconfig {
 	struct l_queue *icmp_route_data;
 	struct l_acd *acd;
 	unsigned int orig_disable_ipv6;
+	uint8_t mac[ETH_ALEN];
+	struct l_timeout *ra_timeout;
 
 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -665,6 +669,35 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 	}
 }
 
+static bool netconfig_match(const void *a, const void *b)
+{
+	return a == b;
+}
+
+static bool netconfig_check_start_dhcp6(struct l_netconfig *nc)
+{
+	/* Don't start DHCPv6 until we get an RA with the managed bit set */
+	if (nc->ra_timeout)
+		return true;
+
+	/* Don't start DHCPv6 while waiting for the link-local address */
+	if (l_queue_find(addr_wait_list, netconfig_match, nc))
+		return true;
+
+	return l_dhcp6_client_start(nc->dhcp6_client);
+}
+
+static void netconfig_ra_timeout_cb(struct l_timeout *timeout, void *user_data)
+{
+	struct l_netconfig *nc = user_data;
+
+	l_timeout_remove(l_steal_ptr(nc->ra_timeout));
+
+	/* No Router Advertisements received, assume no DHCPv6 or SLAAC */
+	l_icmp6_client_stop(nc->icmp6_client);
+	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+}
+
 static uint64_t now;
 
 static bool netconfig_check_route_expired(void *data, void *user_data)
@@ -883,23 +916,23 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 	const struct l_icmp6_router *r;
 	struct netconfig_route_data *default_rd;
 	unsigned int i;
+	bool first_ra = false;
 
 	if (event != L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
 		return;
 
 	r = event_data;
 
-	/*
-	 * Note: If this is the first RA received, the l_dhcp6_client
-	 * will have received the event before us and will be acting
-	 * on it by now.
-	 */
-
-	if (nc->v6_gateway_override)
-		return;
+	if (nc->ra_timeout) {
+		first_ra = true;
+		l_timeout_remove(l_steal_ptr(nc->ra_timeout));
+	}
 
 	netconfig_expire_routes(nc);
 
+	if (nc->v6_gateway_override)
+		goto process_nondefault_routes;
+
 	/* Process the default gateway information */
 	default_rd = netconfig_find_icmp6_route(nc, r->address, NULL);
 
@@ -922,6 +955,7 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 	else if (default_rd && !r->lifetime)
 		netconfig_remove_icmp6_route(nc, default_rd);
 
+process_nondefault_routes:
 	/*
 	 * Process the onlink and offlink routes, from the Router
 	 * Advertisement's Prefix Information options and Route
@@ -950,6 +984,16 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 			netconfig_remove_icmp6_route(nc, rd);
 	}
 
+	/* See if we should start DHCPv6 now */
+	if (first_ra) {
+		if (!l_icmp6_router_get_managed(r) ||
+				!netconfig_check_start_dhcp6(nc)) {
+			netconfig_emit_event(nc, AF_INET6,
+						L_NETCONFIG_EVENT_FAILED);
+			return;
+		}
+	}
+
 	/*
 	 * Note: we may be emitting this before L_NETCONFIG_EVENT_CONFIGURE.
 	 * We should probably instead save the affected routes in separate
@@ -1046,6 +1090,7 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 					nc, NULL);
 
 	nc->dhcp6_client = l_dhcp6_client_new(ifindex);
+	l_dhcp6_client_set_nora(nc->dhcp6_client, true);
 	l_dhcp6_client_set_event_handler(nc->dhcp6_client,
 					netconfig_dhcp6_event_handler,
 					nc, NULL);
@@ -1535,10 +1580,10 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 	l_icmp6_client_set_link_local_address(nc->icmp6_client, ip);
 
 	/*
-	 * Only now that we have a link-local address start actual DHCPv6
-	 * setup.
+	 * Only now that we have a link-local address see if we can start
+	 * actual DHCPv6 setup.
 	 */
-	if (l_dhcp6_client_start(nc->dhcp6_client))
+	if (netconfig_check_start_dhcp6(nc))
 		return;
 
 	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
@@ -1687,6 +1732,35 @@ configure_ipv6:
 
 	l_queue_push_tail(addr_wait_list, netconfig);
 
+	if (!l_net_get_mac_address(netconfig->ifindex, netconfig->mac))
+		goto unregister;
+
+	l_dhcp6_client_set_address(netconfig->dhcp6_client, ARPHRD_ETHER,
+					netconfig->mac, ETH_ALEN);
+	l_icmp6_client_set_address(netconfig->icmp6_client, netconfig->mac);
+
+	/*
+	 * RFC4862 Section 4: "To speed the autoconfiguration process, a host
+	 * may generate its link-local address (and verify its uniqueness) in
+	 * parallel with waiting for a Router Advertisement.  Because a router
+	 * may delay responding to a Router Solicitation for a few seconds,
+	 * the total time needed to complete autoconfiguration can be
+	 * significantly longer if the two steps are done serially."
+	 *
+	 * We don't know whether we have the LL address yet.  The interface
+	 * may have been just brought up and DAD may still running or the LL
+	 * address may have been deleted and won't be added until
+	 * netconfig_ifaddr_ipv6_dump_done_cb() writes the /proc settings.
+	 * In any case the Router Solicitation doesn't depend on having the
+	 * LL address so send it now.  We won't start DHCPv6 however until we
+	 * have both the LL address and the Router Advertisement.
+	 */
+	if (!l_icmp6_client_start(netconfig->icmp6_client))
+		goto unregister;
+
+	netconfig->ra_timeout = l_timeout_create(10, netconfig_ra_timeout_cb,
+							netconfig, NULL);
+
 done:
 	netconfig->started = true;
 	return true;
@@ -1717,6 +1791,9 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 	if (netconfig->signal_expired_work)
 		l_idle_remove(l_steal_ptr(netconfig->signal_expired_work));
 
+	if (netconfig->ra_timeout)
+		l_timeout_remove(l_steal_ptr(netconfig->ra_timeout));
+
 	netconfig_addr_wait_unregister(netconfig, false);
 
 	netconfig_update_cleanup(netconfig);
@@ -1734,6 +1811,7 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 
 	l_dhcp_client_stop(netconfig->dhcp_client);
 	l_dhcp6_client_stop(netconfig->dhcp6_client);
+	l_icmp6_client_stop(netconfig->icmp6_client);
 
 	l_acd_destroy(l_steal_ptr(netconfig->acd));
 
-- 
2.34.1

