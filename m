Received: from mail-oo1-f48.google.com (mail-oo1-f48.google.com [209.85.161.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C03D91BD9E8
	for <ell@lists.linux.dev>; Wed, 30 Oct 2024 21:28:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730323732; cv=none; b=R6gr0OQW8VBJoAYBMP8lbDx3BYE+sdGKXJFWhAIUg4+3Frk8ptYhf2XVgE9g4uXcDk8gTzk4kFOW3RAeY6huJCZ/Dk3RK6g8vHdTcdX8tC/YKRbKOi878sdkcL4S2F/H4cc/nlzDc/TlAc4ZQXMKTi9P124ASlGHYxbdrdb5J5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730323732; c=relaxed/simple;
	bh=hB89sRi30VJcjbI3ZG8wMEl39/KJmO1e2VTXban9pzQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=G6Ms6jklMyeqxiHPg6n66rVFjWSrB4YCs2UQeD2Kyz92Xcv3b2afaZF1rLrtzwgRQjzzzws8/EEDo7N4Hrk+VlXNQR9lIL76Z+RkXKllV/qHzqJ8ug9qVr3uhwOiGaWl5C59XhxE5qtapTSy8kqb3XS/CPG1uwHm6toe7sQdhx4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UdWUK3Ti; arc=none smtp.client-ip=209.85.161.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UdWUK3Ti"
Received: by mail-oo1-f48.google.com with SMTP id 006d021491bc7-5ec2798661aso204461eaf.3
        for <ell@lists.linux.dev>; Wed, 30 Oct 2024 14:28:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730323730; x=1730928530; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=b7JMGAsMEe5NHQ8+qV7fsW/0MIN/qX33tcxQrVfaz9k=;
        b=UdWUK3TiyEhsNIcCTVyNloVL16Mf8a5FeICfnGVh6WWdCcW0RjAafTEL6cDsJNyS1u
         34L7Y0UwoH6iR2m/gz90oQbvRA6cnoAD0nx5OtYvZmRd9CuGWVQYQLz3nhxc6eaaVu5O
         edai4wuFDZgL6Q2x3ZeCOIz956DAtcQm4Pprl9wQ04nlTiZ6sW0Q1yXDJ0n+bxIr+bfJ
         cqvc5LiOFeVta4rdzYj9qZV74RJNQ/m2Hd5LFJGbTNdlAhsLGkVBHKpRqwyRZhEW8x2H
         IH9gIiCdcaDhXXpVwZOUcrCE7iNe8TMtrp+ZvGI5GcLv74Zoj0nNS7dgYiVOmWmp6Ajy
         UwKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730323730; x=1730928530;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=b7JMGAsMEe5NHQ8+qV7fsW/0MIN/qX33tcxQrVfaz9k=;
        b=fFZGTPF7pUTOxphXEkSbInMd5B5CVRThfpSneA0swHQ9MM34IcU06KCzlZOppxghx7
         HiHvrvsmd+RI3lgvqEQKahYmT4LKvbEvBjIW3icrH6njpWrLOekFIpypZ4brxbrBfUrx
         9kq/fCHZI11XZFgJqcmbDgclz0jq103UD2oOI3PuyqQZ6POgVW7zLt/iIk72Zy2gz+Aw
         cAPwMZpj2UPPEGuEsgOqRPHD92FDe7CQgl318glLjPCfgSxEZR13H7ifD9fvecosq7Rz
         RT/BJfUkMEZ5b++JPoo62SQ8+6f0l+zSCXq62fNJk8PzSH5kXq2VSl+MgHv5iGx4OhuE
         G1YQ==
X-Gm-Message-State: AOJu0YzQhwSgyc17KJCk9j4+R52B6KmFVwRoO9tcajXbtZSd7UEApRn4
	mcnPieWNy0F9nC1IPaO120ANUz4Xb9gX96VsyP7C2U4YkPVAWUx+VU6i3g==
X-Google-Smtp-Source: AGHT+IFwUsRTOrj9c5Jy21Q66aIjXVOzsVeSAJ3ErHP+9UlfKPnnjs8rLNbfVg1YIC2FxdP0R8ZX2Q==
X-Received: by 2002:a4a:e915:0:b0:5eb:c6ba:783b with SMTP id 006d021491bc7-5ec5eb2dd1fmr4355768eaf.1.1730323729778;
        Wed, 30 Oct 2024 14:28:49 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5ec705086d3sm9126eaf.20.2024.10.30.14.28.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 30 Oct 2024 14:28:49 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] util: Add l_safe_memcpy
Date: Wed, 30 Oct 2024 16:28:32 -0500
Message-ID: <20241030212846.1491158-1-denkenz@gmail.com>
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
index c56f182292fa..af03f894513d 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -243,6 +243,16 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
 void *l_memdup(const void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
+
+static inline void * __attribute__((nonnull(1,2))) l_safe_memcpy(void *dest,
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

