Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5851C18030
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675090; cv=none; b=I+m3uNEC13C1NEKP1wLXoT8ullD6n2nVwOGvsFqmKbQ84q4KFehJGwq1O6C8O/P7FlkZ621Ml93kuD5uwQuUTodxPnCD5m6aD2JXn5l5KIqJ5bAfc3VaKoKFxThPPrDZK1lZqI8MxuemCjtNeHR7dYbEQOsqPSUUj3maJ9OI0lo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675090; c=relaxed/simple;
	bh=fhUP7ABoW8ejvLCDkAdomuT+lyblZbyUI42C+ewG4Dc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=C4Ya8jDRd/p7GIe1FDnwEtE9aYG24nIpSYTWtHyojRI4Th8L7X9wingqJTKELfP35cszx56JfeVJjDOdeDLbHJf+hBIBCbKreXzwRD01LhnbknmZYRlC45urAAa2tQxc6qFDO5yQOonaMEFuWw1mokMh1qIvL46ceavnfQxa4gg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=a27zGchY; arc=none smtp.client-ip=209.85.161.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a27zGchY"
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-5c669a0b5d1so2770251eaf.3
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675088; x=1722279888; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=HjzJFItQFqoBMF56u5bFyJ7TaXwSWytDi/66uEjOp6w=;
        b=a27zGchYkVgG/niqaNaYWEn18EYYwDtZu8YXSHVu1W7GOlKgJn2N02jj6+WWgvu/gk
         MsMzFDa2lmiX+xcLPCU0160W97RJF0DabHMzOgyBrbTnWW0zKNxn/GrLVvqYX5qyAeNO
         /Bjv+rkXa6SI8OZd/6B3+Azt+JPWKetp/iG5c5UJKiWXo+CXUE6v45GjqaUXJTV11IpO
         HqWx/En9Rnilds6mcfH1g92sHlkIDlZR11e10B6fhxfepWzg0ljatJ8Q97U0drhWsp9R
         RtocsQunX3JWAhX/86Z+DTTgCAoNYxXD2lX46fIWKfbyOWuIpmeHUXlG3IyN/Q0ojeIp
         wzRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675088; x=1722279888;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=HjzJFItQFqoBMF56u5bFyJ7TaXwSWytDi/66uEjOp6w=;
        b=jcvKmAba6thXN9zF7Hrxwk4VEObHywTkl96lHajdsCszlsBlDLWsEhqh+UJvcLCQHR
         uIKJ+P/xjsV10Y5OfVDkc1ZB627qJuWIGVXZrC/N0s+OWDOEXosBSR7S1YVX2sE6aLyN
         N9GVOZWs6kWuZKSuY9hrLi0MGZT0gAl7WF3GtZSanZl/0IR57kRdkDV2eoxJfZeeikor
         5Tdy6WcPvnU5iIL93CGzGvJYoahG7dOJsihPYa5z130irNmu9De4yXnmOeyIn07IIu/O
         dv/Nk99uJ8A3i7v/Okb2V314KpSk74OykWD/HcMplJcKlaWptmweKh2GWbH7r5C8g8l0
         cORw==
X-Gm-Message-State: AOJu0YzrI/lCd8mpVxkyP3KGGn7itfg+KEMcq94jIk7xIVoQvGyOBNk/
	YUs/i8l6egSseMYFSBasOpENJpj2E7DwNxmSHRMDk24dYuMYyLQXbrfy1g==
X-Google-Smtp-Source: AGHT+IHmYl29pZHHAIUkAGGh0txu0aryDZel2K2jRPxR/dM6gBxD4gW98dleZXhQ5WMyw/BC+6Bg4w==
X-Received: by 2002:a05:6820:2014:b0:5b9:e7db:1cf8 with SMTP id 006d021491bc7-5d564f82ed7mr11736438eaf.4.1721675088382;
        Mon, 22 Jul 2024 12:04:48 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:48 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 04/12] string: Use conservative allocation growth strategy
Date: Mon, 22 Jul 2024 14:04:21 -0500
Message-ID: <20240722190443.43196-4-denkenz@gmail.com>
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

Instead of always growing exponentially, only request enough pages to
hold the new string.  It is unlikely that ell based applications will be
processing large strings, so be more conservative with memory use.
---
 ell/string.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/ell/string.c b/ell/string.c
index a6d359d20cc9..e8e45beacb92 100644
--- a/ell/string.c
+++ b/ell/string.c
@@ -34,25 +34,18 @@ struct l_string {
 	char *str;
 };
 
-static inline size_t next_power(size_t len)
-{
-	size_t n = 1;
-
-	if (len > SIZE_MAX / 2)
-		return SIZE_MAX;
-
-	while (n < len)
-		n = n << 1;
-
-	return n;
-}
-
 static void grow_string(struct l_string *str, size_t extra)
 {
 	if (str->len + extra < str->max)
 		return;
 
-	str->max = next_power(str->len + extra + 1);
+	str->max = str->len + extra + 1;
+
+	if (str->max < l_util_pagesize())
+		str->max = roundup_pow_of_two(str->max);
+	else
+		str->max = align_len(str->max, l_util_pagesize());
+
 	str->str = l_realloc(str->str, str->max);
 }
 
-- 
2.45.2

