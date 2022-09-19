Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CBE25C94
	for <ell@lists.linux.dev>; Mon, 19 Sep 2022 13:31:14 +0000 (UTC)
Received: by mail-wm1-f53.google.com with SMTP id o5so16815961wms.1
        for <ell@lists.linux.dev>; Mon, 19 Sep 2022 06:31:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=bFHkYS/sEhT3zf09knf+Fmzjye5RGkHPkm/iEW7GAos=;
        b=sX7Ru8xy6tBBrxXsez4xuPt49R4QvA7wetMY542V1jjF14ZJNJXdu5o2jt6FIvQ9uX
         L6i1RUMlv66XOJckXpDuUMmHlA55YasFpRIfj4+BTN9d0y4IS5HUrdahEcFr8ifJwPPT
         HBSyWdS9INX3HC1K7JebsEPyJujcOvlohcKqPtjkazfFaZ5FalMT4397GCjAtSot28LZ
         VgFDau5KcsCUVPnnBC8s8wbpLAz6Of5NCnkDKedvwR+WOl0noccORgbzDSGg8xmQvxrQ
         Z2nB0VZJmoz+W+XVrpXGJtKOxauGAVrlGQyg1gNYOyFfaZZ/mU7bjGVvRr1Oidic1nz5
         YYzw==
X-Gm-Message-State: ACrzQf0Xm3ZSde5sLZkZpxgO8JWZFh8qIndDNw88AWNzE0KW90aNSgtj
	9OU3mYpBfKWSRbSEx/lf36ts1nyAe7g33w==
X-Google-Smtp-Source: AMsMyM6fQ61blsw9bDo/Ku4k7bKK2jTpQnoTEQ1sp/PuN+xJ2a3BJZHuF5cIomL9Jun7kPnxhzSOfw==
X-Received: by 2002:a05:600c:5009:b0:3a9:f99e:7410 with SMTP id n9-20020a05600c500900b003a9f99e7410mr12593415wmr.5.1663594272269;
        Mon, 19 Sep 2022 06:31:12 -0700 (PDT)
Received: from iss.ger.corp.intel.com ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id az24-20020adfe198000000b00228d7078c4esm14252463wrb.4.2022.09.19.06.31.11
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Sep 2022 06:31:11 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 4/7] rtnl: Add l_rtnl_address_get_in_addr
Date: Mon, 19 Sep 2022 15:31:02 +0200
Message-Id: <20220919133105.3129080-4-andrew.zaborowski@intel.com>
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

Similar to l_rtnl_route_get_dst_in_addr add a getter for the raw address
value, avoiding extra string conversions.
---
 ell/ell.sym | 1 +
 ell/rtnl.c  | 9 +++++++++
 ell/rtnl.h  | 1 +
 3 files changed, 11 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index a28eb55..d76b2ea 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -626,6 +626,7 @@ global:
 	l_rtnl_address_clone;
 	l_rtnl_address_free;
 	l_rtnl_address_get_address;
+	l_rtnl_address_get_in_addr;
 	l_rtnl_address_get_family;
 	l_rtnl_address_get_prefix_length;
 	l_rtnl_address_get_broadcast;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 2483e82..5909c4b 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -180,6 +180,15 @@ LIB_EXPORT bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
 						out_buf);
 }
 
+LIB_EXPORT const void *l_rtnl_address_get_in_addr(
+					const struct l_rtnl_address *addr)
+{
+	if (unlikely(!addr))
+		return NULL;
+
+	return addr->family == AF_INET ? (void *) &addr->in_addr : &addr->in6_addr;
+}
+
 LIB_EXPORT uint8_t l_rtnl_address_get_family(const struct l_rtnl_address *addr)
 {
 	if (unlikely(!addr))
diff --git a/ell/rtnl.h b/ell/rtnl.h
index ffd1d73..1e6b1fa 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -44,6 +44,7 @@ void l_rtnl_address_free(struct l_rtnl_address *addr);
 DEFINE_CLEANUP_FUNC(l_rtnl_address_free);
 bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
 				char *out_buf);
+const void *l_rtnl_address_get_in_addr(const struct l_rtnl_address *addr);
 uint8_t l_rtnl_address_get_family(const struct l_rtnl_address *addr);
 uint8_t l_rtnl_address_get_prefix_length(const struct l_rtnl_address *addr);
 bool l_rtnl_address_get_broadcast(const struct l_rtnl_address *addr,
-- 
2.34.1

