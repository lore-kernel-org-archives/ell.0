Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA95C4C82
	for <ell@lists.linux.dev>; Mon, 15 Aug 2022 18:26:10 +0000 (UTC)
Received: by mail-wr1-f43.google.com with SMTP id e27so5276418wra.11
        for <ell@lists.linux.dev>; Mon, 15 Aug 2022 11:26:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc;
        bh=fgVeknC3GYUxHbPxCrFv+ZVcNYkRwkYN4G/61+IIZ/I=;
        b=xtJ9gJADOUxZLzjwguRhU565j14hUSy7JpWnSaeZWnrMz2uK1SUz2PXfOQG/iRVEtn
         iYQ+hD9RARfsQJdjH3LhB34LDQ8/wAG/OOkYOFNefPFvZ5SoEsSAx6yJKGelYK4SC4LC
         skaSnzbq9CjAyEsWgl8AYhJN2YtIuO+1YFVUKm6JyOIGTzqZ+iD0ih08BAwtyfEEYWBH
         hYy/f9JveG41mNORJOfGe7dtMyT4PSHO4M8VQGiZdod9vAZeoqqROXMGGmGEBxMd72wk
         S0tNJL+ktEKNcns9geKnkdwZ33/WoBWJHtCKfQvl7L9qThB+Bl4QWjSKSS3Zr6ehB9pP
         DtIQ==
X-Gm-Message-State: ACgBeo2E54cJdKSZ49eFDCTj628/nlsta0XrlbrRqswpA2MCFowPFXUy
	ZJdmCJO4asZWLG92ptnQOA/D+M1kNdI=
X-Google-Smtp-Source: AA6agR6CkoCvbXqkVvT28S+cqnfcpfMCi3bINisy6qC//rJt1AeYLw7ff7vbPEr8DThwPFXjyAXbGQ==
X-Received: by 2002:a5d:60c5:0:b0:220:6780:2701 with SMTP id x5-20020a5d60c5000000b0022067802701mr9959943wrt.450.1660587968748;
        Mon, 15 Aug 2022 11:26:08 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id r18-20020a05600c35d200b003a2e92edeccsm10733101wmq.46.2022.08.15.11.26.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Aug 2022 11:26:08 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/2] netconfig: API to disable/enable ACD
Date: Mon, 15 Aug 2022 20:26:01 +0200
Message-Id: <20220815182602.1146368-1-andrew.zaborowski@intel.com>
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

