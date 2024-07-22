Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98D2116EC1E
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675094; cv=none; b=FlzWAKOy58+KmjpTXixYOkBnA3ZB0LsDVunBn5s8bOieEQbYmf4xwLmMYhbeODHchJxJC7HVOFelADVKxKxVD0FJCBr4zYw6KYBEs0jwPt/RC+oIxhBXcLIQEAIbX62yJVE85xn6Eu2I2YTS8+NAV2e4oj8vD8qp8TNeZHrEg/s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675094; c=relaxed/simple;
	bh=pP2vi1bgFOJY4S+vn73KcTZhn4Jvg/Q/82otUHpYyoA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WCQcGx5w0qNaATwttUHvA6fC+PSMhJHH/jICVioOmjmq5JnPKm7Gqoj6XD42dJEo4AnRpesk20DZwLs2YFDoLYMl5vW74kRqocfYo5G/YZ/SdGpLpvAuaQ8pRNMPA0Q9hJf7dPQ70+XVCYHVK5RHEbPc85NjQ45qjtaM3jtJrxs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=E9g7CBRJ; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E9g7CBRJ"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-5c7b6c6a581so2108164eaf.0
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675091; x=1722279891; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=uTI90/cK/NxkdJK+sulTQBjvT37WA/2Of7VzJNu9jec=;
        b=E9g7CBRJDiZ4x5C1cniCsToA9c9XHt2faB/wP1mR3paKzP9qh1vH4HzjpOwapoZAW6
         5HXlmhz61KcX6hMJ1bB+rzpyL8zoPYcnpK7WBKPiYDPw3lFewIySiSivuDi+VUKP91a5
         /lur1yY/dYrwU/IzOTW6/3Nj48+QoPUfycnvxZ91MfjNV+kNXHt3Rz5cGMWWQfEiifcQ
         ERfJ4oFrRBDvj2Ndk+3i3VkdgBno5kfvloKZGZbvxhOXNXBT3U6crN12EHnCTbBN/QfE
         xHEhxTl+bVDGE2D/nnyUtZdoHLw/RcKNcGuxnJOC+MMvq3+0z4vdYyt788xVHh5whe/J
         Yv1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675091; x=1722279891;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=uTI90/cK/NxkdJK+sulTQBjvT37WA/2Of7VzJNu9jec=;
        b=YkRqb+3ALlNexaI/pOrfsfy5Wg9GVdcrkGypzDBrhaXOp/28+D6kNI5fbTy1IEsqEu
         ZJjalTr08BWphA/xeHdd+wonDLl707iM5PtZQ3xWxQ0Bwu4FnXenCoLsY54Uwz7UiIy0
         N902Tdw6XampN9aGCJ4PbHOkP5fgxHW/e2cCgqbTf7fAx8mMHU/8k/IiA/FBoNnZ+cyW
         naNp7n5mWB+SJ6hH9ASErYYvlsIgFBihHcfsmU4zzM4cGOlXnA46u4oKwrsRepgKAePK
         Cs5Tt78gWvAPc7wnzWShYZDVhSGnjron3pi6H4e49IpN4fg4ArcUel3eg3NB7XxDkEvW
         xvWg==
X-Gm-Message-State: AOJu0YzUIwiLdjcNFTB95jUTUKmw2twAIXC+J6KlKf6CR45qIB9IMxNK
	BaAN20p4ejFtOOPTgRXXIjIDkyZCZkTqBO6l+UG/2s+Mak14vTQErBtyOQ==
X-Google-Smtp-Source: AGHT+IFCRzFBZZAGXFa82Mp6t989FmD4c8oXUBpgapfPKI4DftSZhwQIbRBfje2ydC4GIASNJlQu+A==
X-Received: by 2002:a05:6820:1e07:b0:5c6:9320:2df6 with SMTP id 006d021491bc7-5d58b866f09mr1149744eaf.7.1721675091397;
        Mon, 22 Jul 2024 12:04:51 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:51 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 08/12] netlink: Support adding nested attributes to messages
Date: Mon, 22 Jul 2024 14:04:25 -0500
Message-ID: <20240722190443.43196-8-denkenz@gmail.com>
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

---
 ell/ell.sym           |  2 ++
 ell/netlink-private.h |  2 ++
 ell/netlink.c         | 54 +++++++++++++++++++++++++++++++++++++++++++
 ell/netlink.h         |  3 +++
 4 files changed, 61 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index b99b6e552eaa..0dad73f5546e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -441,6 +441,8 @@ global:
 	l_netlink_message_append;
 	l_netlink_message_appendv;
 	l_netlink_message_add_header;
+	l_netlink_message_enter_nested;
+	l_netlink_message_leave_nested;
 	/* path */
 	l_basename;
 	l_path_find;
diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index d04af749b9fb..db4317786a8f 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -38,6 +38,8 @@ struct l_netlink_message {
 		struct nlmsghdr *hdr;
 		void *data;
 	};
+	uint32_t nest_offset[4];
+	uint8_t nest_level;
 };
 
 bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
diff --git a/ell/netlink.c b/ell/netlink.c
index d7294a95f20d..f73b876b4ef0 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -727,6 +727,15 @@ static int add_attribute(struct l_netlink_message *message,
 {
 	struct nlattr *attr = message_tail(message);
 	int offset = message->hdr->nlmsg_len;
+	int i;
+
+	for (i = 0; i < message->nest_level; i++) {
+		uint32_t nested_len = offset + NLA_HDRLEN + NLA_ALIGN(len) -
+					message->nest_offset[i];
+
+		if (nested_len > USHRT_MAX)
+			return -ERANGE;
+	}
 
 	attr->nla_type = type;
 	attr->nla_len = NLA_HDRLEN + len;
@@ -895,3 +904,48 @@ LIB_EXPORT int l_netlink_message_add_header(struct l_netlink_message *message,
 	memcpy(dest, header, len);
 	return 0;
 }
+
+LIB_EXPORT int l_netlink_message_enter_nested(struct l_netlink_message *message,
+						uint16_t type)
+{
+	int r;
+
+	if (unlikely(!message))
+		return -EINVAL;
+
+	if (unlikely(message->nest_level == L_ARRAY_SIZE(message->nest_offset)))
+		return -EOVERFLOW;
+
+	r = message_grow(message, NLA_HDRLEN);
+	if (r < 0)
+		return r;
+
+	r = add_attribute(message, type | NLA_F_NESTED, 0, NULL);
+	if (r < 0)
+		return false;
+
+	message->nest_offset[message->nest_level] = r;
+	message->nest_level += 1;
+
+	return 0;
+}
+
+LIB_EXPORT int l_netlink_message_leave_nested(struct l_netlink_message *message)
+{
+	struct nlattr *nla;
+	uint32_t offset;
+
+	if (unlikely(!message))
+		return -EINVAL;
+
+	if (unlikely(message->nest_level == 0))
+		return -EOVERFLOW;
+
+	message->nest_level -= 1;
+	offset = message->nest_offset[message->nest_level];
+
+	nla = message->data + offset;
+	nla->nla_len = message->hdr->nlmsg_len - offset;
+
+	return 0;
+}
diff --git a/ell/netlink.h b/ell/netlink.h
index 4d1c4761b3bb..593cddf1aee8 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -58,6 +58,9 @@ int l_netlink_message_appendv(struct l_netlink_message *message,
 					const struct iovec *iov, size_t iov_len);
 int l_netlink_message_add_header(struct l_netlink_message *message,
 					const void *header, size_t len);
+int l_netlink_message_enter_nested(struct l_netlink_message *message,
+					uint16_t type);
+int l_netlink_message_leave_nested(struct l_netlink_message *message);
 
 #ifdef __cplusplus
 }
-- 
2.45.2

