Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A89C416F0CE
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675097; cv=none; b=DbPVjnVIkcupmFD1DNJFeVO8qqIMktYUI7T3pP/uI19w75n6yojsfn0IOIE3ZJj/lovJ3hISMQaRvH7JDIw/EdYoCL/0hqdOIjbmQDdNO8Ik8dZaSKs/TDL1nwxZN16QT5KhhQujT4sSLehLhXeblD+gYulYEQA91OV1PkqyBTU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675097; c=relaxed/simple;
	bh=jHZKLbVmRn9+/y5X+scseqa94IU1ZJGOyk8nYd6bOL4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fe18dKGNDByjtm32fk93AuWLtwLg52sk5T/OiDnwR8J5GzCeUrfFnGFrEz26IQPGuGLcDoKkCOYu8VxIKLkz6X9Gg2V5Bwu3aAtHwiffqk1fYilIF1+0wmSa4TyBZbFG87sgzJK6TW/ebY13HmSdc4AjoCkWzdTJ8cppK7Nb/fA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=CRIpAuxU; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CRIpAuxU"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-5d5846f799dso457727eaf.3
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675094; x=1722279894; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=aGNxvHmkTR/bsMHw5Vr0kOh6lxHjm/NM/yldEGmEh+M=;
        b=CRIpAuxU94lizDjthSfDC04KrYWDnTh3NQP437ukt8BdXNzZ6MADeInCmsalLN6Crj
         peqlA8SHtMhU3m3oZoT5pEzRgMsHJB8WJ4/GV+ZQ9QBueg9SjtB1HxkacE+EsJUkJnbW
         kBpdy4J+wiPOcHbeITuARE+elmlGTIt8B2H+JAUVNFWjo2dprlo7g9K+G7Si2elYIGAU
         issOlxm2Q9O63BZ7nBovTqZOiOrjVHjVFDfsA+lJszl4GQziClv8qTggarT/W0ZEK1rF
         7gnE6aruqJ0gE6Ia1msMXJ84z9QKVIN1pvcNhvy+Ax39PTM9s7L+CW6aFTaVwrTwP/xC
         cy8Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675094; x=1722279894;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=aGNxvHmkTR/bsMHw5Vr0kOh6lxHjm/NM/yldEGmEh+M=;
        b=rePIdOgpwc6KjL4OJ62y1MUduCU/FMhw+TxajW3wSBUa7i6e+Pz8aPio/rFvTMUHg2
         sWVK5XUCT+Msaeq94Jiar1vIxyhjqsPdPdm5I7Dk6ZuXBwlh+Z7SQIPN1/TaiLwMhiFI
         bM9VOFTE7mBDzrvuXdOhaLe8sWaObQnyyVjPnH/+FD56e3207Ky1dUOehsWsDkbtBxKq
         nVnpo1FV0dmPkCzIlOBYccgh6bkIfNpjhbRv/4silosqgRKGTZRCyKvOppBCZ+g+Vyg8
         qk7gBZr6JVUIubZD6KxIDWJjROlljtOnKuAOAVwnTzPXORq2Slu/CkbYvCgODYtGOd5f
         8Oqg==
X-Gm-Message-State: AOJu0Yy6pNAnK1Y6kK3ffyh9yox9BaWdPgkUQikdGPXmotSjSi5frNjN
	Cjqw+TFQ1J4hFqZKEHod4RQ1BAOLz6tPyWEBWgiqy4ZQGv6vjLCiWJNGIQ==
X-Google-Smtp-Source: AGHT+IEfraIw5eXiReCCG/HcqChupPVIRg2GCR42ORTHaYSo/X3U13sV4LmqQYaMgo+im1oo0gEOBg==
X-Received: by 2002:a4a:ee83:0:b0:5c4:5cbc:b1b5 with SMTP id 006d021491bc7-5d564cfc26dmr10377239eaf.0.1721675094554;
        Mon, 22 Jul 2024 12:04:54 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:54 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 12/12] genl: Use l_netlink_message as implementation for l_genl_msg
Date: Mon, 22 Jul 2024 14:04:29 -0500
Message-ID: <20240722190443.43196-12-denkenz@gmail.com>
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

This switches the underlying l_genl_msg implementation to
l_netlink_message.
---
 ell/genl.c | 146 ++++++++++-------------------------------------------
 1 file changed, 28 insertions(+), 118 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index d2c6ea15dfa9..5a8dd371a970 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -19,20 +19,15 @@
 #include "queue.h"
 #include "io.h"
 #include "private.h"
+#include "netlink.h"
 #include "netlink-private.h"
 #include "notifylist.h"
 #include "genl.h"
 
-#define MAX_NESTING_LEVEL 4
 #define GENL_DEBUG(fmt, args...)	\
 	l_util_debug(genl->debug_callback, genl->debug_data, "%s:%i " fmt, \
 			__func__, __LINE__, ## args)
 
-struct nest_info {
-	uint16_t type;
-	uint16_t offset;
-};
-
 struct unicast_watch {
 	struct l_notifylist_entry super;
 	char name[GENL_NAMSIZ];
@@ -89,11 +84,7 @@ struct l_genl_msg {
 	char *error_msg;
 	uint8_t cmd;
 	uint8_t version;
-	void *data;
-	uint32_t size;
-	uint32_t len;
-	struct nest_info nests[MAX_NESTING_LEVEL];
-	uint8_t nesting_level;
+	struct l_netlink_message *nlm;
 };
 
 struct genl_request {
@@ -714,44 +705,6 @@ static bool match_request_hid(const void *a, const void *b)
 	return request->handle_id == id;
 }
 
-static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_t version, uint32_t size)
-{
-	struct l_genl_msg *msg;
-
-	msg = l_new(struct l_genl_msg, 1);
-
-	msg->cmd = cmd;
-	msg->version = version;
-
-	msg->len = NLMSG_HDRLEN + GENL_HDRLEN;
-	msg->size = msg->len + NLMSG_ALIGN(size);
-
-	msg->data = l_realloc(NULL, msg->size);
-	memset(msg->data, 0, msg->size);
-	msg->nesting_level = 0;
-
-	return l_genl_msg_ref(msg);
-}
-
-static bool msg_grow(struct l_genl_msg *msg, uint32_t needed)
-{
-	uint32_t grow_by;
-
-	if (msg->size >= msg->len + needed)
-		return true;
-
-	grow_by = msg->len + needed - msg->size;
-
-	if (grow_by < 32)
-		grow_by = 128;
-
-	msg->data = l_realloc(msg->data, msg->size + grow_by);
-	memset(msg->data + msg->size, 0, grow_by);
-	msg->size += grow_by;
-
-	return true;
-}
-
 static struct l_genl_msg *msg_create(const struct nlmsghdr *nlmsg)
 {
 	struct l_genl_msg *msg;
@@ -771,13 +724,10 @@ static struct l_genl_msg *msg_create(const struct nlmsghdr *nlmsg)
 		goto done;
 	}
 
-	msg->data = l_memdup(nlmsg, nlmsg->nlmsg_len);
+	msg->nlm = netlink_message_from_nlmsg(nlmsg);
 
-	msg->len = nlmsg->nlmsg_len;
-	msg->size = nlmsg->nlmsg_len;
-
-	if (msg->len >= GENL_HDRLEN) {
-		struct genlmsghdr *genlmsg = msg->data + NLMSG_HDRLEN;
+	if (nlmsg->nlmsg_len >= NLMSG_LENGTH(GENL_HDRLEN)) {
+		struct genlmsghdr *genlmsg = msg->nlm->data + NLMSG_HDRLEN;
 
 		msg->cmd = genlmsg->cmd;
 		msg->version = genlmsg->version;
@@ -794,23 +744,23 @@ static const void *msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
 	struct nlmsghdr *nlmsg;
 	struct genlmsghdr *genlmsg;
 
-	nlmsg = msg->data;
+	nlmsg = msg->nlm->data;
 
-	nlmsg->nlmsg_len = msg->len;
 	nlmsg->nlmsg_type = type;
 	nlmsg->nlmsg_flags = flags;
 	nlmsg->nlmsg_seq = seq;
 	nlmsg->nlmsg_pid = pid;
 
-	genlmsg = msg->data + NLMSG_HDRLEN;
+	genlmsg = msg->nlm->data + NLMSG_HDRLEN;
 
 	genlmsg->cmd = msg->cmd;
 	genlmsg->version = msg->version;
+	genlmsg->reserved = 0;
 
 	if (out_size)
-		*out_size = msg->len;
+		*out_size = nlmsg->nlmsg_len;
 
-	return msg->data;
+	return msg->nlm->data;
 }
 
 static void write_watch_destroy(void *user_data)
@@ -842,7 +792,7 @@ static bool can_write_data(struct l_io *io, void *user_data)
 		return false;
 	}
 
-	l_util_hexdump(false, request->msg->data, bytes_written,
+	l_util_hexdump(false, data, bytes_written,
 				genl->debug_callback, genl->debug_data);
 
 	l_queue_push_tail(genl->pending_list, request);
@@ -1472,7 +1422,14 @@ LIB_EXPORT struct l_genl_msg *l_genl_msg_new(uint8_t cmd)
 
 LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t size)
 {
-	return msg_alloc(cmd, 0x00, size);
+	struct l_genl_msg *msg = l_new(struct l_genl_msg, 1);
+
+	msg->cmd = cmd;
+	msg->nlm = l_netlink_message_new_sized(0, 0, size + GENL_HDRLEN);
+	netlink_message_reserve_header(msg->nlm,
+					sizeof(struct genlmsghdr), NULL);
+
+	return l_genl_msg_ref(msg);
 }
 
 LIB_EXPORT struct l_genl_msg *l_genl_msg_new_from_data(const void *data,
@@ -1516,7 +1473,7 @@ LIB_EXPORT void l_genl_msg_unref(struct l_genl_msg *msg)
 		return;
 
 	l_free(msg->error_msg);
-	l_free(msg->data);
+	l_netlink_message_unref(msg->nlm);
 	l_free(msg);
 }
 
@@ -1555,23 +1512,12 @@ LIB_EXPORT const char *l_genl_msg_get_extended_error(struct l_genl_msg *msg)
 LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
 						uint16_t len, const void *data)
 {
-	struct nlattr *nla;
-
 	if (unlikely(!msg))
 		return false;
 
-	if (!msg_grow(msg, NLA_HDRLEN + NLA_ALIGN(len)))
+	if (l_netlink_message_append(msg->nlm, type, data, len) < 0)
 		return false;
 
-	nla = msg->data + msg->len;
-	nla->nla_len = NLA_HDRLEN + len;
-	nla->nla_type = type;
-
-	if (len)
-		memcpy(msg->data + msg->len + NLA_HDRLEN, data, len);
-
-	msg->len += NLA_HDRLEN + NLA_ALIGN(len);
-
 	return true;
 }
 
@@ -1579,32 +1525,12 @@ LIB_EXPORT bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t type,
 					const struct iovec *iov,
 					size_t iov_len)
 {
-	struct nlattr *nla;
-	size_t len = 0;
-	unsigned int i;
-
 	if (unlikely(!msg))
 		return false;
 
-	for (i = 0; i < iov_len; i++)
-		len += iov[i].iov_len;
-
-	if (!msg_grow(msg, NLA_HDRLEN + NLA_ALIGN(len)))
+	if (l_netlink_message_appendv(msg->nlm, type, iov, iov_len) < 0)
 		return false;
 
-	nla = msg->data + msg->len;
-	nla->nla_len = NLA_HDRLEN + len;
-	nla->nla_type = type;
-
-	msg->len += NLA_HDRLEN;
-
-	for (i = 0; i < iov_len; i++, iov++) {
-		memcpy(msg->data + msg->len, iov->iov_base, iov->iov_len);
-		msg->len += iov->iov_len;
-	}
-
-	msg->len += NLA_ALIGN(len) - len;
-
 	return true;
 }
 
@@ -1613,37 +1539,20 @@ LIB_EXPORT bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type)
 	if (unlikely(!msg))
 		return false;
 
-	if (unlikely(msg->nesting_level == MAX_NESTING_LEVEL))
-		return false;
-
-	if (!msg_grow(msg, NLA_HDRLEN))
+	if (l_netlink_message_enter_nested(msg->nlm, type) < 0)
 		return false;
 
-	msg->nests[msg->nesting_level].type = type | NLA_F_NESTED;
-	msg->nests[msg->nesting_level].offset = msg->len;
-	msg->nesting_level += 1;
-
-	msg->len += NLA_HDRLEN;
-
 	return true;
 }
 
 LIB_EXPORT bool l_genl_msg_leave_nested(struct l_genl_msg *msg)
 {
-	struct nlattr *nla;
-
 	if (unlikely(!msg))
 		return false;
 
-	if (unlikely(msg->nesting_level == 0))
+	if (l_netlink_message_leave_nested(msg->nlm) < 0)
 		return false;
 
-	nla = msg->data + msg->nests[msg->nesting_level - 1].offset;
-	nla->nla_type = msg->nests[msg->nesting_level - 1].type;
-	nla->nla_len = msg->len - msg->nests[msg->nesting_level - 1].offset;
-
-	msg->nesting_level -= 1;
-
 	return true;
 }
 
@@ -1656,11 +1565,12 @@ LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr *attr,
 	if (unlikely(!attr) || unlikely(!msg))
 		return false;
 
-	if (!msg->data || msg->len < NLMSG_HDRLEN + GENL_HDRLEN)
+	if (!msg->nlm ||
+			msg->nlm->hdr->nlmsg_len < NLMSG_HDRLEN + GENL_HDRLEN)
 		return false;
 
-	nla = msg->data + NLMSG_HDRLEN + GENL_HDRLEN;
-	len = msg->len - NLMSG_HDRLEN - GENL_HDRLEN;
+	nla = msg->nlm->data + NLMSG_HDRLEN + GENL_HDRLEN;
+	len = msg->nlm->hdr->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
 
 	if (!NLA_OK(nla, len))
 		return false;
-- 
2.45.2

