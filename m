Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC2CC7B
	for <ell@lists.linux.dev>; Mon,  3 Oct 2022 22:29:04 +0000 (UTC)
Received: by mail-wm1-f43.google.com with SMTP id 130-20020a1c0288000000b003b494ffc00bso9287499wmc.0
        for <ell@lists.linux.dev>; Mon, 03 Oct 2022 15:29:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=352np4+Vvl4GITWnXLxw5PiWkWduXovJunaijCyYwTY=;
        b=Yh16O+V2I4HP2MeW6TCOYQyptT33EMI4lxAXiaOiIue66Gs+UVdDI9gSgGSwJfErBx
         k2+WLi3wAsKkUOSBSu0/v8Y8BYan3fLiwT7166JOIo24kDu7Cj3fxgs+z9AWnFJ/z//f
         tWZod2GCUYMCbqWdOhez4axfIBQhPzHoPs37jrSdg3ptTOTr8tXrpfj9Zq0UDbEaMlV8
         ZZngKZ40eKwOP+DUhpZwLlUuI44r+mQnmquPYGfh8Y/YqBwElx6ujVVYlF5wVMLCRD6R
         a5z3tQFb1TRmEThWttPwUvrxDYD1yI4XwoqzmoOwtRbnCWS1TP1kq4qXYm7mgw2NmRTP
         6slg==
X-Gm-Message-State: ACrzQf23peRC1cn1AGGRbfYHRV4KiSn7CvLMfFhc8eLsUjyWKk8BozT2
	U+FrS48KiuKYfnWaYwXpOrQJV2kbP7zNjQ==
X-Google-Smtp-Source: AMsMyM5hrczSuJEEJ6JM29VHLZmugBNNdBZ/UsrTG1O3eLSD64x/h8Fi7nYyKhZ1teuH2uqBEuu5tA==
X-Received: by 2002:a1c:7412:0:b0:3b4:7a81:e7e4 with SMTP id p18-20020a1c7412000000b003b47a81e7e4mr7734283wmc.15.1664836142717;
        Mon, 03 Oct 2022 15:29:02 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id l9-20020a056000022900b0022b315b4649sm10434207wrz.26.2022.10.03.15.29.01
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Oct 2022 15:29:01 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/5] netconfig: Return SLAAC+DHCP6 DNS info from getters
Date: Tue,  4 Oct 2022 00:28:45 +0200
Message-Id: <20221003222847.699047-3-andrew.zaborowski@intel.com>
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

In l_netconfig_get_dns_list(), l_netconfig_get_domain_names() return
both the DNS information from Router Advertisements if any, and from the
l_dhcp6_client lease if any, to cover the SLAAC+DHCP6 mode and other
possible corner cases.
---
 ell/netconfig.c | 47 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 17 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index e54e2f9..7aac5ad 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1209,6 +1209,20 @@ process_nondefault_routes:
 			netconfig_remove_icmp6_route(nc, rd);
 	}
 
+	/*
+	 * Do this first so that any changes are included in the event
+	 * emitted next, be it UPDATE or CONFIGURE.
+	 */
+	if (r->n_dns || r->n_domains) {
+		if (!nc->slaac_dnses && r->n_dns)
+			nc->slaac_dnses = l_queue_new();
+
+		if (!nc->slaac_domains && r->n_domains)
+			nc->slaac_domains = l_queue_new();
+
+		dns_updated = netconfig_process_slaac_dns_info(nc, r);
+	}
+
 	/*
 	 * For lack of a better policy, select between DHCPv6 and SLAAC based
 	 * on the first RA received.  Prefer DHCPv6.
@@ -1245,14 +1259,6 @@ process_nondefault_routes:
 		} else
 			nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC;
 
-		/*
-		 * Do this first so that any changes are included in the
-		 * CONFIGURE event emitted next.
-		 */
-		nc->slaac_dnses = l_queue_new();
-		nc->slaac_domains = l_queue_new();
-		netconfig_process_slaac_dns_info(nc, r);
-
 		/*
 		 * The DAD for the link-local address may be still running
 		 * but again we can generate the global address already and
@@ -1287,7 +1293,6 @@ process_nondefault_routes:
 	 * and allows us to extend its lifetime.
 	 */
 	netconfig_set_slaac_address_lifetimes(nc, r);
-	dns_updated = netconfig_process_slaac_dns_info(nc, r);
 
 emit_event:
 	/*
@@ -2411,14 +2416,18 @@ append_v6:
 	if (!netconfig->v6_configured)
 		goto done;
 
-	if (netconfig->v6_dns_override)
+	if (netconfig->v6_dns_override) {
 		netconfig_strv_cat(&ret, netconfig->v6_dns_override, false);
-	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_DHCP &&
+		goto done;
+	}
+
+	if (L_IN_SET(netconfig->v6_auto_method, NETCONFIG_V6_METHOD_DHCP,
+				NETCONFIG_V6_METHOD_SLAAC_DHCP) &&
 			(v6_lease = l_dhcp6_client_get_lease(
 						netconfig->dhcp6_client)))
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_dns(v6_lease), true);
-	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC &&
-			!l_queue_isempty(netconfig->slaac_dnses)) {
+
+	if (!l_queue_isempty(netconfig->slaac_dnses)) {
 		unsigned int dest_len = l_strv_length(ret);
 		unsigned int src_len = l_queue_length(netconfig->slaac_dnses);
 		char **i;
@@ -2468,16 +2477,20 @@ append_v6:
 	if (!netconfig->v6_configured)
 		goto done;
 
-	if (netconfig->v6_domain_names_override)
+	if (netconfig->v6_domain_names_override) {
 		netconfig_strv_cat(&ret, netconfig->v6_domain_names_override,
 					false);
-	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_DHCP &&
+		goto done;
+	}
+
+	if (L_IN_SET(netconfig->v6_auto_method, NETCONFIG_V6_METHOD_DHCP,
+				NETCONFIG_V6_METHOD_SLAAC_DHCP) &&
 			(v6_lease = l_dhcp6_client_get_lease(
 						netconfig->dhcp6_client)))
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_domains(v6_lease),
 					true);
-	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC &&
-			!l_queue_isempty(netconfig->slaac_domains)) {
+
+	if (!l_queue_isempty(netconfig->slaac_domains)) {
 		unsigned int dest_len = l_strv_length(ret);
 		unsigned int src_len = l_queue_length(netconfig->slaac_domains);
 		char **i;
-- 
2.34.1

