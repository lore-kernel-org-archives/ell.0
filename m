Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A645733C9
	for <ell@lists.linux.dev>; Mon,  3 Oct 2022 22:29:03 +0000 (UTC)
Received: by mail-wm1-f49.google.com with SMTP id ay36so7865965wmb.0
        for <ell@lists.linux.dev>; Mon, 03 Oct 2022 15:29:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=U+cNKTXXloGb92ESHveJ5DLwyMf+edpInQque0FO0zM=;
        b=Yduiuu4S2mr0THOlWvUuvwL9KGKu5eqi1QzGbJIL2gIJidnaj4+xsG/AsTC/UrhGar
         Bbat82AHpdtI5B3iL/cX2N69TjCxUk84gaPcu3FxpkPXV5wumFFNFdAV1DSaBEYlOxHd
         4SWuWs4ZvFZkkZlXrRMn2/fGI3MzurvxU6/5bMAtt41fLKOn46XR60oICyiWFDK7sxPR
         2FAwLlrI7TFMJ5QpFkato6wbrJB20pWu6/j2rdHb/vTU7jIJ9oK9MG/6K3J090uIuE8b
         uoCRvtBYNPdLPpLCwfiaH+RKpwpYxmNghJXkMWcDxEDLZQGJjbMWdYgzUBE0a8RfjBjJ
         hBcg==
X-Gm-Message-State: ACrzQf0eDAdH3028Qw/22sRCNF+y0LgADFileuX3W2KEdm8aMHh9ENNf
	gCTrAQgfcgeGh5t7yln6HyVWrOM3M7dk/Q==
X-Google-Smtp-Source: AMsMyM7k/lkb70DV8Kq88a6RkL/Pdvjkjsx0w7AiW1sucLdOKrEl6dKMhNUpLSOL4JCPxPUNsV3JxA==
X-Received: by 2002:a05:600c:27d1:b0:3b4:5e9c:23ed with SMTP id l17-20020a05600c27d100b003b45e9c23edmr7854207wmb.180.1664836141559;
        Mon, 03 Oct 2022 15:29:01 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id l9-20020a056000022900b0022b315b4649sm10434207wrz.26.2022.10.03.15.29.00
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Oct 2022 15:29:01 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/5] netconfig: Enable stateless DHCP mode
Date: Tue,  4 Oct 2022 00:28:44 +0200
Message-Id: <20221003222847.699047-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221003222847.699047-1-andrew.zaborowski@intel.com>
References: <20221003222847.699047-1-andrew.zaborowski@intel.com>
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

