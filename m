Received: from mail-pf1-f181.google.com (mail-pf1-f181.google.com [209.85.210.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BA3924C93
	for <ell@lists.linux.dev>; Tue, 10 Oct 2023 14:25:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jWR2j3Q7"
Received: by mail-pf1-f181.google.com with SMTP id d2e1a72fcca58-692ada71d79so4392503b3a.1
        for <ell@lists.linux.dev>; Tue, 10 Oct 2023 07:25:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1696947911; x=1697552711; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=P8DWwQrY7OVf9LshCKNuxve4d2T82hYFhHS8/ahsG7A=;
        b=jWR2j3Q7cyNVDixcFR43I16HyoP6h2bkzwvbfXB6kXdpY7EVejswSldN3J6bd24eXh
         lPMjU5lUOxtIvzXn4+o2BMhhDtXZbasr6SnfD4IDc7Cmqwo6w2Na+M3wssd/zwyS6tYa
         PwO8K0LmrA89HliJL13rvWhOxnBR9TkVxhLG4FpDdagVwJIxaHBLHUBcaugNZLM12/aC
         qSVYGRb2LV/z964q+y1hAP+BS6YVWW4aoYn59AGp/Y8tz0UvweSMOnVDO7eiLy/vTpF/
         m/nZ3NdN5PeJQZuwnrxWE1DiOPIZhk/DYCsdCUgfR2rQXofp1bwuRdqrqy+o4mPh3WhA
         zD1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1696947911; x=1697552711;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=P8DWwQrY7OVf9LshCKNuxve4d2T82hYFhHS8/ahsG7A=;
        b=twmdz7sYoFQTfsOx3iJ+BfcVh8PoUFoEMpe5CNIe+Kp8SycGzcUiiG2LDZ++YzEsgl
         o4XjZW6t9mFewh13JbzWQY4Sn49sicIBfdba7k4Yn/b8X7Mx02P0ODRJSYgjqrz/v4ft
         Rp/8cZSKkWsb1C6EYpwdLZ73yoZYDEplk8cooOVt4TH0a/lO+vEWniDeADFLD42agWOI
         yaCD42rWx4OAl6JCLdKpHWqnOTK5QzT+R4os089zqB4rav1Bx5fydrOtTVg8AT2JGPsK
         VRGdzkUPlhLsTxhllBU87/UoqedNCcMFZMrkDtM+muKx9lJzEBAWhgQUMCsgPiV/Yrls
         YzRg==
X-Gm-Message-State: AOJu0Yw5HuGr3KawSv/R1d5idW5O8BaAgZ9wMwicSE/fgPljuDnibZFn
	7tSMAi/0rQuRbkOglCDsnAv9zYynXMY=
X-Google-Smtp-Source: AGHT+IHtEZvhwOrR3Wwh9LxVbZrLhQuhR9TECYM+aHo+dxyccQPqe4wp8UGBzd7P48DGGY3n/OLdbw==
X-Received: by 2002:a05:6a21:47c8:b0:172:15c8:1fa2 with SMTP id as8-20020a056a2147c800b0017215c81fa2mr1724487pzc.53.1696947911361;
        Tue, 10 Oct 2023 07:25:11 -0700 (PDT)
Received: from localhost.localdomain ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id z9-20020aa785c9000000b006926e3dc2besm8348563pfn.108.2023.10.10.07.25.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Oct 2023 07:25:11 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 2/2] unit: update test-ecc with compressed point bug fix
Date: Tue, 10 Oct 2023 07:25:06 -0700
Message-Id: <20231010142506.261152-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20231010142506.261152-1-prestwoj@gmail.com>
References: <20231010142506.261152-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-ecc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/unit/test-ecc.c b/unit/test-ecc.c
index 21f73f1..05a89ab 100644
--- a/unit/test-ecc.c
+++ b/unit/test-ecc.c
@@ -374,28 +374,28 @@ struct compressed_point_data {
 
 static struct compressed_point_data compressed_tests[] = {
 	{
-		/* BIT1, subtraction performed */
+		/* BIT0, computed Y is odd, subtraction performed */
 		.x = "19b3fec1c000a888ee9c44272e4d7317e6e36577fc9d53e1edfb4e296b0b7ce1",
 		.exp_y = "a8f9efd0ab526cd930870779621f4e9a53d4e78887ac9f4ed45ff75ded32b158",
-		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT1,
+		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT0,
 	},
 	{
-		/* BIT1, no subtraction */
+		/* BIT0, computed Y is even, no subtraction */
 		.x = "958df5997362a9695ad73938c86be34a4730da877eccaaf8b189e73ff20e67c3",
 		.exp_y = "1042f37262ded34d8424c1728a1ed23a726645b71db30a38f2932001a2027f46",
-		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT1,
+		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT0,
 	},
 	{
-		/* BIT0, subtraction performed */
+		/* BIT1, computed Y is even, subtraction performed */
 		.x = "069bd56634454ca76e7ba434244137509141cbbf532586c6b36e9b5be8a2cc34",
 		.exp_y = "f4f34d46e4bdc1473fec4b4c8724f349375a8a602f5e83c260d6724e64ec7e99",
-		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT0,
+		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT1,
 	},
 	{
-		/* BIT0, no subtraction */
+		/* BIT1, computed Y is odd, no subtraction */
 		.x = "8cade296a68e0c40bcf45a049f1993263bdc8524825e2be44b14ce114e475df0",
 		.exp_y = "94ed7d09b2a0e95d8df993eaf81eb64d5ff734d01da57e53b2e0277199bc5897",
-		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT0,
+		.type = L_ECC_POINT_TYPE_COMPRESSED_BIT1,
 	},
 };
 
-- 
2.25.1

