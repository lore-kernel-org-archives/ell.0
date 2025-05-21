Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6969D1372
	for <ell@lists.linux.dev>; Wed, 21 May 2025 16:17:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747844232; cv=none; b=JzcQSIguHhv+3fJGBE2fNihVPfFvU/FVnIUDqoOw7OdANOTvp7ICpbKosgW0f4lVaqM10oZ/zPOcfVT+dyJGLfQLpQ6gYOfXFLMbISmJcLlUQczqQpSp8wihKDjuPAOmzJpjrueKLt8grIkuMxq0WDRtAyBd3EQJo2BirQqYn2M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747844232; c=relaxed/simple;
	bh=5m30Dm38XTQ1SFolB9+LOFR34SkTgv4osJtJ4eAnAhQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uLO4GPnnDEIuSpq2F86Gy1rDyzQaOFwOuXhdaeN5CmZyvmeV8Tk38iPDQ8xqBFtxse2H6tUE5KN8Qku7iMqq4WvtMnqnOhUtpiWsk/5VmcLqaaigxWRrNI62ITmzA9fzGoQBySZ/tSfWblhbNAatRYwfTkZPPQ3HZdBjWiBYQnQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru; spf=pass smtp.mailfrom=sarg.org.ru; dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b=affkt27h; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sarg.org.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sarg.org.ru header.i=@sarg.org.ru header.b="affkt27h"
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-443a787bd14so34645665e9.1
        for <ell@lists.linux.dev>; Wed, 21 May 2025 09:17:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sarg.org.ru; s=google; t=1747844225; x=1748449025; darn=lists.linux.dev;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :mime-version:subject:date:from:from:to:cc:subject:date:message-id
         :reply-to;
        bh=opK+o+2WPaV4hVVbqPp/XKqoFgVgY8YS2IyMxPy+Q+E=;
        b=affkt27hofzKA02FPja57iIOd4XCk2ZM4UXXvQ7gBhJP64RTpJmTJU3aWD6+kDTabE
         +Ro/TBYgXLzfzz6F+2F3FneP65qNZuFGdQ9IWKpO0CTfuPYlLLrK9BCKgM0Xn5cXns3w
         8UhsXRc7UUGkbhg2DRYu0sT71XtNGM9Qob+kO5ThJ5iUUGHlqrzMmk7RVXg/2jdcyQFP
         kT/CevZjFIi/v7pNPkSad7lJ+JLGk37t7wXaGoPmsLoe9IPau7eMFxvJ74BT1y5SipPj
         beS6CNaeohC8w/22TS4wg1iGU4aWZjRBWLf1P+khEUdn6puVOPTibIUQyp1b034arKFd
         fLsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747844225; x=1748449025;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :mime-version:subject:date:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=opK+o+2WPaV4hVVbqPp/XKqoFgVgY8YS2IyMxPy+Q+E=;
        b=OtO+PmYe4G1GxA9okDjlQBqrSfSf75oD0LEHW4N7MhTimv+HHgz0vOqj1VpDyq6UiW
         zQwco/8SusC9BMlK+BUHP/iG7IHFvQz66m9W4B/xvfq1C9hQHn5YfF4Oc/km7RVAhAIe
         nS/sbxdu1swYyv4KqqI9jui/KtcrJAtWSXKbs9QNC06jsoZMBnqatoHs19s+sQ9XcmjS
         wceKWDsinn9s+cveZcqyXoI07iFDssMbss8KRsOPh/30oRNzsnOUE4mrED47fXOzUwTC
         Uh90FawMUr5T2RhpsnB59n1GHjzDBkp1a2/Wu0x9po8+dx1/Er48h1zhJS885eInxmul
         oqhg==
X-Gm-Message-State: AOJu0Yzxv4YAmS97kJIlfiLcklL5slZltRdGK9bspHCXHohXO2R2Ochr
	XLMysnI+tP91H4IhNaFUjQmOgG+QVyVl6hDiW6wUBB8xvfYfpECnxZRK21Nkvr2/Nnc=
X-Gm-Gg: ASbGncvuwFzCsivFom1Z8nJ2LfyTbUr34CF/jZV1pNTclQz/pCbUWk8u3NKEXb4w88t
	wWrry0XeHxGBYgnV8X/wHYGGKqb+l9kw4UDqXHGGRtHMxDwkLcNIPt4CacVmXVdM8TgI/mRCKqX
	QApkokhIPaJRM4R94qHRj+PHC3QXsr7YPFDKMQtLKvnL1XkUjnysuOkeh0GJMF1a1FH0XElkuq+
	uoFEvLBASLYjCcokBWQwtY0euIXV3v99TtCIiOxpgtAUh84rl16bqBC3gCchR11Ox0wxhf+EZzF
	rE5EwuhEMcZKP9P/yxr+tPPv5S75mB2BqIAi/DxuuSxRoVzX
X-Google-Smtp-Source: AGHT+IEHsL6UDwtggZdY1lB2i7W4SF1abloPhWJo3fAzCJje6Tzq/XAtnZp12cN7QIDpVyQ6s/xefw==
X-Received: by 2002:a05:600c:378a:b0:448:d54a:ca23 with SMTP id 5b1f17b1804b1-448d55a0cf5mr39638135e9.8.1747844224843;
        Wed, 21 May 2025 09:17:04 -0700 (PDT)
Received: from localhost ([2a02:2454:a095:5600:a64e:31ff:fe38:fd6c])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-447f6b29548sm79880025e9.4.2025.05.21.09.17.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 May 2025 09:17:04 -0700 (PDT)
From: Sergey Trofimov <sarg@sarg.org.ru>
Date: Wed, 21 May 2025 18:16:39 +0200
Subject: [PATCH 1/2] unit: test-ecdh: Add bytes to l_getrandom wrapper
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20250521-more-random-v1-1-997802b3052b@sarg.org.ru>
References: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
In-Reply-To: <20250521-more-random-v1-0-997802b3052b@sarg.org.ru>
To: ell@lists.linux.dev
Cc: marcel@holtmann.org
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=930; i=sarg@sarg.org.ru;
 h=from:subject:message-id; bh=5m30Dm38XTQ1SFolB9+LOFR34SkTgv4osJtJ4eAnAhQ=;
 b=owEBbQGS/pANAwAIATrbQjtAogeFAcsmYgBoLfx+J3OlXLgo6D3d6TN/UtLPg0MewqQZfYV3R
 SDToTMeFs6JATMEAAEIAB0WIQQJ9o/IC6DcElynxJA620I7QKIHhQUCaC38fgAKCRA620I7QKIH
 hbB2CACeO6pqsisR22FU9L5RXTD0M80JEKtiIMNhSKpiK/uwTl2cUTWiN37D65p5G6+W7D05pyt
 SdsQGrqndIs2vxbgmMCjQfLwFmHvmUWcocexodL5BmsSaHzTpZwPQ52e/cfFbc4fPXS9kwjCfvx
 /AGsYmLDZRyc3hmnrT2yRpsBt5cBm3UKUtv/LeH5bs/keYYZgjsaSdCWZU2IdqZgBYikvtMsh4S
 XJcp3E3YEYIc/rklQWMctVOkKVqtSUsvAGluw/bFzJ58iue+vpqumndK7q3G6oh312YVNk2VUEu
 AWAhQS2tlvPrd6D/avDmM3p89rV1YOCohlWANSo5aDRaOOhM
X-Developer-Key: i=sarg@sarg.org.ru; a=openpgp;
 fpr=09F68FC80BA0DC125CA7C4903ADB423B40A20785

This should have been put into the commit adding the P-521 unit test.
This test require 72 bytes of randomness, while we only have 48.
---
 unit/test-ecdh.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index ee50f07de11a5c4d6f0ef23e9860f40058e10b43..27f731c9753a420231d21ae7aa7b1e76b4a2c634 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -31,7 +31,13 @@ bool __wrap_l_getrandom(void *buf, size_t len)
 						0x7f, 0xe2, 0x8d, 0x46, 0xb0,
 						0x73, 0xcd, 0xd3, 0x6a, 0x7b,
 						0xa6, 0xd3, 0xde, 0xbf, 0x38,
-						0x96, 0xb7, 0xc3 };
+						0x96, 0xb7, 0xc3, 0xd4, 0xc1,
+						0xcf, 0x46, 0xd4, 0x35, 0x66,
+						0x04, 0x56, 0xd5, 0x61, 0x55,
+						0x52, 0x20, 0xfa, 0x18, 0x97,
+						0x5a, 0x7c, 0x76, 0x35, 0xd3,
+						0x63, 0x3e };
+
 
 	if (use_real_getrandom)
 		return __real_l_getrandom(buf, len);

-- 
2.49.0

