Received: from mail-06.mail-europe.com (mail-06.mail-europe.com [85.9.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6345725A2A2
	for <ell@lists.linux.dev>; Fri, 10 Oct 2025 09:20:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=85.9.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760088030; cv=none; b=EhwMf5vSDI9EqdYaDA7MCAc73PicSRNhOuxaRWEgRd7zzTFugqwVg4yLugx6FezIurv8V2Wp9Lpqa7Nhk67wUT9HksUMVy8Ky/EbJ3sBaRfgcfh6oMB2rhqELUkmtTS6U1uyu+lPZZ/SaX2iGukqbzlknm5vrkbchpOvHenVD38=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760088030; c=relaxed/simple;
	bh=8lNMpwWtzFyvaOHLAyVnMrqMPCvZOsPxCZ7xdHpYh40=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fb5hAcW2pI2scMmAwjsNLD4HqpdOA26PrsHh65j3sqXn8+euad1UNc2oV7mOYx5J3mnf68P/Ts1ONpWWaRvk0nuVxLr6RwTelHb3EC4qaexN3On34KwGjPMDdAjP9gZzSZmkR1Q82dbnjFdYZcql7uiM/+kbxpMvOMBYrm6NZRY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=iRJYNKH0; arc=none smtp.client-ip=85.9.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="iRJYNKH0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=geanix.com;
	s=protonmail2; t=1760088011; x=1760347211;
	bh=rPooCW17yC1AC3ej0mPaBidqy7IGZlIF4jqoOlgoOzk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:From:To:
	 Cc:Date:Subject:Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=iRJYNKH0QJMV/UD0YBsfIT6Hmjsp5OuJuT2cxXEoUdlqqgTtlYCDwejn7XH2n+hnF
	 IFdX9ps5IGWIJ0qlOzf5xpkUOPk4FdOZiKHLd7wuUY3e+QukIHOSH6JRoTnZu641oX
	 wEQEO4qwrGZEqCUzID4MXkjMcg16oZoi2DV5eWAGR4QuypOCsfpAtOlvOJ+3bNNZJR
	 0NawNG1LsIFQUZgiTDKKMSKSjZxxMWX6I5o5wME9Iz6aD10/+pb+Myh70aHckR7c+t
	 R42PamLHCQ8IedQwnejJRQwSP9+VpHiGc0QLbS61fruOhZAqkpZ3T3ntRI0PNY8B7m
	 VCTQkC4NSiO5w==
X-Pm-Submission-Id: 4cjh6L5rVqz2Sg3d
From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH 3/4] main: signal readiness to system before entering main loop
Date: Fri, 10 Oct 2025 11:20:04 +0200
Message-ID: <20251010092005.2283540-3-martin@geanix.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20251010092005.2283540-1-martin@geanix.com>
References: <20251010092005.2283540-1-martin@geanix.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The systemd watchdog protocol requires the service to signal readiness
before maintaining the watchdog. Do this by sending READY=1 on the
notification socket before entering the main loop, from where the
watchdog is maintained.
---
 ell/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/main.c b/ell/main.c
index be9d96377f07..d2d8ca9e0c52 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -500,6 +500,7 @@ LIB_EXPORT int l_main_run(void)
 	if (unlikely(epoll_running))
 		return EXIT_FAILURE;
 
+	sd_notify("READY=1");
 	epoll_running = true;
 
 	for (;;) {
-- 
2.51.0

