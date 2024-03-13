Received: from mail-yb1-f173.google.com (mail-yb1-f173.google.com [209.85.219.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57A2A52F8C
	for <ell@lists.linux.dev>; Wed, 13 Mar 2024 16:44:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710348273; cv=none; b=c8mtXMVM00KOHza7jOFH7ORUaBMdp8G5VP6Rty23uG6FtsTNb4H23X9vPvQIHT0vCtoaxs/utTBRMXj5vokxq7po54Hf2Ww5CVLLcm0KcQee0JsuS5mnKXb1KBx5uTwyiocmifs0OInJMmWV/I2irD8v3fypfoEyEVYnlpTQSso=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710348273; c=relaxed/simple;
	bh=NmPcV0LtNhooT/Lh3f/5xtp7DU+wZJzq6StyKKXY6r0=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=IUNLarkgvfIm+ZWBO35eNiuIKGXUARQ92FBaCwosvKheEPAt6Ovdmw0ZLD1nce1bNNdSD/ovarpRR6vhtqkYEX2gs2OGEezGS3cioyltSVT32DeyI5NANtiGnkGVD9IroLp2aytAVl5RLxii4LhsKOYStqV4MJX1RE9IrbVv7iQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=VbygYukp; arc=none smtp.client-ip=209.85.219.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VbygYukp"
Received: by mail-yb1-f173.google.com with SMTP id 3f1490d57ef6-dcc4de7d901so5953182276.0
        for <ell@lists.linux.dev>; Wed, 13 Mar 2024 09:44:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710348271; x=1710953071; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=YlASbhpmQoNlznSBDtwXQ/paJD8mwd8pzXk6ccrrLwU=;
        b=VbygYukpdS0YphlL203Cgwvl9UNXFPaHebi8pfGWbyQggYRmOAq3vwTfuhUk9NL7mb
         mwCgkqrCSZmwgb3KoA78rhFh2qRektToonmT1uCZK1D0RtZf6MKdyYy1wpWdeZMB8HkM
         3HRGXqsgrRRDPrEFhMVLzX7lDODs/RS6mpokAzl0B37eMdJGb+0EyYQA41PzwKVkJGKX
         tl2PmGT/MbkjCCcyyFTOTI9KHRe6YmI5iy+mdYxcz+d9pmiexd8qApvt9bqpByJCYkKc
         OM+mwa1e6zy7kDKxp37+qAUYK0JnL9Wqi3IGTkEXvtwhjjmrkSbFoFXJTBGdaPxDLjHr
         /9ww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710348271; x=1710953071;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=YlASbhpmQoNlznSBDtwXQ/paJD8mwd8pzXk6ccrrLwU=;
        b=Rs9m2SjD4SdpIquYsgo9T40b0ncGH1Ez7FqTBV4cqHoYvBft6grJTN1270VSu1COOT
         dYkLyyCWXfIjbvoRgPLsFt2MwKq44C+JQMWHvNfZAe47MMEg+aDvo6VvqnbRJj/q9ch6
         Y4uG0/4U0H3hpEABFmhnHxsu3+igwX3hcZCC3oBKMt/wNT2lKbIQHgaFYiZXxrOz1jRj
         YYRhiTf1YTOSQaBAENO8A3K9kdmeDiVQwVYmxXBwcKA5JsILiTUpvobVyMN57/pVsSMO
         0asqA0izrHLGyMnrcowv1ardCTAMMPqwrsQfGct8UVvYkjMqi/0TCOdXs3aU8Gv5fRmq
         JWCg==
X-Gm-Message-State: AOJu0Yz0YSl8SRkc39AiDtyCF8ls2D9wmnRl3os5TOWa1RgFBORaL6r4
	g39ZSX5Uczet9gaQQ4Z/qLIKX+uL2MKQGKedmhPeTv1s6/LdHKxqvEO/NODA
X-Google-Smtp-Source: AGHT+IFo7mW4blmVxnLEwiTq7k8ZAon87KgyZ3enRTKT+qQSjTVlN1Y9H2LYm62EyijBmaMZm+n/Ng==
X-Received: by 2002:a25:ac4b:0:b0:dcc:5f1b:cc4f with SMTP id r11-20020a25ac4b000000b00dcc5f1bcc4fmr2813678ybd.6.1710348271167;
        Wed, 13 Mar 2024 09:44:31 -0700 (PDT)
Received: from LOCLAP699.rst-01.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id g1-20020a25db01000000b00dc6c58ae000sm2332549ybf.16.2024.03.13.09.44.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 13 Mar 2024 09:44:30 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] ecdh: add unlikely() check for NULL parameters
Date: Wed, 13 Mar 2024 09:44:25 -0700
Message-Id: <20240313164425.690572-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240313164425.690572-1-prestwoj@gmail.com>
References: <20240313164425.690572-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ecdh.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/ell/ecdh.c b/ell/ecdh.c
index 568b599..e10a7d4 100644
--- a/ell/ecdh.c
+++ b/ell/ecdh.c
@@ -16,6 +16,7 @@
 #include "ecc.h"
 #include "ecdh.h"
 #include "random.h"
+#include "useful.h"
 
 /*
  * Some sane maximum for calculating the public key.
@@ -41,6 +42,9 @@ LIB_EXPORT bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
 	int iter = 0;
 	uint64_t p2[L_ECC_MAX_DIGITS];
 
+	if (unlikely(!curve || !out_private || !out_public))
+		return false;
+
 	_ecc_calculate_p2(curve, p2);
 
 	*out_public = l_ecc_point_new(curve);
@@ -77,6 +81,9 @@ LIB_EXPORT bool l_ecdh_generate_shared_secret(
 	struct l_ecc_scalar *z;
 	struct l_ecc_point *product;
 
+	if (unlikely(!private_key || !other_public || !secret))
+		return false;
+
 	z = l_ecc_scalar_new_random(curve);
 
 	product = l_ecc_point_new(curve);
-- 
2.34.1

