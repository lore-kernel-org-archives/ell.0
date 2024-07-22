Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA3331805E
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675089; cv=none; b=sBAiEOcd6EQK1ALQR/oQ82hKrR4kvi05fKWNdER0RzRthF+cMW5z3YIDy7xQpJsI1GiLuH4a4IJO8pV4Za/kz2MmHiDjQ2xJ8jjIWmwoqV6oBUDkmF/sZDpuRFTIq0oZnXXHkaYG5d2JgR4PugisokJ9IQvUTVJzu3SyvG5J16o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675089; c=relaxed/simple;
	bh=w4qbSYHp8xXVUkTEEC7x7Il2I0oHSu9WJc0SR+O1zcA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AnMRfArJBLA6hc5XBEDxNRQddwh20BdQgHjNYz5kTdivMCrgH6eDGEu7/lqw3YIup9N5CGbTNG1Df298R+7xufjVaGb3gC8TjFlu0pqxgtQYL3lqVQTw+b0ibaIxxo3bUSFrrkuedjoDfKo9U4UixGa5FGekmDf9p8OIYIRxbW4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=h+hT2X++; arc=none smtp.client-ip=209.85.161.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h+hT2X++"
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-5ce739c2650so2490365eaf.1
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675087; x=1722279887; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=nnVqIdf7tJti7Wkfi1ZE3c57AQfTI8UkuY4bieQ5yQU=;
        b=h+hT2X++7+os0Gx/G6BanvZeggqh4HKeYfTKp6O//RcjFjCsOleE33btCYHI6+wP1g
         s/CdwOFsh1cAr2Zpr3H4v37v4mF9e/Jo2CAV1lSR12UZJnsXqTQL2hbF4/11hAlAOYaS
         IRvfNgpPqsDfyhGW074Ar3pKQnY3LWTI/X9/VRO+joGP7c/Yr6nqZWkqsFQVu1+QUHOG
         NOTKwp47jTVQexZtQhtQOLFQNeIkIJ44h0aD/Pc0SDiAQgMtvhe4cwBwBCmDRT7YP+l9
         cBnQCFI0TPN4lLT5X8XGDZ83h6BfOyKatZpn2cUQUNNGPUfnZueQB49cbltRk1gA8faV
         LRNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675087; x=1722279887;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=nnVqIdf7tJti7Wkfi1ZE3c57AQfTI8UkuY4bieQ5yQU=;
        b=CTzsZI395sJpECmFEBkr/F3zSAF67E8IaBAvHVRW26rKSlD288f+Q1Qfb/O0TZNVml
         pQgkWhEzsU3kxsZbBxE2H+fwJTqUh4DK5OGMAJeJ3AEZF0Hfp8i88yholuN85EYgRKdt
         31aO6PpDGONG/r/tmgd+Y6SAkpYAoFGDVD2iuKz4NpP+xBpM9dSlWI9joIcjoUWeh02u
         ssG36vkr1E6myxUbgdGzrpR1PVDPwKbm+v2c9B2hxfaQnhdZzYaUvP6KzXwxeBH+Rvn1
         MsMK6octhKJ8fTN43CfugrGHv6noZOHR4m9I1UNHeYRsy9kMBrh7y5FRwBHZDO4LEA9j
         NJIg==
X-Gm-Message-State: AOJu0YwY4tkoxJiMrD+XZlduHIl/8PtOQThx3C/lFK/u7ecH+eDlaZEM
	KGjblHYrtlM4GObe8h1/v9+wMjHik7QcOwRkG93isYjj8+x85hvHdTmUBA==
X-Google-Smtp-Source: AGHT+IH62IRr/s4gWFiYoGXquf2mtMAezq954rINimCIzXwigph51thkCNQcG3WqvVtGywaDpbtuOw==
X-Received: by 2002:a05:6820:2002:b0:5ce:e851:7356 with SMTP id 006d021491bc7-5d564e1f3a7mr10208961eaf.1.1721675086882;
        Mon, 22 Jul 2024 12:04:46 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:46 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 02/12] unit: Add unit test for roundup_pow_of_two
Date: Mon, 22 Jul 2024 14:04:19 -0500
Message-ID: <20240722190443.43196-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240722190443.43196-1-denkenz@gmail.com>
References: <20240722190443.43196-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-util.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index b178b86cf489..341c790c3731 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -15,6 +15,7 @@
 #include <errno.h>
 
 #include <ell/ell.h>
+#include <ell/useful.h>
 
 static void test_hexstring(const void *test_data)
 {
@@ -270,6 +271,23 @@ static void test_clear_bits(const void *test_data)
 	assert(l_memeqzero(bitmap, sizeof(bitmap)));
 }
 
+static void test_roundup_pow_of_two(const void *test_data)
+{
+	assert(roundup_pow_of_two(2UL) == 2UL);
+	assert(roundup_pow_of_two(3UL) == 4UL);
+	assert(roundup_pow_of_two(5UL) == 8UL);
+	assert(roundup_pow_of_two(15UL) == 16UL);
+	assert(roundup_pow_of_two(25UL) == 32UL);
+	assert(roundup_pow_of_two(1025) == 2048UL);
+
+	if (sizeof(unsigned long) > 4) {
+		unsigned long l = UINT_MAX;
+
+		l += 1;
+		assert(roundup_pow_of_two(UINT_MAX) == l);
+	}
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -293,5 +311,7 @@ int main(int argc, char *argv[])
 	l_test_add("L_BITS_SET", test_set_bits, NULL);
 	l_test_add("L_BITS_CLEAR", test_clear_bits, NULL);
 
+	l_test_add("roundup_pow_of_two", test_roundup_pow_of_two, NULL);
+
 	return l_test_run();
 }
-- 
2.45.2

