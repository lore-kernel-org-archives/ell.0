Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5DBB1C33
	for <ell@lists.linux.dev>; Tue, 20 Sep 2022 13:32:08 +0000 (UTC)
Received: by mail-wr1-f52.google.com with SMTP id cc5so4314148wrb.6
        for <ell@lists.linux.dev>; Tue, 20 Sep 2022 06:32:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=JLhqwAlbrMsNsRZNtb/RuhRTR9JVrlsRMis9PRUC6HI=;
        b=VxuAXuAnZsRMQqtz/aOOb0JZRBBBtj+hk5KLTmchHdO7Eu3v+37MDtvUXVEPfLII1E
         1MdoAz3oEJITGB5NDAQcAIDPfjsR2UIdi5KpkwVoWpTMgZDc43n374j1s93ooW15buyr
         TpoRSnv86etN2dvCLni51MuqBZCApPoi0I/jKCezU5AKG7IEYGAtsqc7fxS7NL9zP2nI
         zR6LVEfR+8obEryK3VFge0G7LIrifOGtuwXeHymBpp3WYUGNRqTmeYo8/fIo/Qz6mdqJ
         3tGOFDQTENIsI+FqfyTjPpvxZBzCroQPuWtpIvibjgtoNyiOQLgRVU/qPQhP/0uSZ7Rt
         GV8Q==
X-Gm-Message-State: ACrzQf0gVfqNi7SuMDS/QNEcWoq23Zc2EtJMoZqpbC+d9OKq7Ww/NAVP
	E6oAzCdFS6gnys/b9p73eFLhHLIqWjeoP7yR
X-Google-Smtp-Source: AMsMyM5sRAYom4O4ONewW++iISw28OLgVJ2URc+ysmFQRfoy5v7ztyD14v+d/DmbB23KASYs/Vhx9g==
X-Received: by 2002:a5d:6d89:0:b0:22a:f378:e701 with SMTP id l9-20020a5d6d89000000b0022af378e701mr9720803wrs.199.1663680726708;
        Tue, 20 Sep 2022 06:32:06 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id d16-20020adff2d0000000b0022863395912sm2082wrp.53.2022.09.20.06.32.06
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Sep 2022 06:32:06 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/6] netconfig: Set .v6_configured when we set an address
Date: Tue, 20 Sep 2022 15:31:58 +0200
Message-Id: <20220920133201.3303119-3-andrew.zaborowski@intel.com>
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

The DNS getters won't work without this as they return NULL if
.v6_configured is false.

Fixes: 6adf0f5db455 ("netconfig: Create SLAAC address")
---
 ell/netconfig.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 7a9ee89..e5c7b51 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -750,6 +750,7 @@ static void netconfig_add_slaac_address(struct l_netconfig *nc,
 
 	l_queue_push_tail(nc->addresses.current, nc->v6_address);
 	l_queue_push_tail(nc->addresses.added, nc->v6_address);
+	nc->v6_configured = true;
 	netconfig_emit_event(nc, AF_INET6, L_NETCONFIG_EVENT_CONFIGURE);
 
 	/* TODO: set a renew timeout */
-- 
2.34.1

