Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 563F7200AF
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010357; cv=none; b=pG9uf4YwZxrnXIVfdzfgs3Tcr2JdU79HO31vBrjxkmer7jJcHEv6fQfOr96ePcrDLDMgNq3uTYOrNffpL36purnOBiWqhJ9+5ZLxWANLtkFZnrQ/j8g2i2s+Ht2YDS68ieweeO/s0rkc4PcIIeeWsPkSsdYOIKk/lUu5tXY8gtI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010357; c=relaxed/simple;
	bh=s9RflFMYf6MP0p2AF5NlXtTyYOmhwqDUS0WJFqbncOs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qZ3iB3e90ISI8RH470pFMu7+rzRbHPOcAq8yECBhupntdWTDTFV4UaJTae3JHTt0JqptL1FY7zg0WfIAwWQk4PlyXLLBkUKUahDcCItm4rUtNKx72ktt7R2ntLO8Khc6XLNoCoVHkqLltTGQgi6kSu1UAkBbvhELKETCmRSiaW4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Y4oQPaYW; arc=none smtp.client-ip=209.85.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y4oQPaYW"
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-708cf5138b6so865371a34.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010355; x=1722615155; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=B2a5qlA9RJZBQ/NjhdfqQouKqpdeNi6h4cVFnIVkXCI=;
        b=Y4oQPaYWN/43KPOiyaoCUQKmx6TPGpALyyZ0bBc3OYUCaO+W4GW/c5DOOtVuQpuk1d
         fN5d8ymPL7wkFeGqSfjWO1Bs5ZQ9BmF+eUMwpv5t4fFigcGENzgSfVp97DBAtpQ1017U
         M+sHl8CepDox4AZcMQtjx3cr/wsV5IfMN9fmIIfU2dLp76KBCBRXRhX2MOaGG/J8esAV
         ULIpxYspJ2xJf8NQgrzLx0TBmZdc51R/UqSeQg6wXSBuJVE4D9FwCZ6xhY/ROv+AUvQ1
         MeHge90SSenxhCHJXO7DLUSXcmP1kWFvdJMKBnB+u7UX9zYbudoH0BZzH8NhbfAEjZG/
         7U7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010355; x=1722615155;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=B2a5qlA9RJZBQ/NjhdfqQouKqpdeNi6h4cVFnIVkXCI=;
        b=F7aUZab1g/IEDEujxbnsrKa0zfSBpYXlVyhNgTf8fJvpxBNkNR65MTGGbmASpf454A
         UXa9cnzN8SuTM0klP6FtA66ZnL4HC9E958Tr0ywN4T0jrh0OAE9jxKdcl1apC86yUnAZ
         lAcNHUUBML0SoYGrH+ldtYy0lZrxwuESWO1wWOeiR1Dmo9EYF9NnZQyONhcY6rXblRhB
         /9ZEvX/ySlv4VJCGgBn2QV8aqieGExoAf7gx3j+noWRUrUcuU/mFlR3IPseqvYh2gQwL
         l+L2CPtwCEW15QvzQiit3nutFi7ly7krxLhpYSdmEX46Ya8NFQdKzAeAIubKYWL/719c
         5CbA==
X-Gm-Message-State: AOJu0YwevPqTH7h5tXXf+3yBnbEyPNEvi0WyCDZF0zoM49D5XLA8iAdG
	uUxnrKFgGvfS3YMKMPbuuBd8VldYXm9keaCSqDyZPhr9OSp5AfrOPGpjSw==
X-Google-Smtp-Source: AGHT+IGaCG7xpCeay7OUILy6vmvstUdB5DfJAXcygvhCMvqTAxdsB32BV+eScidvcy0VPlqgMLAFaA==
X-Received: by 2002:a9d:77ca:0:b0:709:2721:ad44 with SMTP id 46e09a7af769-70940c0eb28mr74712a34.12.1722010355315;
        Fri, 26 Jul 2024 09:12:35 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:35 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 3/7] rtnl: Add a builder for RTM_{NEW|DEL}ROUTE messages
Date: Fri, 26 Jul 2024 11:12:15 -0500
Message-ID: <20240726161232.146982-3-denkenz@gmail.com>
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
simpler to understand.  Use 'rtm' for struct rtmsg since that is the
common convention.
---
 ell/rtnl-private.h |  4 +++
 ell/rtnl.c         | 76 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+)

diff --git a/ell/rtnl-private.h b/ell/rtnl-private.h
index 8af2ca6d52aa..ade43b3f053a 100644
--- a/ell/rtnl-private.h
+++ b/ell/rtnl-private.h
@@ -28,3 +28,7 @@ struct l_rtnl_route {
 	uint32_t priority;
 	uint8_t preference;
 };
+
+struct l_netlink_message *rtnl_message_from_route(uint16_t type, uint16_t flags,
+						int ifindex,
+						const struct l_rtnl_route *rt);
diff --git a/ell/rtnl.c b/ell/rtnl.c
index ad2dca2f9e3c..dc3f456e0110 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -27,6 +27,7 @@
 #include "log.h"
 #include "util.h"
 #include "time.h"
+#include "netlink-private.h"
 #include "rtnl-private.h"
 #include "rtnl.h"
 #include "private.h"
@@ -714,6 +715,23 @@ static size_t rta_add_address(void *rta_buf, unsigned short type,
 	return 0;
 }
 
+static int append_address(struct l_netlink_message *nlm, uint16_t type,
+				uint8_t family,
+				const struct in6_addr *v6,
+				const struct in_addr *v4)
+{
+	switch (family) {
+	case AF_INET6:
+		l_netlink_message_append(nlm, type, v6, sizeof(struct in6_addr));
+		return 0;
+	case AF_INET:
+		l_netlink_message_append(nlm, type, v4, sizeof(struct in_addr));
+		return 0;
+	}
+
+	return -EAFNOSUPPORT;
+}
+
 static void l_rtnl_route_extract(const struct rtmsg *rtmsg, uint32_t len,
 				int family, uint32_t *table, uint32_t *ifindex,
 				uint32_t *priority, uint8_t *pref,
@@ -1568,3 +1586,61 @@ LIB_EXPORT struct l_netlink *l_rtnl_get()
 
 	return rtnl;
 }
+
+struct l_netlink_message *rtnl_message_from_route(uint16_t type, uint16_t flags,
+						int ifindex,
+						const struct l_rtnl_route *rt)
+{
+	struct l_netlink_message *nlm = l_netlink_message_new(type, flags);
+	uint64_t now = l_time_now();
+	struct rtmsg rtm;
+
+	memset(&rtm, 0, sizeof(struct rtmsg));
+	rtm.rtm_family = rt->family;
+	rtm.rtm_table = RT_TABLE_MAIN;
+	rtm.rtm_protocol = rt->protocol;
+	rtm.rtm_type = RTN_UNICAST;
+	rtm.rtm_scope = rt->scope;
+	rtm.rtm_dst_len = rt->dst_prefix_len;
+
+	l_netlink_message_add_header(nlm, &rtm, sizeof(rtm));
+	l_netlink_message_append_u32(nlm, RTA_OIF, ifindex);
+
+	if (rt->priority)
+		l_netlink_message_append_u32(nlm, RTA_PRIORITY,
+						rt->priority + ifindex);
+
+	if (!address_is_null(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr))
+		append_address(nlm, RTA_GATEWAY, rt->family,
+					&rt->gw.in6_addr, &rt->gw.in_addr);
+
+	if (rt->dst_prefix_len)
+		append_address(nlm, RTA_DST, rt->family,
+					&rt->dst.in6_addr, &rt->dst.in_addr);
+
+	if (!address_is_null(rt->family, &rt->prefsrc.in_addr,
+						&rt->prefsrc.in6_addr))
+		append_address(nlm, RTA_PREFSRC, rt->family,
+						&rt->prefsrc.in6_addr,
+						&rt->prefsrc.in_addr);
+
+	if (rt->mtu) {
+		/*
+		 * NOTE: Legacy RTNL messages do not use NLA_F_NESTED flag
+		 * as they should.  l_netlink_message_enter_nested does.  The
+		 * kernel should still accept this however
+		 */
+		l_netlink_message_enter_nested(nlm, RTA_METRICS);
+		l_netlink_message_append_u32(nlm, RTAX_MTU, rt->mtu);
+		l_netlink_message_leave_nested(nlm);
+	}
+
+	if (rt->preference)
+		l_netlink_message_append_u8(nlm, RTA_PREF, rt->preference);
+
+	if (rt->expiry_time > now)
+		l_netlink_message_append_u32(nlm, RTA_EXPIRES,
+					l_time_to_secs(rt->expiry_time - now));
+
+	return nlm;
+}
-- 
2.45.2

