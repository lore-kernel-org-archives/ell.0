Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D1001C14
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:07 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id g3so4243842wrq.13
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date;
        bh=p+uD+/L+jxWQUGdqxtyjWsUrv0xM55qHt3jLx4B27ZA=;
        b=yOikbv0ZG3i9dHEVoMrn4o6X1UBAip2ytFX5rmz8h52pSXZjj/40zRb5BDDzfYBjd9
         JtH+CJcUrSrOMv8a8hbh5W1J7hbWr7jVl++CtoNb+e/JgEuOqdIvkPztaviWxIL94WDe
         L+KN0g1AxN4AzJbZMdtGnLL1uWdsYz5rxHAdLwNtBdnsl2A4mw49R63wjPUP10umqHL/
         kpk0XNPgCzt8TvtODQ2Aph23aON9YcnlXuH9Dv328al9wEJUV7L3EdJH6TJXyJnWLZY7
         v/woboeChFzcz0/t/AKgMkTzv5xZs+TX262UVlw1xE1nw/TIGYQxvOqUktAR6Fpx6NwB
         +L9Q==
X-Gm-Message-State: ACrzQf2RlKVIEsNG1bK9W6MQaADDnnkkDd5aMaPPMzxtID+LA44pncev
	ruzykAMJkbv9nX6X958tA1s8FbXo/MGL8yyl
X-Google-Smtp-Source: AMsMyM488yun7hSrNNQGDXFfXd7nUVx4w/G2/vMlbM3wZH7mzPPsWDabZOX5zHCz2DhmWyWLpnpDlg==
X-Received: by 2002:a5d:52cb:0:b0:21a:3cc5:f5f4 with SMTP id r11-20020a5d52cb000000b0021a3cc5f5f4mr14548670wrv.367.1663680725087;
        Tue, 20 Sep 2022 06:32:05 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.04
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:04 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/6] net: Allow padding in net_domain_list_parse
Date: Tue, 20 Sep 2022 15:31:56 +0200
Message-Id: <20220920133201.3303119-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The domain name lists in ICMPv6 options may be 0-padded meaning that a
0-byte at the beginning of a domain record (ie. a domain with no labels)
is allowed and should be treated as the end of the list.  Add a boolean
parameter to tell net_domain_list_parse() whether to allow this.

Fixes: 4b1ce9b3e3d0 ("icmp6: Parse RDNSS and DNSSL options")
---
 ell/dhcp6-lease.c | 2 +-
 ell/icmp6.c       | 6 +++---
 ell/net-private.h | 2 +-
 ell/net.c         | 8 +++++++-
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/ell/dhcp6-lease.c b/ell/dhcp6-lease.c
index 978176a..a92cff9 100644
--- a/ell/dhcp6-lease.c
+++ b/ell/dhcp6-lease.c
@@ -312,7 +312,7 @@ struct l_dhcp6_lease *_dhcp6_lease_parse_options(
 			lease->rapid_commit = true;
 			break;
 		case L_DHCP6_OPTION_DOMAIN_LIST:
-			lease->domain_list = net_domain_list_parse(v, l);
+			lease->domain_list = net_domain_list_parse(v, l, false);
 			if (!lease->domain_list)
 				goto error;
 
diff --git a/ell/icmp6.c b/ell/icmp6.c
index a2765ea..5ddc494 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -1104,11 +1104,11 @@ struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *ra,
 		{
 			struct domain_info *info = &r->domains[n_domains];
 			_auto_(l_free) char **domain_list =
-				net_domain_list_parse(opts + 8, l - 8);
+				net_domain_list_parse(opts + 8, l - 8, true);
 			char **i;
 
-			/* Ignore invalid option */
-			if (!domain_list)
+			/* Ignore malformed option */
+			if (!domain_list || !domain_list[0])
 				break;
 
 			for (i = domain_list; *i; i++) {
diff --git a/ell/net-private.h b/ell/net-private.h
index 39d4d98..a864034 100644
--- a/ell/net-private.h
+++ b/ell/net-private.h
@@ -21,7 +21,7 @@
  */
 
 char *net_domain_name_parse(const uint8_t *raw, size_t raw_len);
-char **net_domain_list_parse(const uint8_t *raw, size_t raw_len);
+char **net_domain_list_parse(const uint8_t *raw, size_t raw_len, bool padded);
 
 static inline const void *net_prefix_from_ipv6(const uint8_t *address,
 						uint8_t prefix_len)
diff --git a/ell/net.c b/ell/net.c
index 378b9f2..aa7fc20 100644
--- a/ell/net.c
+++ b/ell/net.c
@@ -295,7 +295,7 @@ char *net_domain_name_parse(const uint8_t *raw, size_t raw_len)
 /*
  * Parse list of domain names encoded according to RFC 1035 Section 3.1
  */
-char **net_domain_list_parse(const uint8_t *raw, size_t raw_len)
+char **net_domain_list_parse(const uint8_t *raw, size_t raw_len, bool padded)
 {
 	size_t remaining = raw_len;
 	const uint8_t *p = raw;
@@ -305,6 +305,9 @@ char **net_domain_list_parse(const uint8_t *raw, size_t raw_len)
 	struct l_string *growable = NULL;
 
 	while (remaining) {
+		if (padded && p[0] == 0)
+			break;
+
 		r = validate_next_domain_name(p, remaining);
 		if (r < 0)
 			return NULL;
@@ -323,6 +326,9 @@ char **net_domain_list_parse(const uint8_t *raw, size_t raw_len)
 		remaining -= *p + 1;
 
 		if (*p == 0) {
+			if (!growable)
+				break;
+
 			p += 1;
 			ret[nitems++] = l_string_unwrap(growable);
 			growable = NULL;
-- 
2.34.1

