Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0632D1A7065
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 16:19:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730391573; cv=none; b=dv1JmCxy29CZOxV0vjnu2iCjiWcJFlw5tl4ZGRVXMYwPhzwBcJpi+hEeO/Tb0I1cPuHoE9452BFSpuJ1LFeDWy+MzZCGP4OGVHaP3iusMxVYK6IF4uU2KVzLlU6VdB0C49KGOnNj8dkiN+M8Q9izrCN/RnLMuYtJKPjQ4XjbPNg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730391573; c=relaxed/simple;
	bh=rB0WVXmA7+mg1gyALVsoxOlEUtBWLETXIbmSqW2Digo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FL8ddizfKSvaN6miJvHz9x6lZfHKwxwLvR+o7STKHYbaiMJra+KslN+auXWAvk5obEdYkXadt56YrORGCiKN4tAVO/8zobDDLsh5A57rUWz5+ePl/v8ooen0GIABO+81p7buidmH2/ENDJ4nz0VsNNxVXPt9WPeev4HPb2nwcSU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Gmr7RdkU; arc=none smtp.client-ip=209.85.161.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gmr7RdkU"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-5ebc0dbc65dso678019eaf.1
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 09:19:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730391571; x=1730996371; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=3Q6lSq75EljNremgSds3C+qDs1D/Xh5cfatupuU7reI=;
        b=Gmr7RdkUs97iBE1mglq/6C/lPZ5Tq+HUsmkNdovtuDRtfVNIUnWJ+UR5IdrX0pcMCt
         Ge+2ARwZfioLv/ObQ0Hw6zQSQTGJ1pwouia5o8ogH9HveHSYUirZW/GVqCyo5S795Iol
         h6L/4JhHmWwtR61uygLNMi2ARDphkZI4VDWqrIpxbwAJ2sWfEHgzL3ADfs7fKMMkLosW
         5xrNFzEODmbltSOsrQuvcSKwsY90ymLCxwrBkeqDPEtoUqKJrEDTJayeGRdN924D8VQm
         T+l+RGIT4Iq/RfCrs9m67Rx0wzesDnR5erJHfVoyyuCkhpD0cpKLbbPrNyELpScy1o4u
         HvFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730391571; x=1730996371;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=3Q6lSq75EljNremgSds3C+qDs1D/Xh5cfatupuU7reI=;
        b=Uo5OMluGk6csUz6DimGgJ8AodA+P2Af1PzgcFGKzUgEolYKFuzxv964ZOum5W1uoEA
         KDGwWca3E2eMFC/Zr3BVQrhJL+ne6+C+ZvuIS69Uq5BpyaWErOVV/z6K94WzAWgQZKwt
         pNpmJ7ZOKQAMtdU8qC5+tnbDYrCG99Pf7v1SVerO1fNoYHPILv8wL4jUW/H9faXcVibG
         I+kTkek73NyQFgX/HVhfE6+PAKkeSRTu8brW0MlP2P8QbvgrQecs1lIQhgvPtIKuttbt
         uVrizwm0Km36/zyttk4Fv0ONG05SdUGY8gHWhW8FLLDZbyYur82GZ9DXMQH4llsxK2U9
         dlSw==
X-Gm-Message-State: AOJu0YwnKa2NBspjWs3/31g0qo2hDeckgta37jUVLgC06XoUBb5NBf3J
	RYXEmWMHIt/xQudKSZXM3QM+eIKQVIOCAEiah67b67WNYMwxiDMWbgd42Q==
X-Google-Smtp-Source: AGHT+IHZOfv3UxWwLbLK8LJR57Gua/aRCwoJ4XQg7vnD9G4CPxg3VwtyEqfpZ1ZJFXJm8uhkkjt9aQ==
X-Received: by 2002:a05:6820:1ca2:b0:5eb:b282:5916 with SMTP id 006d021491bc7-5ec23a8d4c4mr14911695eaf.7.1730391570915;
        Thu, 31 Oct 2024 09:19:30 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5ec70509a9fsm349337eaf.23.2024.10.31.09.19.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2024 09:19:30 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 1/2] util: Add l_safe_memcpy
Date: Thu, 31 Oct 2024 11:19:17 -0500
Message-ID: <20241031161928.1514776-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Some callers use memcpy without checking whether the size 'n' is greater
than zero.  This is generally fine, but does cause sanitizers to
complain.  Add a new l_safe_memcpy function to take care of this case.
---
 ell/util.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index c56f182292fa..8a4e0950b41b 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -243,6 +243,16 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
 void *l_memdup(const void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
+
+static inline void * __attribute__((nonnull(1))) l_safe_memcpy(void *dest,
+						const void *src, size_t n)
+{
+	if (!n)
+		return dest;
+
+	return __builtin_memcpy(dest, src, n);
+}
+
 void l_free(void *ptr);
 DEFINE_CLEANUP_FUNC(l_free);
 
-- 
2.45.2

