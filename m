Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8FE9189F58
	for <ell@lists.linux.dev>; Thu, 29 Aug 2024 11:25:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724930756; cv=none; b=uAAi/2tVthiFpm4MblCPHW3tKK3lKnjNkRo6E/APShhQqkxqfv6TiEhOfyC7Zx7PPRrr0S76r1LXHZcmzD9z6QfRVZ/WHnJTTg9vkb/Ggz2pe/X8oUX7OHevkVYgWh8MqMTtTjJoGWsnJaDBgTJH2dpjImk1yYTEI9PjnwFMPts=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724930756; c=relaxed/simple;
	bh=jWmSuxBAMKPmyi3L+uo+S83rl0UgQsrfIfh91CBms/A=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=scLRYBdm/VBaTvlb1PWD0qbPHrLzFaLZOT6XLzae4LkB2RLWJut7So8EQk2YK8xAJkuYvcKS7EOHi+zKFzwT+pDSrEPUI1cXp3ExGUnE4Kfj4CxGTBSZhKDjxNlH2CivrWl6OlAQBA+OhKH52bA+k101WFJKMDgDLJwSxhxiDYI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=K8OPqTro; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K8OPqTro"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-3df0c80286dso84620b6e.3
        for <ell@lists.linux.dev>; Thu, 29 Aug 2024 04:25:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724930754; x=1725535554; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=sLi9sF+GXGxVumnn1vzySv0VtX4un78a7dYec305axw=;
        b=K8OPqTromOB4YDjG9ur7mMt4lMIxYAlRsOnRlt8XJDghGAcP659Vih2yH5f1Wj8SAf
         JDV1UbndOI5LgIaOdxCLjI7SQtSeeu9fFs8itxyQSyL4nWRYNEStZqgb6AUnwEvvwcE/
         tOINn8YI/D7TFFxtjzlkZ9tloLpjDXp5EidWr+vQ8FLxpsM/vrPMtJQd39j+lCEEwTr6
         5NyX4NcOcaSa3YFl9k7mUwSkm/wnUjfWYCwb0cIa2dQ4/CrvY8mtvhX92acDuVTM2uA6
         mPko5PPmJbEmeGVigsGXg+FDWOuJmTnK71PFC2SDuyoipEOCKSqhrZlfv9AhjLXaMrU8
         Qk5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724930754; x=1725535554;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=sLi9sF+GXGxVumnn1vzySv0VtX4un78a7dYec305axw=;
        b=Fn8m9L2YmQ94hz7wq8ZIU8cnRjROBZtVmXrF92Eclm6bWppIXg+tt4dP/Z26bbSCN5
         X66B9f741z2DVM6grwcDH4qQ/U6aINmavzRF7u6wZDDedE/0IUy/85piJIJiBlonfeVf
         GfLo5yb+D+DdAMNxHwwVNIfyNHF63sYMZ86J5DfVUs2v3icZm8mGpQCCQsr41xevb3kr
         ZanEJmclFPajd9TLPY7LyJPcc7tv0RLzCbbkY5SzmFzm4rpo/Ytu+EVNMKWxg0JfRQ3K
         UcIEM2MASFL6/k2teLKm+lefvvYWb48Izl9e0mL4qKQCxYULCtqvnqJtlnDXzH4mil88
         57cA==
X-Gm-Message-State: AOJu0YwV7CaiUIbZG3IbhuAzv45tg12C+iW7qfY1a1hf0UWjOCs2zJCY
	DSHlz7QQu6ojAwSk8UqVgET4Srlom0Y/mavteccVBUxXUMAdh/gFN9PjzQ==
X-Google-Smtp-Source: AGHT+IHhfs1kfermH61aV6s/f/gLe8RbpxLDCniJC8ow7sA0mPC1V6obWJvZ2Ok33wTaVwNzBXHWFQ==
X-Received: by 2002:a05:6808:ed0:b0:3df:3fc:6afc with SMTP id 5614622812f47-3df05e528cemr2181220b6e.25.1724930753538;
        Thu, 29 Aug 2024 04:25:53 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-45682db5c50sm3969221cf.94.2024.08.29.04.25.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2024 04:25:53 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] time: expose _time_from_timespec in time-private.h
Date: Thu, 29 Aug 2024 04:25:48 -0700
Message-Id: <20240829112549.24935-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/time-private.h | 1 +
 ell/time.c         | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/time-private.h b/ell/time-private.h
index 59c2421..2860943 100644
--- a/ell/time-private.h
+++ b/ell/time-private.h
@@ -12,3 +12,4 @@ uint64_t _time_fuzz_msecs(uint64_t ms);
 uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_offset);
 uint64_t _time_realtime_to_boottime(const struct timeval *ts);
 uint64_t time_realtime_now(void);
+uint64_t _time_from_timespec(const struct timespec *ts);
diff --git a/ell/time.c b/ell/time.c
index de4e161..e124a91 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -18,7 +18,7 @@
 #include "random.h"
 #include "private.h"
 
-static uint64_t _time_from_timespec(const struct timespec *ts)
+uint64_t _time_from_timespec(const struct timespec *ts)
 {
 	return ts->tv_sec * L_USEC_PER_SEC + ts->tv_nsec / L_NSEC_PER_USEC;
 }
-- 
2.34.1

