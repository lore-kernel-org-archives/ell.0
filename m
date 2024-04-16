Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F21512D1FD
	for <ell@lists.linux.dev>; Tue, 16 Apr 2024 14:25:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713277504; cv=none; b=YnkV5RXtfVMHLbtReGNwbnEGYrTstoyNGj4aZL1Jj78yaZWVa08aQOc+Rgkw1hoJW6PJltMHOCRwWgZ723tzOlSQMkFh2mlcNbXdCBYtnYo9IVTDqSGYT4xDTvJ3QKeUJPK+OSlCVGdJHV+oO6eNM94A/aDVrDLkb6erxyHCQPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713277504; c=relaxed/simple;
	bh=nwdqHoOXWcez6n0clJODZMaJMJz18GyICBeKue7pfn8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kOdA0CLZFCTQOJ2cZLZfAH5PkJowLlmhxgsX9D3vYalhqa+7pnsfLY2Dg/Uw0+eOA4hRUSCy68tTnD+yP8Dc6EeVmF9O+1qKy/wB7umxx3ijd+okj3ckWvRUXjxwEFaReDdHysYbQ5yTJfd+OHwsjGcz0X6XbLpJE+KtHuXdsVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QuEL8l4Q; arc=none smtp.client-ip=209.85.210.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QuEL8l4Q"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-6eb86b69e65so1029615a34.3
        for <ell@lists.linux.dev>; Tue, 16 Apr 2024 07:25:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713277502; x=1713882302; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Uy2zvEZvdwnelhW4o8wq3mRw4YITkcPAT3PVo/a/+UA=;
        b=QuEL8l4Q2PHIFlhkppIJlpvVbQJnIXGkl757OF8cR7xvragxjC+wFOVhAgpARjlKan
         qUxzNTvyDTI5FdEM8reGAcsMng0ePy7X38qRQqKl/rYVK17tYkWNbvFQhDdOZ83XSJk9
         Gm/yCsQdEm+uEx232qLWGysEHhTFkEsHYcenVcdTMH8n6PlrSVXTA50pXGQWXbZ9ixii
         bOOAX025fgbaWA3/OC3DInc1qo8JmNW10UThxbGtEWgKWTeMtHIQbDW31LBKmPYcb3h3
         wHxM3YlXON7g/STbzjGGdjIUFQNTWp6YFs1KAjXOfUuVgKo5P3OAKhMGj4LlxBiId0Bd
         SG7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713277502; x=1713882302;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Uy2zvEZvdwnelhW4o8wq3mRw4YITkcPAT3PVo/a/+UA=;
        b=B0awLr+gHUY5O63bNe+fFhYXJFnIpQpKyvlhEHhCg5rOrjyIPVIZa+cty7Rio7HD2B
         YiDZcCpOIM9FFatFX4jRuRZbk2PElEVgE0PHb0gas3t5NSxmoLfXlMB9cM+1Ihe2LfMk
         JwSPLjJLnmZ6RDIpBKniPgv/OQuLHFfRwMEx5y+Pc6JscscVHTZQFzm929GtI9wSH09v
         fPro6KeXTqou7NxC36nz/JalO2Im+WYH3zXS8qJDM5F35QiMuy3cWJMZAeaHSIjhTdYz
         iWZuZwigaDrifQ3gZ4Gz7zXm76hvjNJQ6lOXaZnt/wwTnBmn9ce3xmcVfgt5yO/EhjlN
         KtQg==
X-Gm-Message-State: AOJu0YzG4Xt98brvCqxprbUh5NyoEjWqowGIWYGQWb8c8Z5499v4uVIb
	qZihMPdV4d7BEhUaLNv2xWaVnR+603YABv/bd1DessNZoJawblmb1jXxBw==
X-Google-Smtp-Source: AGHT+IF1X2ZqInNf9q2OJ5n+29O1nFmknk6SI3vA/m7Xw/MEAl+f4QV2eILiVZIgiSeHoBpjPNUM3A==
X-Received: by 2002:a05:6830:650d:b0:6eb:8612:64d3 with SMTP id cm13-20020a056830650d00b006eb861264d3mr6231939otb.23.1713277502359;
        Tue, 16 Apr 2024 07:25:02 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id r33-20020a05683044a100b006eb892647dasm526999otv.79.2024.04.16.07.25.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 16 Apr 2024 07:25:02 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 3/4] util: Add L_BITS_{SET|CLEAR}
Date: Tue, 16 Apr 2024 09:24:54 -0500
Message-ID: <20240416142458.3353383-3-denkenz@gmail.com>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240416142458.3353383-1-denkenz@gmail.com>
References: <20240416142458.3353383-1-denkenz@gmail.com>
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
index ed0bbe845656..346197771514 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -396,6 +396,20 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 	(*_offset & _L_BIT_TO_MASK(_offset, _nr)) != 0;			\
 })
 
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

