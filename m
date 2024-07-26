Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6509B200AF
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010360; cv=none; b=OcUjq3ZLzJllZezY/WJWKJm3oRHzaI7U7OOgfERBHZE6K5XpkuwTuNyD6908dFBXqy1KdJaTW6t6Qm1DMh2sQ/wgi/G9lGnWLLXIFSofMMihPc60wiOnAivr+7GgSHZHuGiVjNRYfY+kApzVsDO+s8FR/X55ukq6urENApV2fH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010360; c=relaxed/simple;
	bh=6qzZEigpv5QlG7OpjZ/0MbMZZMTvFY4iVI4yO3v/5JQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tn4pbxGZ5x7wnBLeECbS0XnFpbmEy6FZQIcvNObfJY6rMvKg/5OKOTw9jOXylgcQEHc7IEdzeF4U5PkvmcsU/ssGjUlobyLB3UlylUO/HrJsM0xPf4ICXrqlHS5LtxoICLenJSjA0kuLqwQ2OPz45UOYLjt9ESvb7xWuNAvw4WY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=igCHzcSP; arc=none smtp.client-ip=209.85.210.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="igCHzcSP"
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-7093472356dso665465a34.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010357; x=1722615157; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=bygahLkMum3pwIQh8kLmkuKwRo3R1qnjWtlLvb6L1gA=;
        b=igCHzcSP77UxCooX6DPqQzTx3skipmJwWPbAgy76Ywn5pVCR28pNUurSQaJZGauMgH
         +xBZvdpyuRt+DaVvoODHpavgngWcn4u0YEkn0dQ+hZquiPSjdTOlIU77w2B0HbHOMOHD
         QmDZSuZDJWEVX5jA67ooFB4ZJ5qqcNoSj16AKnP4y877TpCBewpuclyfT1hH6HHce0E3
         LMIO3z8n4//dUA59ajQmZQOzLzPfHHGUdmAM6H62vhEyyJFxZGPYBHXj8Sv+HnjLGZvs
         S8+6mgPrtmap/b1JqZJMtjcz6Bk1YnwqdgYJoywuxnL/iW49Sf0SSlWYc+S1imbI9g+2
         HZRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010357; x=1722615157;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=bygahLkMum3pwIQh8kLmkuKwRo3R1qnjWtlLvb6L1gA=;
        b=Ccrih+aHetIEFvMqF/HV9qVx3vp5k0bqr7YcqUSFEjnNlbJnDe4NOkqmhuW79isQ61
         vL+6LIRZbHHPDmyZexx5JEwAPbzzbiBydchgB3rBuR5LlrQmZK33YMWIpGAV/Z/hOFFl
         R11z5EBsEopKFkZ9aXgefQycof1YCClv9VQQdsTeWfOrFz9XV80OPCTz4N+EVdwvUbOb
         kEgFsMUbODjfEQ1pyIj6Rj6Dgg4VhpgfNOB9Wc3Ps1PNf3xQjpeRdwP1pmsz/yU21Vlb
         AAMB2W9Yp/zafxt0VPxSLKsMdXc0env9SwlFtsvi/pNoCRAnoIzkvtnNpYGboRysYcyH
         pEwQ==
X-Gm-Message-State: AOJu0YxGZjqX/7Gu0yLJZBRkFra3X7qg9dDNd+8t95yO1mT/sK6+XeSv
	NqF+BgHVbA5y4CkZFPbv4mhNOEZQU/rj2gcaxSKB00ujzgzSq3Zk2yH0Cw==
X-Google-Smtp-Source: AGHT+IGR213Egl/bBq2iPZp42kn+wMDar7oRKpUuJB/xQeVwFDoPSUT4aNou4+j0R9KHgzEikGAzDQ==
X-Received: by 2002:a05:6830:498f:b0:708:bea8:ae28 with SMTP id 46e09a7af769-70940c04164mr99767a34.2.1722010356992;
        Fri, 26 Jul 2024 09:12:36 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:36 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 5/7] unit: Add tests for rtnl_message_from_{route|address}
Date: Fri, 26 Jul 2024 11:12:17 -0500
Message-ID: <20240726161232.146982-5-denkenz@gmail.com>
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

---
 unit/test-rtnl.c | 278 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 277 insertions(+), 1 deletion(-)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index cd944af64de9..25e1859205b4 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -17,12 +17,282 @@
 #include <signal.h>
 #include <sys/wait.h>
 #include <asm/types.h>
+#include <arpa/inet.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/neighbour.h>
+#include <linux/icmpv6.h>
+#include <linux/if.h>
 #include <sys/socket.h>
+#include <assert.h>
+#include <limits.h>
 
 #include <ell/ell.h>
-#include "ell/dbus-private.h"
+#include "ell/netlink-private.h"
+#include "ell/rtnl-private.h"
+#include "ell/useful.h"
+
+static size_t rta_add_u8(void *rta_buf, unsigned short type, uint8_t value)
+{
+	struct rtattr *rta = rta_buf;
+
+	rta->rta_len = RTA_LENGTH(sizeof(uint8_t));
+	rta->rta_type = type;
+	*((uint8_t *) RTA_DATA(rta)) = value;
+
+	return RTA_SPACE(sizeof(uint8_t));
+}
+
+static size_t rta_add_u32(void *rta_buf, unsigned short type, uint32_t value)
+{
+	struct rtattr *rta = rta_buf;
+
+	rta->rta_len = RTA_LENGTH(sizeof(uint32_t));
+	rta->rta_type = type;
+	*((uint32_t *) RTA_DATA(rta)) = value;
+
+	return RTA_SPACE(sizeof(uint32_t));
+}
+
+static size_t rta_add_data(void *rta_buf, unsigned short type, const void *data,
+								size_t data_len)
+{
+	struct rtattr *rta = rta_buf;
+
+	rta->rta_len = RTA_LENGTH(data_len);
+	rta->rta_type = type;
+	memcpy(RTA_DATA(rta), data, data_len);
+
+	return RTA_SPACE(data_len);
+}
+
+static size_t rta_add_address(void *rta_buf, unsigned short type,
+				uint8_t family,
+				const struct in6_addr *v6,
+				const struct in_addr *v4)
+{
+	struct rtattr *rta = rta_buf;
+
+	rta->rta_type = type;
+
+	switch (family) {
+	case AF_INET6:
+		rta->rta_len = RTA_LENGTH(sizeof(struct in6_addr));
+		memcpy(RTA_DATA(rta), v6, sizeof(struct in6_addr));
+		return RTA_SPACE(sizeof(struct in6_addr));
+	case AF_INET:
+		rta->rta_len = RTA_LENGTH(sizeof(struct in_addr));
+		memcpy(RTA_DATA(rta), v4, sizeof(struct in_addr));
+		return RTA_SPACE(sizeof(struct in_addr));
+	}
+
+	return 0;
+}
+
+static int address_is_null(int family, const struct in_addr *v4,
+						const struct in6_addr *v6)
+{
+	switch (family) {
+	case AF_INET:
+		return v4->s_addr == 0;
+	case AF_INET6:
+		return IN6_IS_ADDR_UNSPECIFIED(v6);
+	}
+
+	return -EAFNOSUPPORT;
+}
+
+static bool messages_equal(const struct l_netlink_message *nlm,
+				void *other_message, size_t len)
+{
+
+	if (len != nlm->hdr->nlmsg_len - NLMSG_HDRLEN)
+		return false;
+
+	return !memcmp(nlm->data + NLMSG_HDRLEN, other_message, len);
+}
+
+static const struct l_rtnl_route route = {
+	.family = AF_INET6,
+	.scope = RT_SCOPE_UNIVERSE,
+	.protocol = RTPROT_UNSPEC,
+	.gw = { .in6_addr = IN6ADDR_LOOPBACK_INIT },
+	.dst = { .in6_addr = IN6ADDR_LOOPBACK_INIT },
+	.dst_prefix_len = 32,
+	.prefsrc = { .in6_addr = IN6ADDR_LOOPBACK_INIT },
+	.lifetime = INT_MAX,
+	.expiry_time = 0, /* math performed, will cause messages to differ */
+	.mtu = 8096,
+	.priority = 300,
+	.preference = ICMPV6_ROUTER_PREF_LOW,
+};
+
+static struct rtmsg *build_rtmsg(const struct l_rtnl_route *rt, int ifindex,
+					size_t *out_len)
+{
+	struct rtmsg *rtmmsg;
+	size_t bufsize;
+	void *rta_buf;
+	uint64_t now = l_time_now();
+
+	bufsize = NLMSG_ALIGN(sizeof(struct rtmsg)) +
+			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_OIF */
+			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_PRIORITY */
+			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_GATEWAY */
+			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_DST */
+			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_PREFSRC */
+			256 +                                /* RTA_METRICS */
+			RTA_SPACE(sizeof(uint8_t)) +         /* RTA_PREF */
+			RTA_SPACE(sizeof(uint32_t));         /* RTA_EXPIRES */
+
+	rtmmsg = l_malloc(bufsize);
+	memset(rtmmsg, 0, bufsize);
+
+	rtmmsg->rtm_family = rt->family;
+	rtmmsg->rtm_table = RT_TABLE_MAIN;
+	rtmmsg->rtm_protocol = rt->protocol;
+	rtmmsg->rtm_type = RTN_UNICAST;
+	rtmmsg->rtm_scope = rt->scope;
+
+	rta_buf = (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct rtmsg));
+	rta_buf += rta_add_u32(rta_buf, RTA_OIF, ifindex);
+
+	if (rt->priority)
+		rta_buf += rta_add_u32(rta_buf, RTA_PRIORITY,
+						rt->priority + ifindex);
+
+	if (!address_is_null(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr))
+		rta_buf += rta_add_address(rta_buf, RTA_GATEWAY, rt->family,
+					&rt->gw.in6_addr, &rt->gw.in_addr);
+
+	if (rt->dst_prefix_len) {
+		rtmmsg->rtm_dst_len = rt->dst_prefix_len;
+		rta_buf += rta_add_address(rta_buf, RTA_DST, rt->family,
+					&rt->dst.in6_addr, &rt->dst.in_addr);
+	}
+
+	if (!address_is_null(rt->family, &rt->prefsrc.in_addr,
+						&rt->prefsrc.in6_addr))
+		rta_buf += rta_add_address(rta_buf, RTA_PREFSRC, rt->family,
+						&rt->prefsrc.in6_addr,
+						&rt->prefsrc.in_addr);
+
+	if (rt->mtu) {
+		uint8_t buf[256];
+		size_t written = rta_add_u32(buf, RTAX_MTU, rt->mtu);
+
+		rta_buf += rta_add_data(rta_buf, RTA_METRICS | NLA_F_NESTED,
+							buf, written);
+	}
+
+	if (rt->preference)
+		rta_buf += rta_add_u8(rta_buf, RTA_PREF, rt->preference);
+
+	if (rt->expiry_time > now)
+		rta_buf += rta_add_u32(rta_buf, RTA_EXPIRES,
+					l_time_to_secs(rt->expiry_time - now));
+
+	*out_len = rta_buf - (void *) rtmmsg;
+	return rtmmsg;
+}
+
+static void test_route(const void *data)
+{
+	static const int ifindex = 3;
+	size_t rtmsg_len;
+	_auto_(l_free) void *rtmsg = build_rtmsg(&route, ifindex, &rtmsg_len);
+	struct l_netlink_message *nlm =
+		rtnl_message_from_route(RTM_NEWROUTE,
+					NLM_F_CREATE | NLM_F_REPLACE,
+					ifindex, &route);
+
+	assert(messages_equal(nlm, rtmsg, rtmsg_len));
+	l_netlink_message_unref(nlm);
+}
+
+static const struct l_rtnl_address address = {
+	.family = AF_INET6,
+	.prefix_len = 31,
+	.scope = RT_SCOPE_UNIVERSE,
+	.in6_addr = IN6ADDR_LOOPBACK_INIT,
+	.label = { 'f', 'o', 'o', 'b', 'a', 'r', '\0' },
+	.flags = IFA_F_PERMANENT | IFA_F_NOPREFIXROUTE,
+};
+
+static struct ifaddrmsg *build_ifaddrmsg(const struct l_rtnl_address *addr,
+						int ifindex, size_t *out_len)
+{
+	struct ifaddrmsg *ifamsg;
+	void *buf;
+	size_t bufsize;
+	uint64_t now = l_time_now();
+
+	bufsize = NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
+					RTA_SPACE(sizeof(struct in6_addr)) +
+					RTA_SPACE(sizeof(struct in_addr)) +
+					RTA_SPACE(sizeof(uint32_t)) +
+					RTA_SPACE(IFNAMSIZ) +
+					RTA_SPACE(sizeof(struct ifa_cacheinfo));
+
+	ifamsg = l_malloc(bufsize);
+	memset(ifamsg, 0, bufsize);
+
+	ifamsg->ifa_index = ifindex;
+	ifamsg->ifa_family = addr->family;
+	ifamsg->ifa_scope = addr->scope;
+	ifamsg->ifa_prefixlen = addr->prefix_len;
+	/* Kernel ignores legacy flags in IFA_FLAGS, so set them here */
+	ifamsg->ifa_flags = addr->flags & 0xff;
+
+	buf = (void *) ifamsg + NLMSG_ALIGN(sizeof(struct ifaddrmsg));
+
+	if (addr->family == AF_INET) {
+		buf += rta_add_data(buf, IFA_LOCAL, &addr->in_addr,
+						sizeof(struct in_addr));
+		buf += rta_add_data(buf, IFA_BROADCAST, &addr->broadcast,
+						sizeof(struct in_addr));
+	} else
+		buf += rta_add_data(buf, IFA_LOCAL, &addr->in6_addr,
+						sizeof(struct in6_addr));
+
+	if (addr->flags & 0xffffff00)
+		buf += rta_add_u32(buf, IFA_FLAGS, addr->flags & 0xffffff00);
+
+	if (addr->label[0])
+		buf += rta_add_data(buf, IFA_LABEL,
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
+		buf += rta_add_data(buf, IFA_CACHEINFO, &cinfo, sizeof(cinfo));
+	}
+
+	*out_len = buf - (void *) ifamsg;
+	return ifamsg;
+}
+
+static void test_address(const void *data)
+{
+	static const int ifindex = 3;
+	size_t ifamsg_len;
+	_auto_(l_free) void *ifamsg =
+				build_ifaddrmsg(&address, ifindex, &ifamsg_len);
+	struct l_netlink_message *nlm =
+		rtnl_message_from_address(RTM_NEWADDR,
+					NLM_F_CREATE | NLM_F_REPLACE,
+					ifindex, &address);
+
+	assert(messages_equal(nlm, ifamsg, ifamsg_len));
+	l_netlink_message_unref(nlm);
+}
 
 static void signal_handler(uint32_t signo, void *user_data)
 {
@@ -234,6 +504,12 @@ int main(int argc, char *argv[])
 	if (!l_main_init())
 		return -1;
 
+	/* Run the the tests not requiring the main event loop first */
+	l_test_init(&argc, &argv);
+	l_test_add("route", test_route, NULL);
+	l_test_add("address", test_address, NULL);
+	l_test_run();
+
 	test_add("Dump IPv4 routing table", test_route4_dump, NULL);
 	test_add("Dump IPv6 routing table", test_route6_dump, NULL);
 	test_add("Dump IPv4 addresses", test_ifaddr4_dump, NULL);
-- 
2.45.2

