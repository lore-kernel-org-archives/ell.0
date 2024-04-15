Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE0D7155A27
	for <ell@lists.linux.dev>; Mon, 15 Apr 2024 19:14:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713208500; cv=none; b=X7tS6E9TzMK6XXKe+DhEWzJJ9cDcrumcWum+bNZEQbJtOMxzYkttR6ujJLgTGkfcuPq1BZOoOu/Qvw+zUqz8pjGv+o3Q71brkkTwlJiB9mxQvvUY8R34oqeb6rpUanT5h69N3chQ+TUaGletM2KFzrXRHgz/KYvNJPU0OY2NyCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713208500; c=relaxed/simple;
	bh=etGFJfjhqJnaN2K4N4QHrKF9ivp1CxuuGpLRqITRLcw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GRrqBF9eQ9W+epFH5XcLiglqFa9jW0hJSyfxUW/X3AiveGrVws/WTOUA0kKTFgr/lnHLWx9TMg8olptVrLVW48hrQ2fZ0p1mO5PE4o7Jdg/O9cH9YOmjgVzjeeCIJ7fJTTBfM32pPAx9qzqPBzmZIidy6LSBgqlUE4Zend6pyCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=L+WF9ZIu; arc=none smtp.client-ip=209.85.210.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L+WF9ZIu"
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-6ea156bee62so1474613a34.0
        for <ell@lists.linux.dev>; Mon, 15 Apr 2024 12:14:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713208498; x=1713813298; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=M11g0U3IY03yMnZK0FrhJjZCJ5lipYhsVqDVgp5+Bxo=;
        b=L+WF9ZIu8oBzLQz52M3vo4mRRlVYOhSF+146TgKwcVKMa/jX0zJQnmH29WTknK9g4y
         8jPLBCRhXkmzhWu9vOcL41LnWutFNYTOlUeC2QtakM9G6nlQvVkCKvyfxivA3SF/Bm/M
         xQoJfwdxNlBIeZS4PTmc+rRO0sBvXqFJfqAtkrCO5QIPKCpDOhf6Z6WxdfbFYRYTKiNP
         uVq3VFFqNKhlH0BrqkjpZw9MT8kpDPScbK4MZRFY2B2jHI4IiHDnTDJNcaN0aXuKJNI0
         UXR0g3yK/WbX6R6kARWczhD62fy4kjMEbRu6wVNmyO/bQVdoB9AglYqgOxHVxBrbTQOm
         p8/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713208498; x=1713813298;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=M11g0U3IY03yMnZK0FrhJjZCJ5lipYhsVqDVgp5+Bxo=;
        b=oMOteLzdOcP1+y+fSaAtXkKH5NoMGggT9a6QuYImsSTnIAsYKEzFhSH0ZWM6WVnHp4
         5laFihDggv1chGtthPqTdxiW6XUM6H4MMhDh1eT+wDB2cHehWrjsMCajieoCSJNe6396
         roIRmzkaQ3OAyw/zqBu9Ay9JoN6iZkbuaCE/vv/WSwZDRuzI0oPj2zDyncOKVnBhRwId
         6C86ob1JZh5ohBwJI/V2XE+7SBD+yGuu2EHd633cI5qcvn5ZRSGAd7A69JNDogWSDlDn
         BzIyxZikicMeFS0gPul4lDfTGuhi0UMvY20wGZ+mjGkKZx0+rVVLHmgmDIuujyxht6YM
         iUgQ==
X-Gm-Message-State: AOJu0YwcNxFXtUNC+U9p+yIn3bozredGHsNnLyfHE0TcePXtkz1aWmOv
	cTx9C0j+awwFszUgO2mWOOB2QumCkP1TgTRtjE/sNyKY/+TW5Z4ZX01boQ==
X-Google-Smtp-Source: AGHT+IEEljh5yKb4SlQkI6ZcW7q8hGvftTwq/tENdTpEepNdgvs/qwBm8iukhBGqFOkIsrdYexa2lw==
X-Received: by 2002:a05:6870:6e0e:b0:22e:bd8d:c04d with SMTP id qt14-20020a0568706e0e00b0022ebd8dc04dmr180175oab.14.1713208497812;
        Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id w8-20020a4ae9e8000000b005a586b0906esm2206526ooc.26.2024.04.15.12.14.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 3/4] util: Add L_BITS_{SET|CLEAR}
Date: Mon, 15 Apr 2024 14:14:35 -0500
Message-ID: <20240415191454.3259243-3-denkenz@gmail.com>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240415191454.3259243-1-denkenz@gmail.com>
References: <20240415191454.3259243-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

These macros can set or clear an arbitrary number of bits in a single
call, as follows:

	uint64_t bitmap = 0;

	L_BITS_CLEAR(&bitmap, 0, 1, 5, 15, 32, 63);
---
 ell/util.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index 53a932c771e6..1d14ffb1570d 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -384,6 +384,20 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 #define L_BIT_TEST(bits, nr)						\
 	((~_L_BIT_TO_OFFSET(bits, nr) & _L_BIT_TO_MASK(bits, nr)) == 0)
 
+#define L_BITS_SET(bits, ...) __extension__ ({				\
+	const unsigned int __elems[] = {__VA_ARGS__};			\
+	size_t __i;							\
+	for (__i = 0; __i < L_ARRAY_SIZE(__elems); __i++)		\
+		L_BIT_SET(bits, __elems[__i]);				\
+})
+
+#define L_BITS_CLEAR(bits, ...) __extension__ ({			\
+	const unsigned int __elems[] = {__VA_ARGS__};			\
+	size_t __i;							\
+	for (__i = 0; __i < L_ARRAY_SIZE(__elems); __i++)		\
+		L_BIT_CLEAR(bits, __elems[__i]);			\
+})
+
 /*
  * Taken from https://github.com/chmike/cst_time_memcmp, adding a volatile to
  * ensure the compiler does not try to optimize the constant time behavior.
-- 
2.44.0

