Received: from mail-wr1-f45.google.com (mail-wr1-f45.google.com [209.85.221.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B56B1C39
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:11 +0000 (UTC)
Received: by mail-wr1-f45.google.com with SMTP id t7so4267132wrm.10
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=NUmJw8AAv70r4A9N9K6OuV1PvZ5NQn1u6+ADzwrchUQ=;
        b=knJZUVb/rR3aPQ2xRN0KcEZrMpA++ie/dkQVJttIden2f/+8cwPdJuY8otbZRXc9+7
         X1WdJt0etEKX/PyagV0MZGT6OWAoO+GEWmwfXVGJ6s7zJstVZVSb6dVS/abRicPIVIv1
         bnwDqtV8D2cuCRqZf/NXpxrstZKjcKdTxKBVPe8lSFQqXe7cqveXwS2kyM0/vy1iTc4H
         y4Mh1izBiu2U++vTSWxgNsB9n8Zd0LZeDBf1CVOpNX/5AmRmzMLcRSaYBEaaE8wRDE4O
         GSfnCCRKRFcZ47a2Pf04CD5stgSO5qZnK2otcxTn/JbQ+EiLzfdoLgoBQ9faasHczV0t
         KESg==
X-Gm-Message-State: ACrzQf2ga0Ypjqt4LXBV6zR+xrQfJwdQhukxufKg+tSc5nEJcowlr6Fq
	GtjVwRl8gVedfRVXF+NarQRIJQelIyXmmCi4
X-Google-Smtp-Source: AMsMyM5n8ErAumtqjyq4SYtN/0UM0qRQrRzTWWoUwGOejhYj0dxuZ/qd2p17O9J5lhiDhmvxr4+zgw==
X-Received: by 2002:a05:6000:1d8f:b0:228:57f3:1f72 with SMTP id bk15-20020a0560001d8f00b0022857f31f72mr14415001wrb.276.1663680729494;
        Tue, 20 Sep 2022 06:32:09 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:08 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 6/6] netconfig: Handle missing optimistic_dad /proc file
Date: Tue, 20 Sep 2022 15:32:01 +0200
Message-Id: <20220920133201.3303119-6-andrew.zaborowski@intel.com>
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

Handle netconfig_proc_read_ipv6_uint_setting(..., "optimistic_dad")
failures more cleanly in case CONFIG_IPV6_OPTIMISTIC_DAD has not been
enabled in the kernel config.  This commit makes no noticeable
difference to the user.
---
 ell/netconfig.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index c558cad..fe5bf40 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -90,7 +90,7 @@ struct l_netconfig {
 	struct l_queue *icmp_route_data;
 	struct l_acd *acd;
 	unsigned int orig_disable_ipv6;
-	unsigned int orig_optimistic_dad;
+	long orig_optimistic_dad;
 	uint8_t mac[ETH_ALEN];
 	struct l_timeout *ra_timeout;
 	bool have_lla;
@@ -2010,7 +2010,8 @@ configure_ipv6:
 		netconfig_proc_read_ipv6_uint_setting(netconfig,
 							"optimistic_dad");
 
-	if (!!netconfig->orig_optimistic_dad != optimistic_dad)
+	if (netconfig->orig_optimistic_dad >= 0 &&
+			!!netconfig->orig_optimistic_dad != optimistic_dad)
 		netconfig_proc_write_ipv6_uint_setting(netconfig,
 							"optimistic_dad",
 							optimistic_dad ? 1 : 0);
@@ -2160,7 +2161,8 @@ LIB_EXPORT void l_netconfig_stop(struct l_netconfig *netconfig)
 
 	optimistic_dad = netconfig->optimistic_dad_enabled &&
 		!netconfig->v6_static_addr;
-	if (!!netconfig->orig_optimistic_dad != optimistic_dad)
+	if (netconfig->orig_optimistic_dad >= 0 &&
+			!!netconfig->orig_optimistic_dad != optimistic_dad)
 		netconfig_proc_write_ipv6_uint_setting(netconfig,
 						"optimistic_dad",
 						netconfig->orig_optimistic_dad);
-- 
2.34.1

