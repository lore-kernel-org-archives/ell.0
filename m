Received: from mail-pl1-f179.google.com (mail-pl1-f179.google.com [209.85.214.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE2101DFF9
	for <ell@lists.linux.dev>; Tue, 10 Oct 2023 13:56:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cl1Ggd3D"
Received: by mail-pl1-f179.google.com with SMTP id d9443c01a7336-1c5cd27b1acso44686025ad.2
        for <ell@lists.linux.dev>; Tue, 10 Oct 2023 06:56:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1696946208; x=1697551008; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=TlB5Opm27y3wLoq/Kwp6zGru9/r+MKNDjqBGleXpk3k=;
        b=Cl1Ggd3D/NIL4nh0YDv5VpbDkNwfYxjXAz3XtT1xPW8URzr9sGkFrl9QqERRYc/qu0
         shHjkW2+9MstbiC8uXAMnBfAaEnVNp1eIpOHXd7tubcb/GrLSkXZ4ZWAMELHUIRyPoC5
         j50KNFtt7fYG3mNNnDO+QGxsFlEoXcl+UVuue4tg4kws8Nl4zs+U9Or6yI22YOsJDQ30
         YvV+8XWJDArB0aaCdqGDzpLuxP0e8Kuh9YvUjGTZZ4j7co1h2s94DOmhvcw7HjMyospj
         Dnx/lyqhr+78o7F32eTKw4ip+GkImcsq5G5YSFI06JEoLg1QOeCXgYRpwlUMf9Pjn2uv
         NYFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1696946208; x=1697551008;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=TlB5Opm27y3wLoq/Kwp6zGru9/r+MKNDjqBGleXpk3k=;
        b=ANz2of5gTUXfGJjHVBPnUl6AA5o4mwM1SKK0+wzbI20asrYLVYvw9fiX2Flb7TUaxW
         cCRIYA1qJ+L99Je0HP+JOtaAtHR4eyYeLbsaljicrfXKmb6VLnEYRWOeJ//vkEIF/q1j
         pdlCh6/SvvLdCtV4EnR2divGTKt9zQl57oVNO1U+1vdKpW+Ue7CMfL+TnlSv1GuuGbtX
         dYI4YvRwtWV46em6F6fjpZgOgltKtamBiQIjTOFzvyOUZdkT5EjuYBYcxbHcDTDfEyqQ
         7EsUnSspkyMzkT8rSCeYU4Rt6op4X8gQSd2FMZjHi2mUxxz6bNbK40ZbdhzyIswkfCxI
         wnsQ==
X-Gm-Message-State: AOJu0YwKNB2gLQVZk0M8KSOdXuWCoLo4G4qIhqJJJSccefWBwGwWbAJW
	wisHaonkXOVXjNF4tnbJ+fIfe19ders=
X-Google-Smtp-Source: AGHT+IH48LWDFfDd5uYUxKJJAe8FW+ra1g+nlZ0pEUhC/TYKo8YAyEP+TDUkUnDzUuAuREiVIma3RQ==
X-Received: by 2002:a17:903:244a:b0:1c2:1068:1f4f with SMTP id l10-20020a170903244a00b001c210681f4fmr21595923pls.17.1696946207693;
        Tue, 10 Oct 2023 06:56:47 -0700 (PDT)
Received: from localhost.localdomain ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id y2-20020a1709027c8200b001c736746d33sm11717971pll.217.2023.10.10.06.56.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Oct 2023 06:56:47 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] ecc: fix incorrect derivation of compressed points
Date: Tue, 10 Oct 2023 06:56:45 -0700
Message-Id: <20231010135645.198665-1-prestwoj@gmail.com>
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

