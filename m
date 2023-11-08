Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2A1132C66
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 23:46:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PwqLAqbO"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-1dd71c0a41fso123974fac.2
        for <ell@lists.linux.dev>; Wed, 08 Nov 2023 15:46:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699487194; x=1700091994; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=JvWYwqyaO+ywJYVea2HZVfFveWxMQg3YIMiHI5LHbE8=;
        b=PwqLAqbOdqOqPlgPntmi3cHCpO+PZPYqp/vOSw2ILl9XkUN/bdc5yOgfJyZC/FeBte
         thk3EEuhtCinIvZGpzH538n+0/bbLeYkxMy5OvLrXVRzcZ/AYKRSbEL1NGfqLp1Erf+k
         +n5/iC8RXIpfEC7RgIF/ya6L4oBRWrrQvzF6EmQKcxXmtB627Rf2ebrFRf/RgG+y+XAO
         FREjqfeCyyV1YAGBhHnW11MClAGefUsJrT//7ewqkL46blOa016qEF9X7rWWvm8Ae/5o
         D2b/1+uWLrDoXBHOz+Qx1cMogKC2Z8/Usyozau8pa1Yf4pXMzH64/MjNZ/uA8awnR6Bu
         sHzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699487194; x=1700091994;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=JvWYwqyaO+ywJYVea2HZVfFveWxMQg3YIMiHI5LHbE8=;
        b=Zr7b/fLVY4imyFrwnXfnayFDaVB4jNCue4iOpNJF1Vw8p/QwyfX0CKk6VjI3caKVwF
         JAtXXRDkVbknAR7PaTJFckydemUZAEqO0px+L0zNcgzo9UVAtlLMzYZ5w1Kqx1nd+bhE
         sJfdEnRQGNc4uNge8rVyTB1OVeHB7ADdUqALq6aeSqwHfn0ETdwfO1FMi+kc2i5LgNlx
         tvuEdm1uUjcGiMdNHHSKilbvFl5lXQdD2TqTEvpyjqPEuIj0WkjvP7IicM+CI3FdvHpC
         S0WSgMNU69/HjtIqqRdArDRBNWgETv1JQOMvWCuwNliLt1/gRnBTXH+Y5x5rLvLtXK+Q
         Sdng==
X-Gm-Message-State: AOJu0Yxj8hQvkBi1KoEcPr57kqB61btz/ve3ed3e/NQTI2gqetBz+xf6
	o+Rs26Psvxolo9rRzQtAl6lIJauocDQ=
X-Google-Smtp-Source: AGHT+IEyyL2vG3ytPWX3/qYTgUb9aiwgmO7G10h5+Xb+rFtUQ2hmADTSDlvDdfDIZXcTzL7PXA2LmQ==
X-Received: by 2002:a05:6870:de15:b0:1bf:6ec:dd4d with SMTP id qg21-20020a056870de1500b001bf06ecdd4dmr3525576oab.28.1699487193970;
        Wed, 08 Nov 2023 15:46:33 -0800 (PST)
Received: from localhost.localdomain (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id h5-20020a056870a3c500b001e5c7cc54d3sm491116oak.55.2023.11.08.15.46.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Nov 2023 15:46:33 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/4] rtnl: Fixup rtnetlink includes
Date: Wed,  8 Nov 2023 17:45:20 -0600
Message-ID: <20231108234544.1050199-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

man 7 rtnetlink suggests the 4 includes listed should be used.  Also,
remove rtnetlink.h inclusion from rtnl.h and move it into the individual
code files.
---
 ell/netconfig.c  | 4 ++++
 ell/rtnl.c       | 5 ++++-
 ell/rtnl.h       | 3 ++-
 unit/test-rtnl.c | 4 ++++
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 0e00981e7e98..9b01581fff45 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -9,6 +9,10 @@
 #include <config.h>
 #endif
 
+#include <asm/types.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <sys/socket.h>
 #include <net/if.h>
 #include <linux/types.h>
 #include <linux/if_ether.h>
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 7f14faa7abc6..ad2dca2f9e3c 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -10,12 +10,15 @@
 #endif
 
 #define _GNU_SOURCE
+#include <asm/types.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <sys/socket.h>
 #include <linux/if.h>
 #include <linux/icmpv6.h>
 #include <linux/neighbour.h>
 #include <linux/if_ether.h>
 #include <net/if_arp.h>
-#include <sys/socket.h>
 #include <arpa/inet.h>
 #include <errno.h>
 
diff --git a/ell/rtnl.h b/ell/rtnl.h
index efe58b27a075..fa5d99eb4b53 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -9,13 +9,14 @@
 #define __ELL_RTNL_H
 
 #include <stdint.h>
-#include <linux/rtnetlink.h>
 #include <ell/cleanup.h>
 
 #ifdef __cplusplus
 extern "C" {
 #endif
 
+struct rtmsg;
+struct ifaddrmsg;
 struct l_rtnl_address;
 struct l_rtnl_route;
 
diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 02629040865d..cd944af64de9 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -16,6 +16,10 @@
 #include <stdlib.h>
 #include <signal.h>
 #include <sys/wait.h>
+#include <asm/types.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h>
+#include <sys/socket.h>
 
 #include <ell/ell.h>
 #include "ell/dbus-private.h"
-- 
2.42.0

