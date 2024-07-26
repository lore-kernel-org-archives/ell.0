Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF93317BB1F
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010362; cv=none; b=NLmb66C0dbOZl6Iz97IxMTcF7uyjga5HfgnfvgXPn0PoVeTw9vHwfwxjSPYoevlA+1QCH3qFZW4ih9ygw7+YUagdPlJJLT4t0V/kLOVY6aOEC4Y5ffViYZwpK8U3ntaV2F34opfmxsqVHV0wUs+73O8gslGVO+RkFKHeDytP+0g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010362; c=relaxed/simple;
	bh=vV2D3zIUFUONy0Gv4sXLvQ4y4JORKB98h4aWQneNznM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NreYRaE8IGL9XsAJxIB+3o6bPLp5HX0wnQuOZ8RwfSlxW1PkkGcFQPy60pKDznUjvBZ/Gx9dgXlD/lORFwZo/OrNfP9GY4pKP5niN+p1LxM3lk9X9ZZNVrRtwWYcWDzFrJICawTdqUBgNT3teKrtlx/IV65p9XBpJZ4Sc43kC/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Djh7A3ie; arc=none smtp.client-ip=209.85.210.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Djh7A3ie"
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-7092fb4317dso1041065a34.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010359; x=1722615159; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=UaK9tAB1Mc5Cdl6rqfGmVfeOhgn4sWis+4to48bL/Dk=;
        b=Djh7A3ieZpYvtM+Fr+xDypha55DissDvsAhk/Lv30BJB3KdY5XJlOJnwz5m+WAgzbf
         E5BxGWftmPfrA6umuGC6Ko4dEGeWr+aMwieD80BtYxwF0DyzZN4Ym03hzZx2Yv+NcUx3
         6qbpO6WGGV5LMxrLLT6NZfTwfB89wdG55SnN2rJE6lQUdBL4RzTwPGP5WKud6W+czOzb
         wJJtACxhUR5WuHBJyURYXSXOxu0UsXTEmhqvZen8nxf+26miY+8CdkFl+byf2Wq4ujTi
         s9QOduLWjqGBSWOZzc9UByTJ+ZYQLoVSf+13lpXQ4YW4pcfLbyAny5JvVuaCqzgNo/Ie
         8N6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010359; x=1722615159;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=UaK9tAB1Mc5Cdl6rqfGmVfeOhgn4sWis+4to48bL/Dk=;
        b=lVrOc7/rkGg/OWllg/0/aRCkuxv0BUqH5VBjU8ZXA4U8a5UKp+nPV9lLnXMgszswtK
         8rhQDo7xW7LDj3OFivKfsLc3bhgD4xKdLtui8QsVpfrln8Br1lB2VvgcywHrRd8aXGTV
         sxGDiXhFWPi+IsehT08yejJkoscRcBxueaEuSy49iZzrYY2BWFgtPkkNg+4Edzxv2xis
         1onoKTu5R11S35rVSxNNJLSHtzNQBKNRKwAzES/+1I3mSsgvH/c1CZSueWJpkXBQefkR
         4E8HgalAkXtrhAObP8uQtN2sGZog11420v3Mxwv7Aj6BG9/FlutP+fiO3rNShOL4KQqA
         5Wow==
X-Gm-Message-State: AOJu0YxDaPqkAUnAXc7IAtAu/xIQfqhSxfgAXa4MUbgfVbppcX0zZn0o
	X0AFehxvxNj80RPUz7FM165t3DX3WnMbJjzaXjurtkVm7ovifAJwT5zHTw==
X-Google-Smtp-Source: AGHT+IFmSKjW1yOIoWfU5l1VP6bWSYy9km8Qd9BoCVycqqK8dpVoMIqwydxiC4jalz2sTy+J94jNKg==
X-Received: by 2002:a9d:708f:0:b0:703:69b5:1518 with SMTP id 46e09a7af769-70940c14c11mr66385a34.16.1722010358453;
        Fri, 26 Jul 2024 09:12:38 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:38 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 7/7] netlink/rtnl: Change l_netlink_send API
Date: Fri, 26 Jul 2024 11:12:19 -0500
Message-ID: <20240726161232.146982-7-denkenz@gmail.com>
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

Change l_netlink_send API to operate on newly introduced
l_netlink_message objects instead of arbitrary void * buffers.  This
cuts down the number of arguments to l_netlink_send considerably, making
it much easier to use.

The change in public API does affect the test-netlink unit test.  Fix it
up to use the new API as well.
---
 ell/netlink.c       |  80 ++++----
 ell/netlink.h       |   8 +-
 ell/rtnl.c          | 453 +++++++++++---------------------------------
 unit/test-netlink.c |  11 +-
 4 files changed, 151 insertions(+), 401 deletions(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index b6d5fb1fd36d..121a322fccf5 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -24,11 +24,10 @@
 
 struct command {
 	unsigned int id;
-	uint32_t seq;
-	uint32_t len;
 	l_netlink_command_func_t handler;
 	l_netlink_destroy_func_t destroy;
 	void *user_data;
+	struct l_netlink_message *message;
 };
 
 struct notify {
@@ -61,6 +60,7 @@ static void destroy_command(void *data)
 	if (command->destroy)
 		command->destroy(command->user_data);
 
+	l_netlink_message_unref(command->message);
 	l_free(command);
 }
 
@@ -85,8 +85,8 @@ static bool can_write_data(struct l_io *io, void *user_data)
 {
 	struct l_netlink *netlink = user_data;
 	struct command *command;
+	struct nlmsghdr *hdr;
 	struct sockaddr_nl addr;
-	const void *data;
 	ssize_t written;
 	int sk;
 
@@ -94,28 +94,27 @@ static bool can_write_data(struct l_io *io, void *user_data)
 	if (!command)
 		return false;
 
+	hdr = command->message->hdr;
 	sk = l_io_get_fd(io);
 
 	memset(&addr, 0, sizeof(addr));
 	addr.nl_family = AF_NETLINK;
 	addr.nl_pid = 0;
 
-	data = ((void *) command) + NLMSG_ALIGN(sizeof(struct command));
-
-	written = sendto(sk, data, command->len, 0,
-				(struct sockaddr *) &addr, sizeof(addr));
-	if (written < 0 || (uint32_t) written != command->len) {
+	written = sendto(sk, hdr, hdr->nlmsg_len, 0,
+			(struct sockaddr *) &addr, sizeof(addr));
+	if (written < 0 || (uint32_t) written != hdr->nlmsg_len) {
 		l_hashmap_remove(netlink->command_lookup,
 					L_UINT_TO_PTR(command->id));
 		destroy_command(command);
 		return true;
 	}
 
-	l_util_hexdump(false, data, command->len,
+	l_util_hexdump(false, hdr, hdr->nlmsg_len,
 				netlink->debug_handler, netlink->debug_data);
 
 	l_hashmap_insert(netlink->command_pending,
-				L_UINT_TO_PTR(command->seq), command);
+				L_UINT_TO_PTR(hdr->nlmsg_seq), command);
 
 	return l_queue_length(netlink->command_queue) > 0;
 }
@@ -399,70 +398,55 @@ LIB_EXPORT void l_netlink_destroy(struct l_netlink *netlink)
 }
 
 LIB_EXPORT unsigned int l_netlink_send(struct l_netlink *netlink,
-			uint16_t type, uint16_t flags, const void *data,
-			uint32_t len, l_netlink_command_func_t function,
-			void *user_data, l_netlink_destroy_func_t destroy)
+					struct l_netlink_message *message,
+					l_netlink_command_func_t function,
+					void *user_data,
+					l_netlink_destroy_func_t destroy)
 {
 	struct command *command;
+	uint16_t extra_flags = NLM_F_REQUEST;
 	struct nlmsghdr *nlmsg;
-	size_t size;
 
 	if (unlikely(!netlink))
 		return 0;
 
-	if (flags & 0xff)
+	if (unlikely(message->nest_level))
 		return 0;
 
 	if (function)
-		flags |= NLM_F_ACK;
+		extra_flags |= NLM_F_ACK;
 
-	size = NLMSG_ALIGN(sizeof(struct command)) +
-					NLMSG_HDRLEN + NLMSG_ALIGN(len);
+	command = l_new(struct command, 1);
 
-	command = l_malloc(size);
+	if (!l_hashmap_insert(netlink->command_lookup,
+				L_UINT_TO_PTR(netlink->next_command_id),
+				command)) {
+		l_free(command);
+		return 0;
+	}
 
-	memset(command, 0, size);
 	command->handler = function;
 	command->destroy = destroy;
 	command->user_data = user_data;
+	command->id = netlink->next_command_id++;
+	command->message = message;
+	message->sealed = true;
 
-	command->id = netlink->next_command_id;
-
-	if (!l_hashmap_insert(netlink->command_lookup,
-					L_UINT_TO_PTR(command->id), command))
-		goto free_command;
-
-	command->seq = netlink->next_seq++;
-	command->len = NLMSG_HDRLEN + NLMSG_ALIGN(len);
-
-	nlmsg = ((void *) command) + NLMSG_ALIGN(sizeof(struct command));
-
-	nlmsg->nlmsg_len = command->len;
-	nlmsg->nlmsg_type = type;
-	nlmsg->nlmsg_flags = NLM_F_REQUEST | flags;
-	nlmsg->nlmsg_seq = command->seq;
+	nlmsg = message->hdr;
+	nlmsg->nlmsg_flags |= extra_flags;
+	nlmsg->nlmsg_seq = netlink->next_seq++;
 	nlmsg->nlmsg_pid = netlink->pid;
 
-	if (data && len > 0)
-		memcpy(((void *) nlmsg) + NLMSG_HDRLEN, data, len);
-
 	l_queue_push_tail(netlink->command_queue, command);
-
 	l_io_set_write_handler(netlink->io, can_write_data, netlink, NULL);
 
-	netlink->next_command_id++;
-
 	return command->id;
-
-free_command:
-	l_free(command);
-
-	return 0;
 }
 
 LIB_EXPORT bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id)
 {
 	struct command *command;
+	struct nlmsghdr *hdr;
 
 	if (unlikely(!netlink || !id))
 		return false;
@@ -471,9 +455,11 @@ LIB_EXPORT bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id)
 	if (!command)
 		return false;
 
+	hdr = command->message->hdr;
+
 	if (!l_queue_remove(netlink->command_queue, command)) {
 		l_hashmap_remove(netlink->command_pending,
-					L_UINT_TO_PTR(command->seq));
+					L_UINT_TO_PTR(hdr->nlmsg_seq));
 	}
 
 	destroy_command(command);
diff --git a/ell/netlink.h b/ell/netlink.h
index e7962b9932dc..08aff74fbac2 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -25,14 +25,16 @@ typedef void (*l_netlink_notify_func_t) (uint16_t type, const void *data,
 typedef void (*l_netlink_destroy_func_t) (void *user_data);
 
 struct l_netlink;
+struct l_netlink_message;
 
 struct l_netlink *l_netlink_new(int protocol);
 void l_netlink_destroy(struct l_netlink *netlink);
 
 unsigned int l_netlink_send(struct l_netlink *netlink,
-			uint16_t type, uint16_t flags, const void *data,
-			uint32_t len, l_netlink_command_func_t function,
-			void *user_data, l_netlink_destroy_func_t destroy);
+				struct l_netlink_message *message,
+				l_netlink_command_func_t function,
+				void *user_data,
+				l_netlink_destroy_func_t destroy);
 bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id);
 
 unsigned int l_netlink_register(struct l_netlink *netlink,
diff --git a/ell/rtnl.c b/ell/rtnl.c
index 90ff61c09d13..da5d219feb48 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -641,63 +641,6 @@ LIB_EXPORT bool l_rtnl_route_set_scope(struct l_rtnl_route *rt, uint8_t scope)
 	return true;
 }
 
-static size_t rta_add_u8(void *rta_buf, unsigned short type, uint8_t value)
-{
-	struct rtattr *rta = rta_buf;
-
-	rta->rta_len = RTA_LENGTH(sizeof(uint8_t));
-	rta->rta_type = type;
-	*((uint8_t *) RTA_DATA(rta)) = value;
-
-	return RTA_SPACE(sizeof(uint8_t));
-}
-
-static size_t rta_add_u32(void *rta_buf, unsigned short type, uint32_t value)
-{
-	struct rtattr *rta = rta_buf;
-
-	rta->rta_len = RTA_LENGTH(sizeof(uint32_t));
-	rta->rta_type = type;
-	*((uint32_t *) RTA_DATA(rta)) = value;
-
-	return RTA_SPACE(sizeof(uint32_t));
-}
-
-static size_t rta_add_data(void *rta_buf, unsigned short type, const void *data,
-								size_t data_len)
-{
-	struct rtattr *rta = rta_buf;
-
-	rta->rta_len = RTA_LENGTH(data_len);
-	rta->rta_type = type;
-	memcpy(RTA_DATA(rta), data, data_len);
-
-	return RTA_SPACE(data_len);
-}
-
-static size_t rta_add_address(void *rta_buf, unsigned short type,
-				uint8_t family,
-				const struct in6_addr *v6,
-				const struct in_addr *v4)
-{
-	struct rtattr *rta = rta_buf;
-
-	rta->rta_type = type;
-
-	switch (family) {
-	case AF_INET6:
-		rta->rta_len = RTA_LENGTH(sizeof(struct in6_addr));
-		memcpy(RTA_DATA(rta), v6, sizeof(struct in6_addr));
-		return RTA_SPACE(sizeof(struct in6_addr));
-	case AF_INET:
-		rta->rta_len = RTA_LENGTH(sizeof(struct in_addr));
-		memcpy(RTA_DATA(rta), v4, sizeof(struct in_addr));
-		return RTA_SPACE(sizeof(struct in_addr));
-	}
-
-	return 0;
-}
-
 static int append_address(struct l_netlink_message *nlm, uint16_t type,
 				uint8_t family,
 				const struct in6_addr *v6,
@@ -786,31 +729,18 @@ LIB_EXPORT uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	struct ifinfomsg *rtmmsg;
-	void *rta_buf;
-	size_t bufsize;
-	uint32_t id;
-
-	bufsize = NLMSG_ALIGN(sizeof(struct ifinfomsg)) +
-		RTA_SPACE(sizeof(uint8_t)) + RTA_SPACE(sizeof(uint8_t));
-
-	rtmmsg = l_malloc(bufsize);
-	memset(rtmmsg, 0, bufsize);
-
-	rtmmsg->ifi_family = AF_UNSPEC;
-	rtmmsg->ifi_index = ifindex;
+	struct l_netlink_message *nlm = l_netlink_message_new(RTM_SETLINK, 0);
+	struct ifinfomsg ifi;
 
-	rta_buf = (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifinfomsg));
+	memset(&ifi, 0, sizeof(ifi));
+	ifi.ifi_family = AF_UNSPEC;
+	ifi.ifi_index = ifindex;
 
-	rta_buf += rta_add_u8(rta_buf, IFLA_LINKMODE, linkmode);
-	rta_buf += rta_add_u8(rta_buf, IFLA_OPERSTATE, operstate);
+	l_netlink_message_add_header(nlm, &ifi, sizeof(ifi));
+	l_netlink_message_append_u8(nlm, IFLA_LINKMODE, linkmode);
+	l_netlink_message_append_u8(nlm, IFLA_OPERSTATE, operstate);
 
-	id = l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg,
-					rta_buf - (void *) rtmmsg,
-					cb, user_data, destroy);
-	l_free(rtmmsg);
-
-	return id;
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
@@ -820,34 +750,22 @@ LIB_EXPORT uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	struct ifinfomsg *rtmmsg;
-	void *rta_buf;
-	size_t bufsize;
-	uint32_t id;
-
-	bufsize = NLMSG_ALIGN(sizeof(struct ifinfomsg)) + RTA_SPACE(6);
+	struct l_netlink_message *nlm = l_netlink_message_new(RTM_SETLINK, 0);
+	struct ifinfomsg ifi;
 
-	rtmmsg = l_malloc(bufsize);
-	memset(rtmmsg, 0, bufsize);
-
-	rtmmsg->ifi_family = AF_UNSPEC;
-	rtmmsg->ifi_index = ifindex;
+	memset(&ifi, 0, sizeof(ifi));
+	ifi.ifi_family = AF_UNSPEC;
+	ifi.ifi_index = ifindex;
 
 	if (power_up) {
-		rtmmsg->ifi_change = IFF_UP;
-		rtmmsg->ifi_flags = IFF_UP;
+		ifi.ifi_change = IFF_UP;
+		ifi.ifi_flags = IFF_UP;
 	}
 
-	rta_buf = (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct ifinfomsg));
-
-	rta_buf += rta_add_data(rta_buf, IFLA_ADDRESS, (void *) addr, 6);
+	l_netlink_message_add_header(nlm, &ifi, sizeof(ifi));
+	l_netlink_message_append_mac(nlm, IFLA_ADDRESS, addr);
 
-	id = l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg,
-					rta_buf - (void *) rtmmsg,
-					cb, user_data, destroy);
-	l_free(rtmmsg);
-
-	return id;
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex,
@@ -855,25 +773,18 @@ LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	struct ifinfomsg *rtmmsg;
-	size_t bufsize;
-	uint32_t id;
-
-	bufsize = NLMSG_ALIGN(sizeof(struct ifinfomsg));
-
-	rtmmsg = l_malloc(bufsize);
-	memset(rtmmsg, 0, bufsize);
+	struct l_netlink_message *nlm = l_netlink_message_new(RTM_SETLINK, 0);
+	struct ifinfomsg ifi;
 
-	rtmmsg->ifi_family = AF_UNSPEC;
-	rtmmsg->ifi_index = ifindex;
-	rtmmsg->ifi_change = IFF_UP;
-	rtmmsg->ifi_flags = powered ? IFF_UP : 0;
+	memset(&ifi, 0, sizeof(ifi));
+	ifi.ifi_family = AF_UNSPEC;
+	ifi.ifi_index = ifindex;
+	ifi.ifi_change = IFF_UP;
+	ifi.ifi_flags = powered ? IFF_UP : 0;
 
-	id = l_netlink_send(rtnl, RTM_SETLINK, 0, rtmmsg, bufsize,
-					cb, user_data, destroy);
-	l_free(rtmmsg);
+	l_netlink_message_add_header(nlm, &ifi, sizeof(ifi));
 
-	return id;
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
@@ -919,21 +830,17 @@ LIB_EXPORT uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	struct ifaddrmsg *rtmmsg;
-	uint32_t id;
-
-	rtmmsg = l_malloc(sizeof(struct ifaddrmsg));
-	memset(rtmmsg, 0, sizeof(struct ifaddrmsg));
-
-	rtmmsg->ifa_family = AF_INET;
+	struct ifaddrmsg ifa;
+	struct l_netlink_message *nlm =
+		l_netlink_message_new_sized(RTM_GETADDR,
+						NLM_F_DUMP, sizeof(ifa));
 
-	id = l_netlink_send(rtnl, RTM_GETADDR, NLM_F_DUMP, rtmmsg,
-				sizeof(struct ifaddrmsg), cb, user_data,
-				destroy);
+	memset(&ifa, 0, sizeof(ifa));
+	ifa.ifa_family = AF_INET;
 
-	l_free(rtmmsg);
+	l_netlink_message_add_header(nlm, &ifa, sizeof(ifa));
 
-	return id;
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_ifaddr4_add(struct l_netlink *rtnl, int ifindex,
@@ -984,14 +891,17 @@ LIB_EXPORT uint32_t l_rtnl_route4_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	struct rtmsg rtmsg;
+	struct rtmsg rtm;
+	struct l_netlink_message *nlm =
+		l_netlink_message_new_sized(RTM_GETROUTE,
+						NLM_F_DUMP, sizeof(rtm));
 
-	memset(&rtmsg, 0, sizeof(struct rtmsg));
-	rtmsg.rtm_family = AF_INET;
+	memset(&rtm, 0, sizeof(rtm));
+	rtm.rtm_family = AF_INET;
 
-	return l_netlink_send(rtnl, RTM_GETROUTE, NLM_F_DUMP, &rtmsg,
-					sizeof(struct rtmsg), cb, user_data,
-					destroy);
+	l_netlink_message_add_header(nlm, &rtm, sizeof(rtm));
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_route4_add_connected(struct l_netlink *rtnl,
@@ -1075,21 +985,17 @@ LIB_EXPORT uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	struct ifaddrmsg *rtmmsg;
-	uint32_t id;
-
-	rtmmsg = l_malloc(sizeof(struct ifaddrmsg));
-	memset(rtmmsg, 0, sizeof(struct ifaddrmsg));
-
-	rtmmsg->ifa_family = AF_INET6;
+	struct ifaddrmsg ifa;
+	struct l_netlink_message *nlm =
+		l_netlink_message_new_sized(RTM_GETADDR,
+						NLM_F_DUMP, sizeof(ifa));
 
-	id = l_netlink_send(rtnl, RTM_GETADDR, NLM_F_DUMP, rtmmsg,
-				sizeof(struct ifaddrmsg), cb, user_data,
-				destroy);
+	memset(&ifa, 0, sizeof(ifa));
+	ifa.ifa_family = AF_INET6;
 
-	l_free(rtmmsg);
+	l_netlink_message_add_header(nlm, &ifa, sizeof(ifa));
 
-	return id;
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_ifaddr6_add(struct l_netlink *rtnl, int ifindex,
@@ -1131,14 +1037,17 @@ LIB_EXPORT uint32_t l_rtnl_route6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy)
 {
-	struct rtmsg rtmsg;
+	struct rtmsg rtm;
+	struct l_netlink_message *nlm =
+		l_netlink_message_new_sized(RTM_GETROUTE,
+						NLM_F_DUMP, sizeof(rtm));
 
-	memset(&rtmsg, 0, sizeof(struct rtmsg));
-	rtmsg.rtm_family = AF_INET6;
+	memset(&rtm, 0, sizeof(rtm));
+	rtm.rtm_family = AF_INET6;
 
-	return l_netlink_send(rtnl, RTM_GETROUTE, NLM_F_DUMP, &rtmsg,
-					sizeof(struct rtmsg), cb, user_data,
-					destroy);
+	l_netlink_message_add_header(nlm, &rtm, sizeof(rtm));
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_route6_add_gateway(struct l_netlink *rtnl,
@@ -1187,84 +1096,6 @@ LIB_EXPORT uint32_t l_rtnl_route6_delete_gateway(struct l_netlink *rtnl,
 	return r;
 }
 
-static uint32_t _rtnl_ifaddr_change(struct l_netlink *rtnl, uint16_t nlmsg_type,
-					int ifindex,
-					const struct l_rtnl_address *addr,
-					l_netlink_command_func_t cb,
-					void *user_data,
-					l_netlink_destroy_func_t destroy)
-{
-	struct ifaddrmsg *ifamsg;
-	void *buf;
-	size_t bufsize;
-	uint32_t id;
-	int flags = 0;
-	uint64_t now = l_time_now();
-
-	if  (nlmsg_type == RTM_NEWADDR)
-		flags = NLM_F_CREATE | NLM_F_REPLACE;
-
-	bufsize = NLMSG_ALIGN(sizeof(struct ifaddrmsg)) +
-					RTA_SPACE(sizeof(struct in6_addr)) +
-					RTA_SPACE(sizeof(struct in_addr)) +
-					RTA_SPACE(sizeof(uint32_t)) +
-					RTA_SPACE(IFNAMSIZ) +
-					RTA_SPACE(sizeof(struct ifa_cacheinfo));
-
-	ifamsg = l_malloc(bufsize);
-	memset(ifamsg, 0, bufsize);
-
-	ifamsg->ifa_index = ifindex;
-	ifamsg->ifa_family = addr->family;
-	ifamsg->ifa_scope = addr->scope;
-	ifamsg->ifa_prefixlen = addr->prefix_len;
-	/* Kernel ignores legacy flags in IFA_FLAGS, so set them here */
-	ifamsg->ifa_flags = addr->flags & 0xff;
-
-	buf = (void *) ifamsg + NLMSG_ALIGN(sizeof(struct ifaddrmsg));
-
-	if (addr->family == AF_INET) {
-		buf += rta_add_data(buf, IFA_LOCAL, &addr->in_addr,
-						sizeof(struct in_addr));
-		buf += rta_add_data(buf, IFA_BROADCAST, &addr->broadcast,
-						sizeof(struct in_addr));
-	} else
-		buf += rta_add_data(buf, IFA_LOCAL, &addr->in6_addr,
-						sizeof(struct in6_addr));
-
-	/* Address & Prefix length are enough to perform deletions */
-	if (nlmsg_type == RTM_DELADDR)
-		goto done;
-
-	if (addr->flags & 0xffffff00)
-		buf += rta_add_u32(buf, IFA_FLAGS, addr->flags & 0xffffff00);
-
-	if (addr->label[0])
-		buf += rta_add_data(buf, IFA_LABEL,
-					addr->label, strlen(addr->label) + 1);
-
-	if (addr->preferred_expiry_time > now ||
-			addr->valid_expiry_time > now) {
-		struct ifa_cacheinfo cinfo;
-
-		memset(&cinfo, 0, sizeof(cinfo));
-		cinfo.ifa_prefered = addr->preferred_expiry_time > now ?
-			l_time_to_secs(addr->preferred_expiry_time - now) : 0;
-		cinfo.ifa_valid =  addr->valid_expiry_time > now ?
-			l_time_to_secs(addr->valid_expiry_time - now) : 0;
-
-		buf += rta_add_data(buf, IFA_CACHEINFO, &cinfo, sizeof(cinfo));
-	}
-
-done:
-	id = l_netlink_send(rtnl, nlmsg_type, flags,
-				ifamsg, buf - (void *) ifamsg,
-				cb, user_data, destroy);
-	l_free(ifamsg);
-
-	return id;
-}
-
 LIB_EXPORT struct l_rtnl_address *l_rtnl_ifaddr_extract(
 						const struct ifaddrmsg *ifa,
 						int bytes)
@@ -1324,8 +1155,12 @@ LIB_EXPORT uint32_t l_rtnl_ifaddr_add(struct l_netlink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return _rtnl_ifaddr_change(rtnl, RTM_NEWADDR, ifindex, addr,
-						cb, user_data, destroy);
+	struct l_netlink_message *nlm =
+		rtnl_message_from_address(RTM_NEWADDR,
+						NLM_F_CREATE | NLM_F_REPLACE,
+						ifindex, addr);
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
@@ -1334,84 +1169,10 @@ LIB_EXPORT uint32_t l_rtnl_ifaddr_delete(struct l_netlink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return _rtnl_ifaddr_change(rtnl, RTM_DELADDR, ifindex, addr,
-						cb, user_data, destroy);
-}
+	struct l_netlink_message *nlm =
+		rtnl_message_from_address(RTM_DELADDR, 0, ifindex, addr);
 
-static uint32_t _rtnl_route_change(struct l_netlink *rtnl,
-					uint16_t nlmsg_type, int ifindex,
-					const struct l_rtnl_route *rt,
-					l_netlink_command_func_t cb,
-					void *user_data,
-					l_netlink_destroy_func_t destroy)
-{
-	L_AUTO_FREE_VAR(struct rtmsg *, rtmmsg) = NULL;
-	size_t bufsize;
-	void *rta_buf;
-	uint16_t flags;
-	uint64_t now = l_time_now();
-
-	bufsize = NLMSG_ALIGN(sizeof(struct rtmsg)) +
-			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_OIF */
-			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_PRIORITY */
-			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_GATEWAY */
-			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_DST */
-			RTA_SPACE(sizeof(struct in6_addr)) + /* RTA_PREFSRC */
-			256 +                                /* RTA_METRICS */
-			RTA_SPACE(sizeof(uint8_t)) +         /* RTA_PREF */
-			RTA_SPACE(sizeof(uint32_t));         /* RTA_EXPIRES */
-
-	rtmmsg = l_malloc(bufsize);
-	memset(rtmmsg, 0, bufsize);
-
-	rtmmsg->rtm_family = rt->family;
-	rtmmsg->rtm_table = RT_TABLE_MAIN;
-	rtmmsg->rtm_protocol = rt->protocol;
-	rtmmsg->rtm_type = RTN_UNICAST;
-	rtmmsg->rtm_scope = rt->scope;
-
-	flags = NLM_F_CREATE | NLM_F_REPLACE;
-
-	rta_buf = (void *) rtmmsg + NLMSG_ALIGN(sizeof(struct rtmsg));
-	rta_buf += rta_add_u32(rta_buf, RTA_OIF, ifindex);
-
-	if (rt->priority)
-		rta_buf += rta_add_u32(rta_buf, RTA_PRIORITY,
-						rt->priority + ifindex);
-
-	if (!address_is_null(rt->family, &rt->gw.in_addr, &rt->gw.in6_addr))
-		rta_buf += rta_add_address(rta_buf, RTA_GATEWAY, rt->family,
-					&rt->gw.in6_addr, &rt->gw.in_addr);
-
-	if (rt->dst_prefix_len) {
-		rtmmsg->rtm_dst_len = rt->dst_prefix_len;
-		rta_buf += rta_add_address(rta_buf, RTA_DST, rt->family,
-					&rt->dst.in6_addr, &rt->dst.in_addr);
-	}
-
-	if (!address_is_null(rt->family, &rt->prefsrc.in_addr,
-						&rt->prefsrc.in6_addr))
-		rta_buf += rta_add_address(rta_buf, RTA_PREFSRC, rt->family,
-						&rt->prefsrc.in6_addr,
-						&rt->prefsrc.in_addr);
-
-	if (rt->mtu) {
-		uint8_t buf[256];
-		size_t written = rta_add_u32(buf, RTAX_MTU, rt->mtu);
-
-		rta_buf += rta_add_data(rta_buf, RTA_METRICS, buf, written);
-	}
-
-	if (rt->preference)
-		rta_buf += rta_add_u8(rta_buf, RTA_PREF, rt->preference);
-
-	if (rt->expiry_time > now)
-		rta_buf += rta_add_u32(rta_buf, RTA_EXPIRES,
-					l_time_to_secs(rt->expiry_time - now));
-
-	return l_netlink_send(rtnl, nlmsg_type, flags, rtmmsg,
-				rta_buf - (void *) rtmmsg, cb, user_data,
-								destroy);
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_route_add(struct l_netlink *rtnl, int ifindex,
@@ -1420,8 +1181,12 @@ LIB_EXPORT uint32_t l_rtnl_route_add(struct l_netlink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return _rtnl_route_change(rtnl, RTM_NEWROUTE, ifindex, rt,
-						cb, user_data, destroy);
+	struct l_netlink_message *nlm =
+		rtnl_message_from_route(RTM_NEWROUTE,
+						NLM_F_CREATE | NLM_F_REPLACE,
+						ifindex, rt);
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 LIB_EXPORT uint32_t l_rtnl_route_delete(struct l_netlink *rtnl, int ifindex,
@@ -1430,8 +1195,10 @@ LIB_EXPORT uint32_t l_rtnl_route_delete(struct l_netlink *rtnl, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	return _rtnl_route_change(rtnl, RTM_DELROUTE, ifindex, rt,
-						cb, user_data, destroy);
+	struct l_netlink_message *nlm =
+		rtnl_message_from_route(RTM_DELROUTE, 0, ifindex, rt);
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 struct rtnl_neighbor_get_data {
@@ -1500,25 +1267,21 @@ LIB_EXPORT uint32_t l_rtnl_neighbor_get_hwaddr(struct l_netlink *rtnl,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	size_t bufsize = NLMSG_ALIGN(sizeof(struct ndmsg)) +
-			RTA_SPACE(16); /* NDA_DST */
-	uint8_t buf[bufsize];
-	struct ndmsg *ndmsg = (struct ndmsg *) buf;
-	void *rta_buf = (void *) ndmsg + NLMSG_ALIGN(sizeof(struct ndmsg));
+	struct ndmsg ndm;
+	struct l_netlink_message *nlm = l_netlink_message_new(RTM_GETNEIGH, 0);
 	__auto_type cb_data = struct_alloc(rtnl_neighbor_get_data,
 						cb, user_data, destroy);
-	uint32_t ret;
+	int ret;
 
-	memset(buf, 0, bufsize);
-	ndmsg->ndm_family = family;
-	ndmsg->ndm_ifindex = ifindex;
-	ndmsg->ndm_flags = 0;
+	memset(&ndm, 0, sizeof(ndm));
+	ndm.ndm_family = family;
+	ndm.ndm_ifindex = ifindex;
+	ndm.ndm_flags = 0;
 
-	rta_buf += rta_add_address(rta_buf, NDA_DST, family, ip, ip);
+	l_netlink_message_add_header(nlm, &ndm, sizeof(ndm));
+	append_address(nlm, NDA_DST, family, ip, ip);
 
-	ret = l_netlink_send(rtnl, RTM_GETNEIGH, 0, ndmsg,
-				rta_buf - (void *) ndmsg,
-				rtnl_neighbor_get_cb, cb_data,
+	ret = l_netlink_send(rtnl, nlm, rtnl_neighbor_get_cb, cb_data,
 				rtnl_neighbor_get_destroy_cb);
 	if (ret)
 		return ret;
@@ -1536,25 +1299,21 @@ LIB_EXPORT uint32_t l_rtnl_neighbor_set_hwaddr(struct l_netlink *rtnl,
 					void *user_data,
 					l_netlink_destroy_func_t destroy)
 {
-	size_t bufsize = NLMSG_ALIGN(sizeof(struct ndmsg)) +
-			RTA_SPACE(16) +        /* NDA_DST */
-			RTA_SPACE(hwaddr_len); /* NDA_LLADDR */
-	uint8_t buf[bufsize];
-	struct ndmsg *ndmsg = (struct ndmsg *) buf;
-	void *rta_buf = (void *) ndmsg + NLMSG_ALIGN(sizeof(struct ndmsg));
-
-	memset(buf, 0, bufsize);
-	ndmsg->ndm_family = family;
-	ndmsg->ndm_ifindex = ifindex;
-	ndmsg->ndm_flags = 0;
-	ndmsg->ndm_state = NUD_REACHABLE;
-
-	rta_buf += rta_add_address(rta_buf, NDA_DST, family, ip, ip);
-	rta_buf += rta_add_data(rta_buf, NDA_LLADDR, hwaddr, hwaddr_len);
-
-	return l_netlink_send(rtnl, RTM_NEWNEIGH, NLM_F_CREATE | NLM_F_REPLACE,
-				ndmsg, rta_buf - (void *) ndmsg,
-				cb, user_data, destroy);
+	struct ndmsg ndm;
+	struct l_netlink_message *nlm =
+			l_netlink_message_new(RTM_NEWNEIGH,
+						NLM_F_CREATE | NLM_F_REPLACE);
+	memset(&ndm, 0, sizeof(ndm));
+	ndm.ndm_family = family;
+	ndm.ndm_ifindex = ifindex;
+	ndm.ndm_flags = 0;
+	ndm.ndm_state = NUD_REACHABLE;
+
+	l_netlink_message_add_header(nlm, &ndm, sizeof(ndm));
+	append_address(nlm, NDA_DST, family, ip, ip);
+	l_netlink_message_append(nlm, NDA_LLADDR, hwaddr, hwaddr_len);
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
 __attribute__((destructor(32000))) static void free_rtnl()
diff --git a/unit/test-netlink.c b/unit/test-netlink.c
index 1bcf1e4b274c..da23ee5c9b0e 100644
--- a/unit/test-netlink.c
+++ b/unit/test-netlink.c
@@ -66,7 +66,10 @@ static void link_notification(uint16_t type, void const * data,
 int main(int argc, char *argv[])
 {
 	struct l_netlink *netlink;
-	struct ifinfomsg msg;
+	struct ifinfomsg ifi;
+	struct l_netlink_message *nlm =
+			l_netlink_message_new_sized(RTM_GETLINK,
+							NLM_F_DUMP, sizeof(ifi));
 	unsigned int link_id;
 
 	if (!l_main_init())
@@ -78,10 +81,10 @@ int main(int argc, char *argv[])
 
 	l_netlink_set_debug(netlink, do_debug, "[NETLINK] ", NULL);
 
-	memset(&msg, 0, sizeof(msg));
+	memset(&ifi, 0, sizeof(ifi));
+	l_netlink_message_add_header(nlm, &ifi, sizeof(ifi));
 
-	l_netlink_send(netlink, RTM_GETLINK, NLM_F_DUMP, &msg, sizeof(msg),
-						getlink_callback, NULL, NULL);
+	l_netlink_send(netlink, nlm, getlink_callback, NULL, NULL);
 
 	link_id = l_netlink_register(netlink, RTNLGRP_LINK,
 					link_notification, NULL, NULL);
-- 
2.45.2

