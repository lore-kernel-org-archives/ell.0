Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 176B06101
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:16 +0000 (UTC)
Received: by mail-wr1-f46.google.com with SMTP id g3so26640559wrq.13
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=AmjmGQI413kSQYZ8UfQUov1MoU7e7RMicUDCcchBUaQ=;
        b=ublpQKjlDj8YJwmknJhwn1aWz0wpPv9VuMecgrWCx6Gw1jhOtJ95DYqdeNjvHZIlnI
         y2Nu3/btas257qw1yCpCmoXnPfg53zRsgN98BWWBeaVLOgesxM4sDXhs/HPiJT+v15Ms
         JVVDiQbNLIB/Z+CtxGTUGmNdihuQuVWeEJgfY6GBZgFLCkVD7rORnT6VIHYWd4h4fgTx
         p1mz7eR6MOMUmAsfyzitRMkTqNu4YYynBBvuDZmGypWbfPn3UoIV9W9uHlOow6LXHj0/
         gvYmy/9ThjFXMNctp8jm5IQ1PfouV1SoxdzIOKcizjBD1YsNXsPQ1/dZVIhBF4Q5TObS
         kpAQ==
X-Gm-Message-State: ACrzQf0xiuSLR9FBjuRiFBmhIktv8o/Hxf52OuVVmHl6OdSEkW7PbFHN
	Xi1JQ/PwiWdWh6xry7vrdPdww+y3DofccQ==
X-Google-Smtp-Source: AMsMyM7U/67yaGGvFNh/+tmESdP5VGDT7jO4RMAeOkFN9nXYLi+lEbV+dp3ImMsSMG9BeH+1YNb0fA==
X-Received: by 2002:adf:dd83:0:b0:22a:eb0a:7fa7 with SMTP id x3-20020adfdd83000000b0022aeb0a7fa7mr7059408wrl.135.1663594275019;
        Mon, 19 Sep 2022 06:31:15 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.14
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:14 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 7/7] netconfig: Control optimistic DAD
Date: Mon, 19 Sep 2022 15:31:05 +0200
Message-Id: <20220919133105.3129080-7-andrew.zaborowski@intel.com>
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

Enable or disable optimistic DAD for the interface using /proc.  Add
l_netconfig_set_optimistic_dad_enabled() for the user to request that
RFC 4429 optimistic DAD be enabled.  As recommended in the RFC, we'll
only actually enable optimistic DAD for the automatic address generation
methods and disable it if a static IPv6 address is configured.  The
default if l_netconfig_set_optimistic_dad_enabled() isn't used is to
disable optimistic DAD always.

Optimistic DAD can shorten practical IPv6 setup time by an amount on
the order of a second by allowing the link-local address and the global
address to be used immediately after being generated.  For the
link-local address this means that DHCPv6 may start sooner and
for the global address, which is added to the kernel by the
L_NETCONFIG_EVENT_CONFIGURE event handler, the user can start
establishing connections sooner.  With DHCPv6 and some luck the two
savings may compound, with SLAAC only the global address's DAD time
should matter.
---
 ell/ell.sym     |  1 +
 ell/netconfig.c | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 ell/netconfig.h |  2 ++
 3 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index d76b2ea..6df9024 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -751,6 +751,7 @@ global:
 	l_netconfig_set_dns_override;
 	l_netconfig_set_domain_names_override;
 	l_netconfig_set_acd_enabled;
+	l_netconfig_set_optimistic_dad_enabled;
 	l_netconfig_check_config;
 	l_netconfig_reset_config;
 	l_netconfig_start;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 3336b30..7a9ee89 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -76,6 +76,7 @@ struct l_netconfig {
 	char *v6_gateway_override;
 	char **v6_dns_override;
 	char **v6_domain_names_override;
+	bool optimistic_dad_enabled;
 
 	bool started;
 	struct l_idle *do_static_work;
@@ -89,6 +90,7 @@ struct l_netconfig {
 	struct l_queue *icmp_route_data;
 	struct l_acd *acd;
 	unsigned int orig_disable_ipv6;
+	unsigned int orig_optimistic_dad;
 	uint8_t mac[ETH_ALEN];
 	struct l_timeout *ra_timeout;
 	enum {
@@ -1490,6 +1492,17 @@ LIB_EXPORT bool l_netconfig_set_acd_enabled(struct l_netconfig *netconfig,
 	return true;
 }
 
+LIB_EXPORT bool l_netconfig_set_optimistic_dad_enabled(
+						struct l_netconfig *netconfig,
+						bool enabled)
+{
+	if (unlikely(!netconfig || netconfig->started))
+		return false;
+
+	netconfig->optimistic_dad_enabled = enabled;
+	return true;
+}
+
 static bool netconfig_check_family_config(struct l_netconfig *nc,
 						uint8_t family)
 {
@@ -1724,7 +1737,8 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 	struct in6_addr in6;
 	_auto_(l_free) char *ip = NULL;
 
-	if (ifa->ifa_flags & IFA_F_TENTATIVE)
+	if ((ifa->ifa_flags & IFA_F_TENTATIVE) &&
+			!(ifa->ifa_flags & IFA_F_OPTIMISTIC))
 		return;
 
 	if (!nc->started)
@@ -1828,6 +1842,8 @@ static void netconfig_ifaddr_ipv6_dump_done_cb(void *user_data)
 
 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 {
+	bool optimistic_dad;
+
 	if (unlikely(!netconfig || netconfig->started))
 		return false;
 
@@ -1855,6 +1871,28 @@ configure_ipv6:
 	if (!netconfig->v6_enabled)
 		goto done;
 
+	/*
+	 * Enable optimistic DAD if the user has requested it *and* it is
+	 * recommended by RFC 4429 Section 3.1 for the address generation
+	 * method in use:
+	 *   * mac-based Interface ID such as EUI-64
+	 *   * random
+	 *   * well-distributed hash function
+	 *   * DHCPv6
+	 * i.e. all autoconfiguration methods.  In any other case disable
+	 * it.
+	 */
+	optimistic_dad = netconfig->optimistic_dad_enabled &&
+		!netconfig->v6_static_addr;
+	netconfig->orig_optimistic_dad =
+		netconfig_proc_read_ipv6_uint_setting(netconfig,
+							"optimistic_dad");
+
+	if (!!netconfig->orig_optimistic_dad != optimistic_dad)
+		netconfig_proc_write_ipv6_uint_setting(netconfig,
+							"optimistic_dad",
+							optimistic_dad ? 1 : 0);
+
 	if (netconfig->v6_static_addr) {
 		/*
 		 * We're basically ready to configure the interface
@@ -1944,6 +1982,8 @@ unregister:
 
 LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 {
+	bool optimistic_dad;
+
 	if (unlikely(!netconfig || !netconfig->started))
 		return;
 
@@ -1985,6 +2025,13 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 						netconfig->orig_disable_ipv6);
 		netconfig->orig_disable_ipv6 = 0;
 	}
+
+	optimistic_dad = netconfig->optimistic_dad_enabled &&
+		!netconfig->v6_static_addr;
+	if (!!netconfig->orig_optimistic_dad != optimistic_dad)
+		netconfig_proc_write_ipv6_uint_setting(netconfig,
+						"optimistic_dad",
+						netconfig->orig_optimistic_dad);
 }
 
 /*
diff --git a/ell/netconfig.h b/ell/netconfig.h
index fb3c536..3c024fe 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -69,6 +69,8 @@ bool l_netconfig_set_dns_override(struct l_netconfig *netconfig, uint8_t family,
 bool l_netconfig_set_domain_names_override(struct l_netconfig *netconfig,
 						uint8_t family, char **names);
 bool l_netconfig_set_acd_enabled(struct l_netconfig *netconfig, bool enabled);
+bool l_netconfig_set_optimistic_dad_enabled(struct l_netconfig *netconfig,
+						bool enabled);
 bool l_netconfig_check_config(struct l_netconfig *netconfig);
 bool l_netconfig_reset_config(struct l_netconfig *netconfig);
 
-- 
2.34.1

