Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC0F423FC66
	for <ell@lists.linux.dev>; Wed, 21 May 2025 16:17:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747844232; cv=none; b=dbDx9vrkcIs17kKFYmtIiTotMfOoJG0TqFm+CA0caWIG2K8EVsbj/K4MvWoCcKkbHYSK+QUXOeI4InW1Zpbo6e8G/PhNnDeNStCuQg7Vyd8nZDDbcXbLShbRKZ0WPlil9BmEFajT3QHaDHWcxbQMf5GHLAsdIFoS+MloXdIxrhw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747844232; c=relaxed/simple;
	bh=iwuT38N/5WzJflzlVJSsP23POCTX1eIF1yrqvZqXG3w=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=jpjo/60eirqOseRY8nKMtPfq7sb+2uN0us/mOjMPvCoosufwwbHhlQ3rw27Gwp1bkVJllqna952o5BIPRZMjtXoF2wYayRhXP0QGuXXVqWSLFfa9r2QltL4rCB4ClWgItgWT3ah6Od0aejgiq3RbYTt62w1TVU5VTBzggT2zj5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru; spf=pass smtp.mailfrom=sarg.org.ru; dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b=fv8RsKmv; arc=none smtp.client-ip=209.85.221.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b="fv8RsKmv"
Received: by mail-wr1-f54.google.com with SMTP id ffacd0b85a97d-3a365a68057so3960263f8f.0
        for <ell@lists.linux.dev>; Wed, 21 May 2025 09:17:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sarg.org.ru; s=google; t=1747844224; x=1748449024; darn=lists.linux.dev;
        h=cc:to:content-transfer-encoding:mime-version:message-id:date
         :subject:from:from:to:cc:subject:date:message-id:reply-to;
        bh=0B3oeRl7HpEXsQAfW9jFGnlxlET8sngOCwgTx6dGDnI=;
        b=fv8RsKmv2fSRQxbUjFTvHe8HY1viqxR3LPttn4N+EgFvvLmy2972o+1JyF182z9cyl
         d8AY9yHg8A9W7rWZdswjn6zPLvxdlFlE867XaDXHBZLJJQMDN0v/qLSSiB+0jxsxYbSG
         HIma6qHAGO6vPRWy8Z3JgEHNpOW7Jspu7TsMcBGmUwvI4H9xHGh9xR4+RwuB65rtPZ22
         JZDAiYTZ1n5fkqW44DIgiwMwymveembCoxEr/NdjHdn9FAgYkxlBNleg8VgRc0VCZBpE
         TPzHaIP+r9CYuYIsf7YYqKqJaYWLhbZOgJVU8UAaAYl2CCODV1iELfv3wmuw3kEK6Z+w
         qpdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747844224; x=1748449024;
        h=cc:to:content-transfer-encoding:mime-version:message-id:date
         :subject:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=0B3oeRl7HpEXsQAfW9jFGnlxlET8sngOCwgTx6dGDnI=;
        b=OSM9q+bO4JDNtMDBZ3vlAiEWDsYkB5XeVAbmL+wM90D290JX/S1i5RMOOzmouQtBoh
         YMa5NE4apCs28v2zUu7NyxOC85tJajiCnQXx7KegOQYnvW1yh5ktjB2GdDugiMnyw33C
         Zo5bFd/sRiDvXdJab/fa+W/drX/0gRXz6WgX/T7Wo6S6r25BKrgwkOWKqDZLeJDJpSIL
         LMjI1xJvZEWpJOsHvh1FjHSjx1PLk4m0pFLx28m3KwpVWE3YqKP9cFKpv0RterxAepm/
         dwRbQ8BErqwjR/113RcGmm0f3dx/qN7v6Ayhrjex9pfNhrBj4jAQtDhG3XnfqoMZz4TY
         O6RA==
X-Gm-Message-State: AOJu0Yxi3OJrWw/BIAyeW+1ugb3ukrlZQKLA3P11Y+3B2nJY/iHM0aQo
	2X4D/RFmfFkR3V3Nrnx/1IIrxHhyu3+aipYpuwEcF7fT9N5I/+4BTM3NpYR3ii7I7LTMUkcbDjh
	mE0Xf+xg=
X-Gm-Gg: ASbGncuiZG5pO6l+BRM33mB1b3EbAlh/0kGp67RTFtDHdZ1y+6p7hdr1OoW7+EYLbEh
	dzt3rELs5wfAzXYGrPRoHYubYoRhwhlsi6DBvTfhOHB2J6Qe+bWKCcX4omnUaxW/JUx7PW9LEv8
	h+JE1EmKpMnCao/BOl+j53L51zOhPFTam0ikhlBKBzzljEix8tXB4sDU1eebXn+pm5qpJbXia0D
	9TnM0/FGWMwRUu/Cr+Hy4jx4gIVHroFaZarnCrMSIog6CA3FLx/sfCz1aEzFqNVdkiSfuTsQe6T
	MtR0J8y+AXUgVJX1ZfRRBL28v+KvrHdqsU4lU5/ebieguDVV
X-Google-Smtp-Source: AGHT+IENW491w4pCKHlr/111tMyrnCqi1JBXUCQ3FVU1BEZdVnahta7DvAY9rYFS2QEHRfRRRzvKEA==
X-Received: by 2002:a05:6000:430a:b0:3a3:648d:aa84 with SMTP id ffacd0b85a97d-3a3648dab2fmr15326307f8f.5.1747844223573;
        Wed, 21 May 2025 09:17:03 -0700 (PDT)
Received: from localhost ([2a02:2454:a095:5600:a64e:31ff:fe38:fd6c])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3a35ca4d0fasm20357776f8f.8.2025.05.21.09.17.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 May 2025 09:17:03 -0700 (PDT)
From: Sergey Trofimov <sarg@sarg.org.ru>
Subject: [PATCH 0/2] Fix ECDH P-521 test
Date: Wed, 21 May 2025 18:16:38 +0200
Message-Id: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAGb8LWgC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDI1MDUyND3dz8olTdosS8lPxc3VRjC9MUA3Nzs+QUSyWgjoKi1LTMCrBp0bG
 1tQBVWH3JXQAAAA==
X-Change-ID: 20250521-more-random-e385d0776cd9
To: ell@lists.linux.dev
Cc: marcel@holtmann.org
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=693; i=sarg@sarg.org.ru;
 h=from:subject:message-id; bh=iwuT38N/5WzJflzlVJSsP23POCTX1eIF1yrqvZqXG3w=;
 b=owEBbQGS/pANAwAIATrbQjtAogeFAcsmYgBoLfx+FwcJi8uSMT96TyjgbG/Jxq72Dg1ZK5noF
 EW9QihcOzqJATMEAAEIAB0WIQQJ9o/IC6DcElynxJA620I7QKIHhQUCaC38fgAKCRA620I7QKIH
 hWvgB/4gU5bYek+nNpcaE9NTA6QJHzyMVIXDc9ZbAaSCOtvihFGkDRJxGeLGKNtp/xzqoj0KA+7
 dx0HBCEwRnGTBmuI6eFBV+8eC/VDoiF55BgVAwE1iA4gWuP139G2/oPkWII3jUuMlW6kvPaBQP+
 +0v1JQU5vpBlDuGkpcBKxusMA1cOPWdFmF4HfqwGAGqhIzw0rgd9RplN0CmhZK7U5e3mSTVm0IF
 rYgBv0+HPbuP52RKTnBMU3cOzoOaflB0oi+HCkBHOrP+sSaLibmePKLm2Bn2ulF07dDnbhbaSE3
 1s3Gnqdm7T8yNQ5R8NLoluo7ZsdqkWrTzQZckn2Eh9DGSSAx
X-Developer-Key: i=sarg@sarg.org.ru; a=openpgp;
 fpr=09F68FC80BA0DC125CA7C4903ADB423B40A20785

When building ell, unit/test-ecdh fails 8 out of 10 times. This appears
to be due to the `l_getrandom` function. The return value of
`l_getrandom` is not being checked, and the wrapper for `l_getrandom`
has not enough pre-generated random numbers, causing it to return
`false`.

---
Sergey Trofimov (2):
      unit: test-ecdh: Add bytes to l_getrandom wrapper
      ecc: Check return value of l_getrandom()

 ell/ecc.c        | 3 ++-
 unit/test-ecdh.c | 8 +++++++-
 2 files changed, 9 insertions(+), 2 deletions(-)
---
base-commit: ccf0a874154b124ce25999b15f172b050c2266ae
change-id: 20250521-more-random-e385d0776cd9

Best regards,
-- 
Sergey Trofimov <sarg@sarg.org.ru>

