Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA77D22A7F9
	for <ell@lists.linux.dev>; Wed, 21 May 2025 16:17:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747844232; cv=none; b=bYKoymPHr6lrD4HVmr/E/w+gsAz4uHl4axv8H5zOoQ//bpwZMwc2ePaPeIeOOGg/u3hPWMqET5adwgHs4/uvgIzhI6kStsxZBOyMPmP20bAXFnktHnV72urTkXkMOyrr8rCFp1Iz3MN7Qj49OK5+A1fJDx7FZLNaK7TOi9RiNUs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747844232; c=relaxed/simple;
	bh=O1PYA3nzZw20tux02yGm3V9Qma0dthvB1pvLqbGaGYk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=R5eIS6fPMNdSI08HY3XET8ud9taDrsFVv3XpmZiaf3L0j5Qtkm8DiM8DA8sLWSazOLwebXTtQDjiMg0tqmyhZ0GnlD/SPv/tgneSKy6xvND7YMrCt1xmyhlqcImHpes2tNw8G3QyUFOzk/PR29VZ6miooOWE5NpnQMta7GqJhXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru; spf=pass smtp.mailfrom=sarg.org.ru; dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b=u7xaDlPD; arc=none smtp.client-ip=209.85.221.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b="u7xaDlPD"
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-3a37a243388so1965327f8f.1
        for <ell@lists.linux.dev>; Wed, 21 May 2025 09:17:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sarg.org.ru; s=google; t=1747844226; x=1748449026; darn=lists.linux.dev;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :mime-version:subject:date:from:from:to:cc:subject:date:message-id
         :reply-to;
        bh=16hcIskgfAomS2YtISFDif5fUBxG+dRvgjNdc6Gxg/s=;
        b=u7xaDlPDfqjhJwW8nuH/KJtnQSyFZbmbKFzHvm05vSQv9g4Bl3DL9Wwl0S4h5+UZcQ
         8OPNhhQ2nSBgRQOhmu9ruux/J/1Mcfbo9cGRJMK9hpubuKgP1DfVnSL1Uut2fDeDFuQ+
         CYQTvrIesZnYkBXY7Nlr38zr4GAUPQWZustp8Qn3kI5fetBrQoBIekX3ChL1mj4I7t8y
         0R25CRDcQtNsI3m/9dKBHVz9sYEll0jOIjwowjHs5AZIq8/IB6bjHfSyQz4EyydVkomi
         vwZ/rSrYCfc9b9d14X13vHWvL/6RCKs+GFD86oaWNE6p9EXpMRXViOmowdyyDKJ9wSaC
         7nCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747844226; x=1748449026;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :mime-version:subject:date:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=16hcIskgfAomS2YtISFDif5fUBxG+dRvgjNdc6Gxg/s=;
        b=HvCxG+AcNgd4M1Sggp5wh80X6nQ/SHd4n23rREr4oN01eLzCO8s6QScC3cewPemt7N
         XRNzywHjZvg3BB6TvbjKwm/9l5wKRyRZ5EctDdJBnf5T/jKPCmur+SXdzdQ8U+sWq1+3
         6ReEFXAVy0HnWlmtTGCc8tTWlGruPHNgvV/RPXgJpy+gt8PhUve5YaaJo+D7LC+HIqFL
         vEZ6hr1OGpQJiXhVn9c/ZSgrYFllOjqu+jGBHBHkhHZ+kAYaD4RBNHJa597cLx7gYcpr
         hXt6zX13mPQMyESLktvBLvw3z+roFosWG0FXgw2hqCky4hyYT0xBABsh3ju0DXpJ7Iyk
         2GLg==
X-Gm-Message-State: AOJu0YyDO68iad6+IDu/WLqiO3JnNiMpDEwZZB4Jt/moXCICGfzWBsih
	KPP6AlGwZ/5rQuw391jkIkrDNSB5xJ4dBe5pOswlo9ocBiSm8Qg7aYHOPz86WqAEx2MpBMaDl07
	AyueOiKI=
X-Gm-Gg: ASbGncu8Pd/JKo2C5ZvtoS6l2+rYkk5UN5DRULyGtyauxZvfrxXRc1CNJFqEW67USGZ
	ZxEC5vbbnZJ7mGy9SEmmuXmbUVpuJJtUXIVZvNtFb0gIXVTOdBpG2YH8+BZfw1QbB03QrjRBWAm
	hgPaGUxCHYjDputogiAQ6obw6NbWbg01EvyXQ/GRowh0ugK07wWwTWj/oIJZ101ZN6FpzWWiJXm
	B6XxaZOFdgKtiTxfkMGM3++OreGU+MmYiPSxIUYIhQXWRB0SK/FJnnIjeApI9lUdZWmQzMEdPnR
	0StPK+cRZzk4d8lLLb1T3XCVxkgGK8a9W0yYyxhobGED6SxgpFH/kHBR5QI=
X-Google-Smtp-Source: AGHT+IGzaPw1eNqWkaVZdkFdgNCzHwTdz6c9BCFrTwnMW7GnFXqBz0SWLDOAdVdeesN87/IU8naTfg==
X-Received: by 2002:a05:6000:1445:b0:3a3:7be3:d0f7 with SMTP id ffacd0b85a97d-3a37be3d46emr6025932f8f.22.1747844226025;
        Wed, 21 May 2025 09:17:06 -0700 (PDT)
Received: from localhost ([2a02:2454:a095:5600:a64e:31ff:fe38:fd6c])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3a35ca8cfb8sm19415286f8f.85.2025.05.21.09.17.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 May 2025 09:17:05 -0700 (PDT)
From: Sergey Trofimov <sarg@sarg.org.ru>
Date: Wed, 21 May 2025 18:16:40 +0200
Subject: [PATCH 2/2] ecc: Check return value of l_getrandom()
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20250521-more-random-v1-2-997802b3052b@sarg.org.ru>
References: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
In-Reply-To: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
To: ell@lists.linux.dev
Cc: marcel@holtmann.org
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=569; i=sarg@sarg.org.ru;
 h=from:subject:message-id; bh=O1PYA3nzZw20tux02yGm3V9Qma0dthvB1pvLqbGaGYk=;
 b=owEBbQGS/pANAwAIATrbQjtAogeFAcsmYgBoLfx+A7pEzWJOvKcRAcHP0R0LZaY6o3I8eOuPm
 OnNznUVozeJATMEAAEIAB0WIQQJ9o/IC6DcElynxJA620I7QKIHhQUCaC38fgAKCRA620I7QKIH
 has4CAC3rcppAi4ynwZlmwUowBQMZIzWTZU75nxUuhaixj1HVA3UzP9DoStlG1JpSIsj+h2qSrd
 9evihJoGuSCNlnjxtrs4dlugxCNdeeXEURDHfPZ2MEAZH5MXBCcMn3VCJtQw1WyPt3yZkWELaFw
 xmk4uhUUUmQVzfpPuAtQgPQZuD8wPTkftvxg7E869v8+ToncdXxRgyqqwRYsuX9RQtgrnWB3W19
 Vc5nGCnlkRB4UEQ7kvLcM9yi3eFn1vskT1sKBI3nQWPG4v+ROkF8DO7mDW4UlpaEmvR4U1oQTjI
 MF3UBdM54aC74gFX5TpTBu+2cAV+WSK95mvkadPGRMVG6MoV
X-Developer-Key: i=sarg@sarg.org.ru; a=openpgp;
 fpr=09F68FC80BA0DC125CA7C4903ADB423B40A20785

---
 ell/ecc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 7ab3c1accc869f0d178a203d85f9ec5f77c89a09..bed31336a634d2e40cdda88da06df9e6a62d515b 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -1037,7 +1037,8 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new_random(
 	uint64_t r[L_ECC_MAX_DIGITS];
 
 	while (iter++ < ECC_RANDOM_MAX_ITERATIONS) {
-		l_getrandom(r, curve->ndigits * 8);
+		if (!l_getrandom(r, curve->ndigits * 8))
+			continue;
 
 		if (curve == &p521)
 			r[8] &= 0x1ff;

-- 
2.49.0

