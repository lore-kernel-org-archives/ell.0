Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com [209.85.167.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A44CD7A
	for <ell@lists.linux.dev>; Mon, 11 Jul 2022 14:03:51 +0000 (UTC)
Received: by mail-lf1-f45.google.com with SMTP id d12so8837630lfq.12
        for <ell@lists.linux.dev>; Mon, 11 Jul 2022 07:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=fgVeknC3GYUxHbPxCrFv+ZVcNYkRwkYN4G/61+IIZ/I=;
        b=s3102kPrve3jHT5EGePAnvYd4QQ1fybdlQ8pmaMGgWcQI54TVpVWVMVyCWcJ7CO3N7
         Hzuz0bM2rePoU7TVS0/Rngu/7FIv+dMRYiweJYYh4XZiNznI1IEW8NRfSomOgSw/z9W9
         5LveoNUykDBzndzlE0y2Y/qWKeuGkNrn0YcMgUYhW+V0yeIrK7sFINgsikRob7ldTaCQ
         a9QMpGI5Te96PfeXKWi+4eqkLpjvOLc1GLJ6QZlUAYGVTFEmsesbCrrBj52V7c8ghmlU
         DHRqDKPUe/OQ9Q2M6EjQl9eOCFdHF9JRzmFPCId5NWWLodhnfjWBsBNhY83q78tDoIcb
         Vq/g==
X-Gm-Message-State: AJIora/sS1J50H9jhkdv8WZPSptyQNleDmR07Wbym1COWmQl1CjXf5Ix
	806QahZvIIkG98R4ZNMgDAGSdv0KK9G5cBWJ
X-Google-Smtp-Source: AGRyM1vcNKl9MdvP2VXumBf+octcOJ6t6eXUQpbqhah2fgFiJMdYoQNg5ujEfbMA+WAmtMWj78VOCw==
X-Received: by 2002:a05:6512:158b:b0:489:e031:a013 with SMTP id bp11-20020a056512158b00b00489e031a013mr2720533lfb.508.1657548229296;
        Mon, 11 Jul 2022 07:03:49 -0700 (PDT)
Received: from iss.home (79.184.238.213.ipv4.supernova.orange.pl. [79.184.238.213])
        by smtp.gmail.com with ESMTPSA id h15-20020a19ca4f000000b0048745483f2asm1565178lfj.23.2022.07.11.07.03.48
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 11 Jul 2022 07:03:48 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH] netconfig: API to disable/enable ACD
Date: Mon, 11 Jul 2022 16:03:44 +0200
Message-Id: <20220711140344.3464765-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When using FILS IP Assignment, the received configuration will be passed
to l_netconfig as "static", yet we may want to skip ACD to avoid the
overhead.
---
 ell/ell.sym     |  1 +
 ell/netconfig.c | 40 ++++++++++++++++++++++++++++------------
 ell/netconfig.h |  1 +
 3 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 8f4e59d..81cec64 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -747,6 +747,7 @@ global:
 	l_netconfig_set_gateway_override;
 	l_netconfig_set_dns_override;
 	l_netconfig_set_domain_names_override;
+	l_netconfig_set_acd_enabled;
 	l_netconfig_check_config;
 	l_netconfig_reset_config;
 	l_netconfig_start;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 28afa9b..8f87e64 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -67,6 +67,7 @@ struct l_netconfig {
 	char *v4_gateway_override;
 	char **v4_dns_override;
 	char **v4_domain_names_override;
+	bool acd_enabled;
 
 	bool v6_enabled;
 	struct l_rtnl_address *v6_static_addr;
@@ -1031,7 +1032,6 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 
 	nc = l_new(struct l_netconfig, 1);
 	nc->ifindex = ifindex;
-	nc->v4_enabled = true;
 
 	nc->addresses.current = l_queue_new();
 	nc->addresses.added = l_queue_new();
@@ -1061,6 +1061,7 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 	/* Disable in-kernel autoconfiguration for the interface */
 	netconfig_proc_write_ipv6_uint_setting(nc, "accept_ra", 0);
 
+	l_netconfig_reset_config(nc);
 	return nc;
 }
 
@@ -1275,6 +1276,16 @@ LIB_EXPORT bool l_netconfig_set_domain_names_override(
 	return true;
 }
 
+LIB_EXPORT bool l_netconfig_set_acd_enabled(struct l_netconfig *netconfig,
+						bool enabled)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	netconfig->acd_enabled = enabled;
+	return true;
+}
+
 static bool netconfig_check_family_config(struct l_netconfig *nc,
 						uint8_t family)
 {
@@ -1343,6 +1354,7 @@ LIB_EXPORT bool l_netconfig_reset_config(struct l_netconfig *netconfig)
 	l_netconfig_set_gateway_override(netconfig, AF_INET, NULL);
 	l_netconfig_set_dns_override(netconfig, AF_INET, NULL);
 	l_netconfig_set_domain_names_override(netconfig, AF_INET, NULL);
+	l_netconfig_set_acd_enabled(netconfig, true);
 	l_netconfig_set_family_enabled(netconfig, AF_INET6, false);
 	l_netconfig_set_static_addr(netconfig, AF_INET6, NULL);
 	l_netconfig_set_gateway_override(netconfig, AF_INET6, NULL);
@@ -1434,25 +1446,29 @@ static void netconfig_do_static_config(struct l_idle *idle, void *user_data)
 	l_idle_remove(l_steal_ptr(nc->do_static_work));
 
 	if (nc->v4_static_addr && !nc->v4_configured) {
-		char ip[INET_ADDRSTRLEN];
+		if (nc->acd_enabled) {
+			char ip[INET_ADDRSTRLEN];
 
-		l_rtnl_address_get_address(nc->v4_static_addr, ip);
+			l_rtnl_address_get_address(nc->v4_static_addr, ip);
 
-		nc->acd = l_acd_new(nc->ifindex);
-                l_acd_set_event_handler(nc->acd, netconfig_ipv4_acd_event, nc,
-					NULL);
+			nc->acd = l_acd_new(nc->ifindex);
+			l_acd_set_event_handler(nc->acd,
+						netconfig_ipv4_acd_event, nc,
+						NULL);
 
-		if (!l_acd_start(nc->acd, ip)) {
-			l_acd_destroy(l_steal_ptr(nc->acd));
+			if (l_acd_start(nc->acd, ip))
+				goto configure_ipv6;
 
+			l_acd_destroy(l_steal_ptr(nc->acd));
 			/* Configure right now as a fallback */
-			netconfig_add_v4_static_address_routes(nc);
-			nc->v4_configured = true;
-			netconfig_emit_event(nc, AF_INET,
-						L_NETCONFIG_EVENT_CONFIGURE);
 		}
+
+		netconfig_add_v4_static_address_routes(nc);
+		nc->v4_configured = true;
+		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_CONFIGURE);
 	}
 
+configure_ipv6:
 	if (nc->v6_static_addr && !nc->v6_configured) {
 		netconfig_add_v6_static_address_routes(nc);
 		nc->v6_configured = true;
diff --git a/ell/netconfig.h b/ell/netconfig.h
index ac467b6..7710d83 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -68,6 +68,7 @@ bool l_netconfig_set_dns_override(struct l_netconfig *netconfig, uint8_t family,
 					char **dns_list);
 bool l_netconfig_set_domain_names_override(struct l_netconfig *netconfig,
 						uint8_t family, char **names);
+bool l_netconfig_set_acd_enabled(struct l_netconfig *netconfig, bool enabled);
 bool l_netconfig_check_config(struct l_netconfig *netconfig);
 bool l_netconfig_reset_config(struct l_netconfig *netconfig);
 
-- 
2.34.1

