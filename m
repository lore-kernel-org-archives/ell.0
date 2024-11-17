Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A895D256E
	for <ell@lists.linux.dev>; Sun, 17 Nov 2024 00:18:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731802709; cv=none; b=YuW7NJZdiFaZSlViQDEzdblVLmVeYbLh88vmVYRqaRY/IgHBMx5hFl/caZHvlusdXeA17YRgLWdj11U5A09JpVUNIfLceCyHAoM+X7ffUfEbptuWiZ6zb7G/ONs6wadQyP4EnwM3I/C2rznlibnCd7ZkcJXPepyVdSeKLPJfQ0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731802709; c=relaxed/simple;
	bh=S7NAR9oCFBVG8QQwn1NWUioPmm01w4WJdkOG9Mpjplo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jhw0SZ1LqEk0LT7tZM1fjvHXQMHR6G3hqgdU/v4j3PS8G1fOWswTrVS/vxXijQ6leGJ6PhOI7KhvCzQGZAwC5a896Cw6wOfpkZtQvwW+QgaFuXPP9Z0IjIm0LFLvSiNzL+kcEdgRNdzziCDEjPiIaSV1SQB54IPPYEg+nGvi/rc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=KVUypC+D; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KVUypC+D"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-431688d5127so24709115e9.0
        for <ell@lists.linux.dev>; Sat, 16 Nov 2024 16:18:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731802706; x=1732407506; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=AW1Spj5c1lIwPknle3i4B7rPj8NocNmpJtbThGG+56A=;
        b=KVUypC+DyJVZBUcxRQnZeHPgS3vtITSPt39OTjYOrcQ9e4CGEovXiDsCibKCg30AM1
         4SF+8hC/4cSQuuYwv3rBflByatMSOi7BrJVcvjEi1CGdC88hfkl7s9+zh8MZAPz25qSo
         K9ryRGe7vj5+cHTKHK46hf9tmD0+u1d5LUCn+CJlfJF/5BRPh+V6cguYruIvBwGcGP3W
         l5zl1FCOmU1nf9+7yyFOcNjRzUloyDzf9VhCcY733yi0I0rVHnRfJs87XT5XToby6kN7
         oevlP8xCVeKx9iFTFUaa4k6c/1cS77Bod2gNszKUNQq5LTFOrLWXs587JyV2J3u/PR2L
         RvKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731802706; x=1732407506;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=AW1Spj5c1lIwPknle3i4B7rPj8NocNmpJtbThGG+56A=;
        b=cYfq7ed2hJ3hqJ2ssqNQnYVKK0fT/dXdHBhF6SlN+qXW8QYitXY65AnTDqtS44Zx6W
         Q4iVBxnZX8JwYD4zGGWtLrJ9sGNgu3BhxQUX4F+F7EaPmwz1p3Z44PBYOU0liXdeluuG
         niUU7pkc5TmJsS1Hw/KPEOI6rg787rotWW/A2JfwfcbkMJRjzUrMIstiGKRCv5tekILH
         5KDyOPezYUnLXuMsDWLGKkOETLUPvvNPZtyXwuJ6Gi4pfTUCxWQXXtXD59ZWfybl0LoN
         mf9EDvyoPuaZc8jpuWIOW/aEwdt6SWhegkORt7IsuIxCYy+N05UZv2uEcY9SjmqGvCGg
         Gohw==
X-Gm-Message-State: AOJu0YxXs/jTCT1F67nV/7s4E0krmzeBtL4KZhqKL2fkKHrWK8wk4O4o
	snMKQfT6l7gZHI0oGcFTan1xUyR0/91Ygfxi25O2xE8/mQJmGHmU1Q/F1A==
X-Google-Smtp-Source: AGHT+IH7sUluecTgLkKsybYCbGpCn4O6ETe7YZrWPaC8VIQYQssF9f6T/VjAmQ0dMIwsBHqJTcQTjw==
X-Received: by 2002:a5d:5e8c:0:b0:381:dff2:cf08 with SMTP id ffacd0b85a97d-382258ed508mr5714730f8f.2.1731802705865;
        Sat, 16 Nov 2024 16:18:25 -0800 (PST)
Received: from nz.home (host109-156-56-74.range109-156.btcentralplus.com. [109.156.56.74])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3821ae2f67fsm8629843f8f.89.2024.11.16.16.18.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 16 Nov 2024 16:18:24 -0800 (PST)
Received: by nz.home (Postfix, from userid 1000)
	id 4090324A077F16; Sun, 17 Nov 2024 00:18:23 +0000 (GMT)
From: Sergei Trofimovich <slyich@gmail.com>
To: ell@lists.linux.dev
Cc: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 2/4] cert: fix -std=c23 build failure
Date: Sun, 17 Nov 2024 00:18:12 +0000
Message-ID: <20241117001814.2149181-2-slyich@gmail.com>
X-Mailer: git-send-email 2.47.0
In-Reply-To: <20241117001814.2149181-1-slyich@gmail.com>
References: <20241117001814.2149181-1-slyich@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

gcc-15 switched to -std=c23 by default:

    https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=55e3bd376b2214e200fa76d12b67ff
259b06c212

As a result `ell` fails the build as:

    ell/cert.c:390:32: error: incompatible types when returning type '_Bool' but 'const uint8_t *' {aka 'const unsigned char *'} was expected
      390 |                         return false;
          |                                ^~~~~
---
 ell/cert.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 38bb01a..19a6556 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -387,13 +387,13 @@ const uint8_t *cert_get_extension(struct l_cert *cert,
 
 		seq = asn1_der_find_elem(ext, end - ext, 0, &tag, &len);
 		if (unlikely(!seq || tag != ASN1_ID_SEQUENCE))
-			return false;
+			return NULL;
 
 		ext = seq + len;
 
 		oid = asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
 		if (unlikely(!oid || tag != ASN1_ID_OID))
-			return false;
+			return NULL;
 
 		if (!asn1_oid_eq(ext_id, oid_len, oid))
 			continue;
@@ -403,7 +403,7 @@ const uint8_t *cert_get_extension(struct l_cert *cert,
 
 		if (data && tag == ASN1_ID_BOOLEAN) {
 			if (data_len != 1)
-				return false;
+				return NULL;
 
 			critical = *data != 0;	/* Tolerate BER booleans */
 
@@ -411,7 +411,7 @@ const uint8_t *cert_get_extension(struct l_cert *cert,
 		}
 
 		if (unlikely(!data || tag != ASN1_ID_OCTET_STRING))
-			return false;
+			return NULL;
 
 		if (out_critical)
 			*out_critical = critical;
-- 
2.47.0

