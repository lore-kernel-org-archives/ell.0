Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B201733DD
	for <ell@lists.linux.dev>; Fri, 30 Sep 2022 13:53:16 +0000 (UTC)
Received: by mail-wr1-f54.google.com with SMTP id n10so6950628wrw.12
        for <ell@lists.linux.dev>; Fri, 30 Sep 2022 06:53:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=U+cNKTXXloGb92ESHveJ5DLwyMf+edpInQque0FO0zM=;
        b=8KA5XiuPuC0jYbmr8XYokYhWvuDuU7kzKZLJmZwUzuJMCYbq1X4QVY59A9DMtLTtdF
         txiLct+OB9j04oX7TGYKFAPxPvS8YY4yTi1AQfYGFqXX67QP/wvHcDQasZy0jWxXNXqg
         I90E5bF6bNXBZudMsJAkV8v7WUl84riSA/05e4ITaodcYAF0fvCsdx2nnysF8x1Eys4b
         pK/qZ2rPnKhmNRmAvbINasOZVLy3ccH1z95ddKopUfeaPkI7J7h2Q6I3skA1O1cAp0ZT
         VFdBB0mq2pkbKs/Y1uGqQ4ClBhjH4ihQkds82sc4RNNxszG4UYeMJz6+KGMrUSBe2uFN
         QRuQ==
X-Gm-Message-State: ACrzQf2Pd9CdTa3hCAgAhyWSp0/TfezNx7MsUuLhjesqHu0z3ptAml1z
	aqzLbzrN1tQRIEU6nUZB8VVUVnQ7gBI=
X-Google-Smtp-Source: AMsMyM7FZO+iT7qg1IE2nqgbH/YOxLkMm2zN4vCLSxR6QCni9WAQnkjan+oeyhCDcCUyOTwZtJUPPg==
X-Received: by 2002:a5d:4bc3:0:b0:22a:4b7a:6f60 with SMTP id l3-20020a5d4bc3000000b0022a4b7a6f60mr5866955wrt.549.1664545994743;
        Fri, 30 Sep 2022 06:53:14 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id p5-20020a05600c1d8500b003b492b30822sm2249801wms.2.2022.09.30.06.53.14
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Sep 2022 06:53:14 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/5] netconfig: Enable stateless DHCP mode
Date: Fri, 30 Sep 2022 15:52:48 +0200
Message-Id: <20220930135250.534296-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220930135250.534296-1-andrew.zaborowski@intel.com>
References: <20220930135250.534296-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When using SLAAC, if the "Other" bit in Router Advertisements is set,
start DHCP6 in stateless mode and use the DNS entries from the lease
object created by l_dhcp6_client.  If there is DNS information in the RA
then emit the CONFIGURE event immediately after we've generated the
addresses as before.  If there's no DNS information, wait for the
l_dhcp6_client LEASE_OBTAINED event before we emit CONFIGURE and set
netconfig->v6_configured.
---
 ell/netconfig.c | 53 ++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 39 insertions(+), 14 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index fe5bf40..e54e2f9 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -96,8 +96,9 @@ struct l_netconfig {
 	bool have_lla;
 	enum {
 		NETCONFIG_V6_METHOD_UNSET,
-		NETCONFIG_V6_METHOD_DHCP,
-		NETCONFIG_V6_METHOD_SLAAC,
+		NETCONFIG_V6_METHOD_DHCP,       /* Managed bit set in RA */
+		NETCONFIG_V6_METHOD_SLAAC_DHCP, /* Other bit set in RA */
+		NETCONFIG_V6_METHOD_SLAAC,      /* Neither flag set in RA */
 	} v6_auto_method;
 	struct l_queue *slaac_dnses;
 	struct l_queue *slaac_domains;
@@ -624,13 +625,17 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 		if (L_WARN_ON(nc->v6_configured))
 			break;
 
-		netconfig_add_dhcp6_address(nc);
-		netconfig_set_dhcp6_address_lifetimes(nc, false);
+		if (nc->v6_auto_method == NETCONFIG_V6_METHOD_DHCP) {
+			netconfig_add_dhcp6_address(nc);
+			netconfig_set_dhcp6_address_lifetimes(nc, false);
+		}
+
 		nc->v6_configured = true;
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
 		break;
 	case L_DHCP6_CLIENT_EVENT_IP_CHANGED:
-		if (L_WARN_ON(!nc->v6_configured))
+		if (L_WARN_ON(!nc->v6_configured ||
+				nc->v6_auto_method != NETCONFIG_V6_METHOD_DHCP))
 			break;
 
 		netconfig_remove_dhcp6_address(nc, false);
@@ -639,7 +644,8 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 		break;
 	case L_DHCP6_CLIENT_EVENT_LEASE_EXPIRED:
-		if (L_WARN_ON(!nc->v6_configured))
+		if (L_WARN_ON(!nc->v6_configured ||
+				nc->v6_auto_method != NETCONFIG_V6_METHOD_DHCP))
 			break;
 
 		netconfig_remove_dhcp6_address(nc, true);
@@ -658,13 +664,19 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 		if (L_WARN_ON(!nc->v6_configured))
 			break;
 
-		netconfig_set_dhcp6_address_lifetimes(nc, true);
+		if (nc->v6_auto_method == NETCONFIG_V6_METHOD_DHCP)
+			netconfig_set_dhcp6_address_lifetimes(nc, true);
+
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 		break;
 	case L_DHCP6_CLIENT_EVENT_NO_LEASE:
 		if (L_WARN_ON(nc->v6_configured))
 			break;
 
+		if (nc->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC_DHCP &&
+				!l_queue_isempty(nc->slaac_dnses))
+			break;
+
 		/*
 		 * The requested address is no longer available, try to restart
 		 * the client.
@@ -699,7 +711,9 @@ static bool netconfig_match_str(const void *a, const void *b)
 static bool netconfig_check_start_dhcp6(struct l_netconfig *nc)
 {
 	/* Don't start DHCPv6 until we get an RA with the managed bit set */
-	if (nc->ra_timeout || nc->v6_auto_method != NETCONFIG_V6_METHOD_DHCP)
+	if (nc->ra_timeout || !L_IN_SET(nc->v6_auto_method,
+				NETCONFIG_V6_METHOD_DHCP,
+				NETCONFIG_V6_METHOD_SLAAC_DHCP))
 		return true;
 
 	/* Don't start DHCPv6 while waiting for the link-local address */
@@ -765,8 +779,13 @@ static void netconfig_add_slaac_address(struct l_netconfig *nc,
 
 	l_queue_push_tail(nc->addresses.current, nc->v6_address);
 	l_queue_push_tail(nc->addresses.added, nc->v6_address);
-	nc->v6_configured = true;
-	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
+
+	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC ||
+			nc->slaac_dnses) {
+		nc->v6_configured = true;
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
+	} else
+		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 
 	/* TODO: set a renew timeout */
 }
@@ -1202,6 +1221,7 @@ process_nondefault_routes:
 	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET &&
 			l_icmp6_router_get_managed(r)) {
 		nc->v6_auto_method = NETCONFIG_V6_METHOD_DHCP;
+		l_dhcp6_client_set_stateless(nc->dhcp6_client, false);
 
 		if (!netconfig_check_start_dhcp6(nc)) {
 			netconfig_emit_event(nc, AF_INET6,
@@ -1213,12 +1233,17 @@ process_nondefault_routes:
 	}
 
 	/*
-	 * DHCP not available according to this router, check if any of the
-	 * prefixes allow SLAAC.
+	 * Stateful DHCP not available according to this router, check if
+	 * any of the prefixes allow SLAAC.
 	 */
 	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET &&
 			r->n_ac_prefixes) {
-		nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC;
+		if (l_icmp6_router_get_other(r)) {
+			nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC_DHCP;
+			l_dhcp6_client_set_stateless(nc->dhcp6_client, true);
+			netconfig_check_start_dhcp6(nc);
+		} else
+			nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC;
 
 		/*
 		 * Do this first so that any changes are included in the
@@ -2188,7 +2213,7 @@ LIB_EXPORT void l_netconfig_unconfigure(struct l_netconfig *netconfig)
 					L_NETCONFIG_EVENT_UNCONFIGURE);
 	}
 
-	if (netconfig->v6_configured) {
+	if (netconfig->v6_address) {
 		netconfig_remove_dhcp6_address(netconfig, false);
 		netconfig->v6_configured = false;
 	}
-- 
2.34.1

