Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C9971C36
	for <ell@lists.linux.dev>; Sun, 17 Nov 2024 00:18:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731802708; cv=none; b=qKwvwGXBjgEAJ1ocz7ephRCwytcvBI78PA0c36NxX1oI8sYsXfonMqRaD2AfyYHkOfhYRkN2l56xrykqjNO1lNSkEpG+Y4JrgB+6K5QsOfIw2i9+mrFjNMs9wHdJ0RUNHnz1hQTEsncr9en1TPXa9/IHJ3dXvAYOh3l/W92y/8A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731802708; c=relaxed/simple;
	bh=L8+uXtEZdpuJMzyr8qlEUABAVpdDOdjmo1m2KJvzub4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NwWwCa8btCeWAZVkeDNcyxI823hXrlEz8AF8/37Job+9RigWsBMPGhiJcE2y01QHaNn/cWJdkALeL4rUXOW8mzkJcvGbn6+oUgsXp5wXvTTaZCKP3E/Qz92tNJtzqalDLcoQRkueRGi+Xk2/sdzz/KGxsi2gepXXGO8ldx4EB7c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=GtmSuPgC; arc=none smtp.client-ip=209.85.221.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GtmSuPgC"
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-38207c86695so2197353f8f.2
        for <ell@lists.linux.dev>; Sat, 16 Nov 2024 16:18:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731802705; x=1732407505; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=vfTtmxzuWsu6T7VtMVn4At/DamS5g05WGCBXuZ72XR4=;
        b=GtmSuPgC2VH7i+VYSFolmMA38fFGgQcEZJ20Us+sEeNPV0x+nCFZ6GM/bbg2cFUx5C
         T3F0ZfuvQJiXaWmhL3TNV1dNJtENUO12KFj50Ws4JPaVoPnjvCnvYWLbxbDtOVVyCL1S
         BFIlPKbUXnU5aduk6KtWevICVHXfsqmnht16E+XhxNsEj9UPigWtSWEBmAWvtu+mnC1+
         0iwvrmV2rfK+4G98kG1y6gs99B5bPSP09HasmFLjC8zs+YFM7LKw4zflUNrNpb15ASsL
         jzey4J6MBfs7ZBSIR411lp/H2j9g/ZtPZ5MxeRDe0S9AEkSmeT+CDARGc8AIhMFZxrKz
         H0XQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731802705; x=1732407505;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=vfTtmxzuWsu6T7VtMVn4At/DamS5g05WGCBXuZ72XR4=;
        b=Y50V5+UTbnEjRr82YGbXt0AmlPNb5417rGKYN3hGq5q0xTABcpR7Fe261H8GP0Jla5
         UzfEaW51ft6n8yEgJiDfpQz/wqbGcV9lgOiDErmqkVeyeNJkcatrAeQu/SSMUnfDftas
         lv/eu7WaZQ3ltXIolVfHorxzoVY5DTV8kF92r2G7aA3ghO25UeiQmJDZseOejxJauw0n
         YnEj2F1Yz0ccJz1DLvqOdSEiEUfFZp3NXR177WcrMs4jFKrF9+BCBHBEdBcygjoKxLul
         cvTUApLMJhGtRHPS1kVBChW3LmTxA1dyWE6ABpurizzRIM4HqvNhxZQRsKhhBLWpXMV/
         LUtg==
X-Gm-Message-State: AOJu0Yzg3oZwDoadmGOZxcPv6gKJe7Jhayth/zerLOvpbnorfHTVI+bA
	15rz3tseS/ZKS4v7NCGQ/eu1h3zEsXCf1XnSSDeOcVjG/SGC0R+s
X-Google-Smtp-Source: AGHT+IEJmesw+pBWgNdZDo9tp4c1tq0WKGFgnNOyj+vB4ks5d3y3PkyZM1dCqxej3BZAhQuibrwSCg==
X-Received: by 2002:adf:e191:0:b0:382:531:536d with SMTP id ffacd0b85a97d-38225906ba5mr6385171f8f.21.1731802705410;
        Sat, 16 Nov 2024 16:18:25 -0800 (PST)
Received: from nz.home ([2a00:23c8:a613:101:729c:d1ff:fe4f:94a3])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-382224253f6sm7113497f8f.111.2024.11.16.16.18.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 16 Nov 2024 16:18:24 -0800 (PST)
Received: by nz.home (Postfix, from userid 1000)
	id 45C9524A077F1A; Sun, 17 Nov 2024 00:18:23 +0000 (GMT)
From: Sergei Trofimovich <slyich@gmail.com>
To: ell@lists.linux.dev
Cc: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 4/4] test-rtnl: fix -std=c23 build failure
Date: Sun, 17 Nov 2024 00:18:14 +0000
Message-ID: <20241117001814.2149181-4-slyich@gmail.com>
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

    https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=55e3bd376b2214e200fa76d12b67ff259b06c212

As a result `ell` fails the build as:

    unit/test-rtnl.c: In function 'test_run':
    unit/test-rtnl.c:501:24: error:
      passing argument 1 of 'l_idle_oneshot' from incompatible pointer type [-Wincompatible-pointer-types]
      501 |         l_idle_oneshot(test_next, NULL, NULL);
          |                        ^~~~~~~~~
          |                        |
          |                        void (*)(void)
---
 unit/test-rtnl.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 59d8492..6fbac9e 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -358,6 +358,12 @@ static void test_next()
 	test->start(rtnl, test->data);
 }
 
+static void test_next_cb(void * unused)
+{
+	(void)unused;
+	test_next();
+}
+
 #define test_assert(cond)	\
 	do {	\
 		if (!(cond)) {	\
@@ -498,7 +504,7 @@ static void test_run(void)
 {
 	success = false;
 
-	l_idle_oneshot(test_next, NULL, NULL);
+	l_idle_oneshot(test_next_cb, NULL, NULL);
 	l_main_run_with_signal(signal_handler, NULL);
 }
 
-- 
2.47.0

