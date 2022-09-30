Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C48833C7
	for <ell@lists.linux.dev>; Fri, 30 Sep 2022 13:53:17 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id bk15so6956120wrb.13
        for <ell@lists.linux.dev>; Fri, 30 Sep 2022 06:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=352np4+Vvl4GITWnXLxw5PiWkWduXovJunaijCyYwTY=;
        b=csSyTrRZAQ7LJ2AhwIEwwd0X1oGuRzuD2UQ2Y1UmuYGKLMmp3bop/ouiuXtpANXmTs
         5ZPI4qJQxAxOriUycXwA45sHjwWifTrWqrcxAtZG3y81Lj7p9aqyiiIinUbQeaFPQZqF
         OwvTW5YfUnJ79aWRNILF79GpxaJnxNtuE5AhAOtcImc41Lc/8RAFMJfd8IiQXs/QawW9
         XVdxsmmR8YYksLlALmuW0q+Z2ReixXqcWmzBudLy7NLxBgvAyihwYu1Zev+8txABkLbw
         UmFHZyQ//UMbmUw+Bw/wBn2LYcMa0aOIO36Nu8kRuRLsSeDFrgf+aFr59zkHsiPr8p6E
         a0pg==
X-Gm-Message-State: ACrzQf08ejtC4jw6z8b8o+mUz77lZbxoa0dsN2cEs6dxws7Y1NEYMrcL
	/QsqYu1eRLxRBtISUdaLUkkne3efok0=
X-Google-Smtp-Source: AMsMyM7tByFYrhHpxD/FE6Ev0cGhf9obZHXeWOLIzG3/wyv6rJ23XVnlZQHRpoKE6djfrMDo1m1nSw==
X-Received: by 2002:adf:d1c2:0:b0:22a:66ad:2669 with SMTP id b2-20020adfd1c2000000b0022a66ad2669mr5947428wrd.468.1664545995519;
        Fri, 30 Sep 2022 06:53:15 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id p5-20020a05600c1d8500b003b492b30822sm2249801wms.2.2022.09.30.06.53.14
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Sep 2022 06:53:15 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/5] netconfig: Return SLAAC+DHCP6 DNS info from getters
Date: Fri, 30 Sep 2022 15:52:49 +0200
Message-Id: <20220930135250.534296-4-andrew.zaborowski@intel.com>
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

