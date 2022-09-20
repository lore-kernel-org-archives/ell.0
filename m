Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D71E01C14
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:09 +0000 (UTC)
Received: by mail-wm1-f49.google.com with SMTP id n8so1928669wmr.5
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=AZi3cbry6UKzY4JlMsSbIQlN6BVUAUgZlnk+ekcym10=;
        b=6KixW1z+4SNGB8xxTUELVb7AJ8Nr3lPY7GIlj0sGvi0A1s7gXIWoy2VNToJ8am5APV
         zIl7JqMZ3kKxR7F1By3C8h+TtKo/acnlKoiqh0xg0HLS2iFmJ17Ya+LkzZtxU931C2eq
         9AC006aJ8tTTU1ApOpzkPA+gCrUT+hU5Byn1a4MvSHwz7fXH27bEg9/y0FbghMt8pKhY
         Bu3sD8AeE/8A6pXfQTZQVd/vSmYDrlp1AmT9rbcgx4/99c9xL8EYoujdynVOc7H4OA6/
         FJUN+u3CULQtiraEgWPYOUykBH0dTAj4Zo4GGT30JkWvnakV51LUVQTfTUx0lX5HZLRH
         n+yQ==
X-Gm-Message-State: ACrzQf2lTKGLmsgDNfPaBTUxbu0mG5XsMzkB/Ldf5Wch2jhYYkS5MxLM
	JZnIoOA+UKn27aLVKup5tBlJG5kAZQtvCue0
X-Google-Smtp-Source: AMsMyM7nPKTymL4mLW57nLO5LSBu86baNXFWfbY3krDIXyDEi3jPwXUVfTiB+4zGJpzR+MNTO/uEaA==
X-Received: by 2002:a7b:cb49:0:b0:3b4:b08a:89b with SMTP id v9-20020a7bcb49000000b003b4b08a089bmr2405898wmj.173.1663680727712;
        Tue, 20 Sep 2022 06:32:07 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.06
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:07 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/6] netconfig: Handle DNS data from l_icmp6_router
Date: Tue, 20 Sep 2022 15:31:59 +0200
Message-Id: <20220920133201.3303119-4-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
References: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Track the lists of DNSes and search domains based on Router Advertisement
options parsed by l_icmp6_client.  Return them in
l_netconfig_get_dns_list, l_netconfig_get_domain_names.
---
 ell/netconfig.c | 160 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 154 insertions(+), 6 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index e5c7b51..765703b 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -98,6 +98,8 @@ struct l_netconfig {
 		NETCONFIG_V6_METHOD_DHCP,
 		NETCONFIG_V6_METHOD_SLAAC,
 	} v6_auto_method;
+	struct l_queue *slaac_dnses;
+	struct l_queue *slaac_domains;
 
 	/* These objects, if not NULL, are owned by @addresses and @routes */
 	struct l_rtnl_address *v4_address;
@@ -151,6 +153,8 @@ static struct l_queue *addr_wait_list;
 static unsigned int rtnl_id;
 
 static const unsigned int max_icmp6_routes = 100;
+static const unsigned int max_icmp6_dnses = 10;
+static const unsigned int max_icmp6_domains = 10;
 
 static void netconfig_update_cleanup(struct l_netconfig *nc)
 {
@@ -681,6 +685,16 @@ static bool netconfig_match(const void *a, const void *b)
 	return a == b;
 }
 
+static bool netconfig_match_addr(const void *a, const void *b)
+{
+	return memcmp(a, b, 16) == 0;
+}
+
+static bool netconfig_match_str(const void *a, const void *b)
+{
+	return strcmp(a, b) == 0;
+}
+
 static bool netconfig_check_start_dhcp6(struct l_netconfig *nc)
 {
 	/* Don't start DHCPv6 until we get an RA with the managed bit set */
@@ -809,6 +823,88 @@ static void netconfig_set_slaac_address_lifetimes(struct l_netconfig *nc,
 		l_queue_push_tail(nc->addresses.updated, nc->v6_address);
 }
 
+static bool netconfig_process_slaac_dns_info(struct l_netconfig *nc,
+						const struct l_icmp6_router *r)
+{
+	bool updated = false;
+	unsigned int i;
+	unsigned int n_dns = l_queue_length(nc->slaac_dnses);
+	unsigned int n_domains = l_queue_length(nc->slaac_domains);
+
+	for (i = 0; i < r->n_dns; i++) {
+		const struct dns_info *info = &r->dns_list[i];
+
+		/*
+		 * For simplicity don't track lifetimes (TODO), add entries
+		 * when the lifetime is non-zero, remove them when the
+		 * lifetime is zero.  We have no API to add time-limited
+		 * entries to the system either.
+		 *
+		 * RFC8106 Section 5.1: "A value of zero means that the RDNSS
+		 * addresses MUST no longer be used."
+		 */
+		if (info->lifetime) {
+			if (n_dns >= max_icmp6_dnses)
+				continue;
+
+			if (l_queue_find(nc->slaac_dnses, netconfig_match_addr,
+						info->address))
+				continue;
+
+			l_queue_push_tail(nc->slaac_dnses,
+						l_memdup(info->address, 16));
+			n_dns++;
+		} else {
+			void *addr = l_queue_remove_if(nc->slaac_dnses,
+							netconfig_match_addr,
+							info->address);
+
+			if (!addr)
+				continue;
+
+			l_free(addr);
+			n_dns--;
+		}
+
+		updated = true;
+	}
+
+	for (i = 0; i < r->n_domains; i++) {
+		const struct domain_info *info = &r->domains[i];
+
+		/*
+		 * RFC8106 Section 5.2: "A value of zero means that the DNSSL
+		 * domain names MUST no longer be used."
+		 */
+		if (info->lifetime) {
+			if (n_domains >= max_icmp6_domains)
+				continue;
+
+			if (l_queue_find(nc->slaac_domains, netconfig_match_str,
+						info->domain))
+				continue;
+
+			l_queue_push_tail(nc->slaac_domains,
+						l_strdup(info->domain));
+			n_domains++;
+		} else {
+			void *str = l_queue_remove_if(nc->slaac_domains,
+							netconfig_match_str,
+							info->domain);
+
+			if (!str)
+				continue;
+
+			l_free(str);
+			n_domains--;
+		}
+
+		updated = true;
+	}
+
+	return updated;
+}
+
 static uint64_t now;
 
 static bool netconfig_check_route_expired(void *data, void *user_data)
@@ -1027,6 +1123,7 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 	const struct l_icmp6_router *r;
 	struct netconfig_route_data *default_rd;
 	unsigned int i;
+	bool dns_updated = false;
 
 	if (event != L_ICMP6_CLIENT_EVENT_ROUTER_FOUND)
 		return;
@@ -1122,6 +1219,14 @@ process_nondefault_routes:
 			r->n_ac_prefixes) {
 		nc->v6_auto_method = NETCONFIG_V6_METHOD_SLAAC;
 
+		/*
+		 * Do this first so that any changes are included in the
+		 * CONFIGURE event emitted next.
+		 */
+		nc->slaac_dnses = l_queue_new();
+		nc->slaac_domains = l_queue_new();
+		netconfig_process_slaac_dns_info(nc, r);
+
 		/*
 		 * The DAD for the link-local address may be still running
 		 * but again we can generate the global address already and
@@ -1156,6 +1261,7 @@ process_nondefault_routes:
 	 * and allows us to extend its lifetime.
 	 */
 	netconfig_set_slaac_address_lifetimes(nc, r);
+	dns_updated = netconfig_process_slaac_dns_info(nc, r);
 
 emit_event:
 	/*
@@ -1168,7 +1274,8 @@ emit_event:
 			!l_queue_isempty(nc->routes.updated) ||
 			!l_queue_isempty(nc->routes.removed) ||
 			!l_queue_isempty(nc->routes.expired) ||
-			!l_queue_isempty(nc->addresses.updated))
+			!l_queue_isempty(nc->addresses.updated) ||
+			dns_updated)
 		netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_UPDATE);
 }
 
@@ -2007,6 +2114,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 	l_queue_clear(netconfig->routes.current,
 			(l_queue_destroy_func_t) l_rtnl_route_free);
 	l_queue_clear(netconfig->icmp_route_data, l_free);
+	l_queue_clear(netconfig->slaac_dnses, l_free);
+	l_queue_clear(netconfig->slaac_domains, l_free);
 	netconfig->v4_address = NULL;
 	netconfig->v4_subnet_route = NULL;
 	netconfig->v4_default_route = NULL;
@@ -2255,9 +2364,31 @@ append_v6:
 
 	if (netconfig->v6_dns_override)
 		netconfig_strv_cat(&ret, netconfig->v6_dns_override, false);
-	else if ((v6_lease =
-			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_DHCP &&
+			(v6_lease = l_dhcp6_client_get_lease(
+						netconfig->dhcp6_client)))
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_dns(v6_lease), true);
+	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC &&
+			!l_queue_isempty(netconfig->slaac_dnses)) {
+		unsigned int dest_len = l_strv_length(ret);
+		unsigned int src_len = l_queue_length(netconfig->slaac_dnses);
+		char **i;
+		const struct l_queue_entry *entry;
+
+		ret = l_realloc(ret, sizeof(char *) * (dest_len + src_len + 1));
+		i = ret + dest_len;
+
+		for (entry = l_queue_get_entries(netconfig->slaac_dnses);
+				entry; entry = entry->next) {
+			char addr_str[INET6_ADDRSTRLEN];
+
+			if (inet_ntop(AF_INET6, entry->data, addr_str,
+					sizeof(addr_str)))
+				*i++ = l_strdup(addr_str);
+		}
+
+		*i = NULL;
+	}
 
 done:
 	return ret;
@@ -2288,13 +2419,30 @@ append_v6:
 	if (!netconfig->v6_configured)
 		goto done;
 
-	if (netconfig->v6_dns_override)
+	if (netconfig->v6_domain_names_override)
 		netconfig_strv_cat(&ret, netconfig->v6_domain_names_override,
 					false);
-	else if ((v6_lease =
-			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_DHCP &&
+			(v6_lease = l_dhcp6_client_get_lease(
+						netconfig->dhcp6_client)))
 		netconfig_strv_cat(&ret, l_dhcp6_lease_get_domains(v6_lease),
 					true);
+	else if (netconfig->v6_auto_method == NETCONFIG_V6_METHOD_SLAAC &&
+			!l_queue_isempty(netconfig->slaac_domains)) {
+		unsigned int dest_len = l_strv_length(ret);
+		unsigned int src_len = l_queue_length(netconfig->slaac_domains);
+		char **i;
+		const struct l_queue_entry *entry;
+
+		ret = l_realloc(ret, sizeof(char *) * (dest_len + src_len + 1));
+		i = ret + dest_len;
+
+		for (entry = l_queue_get_entries(netconfig->slaac_domains);
+				entry; entry = entry->next)
+			*i++ = l_strdup(entry->data);
+
+		*i = NULL;
+	}
 
 done:
 	return ret;
-- 
2.34.1

