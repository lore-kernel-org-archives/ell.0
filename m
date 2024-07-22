Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 297152032A
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675095; cv=none; b=FwFPC0d52xpp56Q8TWldxWJ4hI9H5u40xT3VsCjPrJ5pYs3BMeDT8Caou3rxvuF98llKhqza3/YJwix6GwnBLAwnRqZDhR2GSKs4+wVsV3jsioOJHgR4PXIT6P2LeQiYO/SqVueGBg43cYXgAf1Wl0aV1xiIb73hk1rnEErJGaI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675095; c=relaxed/simple;
	bh=85kKHV44JaXoI4q7w84xKPeWEE/wt9uU8oEgxhgYL2I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HiZ1OWZurrDnvDC9oHxzMExNpQhmvZJHJLoOMB8L8Qrf9gbxAOgKpGqiE8iH4zFTT1pdJp5bJPuKPvLH9AROALROiObmw3G3Qd3jyxV3ruHBucPxnRj8jKfpMkY4yGVTwsKo3JvNEfr7fkkbMyepONMcqvwKgQzDlA9xkY/v4is=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NdLy/yxG; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NdLy/yxG"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-5d569902626so1171069eaf.2
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675093; x=1722279893; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=DyyfFvvgXQKHvzqcKXjAA0jfXa5GRyrMHP/lNXZeszY=;
        b=NdLy/yxGyWW7JI0UqK8C2bOSUEmo7khOgmOYvy88NSKr5HZOelYNZCZPwKIgiagF3n
         cdm/MfxqGM5LGqd1iyp7Vl25Iq5QqonVx/3vG5vl/7iD9ODaQBoiLQ/im5EIIRUNbODa
         aOQdGlYUuY3M/nzvN+TYGdQfJxIM68HZn/5WuZnh2E5F8BF7LsUYoRR2Cra8+5RW3hcR
         JGV7YVZfl88eh/N9FgrzTerSKpAL9DaUBc/zXNZlhdiGRhSc7k5J+BOqPQsCMKqpzmI2
         HjXbvqp2BbLb6Jd4CJthB/PLmThN5/S8Ah6fr8Ltoaq9CVoGjbIOMWN2UUnHvnX2OhMI
         ZZNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675093; x=1722279893;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=DyyfFvvgXQKHvzqcKXjAA0jfXa5GRyrMHP/lNXZeszY=;
        b=kYQ9J3hQVJi+99X9G6ZYqJxvEm3Ezl5yt6nAhdaKAZSh2gc2N2s3v+mVfZtbRjSrWy
         UK9LhkKoRVUzs4N0mqpZ8lu2xarTsQvc7OpU9ndY7DTIFLHuh6KLvi4DlvBKtRExh8se
         gdzyGTpfMSt1eO4OSUZ7RKB8GBat+UGsgEF6Di2l4x3njdX7tk7WJ6izqhyZdLUHxjYR
         Qlyqx0UlyJmyC+KfRTsgCSmUyFUn6CLxVV3RvwEY+As3y1KxIkaQu1V1GxgfhSFnfT1J
         2A+l7DCcbcH4JgSfpmSvOYMKdVRGakGUZ4LG3yp73ErITeKpsZZ7wDtR/d6QKNmpzfff
         4M4Q==
X-Gm-Message-State: AOJu0Yxr74vnRdSRbKKGGMVLOm1SpBQUtKjE8Xl8EpoJopeHCkXpcGuZ
	nyBYzWbBlCK5t3esrk057pXQ51x17vbPXusBLqs8emgH8JqVIR32TAxEYw==
X-Google-Smtp-Source: AGHT+IEB3rbfpOIiXNYvbRaM7anY7INGakDnbPgZ7SiTZs/hG3Iscx4dJ6wvWbCxMO6urUlAYt7qzg==
X-Received: by 2002:a05:6820:1e01:b0:5c4:2497:c92d with SMTP id 006d021491bc7-5d564e497femr10406308eaf.2.1721675093128;
        Mon, 22 Jul 2024 12:04:53 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:52 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 10/12] unit: Add netlink message builder / parser tests
Date: Mon, 22 Jul 2024 14:04:27 -0500
Message-ID: <20240722190443.43196-10-denkenz@gmail.com>
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

These tests are similar to l_genl_msg based tests, but use
l_netlink_message APIs directly.
---
 unit/test-genl-msg.c | 74 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index e6432f4362ef..3d996f4e242a 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -14,6 +14,8 @@
 #include <linux/genetlink.h>
 #include <ell/ell.h>
 
+#include "ell/netlink-private.h"
+
 static bool do_print = false;
 
 static void do_debug(const char *str, void *user_data)
@@ -126,6 +128,38 @@ static void build_set_station(const void *data)
 	l_genl_msg_unref(msg);
 }
 
+static void build_set_station_netlink(const void *data)
+{
+	const struct set_station_test *test = data;
+	struct l_netlink_message *m;
+	struct genlmsghdr genlhdr = { .cmd = 18, .version = 0, .reserved = 0 };
+
+	m = l_netlink_message_new(0x17, NLM_F_REQUEST | NLM_F_ACK);
+	assert(m);
+
+	assert(!l_netlink_message_add_header(m, &genlhdr, sizeof(genlhdr)));
+	assert(!l_netlink_message_append_u32(m, 3, test->ifindex));
+	assert(!l_netlink_message_append_mac(m, 6, test->mac));
+	assert(!l_netlink_message_append(m, 67,
+					test->flags, sizeof(test->flags)));
+
+	m->hdr->nlmsg_seq = test->seq;
+	m->hdr->nlmsg_pid = test->pid;
+
+	if (do_print) {
+		l_util_hexdump(false, m->data, m->hdr->nlmsg_len,
+					do_debug, "[MSG] ");
+		l_util_hexdump(true, set_station_request,
+				sizeof(set_station_request), do_debug, "[MSG] ");
+	}
+
+	assert(m->hdr->nlmsg_len == sizeof(set_station_request));
+	assert(!memcmp(m->data, set_station_request,
+					sizeof(set_station_request)));
+
+	l_netlink_message_unref(m);
+}
+
 static const unsigned char set_rekey_offload_request[] = {
 	0x54, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x05, 0x00, 0x59, 0xa3, 0xe1, 0x53,
 	0xba, 0x02, 0x40, 0xe7, 0x4f, 0x00, 0x00, 0x00, 0x08, 0x00, 0x03, 0x00,
@@ -252,6 +286,42 @@ static void build_set_rekey_offload(const void *data)
 	l_genl_msg_unref(msg);
 }
 
+static void build_set_rekey_offload_netlink(const void *data)
+{
+	const struct set_rekey_offload_test *test = data;
+	struct l_netlink_message *m;
+	struct genlmsghdr genlhdr = { .cmd = 79, .version = 0, .reserved = 0 };
+
+	m = l_netlink_message_new(0x1b, NLM_F_REQUEST | NLM_F_ACK);
+	assert(m);
+
+	assert(!l_netlink_message_add_header(m, &genlhdr, sizeof(genlhdr)));
+	assert(!l_netlink_message_append_u32(m, 3, test->ifindex));
+	assert(!l_netlink_message_enter_nested(m, 122));
+	assert(!l_netlink_message_append(m, 1, test->kek, sizeof(test->kek)));
+	assert(!l_netlink_message_append(m, 2, test->kck, sizeof(test->kck)));
+	assert(!l_netlink_message_append(m, 3, test->replay_counter,
+						sizeof(test->replay_counter)));
+	assert(!l_netlink_message_leave_nested(m));
+
+	m->hdr->nlmsg_seq = test->seq;
+	m->hdr->nlmsg_pid = test->pid;
+
+	if (do_print) {
+		l_util_hexdump(false, m->data, m->hdr->nlmsg_len,
+					do_debug, "[MSG] ");
+		l_util_hexdump(true, set_rekey_offload_request,
+				sizeof(set_rekey_offload_request),
+				do_debug, "[MSG] ");
+	}
+
+	assert(m->hdr->nlmsg_len == sizeof(set_rekey_offload_request));
+	assert(!memcmp(m->data, set_rekey_offload_request,
+					sizeof(set_rekey_offload_request)));
+
+	l_netlink_message_unref(m);
+}
+
 /*
  * This example is generated by libnl:
 	msg = nlmsg_alloc();
@@ -441,8 +511,12 @@ int main(int argc, char *argv[])
 				parse_set_rekey_offload, &rekey_offload);
 
 	l_test_add("Build Set Station Request", build_set_station, &set_station);
+	l_test_add("Build Set Station Request (Netlink)",
+			build_set_station_netlink, &set_station);
 	l_test_add("Build Set Rekey Offload Request",
 				build_set_rekey_offload, &rekey_offload);
+	l_test_add("Build Set Rekey Offload Request (Netlink)",
+			build_set_rekey_offload_netlink, &rekey_offload);
 
 	l_test_add("libnl-generated Example with Nesting",
 				parse_libnl_nested, NULL);
-- 
2.45.2

