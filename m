Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com [209.85.167.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E60D11871
	for <ell@lists.linux.dev>; Fri,  1 Jul 2022 13:32:47 +0000 (UTC)
Received: by mail-lf1-f44.google.com with SMTP id e12so3903781lfr.6
        for <ell@lists.linux.dev>; Fri, 01 Jul 2022 06:32:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=/hLvYs7sEwJvI3VTTxUUHhC+s9Axkwyt9+JhIeFsxbo=;
        b=qaHsuIbE9S2tYPLw2GgIDnbhEvhADPGUr/9cbskat8xNLbKB6VtmwxYFhXKaWutKl9
         Zn82Wn9dloPvguRI8zXmAlDzIsOCAfZQWDx7JT0CqSFAXMc3Jjq07xmXTTy4jkc3aTW+
         O7WT+6YiAvlr0rk82ZX8Di+DV2VNv/4UFHMn7S6AOSbIM6IYyagNNGuDUQGqdRrOXHt2
         eBUnFJeKij0cdawwjTB3/6wk/mzJYiDXUCHgyGlMWoY0ZO5/6wQpbTxXUrValBTP3xYC
         yXyfX44wcfRFQ0B55yqypwdp8WJbAww9D0kJmHmAkSsrcmD8+i7p4jNR0c3E7mupyh+y
         Ti2A==
X-Gm-Message-State: AJIora8QHHrfjaw7U5qWkjG0WtbcFT8Zy7I+yL1dI4Z8DuJcC/Xd5fJU
	waD2kAx56pBU5QFl2KxyHkNkdCEc+Vsb7C7x
X-Google-Smtp-Source: AGRyM1vvAZPufe61tyqAmkaQkrQ0kxnUJuMDg6Tc2J0syo88MJubaXkVgeFeYoDSncz22exiXNfFVA==
X-Received: by 2002:a05:6512:31cc:b0:47f:63ca:bfc8 with SMTP id j12-20020a05651231cc00b0047f63cabfc8mr8792578lfe.242.1656682365554;
        Fri, 01 Jul 2022 06:32:45 -0700 (PDT)
Received: from iss.home (79.184.238.213.ipv4.supernova.orange.pl. [79.184.238.213])
        by smtp.gmail.com with ESMTPSA id 11-20020a05651c128b00b0025a725af81csm3185815ljc.39.2022.07.01.06.32.44
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 01 Jul 2022 06:32:44 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/4] netconfig: Restore net.ipv6.conf...disable_ipv6 on stop
Date: Fri,  1 Jul 2022 15:32:36 +0200
Message-Id: <20220701133237.2887854-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
References: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since we write the net.ipv6.conf.<ifname>.disable_ipv6 option to 0 when
enabling DHCPv6, reset it to its original value when stopping netconfig.
---
 ell/netconfig.c | 69 ++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 59 insertions(+), 10 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 19aaf56..f48018b 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -35,6 +35,8 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <stdlib.h>
+#include <stdio.h>
 
 #include "private.h"
 #include "useful.h"
@@ -83,6 +85,7 @@ struct l_netconfig {
 	unsigned int ifaddr6_dump_cmd_id;
 	struct l_queue *icmp_route_data;
 	struct l_acd *acd;
+	unsigned int orig_disable_ipv6;
 
 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -962,14 +965,15 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 }
 
-static int netconfig_proc_write_ipv6_setting(struct l_netconfig *nc,
-						const char *setting,
-						const char *value)
+static int netconfig_proc_write_ipv6_uint_setting(struct l_netconfig *nc,
+							const char *setting,
+							unsigned int value)
 {
 	char ifname[IF_NAMESIZE];
 	_auto_(l_free) char *filename = NULL;
 	_auto_(close) int fd = -1;
 	int r;
+	char valuestr[20];
 
 	if (unlikely(!if_indextoname(nc->ifindex, ifname)))
 		return -errno;
@@ -981,10 +985,46 @@ static int netconfig_proc_write_ipv6_setting(struct l_netconfig *nc,
 	if (unlikely(fd < 0))
 		return -errno;
 
-	r = L_TFR(write(fd, value, strlen(value)));
+	snprintf(valuestr, sizeof(valuestr), "%u", value);
+	r = L_TFR(write(fd, valuestr, strlen(valuestr)));
 	return r > 0 ? 0 : -errno;
 }
 
+static long netconfig_proc_read_ipv6_uint_setting(struct l_netconfig *nc,
+							const char *setting)
+{
+	char ifname[IF_NAMESIZE];
+	_auto_(l_free) char *filename = NULL;
+	_auto_(close) int fd = -1;
+	int r;
+	char valuestr[20];
+	long value;
+	char *endp;
+
+	if (unlikely(!if_indextoname(nc->ifindex, ifname)))
+		return -errno;
+
+	filename = l_strdup_printf("/proc/sys/net/ipv6/conf/%s/%s",
+					ifname, setting);
+
+	fd = L_TFR(open(filename, O_RDONLY));
+	if (unlikely(fd < 0))
+		return -errno;
+
+	r = L_TFR(read(fd, valuestr, sizeof(valuestr) - 1));
+	if (unlikely(r < 1))
+		return r == 0 ? -EINVAL : -errno;
+
+	valuestr[r - 1] = '\0';
+	errno = 0;
+	value = strtoul(valuestr, &endp, 10);
+
+	if (unlikely(errno || !L_IN_SET(*endp, '\n', '\0')))
+		return -EINVAL;
+
+	return value;
+}
+
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 {
 	struct l_netconfig *nc;
@@ -1019,7 +1059,7 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 					nc, NULL);
 
 	/* Disable in-kernel autoconfiguration for the interface */
-	netconfig_proc_write_ipv6_setting(nc, "accept_ra", "0");
+	netconfig_proc_write_ipv6_uint_setting(nc, "accept_ra", 0);
 
 	return nc;
 }
@@ -1554,13 +1594,15 @@ static void netconfig_ifaddr_ipv6_dump_done_cb(void *user_data)
 	nc->ifaddr6_dump_cmd_id = 0;
 
 	/* "do not generate a link-local address" */
-	netconfig_proc_write_ipv6_setting(nc, "addr_gen_mode", "1");
+	netconfig_proc_write_ipv6_uint_setting(nc, "addr_gen_mode", 1);
 	/* "generate address based on EUI64 (default)" */
-	netconfig_proc_write_ipv6_setting(nc, "addr_gen_mode", "0");
-	/* "enable IPv6 operation" */
-	netconfig_proc_write_ipv6_setting(nc, "disable_ipv6", "0");
+	netconfig_proc_write_ipv6_uint_setting(nc, "addr_gen_mode", 0);
 
-	/* TODO: save original values and reset in l_netconfig_stop() */
+	/* "enable IPv6 operation" */
+	nc->orig_disable_ipv6 =
+		netconfig_proc_read_ipv6_uint_setting(nc, "disable_ipv6");
+	if (nc->orig_disable_ipv6)
+		netconfig_proc_write_ipv6_uint_setting(nc, "disable_ipv6", 0);
 }
 
 LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
@@ -1680,6 +1722,13 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 	l_dhcp6_client_stop(netconfig->dhcp6_client);
 
 	l_acd_destroy(l_steal_ptr(netconfig->acd));
+
+	if (netconfig->orig_disable_ipv6) {
+		netconfig_proc_write_ipv6_uint_setting(netconfig,
+						"disable_ipv6",
+						netconfig->orig_disable_ipv6);
+		netconfig->orig_disable_ipv6 = 0;
+	}
 }
 
 LIB_EXPORT struct l_dhcp_client *l_netconfig_get_dhcp_client(
-- 
2.34.1

