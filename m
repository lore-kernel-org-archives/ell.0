Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B19C44C8A
	for <ell@lists.linux.dev>; Mon, 15 Aug 2022 18:26:11 +0000 (UTC)
Received: by mail-wr1-f53.google.com with SMTP id b4so6870464wrn.4
        for <ell@lists.linux.dev>; Mon, 15 Aug 2022 11:26:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc;
        bh=R5J7ThmxcZRPBUYyjivgcfCLae7YSIKnwl3DSzTOPMQ=;
        b=hTcHoJHwYvg1JWcYaMDyAzs1zjSWHLgYZFhZwJyrOXSMyO11oxfnVcSaqwNrfYd3hh
         wbu5VH1DYzzqE11FI/Q5VcRZU0l+DrWfbyYmycqCYJTXZfAYCW9ZEwtVS8OmFLFLQkAm
         NPCBFDWKfiHgVT2A6dHMA/MGkyvtR/tQ3qxuhlGlR58syJ31+5MsRyYoUMXPctM7Otwp
         lWmMPvjF4mZBfK1+SFOWyUjRCRx9aSMin+bML/u5nEXpeWIByLyXjHOnl2GM5yXVcQX5
         5DL4p5/P0u7Ce7fP3oJ6STrXGxsZvVkQqH2Xf5Aip7DLiprQTO3Fq6eVMIK10hAzwzAW
         PNyA==
X-Gm-Message-State: ACgBeo2MU5lIrLN7l4a5D0THretbmalL272+LzmbWLw/BWirB7pWGImU
	2bca2sfNXBJQiS+JcxYwaQPno5zaPaY=
X-Google-Smtp-Source: AA6agR4fT/SImAMkE0iAIyyos89i3e882FR7lyOIXAN6zdoLsXyyl8v4WwxDXfmSOCJEWlkk4XP2AQ==
X-Received: by 2002:adf:fe81:0:b0:21b:88ea:6981 with SMTP id l1-20020adffe81000000b0021b88ea6981mr10024900wrr.616.1660587969564;
        Mon, 15 Aug 2022 11:26:09 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id r18-20020a05600c35d200b003a2e92edeccsm10733101wmq.46.2022.08.15.11.26.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Aug 2022 11:26:09 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/2] netconfig: Add l_netconfig_unconfigure
Date: Mon, 15 Aug 2022 20:26:02 +0200
Message-Id: <20220815182602.1146368-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220815182602.1146368-1-andrew.zaborowski@intel.com>
References: <20220815182602.1146368-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add method to trigger an UNCONFIGURE event with all routes and addresses
removed, if there were any.  Make sure l_netconfig_get_dns_list() and
l_netconfig_get_domain_names() return empty too.
---
 ell/ell.sym     |  1 +
 ell/netconfig.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netconfig.h |  1 +
 3 files changed, 67 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 81cec64..0dcf8f8 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -752,6 +752,7 @@ global:
 	l_netconfig_reset_config;
 	l_netconfig_start;
 	l_netconfig_stop;
+	l_netconfig_unconfigure;
 	l_netconfig_get_dhcp_client;
 	l_netconfig_get_dhcp6_client;
 	l_netconfig_get_icmp6_client;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 8f87e64..29e95b7 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1747,6 +1747,55 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 	}
 }
 
+/*
+ * Undo any configuration already applied to the interface by previous
+ * calls to the event handler, by synchronously emitting
+ * L_NETCONFIG_EVENT_UNCONFIGURE events.  This can be called before
+ * l_netconfig_stop() which won't emit any events.  It mainly makes
+ * sense if the interface isn't being removed or brought DOWN, which
+ * would otherwise implicitly remove routes and addresses.
+ */
+LIB_EXPORT void l_netconfig_unconfigure(struct l_netconfig *netconfig)
+{
+	const struct l_queue_entry *entry;
+
+	if (netconfig->v4_configured) {
+		netconfig_remove_v4_address_routes(netconfig, false);
+		netconfig->v4_configured = false;
+
+		netconfig_emit_event(netconfig, AF_INET,
+					L_NETCONFIG_EVENT_UNCONFIGURE);
+	}
+
+	if (netconfig->v6_configured) {
+		netconfig_remove_dhcp6_address(netconfig, false);
+		netconfig->v6_configured = false;
+	}
+
+	/* Bulk remove any other routes or addresses */
+	for (entry = l_queue_get_entries(netconfig->addresses.current); entry;
+			entry = entry->next)
+		l_queue_push_tail(netconfig->addresses.removed, entry->data);
+
+	l_queue_clear(netconfig->addresses.added, NULL);
+	l_queue_clear(netconfig->addresses.updated, NULL);
+	l_queue_clear(netconfig->addresses.current, NULL);
+
+	for (entry = l_queue_get_entries(netconfig->routes.current); entry;
+			entry = entry->next)
+		l_queue_push_tail(netconfig->routes.removed, entry->data);
+
+	l_queue_clear(netconfig->routes.added, NULL);
+	l_queue_clear(netconfig->routes.updated, NULL);
+	l_queue_clear(netconfig->routes.current, NULL);
+	l_queue_clear(netconfig->icmp_route_data, l_free);
+
+	if (!l_queue_isempty(netconfig->addresses.removed) ||
+			!l_queue_isempty(netconfig->routes.removed))
+		netconfig_emit_event(netconfig, AF_INET6,
+					L_NETCONFIG_EVENT_UNCONFIGURE);
+}
+
 LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhcp_client(
 						struct l_netconfig *netconfig)
 {
@@ -1903,18 +1952,26 @@ LIB_EXPORT char **l_netconfig_get_dns_list(struct l_netconfig *netconfig)
 	const struct l_dhcp_lease *v4_lease;
 	const struct l_dhcp6_lease *v6_lease;
 
+	if (!netconfig->v4_configured)
+		goto append_v6;
+
 	if (netconfig->v4_dns_override)
 		netconfig_strv_cat(&ret, netconfig->v4_dns_override, false);
 	else if ((v4_lease =
 			l_dhcp_client_get_lease(netconfig->dhcp_client)))
 		netconfig_strv_cat(&ret, l_dhcp_lease_get_dns(v4_lease), true);
 
+append_v6:
+	if (!netconfig->v6_configured)
+		goto done;
+
 	if (netconfig->v6_dns_override)
 		netconfig_strv_cat(&ret, netconfig->v6_dns_override, false);
 	else if ((v6_lease =
 			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_dns(v6_lease), true);
 
+done:
 	return ret;
 }
 
@@ -1926,6 +1983,9 @@ LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconfig)
 	const struct l_dhcp6_lease *v6_lease;
 	char *dn;
 
+	if (!netconfig->v4_configured)
+		goto append_v6;
+
 	if (netconfig->v4_domain_names_override)
 		netconfig_strv_cat(&ret, netconfig->v4_domain_names_override,
 					false);
@@ -1936,6 +1996,10 @@ LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconfig)
 		ret[0] = dn;
 	}
 
+append_v6:
+	if (!netconfig->v6_configured)
+		goto done;
+
 	if (netconfig->v6_dns_override)
 		netconfig_strv_cat(&ret, netconfig->v6_domain_names_override,
 					false);
@@ -1944,5 +2008,6 @@ LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconfig)
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_domains(v6_lease),
 					true);
 
+done:
 	return ret;
 }
diff --git a/ell/netconfig.h b/ell/netconfig.h
index 7710d83..fb3c536 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -74,6 +74,7 @@ bool l_netconfig_reset_config(struct l_netconfig *netconfig);
 
 bool l_netconfig_start(struct l_netconfig *netconfig);
 void l_netconfig_stop(struct l_netconfig *netconfig);
+void l_netconfig_unconfigure(struct l_netconfig *netconfig);
 
 struct l_dhcp_client *l_netconfig_get_dhcp_client(
 						struct l_netconfig *netconfig);
-- 
2.34.1

