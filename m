Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 446564C79
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:16 +0000 (UTC)
Received: by mail-wr1-f49.google.com with SMTP id c11so47521286wrp.11
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=4Z2wckLxQC+Mie9Xxz0mnDuGVXpXoSbzpsP1jMWy8VE=;
        b=CKzURSNKYsBW79XxbqRBA4sbofGzUREXWst9XCc0m9Z3/HUoLvXwWhAsbFxiukWPZH
         OgS67mOWdXl5JThiKkZFmO3xY/yW1v6oW9OAuh4Zb54NyIQl0I6hdu36qH7tIsSVLQLd
         GO7RC98lvs7+LTXDPTtq7kCe6Dkd/UxnFrKPVPcSX0cOx5DWsBzjghWLcMUpMQBNhDLY
         UIe3IN58ZYbLlY1+fFFAqy+R4x+GnxHZLJbSrQKCNFh5PeMSpHGbjQmumfobhiATZI7f
         6QI1XBO+PVpnioSF0GdgVoyp1Nvmc4E7Boinx6CWBumYUCxj8Lw3e2SFDYhVxHGkPKxv
         9i/g==
X-Gm-Message-State: ACrzQf087mGCjgB8EF6vENvUuAJnumJk4Jcujf/Nr/q3O9dFrPejttLa
	WGDmiL64YO0afPPBTvDL+np5HK/4gPJL4g==
X-Google-Smtp-Source: AMsMyM5uJrsoZcgg2DQyHWUMyQ65NgKAQVzT7kMM1MDzWFZk1kQYYgkBn1S+0g/DjZ8V/P5A42Eh5w==
X-Received: by 2002:a05:6000:1c1c:b0:228:de40:986f with SMTP id ba28-20020a0560001c1c00b00228de40986fmr11144201wrb.212.1663594274103;
        Mon, 19 Sep 2022 06:31:14 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.13
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:13 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 6/7] netconfig: Create SLAAC address
Date: Mon, 19 Sep 2022 15:31:04 +0200
Message-Id: <20220919133105.3129080-6-andrew.zaborowski@intel.com>
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

If the Router Advertisement doesn't indicate DHCPv6 is available and
includes prefixes for address auto-configuration, fall back to using
those to generate a single IPv6 address.  Other settings such as DNS
are not supported in this mode yet and there's no renewal timer for when
the address lifetime is finite.
---
 ell/netconfig.c | 184 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 174 insertions(+), 10 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 3ac0319..3336b30 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -91,6 +91,11 @@ struct l_netconfig {
 	unsigned int orig_disable_ipv6;
 	uint8_t mac[ETH_ALEN];
 	struct l_timeout *ra_timeout;
+	enum {
+		NETCONFIG_V6_METHOD_UNSET,
+		NETCONFIG_V6_METHOD_DHCP,
+		NETCONFIG_V6_METHOD_SLAAC,
+	} v6_auto_method;
 
 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -677,7 +682,7 @@ static bool netconfig_match(const void *a, const void *b)
 static bool netconfig_check_start_dhcp6(struct l_netconfig *nc)
 {
 	/* Don't start DHCPv6 until we get an RA with the managed bit set */
-	if (nc->ra_timeout)
+	if (nc->ra_timeout || nc->v6_auto_method != NETCONFIG_V6_METHOD_DHCP)
 		return true;
 
 	/* Don't start DHCPv6 while waiting for the link-local address */
@@ -698,6 +703,109 @@ static void netconfig_ra_timeout_cb(struct l_timeout *timeout, void *user_data)
 	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
 }
 
+static void netconfig_add_slaac_address(struct l_netconfig *nc,
+					const struct l_icmp6_router *r)
+{
+	unsigned int i;
+	const struct autoconf_prefix_info *longest = &r->ac_prefixes[0];
+	uint8_t addr[16];
+	char addr_str[INET6_ADDRSTRLEN];
+	uint32_t p, v;
+
+	/* Find the autoconfiguration prefix that offers the longest lifetime */
+	for (i = 1; i < r->n_ac_prefixes; i++)
+		if (r->ac_prefixes[i].preferred_lifetime >
+				longest->preferred_lifetime)
+			longest = &r->ac_prefixes[i];
+
+	memcpy(addr, longest->prefix, 8);
+	/* EUI-64-based Interface Identifier (RFC2464 Section 4) */
+	addr[ 8] = nc->mac[0] ^ 0x02;
+	addr[ 9] = nc->mac[1];
+	addr[10] = nc->mac[2];
+	addr[11] = 0xff;
+	addr[12] = 0xfe;
+	addr[13] = nc->mac[3];
+	addr[14] = nc->mac[4];
+	addr[15] = nc->mac[5];
+	inet_ntop(AF_INET6, addr, addr_str, sizeof(addr_str));
+	p = longest->preferred_lifetime;
+	v = longest->valid_lifetime;
+
+	nc->v6_address = l_rtnl_address_new(addr_str, 128);
+	l_rtnl_address_set_noprefixroute(nc->v6_address, true);
+
+	if (p != 0xffffffff || v != 0xffffffff) {
+		l_rtnl_address_set_lifetimes(nc->v6_address,
+					p != 0xffffffff ? p : 0,
+					v != 0xffffffff ? v : 0);
+		l_rtnl_address_set_expiry(nc->v6_address,
+					p != 0xffffffff ?
+					r->start_time + p * L_USEC_PER_SEC : 0,
+					v != 0xffffffff ?
+					r->start_time + v * L_USEC_PER_SEC : 0);
+	}
+
+	l_queue_push_tail(nc->addresses.current, nc->v6_address);
+	l_queue_push_tail(nc->addresses.added, nc->v6_address);
+	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
+
+	/* TODO: set a renew timeout */
+}
+
+static void netconfig_set_slaac_address_lifetimes(struct l_netconfig *nc,
+						const struct l_icmp6_router *r)
+{
+	const uint8_t *addr = l_rtnl_address_get_in_addr(nc->v6_address);
+	bool updated = false;
+	uint64_t p_expiry;
+	uint64_t v_expiry;
+	uint32_t remaining = 0xffffffff;
+	unsigned int i;
+
+	if (L_WARN_ON(!addr))
+		return;
+
+	l_rtnl_address_get_expiry(nc->v6_address, &p_expiry, &v_expiry);
+
+	if (v_expiry)
+		remaining = (v_expiry - r->start_time) / L_USEC_PER_SEC;
+
+	for (i = 0; i < r->n_ac_prefixes; i++) {
+		const struct autoconf_prefix_info *prefix = &r->ac_prefixes[i];
+		uint32_t p = prefix->preferred_lifetime;
+		uint32_t v = prefix->valid_lifetime;
+
+		if (memcmp(prefix->prefix, addr, 8))
+			continue;
+
+		/* RFC4862 Section 5.5.3 e) */
+		if (v < 120 * 60 && v < remaining)
+			v = 120 * 60; /* 2 hours */
+
+		l_rtnl_address_set_lifetimes(nc->v6_address,
+						p != 0xffffffff ? p : 0,
+						v != 0xffffffff ? v : 0);
+		p_expiry = p != 0xffffffff ? r->start_time + p * L_USEC_PER_SEC : 0;
+		v_expiry = v != 0xffffffff ? r->start_time + v * L_USEC_PER_SEC : 0;
+		l_rtnl_address_set_expiry(nc->v6_address, p_expiry, v_expiry);
+		updated = true;
+
+		/*
+		 * TODO: modify the renew timeout.
+		 *
+		 * Also we probably want to apply a mechanism similar to that
+		 * in netconfig_check_route_need_update() to avoid generating
+		 * and UPDATED event for every RA that covers this prefix
+		 * with constant lifetime values.
+		 */
+	}
+
+	if (updated && !l_queue_find(nc->addresses.added, netconfig_match,
+					nc->v6_address))
+		l_queue_push_tail(nc->addresses.updated, nc->v6_address);
+}
+
 static uint64_t now;
 
 static bool netconfig_check_route_expired(void *data, void *user_data)
@@ -916,17 +1024,14 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 	const struct l_icmp6_router *r;
 	struct netconfig_route_data *default_rd;
 	unsigned int i;
-	bool first_ra = false;
 
 	if (event != L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
 		return;
 
 	r = event_data;
 
-	if (nc->ra_timeout) {
-		first_ra = true;
+	if (nc->ra_timeout)
 		l_timeout_remove(l_steal_ptr(nc->ra_timeout));
-	}
 
 	netconfig_expire_routes(nc);
 
@@ -984,16 +1089,72 @@ process_nondefault_routes:
 			netconfig_remove_icmp6_route(nc, rd);
 	}
 
-	/* See if we should start DHCPv6 now */
-	if (first_ra) {
-		if (!l_icmp6_router_get_managed(r) ||
-				!netconfig_check_start_dhcp6(nc)) {
+	/*
+	 * For lack of a better policy, select between DHCPv6 and SLAAC based
+	 * on the first RA received.  Prefer DHCPv6.
+	 *
+	 * Just like we currently only request one address in l_dhcp6_client,
+	 * we only set up one address using SLAAC regardless of how many
+	 * prefixes are available.  Generate the address in the prefix that
+	 * offers the longest preferred_lifetime.
+	 */
+	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET &&
+			l_icmp6_router_get_managed(r)) {
+		nc->v6_auto_method = NETCONFIG_V6_METHOD_DHCP;
+
+		if (!netconfig_check_start_dhcp6(nc)) {
 			netconfig_emit_event(nc, AF_INET6,
 						L_NETCONFIG_EVENT_FAILED);
 			return;
 		}
+
+		goto emit_event;
+	}
+
+	/*
+	 * DHCP not available according to this router, check if any of the
+	 * prefixes allow SLAAC.
+	 */
+	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET &&
+			r->n_ac_prefixes) {
+		nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC;
+
+		/*
+		 * The DAD for the link-local address may be still running
+		 * but again we can generate the global address already and
+		 * commit it to start in-kernel DAD for it.
+		 *
+		 * The global address alone should work for most uses.  On
+		 * the other hand since both the link-local address and the
+		 * global address are based on the same MAC, there's some
+		 * correlation between one failing DAD and the other
+		 * failing DAD due to another host using the same address.
+		 * As RFC4862 Section 5.4 notes we can't rely on that to
+		 * skip DAD for one of the addresses.
+		 */
+
+		netconfig_add_slaac_address(nc, r);
+		return;
 	}
 
+	/* Neither method seems available, fail */
+	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET) {
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+		return;
+	}
+
+	/* DHCP already started or waiting for the LL address, nothing to do */
+	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_DHCP)
+		goto emit_event;
+
+	/*
+	 * Otherwise we already have a SLAAC address, just check if any of the
+	 * auto-configuration prefixes in this RA covers our existing address
+	 * and allows us to extend its lifetime.
+	 */
+	netconfig_set_slaac_address_lifetimes(nc, r);
+
+emit_event:
 	/*
 	 * Note: we may be emitting this before L_NETCONFIG_EVENT_CONFIGURE.
 	 * We should probably instead save the affected routes in separate
@@ -1003,7 +1164,8 @@ process_nondefault_routes:
 	if (!l_queue_isempty(nc->routes.added) ||
 			!l_queue_isempty(nc->routes.updated) ||
 			!l_queue_isempty(nc->routes.removed) ||
-			!l_queue_isempty(nc->routes.expired))
+			!l_queue_isempty(nc->routes.expired) ||
+			!l_queue_isempty(nc->addresses.updated))
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 }
 
@@ -1706,6 +1868,8 @@ configure_ipv6:
 		goto done;
 	}
 
+	netconfig->v6_auto_method = NETCONFIG_V6_METHOD_UNSET;
+
 	/*
 	 * We only care about being on addr_wait_list if we're waiting for
 	 * the link-local address for DHCP6.  Add ourself to the list here
-- 
2.34.1

