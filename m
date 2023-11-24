Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B06B15AEB
	for <ell@lists.linux.dev>; Fri, 24 Nov 2023 16:18:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SqFjdrlq"
Received: by mail-oi1-f171.google.com with SMTP id 5614622812f47-3b83c4c5aefso1254432b6e.1
        for <ell@lists.linux.dev>; Fri, 24 Nov 2023 08:18:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1700842710; x=1701447510; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=Wxr02uL6kvNSFmxjpc1K16JrLbeAmKvM37TVWz9Igm4=;
        b=SqFjdrlqKqMzj3jONxqey5Q/WIAvzKOvMwLnnIX4bs40pYEvlbWC2FP1bJj8kwn8o+
         4/2b5WUuyUSse2Nd3UnoZHxAN6TE6Au0O1NKR7vJc4YzNcOvxfOGpNVWNQKt05YfgCDm
         8M9MGKKmozKPCeh5itI+lKcYu8t1y6VN+0Jt6YhTXsfeSJr16gV4XIJ4xAydjrqzifEd
         xQtj+7Dcu/0xSE1B+KPHh2b0STLpqFPRWT1dufyA/sP5LE7VwWNspZnQDnsbCWL057ol
         7JwlujUIUW7YUo7KA+dEe5MyadOEhDfkLHP1DxjhJWBGxjTdIRcp+yGajJrs6Q7OcMoc
         WdrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700842710; x=1701447510;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=Wxr02uL6kvNSFmxjpc1K16JrLbeAmKvM37TVWz9Igm4=;
        b=cHa5QmhbwLtj9p5U/Dx4OJgdOSFMWf0/LBRCFIWetKvDiJmOf+Fmbuz73MmT20kOiO
         20iRLpk4+KQGfPhRI/yRNGNcvFT1kpHUMKoygCiZ0AEIuZuRn50Lie2kcUZRdBLQswdl
         VxPErCFnjnF8Pg7kM0AnMdWBskF5wg2tDvaZTzs/2YzRK24a4SsQhZokB5+FjLcxtUEj
         t+lM5N9sNMTXPSGzRkY1dXh139OpvMZ6TS5rQHpGiXj0E9hHZqxC9QZwqwrvnyKS3T0F
         SitC3BoW3Q+01EQMuHUe7CnlD+1UfZlbQQaTo0TzX+wjoIRj4P7BuPRFeCCN0rJjCc46
         OMJw==
X-Gm-Message-State: AOJu0YxB1/Knr31u1+2zBVHdsVrkLVzNhV7xDu/pn4svmHKh633JRJgW
	VSs23fp30TXCjMFkJJZRz4V9URKhSHs=
X-Google-Smtp-Source: AGHT+IFFPySENwM7RY/sMXWtqRPmG+q/uUOrVQ6hSeft1/goZsXzq8CC8xoTNwxKseMmlUYD3KsQGQ==
X-Received: by 2002:a05:6808:6411:b0:3a8:1877:2d28 with SMTP id fg17-20020a056808641100b003a818772d28mr4103233oib.50.1700842710109;
        Fri, 24 Nov 2023 08:18:30 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id w9-20020a056808090900b003b2daf09267sm530815oih.48.2023.11.24.08.18.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 24 Nov 2023 08:18:29 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] netconfig: Always set DHCP MAC address on start
Date: Fri, 24 Nov 2023 10:17:26 -0600
Message-ID: <20231124161740.1243946-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

l_netconfig_stop() calls l_dhcp_client_stop which does not reset the
client MAC address being used.  Since the underlying MAC might have
changed (for example, due to per-network MAC address generation in iwd),
make sure that any subsequent l_netconfig_start() invocations will
update the DHCP client MAC.  This already happens for DHCPv6, but
somehow did not happen for DHCPv4.
---
 ell/netconfig.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 9b01581fff45..dc6cb0f6a8d9 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1970,6 +1970,9 @@ LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 	if (!netconfig_check_config(netconfig))
 		return false;
 
+	if (!l_net_get_mac_address(netconfig->ifindex, netconfig->mac))
+		return false;
+
 	if (!netconfig->v4_enabled)
 		goto configure_ipv6;
 
@@ -1984,6 +1987,9 @@ LIB_EXPORT bool l_netconfig_start(struct l_netconfig *netconfig)
 		goto configure_ipv6;
 	}
 
+	l_dhcp_client_set_address(netconfig->dhcp_client, ARPHRD_ETHER,
+					netconfig->mac, ETH_ALEN);
+
 	if (!l_dhcp_client_start(netconfig->dhcp_client))
 		return false;
 
@@ -2064,9 +2070,6 @@ configure_ipv6:
 	l_queue_push_tail(addr_wait_list, netconfig);
 	netconfig->have_lla = false;
 
-	if (!l_net_get_mac_address(netconfig->ifindex, netconfig->mac))
-		goto unregister;
-
 	l_dhcp6_client_set_address(netconfig->dhcp6_client, ARPHRD_ETHER,
 					netconfig->mac, ETH_ALEN);
 	l_icmp6_client_set_address(netconfig->icmp6_client, netconfig->mac);
-- 
2.42.0

