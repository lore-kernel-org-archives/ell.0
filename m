Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F29F1CB51C
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 20:26:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730406392; cv=none; b=foDR03e1jEEC7xaZqAAL2Nuec+Ty2Hm/Oj+Btl66EDe2gN7fD/d5qVd831SKFy8psDkAWkh5POLOesSOD5tjEYx7i0D68NFJl9Bdw7IA7AeEk+vqXNxIi7Lg/yfO9GE30wjSqIm93Ql9zeFEF7OSn9Jjs1IzG/BDvJW1HeByLeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730406392; c=relaxed/simple;
	bh=lbJ29Yi7RpD5RnDW2kiFil9sEGyf3kMPa+e7Aj7G6dw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mmZEUOE22iVQoEC02JaNWENE729pb67vsYlIGQshgfrzbnSts90AusuD8jcklcQMZ1WZLHm3x/4sChYrb+SLETY3eWjGMKzRjvphBDYusld/v5ZmuuLubLhuiaqeY5uBNlvbYvdCb7taGZ/xPIDV0Ni45eeA1MMEP+nI33jJfAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=k4grpLT3; arc=none smtp.client-ip=209.85.160.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k4grpLT3"
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-2689e7a941fso765672fac.3
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 13:26:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730406390; x=1731011190; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=AAadpLSg11zRTQ6PtMzXn0c8UoyAbraRzYllVdPBD68=;
        b=k4grpLT3axDTs7nO7x7M48zZrip5/KidJQJTFKtwBoyOfmsuuqlsjOmmHjiQIMSzIi
         62EByEy4SuyNlZrz1RSP48d1x7yfjZqZ6H/cYkJfht6oBw+04H/Puo5WxNt4ibQLgRrf
         8yWv2RFMQyhVfo7pji/x1slldLK+fQJQgPK0AaOM/u1nvD0wXLxXluYazQN3QIU9JWw6
         dvKgUxY3MfaX/7atmuwSFa/Dz2t4zokB7qeYuQVdKxbvTo3JgSQh3VcuJ79T7xhzG8hY
         +JDuG4NZ4u9/0+fuykSs0yZ5kHkrJC4DUo3fs9iMNMA+fv/7Zn/L72rIrG7jNYt6TWkB
         2BsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730406390; x=1731011190;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=AAadpLSg11zRTQ6PtMzXn0c8UoyAbraRzYllVdPBD68=;
        b=aZF23wGhh7ZJMNxiX7mWl/tAMcVMxpPi1JcGMvEM7muFXPNgx8GHC4VEfogAkkwrEp
         AHLodqeLaYf3kSAqsmEottd5jQ9qF8Nc3FzLT7mtJpLfXbSgUzJJlVdFhUEDrQqFG/ID
         FlOGv40ccELWKwSIg3Pl5c7dwvazNGKy9xCPAU4njutArw651d3AHj6xSpGLhNHM/Qgw
         7zwbCltOVY4303H310PwL2TSWyKv6GWHG9tt+3YAFDop6aiZjV3M3rTA2GU2CPIGEn2S
         mKRm2+NyLY8f0baYrYPAFpqhvgrJx5c5qEgPEBj85iUZWzwnvorKkj5zyiBL3bHTw28m
         42yg==
X-Gm-Message-State: AOJu0Yx1Tt6DFHeACeqhYNZyO3tt34db8GyV9iJFdKjeXd/Xq/Qs3g32
	n5orOfOapTszjmwjo3X6oavuvf7GdDT+QYRLhbQ14HD4LMnjYLWPzjzjsQ==
X-Google-Smtp-Source: AGHT+IFXdPG/xjhL9zcTaDhEok149AuiM1ubHpfSyjTUd13LBfmxr7Ea/NmYUEF8ndVLpTkMC3sUXA==
X-Received: by 2002:a05:6870:5252:b0:287:7bb6:3c54 with SMTP id 586e51a60fabf-2948466f648mr4422392fac.38.1730406390190;
        Thu, 31 Oct 2024 13:26:30 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-294874d6687sm712930fac.31.2024.10.31.13.26.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2024 13:26:29 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v3 2/3] util: Add l_memcpy
Date: Thu, 31 Oct 2024 15:26:14 -0500
Message-ID: <20241031202627.1548592-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20241031202627.1548592-1-denkenz@gmail.com>
References: <20241031202627.1548592-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Some callers use memcpy without checking whether the size 'n' is 0 and
src is NULL.  'src' is declared as non-null and can thus cause
sanitizers to complain.  Having 'src' as NULL is fine as long as 'n' is
0.  Add a new l_memcpy function to take care of this case.
---
 ell/util.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index c56f182292fa..2a0ee0e50b93 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -243,6 +243,16 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
 void *l_memdup(const void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
+
+static inline void * __attribute__((nonnull(1))) l_memcpy(void *dest,
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

