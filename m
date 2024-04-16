Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D84F132489
	for <ell@lists.linux.dev>; Tue, 16 Apr 2024 14:25:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713277505; cv=none; b=TCviZ0Zhu8aJ9ijXbH/0WZKCnJZvO5XvOs1r/3R2zdYk0NPwGUg3bJk5GImUcOud+OUU8fmltAEMNAqEK44YSAPizHuNKe6KkqsRLvvlxyeTa5squ8EJcZnd1p2nO2r/AxXFG4+BIyIUlcVm4RJuIUOkVcA6m3GD5HpT5jcuQQA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713277505; c=relaxed/simple;
	bh=Ryn63rGfHAomvx3udqLVIkIHeXBulDtGuOGCDufvJGE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GNVlw0CHPrAN23NJCaxc8Jxlvf+SGHBSfu4uIcMTO47P51yiCZtfr4+Dr8T1H5wtFYE6DWXVtaG80VUCe9d/8zhI+DOwUyVnZF/x9R3miQTO2p4T6MsRUz9irgXLOFzZb/6X5Ebbhei0K9RJIzTVCmwmT1thd3BIVVCKq7wcENA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fiLA13Dt; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fiLA13Dt"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-3c5ed7fdbb1so2958966b6e.0
        for <ell@lists.linux.dev>; Tue, 16 Apr 2024 07:25:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713277503; x=1713882303; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=lFmR3yMaN22EiDkIkEHWYWMk2s1k0kUvlvYOigLAYJo=;
        b=fiLA13Dtt5alfcmvVBA654DG1lRU75NZPaEX74nf4m/rGCxiXdqSpCxUrsmSD9TYf/
         uxW1MRKWCHp8bBH/g/6XogZZ0Hy1AYT1f+bSbzLGFV23n87YVWApmx4IpphkKUESGF9E
         OTdKLaR8/0Mfv/MTvPehS+S7jfjjjKfHfIe4MjKtiIOchNatefeOppDs1yIO9tjsKTXG
         pYpRN5YdYIQ76P2IUg+LYng8N+SjCjDrZ85a6EccuCcUGMP8HHQHBUrmR6sGZLmvOPIx
         cowBahfr6rlwDAfYBiSJgc2ad4aPa6Ts1ZM63LAlbPoWRlAIyBAP16MsDQ5MYV+aVVr9
         cEdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713277503; x=1713882303;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=lFmR3yMaN22EiDkIkEHWYWMk2s1k0kUvlvYOigLAYJo=;
        b=hMEj7Ia22hcgsEqY3Oid3Qu59Q59z2jUtHhCjbE6hnUDS1CCvpKYCq+1myokAi2vnv
         9af62mzko1rCnk3oMz2HRvG9wjXO7SLuUzCW9OzpVH3hZV165Rhbhf7dARzoT4LGhDlC
         QqmPWosqcECYlVl6kR9IBRdH8iWYSXjhXN8kVrxbcWzCahDeVy3+K77lpjO6OZSuCMYO
         kjd9S44oYekjI6bSn3oxU0zi95w7+/uk1K4nbjQCqEhQmhihOSXErfileHnVGrjRTQfG
         3em6aiyuGvx//OoJdFGGu5aE6h7CrGnaK2UmiHY5Iel5xTOG76MZhEEteTvZ8IuskC/l
         x+3w==
X-Gm-Message-State: AOJu0YwH6yzu7VGJCTgtenXQ7tZDQVCSon3cW3n8zYUDY2eCU5pa0xie
	kNVNkiy20VgeOAntc3uv97Z2v4LwMotNqjlWdtfv1/AXElVm9TlsOPkgcQ==
X-Google-Smtp-Source: AGHT+IHYwl/wWSIgQBiKF6LhklpCMKyt7yJpW0BPnFQOvxl9nk9zcuizFncNV6hE8/C13DcyhbWeIw==
X-Received: by 2002:a05:6808:3086:b0:3c7:2066:8f8c with SMTP id bl6-20020a056808308600b003c720668f8cmr1039022oib.2.1713277503048;
        Tue, 16 Apr 2024 07:25:03 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id r33-20020a05683044a100b006eb892647dasm526999otv.79.2024.04.16.07.25.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 16 Apr 2024 07:25:02 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 4/4] unit: Add tests for the new bitmap utilities
Date: Tue, 16 Apr 2024 09:24:55 -0500
Message-ID: <20240416142458.3353383-4-denkenz@gmail.com>
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

---
 unit/test-util.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index f7a895f911d5..b178b86cf489 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -195,6 +195,81 @@ static void test_safe_atoux(const void *test_data)
 	assert(l_safe_atox8("0xffff", &c) == -ERANGE);
 }
 
+static void test_set_bit(const void *test_data)
+{
+	uint32_t bitmap[2] = { };
+	int one = 0;
+
+	L_BIT_SET(&bitmap[0], 0);
+	L_BIT_SET(bitmap, 1);
+	L_BIT_SET(bitmap, 2);
+	L_BIT_SET(bitmap, 3);
+
+	assert(bitmap[0] == 0x0f);
+	assert(bitmap[1] == 0);
+
+	L_BIT_SET(bitmap, 63);
+	L_BIT_SET(bitmap, 62);
+	L_BIT_SET(bitmap, 61);
+	L_BIT_SET(bitmap, 60);
+
+	assert(bitmap[0] == 0x0fU);
+	assert(bitmap[1] == 0xf0000000U);
+
+	L_BIT_SET(&one, 0);
+	assert(one == 1);
+}
+
+static void test_clear_bit(const void *test_data)
+{
+	uint32_t bitmap[2] = { 0xfU, 0xf0000000U };
+
+	L_BIT_CLEAR(&bitmap[0], 3);
+	L_BIT_CLEAR(bitmap, 63);
+
+	assert(bitmap[0] == 0x07U);
+	assert(bitmap[1] == 0x70000000U);
+}
+
+static void test_is_bit_set(const void *test_data)
+{
+	uint32_t bitmap[2] = { 0xfU, 0xf0000000U };
+	uint8_t one = 1;
+
+	assert(L_BIT_TEST(&bitmap[0], 0) == true);
+	assert(L_BIT_TEST(bitmap, 1) == true);
+	assert(L_BIT_TEST(bitmap, 2) == true);
+	assert(L_BIT_TEST(bitmap, 3) == true);
+	assert(L_BIT_TEST(bitmap, 4) == false);
+
+	assert(L_BIT_TEST(bitmap, 63) == true);
+	assert(L_BIT_TEST(bitmap, 55) == false);
+
+	assert(L_BIT_TEST(&one, 0) == true);
+	assert(L_BIT_TEST(&one, 1) == false);
+}
+
+static void test_set_bits(const void *test_data)
+{
+	uint16_t bitmap[4] = {};
+
+	L_BITS_SET(bitmap, 0, 1, 16, 32, 48);
+
+	assert(bitmap[0] == 0x3);
+	assert(bitmap[1] == 0x1);
+	assert(bitmap[2] == 0x1);
+	assert(bitmap[3] == 0x1);
+}
+
+static void test_clear_bits(const void *test_data)
+{
+	uint16_t bitmap[4] = { 0x3, 0x1, 0x1, 0x1 };
+
+	L_BITS_CLEAR(bitmap, 0, 1, 16, 32, 48);
+
+	assert(l_memeqzero(bitmap, sizeof(bitmap)));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -212,5 +287,11 @@ int main(int argc, char *argv[])
 
 	l_test_add("l_safe_atoux", test_safe_atoux, NULL);
 
+	l_test_add("L_BIT_SET", test_set_bit, NULL);
+	l_test_add("L_BIT_CLEAR", test_clear_bit, NULL);
+	l_test_add("L_BIT_TEST", test_is_bit_set, NULL);
+	l_test_add("L_BITS_SET", test_set_bits, NULL);
+	l_test_add("L_BITS_CLEAR", test_clear_bits, NULL);
+
 	return l_test_run();
 }
-- 
2.44.0

