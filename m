Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0C1C155A56
	for <ell@lists.linux.dev>; Mon, 15 Apr 2024 19:14:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713208501; cv=none; b=BHOtAllR4UcXiUzbC2rmMtO/hji/AblD8zfR+9FAXR0yBbiw3LJ/t62UuTjzTZdJoKeYFQqitHU3CBXSvc9K1DxcWykc6b25pvfcYPtdqDMt/l0W6/ybi+oLBmonu5JwV9DDd8Bc+QNI1Ydr7bHFDawwJn2PggPGRlDteDC7qXI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713208501; c=relaxed/simple;
	bh=BedpNYth8Yhlu6kw2fK5DRRsEaW6up9cmeBc+vkds2M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=g/Is0T2xexPll67lVW5KuzqidfKS7durzTx5iPceDp4hcVkEPH9233o5oPTXezo8NvcnjzhM1TwOvndDW1E0oEj/355vO6LxXMxu1YFyje0fUSOVsvm0wgau9y9h5MB+xGoQ/LMmEGd3X6MAbELhzW5TcXK4ir32b2RAgt1drm8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TSNJK9a8; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TSNJK9a8"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-6ea156bee62so1474620a34.0
        for <ell@lists.linux.dev>; Mon, 15 Apr 2024 12:14:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713208498; x=1713813298; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=hcXbxCazyvp8pYGsZSf1RhXr8bFq70dKEKToGtuxJ6o=;
        b=TSNJK9a8VOeFJbXhhjFcz39FpoE31oUP3l6dMy2CMCqFYf3m9gtMa34f9yJjQ6+xDu
         M4DdMgr9GWRsj5GRrkGsc8qclkBbp+3xKG7UsulbVw4ArVbGdeRr7fcKeL2panQejItO
         p/mX9wg8AfAKkNaOyRTgz1B7+sCpIG7QNlGLgheGb1Cl/+Q1Q02zvVOBMvBz8/yng93Z
         DcUcWiBgwKB145/zfRzjsTC6h0JnNY3MiL6FlrweY4YKFs4nZbwwzEt988Xy4D9Votdj
         ua1AVMWxYNsVHXHxrDlWaNf5F71v4oxyneklKi6ZcFQ2ZQla22e7q4YMTRfu0i4gc5bS
         Y8aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713208498; x=1713813298;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=hcXbxCazyvp8pYGsZSf1RhXr8bFq70dKEKToGtuxJ6o=;
        b=fFP93GRVshiyhw3ppme460sHk9HcxrrpIatmb6XHS8p91TZGyMQlsvvkrROlXpJMqZ
         7W0NcmPTbUz+SjtX2UivbnztcPWAW5VvQ6cvopU2oX1pYcQhJUOik8INXjFEyj9T0OHU
         r8jdd3EiaPh+UrYtJzBEUQ82g1SeC0SfSS1A1W4FyiJrIqMakcCyuVk/R7zyDAEm43wY
         WtxvNqU5+BSyJuKxW6X7WZFLsfwWaHcBXLX6xEsoNXeUkW5aAtRnVrxIEevJTYk5+jVk
         7R+u4fHfZt/cwUbZutmZwfDo0hDKrAgvEEPXZkoMUXNQFwVx5On140m9mgEywIxCmAdN
         xpoA==
X-Gm-Message-State: AOJu0YwAJo6d3nLc2np26ErY3rXklytrj3ocUi2fNN2IaFe6groCokBa
	mQo/DMbnR4HGpLC/eSCcQO1RO6o7cCBzyGRFAonsgx70E3lCSL0jMC9uig==
X-Google-Smtp-Source: AGHT+IEqVSJyZ06C9pfC7/+wDS2205gtONQC+mpw0L+y4HSGRuLJxgvg3Spomul7uCLEtYPZxWQU1w==
X-Received: by 2002:a05:6870:d8d1:b0:22a:7d7:1007 with SMTP id of17-20020a056870d8d100b0022a07d71007mr222325oac.5.1713208498494;
        Mon, 15 Apr 2024 12:14:58 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id w8-20020a4ae9e8000000b005a586b0906esm2206526ooc.26.2024.04.15.12.14.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Apr 2024 12:14:58 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 4/4] unit: Add tests for the new bitmap utilities
Date: Mon, 15 Apr 2024 14:14:36 -0500
Message-ID: <20240415191454.3259243-4-denkenz@gmail.com>
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

---
 unit/test-util.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 81 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index f7a895f911d5..14724f2a608b 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -195,6 +195,81 @@ static void test_safe_atoux(const void *test_data)
 	assert(l_safe_atox8("0xffff", &c) == -ERANGE);
 }
 
+static void test_set_bit(const void *test_data)
+{
+	unsigned int bitmap[2] = { };
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
+	unsigned int bitmap[2] = { 0xfU, 0xf0000000U };
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
+	unsigned int bitmap[2] = { 0xfU, 0xf0000000U };
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

