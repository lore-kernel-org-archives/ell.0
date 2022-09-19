Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C7964C79
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:11 +0000 (UTC)
Received: by mail-wm1-f51.google.com with SMTP id ay7-20020a05600c1e0700b003b49861bf48so3868761wmb.0
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date;
        bh=7tbpeBZOcBh9smpgVIA0WOBnMrzIAfe4ghmKBWYjmMY=;
        b=PO61Hkdk5X8vC1zpMswCT4E4mymYjab9OLQtvEGcyEDjoo2WYOM3syGmY9PRziF9MA
         1j+l6oS3YNksaoY9m/uKtm9MgBUrgJENRig15MXT1UYzwKr/3F742ge/80dHFyp3DvNn
         RqzpgX7qXR/kw08BUX9HuQsKj0IL322X6KdvLoNqn2a6eDAuEWD7T9GWl+mcvolC4XCJ
         mppBbOMnTVjnADdqaK2TsT1T3LCMYS/8xGluRD0m2JDaL13ntWw4Fad1cQOqcmXipARU
         m3VA/0Mrl5KkvD1KG3D+KTGtYiTWWc1j6O4BvDbQLPkHIOOZT3YiuHzwPz2IeUDKhMI+
         J8fQ==
X-Gm-Message-State: ACrzQf3JNbaAPeDB7Zc70d0jD1gss8Xog/1MaR6u++pzE8Wd1IEugVHs
	YFdhDmRanSGsdU64eDcUzrCWxmVFyraQ1g==
X-Google-Smtp-Source: AMsMyM4UX1ub9e9E3NKGtzZllYLENoIe4xYAgtcxWmSib6P7NRsabiiTEN2ClXMflVKz+rAgh9p36g==
X-Received: by 2002:a05:600c:5d3:b0:3b4:c326:d096 with SMTP id p19-20020a05600c05d300b003b4c326d096mr8112638wmd.98.1663594269407;
        Mon, 19 Sep 2022 06:31:09 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:08 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/7] icmp6: Save SLAAC prefixes from RAs
Date: Mon, 19 Sep 2022 15:30:59 +0200
Message-Id: <20220919133105.3129080-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In struct l_icmp6_router save the lists of prefixes for autoconfiguration
separately from routes.  The two sets of prefixes may overlap completely,
partially or not at all.  Drop the preferred_lifetime information from
route_info since this is strictly to be used as the preferred lifetime
for addresses generated through SLAAC and has nothing to do with routes.
---
 ell/icmp6-private.h |  7 ++++
 ell/icmp6.c         | 98 +++++++++++++++++++++++++++++++--------------
 ell/netconfig.c     |  7 +---
 3 files changed, 77 insertions(+), 35 deletions(-)

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index 77df0b8..a26639d 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -25,6 +25,11 @@ struct route_info {
 	bool onlink : 1;
 	uint8_t prefix_len;
 	uint8_t preference;
+	uint32_t valid_lifetime;
+};
+
+struct autoconf_prefix_info {
+	uint8_t prefix[8];
 	uint32_t preferred_lifetime;
 	uint32_t valid_lifetime;
 };
@@ -40,6 +45,8 @@ struct l_icmp6_router {
 	uint32_t max_rtr_adv_interval_ms;
 	uint32_t n_routes;
 	struct route_info *routes;
+	uint32_t n_ac_prefixes;
+	struct autoconf_prefix_info *ac_prefixes;
 };
 
 struct l_icmp6_router *_icmp6_router_new();
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 7319903..b71a98f 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -693,9 +693,58 @@ struct l_icmp6_router *_icmp6_router_new()
 void _icmp6_router_free(struct l_icmp6_router *r)
 {
 	l_free(r->routes);
+	l_free(r->ac_prefixes);
 	l_free(r);
 }
 
+/* Note: the following two write to @out even when they return false */
+static bool icmp6_prefix_parse_rt_info(const uint8_t *data,
+					struct route_info *out)
+{
+	out->prefix_len = data[2];
+	out->onlink = true;
+	out->preference = 0;
+	out->valid_lifetime = l_get_be32(data + 4);
+
+	/*
+	 * Only the initial Prefix Length bits of the prefix are valid.
+	 * The remaining bits "MUST" be ignored by the receiver.
+	 */
+	memcpy(out->address, net_prefix_from_ipv6(data + 16, out->prefix_len),
+		16);
+
+	if (out->prefix_len >= 10 && IN6_IS_ADDR_LINKLOCAL(out->address))
+		return false;
+
+	return true;
+}
+
+static bool icmp6_prefix_parse_ac_info(const uint8_t *data,
+					struct autoconf_prefix_info *out)
+{
+	/*
+	 * Per RFC4862 we need to silently ignore prefixes with a
+	 * preferred lifetime longer than valid lifetime, those with
+	 * 0 valid lifetime and those with link-local prefixes.
+	 * Prefix Length must be 8 bytes (IPv6 address - Interface ID).
+	 */
+	if (data[2] != 64)
+		return false;
+
+	if (IN6_IS_ADDR_LINKLOCAL(data + 16))
+		return false;
+
+	out->valid_lifetime = l_get_be32(data + 4);
+	out->preferred_lifetime = l_get_be32(data + 8);
+
+	if (out->valid_lifetime == 0 ||
+			out->preferred_lifetime > out->valid_lifetime)
+		return false;
+
+	memcpy(out->prefix, data + 16, 8);
+	return true;
+}
+
 struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 						size_t len,
 						const uint8_t src[static 16],
@@ -705,6 +754,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	const uint8_t *opts;
 	uint32_t opts_len;
 	uint32_t n_routes = 0;
+	uint32_t n_ac_prefixes = 0;
 
 	if (ra->nd_ra_type != ND_ROUTER_ADVERT)
 		return NULL;
@@ -742,6 +792,10 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 
 			if (opts[3] & ND_OPT_PI_FLAG_ONLINK)
 				n_routes += 1;
+
+			if (opts[3] & ND_OPT_PI_FLAG_AUTO)
+				n_ac_prefixes += 1;
+
 			break;
 		case ND_OPT_ROUTE_INFORMATION:
 			if (l < 8)
@@ -781,6 +835,8 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	memcpy(r->address, src, sizeof(r->address));
 	r->routes = l_new(struct route_info, n_routes);
 	r->n_routes = n_routes;
+	r->ac_prefixes = l_new(struct autoconf_prefix_info, n_ac_prefixes);
+	r->n_ac_prefixes = n_ac_prefixes;
 
 	if (ra->nd_ra_flags_reserved & ND_RA_FLAG_MANAGED)
 		r->managed = true;
@@ -798,6 +854,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	opts = (uint8_t *) (ra + 1);
 	opts_len = len - sizeof(struct nd_router_advert);
 	n_routes = 0;
+	n_ac_prefixes = 0;
 
 	while (opts_len) {
 		uint8_t t = opts[0];
@@ -814,41 +871,22 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 
 			break;
 		case ND_OPT_PREFIX_INFORMATION:
-		{
-			struct route_info *i = &r->routes[n_routes];
-
-			if (!(opts[3] & ND_OPT_PI_FLAG_ONLINK))
-				break;
+			if (opts[3] & ND_OPT_PI_FLAG_ONLINK) {
+				struct route_info *i = &r->routes[n_routes];
 
-			i->prefix_len = opts[2];
-			i->onlink = true;
-			i->valid_lifetime = l_get_be32(opts + 4);
-			i->preferred_lifetime = l_get_be32(opts + 8);
-
-			/*
-			 * Only the initial Prefix Length bits of the prefix
-			 * are valid.  The remaining bits "MUST" be ignored
-			 * by the receiver.
-			 */
-			memcpy(i->address, net_prefix_from_ipv6(opts + 16,
-							i->prefix_len), 16);
+				if (icmp6_prefix_parse_rt_info(opts, i))
+					n_routes++;
+			}
 
-			/*
-			 * For SLAAC (RFC4862) we need to "silently ignore"
-			 * routes with a preferred lifetime longer than valid
-			 * lifetime, and those with the link-local prefix.
-			 * Since it makes sense, do it regardless of SLAAC.
-			 */
-			if (i->preferred_lifetime > i->valid_lifetime)
-				break;
+			if (opts[3] & ND_OPT_PI_FLAG_AUTO) {
+				struct autoconf_prefix_info *i =
+					&r->ac_prefixes[n_ac_prefixes];
 
-			if (i->prefix_len >= 10 &&
-					IN6_IS_ADDR_LINKLOCAL(i->address))
-				break;
+				if (icmp6_prefix_parse_ac_info(opts, i))
+					n_ac_prefixes++;
+			}
 
-			n_routes += 1;
 			break;
-		}
 		case ND_OPT_RTR_ADV_INTERVAL:
 			if (l < 8)
 				break;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index 29e95b7..bbe1dec 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -799,7 +799,6 @@ static bool netconfig_check_route_need_update(
 static void netconfig_set_icmp6_route_data(struct l_netconfig *nc,
 						struct netconfig_route_data *rd,
 						const struct l_icmp6_router *ra,
-						uint32_t preferred_lifetime,
 						uint32_t valid_lifetime,
 						uint32_t mtu, bool updated)
 {
@@ -916,10 +915,10 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 		 * netconfig_set_icmp6_route_data.
 		 */
 		netconfig_set_icmp6_route_data(nc, default_rd, r, r->lifetime,
-						r->lifetime, r->mtu, false);
+						r->mtu, false);
 	} else if (default_rd && r->lifetime)
 		netconfig_set_icmp6_route_data(nc, default_rd, r, r->lifetime,
-						r->lifetime, r->mtu, true);
+						r->mtu, true);
 	else if (default_rd && !r->lifetime)
 		netconfig_remove_icmp6_route(nc, default_rd);
 
@@ -941,12 +940,10 @@ static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
 				continue;
 
 			netconfig_set_icmp6_route_data(nc, rd, r,
-						info->preferred_lifetime,
 						info->valid_lifetime,
 						gateway ? r->mtu : 0, false);
 		} else if (rd && info->valid_lifetime)
 			netconfig_set_icmp6_route_data(nc, rd, r,
-						info->preferred_lifetime,
 						info->valid_lifetime,
 						gateway ? r->mtu : 0, true);
 		else if (rd && !info->valid_lifetime)
-- 
2.34.1

