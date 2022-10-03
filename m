Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0F3C33C9
	for <ell@lists.linux.dev>; Mon,  3 Oct 2022 22:29:05 +0000 (UTC)
Received: by mail-wr1-f51.google.com with SMTP id bk15so18691113wrb.13
        for <ell@lists.linux.dev>; Mon, 03 Oct 2022 15:29:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=TVzIy4OOYGtD8U3hCNP460aQxBdJlNFEpxfDuXjjKsg=;
        b=MsW0SRpJuI5qKCzJ1jjYU4ruQvOf5+9GQ8JJJQGiC/a554nAiTXfZFK3LJmlsrBb/t
         p0lzlOOuXc3zKsiQYHYh8rQ85aJ+hdPbXKRl0XLz2wa/FJ8GCzn584382KC0DJpD6DUG
         QkLClRptJPaacbVcKYbSo5CAzUE8Zs9d9CXTa9zKsDgSTi6S5kuz1Gbatn2vyEtYL1bv
         StVi+RmuPrElejRKZJCfNHtEPQm9imCexjknzVfp9/ga1QEJiG639ONiP0QMeKFIOCze
         FvaF9fqhKIxKXYosbnPkTgCsIt2seYWlpl8AUtQ+4N7apH9H7px/A16T3cPN3qo9YrQg
         UG8g==
X-Gm-Message-State: ACrzQf2q9s3Zg1/Y/VcQ6bY75MewYEocHF1Jf/64CLmScAmwAAtJB+G/
	l4EJD45T6fwF0cZ76weOLZKsgtVn6ebvfQ==
X-Google-Smtp-Source: AMsMyM6OdAzArzqVwaQ5UTfqBrcCXyv/JTvZ78ekT5RRqXNHvb7+pJ/Ebt+Oe0QeplCVsvdVsnvm3g==
X-Received: by 2002:a05:6000:78a:b0:22e:4c41:9e36 with SMTP id bu10-20020a056000078a00b0022e4c419e36mr369513wrb.160.1664836143734;
        Mon, 03 Oct 2022 15:29:03 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id l9-20020a056000022900b0022b315b4649sm10434207wrz.26.2022.10.03.15.29.02
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Oct 2022 15:29:03 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/5] netconfig: Stop ongoing work on failure
Date: Tue,  4 Oct 2022 00:28:46 +0200
Message-Id: <20221003222847.699047-4-andrew.zaborowski@intel.com>
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

When we emit L_NETCONFIG_EVENT_FAILED for either address family, stop
any timeouts and processing of events for that family.  The assumption
was that the user will call l_netconfig_unconfigure() and/or
l_netconfig_stop() when this happens but the user may want to ignore one
of the address families setup failing and continue with the other one.
---
 ell/netconfig.c | 53 ++++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 23 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 7aac5ad..76b18a7 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -188,6 +188,24 @@ static void netconfig_emit_event(struct l_netconfig *nc, uint8_t family,
 		netconfig_update_cleanup(nc);
 }
 
+static void netconfig_addr_wait_unregister(struct l_netconfig *nc,
+						bool in_notify);
+
+static void netconfig_failed(struct l_netconfig *nc, uint8_t family)
+{
+	if (family == AF_INET) {
+		l_dhcp_client_stop(nc->dhcp_client);
+		l_acd_destroy(l_steal_ptr(nc->acd));
+	} else {
+		netconfig_addr_wait_unregister(nc, false);
+		l_dhcp6_client_stop(nc->dhcp6_client);
+		l_icmp6_client_stop(nc->icmp6_client);
+		l_timeout_remove(l_steal_ptr(nc->ra_timeout));
+	}
+
+	netconfig_emit_event(nc, family, L_NETCONFIG_EVENT_FAILED);
+}
+
 static struct l_rtnl_route *netconfig_route_new(struct l_netconfig *nc,
 						uint8_t family,
 						const void *dst,
@@ -523,8 +541,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
 			netconfig_emit_event(nc, AF_INET,
 						L_NETCONFIG_EVENT_UNCONFIGURE);
 		else
-			netconfig_emit_event(nc, AF_INET,
-						L_NETCONFIG_EVENT_FAILED);
+			netconfig_failed(nc, AF_INET);
 
 		break;
 	case L_DHCP_CLIENT_EVENT_NO_LEASE:
@@ -539,8 +556,7 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
 		 * better yet a configurable timeout.
 		 */
 		if (!l_dhcp_client_start(nc->dhcp_client))
-			netconfig_emit_event(nc, AF_INET,
-						L_NETCONFIG_EVENT_FAILED);
+			netconfig_failed(nc, AF_INET);
 
 		break;
 	}
@@ -656,8 +672,7 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 			netconfig_emit_event(nc, AF_INET6,
 						L_NETCONFIG_EVENT_UNCONFIGURE);
 		else
-			netconfig_emit_event(nc, AF_INET6,
-						L_NETCONFIG_EVENT_FAILED);
+			netconfig_failed(nc, AF_INET6);
 
 		break;
 	case L_DHCP6_CLIENT_EVENT_LEASE_RENEWED:
@@ -686,8 +701,7 @@ static void netconfig_dhcp6_event_handler(struct l_dhcp6_client *client,
 		 * or better yet a configurable timeout.
 		 */
 		if (!l_dhcp6_client_start(nc->dhcp6_client))
-			netconfig_emit_event(nc, AF_INET6,
-						L_NETCONFIG_EVENT_FAILED);
+			netconfig_failed(nc, AF_INET6);
 
 		break;
 	}
@@ -727,11 +741,8 @@ static void netconfig_ra_timeout_cb(struct l_timeout *timeout, void *user_data)
 {
 	struct l_netconfig *nc = user_data;
 
-	l_timeout_remove(l_steal_ptr(nc->ra_timeout));
-
 	/* No Router Advertisements received, assume no DHCPv6 or SLAAC */
-	l_icmp6_client_stop(nc->icmp6_client);
-	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+	netconfig_failed(nc, AF_INET6);
 }
 
 static void netconfig_add_slaac_address(struct l_netconfig *nc,
@@ -1238,8 +1249,7 @@ process_nondefault_routes:
 		l_dhcp6_client_set_stateless(nc->dhcp6_client, false);
 
 		if (!netconfig_check_start_dhcp6(nc)) {
-			netconfig_emit_event(nc, AF_INET6,
-						L_NETCONFIG_EVENT_FAILED);
+			netconfig_failed(nc, AF_INET6);
 			return;
 		}
 
@@ -1279,7 +1289,7 @@ process_nondefault_routes:
 
 	/* Neither method seems available, fail */
 	if (nc->v6_auto_method == NETCONFIG_V6_METHOD_UNSET) {
-		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+		netconfig_failed(nc, AF_INET6);
 		return;
 	}
 
@@ -1777,7 +1787,7 @@ static void netconfig_ipv4_acd_event(enum l_acd_event event, void *user_data)
 		 * Conflict found, no IP was actually set or routes added so
 		 * just emit the event.
 		 */
-		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_FAILED);
+		netconfig_failed(nc, AF_INET);
 		break;
 	case L_ACD_EVENT_LOST:
 		if (L_WARN_ON(!nc->v4_configured))
@@ -1790,7 +1800,7 @@ static void netconfig_ipv4_acd_event(enum l_acd_event event, void *user_data)
 		 */
 		netconfig_remove_v4_address_routes(nc, false);
 		nc->v4_configured = false;
-		netconfig_emit_event(nc, AF_INET, L_NETCONFIG_EVENT_FAILED);
+		netconfig_failed(nc, AF_INET);
 		break;
 	}
 }
@@ -1911,10 +1921,8 @@ static void netconfig_ifaddr_ipv6_added(struct l_netconfig *nc,
 	 * Only now that we have a link-local address see if we can start
 	 * actual DHCPv6 setup.
 	 */
-	if (new_lla && netconfig_check_start_dhcp6(nc))
-		return;
-
-	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+	if (new_lla && !netconfig_check_start_dhcp6(nc))
+		netconfig_failed(nc, AF_INET6);
 }
 
 static void netconfig_ifaddr_ipv6_notify(uint16_t type, const void *data,
@@ -1951,8 +1959,7 @@ static void netconfig_ifaddr_ipv6_dump_cb(int error, uint16_t type,
 		return;
 
 	if (error) {
-		netconfig_addr_wait_unregister(nc, false);
-		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_FAILED);
+		netconfig_failed(nc, AF_INET6);
 		return;
 	}
 
-- 
2.34.1

