Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A06931EA84
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010357; cv=none; b=e+HqivvBLcUgvE7NUZwlZmVZ9pc4ji+EmQt9AkkCM1nF8EnZoVGfnYXy58E0ZIcSB0AZusYxfH7IhPxjR5lwnLaspSpd8WpmIeryuAhc9VSCjT5leaKgJUdmjioJ+I9LR7xtYVNQJcljjwP3CGCJE4c6HzQMdqaLxyBPLcZlbh8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010357; c=relaxed/simple;
	bh=SBDuGoPc43t19pnVJbizIlNuze7CMqqCCvxG42npFkA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=awr1GZnBwWR/6oIZXO9XBtKwA1nRFW4Jh+KVdR5dpeQDbXUgsUwhjYKF2F0OfALICkR8d67kCOWdf9eDaSTxGgYNOnxk1LA/oPbk3sZHF8DEUEsTiTCU3X9Dg2R+YxLgnQcazW5x5WdHPqBrOspr4ycAQPiMovBFXlx0wvMWeO0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=I1MUZ9PD; arc=none smtp.client-ip=209.85.210.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I1MUZ9PD"
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-70365f905b6so859274a34.0
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010355; x=1722615155; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=xRsn/rfrdCPG+71aVif4B77Y1y1DwE5fnEWM44sYQnQ=;
        b=I1MUZ9PD2OnVU05Q1vX6Kijkh188ysGCWR0X/h/KxD11rVJ0l5ZVo3PT1Rv0k8hCl8
         y9r0EIYLEyicxsdVa9qQAWgjgk+2B1RPBUJewW9ZRo1ZpV+kBxtegfMFdxTI0uNZ6MAi
         k8U2hgkVHr182gJfx5rsTnjLxGB3rexyeLytv1F4dn77CgSNBnRWH828FW/+hMfBut/k
         v0BPJXP4yURW4ML+YBABKDLryO8BJnBuZIb/nyvFeZwr76UsYuk0B55qDYH9TonF5cY7
         +bOKKu4Nr65sJEXWX6HlBpcumpoJ7eZIoy1meGa+Z3X0+dUV2eoVib8zO6uu95TETbDg
         CBJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010355; x=1722615155;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=xRsn/rfrdCPG+71aVif4B77Y1y1DwE5fnEWM44sYQnQ=;
        b=Z2oPb+X7MV8mhCFhCkcGjLrQ87AkIYzWxYKmHyGt4/UAGWB7c4UYovIZXH1X7jZ0Rz
         Mcus2KCpoYBKbcq/XOy7G/qIdKcc+0qkiJ3N9rwGNv0o9T8vLeMlEjfye2jTvrMdUKLb
         jM/hYrhW6GAmLP5BpRdDabx0KwT9zqYimzjpkjzU2489KxkOyirnjBKrKdQ2Xn9BVgRr
         pIh6GMLHz9k+IsQQRSVb6ITIf+nFjbt13P7tj2GYiYasCqe5K6Zyf6XjgMtQzVOubbMb
         90W+gdqRnlq3PkmUhp6eip8v7YF9reIQUD5it1fgsacK0hAXZtXfdyE3GzOGSVPXfoob
         X15g==
X-Gm-Message-State: AOJu0YygkTVu3kDHdSuOzaevFgcVRusF1Iko/QMz9OdJlHtLz8Fe2B3D
	8RpiIKGZyK7KdssvudTXtwXmSX6HFrMvS/jaqB8NkN6I2RMR7AFnEGtO6A==
X-Google-Smtp-Source: AGHT+IFfKJRleWZr1gkPqe82ndbw0V50xLICj2UugiERY4P+UdilHBva8WoZ9srA8rb1sqFthEXCjw==
X-Received: by 2002:a05:6830:6208:b0:703:6d69:55b0 with SMTP id 46e09a7af769-70940c9e5admr57141a34.31.1722010354649;
        Fri, 26 Jul 2024 09:12:34 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:34 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/7] netlink: Disallow certain flags in message constructor
Date: Fri, 26 Jul 2024 11:12:14 -0500
Message-ID: <20240726161232.146982-2-denkenz@gmail.com>
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

Certain flags are reserved for use by l_netlink when sending messages.
Other flags don't make sense for messages that are to be sent to the
kernel.  Disallow their use.
---
 ell/netlink.c        | 3 +++
 unit/test-genl-msg.c | 6 ++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index 26c31679e4c7..58dfd9779875 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -751,6 +751,9 @@ LIB_EXPORT struct l_netlink_message *l_netlink_message_new_sized(uint16_t type,
 {
 	struct l_netlink_message *message;
 
+	if (flags & 0xff)
+		return NULL;
+
 	message = l_new(struct l_netlink_message, 1);
 
 	message->size = initial_len + NLMSG_HDRLEN;
diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index 3d996f4e242a..d10a87f30e3b 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -134,7 +134,7 @@ static void build_set_station_netlink(const void *data)
 	struct l_netlink_message *m;
 	struct genlmsghdr genlhdr = { .cmd = 18, .version = 0, .reserved = 0 };
 
-	m = l_netlink_message_new(0x17, NLM_F_REQUEST | NLM_F_ACK);
+	m = l_netlink_message_new(0x17, 0);
 	assert(m);
 
 	assert(!l_netlink_message_add_header(m, &genlhdr, sizeof(genlhdr)));
@@ -153,6 +153,7 @@ static void build_set_station_netlink(const void *data)
 				sizeof(set_station_request), do_debug, "[MSG] ");
 	}
 
+	m->hdr->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
 	assert(m->hdr->nlmsg_len == sizeof(set_station_request));
 	assert(!memcmp(m->data, set_station_request,
 					sizeof(set_station_request)));
@@ -292,7 +293,7 @@ static void build_set_rekey_offload_netlink(const void *data)
 	struct l_netlink_message *m;
 	struct genlmsghdr genlhdr = { .cmd = 79, .version = 0, .reserved = 0 };
 
-	m = l_netlink_message_new(0x1b, NLM_F_REQUEST | NLM_F_ACK);
+	m = l_netlink_message_new(0x1b, 0);
 	assert(m);
 
 	assert(!l_netlink_message_add_header(m, &genlhdr, sizeof(genlhdr)));
@@ -315,6 +316,7 @@ static void build_set_rekey_offload_netlink(const void *data)
 				do_debug, "[MSG] ");
 	}
 
+	m->hdr->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
 	assert(m->hdr->nlmsg_len == sizeof(set_rekey_offload_request));
 	assert(!memcmp(m->data, set_rekey_offload_request,
 					sizeof(set_rekey_offload_request)));
-- 
2.45.2

