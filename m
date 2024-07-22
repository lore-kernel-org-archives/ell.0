Received: from mail-oi1-f172.google.com (mail-oi1-f172.google.com [209.85.167.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 464A318637
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675094; cv=none; b=tTw5ukdaq03CfvigAZcpfiu49wEuDWFtl1G42eXbmOs90deF6Xaye4f3V7IFdlDE6oo7PEkbxTcKiTFfu6BeW7dpN/QIbh3q+iFqNAQV7889nusUSIK34cV5PhjV7nOoIB4Ia2VJy9qB+4q7xLjlb7pW04O6H3bNiBEZ72s63JQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675094; c=relaxed/simple;
	bh=mvxvRCkpeY/8mm4UHwjWK1nhilAomrMCnKrpmabG2P8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qM5ZXGal9x9T/IAGsAG5/KYtF9yLKYre4bw426Onf5cJoCgkXL7N43SSWW/sRpOoNBB3jPukbl2E/GryRqG7i9DbnHdXhrhuERsDjCQKA30E3sx5E5MSbFC2qaBcpX2bikjGR5JiU6BHEO0x9R/ERB0PyeoPKHfHo+xd/mExHgw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=j789Svhk; arc=none smtp.client-ip=209.85.167.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j789Svhk"
Received: by mail-oi1-f172.google.com with SMTP id 5614622812f47-3daf0e73a59so801034b6e.1
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675092; x=1722279892; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=vdx1MTQkyWlY4DSqjiy9jL2ROlqXPrp4F3hAgRBBBPw=;
        b=j789SvhkAIyp/0e8fICqSuza3Mcw4gzeQkX1lSuGOsdDQv7QxXV1jvT8Bybs9m0ATR
         zHdZ42UD2hdo9Y3W/ma8cZADFaL8UrAq8h2QiDurEdIm1cKOFs3weiutduFzX3o4MfWC
         YovzHWemQL/ogTrU6xzqll4chWFv7isWirBb4NuqwJ1tjrXpSVVzORBcqFaN7dBNc7Wp
         a9tZ9ni5l0S7K5tT3FOplyxiCGMI7ZVzh270HYFbQaFKMnRqxrZz0Vy8IpNWsTXfmGo3
         jPYqviIyhWzxSpH+Fhz+1+Vlcx3r0C+GuhWWNEcaQaLx4UQFAQcLJlhnfqBM5UUDFXzb
         725A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675092; x=1722279892;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=vdx1MTQkyWlY4DSqjiy9jL2ROlqXPrp4F3hAgRBBBPw=;
        b=EO29lj4kh1gL4KfP8ldzsb3ueF7sy9lTI2DEwaIr7cqmrbT4bREJuNd8F/M2LPyo9Y
         K1uhQBPSYKpnTX4AEpLOxjf4i9LBLEoMRP7/ysm+02/lHSG0VH6MdkVGZGTyyVVsJl+0
         p/NlQqUiDYinJvtsckndO4wGtzYqDi5qh7MFtbQJ2p3AoXKcbkEKU3HoyCAraYauJxW4
         P8IEOa5jQNekzMFNZEgOSBq83AX3Frtpdn2UymAi9BdTu1ETvLHmVzFq2LBimuzm9IOA
         uEOs9sI457sQuNPB7UGFJ+Xs7FoWD6XbSXLKklRUzQFu1svW8UjAnQrHTVJyM/p9WT4w
         m74A==
X-Gm-Message-State: AOJu0YzNaK48HEqyzaK0WJFQjlDWqxxLJnN4v66JTozTprZC9XHaKC6p
	UTXweHCTLQHxo25YhbFWCTr/Zj8PwYRfjTIk7znKbRJ/fcsPFnN5UhQOeg==
X-Google-Smtp-Source: AGHT+IE8n175O0mq8MjSFisIHLJzOwwIGkgg/G9Wl2mlGcO+kgDI2llf9QN4a1u3zkVYAcA+9QQtpQ==
X-Received: by 2002:a05:6808:2387:b0:3d9:2104:47e6 with SMTP id 5614622812f47-3dad73dc129mr7565684b6e.13.1721675092352;
        Mon, 22 Jul 2024 12:04:52 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:52 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 09/12] netlink: Add additional helpers
Date: Mon, 22 Jul 2024 14:04:26 -0500
Message-ID: <20240722190443.43196-9-denkenz@gmail.com>
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

Helpers around l_netlink_message_append for use with common data types.
---
 ell/netlink.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/ell/netlink.h b/ell/netlink.h
index 593cddf1aee8..e7962b9932dc 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -62,6 +62,61 @@ int l_netlink_message_enter_nested(struct l_netlink_message *message,
 					uint16_t type);
 int l_netlink_message_leave_nested(struct l_netlink_message *message);
 
+static inline int l_netlink_message_append_u8(struct l_netlink_message *message,
+						uint16_t type, uint8_t u8)
+{
+	return l_netlink_message_append(message, type, &u8, sizeof(uint8_t));
+}
+
+static inline int l_netlink_message_append_u16(struct l_netlink_message *message,
+						uint16_t type, uint16_t u16)
+{
+	return l_netlink_message_append(message, type, &u16, sizeof(uint16_t));
+}
+
+static inline int l_netlink_message_append_u32(struct l_netlink_message *message,
+						uint16_t type, uint32_t u32)
+{
+	return l_netlink_message_append(message, type, &u32, sizeof(uint32_t));
+}
+
+static inline int l_netlink_message_append_u64(struct l_netlink_message *message,
+						uint16_t type, uint64_t u64)
+{
+	return l_netlink_message_append(message, type, &u64, sizeof(uint64_t));
+}
+
+static inline int l_netlink_message_append_s8(struct l_netlink_message *message,
+						uint16_t type, int8_t s8)
+{
+	return l_netlink_message_append(message, type, &s8, sizeof(int8_t));
+}
+
+static inline int l_netlink_message_append_s16(struct l_netlink_message *message,
+						uint16_t type, int16_t s16)
+{
+	return l_netlink_message_append(message, type, &s16, sizeof(int16_t));
+}
+
+static inline int l_netlink_message_append_s32(struct l_netlink_message *message,
+						uint16_t type, int32_t s32)
+{
+	return l_netlink_message_append(message, type, &s32, sizeof(int32_t));
+}
+
+static inline int l_netlink_message_append_s64(struct l_netlink_message *message,
+						uint16_t type, int64_t s64)
+{
+	return l_netlink_message_append(message, type, &s64, sizeof(int64_t));
+}
+
+static inline int l_netlink_message_append_mac(struct l_netlink_message *message,
+						uint16_t type,
+						const uint8_t mac[static 6])
+{
+	return l_netlink_message_append(message, type, mac, 6);
+}
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.2

