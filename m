Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7F7F18637
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675096; cv=none; b=n4RIFt5a8c6159nZRApVPGvY6zNrAgPihUuddVvEXhx+Hoj0fwVpN0xR0roDlhX9QZ0pwP+Oa9cQsU8ZUpq8gLfVf7QoE0E2MPpcS0KPHr0ikvoNvPbN71x7NVMAohZ0eGZkFLz6xzO71Bvt6OPBhMrad2h1/CC4AJwzf1HP+cQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675096; c=relaxed/simple;
	bh=Hn1CNurE9BtxPUuHaG8+6p0mH5LbXv5yJ2AEzO1LVA4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XwdoXCZfBYjsGp6JDFNA03QzwslhTkzh+P0sSCcMAURI4r7tNsD3AvHg6fc+73BYnoJqyLXxmrvlAJQTaw5JuNRwpBxAmgPiNg6UPKjNQcAJCP/S4t8N/LjVpq8O4bJOTmurIEzwvNHl4tJBl/5o55kfDgMzGFm0VQc6cthY0fI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=RKz+LFp8; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RKz+LFp8"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-5d569bee00aso1248059eaf.1
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675094; x=1722279894; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=FnIA1vupo76R42JBHhMrMF2WBhjdzyZwSHusD5SML1s=;
        b=RKz+LFp8V1oxuE+2eJr2JNfJQlSoXFHYwuK6uLrXb1nLcsOrPe53I2ob3KlmHg3+id
         Hta0Xtm2spOkLOmx2u7MIj3SkPd1Vz0qsw6DmOt/YsrzclQ/WYE5cY1VfgVO6yjZ7YuU
         AYqrgeHRXENMJN2xqwelcINJBWKFpsE3P+xhi9bGnTgloVzDcuak7Pru76jBswHANROf
         IZwrh3s80h0nJRPE7ylPhrUHBWRK6e3Lk3CqXMS1gT85sI3D1RcFHFgkxNDUKfIUOY5e
         WWg928wk/CNz5PTXafgv6HcH/pjHnlte1wVfAR8JiC+6HuryZ2GtCTgxxdOeMmZBgdyI
         LeKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675094; x=1722279894;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=FnIA1vupo76R42JBHhMrMF2WBhjdzyZwSHusD5SML1s=;
        b=fYpxopgtCK2CCGvph6SeGIkiqY9zLjWwokckQK0p/8PMHtw5s8kIJZi4BuLQPWf5Ft
         3SAxtTgBzL2/eWLS61yiJ3sNi248u7CoI2NwbCF1jnlyLmOE+ha7xuD/RXA6mj5zxwst
         yo84Kg/gjkh+gdCFwktyFlpEA41wqQDiEEKLSjdPMrxLy1tJGUEHtWWbNirRptROatrO
         DFppC7rR9iVofWW9Sa0j7cbYoG19GrDYlnSRbyXjqOkLQ8Ag4O7+Bn/5DEFtcZzkH1ps
         Rwo0ZIy3OUC+AMTWsGdOPfdIHJDDnxATUApM7cOtk7DO1e+qL8SSYFfRJvRars3uCvNP
         wkHA==
X-Gm-Message-State: AOJu0YwuG4S0LH35I7F2H+F8ClbOu6OoSHtIWSpr5u8QcmtvbgOJ8xWH
	Ks7Zl6sNoX38/zz4ZVbncf/x6b/q//iitrsZloG+HW0ITbq9XqGqfMIYiw==
X-Google-Smtp-Source: AGHT+IFFYPy3iU9vq/j0ZslcpOwZdI4eUfUgE3Nh2mYjfh2apz8UgpnchHwdj/CyD82EkTbA7ggBpw==
X-Received: by 2002:a05:6820:210c:b0:5c7:b679:4503 with SMTP id 006d021491bc7-5d564cfc023mr11127482eaf.0.1721675093791;
        Mon, 22 Jul 2024 12:04:53 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:53 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 11/12] netlink: add netlink_message_from_nlmsg
Date: Mon, 22 Jul 2024 14:04:28 -0500
Message-ID: <20240722190443.43196-11-denkenz@gmail.com>
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

This is a low level utility to create a l_netlink_message from raw data
represented by struct nlmsghdr.  Typically used on the RX path when
reading from the socket, or by unit tests.
---
 ell/netlink-private.h |  2 ++
 ell/netlink.c         | 11 +++++++++++
 2 files changed, 13 insertions(+)

diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index db4317786a8f..b114f62f6bf3 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -47,3 +47,5 @@ bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
 					uint32_t *out_error_offset);
 int netlink_message_reserve_header(struct l_netlink_message *message,
 					size_t header_len, void **out_header);
+struct l_netlink_message *netlink_message_from_nlmsg(
+						const struct nlmsghdr *nlmsg);
diff --git a/ell/netlink.c b/ell/netlink.c
index f73b876b4ef0..024740b62fc3 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -781,6 +781,17 @@ LIB_EXPORT struct l_netlink_message *l_netlink_message_new(uint16_t type,
 	return l_netlink_message_new_sized(type, flags, 256 - NLMSG_HDRLEN);
 }
 
+struct l_netlink_message *netlink_message_from_nlmsg(
+						const struct nlmsghdr *nlmsg)
+{
+	struct l_netlink_message *message = l_new(struct l_netlink_message, 1);
+
+	message->hdr = l_memdup(nlmsg, nlmsg->nlmsg_len);
+	message->size = nlmsg->nlmsg_len;
+
+	return l_netlink_message_ref(message);
+}
+
 LIB_EXPORT struct l_netlink_message *l_netlink_message_ref(
 					struct l_netlink_message *message)
 {
-- 
2.45.2

