Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com [209.85.167.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC6341C33
	for <ell@lists.linux.dev>; Fri,  1 Jul 2022 13:32:48 +0000 (UTC)
Received: by mail-lf1-f51.google.com with SMTP id t19so3274201lfl.5
        for <ell@lists.linux.dev>; Fri, 01 Jul 2022 06:32:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=5WaiZ6WdenVYaLa/HU1wDrnAQDLNZons6UkKeVPzK3I=;
        b=KLtaC442PhdcciQfzi2r66LAK+s35wHYCyBh3YPXpjwN0R6Hc7L+B0DEjl4TOYAi62
         5U/DBDOcnU+IlWflcu4RwZDCoqyCvyMxc1OmcUL80GX3bsIX6Al/ufavIV2x+sPNJexA
         B3z5cHxPXKqon7x4P9ei7JcV8t9A9bU1wXjUvoSdMHDIp1cUCS7bd+59QpgIvSVvdft3
         stGZRGSb6CJSuYv7bK8TJ7AZQWH6nMCrla5Y0ShxGcvPxJKsx+/UO+dvuk6yiG1QG1Hi
         lOSZFB4gR4I8bOhkQQCxywYkAvw+oofT36Rb0yFB6ivlevZp/Zse+sK2hGqbPjTsRQ8S
         /TDA==
X-Gm-Message-State: AJIora/gWnX8oMfGh5G0nWkKsCdLTe77vD53CXZZBGlCtjH5IJOifw28
	IrpwYhxi9hnCtQXFWqBlMPmTRm1fYO2Hblrd
X-Google-Smtp-Source: AGRyM1t8RCd0YNWqm2e6Rc1hstRFJ9SxLDgRtZdqXX0SMPtoteLkUL4UVIgYnH5AO2US7005y6cPnA==
X-Received: by 2002:a05:6512:3e19:b0:47f:77d8:236c with SMTP id i25-20020a0565123e1900b0047f77d8236cmr8990258lfv.560.1656682366526;
        Fri, 01 Jul 2022 06:32:46 -0700 (PDT)
Received: from iss.home (79.184.238.213.ipv4.supernova.orange.pl. [79.184.238.213])
        by smtp.gmail.com with ESMTPSA id 11-20020a05651c128b00b0025a725af81csm3185815ljc.39.2022.07.01.06.32.45
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 01 Jul 2022 06:32:45 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/4] netconfig: Fix leaking domain name string
Date: Fri,  1 Jul 2022 15:32:37 +0200
Message-Id: <20220701133237.2887854-4-andrew.zaborowski@intel.com>
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

In l_netconfig_get_domain_names we had two
l_dhcp_lease_get_domain_name() calls and only saved one of the values.
l_dhcp_lease_get_domain_name() internally does an strdup so we own the
returned string.

Reported by Coverity Scan as CID 379209.
---
 ell/netconfig.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index f48018b..28afa9b 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1908,15 +1908,16 @@ LIB_EXPORT char **l_netconfig_get_domain_names(struct l_netconfig *netconfig)
 	char **ret = NULL;
 	const struct l_dhcp_lease *v4_lease;
 	const struct l_dhcp6_lease *v6_lease;
+	char *dn;
 
 	if (netconfig->v4_domain_names_override)
 		netconfig_strv_cat(&ret, netconfig->v4_domain_names_override,
 					false);
 	else if ((v4_lease =
 			l_dhcp_client_get_lease(netconfig->dhcp_client)) &&
-			l_dhcp_lease_get_domain_name(v4_lease)) {
+			(dn = l_dhcp_lease_get_domain_name(v4_lease))) {
 		ret = l_new(char *, 2);
-		ret[0] = l_dhcp_lease_get_domain_name(v4_lease);
+		ret[0] = dn;
 	}
 
 	if (netconfig->v6_dns_override)
-- 
2.34.1

