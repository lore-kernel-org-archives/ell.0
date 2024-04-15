Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C140219EA
	for <ell@lists.linux.dev>; Mon, 15 Apr 2024 19:14:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713208499; cv=none; b=nqijw67IrX1QjFY7d9W5nNZzdDQ2nsbQx3nVAmW0gsJ9xDbEtzz4UpggKppWVLiFWQXMZ54j5Sm/SnviYn2OzXZK+q5VnoqfcXPv4mN9IBmDG9r4gWrkwsd8aMqIMI9nZjgE/epofFM154Q0eU6RFV6J4Sp/BVHZsP1V/1iFQqE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713208499; c=relaxed/simple;
	bh=qFi+tH4pcqnIybS3Fso/M652fRG75zRQUMViz6aDYts=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZtlQzVc3NN2or3A5SjXBGtjdionDSv7ouklTjlIbvVjeaQJDXDDe6GPM2+C9y1J0FXdJe62Kr1naYUB9XLC57KI1SQfYATQz/ptKCPInijBVRsqSqVlv28sO7r73MpzXrBZBcI8JR48uzuF6gQIN7wfKbK8tNYLnvgwHR4a4GFk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=aKoJeC52; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aKoJeC52"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-5aa691c2349so2483587eaf.1
        for <ell@lists.linux.dev>; Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713208497; x=1713813297; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=kevpRA/R60NsZ0JLRUZI+rGbjyhOfw7i6iOyAoPTBg8=;
        b=aKoJeC52h9znPiC8ptpN33nkyORezs1/OUrEhYMSW2IelW7ol9IgLOYA2TgXec5gfP
         untcTnR9escTpb6kFsxfsdHgNVfPX5aSrJijTjIQs/XRMnIzQquZlTENy0SX5yiMw7Mk
         Fdig07qchUmYX6fAfILuYSCxgOaRc9q7ZUxTso1KqnGBhaIykwWG9hk7igUf9qvdYdsI
         kvgXGroeC0aYqBY21tLFfp2O3+uQKvC8Qa04o3Yiv5LpDKxhUa0EVRYH+kC3c7qtYtMU
         5IHqoa4oZXiPZaCHyM+Ju3xbimyVnGEBkhpF25lXJjn6H1SNxn5GxKubONlrGk2jx6Cp
         ku9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713208497; x=1713813297;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=kevpRA/R60NsZ0JLRUZI+rGbjyhOfw7i6iOyAoPTBg8=;
        b=r68FOSeT4IBYGjBvrFtJN4GHq2xy1i8QTk4ltIsp3PSpcsdQDEcdDdSFgztFXAX72t
         XQZZABqxzDGPi9LJsy4f4VNpVFigwdanU9/zZ6y8KlMXciRcC37DCQ2Um3fa3yIVMG3O
         EFqO+FsHb83ICxq6KFg7OHNO7N7VbFb7VQne63Rv7P4psoQnrdHWSTRjfkzYeh4lSWKi
         CgZ21xDGcnrIJaQ9qxHsD4/rGzNahkXk2X35NmvsrjvpN1sIh9GmJKqxeCO67BPihlhj
         hiiBo9XH82+vs09Ocn6tsIXHWR45Wo3GvOmhyLM3KvTsnqFcOS8OrJ9Py+PbpiaTlI+8
         TIsQ==
X-Gm-Message-State: AOJu0Ywqa7SMTRJMgfQOTuzCFELsDsx9BcudQi+I8BjuuBmVzDF+ec8G
	0j+3M7BiEGVX1rNioQCn7oT7Gyz0HvRWqcfvcH6lQUkevLfJDwtiNXRhSQ==
X-Google-Smtp-Source: AGHT+IHuA69rZCiwmTzDwulBJiEm+I2S0FUB56H90DBFBQIdO4r0aLtmHAEByZHmSyVA1sYD2SRF8g==
X-Received: by 2002:a05:6820:209:b0:5aa:5206:30aa with SMTP id bw9-20020a056820020900b005aa520630aamr11924916oob.7.1713208497194;
        Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id w8-20020a4ae9e8000000b005a586b0906esm2206526ooc.26.2024.04.15.12.14.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/4] util: Add L_BIT_{SET|CLEAR|TEST} macros
Date: Mon, 15 Apr 2024 14:14:34 -0500
Message-ID: <20240415191454.3259243-2-denkenz@gmail.com>
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

These macros support arbitrarily sized bitmaps using any integer data
type.  It is thus possible to write code like this:

	uint64_t bitmap = 0;
	uint8_t array[4] = {};
	bool r;

	L_BIT_SET(&bitmap, 63);
	r = L_BIT_TEST(&bitmap, 0);

	L_BIT_SET(array, 25);
	r = L_BIT_TEST(array, 31);
---
 ell/util.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index b5d96754e8ae..53a932c771e6 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -366,6 +366,24 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 				(__v && __elems[__i] &&			\
 				 !strcmp(__v, __elems[__i])), ##__VA_ARGS__)
 
+#define _L_BIT_TO_MASK(bits, nr) __extension__ ({			\
+	const unsigned int shift = (nr) % (sizeof(*(bits)) * 8);	\
+	const typeof(*(bits)) mask = (typeof(*(bits)))1 << shift;	\
+	mask;								\
+})
+
+#define _L_BIT_TO_OFFSET(bits, nr)					\
+	(*((bits) + ((nr) / (sizeof(*(bits)) * 8))))			\
+
+#define L_BIT_SET(bits, nr)						\
+	_L_BIT_TO_OFFSET(bits, nr) |= _L_BIT_TO_MASK(bits, nr)
+
+#define L_BIT_CLEAR(bits, nr)						\
+	_L_BIT_TO_OFFSET(bits, nr) &= ~_L_BIT_TO_MASK(bits, nr)
+
+#define L_BIT_TEST(bits, nr)						\
+	((~_L_BIT_TO_OFFSET(bits, nr) & _L_BIT_TO_MASK(bits, nr)) == 0)
+
 /*
  * Taken from https://github.com/chmike/cst_time_memcmp, adding a volatile to
  * ensure the compiler does not try to optimize the constant time behavior.
-- 
2.44.0

