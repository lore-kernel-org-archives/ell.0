Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E4951CBE86
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 20:26:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730406393; cv=none; b=TZmw8+dYMPJT7MS02k1tvSgTSmiaclPsVf3Ki6DaJRDCqNaikSLMKw65NVW7bOmaEsPZAbyTYKCY6ub/GAmkqeAenYMHfe4YWSs/Fr3yuU/pTWi+a7J4GGodyYdHdPHpcCTrG88V4eykBAx1ux3jTbWQzNfU6ZTExFaJIe+MpP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730406393; c=relaxed/simple;
	bh=kPXc+2rEvy7FUKdbptWgbIqpLFhJPt5uk7QHP0Yd6mU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ViYwUF7+vYGRspm3JkmhzXHC1Hsi6a0+YKKQs1YYqRKh49Ba7tfASnYdvDVoceCHcOU2tKffA2w3hTEif+BDSchpfTjqCFAvjgl2h8szp+hCawy8iAqFROrfADCnrGZze1WuMtEt7X6O/4I8caKJuqBqV6mH6cDwvWdwPhYOEyI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=R6omvcoP; arc=none smtp.client-ip=209.85.160.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R6omvcoP"
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-288a90e4394so672705fac.0
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 13:26:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730406391; x=1731011191; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=eJG107oWF1YNGNJmo8zEGIKAPUo8oQ5mTKAtAqPhM/E=;
        b=R6omvcoPpDvOTu/GxiI2Vj2ZeQwe34Dhd8YKRk2/GcViqkExh3jdhpvri7H5I+KdQp
         qkuk9D4WEjUvUkejRWCQNVl9Jj7R2/NWmR5IqFlt+QVMsR1lhDyYlwe1TBGWfzUxBaSM
         KDQjP/JOV0sjHrpo1NxFYqG11tpzsKIhZv/vD9WSrIgZnhL6hCYehBqz9qQoQzHiDSsU
         Pc9n2lGwyWnu+m3ZsHSAdkDSmDsvMY7+SfdRm10A/ojYdrsC/zqGJYq09Hmxwe3qcsfU
         TVPd8Yrpp5VTP5u5ScvL1TGbYEYQdenN0n4PqGxCcy5My3+hLtpCmow9eCpSqQmBF/Gl
         060g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730406391; x=1731011191;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=eJG107oWF1YNGNJmo8zEGIKAPUo8oQ5mTKAtAqPhM/E=;
        b=crAvsMnyRetl1GmNAko6OZ19WftwD65j79f9DVVgJvW+9262yDKvA/dBs6UQ2b+Yan
         UE8vyiD5z13OSZd8QDr/TfmLL+TMo87ietRXbG9prwBRNQPxRyiq2DcFxHQUzRgbRKCb
         IsyaHbI2R9x63TK5LKU61I8UTNUYk5QOHSh1ycXN8C8/7WVwqKPr2+yqZ1Rw/i/g9fxg
         EWvKGKK7fH74W4rIRV6dIlFCVP9n/vR/8MSy26kNSMwKzW49fmWHCOyLKp2TyfZ2USju
         PGVMOBr1STn8shWSC+sJ64QWE0jyDDaoxa+URsu9TLI6VnMp0lIfRsyqUMx3Is4wHbEM
         AxbQ==
X-Gm-Message-State: AOJu0Yweab/Y4B85/DgIohyrGakDdz/1S2jMfIwYfx8dsyROHrfoDP2L
	DFz8LQF8TfzVgZ1x9tPBMkJAIq6ku3ny2R0ogdVpC86ibmLlp8LVLMXzqA==
X-Google-Smtp-Source: AGHT+IEWHFxvRtUqNHdFngea/847fnLsWRvtMluTMwZJgLq5lOINIkl5MT8sV0AshgJoQnMsgYJI/w==
X-Received: by 2002:a05:6871:8116:b0:277:db7f:cfb2 with SMTP id 586e51a60fabf-29464702478mr8876593fac.14.1730406391172;
        Thu, 31 Oct 2024 13:26:31 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-294874d6687sm712930fac.31.2024.10.31.13.26.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2024 13:26:30 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v3 3/3] unit: Add l_memcpy test
Date: Thu, 31 Oct 2024 15:26:15 -0500
Message-ID: <20241031202627.1548592-3-denkenz@gmail.com>
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

---
 unit/test-util.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index 341c790c3731..27b0422200d0 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -288,6 +288,16 @@ static void test_roundup_pow_of_two(const void *test_data)
 	}
 }
 
+static void test_l_memcpy(const void *test_data)
+{
+	static const uint8_t src[] = { 0x00, 0xff, 0xff, 0xff };
+	uint8_t dst[10];
+
+	assert(l_memcpy(dst, src, sizeof(src)) == dst);
+	assert(l_memcpy(dst, src, 0) == dst);
+	assert(l_memcpy(dst, NULL, 0) == dst);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -313,5 +323,7 @@ int main(int argc, char *argv[])
 
 	l_test_add("roundup_pow_of_two", test_roundup_pow_of_two, NULL);
 
+	l_test_add("l_memcpy", test_l_memcpy, NULL);
+
 	return l_test_run();
 }
-- 
2.45.2

