Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13E8318BC39
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429758; cv=none; b=RIXnyHJQIvm93ytfgwnQqKykMrliCTxKO2eEI8seyQ50YXgj1HDCTb9zEyS4SfiDIOwzP54KyrPH29QoqgfvnLk/dkwyvb/StJQfKJHJ6Q4Giukq5nbW3nJS6h7ED9luMqzKXI+ACtmeeKnTIvL7t8fX1u2cSUU09OIq0OjvgQc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429758; c=relaxed/simple;
	bh=X8CIYuXzXLrJ32tJUUltHPOUDQ5iLdwyLHAitt6pd0s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WtwBvWksJRy6oHi4KKLDjsHotATb9ttShB/rjoLouutzaEydSyER7oAnMulHZoBO1YIFVwlPKVBSO66EVibCcygbVVXSipWJVDa9dfiwp58FTVsU/KGIHe1ZrXpDp2aR3pB0CmV0CsZA+yJhHx8K9MB6Tj1iN8uRHionA2N8dFY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jKqe9zns; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jKqe9zns"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-5d5c8c1006eso1525752eaf.3
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429756; x=1725034556; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=s8trhKgXPl0k8p/Xs8doNH3rTsnqbgyAarZYQgKSCEM=;
        b=jKqe9znsDA7IzkSmIobyv6c/iPDSkuKOQnt+9eYhb8+eRFUnTTggA2c+Mpg3OOqjPj
         VrM9Itu7fJrmSABrYcefyf17Hk73oK2YjXM5CENUgljp0xLGF3oM4Hds38Iij0RILAd6
         IXSBsBFln5QGiLgyqrLYc8kZ5tN+7hUcCl/l7CLYaE3pGerxcWAjwFbxrID/TaYKtVMV
         bcSiBgGlOyCgaURwYhS98rp1AKNm/wHqrdC3LrkU1fuI8z7ZkqZSo6hXBDN2vkKSm6j6
         uBk3IIuP8+erUwmmm9iAcr/DQhuJhXiJsRXEomEWVjKQI7BWuKdybbB8T95Io+U6kBxT
         DZtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429756; x=1725034556;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=s8trhKgXPl0k8p/Xs8doNH3rTsnqbgyAarZYQgKSCEM=;
        b=EDu+PdfwxX/7VTOxNVHX1PbEPGD9H6J45nm1UwgcWulLlsu9uXx5ViI8afQ4BRnrrm
         B0W1UTRB7lgExho1AZxZC1mi9HPfj6T1NOoK7mk45tcyF9ZnGSuEuuQwmEZxfwknWeH8
         n43sh6W49M7x+2orrrkOM8suuWGIXgY7mtOOVW04z6JmQC/0NcdKD0brHXRxfJKe2cYf
         Ze0I82nQSbSLPiQqCE3yyk8Aws/gXQroRf4QMRyLmc3JQ9zSaxm67DZwl6+z/N8AkpF5
         QWbXZN2p59LIzFeo3r/UCQialOApQlNM7kblupgpePiBukMS2b0UPqOn3UoE4PUh6M8K
         Wrjw==
X-Gm-Message-State: AOJu0Yx32u9mmqEA6W84G7GBqaH4lseyADoFLIxwWhzAhWyBjgCxhz0r
	wYrcmdNTiIh4LnSijJVYKBcsmsoY0SjWG1Yb0vUoDIaZ7g40xvyWZ0GPSA==
X-Google-Smtp-Source: AGHT+IH50q6kkz5e66+P+GkDtzkTUFBc7xWB1GB9JoOjUjuJBcqRcDvXo54s1fqoxouoBoAUNoR72A==
X-Received: by 2002:a05:6820:820:b0:5da:9ef9:55c5 with SMTP id 006d021491bc7-5dcc5d51d14mr2801504eaf.0.1724429755996;
        Fri, 23 Aug 2024 09:15:55 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:55 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/6] unit: Use the new l_netlink_attr API
Date: Fri, 23 Aug 2024 11:15:46 -0500
Message-ID: <20240823161553.479576-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240823161553.479576-1-denkenz@gmail.com>
References: <20240823161553.479576-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-netlink.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/unit/test-netlink.c b/unit/test-netlink.c
index da23ee5c9b0e..113d735adf40 100644
--- a/unit/test-netlink.c
+++ b/unit/test-netlink.c
@@ -27,31 +27,34 @@ static void getlink_callback(int error, uint16_t type, const void *data,
 						uint32_t len, void *user_data)
 {
 	const struct ifinfomsg *ifi = data;
-	struct rtattr *rta;
-	int bytes;
+	struct l_netlink_attr attr;
 	char ifname[IF_NAMESIZE];
 	uint32_t index, flags;
+	uint16_t rta_type;
+	uint16_t rta_len;
+	const void *rta_data;
 
 	if (error)
 		goto done;
 
-	bytes = len - NLMSG_ALIGN(sizeof(struct ifinfomsg));
+	if (l_netlink_attr_init(&attr, sizeof(struct ifinfomsg), data, len) < 0)
+		goto done;
 
 	memset(ifname, 0, sizeof(ifname));
 
-	index = ifi->ifi_index;
-	flags = ifi->ifi_flags;
+	while (!l_netlink_attr_next(&attr, &rta_type, &rta_len, &rta_data)) {
+		if (rta_type != IFLA_IFNAME)
+			continue;
+
+		if (rta_len <= IF_NAMESIZE)
+			strcpy(ifname, rta_data);
 
-	for (rta = IFLA_RTA(ifi); RTA_OK(rta, bytes);
-					rta = RTA_NEXT(rta, bytes)) {
-		switch (rta->rta_type) {
-		case IFLA_IFNAME:
-			if (RTA_PAYLOAD(rta) <= IF_NAMESIZE)
-				strcpy(ifname, RTA_DATA(rta));
-			break;
-		}
+		break;
 	}
 
+	index = ifi->ifi_index;
+	flags = ifi->ifi_flags;
+
 	l_info("index=%d flags=0x%08x name=%s", index, flags, ifname);
 
 done:
-- 
2.45.2

