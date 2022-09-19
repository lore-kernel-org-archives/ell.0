Received: from mail-wr1-f44.google.com (mail-wr1-f44.google.com [209.85.221.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9983D4C7C
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:12 +0000 (UTC)
Received: by mail-wr1-f44.google.com with SMTP id n10so16952174wrw.12
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=3R9INdt9TpcZUy6qK3CoAew1LarerMroyK/3WMLXTO8=;
        b=I9EnSHO5z9bSWEyDOOLeihHswlALK+DBgAnwmj/6kOOOtHtEYdDF4qf/OoZJFKUw/5
         SPN66y5yQLDEEu+Dcgf8TR/AZz74llqSGsLvLQDh7y+o8KaXASGUw9ogXtYy3Vm1sbL5
         iI9l2LmsFuCTSaVmd2WUy1XbdbI1rmQyKAt5o8YdIBNMbyVRAoOH6jGSpTICIMxD8adJ
         Dk9RDCopzpnkoGEvTXV0MKNsuuf5DP0OA9iGHknT5b1L6YeE8xwZyXnep8vAY2jyIJRE
         RyOVXYM+URnXaW2VS+0c+0KO6T+P5ZcvY3VwSIp3e27rkt+Q0KNKgh+71d2NumtB+H3p
         ir/g==
X-Gm-Message-State: ACrzQf2qQ8eOq/WW3AYM+LLbg6JKbr5HW3Q4Si2kLBANp9k8vJg1BQM8
	hPyNtbCmhyjzHoE0mdH7Vs9gsGqmQOqFkQ==
X-Google-Smtp-Source: AMsMyM5Hjp7ZxyP/8a2zg+Kptuy/utlsv6aoXLnQyM0gzsXeyoKkqPwMwOXLUcs0nuVsa+O9tTbkSg==
X-Received: by 2002:a5d:47c5:0:b0:22a:6d4c:f21e with SMTP id o5-20020a5d47c5000000b0022a6d4cf21emr10814105wrc.417.1663594270521;
        Mon, 19 Sep 2022 06:31:10 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.09
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:10 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/7] icmp6: Parse RDNSS and DNSSL options
Date: Mon, 19 Sep 2022 15:31:00 +0200
Message-Id: <20220919133105.3129080-2-andrew.zaborowski@intel.com>
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

Save the list of DNS server addresses and the local domain search list
from Router Advertisements in the l_icmp6_router structure.
---
 ell/icmp6-private.h | 14 +++++++
 ell/icmp6.c         | 94 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index a26639d..f207164 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -34,6 +34,16 @@ struct autoconf_prefix_info {
 	uint32_t valid_lifetime;
 };
 
+struct dns_info {
+	uint8_t address[16];
+	uint32_t lifetime;
+};
+
+struct domain_info {
+	char *domain;
+	uint32_t lifetime;
+};
+
 struct l_icmp6_router {
 	uint8_t address[16];
 	bool managed : 1;
@@ -47,6 +57,10 @@ struct l_icmp6_router {
 	struct route_info *routes;
 	uint32_t n_ac_prefixes;
 	struct autoconf_prefix_info *ac_prefixes;
+	uint32_t n_dns;
+	struct dns_info *dns_list;
+	uint32_t n_domains;
+	struct domain_info *domains;
 };
 
 struct l_icmp6_router *_icmp6_router_new();
diff --git a/ell/icmp6.c b/ell/icmp6.c
index b71a98f..c38df17 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -50,6 +50,7 @@
 #include "netlink.h"
 #include "rtnl.h"
 #include "missing.h"
+#include "utf8.h"
 #include "icmp6.h"
 #include "icmp6-private.h"
 
@@ -58,6 +59,14 @@
 #define ND_OPT_ROUTE_INFORMATION	24
 #endif
 
+/* RFC8106 */
+#ifndef ND_OPT_RECURSIVE_DNS_SERVER
+#define ND_OPT_RECURSIVE_DNS_SERVER	25
+#endif
+#ifndef ND_OPT_DNS_SEARCH_LIST
+#define ND_OPT_DNS_SEARCH_LIST		31
+#endif
+
 #define CLIENT_DEBUG(fmt, args...)					\
 	l_util_debug(client->debug_handler, client->debug_data,		\
 			"%s:%i " fmt, __func__, __LINE__, ## args)
@@ -755,6 +764,8 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	uint32_t opts_len;
 	uint32_t n_routes = 0;
 	uint32_t n_ac_prefixes = 0;
+	uint32_t n_dns = 0;
+	uint32_t n_domains = 0;
 
 	if (ra->nd_ra_type != ND_ROUTER_ADVERT)
 		return NULL;
@@ -824,8 +835,48 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 				break;
 
 			n_routes += 1;
+			break;
+		case ND_OPT_RECURSIVE_DNS_SERVER:
+			if (l < 24 || (l & 15) != 8)
+				return NULL;
+
+			n_dns += (l - 8) / 16;
+			break;
+		case ND_OPT_DNS_SEARCH_LIST:
+		{
+			unsigned int n_labels;
+			unsigned int pos = 8;
+
+			if (l < 16)
+				return NULL;
+
+			/* Count domains according to RFC1035 Section 3.1 */
+			do {
+				unsigned int label_len;
+
+				n_labels = 0;
+
+				do {
+					label_len = opts[pos];
+					pos += 1 + label_len;
+					n_labels += label_len ? 1 : 0;
+				} while (label_len && pos < l);
+
+				/*
+				 * Check if the root label was missing, or
+				 * a label didn't fit in the option bytes, or
+				 * the first domain had 0 labels, i.e. there
+				 * were no domains.
+				 */
+				if (label_len || pos > l || pos == 9)
+					return NULL;
+
+				n_domains += n_labels ? 1 : 0;
+			} while (n_labels && pos < l);
+
 			break;
 		}
+		}
 
 		opts += l;
 		opts_len -= l;
@@ -834,9 +885,9 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	r = _icmp6_router_new();
 	memcpy(r->address, src, sizeof(r->address));
 	r->routes = l_new(struct route_info, n_routes);
-	r->n_routes = n_routes;
 	r->ac_prefixes = l_new(struct autoconf_prefix_info, n_ac_prefixes);
-	r->n_ac_prefixes = n_ac_prefixes;
+	r->dns_list = l_new(struct dns_info, n_dns);
+	r->domains = l_new(struct domain_info, n_domains);
 
 	if (ra->nd_ra_flags_reserved & ND_RA_FLAG_MANAGED)
 		r->managed = true;
@@ -855,6 +906,8 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 	opts_len = len - sizeof(struct nd_router_advert);
 	n_routes = 0;
 	n_ac_prefixes = 0;
+	n_dns = 0;
+	n_domains = 0;
 
 	while (opts_len) {
 		uint8_t t = opts[0];
@@ -946,12 +999,49 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 			n_routes += 1;
 			break;
 		}
+		case ND_OPT_RECURSIVE_DNS_SERVER:
+		{
+			unsigned int pos;
+
+			for (pos = 8; pos < l; pos += 16) {
+				struct dns_info *i = &r->dns_list[n_dns++];
+
+				i->lifetime = l_get_be32(opts + 4);
+				memcpy(i->address, opts + pos, 16);
+			}
+
+			break;
+		}
+		case ND_OPT_DNS_SEARCH_LIST:
+		{
+			struct domain_info *info = &r->domains[n_domains];
+			_auto_(l_free) char **domain_list =
+				net_domain_list_parse(opts + 8, l - 8);
+			char **i;
+
+			/* Ignore invalid option */
+			if (!domain_list)
+				break;
+
+			for (i = domain_list; *i; i++) {
+				info->lifetime = l_get_be32(opts + 4);
+				info->domain = *i;
+				info++;
+				n_domains++;
+			}
+
+			break;
+		}
 		}
 
 		opts += l;
 		opts_len -= l;
 	}
 
+	r->n_routes = n_routes;
+	r->n_ac_prefixes = n_ac_prefixes;
+	r->n_dns = n_dns;
+	r->n_domains = n_domains;
 	return r;
 }
 
-- 
2.34.1

