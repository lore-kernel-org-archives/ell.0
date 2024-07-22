Received: from mail-oo1-f48.google.com (mail-oo1-f48.google.com [209.85.161.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD07B1863F
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675090; cv=none; b=euiZ/PGLQmlRgaefnhHIYtFpT/M7zqGcvgrmORNLVkX8euIwcpGSw/MYmYILSTMBovWg/aBDFoBVN4WekvWEfQv2aSnb6TSvW05BpfAPrViNWTQXBU8YKkyH8qOAuQPvm4p5ZejkinfMd1AkOxqF3uAL2hi+Xm79F4pijRAPyyQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675090; c=relaxed/simple;
	bh=Hy0R84CVcG3Sw49FW9f8blctks4owv6XZ3EAohmXsNw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WJZQW6GrVivhJISOKyADSdED6ekSNQXHvsbR+4ZS35l91+M+XeI3DuY4uDSBFMk62d8oq/oyCvtx1HwPpnEKBrwv+eRGwr2GuvxCo6jEn2N5Dc/XtOZb7iUhzDevjLKESz4r1zJQEzZmkfCJI5FFH7NCy8r44gVFRhIpaRo4az0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=j8Qt8MSS; arc=none smtp.client-ip=209.85.161.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j8Qt8MSS"
Received: by mail-oo1-f48.google.com with SMTP id 006d021491bc7-5c669a0b5d1so2770234eaf.3
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675087; x=1722279887; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Mo0eLWlEhhHrwQmkhuENMv7vw2sYPCeYuxDPg6p8iNQ=;
        b=j8Qt8MSSm7JA03bl5rT1gQPx0hSdBDUwuRRRp8EPJ6xqZGgjVt0Mr1M6UjlM6+AHIk
         pbkQHJFrd+p6J/fF7LYwrRPBJKiG91kpVFBysc2iWTIGV1QoPGRpV3iqvAgO580DMXh4
         B69ltLokGZVWDz/I/Z3lcdvCBCXIr450J2S7oClqzTKQusf6nyqTVB9OIRW9sCIekJnp
         SikvCCjvTllT+rxLCPa+6BxWa+ktup6TObEm5thTopChEV1xN/g5Rlyu748uIyonn5/H
         cAzDRNsfH5rIHE7d1HkIpBT4DZ6yM5DPOEsjwjjMxMDitqhUR3LcJY3B+B1Qc4Lxs+Oe
         ZUXQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675087; x=1722279887;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Mo0eLWlEhhHrwQmkhuENMv7vw2sYPCeYuxDPg6p8iNQ=;
        b=Zk4lB6ttUtCq6XP4O3i6bxE8MPck+QNBpwdgnXrezskTQX4Qus85BX6F8yjkuuULO3
         Tr2alrFeTyps4rbz/fHHQB8Y9pMQ9rrRtpD2x03lo+ZIxV2MIXUlN9NS//EnwvlszJcJ
         IqgozK0aA7OvWVacojsAf+nmDr/IXu8Qf4urXQQZQoiXkqKb+OmGESWBvdQ8bgKgsG22
         2adiVbofvNGGHl2w6+i6h+fmJhB1MPwcRLGdHY+ExQLIK31c5T2Dkvea6Fb+uOEoXSmf
         KoBSOJkBIBZFKweeijWvgQ6/91puSgjDHbAmv65gKihB+jccMDR+nJi6wIlZdchttwRL
         FvzA==
X-Gm-Message-State: AOJu0YwKkzXBCXMJoh2lCAHQMxmuWesdDe5u/h0vbaWAcuzfZ1VhEBTC
	Ca/3ub+N7QVa2PwNwKRqf4bj74hK9NMKbx6aFRMjBlW7/gwCPyjFiuJXLg==
X-Google-Smtp-Source: AGHT+IGv5TTZEaryYuR89kWjuEEK9VO+owhUDSVwW249REtOat4j652lZW0WAxvjPrW/N+U632jSUQ==
X-Received: by 2002:a4a:e84b:0:b0:5c6:9293:ed8a with SMTP id 006d021491bc7-5d564fd61abmr10363671eaf.6.1721675087665;
        Mon, 22 Jul 2024 12:04:47 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:47 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 03/12] util: Introduce l_util_pagesize
Date: Mon, 22 Jul 2024 14:04:20 -0500
Message-ID: <20240722190443.43196-3-denkenz@gmail.com>
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
 ell/ell.sym |  1 +
 ell/util.c  | 12 ++++++++++++
 ell/util.h  |  2 ++
 3 files changed, 15 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 9fcc3aad9a2f..bc0c6e10ebca 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -23,6 +23,7 @@ global:
 	l_util_hexdumpv;
 	l_util_debug;
 	l_util_get_debugfs_path;
+	l_util_pagesize;
 	l_memeq;
 	l_secure_memeq;
 	l_safe_atox8;
diff --git a/ell/util.c b/ell/util.c
index 549e253eefc0..45ec6c8110bc 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -15,6 +15,7 @@
 #include <limits.h>
 #include <stdint.h>
 #include <errno.h>
+#include <unistd.h>
 
 #include "utf8.h"
 #include "util.h"
@@ -812,3 +813,14 @@ LIB_EXPORT int l_safe_atox32(const char *s, uint32_t *out_x)
 
 	return safe_atou(s, 16, out_x);
 }
+
+LIB_EXPORT size_t l_util_pagesize(void)
+{
+	static size_t page_size = 0;
+
+	if (likely(page_size > 0))
+		return page_size;
+
+	page_size = sysconf(_SC_PAGESIZE);
+	return page_size;
+}
diff --git a/ell/util.h b/ell/util.h
index f4fc4d1143e3..c56f182292fa 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -515,6 +515,8 @@ int l_safe_atox32(const char *s, uint32_t *out_u);
 int l_safe_atox16(const char *s, uint16_t *out_u);
 int l_safe_atox8(const char *s, uint8_t *out_u);
 
+size_t l_util_pagesize(void);
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.2

