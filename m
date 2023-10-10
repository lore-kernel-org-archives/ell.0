Received: from mail-pf1-f175.google.com (mail-pf1-f175.google.com [209.85.210.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0B9F24C84
	for <ell@lists.linux.dev>; Tue, 10 Oct 2023 14:25:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qk62IS0e"
Received: by mail-pf1-f175.google.com with SMTP id d2e1a72fcca58-690d2e13074so4307690b3a.1
        for <ell@lists.linux.dev>; Tue, 10 Oct 2023 07:25:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1696947911; x=1697552711; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=TlB5Opm27y3wLoq/Kwp6zGru9/r+MKNDjqBGleXpk3k=;
        b=Qk62IS0e8qfjBz1+7fPO8UY1u+eSs4bHqc/i8w6siHx3EDHowM4Kw8e0JfqWRBpQX6
         Zm5BZWPPx7b8jbwr3G0Q9uqB4goIsLZqiaZPPl0FTIbJymhHGfu/HO7GTC/wefAYiFPK
         jfb4UyX0g5jPIULlpfknRuUDBBx8t/fRJywUmJ5Tn98s8C479aYsD5Mc9LDCS5ud7vS6
         4gcuuN3hALj3iyN9HIOW+qFKFxs6BNQz0nuyTYsBvXPltmP3cSPDx9kLBccOf4nBrkAF
         r0P29MNitJFvKqkdJMhnQ7q9ylD7JmZIkHZr2pegDiOXLzGlRx5FD00QwlORsWkYZF0U
         9AAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1696947911; x=1697552711;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=TlB5Opm27y3wLoq/Kwp6zGru9/r+MKNDjqBGleXpk3k=;
        b=jKvGJNfoptzqo0jV9cAgM1Y41IoP8CQtpmhOAUKFW2Ua4SztSGXG/sU8dmvMOoYluU
         E1pqPn1Ou4eMQwVxqxZPYnRUbExXicNQQJwwOGzuUlH/A8SAGSB5vT+vyd9W3Ttyq6BX
         s+uD9HfoKV3IYb00iw9QGs+If1ZNSJHWA4a9wDL2gJiyLhVyqL+6lIpzFrjk2/MxkCOj
         2w8SLd7VxlOBuYXAhkqonAqGfseDanrpxkp6Jnx13esw2be4F8IlH4ZFhNzbmJ7ASIqS
         OSp9sB2wHIE3F3uRe9cUmFbmdNg+4Au7KnrtHusqA68geR+zAiLZZpUzKzA4r8j9nZyr
         JbLw==
X-Gm-Message-State: AOJu0Yy8nPQJXt4Qqe3Qpbr1uXuxizX0RH3nGU3gj7yNd0EAgaxGp18X
	GdoY/rxJywewl4jymy9oXly2pKm8LS0=
X-Google-Smtp-Source: AGHT+IFcy8X1IyD6EKHjaJP7uvB8AFGoX4w2UP0/hXhnUuIymBUkjzQP8CTaCswMa9v2i8ZheajjTg==
X-Received: by 2002:a05:6a20:3d85:b0:16b:e89b:fb11 with SMTP id s5-20020a056a203d8500b0016be89bfb11mr10622818pzi.56.1696947910844;
        Tue, 10 Oct 2023 07:25:10 -0700 (PDT)
Received: from localhost.localdomain ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id z9-20020aa785c9000000b006926e3dc2besm8348563pfn.108.2023.10.10.07.25.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Oct 2023 07:25:10 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 1/2] ecc: fix incorrect derivation of compressed points
Date: Tue, 10 Oct 2023 07:25:05 -0700
Message-Id: <20231010142506.261152-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The logic was inversed here and was performing a subtraction if:
 - Y was even and type == BIT0
 - Y was odd and type == BIT1

This is not correct according to the ANSI spec. IWD relied on this
API but had matching incorrect logic so things "worked" up until
a compressed point needed to be parsed from an source that
explicitly specified the type (e.g. an ASN1 DER in DPP). All other
uses (PWD/SAE) the point type was only used to force a subtraction
so since both locations used the incorrect logic the points would
compute correctly.
---
 ell/ecc.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 98ef812..73ddb96 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -562,8 +562,24 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 		if (!_ecc_compute_y(curve, p->y, p->x))
 			goto failed;
 
+		/*
+		 * This is determining whether or not to subtract the Y
+		 * coordinate from P. According to ANSI X9.62 an even Y should
+		 * be prefixed with 02 (BIT0) and an odd Y should be prefixed
+		 * with 03 (BIT1). If this is not the case, subtract Y from P.
+		 *
+		 * ANSI X9.62
+		 * 4.3.6 Point-to-Octet-String Conversion
+		 *
+		 * 2. If the compressed form is used, then do the following:
+		 *     2.1. Compute the bit ~Yp . (See Section 4.2.)
+		 *     2.2. Assign the value 02 to the single octet PC if ~Yp
+		 *          is 0, or the value 03 if ~Yp is 1.
+		 *     2.3. The result is the octet string PO = PC || X
+		 */
+
 		sub = secure_select(type == L_ECC_POINT_TYPE_COMPRESSED_BIT0,
-					!(p->y[0] & 1), p->y[0] & 1);
+					p->y[0] & 1, !(p->y[0] & 1));
 
 		_vli_mod_sub(tmp, curve->p, p->y, curve->p, curve->ndigits);
 
-- 
2.25.1

