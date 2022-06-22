Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97B2EEC4
	for <ell@lists.linux.dev>; Wed, 22 Jun 2022 00:57:21 +0000 (UTC)
Received: by mail-wr1-f54.google.com with SMTP id n1so20936088wrg.12
        for <ell@lists.linux.dev>; Tue, 21 Jun 2022 17:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=7D4qUJhgM+r96UrbtOOEjTi8iwD6F5T0CQRTH1JeAzY=;
        b=pClYqyxBz0oNGxRvrYqEl/eK4SeEofQYVZXxRWFU1iRQKLbbZAguH7Sg4Gc9hsCSla
         w8V0wDDrb43pEfHLaN8VtN+Na+o/X9Sa9/OnHj7Tan3DsvfJi5x86ua3BQpYP0XoKgo0
         HJ//P47wapU8zWvvXA3OMGn3nJBYd/ZGJk+ArZochzGBqt9dE/mwXm9a+kVln4LmiyRF
         X/s3NZvOyT3iaqkjtTexwuQdAu4l0yS3VKNxlmQz4EhQ1pB4C9hNru/U1ZCODwmBODpf
         dd+pGYhwNl960+rfwUCzuoje69Ii2SOl1yl2/LxD+1n7rI+shheK+gXhcIFrPtotsPw0
         iGYw==
X-Gm-Message-State: AJIora/q1htZAJvpsayFfjEEfrKHCU4n9QAR6tNChmPVb2SRMFliNIT4
	99LxfgRaKfoNEPYylH/Fkq/En5iskXgT5g==
X-Google-Smtp-Source: AGRyM1uhKQfHIQ/ahBXxcNPhN8544wRsHmWXqxpUpd+CWj9PkOCjhRNhbXl/KvGmbcmFOyOhedk1pA==
X-Received: by 2002:a05:6000:381:b0:21b:9a20:6543 with SMTP id u1-20020a056000038100b0021b9a206543mr613152wrf.127.1655859439472;
        Tue, 21 Jun 2022 17:57:19 -0700 (PDT)
Received: from iss.Home ([82.213.231.20])
        by smtp.gmail.com with ESMTPSA id n10-20020adffe0a000000b0021b5861eaf7sm15101935wrr.3.2022.06.21.17.57.18
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 21 Jun 2022 17:57:18 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH] netconfig: Add getters for DNS addresses and domain names
Date: Wed, 22 Jun 2022 02:57:14 +0200
Message-Id: <20220622005714.2319560-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ell.sym     |  2 ++
 ell/netconfig.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netconfig.h |  2 ++
 3 files changed, 77 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 38422e7..8f4e59d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -758,6 +758,8 @@ global:
 	l_netconfig_apply_rtnl;
 	l_netconfig_get_addresses;
 	l_netconfig_get_routes;
+	l_netconfig_get_dns_list;
+	l_netconfig_get_domain_names;
 local:
 	*;
 };
diff --git a/ell/netconfig.c b/ell/netconfig.c
index b4e9802..d4487bd 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1808,3 +1808,76 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_get_routes(
 
 	return l_queue_get_entries(netconfig->routes.current);
 }
+
+static void netconfig_strv_cat(char ***dest, char **src, bool free)
+{
+	unsigned int dest_len;
+	unsigned int src_len;
+
+	if (!src)
+		return;
+
+	if (!free)
+		src = l_strv_copy(src);
+
+	if (!*dest) {
+		*dest = src;
+		return;
+	}
+
+	dest_len = l_strv_length(*dest);
+	src_len = l_strv_length(src);
+	*dest = l_realloc(*dest, sizeof(char *) * (dest_len + src_len + 1));
+	memcpy(*dest + dest_len, src, sizeof(char *) * (src_len + 1));
+	l_free(src);
+}
+
+/* Returns a new strv array to be freed by the caller */
+LIB_EXPORT char **l_netconfig_get_dns_list(struct l_netconfig *netconfig)
+{
+	char **ret = NULL;
+	const struct l_dhcp_lease *v4_lease;
+	const struct l_dhcp6_lease *v6_lease;
+
+	if (netconfig->v4_dns_override)
+		netconfig_strv_cat(&ret, netconfig->v4_dns_override, false);
+	else if ((v4_lease =
+			l_dhcp_client_get_lease(netconfig->dhcp_client)))
+		netconfig_strv_cat(&ret, l_dhcp_lease_get_dns(v4_lease), true);
+
+	if (netconfig->v6_dns_override)
+		netconfig_strv_cat(&ret, netconfig->v6_dns_override, false);
+	else if ((v6_lease =
+			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+		netconfig_strv_cat(&ret, l_dhcp6_lease_get_dns(v6_lease), true);
+
+	return ret;
+}
+
+/* Returns a new strv array to be freed by the caller */
+LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconfig)
+{
+	char **ret = NULL;
+	const struct l_dhcp_lease *v4_lease;
+	const struct l_dhcp6_lease *v6_lease;
+
+	if (netconfig->v4_domain_names_override)
+		netconfig_strv_cat(&ret, netconfig->v4_domain_names_override,
+					false);
+	else if ((v4_lease =
+			l_dhcp_client_get_lease(netconfig->dhcp_client)) &&
+			l_dhcp_lease_get_domain_name(v4_lease)) {
+		ret = l_new(char *, 2);
+		ret[0] = l_dhcp_lease_get_domain_name(v4_lease);
+	}
+
+	if (netconfig->v6_dns_override)
+		netconfig_strv_cat(&ret, netconfig->v6_domain_names_override,
+					false);
+	else if ((v6_lease =
+			l_dhcp6_client_get_lease(netconfig->dhcp6_client)))
+		netconfig_strv_cat(&ret, l_dhcp6_lease_get_domains(v6_lease),
+					true);
+
+	return ret;
+}
diff --git a/ell/netconfig.h b/ell/netconfig.h
index d845c55..ac467b6 100644
--- a/ell/netconfig.h
+++ b/ell/netconfig.h
@@ -99,6 +99,8 @@ const struct l_queue_entry *l_netconfig_get_routes(
 				const struct l_queue_entry **out_updated,
 				const struct l_queue_entry **out_removed,
 				const struct l_queue_entry **out_expired);
+char **l_netconfig_get_dns_list(struct l_netconfig *netconfig);
+char **l_netconfig_get_domain_names(struct l_netconfig *netconfig);
 
 #ifdef __cplusplus
 }
-- 
2.34.1

