Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5B6512D1FA
	for <ell@lists.linux.dev>; Tue, 16 Apr 2024 14:25:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713277504; cv=none; b=pOXwqI8jvHY/xRdKRy5R3/rU5lva9cAPEULHBQP37NNrRyWuKNPBE5MvDT5nh5nTpOQihwFliFzyS2+k5B+XlosGXeMryO3H3UXRYE8QerTqc09BAoUCBRpyEeRnKQzdZYSOCHtZKi97gpT7P3P9cEtgEQFdjYVMLkgSyUwy9xM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713277504; c=relaxed/simple;
	bh=j10vhC0Mr9hA/ntVVrTff+CXbRTx/mxSlPtqo/yafyQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gJs3fCvxU1+szeTEB70A/BkZ4OzJaKhwAVYIJc+ZQFU3/IRA7CJ0xwOSG7vxG60Xu61C4mUqYij+aI6z86ywRf22ivrxn4bLeFR/Hst968ACBjnY+Dt0QrvTM3JHTtWvayxPPURZCRr3OTkkWcS8HnPE6EyLSBu8ojp1VjKTURc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HPMODYs+; arc=none smtp.client-ip=209.85.210.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HPMODYs+"
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-6eb8ae9b14eso870527a34.0
        for <ell@lists.linux.dev>; Tue, 16 Apr 2024 07:25:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713277501; x=1713882301; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=+rWQ066RNWOEY5oDq5u+p7aNXhCkyXRm5K2HwNWwDo8=;
        b=HPMODYs+oQA1+JazPqUCMmgmlMvdSDSLnJYFAjk7Fq92qFfEbOzsYhxdBBeQToMJjs
         8f5RvAWlu+4qpKaOYGJYe1MfoVxDhgejLonvDeAD2K0fOTi8l9GZsabi1EpozVBywbbw
         vyOW0zv+AvAfc8VLZ2m8bC/tUYsbqDB5MWFPBgw3oXEBr869lW0QhZ9vOIf756ntg8w4
         xBeayWomY7tlYoFFA4WnP0H+Xnc1XkqphyFKByKMGUbgOVIGc8JDfzczEst6FIH5V02X
         y4uzJ6KRatOqgxn6ehyPbFoxh0Mdf3VDD/rG2fEbR66PL4eChFV1oMtJQIOOp01NcZU8
         Uywg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713277501; x=1713882301;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=+rWQ066RNWOEY5oDq5u+p7aNXhCkyXRm5K2HwNWwDo8=;
        b=FpWzPVlVCkjLD50364dN4NaFxKccBRV4NRi9lEA1FgmyFBSKMZn3udgwzKPXQtscHd
         hifMbOIQM3TJ2B6GMXVz1ZD6cXgXifDUawQUbaZnX/5gy5qnsLLWoSeJH2LFvZ0U0hia
         znpI53f6FshXJc+LkETbJo8rG9fsAUM3PG+R3+73s4znca6QlHsyWXkwajZaldI35S0L
         zgO3w3XnU+IvSl+i8SH0x2fmafwx1tmlnpeThitSHqOVTn98+VRnop8SgFW09IroBTZC
         4aitf/taD2NcDcOI/hxO8hV7lo45qonuOjCFJV8c4L105HsBCRk18TtGBrn0BxxkeloP
         +cUg==
X-Gm-Message-State: AOJu0YzwIG766UbCmjNM2v34a7/4lHOrCg0w3+Zq/k+kqWQzb0vkL4GM
	4o9toQ6K+waIEUgiJbYlPCkZ904gin+ljRC8S4eX5N+ya1yIa0Oo8HERTQ==
X-Google-Smtp-Source: AGHT+IEnhjSmSbx4Xu+vbnetCyn/VfyhKK+EcWlXxRZcslVXqtbNYg9LAFBCPNpPckSzk6KAuLro5g==
X-Received: by 2002:a05:6830:ecb:b0:6eb:5a72:3e57 with SMTP id dq11-20020a0568300ecb00b006eb5a723e57mr11399430otb.10.1713277501608;
        Tue, 16 Apr 2024 07:25:01 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id r33-20020a05683044a100b006eb892647dasm526999otv.79.2024.04.16.07.25.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 16 Apr 2024 07:25:01 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 2/4] util: Add L_BIT_{SET|CLEAR|TEST} macros
Date: Tue, 16 Apr 2024 09:24:53 -0500
Message-ID: <20240416142458.3353383-2-denkenz@gmail.com>
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
 ell/util.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index 237ea4824b06..ed0bbe845656 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -366,6 +366,36 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 				(__v && __elems[__i] &&			\
 				 !strcmp(__v, __elems[__i])), ##__VA_ARGS__)
 
+#define _L_BIT_TO_MASK(bits, nr) __extension__ ({			\
+	typeof(*(bits)) _one = 1U;					\
+	const unsigned int _shift = (nr) % (sizeof(_one) * 8);		\
+	_one << _shift;							\
+})
+
+#define _L_BIT_TO_OFFSET(bits, nr) __extension__ ({			\
+	__auto_type _bits = (bits);					\
+	const size_t _offset = (nr) / (sizeof(*_bits) * 8);		\
+	_bits + _offset;						\
+})
+
+#define L_BIT_SET(bits, nr) __extension__ ({				\
+	size_t _nr = (nr);						\
+	__auto_type _offset = _L_BIT_TO_OFFSET(bits, _nr);		\
+	*_offset |= _L_BIT_TO_MASK(_offset, _nr);			\
+})
+
+#define L_BIT_CLEAR(bits, nr) __extension__ ({				\
+	size_t _nr = (nr);						\
+	__auto_type _offset = _L_BIT_TO_OFFSET(bits, _nr);		\
+	*_offset &= ~_L_BIT_TO_MASK(_offset, _nr);			\
+})
+
+#define L_BIT_TEST(bits, nr) __extension__ ({				\
+	size_t _nr = (nr);						\
+	__auto_type _offset = _L_BIT_TO_OFFSET(bits, _nr);		\
+	(*_offset & _L_BIT_TO_MASK(_offset, _nr)) != 0;			\
+})
+
 /*
  * Taken from https://github.com/chmike/cst_time_memcmp, adding a volatile to
  * ensure the compiler does not try to optimize the constant time behavior.
-- 
2.44.0

