Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D06D266EF4
	for <ell@lists.linux.dev>; Thu, 27 Feb 2025 15:01:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740668466; cv=none; b=dS5bgV5NNQhs6P+xsGslwxH8vwe0kyM05KH3Xrp1pljtzVm/Vw3+mv//AbjbDNhBO9no3AIdveslblUiwX5dsVGMakb7Bb+b0/nnCUv8iVRkIYKmkeD3pLcDZNv6clUQ3wkqgrp4MkUfVDGINzwxYUWZpHl9lXKcZf1fCOr/Vgk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740668466; c=relaxed/simple;
	bh=+83eKnzhQoFwM7+H0lyMQG7m1p/xCv1K8QtmIgRPsIY=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=NChRTod2AwEVR0Al4US5NkXzlgKP0snOHAEjooZ93nQ8A6UfX1LgHdbVUJrU2puZi9piSx7x6Ds75ZAO/wwpnAB4FzsYPrRBxU75Pp9jV+Ycm3OsP/7+CZn52NIslEggkxiPA2E5B5p9Dao9R7hYuYs+kyWjpyc7xow7QKzVXEE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ngV1ESnd; arc=none smtp.client-ip=209.85.222.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ngV1ESnd"
Received: by mail-qk1-f181.google.com with SMTP id af79cd13be357-7c0b9f35dc7so130823085a.2
        for <ell@lists.linux.dev>; Thu, 27 Feb 2025 07:01:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1740668463; x=1741273263; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=iLb5ZEH/Ch2HJ+ilrDO0WG+wssWtnvAJsniqZKgy4es=;
        b=ngV1ESndhA0HMFCuKOQgS6ry4Kn72/d33nEGf/ZruNru4XH1lJDh7FY1P1AmNlyWAZ
         N7T6dxDBa8Yn3zht26bsFyIyEBz2i3m+gUVC2Q9WROQ9oGclnVW0adS2KRQdNqmA35y4
         UBka5L+5J755v6H6e4/ksvBls0sAmvrJM7cXKRRGQKWQ84CH7ewdWDb3xSPOekLUuZ3G
         1DCr/osQcQ1JkRRmaBfmjvrI3Z0vwdzfYzpy/RG7D9me4zw2qKva02pfvYp8RAW9cY+a
         42vFIzr4KiiuUHDhfu/Ab9QcsGTNJXjntOYocVKKRomusdDTOdWMphBkpyj8eiONPi8r
         4mug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1740668463; x=1741273263;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=iLb5ZEH/Ch2HJ+ilrDO0WG+wssWtnvAJsniqZKgy4es=;
        b=PjBkWrJXW+FS2+PcfgZa5a1eJlooqIQlS+bCjUVSMogqKEBwirZq9xRx2S2LhhsLVP
         Sl29SlGIhXgw27SiFTKOIJ+Meh4fjyv0BaBAmFTiUPsRa2gEaxrR/DW8boCb7y+3JZtV
         EAfT2luRy6MEvY4mpskh75hguZMButRYyR8fDcBpiVN1RfdIYe8/gZn82hioVfuhYCk4
         9MqbSJWpktSaDY2eELuZ3qA5cKf43ZnJvreIz0kNFva/7U3uju8NfQUNMJIVjoYExn6j
         8x2crUrlI2Njw//bHljylurp7C0FJ5BjXj9onrt5iFPo5P+Iu+7ceUeuvOW2JcDBVwse
         vHJg==
X-Gm-Message-State: AOJu0YxNAtVx3h5MkNZQ0cVqsdiuy33Ui7GFr5Ukfa8+Yk5/HMUfuVaD
	J7aFFZa4U8uKQ8X/m7fV1nBXZs+IuoqtqS8mLMuhldD0vqwf61Dzo8Q0cg==
X-Gm-Gg: ASbGncus5PSTWQmgn85o/GMgQa3nSGr9NSvbX70G4P4QHqbwLd/vMqtnJKd3NfatSPB
	34pG0XmNbSwbW0FGMe+iZF6fb2DuNMHXbf8+UQmSWveua8e63TELUZAa8CGYctCe3sjKyzBAfzi
	KelJNXqgr0EolSCwGlaVKeeTeQOAmBBuUvakJCIoCvIl4GlboCSIL0RURBJBXze7qzTLh6Ax0pn
	7M6hKKO+E0PtvQ9XXJ6dv5C/dVL9NgPMcN6vA97ye7FeO7ld2UAfkKLzGadCXdAmO3QufVD6+4X
	OtE12mFZW6mF3tF8BLq4V/Pax0fSYADRsSgm
X-Google-Smtp-Source: AGHT+IHl5S9OEXqncQD6rm1sJ/TpZkSqgwDssbrXEkw1IJ6B20BTt5AnnKSgMj74IBD58vqGM60f/w==
X-Received: by 2002:a05:620a:c41:b0:7b6:7850:21d4 with SMTP id af79cd13be357-7c247fe1ddbmr1075096785a.52.1740668463512;
        Thu, 27 Feb 2025 07:01:03 -0800 (PST)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-7c36fef65b2sm116197785a.30.2025.02.27.07.01.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 27 Feb 2025 07:01:03 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] unit: use l_basename in test-path
Date: Thu, 27 Feb 2025 07:00:58 -0800
Message-Id: <20250227150058.160709-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This fixes a compiler error on musl
---
 unit/test-path.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/unit/test-path.c b/unit/test-path.c
index 1f74423..f01fa52 100644
--- a/unit/test-path.c
+++ b/unit/test-path.c
@@ -55,14 +55,14 @@ static void test_path_find(const void *data)
 	static const char *cant_find = "/foo:/bar:/dir:fr";
 	static const char *can_find = "/tmp";
 	char *tmp_path = l_strdup("/tmp/foobarXXXXXX.tmp");
-	char *base;
+	const char *base;
 	char *path;
 	int fd;
 
 	fd = L_TFR(mkostemps(tmp_path, 4, O_CLOEXEC));
 	assert(fd > 0);
 	L_TFR(close(fd));
-	base = basename(tmp_path);
+	base = l_basename(tmp_path);
 
 	assert(l_path_find(base, cant_find, F_OK) == NULL);
 
-- 
2.34.1

