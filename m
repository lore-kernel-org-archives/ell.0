Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E290518030
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675092; cv=none; b=UGHKN9+OKxGiUeoh3EV6Ixo5drlnS1MqKSCiAkGQjp3brhaJ7A+BylXyRYadlO+TueTPSz3Rmi1OVMhpwODV0h88g4JRbzeF4MbNzLEdkYyArDQJm1uCAckPfYiWpDVBiCrKEg5hFC7D1ivB9Ex+tJwn27EDy6I4wouduzKTETU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675092; c=relaxed/simple;
	bh=g6mxt8O/vg7Spt4vp6gcKEqncw4JqwAGdTuRecP6aLw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=S8UfLHFCApD2/ArV40OjjcfSCk90cEY4j3aAjW3BANfBBNmV44Y6K0VUxRYHeX5qjRwWwgvY0vy9mz2vznNKkH3KuKRlAK/KOy1/LV4cA3asEon6daaTIJPVx6ULTmMdRf92vwgFp7SCFHvyWs7pFEdYFj3q/LO5rdcP+eik6tg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=K8HFA66j; arc=none smtp.client-ip=209.85.161.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K8HFA66j"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-5c667b28c82so2153908eaf.1
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675090; x=1722279890; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=uegv3AweMDG0BkxOh+/tA+bEATdYXMdlok3Fo1thj0A=;
        b=K8HFA66j8pZHfaI+CMPIb2B8/JG0a0s1xaOS8Z8xL6IQtvAamtDDEDHwOYHEDVQ7nr
         0FvY1c3e2F+UUV0oVQVPgJZnoZaaB/uxP9/L1uZB67KTILd9BQoV2ykeCipdIrrp9DJ0
         rJv+JFLmxfKb9Qg99NGy7iLjObygOOmrHFq34F52iYlTIbjjcpf95tf9HCT44Sdrz2mN
         xj/Y3dZ4oVjmB40MY7HKie7Fzh61DBsZXVCwp8nY4qFnGddr/nDYB6eEoAVjS0h+zRgS
         3fD3XxRJE/z3fsXbp4eSVrgMVm+KswdliFCJ+3nRkHUTZJg3PkzcxOb7bH0fXKgyxpIy
         L5Rw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675090; x=1722279890;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=uegv3AweMDG0BkxOh+/tA+bEATdYXMdlok3Fo1thj0A=;
        b=nmf1aZR+bhe92yNmwMxSw4aqSurN00LDP7+nbJTa9/hJi0SMeBk64j6P+ALtVF67DQ
         U4BzYAFb7OEJVPxblSqFwEkWTD6VKdYnwmyz154eSanedLH0mkSMkgLm+iXtDsZ7QGJc
         elf9S412161IkvFJOvRd/pftQjgChaHE5Vq22KAKx3VG7yw71Zw9OiW3zvQHdC1Q0GMi
         2FOFsxDmjySQxcAnIopnEeGU2lnb8qh3PoOYHOwvw/S8R8F9T4LxIn1SaA7jzVv3g1RR
         Ky2oNzx7RHr0sxn7yEsf8DPwVqv88fDkPFYe2tpnmhJByKpljZl4pxKKFHchlHJjqpxa
         OwQg==
X-Gm-Message-State: AOJu0YzMQdqBBsjIccl2QqMMwuWgsjsXU3hZVDYWHvHA5wKTwZEA9ql3
	wa7oxneAq6FAl2M8mTDXtRd4zwnWZlLWnflZYeT7C7PTkpgpygnuxpx+tg==
X-Google-Smtp-Source: AGHT+IF6faZYeYXv5TZpObZvj9Xn2yPe/GfkIxV5dRnW6mBs4Gz7vWNmW/6luqvWd9z3iXzeV5Aw2Q==
X-Received: by 2002:a05:6820:199b:b0:5c4:79a5:c535 with SMTP id 006d021491bc7-5d564fd4baemr4937194eaf.2.1721675089946;
        Mon, 22 Jul 2024 12:04:49 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:49 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 06/12] netlink: Add l_netlink_message class
Date: Mon, 22 Jul 2024 14:04:23 -0500
Message-ID: <20240722190443.43196-6-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240722190443.43196-1-denkenz@gmail.com>
References: <20240722190443.43196-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Initial implementation of the l_netlink_message class.  For now, only
basic message building is supported.  Both RTNL (rtnetlink) and Generic
Netlink (genetlink) messages can be created by including the appropriate
header using l_netlink_message_add_header.
---
 ell/ell.sym           |   6 ++
 ell/netlink-private.h |  11 +++
 ell/netlink.c         | 174 ++++++++++++++++++++++++++++++++++++++++++
 ell/netlink.h         |  12 +++
 4 files changed, 203 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index bc0c6e10ebca..247786d5ee98 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -434,6 +434,12 @@ global:
 	l_netlink_register;
 	l_netlink_unregister;
 	l_netlink_set_debug;
+	l_netlink_message_new;
+	l_netlink_message_new_sized;
+	l_netlink_message_ref;
+	l_netlink_message_unref;
+	l_netlink_message_append;
+	l_netlink_message_add_header;
 	/* path */
 	l_basename;
 	l_path_find;
diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index fdb584e62652..d04af749b9fb 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -31,6 +31,17 @@ enum nlmsgerr_attrs {
 #define NLM_F_ACK_TLVS 0x200
 #endif
 
+struct l_netlink_message {
+	int ref_count;
+	uint32_t size;
+	union { /* The actual data */
+		struct nlmsghdr *hdr;
+		void *data;
+	};
+};
+
 bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
 					const char **out_error_msg,
 					uint32_t *out_error_offset);
+int netlink_message_reserve_header(struct l_netlink_message *message,
+					size_t header_len, void **out_header);
diff --git a/ell/netlink.c b/ell/netlink.c
index 2e23c8903509..39c5bc335e19 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -12,6 +12,7 @@
 #include <unistd.h>
 #include <sys/socket.h>
 #include <linux/netlink.h>
+#include <limits.h>
 
 #include "useful.h"
 #include "hashmap.h"
@@ -687,3 +688,176 @@ bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
 
 	return true;
 }
+
+static int message_grow(struct l_netlink_message *message, uint32_t needed)
+{
+	uint32_t grow_to;
+
+	if (message->size - message->hdr->nlmsg_len >= needed)
+		return 0;
+
+	/*
+	 * Kernel places a practical limit on the size of messages it will
+	 * accept, at least without tweaking SNDBUF.  There's no (known) reason
+	 * to send very large messages, so limit accordingly
+	 */
+	grow_to = message->hdr->nlmsg_len + needed;
+	if (grow_to > (1U << 20))
+		return -EMSGSIZE;
+
+	if (grow_to < l_util_pagesize())
+		grow_to = roundup_pow_of_two(grow_to);
+	else
+		grow_to = align_len(grow_to, l_util_pagesize());
+
+	message->data = l_realloc(message->data, grow_to);
+	message->size = grow_to;
+
+	return 0;
+}
+
+static inline void *message_tail(struct l_netlink_message *message)
+{
+	return message->data + NLMSG_ALIGN(message->hdr->nlmsg_len);
+}
+
+static int add_attribute(struct l_netlink_message *message,
+				uint16_t type, size_t len,
+				void **out_dest)
+{
+	struct nlattr *attr = message_tail(message);
+	int offset = message->hdr->nlmsg_len;
+
+	attr->nla_type = type;
+	attr->nla_len = NLA_HDRLEN + len;
+
+	if (len) {
+		void *dest = message_tail(message) + NLA_HDRLEN;
+
+		memset(dest + len, 0, NLA_ALIGN(len) - len);
+
+		if (out_dest)
+			*out_dest = dest;
+	}
+
+	message->hdr->nlmsg_len += NLA_HDRLEN + NLA_ALIGN(len);
+
+	return offset;
+}
+
+LIB_EXPORT struct l_netlink_message *l_netlink_message_new_sized(uint16_t type,
+					uint16_t flags, size_t initial_len)
+{
+	struct l_netlink_message *message;
+
+	message = l_new(struct l_netlink_message, 1);
+
+	message->size = initial_len + NLMSG_HDRLEN;
+	message->hdr = l_realloc(NULL, message->size);
+	memset(message->hdr, 0, NLMSG_HDRLEN);
+
+	message->hdr->nlmsg_len = NLMSG_HDRLEN;
+	message->hdr->nlmsg_type = type;
+	message->hdr->nlmsg_flags = flags;
+	/* seq and pid will be filled on send */
+	message->hdr->nlmsg_pid = 0;
+
+	return l_netlink_message_ref(message);
+
+}
+
+LIB_EXPORT struct l_netlink_message *l_netlink_message_new(uint16_t type,
+								uint16_t flags)
+{
+	return l_netlink_message_new_sized(type, flags, 256 - NLMSG_HDRLEN);
+}
+
+LIB_EXPORT struct l_netlink_message *l_netlink_message_ref(
+					struct l_netlink_message *message)
+{
+	if (unlikely(!message))
+		return NULL;
+
+	__atomic_fetch_add(&message->ref_count, 1, __ATOMIC_SEQ_CST);
+
+	return message;
+}
+
+LIB_EXPORT void l_netlink_message_unref(struct l_netlink_message *message)
+{
+	if (unlikely(!message))
+		return;
+
+	if (__atomic_sub_fetch(&message->ref_count, 1, __ATOMIC_SEQ_CST))
+		return;
+
+	l_free(message->hdr);
+	l_free(message);
+}
+
+LIB_EXPORT int l_netlink_message_append(struct l_netlink_message *message,
+						uint16_t type,
+						const void *data, size_t len)
+{
+	void *dest;
+	int r;
+
+	if (unlikely(!message))
+		return -EINVAL;
+
+	if (len > USHRT_MAX - NLA_HDRLEN)
+		return -ERANGE;
+
+	r = message_grow(message, NLA_HDRLEN + NLA_ALIGN(len));
+	if (r < 0)
+		return r;
+
+	r = add_attribute(message, type, len, &dest);
+	if (r < 0)
+		return r;
+
+	memcpy(dest, data, len);
+
+	return 0;
+}
+
+int netlink_message_reserve_header(struct l_netlink_message *message,
+					size_t len, void **out_header)
+{
+	int r;
+
+	if (message->hdr->nlmsg_len != NLMSG_HDRLEN)
+		return -EBADE;
+
+	if (len > USHRT_MAX)
+		return -ERANGE;
+
+	r = message_grow(message, NLA_ALIGN(len));
+	if (r < 0)
+		return r;
+
+	if (out_header)
+		*out_header = message_tail(message);
+
+	memset(message_tail(message) + len, 0, NLA_ALIGN(len) - len);
+	message->hdr->nlmsg_len += NLA_ALIGN(len);
+	return 0;
+}
+
+LIB_EXPORT int l_netlink_message_add_header(struct l_netlink_message *message,
+						const void *header,
+						size_t len)
+{
+	int r;
+	void *dest;
+
+	if (unlikely(!message || !len))
+		return -EINVAL;
+
+	r = netlink_message_reserve_header(message, len, &dest);
+	if (r < 0)
+		return r;
+
+	memcpy(dest, header, len);
+	return 0;
+}
diff --git a/ell/netlink.h b/ell/netlink.h
index 3f3dc50e14be..70a55d652560 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -44,6 +44,18 @@ bool l_netlink_set_debug(struct l_netlink *netlink,
 			l_netlink_debug_func_t function,
 			void *user_data, l_netlink_destroy_func_t destroy);
 
+struct l_netlink_message *l_netlink_message_new(uint16_t type, uint16_t flags);
+struct l_netlink_message *l_netlink_message_new_sized(uint16_t type,
+							uint16_t flags,
+							size_t initial_size);
+struct l_netlink_message *l_netlink_message_ref(
+					struct l_netlink_message *message);
+void l_netlink_message_unref(struct l_netlink_message *message);
+int l_netlink_message_append(struct l_netlink_message *message, uint16_t type,
+					const void *data, size_t len);
+int l_netlink_message_add_header(struct l_netlink_message *message,
+					const void *header, size_t len);
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.2

