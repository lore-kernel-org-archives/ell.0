Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2317B4A35
	for <ell@lists.linux.dev>; Fri,  7 Oct 2022 18:02:32 +0000 (UTC)
Received: by mail-wm1-f45.google.com with SMTP id fn7-20020a05600c688700b003b4fb113b86so3035085wmb.0
        for <ell@lists.linux.dev>; Fri, 07 Oct 2022 11:02:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=3ezY7pQidjJMIB/9B/hi9Uomr2xHMRi0zsk9pJY7yKw=;
        b=y1dVSJvXaeICDp+/5FuDV2xWbHTjb7/cYg0+xoKfVTkIvDxbBIt0wJ+KZlamGuwUfd
         Jq/cvSH338pUsCu73P84x3V3D5cb3y60/o/ajPAE8dXieltqntY5Pmzff6Vrqb03kDwZ
         lKOZsYMMTpWNuVkf7WaE7NJhm2WhHSHg6lJvJDfgua1ZiC0IgXZ57LSc2FgxHpJcZviu
         O0Z6Me2u6BFMIk6u2SZNnuHbFsFG4JFzWY29Hb23YMvFWRTL+7uc/i7q1173iEuFFhmA
         qkLlllda9ck6JKV3S5dq3r0uhi9pr6ezx0lDWl/mnAyHqY2SehjoLpOP7rnCZst7zinX
         hNUg==
X-Gm-Message-State: ACrzQf1hKr99SHojaaTEmUpFbyjfzyZurbsVRrrD2giLquuVvWs2ZyUn
	NZGjHvv9N00msx7Kux5kA2u/tgdWNyk=
X-Google-Smtp-Source: AMsMyM7IfiMRZ4+Rb3uoZjQf9PjocbI0mD9iOD+4CR66N3M8rkT0bjh9eVTAzq5DcBk6myoXJlhxKA==
X-Received: by 2002:a05:600c:1f15:b0:3b4:8600:fd7e with SMTP id bd21-20020a05600c1f1500b003b48600fd7emr11636533wmb.40.1665165750029;
        Fri, 07 Oct 2022 11:02:30 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id m14-20020adff38e000000b0022c906ffedasm2477078wro.70.2022.10.07.11.02.24
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 07 Oct 2022 11:02:26 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/2] netconfig: Set preferred lifetimes on DHCP addresses
Date: Fri,  7 Oct 2022 20:02:08 +0200
Message-Id: <20221007180209.1069526-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

We receive one lease lifetime value for a DHCP lease so we were setting
the preferred lifetime for the RTNL address to 0 and the valid lifetime
to the lease lifetime.  If either value is non-zero rtnl.c will send
both to the kernel and the 0 preferred lifetime is treated as literal
zero and the address becomes deprecated immediately.  This doesn't
matter for most usages but systemd-resolved would check whether a link
has a non-deprecated address before setting the link's
"unicast_relevant" flag and internally wouldn't create a DNS "scope" on
the link or set its "DefaultRoute" flag both of which are required for
it to want to resolve names.
---
 ell/netconfig.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 76b18a7..8ded113 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -405,8 +405,8 @@ static void netconfig_set_dhcp_lifetimes(struct l_netconfig *nc, bool updated)
 	uint64_t expiry = l_dhcp_lease_get_start_time(lease) +
 		lifetime * L_USEC_PER_SEC;
 
-	l_rtnl_address_set_lifetimes(nc->v4_address, 0, lifetime);
-	l_rtnl_address_set_expiry(nc->v4_address, 0, expiry);
+	l_rtnl_address_set_lifetimes(nc->v4_address, lifetime, lifetime);
+	l_rtnl_address_set_expiry(nc->v4_address, expiry, expiry);
 
 	if (updated && !netconfig_address_exists(nc->addresses.added,
 							nc->v4_address))
-- 
2.34.1

