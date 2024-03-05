Received: from mail-pg1-f180.google.com (mail-pg1-f180.google.com [209.85.215.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC12143AB0
	for <ell@lists.linux.dev>; Tue,  5 Mar 2024 13:28:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709645294; cv=none; b=HJ+WOkdKnNisNHgvouQfRNHH50QerG+v8JvF5/8h0haRxZvWneASQriS8hE3YBVEtOsRdpAdzHgSwi45T4TOXbSO3L91bJvKyBoJ+lxcFE1gZFWwmO98BmuX8hOb9YPsobvx8B/hy5HVvWkG9wj1z2fj8xQGddjaf65rmPDfkek=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709645294; c=relaxed/simple;
	bh=yCWhT5NTafTYE8AySuKCpzd30IKukbH6ryhlLhZiaK4=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=KWn1oS6MyIgo4OG7LtPlMeplvoHpbTIsLjD/omCMJI+jh32tqbwtEgifvRxcaTaOOwBLDD0SLljauHZ9eCoNI6Zx/hjzYkduNBxi3YeB7v3hzyWtfkXJuw1GSSRK0OPgwnpjLt57nGr5RD46kz+2BpYaqpdaTUFzgVgObJeT2uc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TyECrtNx; arc=none smtp.client-ip=209.85.215.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TyECrtNx"
Received: by mail-pg1-f180.google.com with SMTP id 41be03b00d2f7-5ce9555d42eso4854527a12.2
        for <ell@lists.linux.dev>; Tue, 05 Mar 2024 05:28:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1709645292; x=1710250092; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=F7RSJaeD29eME/PytTf73LOaZS9v5mTgYH7ZOhz1hCo=;
        b=TyECrtNxh/WQBMPLiLebJ5j85dVHhjvF2eAn1WV5/NV9Fnoo5O2pwkdiMwW9JoNJ/6
         9IqlvQq9pqGfrITi6P24zAh6aeojtA26buZO7Q4SESxh44TKX9LL9Bm+h6i8wXnfviof
         N9ngnsrJ20itECJnldSz6tS48Ds+xEUtDiy2npUdJahtdvCl5yrhbkzwUWeHctJisoP1
         mkjZeiI1Z4RxEC5CWFc050obbyka/c7lMRcayFxwKlr/CQGpftf8L+7iagSDfB8HTKcX
         m13H2CRIqJaJPej/kLMA4t9vmsfC8E0O8vk5CT+K+gQvp5xHJcU3a20S5AzM6ncXN602
         PSmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709645292; x=1710250092;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=F7RSJaeD29eME/PytTf73LOaZS9v5mTgYH7ZOhz1hCo=;
        b=wL9a1Tg4Q9fGvnNlsfEF6F5jjJfJrJDQoStTygnX8KL6Yhhft23sDbmr8P7q18z0vL
         W9l9UDHij6VPkr9vr/QPr3Dl4qtXNU4XYI04NI1sDBJzRx/Fk5qCjjqrHIlmssotoEst
         siLUGCaTC8awgkxUgxbBlt2ZfrbvMoczTiP/kfbDfvuY2lmNk7xFw2NWLNJWkwVS42g0
         YQesaKDsppYhnQlXEhkbOsh6T/BQa8eGNZ5HN8FkwazYN1/U8ftYmmBur+Taa7YCjjSQ
         VFZfyiZtfrm+BsAMQ0LIQ8UQFNRPd6trs9P10eu9uQ3lCU49bnKunSkS6iPKnoPi7RJr
         eSvA==
X-Gm-Message-State: AOJu0YwddGjW6pSynUMTtkh/irAQzcj4xdzuR0pbBM/bUtlDKwPFClqk
	tfuFDfhZe0/vRGRVfcdzJy/h3MvQgABsZ7Q5Xyi6ElhqL123G3poFuo7ie4V
X-Google-Smtp-Source: AGHT+IFjak7Yiz2LUIl37BdZ1TIB1g435n4M9xtZ7Ea+liVaNqMc3ST6U8u+DQjm4zIduF6DNQkI6w==
X-Received: by 2002:a17:902:a503:b0:1dc:c59d:5dde with SMTP id s3-20020a170902a50300b001dcc59d5ddemr1900503plq.59.1709645292020;
        Tue, 05 Mar 2024 05:28:12 -0800 (PST)
Received: from LOCLAP699.. ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id 4-20020a170902e9c400b001d7252fef6bsm10489493plk.299.2024.03.05.05.28.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Mar 2024 05:28:11 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 5/5] unit: assert return of several gvariant-util calls
Date: Tue,  5 Mar 2024 05:28:07 -0800
Message-Id: <20240305132807.85724-5-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240305132807.85724-1-prestwoj@gmail.com>
References: <20240305132807.85724-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Caught by clang static analysis, there were several calls where the
return value was unused.
---
 unit/test-gvariant-util.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-gvariant-util.c b/unit/test-gvariant-util.c
index 7b2e860..9a7a5df 100644
--- a/unit/test-gvariant-util.c
+++ b/unit/test-gvariant-util.c
@@ -644,6 +644,7 @@ static void test_iter_variant_2(const void *test_data)
 	assert(ret);
 
 	ret = _gvariant_iter_enter_struct(&variant, &structure);
+	assert(ret);
 
 	ret = _gvariant_iter_next_entry_basic(&structure, 's', &s);
 	assert(ret);
@@ -1047,6 +1048,7 @@ static void test_iter_header_1(const void *test_data)
 
 	ret = _gvariant_iter_init(&iter, NULL, "a(yv)", NULL,
 					test->data + 16, u);
+	assert(ret);
 	ret = _gvariant_iter_enter_array(&iter, &array);
 	assert(ret);
 
@@ -1308,6 +1310,7 @@ static void test_builder_fixed_struct_2(const void *test_data)
 	assert(ret);
 
 	ret = _gvariant_builder_append_basic(builder, 't', &t);
+	assert(ret);
 
 	ret = _gvariant_builder_leave_struct(builder);
 	assert(ret);
-- 
2.34.1

