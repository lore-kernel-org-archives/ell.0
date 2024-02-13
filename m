Received: from mail-pj1-f54.google.com (mail-pj1-f54.google.com [209.85.216.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E5E955765
	for <ell@lists.linux.dev>; Tue, 13 Feb 2024 13:16:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707830186; cv=none; b=NuPKaOUodkwO2thOXQWBIVqb/rhEgPxQ64kJ8tj+0uqDBttwMvpti4lgWMwh+QPs+hjiR9V0ImjGl3UFMqqYBUo80mnwhg7BEGGBhy/aaQtEnTE0RtGODss8+shFA7Wtu25miji7T8rLfs0XfJCXVLEbLtzYOzDWdP2QRLoffF4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707830186; c=relaxed/simple;
	bh=4wLmqlNNMxNeFPOTTsAaks9puAGmoF4hceVxarXlLZQ=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=jcisBcK1/66FM3V8gXhtn3LYLOPKX8GFA9x7sG5uzjgH1OZG6Er/ORmB1tLAbPf47Z9TLiPYi19FnEZWIEKITX3sRwxXeowk2lcRHVQCaGQwdS5lVP4CW72+HYO5Kwu6lXHfnJl1UHlrcl7ZY2L3qwfq4kNT9tf9DFbu8XRERHA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QTTPIZda; arc=none smtp.client-ip=209.85.216.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QTTPIZda"
Received: by mail-pj1-f54.google.com with SMTP id 98e67ed59e1d1-290d59df3f0so3103206a91.2
        for <ell@lists.linux.dev>; Tue, 13 Feb 2024 05:16:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1707830184; x=1708434984; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=LTsB2bA9IKuAaTjHZclX5VOr/NmCOdpXphl8gun7zv4=;
        b=QTTPIZda7FPs72iFezLCplyFb40UmlvRJVOFrL5e/0psajBKkshzfAmbAvfIcUT3CM
         +WV/dC+O3qvJKih52nPKkMf4Z3/7NBDS/12OvfMeh+qmsONxOyzd1pNJEXrJfYTx0T2u
         yDDgSaAZUZ8k+tEIKnxrr4fWNdoKOPyY9sKo/2xQluzbkGj+SXNBfegLcdaqhYzRY2qf
         43fZxUsvhMx6L2loYHYoEzO+oakoATjU8uopiPYR+Nl2k50GpN/BRztWTTxRzbaD0A6/
         61M4ck16RG+v1Jvaj74oBddaA8WJxuFaf8d+Pc21JVCJF7xtewmuudKhXSyCHfDK/bbK
         SmfA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1707830184; x=1708434984;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=LTsB2bA9IKuAaTjHZclX5VOr/NmCOdpXphl8gun7zv4=;
        b=RHEOnNWDzFiQPXY/QcP3sipepmM5LeWv5YfXJ3E+gkBbGs4mXUSzF0zlRBf7rtTHht
         RfvOqoJCoOFYCRgAjb0667J0TApKdIqIGnUDPPUZPDtKtzEjDu1aydf/vp8vEIXTgjUM
         DP2GWvlRp6SG4Tvld6RzS8GoZ9oaATMBPWO7I0N65iQU+iX8U5je9NMck9UjmrMprO97
         5rcReD0r1XTOW4EBjsEOH5W+jF/x/ny63rYVtCM1mKfJBYu2xJQt6lugcemfmXyluoed
         fZlv+61C0J8OCSOFmizprtHEQ39nWEwEWibfvnmDDnLG3xSYrogVDa/sEVtm7sdw6dlA
         L3cw==
X-Gm-Message-State: AOJu0YwdIO6IU2eWaVV6mTbym++6w0xXT9D6yWffg2vpo0HDvxfeXE8F
	cTN74m2EOIroyrHBEa7uqZ73vVhfZ62KjPZiUV8rE2pmH6gSw4LKWKFqKQcEKyI=
X-Google-Smtp-Source: AGHT+IEbfTJmE009GFZqa+D9yQtpfpOVnNN1J0ZIM0LnUCup/4hXpHvKYX8xkrR4X1lojAnl7x3UBw==
X-Received: by 2002:a17:90a:f58e:b0:297:2748:3a0b with SMTP id ct14-20020a17090af58e00b0029727483a0bmr5074835pjb.44.1707830184008;
        Tue, 13 Feb 2024 05:16:24 -0800 (PST)
Received: from LOCLAP699.rst-02.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id lx4-20020a17090b4b0400b00296ba96cda9sm2426154pjb.55.2024.02.13.05.16.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Feb 2024 05:16:23 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] log: add l_notice
Date: Tue, 13 Feb 2024 05:16:19 -0800
Message-Id: <20240213131619.828613-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Adds the ability to use a notice (5) log level.
---
 ell/log.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/log.h b/ell/log.h
index 72dbed3..7ddf663 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -17,6 +17,7 @@ extern "C" {
 
 #define L_LOG_ERR	3
 #define L_LOG_WARNING	4
+#define L_LOG_NOTICE	5
 #define L_LOG_INFO	6
 #define L_LOG_DEBUG	7
 
@@ -84,6 +85,7 @@ void l_debug_disable(void);
 
 #define l_error(format, ...)  l_log(L_LOG_ERR, format, ##__VA_ARGS__)
 #define l_warn(format, ...)   l_log(L_LOG_WARNING, format, ##__VA_ARGS__)
+#define l_notice(format, ...) l_log(L_LOG_NOTICE, format, ##__VA_ARGS__)
 #define l_info(format, ...)   l_log(L_LOG_INFO, format, ##__VA_ARGS__)
 #define l_debug(format, ...)  L_DEBUG_SYMBOL(__debug_desc, format, ##__VA_ARGS__)
 
-- 
2.34.1

