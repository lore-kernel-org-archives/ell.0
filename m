Received: from mail-qt1-f180.google.com (mail-qt1-f180.google.com [209.85.160.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6467927705
	for <ell@lists.linux.dev>; Thu, 12 Oct 2023 13:38:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NxqsFoOc"
Received: by mail-qt1-f180.google.com with SMTP id d75a77b69052e-419c16a4209so18013581cf.0
        for <ell@lists.linux.dev>; Thu, 12 Oct 2023 06:38:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1697117898; x=1697722698; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=muuUICZAQgnlOaOeJj6IONQxzjiihyFPKmbzParOzeY=;
        b=NxqsFoOcaPEJp36LLVgORqTggXbjbsjkI454eUdImY5M213XeJUXLaOnVrNecfJbNY
         YlCYTOKpOkV/kHLoZDLwGnnqxSBqCfIWMNkGeEvZi1MWfSSa86zRRlJGRyC+QpOqmciq
         51clPylQkBwKGpraU1C4BPuVY2WDEuOzbcwxF2aVQdwvVboR8x+/yPmQXQyNcqxi16wK
         X9S3fsifm+RmD7LO/KM2OdOkABLBLS1Sx+tE/9n+cI9FoPiPUy6lKYefyBz8Hp3Ofd09
         OtUixYOf03875wfac9uoTBjiCqPWh2BNYIVEyHGSiKZ9DV1lUdyyPvUmOSY+5gRdEr9/
         U71Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697117898; x=1697722698;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=muuUICZAQgnlOaOeJj6IONQxzjiihyFPKmbzParOzeY=;
        b=AEDmkbFiHGuV62FqLaGAVVuleNYhjw8yVnyfCf47m1fi3nC26VXvRkAiBIbYHAxLSD
         7ah0+Ph4eiYKTE2dUIpsw9VjpUfwnnFDlOriqsYwTah5jMdZDNU/vwV/7wSqu49fDPzS
         IQeEjEtgWuJPutY+bG6UrIQGySC+rd4kk9Uq7EvLA1+Sv7FKf8GCKvVg+EH6xHseQvHX
         k+VTP+zIg0FhOU8sYBo/eAt6bjdunOyyisehUMPTOL0gCWJLF9QUESrZWg3LyynNa6RA
         fvDAVzMquwmvVv+D/3UOhgCOn0n2gncqMu3AZkdEOHtseO9qUAkE3syIynaAAlvgpOwD
         Wjxg==
X-Gm-Message-State: AOJu0YxkICBbKUt9z9gjBwnhfqFbqjfEhPX1mwbGYkTmK52q1IZcc4Lp
	zasiEokzgmI4U9v6ukd5do1fGReQSIA=
X-Google-Smtp-Source: AGHT+IF/Xa4n+jG+TNilWF4QgPwLtitQYv04hw919oVYjBy45X2pFigBMg64Bqna1kzWfvwjYdkzAg==
X-Received: by 2002:a05:622a:1996:b0:417:a13f:224b with SMTP id u22-20020a05622a199600b00417a13f224bmr30428833qtc.23.1697117898136;
        Thu, 12 Oct 2023 06:38:18 -0700 (PDT)
Received: from LOCLAP699.rst-02.locus (50-78-19-50-static.hfc.comcastbusiness.net. [50.78.19.50])
        by smtp.gmail.com with ESMTPSA id l17-20020ac81491000000b004181d77e08fsm6181908qtj.85.2023.10.12.06.38.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Oct 2023 06:38:17 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] ecc: add l_ecc_point_is_infinity
Date: Thu, 12 Oct 2023 06:38:12 -0700
Message-Id: <20231012133812.139893-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When creating a point from raw data the validity and if
infinity is checked but there doesn't exist any way to check
a point for infinity after doing some arithmetic on it. Some
specs requires a resulting point be checked for infinity.
---
 ell/ecc.c   | 5 +++++
 ell/ecc.h   | 1 +
 ell/ell.sym | 1 +
 3 files changed, 7 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 73ddb96..518f405 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -1026,3 +1026,8 @@ LIB_EXPORT bool l_ecc_points_are_equal(const struct l_ecc_point *a,
 	return ((memcmp(a->x, b->x, a->curve->ndigits * 8) == 0) &&
 			(memcmp(a->y, b->y, a->curve->ndigits * 8) == 0));
 }
+
+LIB_EXPORT bool l_ecc_point_is_infinity(const struct l_ecc_point *p)
+{
+	return _ecc_point_is_zero(p);
+}
diff --git a/ell/ecc.h b/ell/ecc.h
index 981bf95..2c2c73a 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -114,6 +114,7 @@ bool l_ecc_scalars_are_equal(const struct l_ecc_scalar *a,
 
 bool l_ecc_points_are_equal(const struct l_ecc_point *a,
 				const struct l_ecc_point *b);
+bool l_ecc_point_is_infinity(const struct l_ecc_point *p);
 
 #ifdef __cplusplus
 }
diff --git a/ell/ell.sym b/ell/ell.sym
index 7b5caa1..84c45b1 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -594,6 +594,7 @@ global:
 	l_ecc_point_clone;
 	l_ecc_point_get_curve;
 	l_ecc_points_are_equal;
+	l_ecc_point_is_infinity;
 	l_ecc_scalar_add;
 	l_ecc_scalar_free;
 	l_ecc_scalar_get_data;
-- 
2.25.1

