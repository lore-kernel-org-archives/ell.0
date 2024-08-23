Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F21318BC31
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429757; cv=none; b=m/vngT2qDoksqFUasJEj7DYM+hldZV71e689gVFGp1KeiPBQ/9sUuGNf2T/ct16NjJWTRtq2j0uMMrjR2vNzf7fTZaGRU7DleCPRImDsWSASkZW+iAaeZyU9D3LEF2tzArHCbsB445Jz8SYAnM5aMZey/Or0ku3WUULnoi1vWpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429757; c=relaxed/simple;
	bh=ZjMp0u2393LT8iz7OfixDBw9ywdR2DKD5lV/UO2ij3o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uqb0doYQadzZH6yXCNaYWFOW+rgETG1BtTOxbic3wgRdHVrRUlH7dJSH46OZUilFN4pxsZ/osUpmxKfEt26sZ95GGoKOUNzNJKtZuMs8XgzeXDte2y81V/7zRooncz4e95igVCXXrQ6wo6uy032ZmOEQPNGw1pLbTnnMQr8ffhk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=aVAUyE/u; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aVAUyE/u"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-5d5eec95a74so1485451eaf.1
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429755; x=1725034555; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=htVfznG7fepxsS7pzxoMJVB2hZnfsGO89YO7ZE1YQxI=;
        b=aVAUyE/u2LNRkw/VnaQ1EAmmEGCG8Pw9Uqw/ueTGzP8gus5iRCsJI497R26zlDqoFY
         AGAJczFvVLclH41O8SIuOndYeXX+uIY1I9MI5nlPraAoWmmY4zK2M9ZF/7xPr0usZtrZ
         SaJONrfaXRx6pR5drVSvsJfvMPvbnKtuilgSuS7ofdXAFjX14Y6FKw5YzB7/nvgN6vaL
         6JjQGNi7okYgen9DDThexNLaAK1qUeGKjnDtyeLW20nHMXh8akZgT28u08kEQ2ebYnr4
         dihN0PcB9DZBHYUiAereaOSuGjaZs10vaJnYfZOEPQjRTBkIRATGKnhL9jK1K96TgCM7
         F29g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429755; x=1725034555;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=htVfznG7fepxsS7pzxoMJVB2hZnfsGO89YO7ZE1YQxI=;
        b=eamv+/LqJ1O2syXBDhP455/guiOCGM3oIUOVtHTrUVej+/aomUxSKp6yUuqNDIZ4Xh
         4hvkIO1PjRO10tMJ+/eaG4H++L7TVDVkc5Ar0CRGSeYN8+fpgZgvau8MW9ZMX8qJj34c
         1S5nPNhAooB0CStmGExNqWUewJOfRpuaePkW3I9DGKYp1toFVEUGFxIX6EK3IYb7K3h4
         hjPsqLINa7L6TvinGsALtxaMga9/ODnSgsCD0yDLDfPBOWVzyYJSLrlCHDCKaajQ5+4M
         VgpPwWz4Y0kE97Nrh7VKsi6rbEBFlDUZXW6sY3Z94wsIHCOuU8WbbWYcv7xD09u3Yrwl
         g1Uw==
X-Gm-Message-State: AOJu0YxygtzqjscGLaN5GHxYPpfuo/drBO/fUcmxc3kL5n0W/IBZzS5y
	6PlsJhhZHgW+ARuUpDx7+qwqag5h80/vKL/+amn5T52fAK4kLqKqez3eOQ==
X-Google-Smtp-Source: AGHT+IFi2WKKnsx/uL2USm2JzS46vwk6WwZuFQ+oN/NSXDh2NQCc35XMotR9vBLLswnvOSRUCoDZ2Q==
X-Received: by 2002:a05:6820:451:b0:5dc:cdf8:21c8 with SMTP id 006d021491bc7-5dccdf8229dmr1370347eaf.4.1724429755241;
        Fri, 23 Aug 2024 09:15:55 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:55 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/6] netlink: Add l_netlink_iter
Date: Fri, 23 Aug 2024 11:15:45 -0500
Message-ID: <20240823161553.479576-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Move netlink attribute iterator out of genl.c and into netlink.c.  Both
genl and netlink use the same attribute structure, and is applicable to
both.  This makes implementing netlink and rtnl message parsers much
easier.

In order to keep source compatibility, structure the netlink iterator in
the same way as the genl iterator.  In the future, the use of genl
iterators will be removed.
---
 ell/ell.sym   |  5 ++--
 ell/genl.c    | 76 +++------------------------------------------------
 ell/genl.h    | 18 +++++++++---
 ell/netlink.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/netlink.h | 15 ++++++++++
 5 files changed, 111 insertions(+), 78 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index c5d1c2a9edea..1499081cb25e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -344,8 +344,6 @@ global:
 	l_genl_msg_enter_nested;
 	l_genl_msg_leave_nested;
 	l_genl_attr_init;
-	l_genl_attr_next;
-	l_genl_attr_recurse;
 	l_genl_family_info_can_send;
 	l_genl_family_info_can_dump;
 	l_genl_family_info_has_group;
@@ -445,6 +443,9 @@ global:
 	l_netlink_message_add_header;
 	l_netlink_message_enter_nested;
 	l_netlink_message_leave_nested;
+	l_netlink_attr_init;
+	l_netlink_attr_next;
+	l_netlink_attr_recurse;
 	/* path */
 	l_basename;
 	l_path_find;
diff --git a/ell/genl.c b/ell/genl.c
index 5a8dd371a970..ac10cbf07ef0 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1559,80 +1559,12 @@ LIB_EXPORT bool l_genl_msg_leave_nested(struct l_genl_msg *msg)
 LIB_EXPORT bool l_genl_attr_init(struct l_genl_attr *attr,
 						struct l_genl_msg *msg)
 {
-	const struct nlattr *nla;
-	uint32_t len;
-
-	if (unlikely(!attr) || unlikely(!msg))
-		return false;
-
-	if (!msg->nlm ||
-			msg->nlm->hdr->nlmsg_len < NLMSG_HDRLEN + GENL_HDRLEN)
-		return false;
-
-	nla = msg->nlm->data + NLMSG_HDRLEN + GENL_HDRLEN;
-	len = msg->nlm->hdr->nlmsg_len - NLMSG_HDRLEN - GENL_HDRLEN;
-
-	if (!NLA_OK(nla, len))
-		return false;
-
-	attr->data = NULL;
-	attr->len = 0;
-	attr->next_data = nla;
-	attr->next_len = len;
-
-	return true;
-}
-
-LIB_EXPORT bool l_genl_attr_next(struct l_genl_attr *attr,
-						uint16_t *type,
-						uint16_t *len,
-						const void **data)
-{
-	const struct nlattr *nla;
-
-	if (unlikely(!attr))
-		return false;
-
-	nla = attr->next_data;
-
-	if (!NLA_OK(nla, attr->next_len))
+	if (unlikely(!msg) || unlikely(!msg->nlm))
 		return false;
 
-	if (type)
-		*type = nla->nla_type & NLA_TYPE_MASK;
-
-	if (len)
-		*len = NLA_PAYLOAD(nla);
-
-	if (data)
-		*data = NLA_DATA(nla);
-
-	attr->data = attr->next_data;
-	attr->len = attr->next_len;
-
-	attr->next_data = NLA_NEXT(nla, attr->next_len);
-
-	return true;
-}
-
-LIB_EXPORT bool l_genl_attr_recurse(const struct l_genl_attr *attr,
-						struct l_genl_attr *nested)
-{
-	const struct nlattr *nla;
-
-	if (unlikely(!attr) || unlikely(!nested))
-		return false;
-
-	nla = attr->data;
-	if (!nla)
-		return false;
-
-	nested->data = NULL;
-	nested->len = 0;
-	nested->next_data = NLA_DATA(nla);
-	nested->next_len = NLA_PAYLOAD(nla);
-
-	return true;
+	return l_netlink_attr_init((struct l_netlink_attr *) attr,
+				NLMSG_HDRLEN + GENL_HDRLEN,
+				msg->nlm->data, msg->nlm->hdr->nlmsg_len) == 0;
 }
 
 /**
diff --git a/ell/genl.h b/ell/genl.h
index 3f38fd9d5710..ed5f17c4fd2e 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -91,10 +91,20 @@ bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
 bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 
 bool l_genl_attr_init(struct l_genl_attr *attr, struct l_genl_msg *msg);
-bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
-					uint16_t *len, const void **data);
-bool l_genl_attr_recurse(const struct l_genl_attr *attr,
-				struct l_genl_attr *nested);
+
+static inline bool l_genl_attr_next(struct l_genl_attr *attr, uint16_t *type,
+					uint16_t *len, const void **data)
+{
+	return l_netlink_attr_next((struct l_netlink_attr *) attr,
+					type, len, data) == 0;
+}
+
+static inline bool l_genl_attr_recurse(const struct l_genl_attr *attr,
+				struct l_genl_attr *nested)
+{
+	return l_netlink_attr_recurse((struct l_netlink_attr *) attr,
+					(struct l_netlink_attr *) nested) == 0;
+}
 
 bool l_genl_family_info_has_group(const struct l_genl_family_info *info,
 					const char *group);
diff --git a/ell/netlink.c b/ell/netlink.c
index 121a322fccf5..0be3009c736f 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -944,3 +944,78 @@ LIB_EXPORT int l_netlink_message_leave_nested(struct l_netlink_message *message)
 
 	return 0;
 }
+
+LIB_EXPORT int l_netlink_attr_init(struct l_netlink_attr *iter,
+					size_t header_len,
+					const void *data, uint32_t len)
+{
+	const struct nlattr *nla;
+
+	if (unlikely(!iter) || unlikely(!data))
+		return -EINVAL;
+
+	if (len < NLA_ALIGN(header_len))
+		return -EMSGSIZE;
+
+	nla = data + NLA_ALIGN(header_len);
+	len -= NLA_ALIGN(header_len);
+
+	if (!NLA_OK(nla, len))
+		return -EMSGSIZE;
+
+	iter->data = NULL;
+	iter->len = 0;
+	iter->next_data = nla;
+	iter->next_len = len;
+
+	return 0;
+}
+
+LIB_EXPORT int l_netlink_attr_next(struct l_netlink_attr *iter,
+					uint16_t *type, uint16_t *len,
+					const void **data)
+{
+	const struct nlattr *nla;
+
+	if (unlikely(!iter))
+		return -EINVAL;
+
+	nla = iter->next_data;
+	if (!NLA_OK(nla, iter->next_len))
+		return -EMSGSIZE;
+
+	if (type)
+		*type = nla->nla_type & NLA_TYPE_MASK;
+
+	if (len)
+		*len = NLA_PAYLOAD(nla);
+
+	if (data)
+		*data = NLA_DATA(nla);
+
+	iter->data = iter->next_data;
+	iter->len = iter->next_len;
+
+	iter->next_data = NLA_NEXT(nla, iter->next_len);
+	return 0;
+}
+
+LIB_EXPORT int l_netlink_attr_recurse(const struct l_netlink_attr *iter,
+					struct l_netlink_attr *nested)
+{
+	const struct nlattr *nla;
+
+	if (unlikely(!iter) || unlikely(!nested))
+		return -EINVAL;
+
+	nla = iter->data;
+	if (!nla)
+		return false;
+
+	nested->data = NULL;
+	nested->len = 0;
+	nested->next_data = NLA_DATA(nla);
+	nested->next_len = NLA_PAYLOAD(nla);
+
+	return 0;
+}
diff --git a/ell/netlink.h b/ell/netlink.h
index 08aff74fbac2..f09d42043675 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -119,6 +119,21 @@ static inline int l_netlink_message_append_mac(struct l_netlink_message *message
 	return l_netlink_message_append(message, type, mac, 6);
 }
 
+struct l_netlink_attr {
+	const struct nlattr *data;
+	uint32_t len;
+	const struct nlattr *next_data;
+	uint32_t next_len;
+};
+
+int l_netlink_attr_init(struct l_netlink_attr *attr, size_t header_len,
+					const void *data, uint32_t len);
+int l_netlink_attr_next(struct l_netlink_attr *attr,
+					uint16_t *type, uint16_t *len,
+					const void **data);
+int l_netlink_attr_recurse(const struct l_netlink_attr *iter,
+					struct l_netlink_attr *nested);
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.2

