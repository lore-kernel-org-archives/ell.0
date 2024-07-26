Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3618617BB1F
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010358; cv=none; b=gJZyu0x5rX10fH63ofUicE2elSQg7EUaASRYOQMNCCMJ/d2Q6qzNziFI9ZJX4xETDXWpxIcc2zjkQjZHqZh92xBpXrW9jWXqg8J5fK+foqhbtRn9IuJtFvVVS03AHHNRCd0YLV2uW+0XHvHm0dQaCuEeJ2cZ6Q3UilCN9LEaKOI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010358; c=relaxed/simple;
	bh=RsmyEV2w9iKQdnzsr+ywfsif45L35bUnGSXc1NqLRPQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tTOopFM1nqaHUrhb77GTNjCZs35MVTXpnITdWxmV2ihH7GE9xn3HDNGMl5upoTjbssOaFKgLWuNjcmnPDpxAMbLwIp1RINnniNeX4qe2vSt+K4oTeB9NiVIGZAhgAyiWdVxi3uDLIpAk5Gff+wWtoUtX5Kbdm1kbioEVWmoX1b8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Oqn8h/gs; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Oqn8h/gs"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-7037a208ff5so745189a34.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010356; x=1722615156; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=sFr7czbaeoJ1L7Nz/COBeeEwi3Gc7sHep8ZCzITtmcc=;
        b=Oqn8h/gsJFPjKhmTGwerBIcX1li8Y49wvZYCiS4Ms7xBtYbkw/rG9EQNgava3tbzWQ
         hI+7FaeLXAZqxzwoew227V6kRzMv7whR3AbIKeks5RGi98IXSKiDYd8ArU+6q6MA+kXb
         hH7pbnepULGzf3YAS6YuzUKvnm8qILbVKJK4CaPcbObag7oPTtceWcJFaIkQ/xf4iC00
         QckkbaiCS32aPIzD7DUbswdin748tDQX1iwPLDSvXRDumxm4WQz3loAd8kpqx6e6rmQO
         5TgFTe52tavn+QpMhOtV1Ad79dowMFnOV6DOOzADWtgZaUbYf37dO66knQucIhXr7AAG
         VNLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010356; x=1722615156;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=sFr7czbaeoJ1L7Nz/COBeeEwi3Gc7sHep8ZCzITtmcc=;
        b=h49bLaOOOM232X5ZWPf7MFxGOg1FZJ+/m5JzZw0NcQnB7R28cXkhh2wv4FVliBk2fQ
         FfvfCr6MbdVN2y6wV3iTPNhY3CE3kE74zeg+qxj+ZkJXFnlCeZ265CZ6Y2G8E2bADVq5
         0CHdvMuSOnS2rQXGSFppAzcwJvbu/BZtOSLnDYApL9qvcjLRQsLW48o07q94RrYttlk2
         8s6tCuP0hqwOXVAXYFn60x89CewXU7hdfqeXA6u2sZiKXVDVpA4hphmGgK48nAXG53mW
         e9bOR0CHco3ocDTY5zyW0gIzGGDf17YGcTZmtkybqhmetNi+GV82kj/tocCesZpm6GV5
         mK5A==
X-Gm-Message-State: AOJu0YwRGlDcWFphU450ZyhLYqVT1aSK2s50UnSLA2DewLJLRBSXcMj/
	T2ExOyHU8nG58r26uHm3F5bg7SIAxMaGtw/DFNB4+cUM6ONtyzsiLaKs6g==
X-Google-Smtp-Source: AGHT+IG3KHj9qbOT3DMt0WU0r0QRV1ol4Zu1+vl3zQB45JGDErFXbz2H7DDEycL/uDs0RNnNconyEw==
X-Received: by 2002:a9d:6e14:0:b0:703:5ccb:85f3 with SMTP id 46e09a7af769-70940c701d5mr49415a34.22.1722010356161;
        Fri, 26 Jul 2024 09:12:36 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:35 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 4/7] rtnl: Add a builder for RTM_{NEW|DEL}ADDR messages
Date: Fri, 26 Jul 2024 11:12:16 -0500
Message-ID: <20240726161232.146982-4-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240726161232.146982-1-denkenz@gmail.com>
References: <20240726161232.146982-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This builder is based on the new l_netlink_message APIs and is much
simpler to understand.  Use 'ifa' for struct ifaddrmsg since that is the
common convention.
---
 ell/rtnl-private.h | 20 +++++++++++++
 ell/rtnl.c         | 73 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 76 insertions(+), 17 deletions(-)

diff --git a/ell/rtnl-private.h b/ell/rtnl-private.h
index ade43b3f053a..fe9cbf35b232 100644
--- a/ell/rtnl-private.h
+++ b/ell/rtnl-private.h
@@ -5,6 +5,23 @@
  * SPDX-License-Identifier: LGPL-2.1-or-later
  */
 
+struct l_rtnl_address {
+	uint8_t family;
+	uint8_t prefix_len;
+	uint8_t scope;
+	union {
+		struct in6_addr in6_addr;
+		struct in_addr in_addr;
+	};
+	struct in_addr broadcast;
+	char label[IFNAMSIZ];
+	uint32_t preferred_lifetime;
+	uint32_t valid_lifetime;
+	uint64_t preferred_expiry_time;
+	uint64_t valid_expiry_time;
+	uint32_t flags;
+};
+
 struct l_rtnl_route {
 	uint8_t family;
 	uint8_t scope;
@@ -32,3 +49,6 @@ struct l_rtnl_route {
 struct l_netlink_message *rtnl_message_from_route(uint16_t type, uint16_t flags,
 						int ifindex,
 						const struct l_rtnl_route *rt);
+struct l_netlink_message *rtnl_message_from_address(uint16_t type,
+					uint16_t flags, int ifindex,
+					const struct l_rtnl_address *addr);
diff --git a/ell/rtnl.c b/ell/rtnl.c
index dc3f456e0110..90ff61c09d13 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -34,23 +34,6 @@
 
 static struct l_netlink *rtnl;
 
-struct l_rtnl_address {
-	uint8_t family;
-	uint8_t prefix_len;
-	uint8_t scope;
-	union {
-		struct in6_addr in6_addr;
-		struct in_addr in_addr;
-	};
-	struct in_addr broadcast;
-	char label[IFNAMSIZ];
-	uint32_t preferred_lifetime;
-	uint32_t valid_lifetime;
-	uint64_t preferred_expiry_time;
-	uint64_t valid_expiry_time;
-	uint32_t flags;
-};
-
 static inline int address_to_string(int family, const struct in_addr *v4,
 					const struct in6_addr *v6,
 					char *out_address)
@@ -1644,3 +1627,59 @@ struct l_netlink_message *rtnl_message_from_route(uint16_t type, uint16_t flags,
 
 	return nlm;
 }
+
+struct l_netlink_message *rtnl_message_from_address(uint16_t type,
+					uint16_t flags, int ifindex,
+					const struct l_rtnl_address *addr)
+{
+	struct l_netlink_message *nlm = l_netlink_message_new(type, flags);
+	struct ifaddrmsg ifa;
+	uint64_t now = l_time_now();
+
+	memset(&ifa, 0, sizeof(ifa));
+	ifa.ifa_index = ifindex;
+	ifa.ifa_family = addr->family;
+	ifa.ifa_scope = addr->scope;
+	ifa.ifa_prefixlen = addr->prefix_len;
+	/* Kernel ignores legacy flags in IFA_FLAGS, so set them here */
+	ifa.ifa_flags = addr->flags & 0xff;
+
+	l_netlink_message_add_header(nlm, &ifa, sizeof(ifa));
+
+	if (addr->family == AF_INET) {
+		l_netlink_message_append(nlm, IFA_LOCAL, &addr->in_addr,
+						sizeof(struct in_addr));
+		l_netlink_message_append(nlm, IFA_BROADCAST, &addr->broadcast,
+						sizeof(struct in_addr));
+	} else
+		l_netlink_message_append(nlm, IFA_LOCAL, &addr->in6_addr,
+						sizeof(struct in6_addr));
+
+	/* Address & Prefix length are enough to perform deletions */
+	if (type == RTM_DELADDR)
+		goto done;
+
+	if (addr->flags & 0xffffff00)
+		l_netlink_message_append_u32(nlm, IFA_FLAGS,
+						addr->flags & 0xffffff00);
+
+	if (addr->label[0])
+		l_netlink_message_append(nlm, IFA_LABEL,
+					addr->label, strlen(addr->label) + 1);
+
+	if (addr->preferred_expiry_time > now ||
+			addr->valid_expiry_time > now) {
+		struct ifa_cacheinfo cinfo;
+
+		memset(&cinfo, 0, sizeof(cinfo));
+		cinfo.ifa_prefered = addr->preferred_expiry_time > now ?
+			l_time_to_secs(addr->preferred_expiry_time - now) : 0;
+		cinfo.ifa_valid =  addr->valid_expiry_time > now ?
+			l_time_to_secs(addr->valid_expiry_time - now) : 0;
+
+		l_netlink_message_append(nlm, IFA_CACHEINFO,
+						&cinfo, sizeof(cinfo));
+	}
+done:
+	return nlm;
+}
-- 
2.45.2

