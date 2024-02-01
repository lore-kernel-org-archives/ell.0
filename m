Received: from mail-oo1-f43.google.com (mail-oo1-f43.google.com [209.85.161.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6E981649C7
	for <ell@lists.linux.dev>; Thu,  1 Feb 2024 15:18:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706800722; cv=none; b=ENp1KdQm1RvmpxQxkEl3N/99TnLgVkJT6BBpLJYf+6eis4ZVrUxefZ669intdyj24huIm3xcwHL46pKsXyd7nzftOOQVNkB4GwenEyVT6/0aeDVwVi1hNTS5r/AbJmOy4QifNjk2mT7iWz8TkwoEyCfpIM3l3PfgY3z/VUhvtXY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706800722; c=relaxed/simple;
	bh=deiuispV5WCU4Ydn/x3JNlAwg/9aJzC3zZR+5sTlSdQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lPhtAXh26Jg5rNZ7dbMFAmubccw5zKMt21WYwpi/OJPnDaTBDKwZ7kz2JWAzG3hlSM9/21avnR3iIUNH47bmI4vgq7Q65Kpsw7L5M8VwnWlf5cTfsvE+S44o90oQin+hfNQgaok/BkQaahM/Feu8OxKlZ6wQw+m3cy1SY8lVUVY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=m/4g+qx9; arc=none smtp.client-ip=209.85.161.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m/4g+qx9"
Received: by mail-oo1-f43.google.com with SMTP id 006d021491bc7-5957ede4deaso672215eaf.1
        for <ell@lists.linux.dev>; Thu, 01 Feb 2024 07:18:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706800719; x=1707405519; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=KB/gFFbQX0N0sOMvTtWqlAdzmlo+BNpSVuKL7ZoXmpE=;
        b=m/4g+qx9Aiy1A4uhWgpBCHs0CyHgQVWLezuh3mJVBF0EbayMXlRQvUmF2t1IQ97xyK
         x2ea5osfF1NQBT7EIpPpcALeOpaqLL5rvkaBbqlbEpeQV/zWsdxZv0QkdU6EfbGdxBhC
         9+QTNlOp9XgKz139SeTOI03lY+57XkeAhrKtQpv3UeWBn3Q0jG5jBnWbXw03O4YHGy+C
         agIf0CxN1TpmmrALWs5kiMIAik8ETgTbAvUKOlmJzrQW6yanD8mXUkE5YGob83L1Il2j
         OmmjAXLaKpnCs6QIzDnJODhq+/m2kdTzRvRctKoKGwbXmlQ7iKC7b7LgeNl1li0N/8Zv
         McGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706800719; x=1707405519;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=KB/gFFbQX0N0sOMvTtWqlAdzmlo+BNpSVuKL7ZoXmpE=;
        b=wc7PJkmPT34RpzusMJgc1BRNhhCLelzmiFAHQthiI8rhjaXN5fCVC87mIT0WUdcj6x
         tAQ2eVtgODh8ky4tqO+JWVr8qsuQu+xlqbBurPyiyB7VCs/ZlJYc+EEYvN9Yd04BAcDv
         nl7FDqb4US8S71163cizfTIjOl5cY7qHI8ZvYnffNbOwtAULCNHppQDwmD3t3unmNm+s
         /Mrujz7LKxGUB+Pq8B0W6CA+ar5OotfHAtApUxELHyGn6Vt4N3fHxsm181a3oJLHAaj/
         IkiLCdj4gRYeTGRbnAWkmF2KB8Hod16ouf1Cj0HtYFgBC8ZmdNRzM2DgUuiUM9F/4vQt
         jIDg==
X-Gm-Message-State: AOJu0YxlNHrn73JkexUTugaxvL7ciztvglkXe6Y+R9+syCi5PAd8uAIK
	pkjMM8Wiv/FuC972U8EsoUCeMlOOSERaoscVVL90qLMC7fVk+iOtHB7ynh4b
X-Google-Smtp-Source: AGHT+IFZc5X/SWy9+b2ULX4rsgAu7iS6RnVDucAseLKWc1W9UKe/YUSX8M+937mm5VEm6xLUdM+tWA==
X-Received: by 2002:a05:6870:c387:b0:218:550b:d6a with SMTP id g7-20020a056870c38700b00218550b0d6amr5636431oao.48.1706800719565;
        Thu, 01 Feb 2024 07:18:39 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id e12-20020a056870450c00b00218496d80b7sm3153326oao.29.2024.02.01.07.18.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 01 Feb 2024 07:18:39 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/2] cleanup: Use _l_ preffix for all cleanup functions
Date: Thu,  1 Feb 2024 09:17:34 -0600
Message-ID: <20240201151751.880279-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20240201151751.880279-1-denkenz@gmail.com>
References: <20240201151751.880279-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Also while here, move the __AUTODESTRUCT macro to cleanup.h and prefix
it with _L
---
 ell/cleanup.h | 5 ++++-
 ell/useful.h  | 5 +----
 ell/util.h    | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/ell/cleanup.h b/ell/cleanup.h
index 337c8ad5d753..ac9f5a894b24 100644
--- a/ell/cleanup.h
+++ b/ell/cleanup.h
@@ -7,6 +7,9 @@
 
 #pragma once
 
+#define __L_AUTODESTRUCT(func)				\
+	__attribute((cleanup(_l_ ## func ## _cleanup)))
+
 #define DEFINE_CLEANUP_FUNC(func)			\
 	inline __attribute__((always_inline))		\
-	void func ## _cleanup(void *p) { func(*(void **) p); }
+	void _l_ ## func ## _cleanup(void *p) { func(*(void **) p); }
diff --git a/ell/useful.h b/ell/useful.h
index 8a4bf2ce70c9..ab88f52556f5 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -59,11 +59,8 @@ static inline unsigned char bit_field(const unsigned char oct,
 	_x / _d;					\
 })
 
-#define __AUTODESTRUCT(func)				\
-	__attribute((cleanup(func ## _cleanup)))
-
 #define _auto_(func)					\
-	__AUTODESTRUCT(func)
+	__L_AUTODESTRUCT(func)
 
 /*
  * Trick the compiler into thinking that var might be changed somehow by
diff --git a/ell/util.h b/ell/util.h
index db86bfe278ea..4ae03095d013 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -317,7 +317,7 @@ const char *l_util_get_debugfs_path(void);
        __result; }))
 
 /* Enables declaring _auto_(close) int fd = <-1 or L_TFR(open(...))>; */
-inline __attribute__((always_inline)) void close_cleanup(void *p)
+inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 {
 	int fd = *(int *) p;
 
-- 
2.43.0

