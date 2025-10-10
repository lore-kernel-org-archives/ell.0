Received: from mail-06.mail-europe.com (mail-06.mail-europe.com [85.9.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4899238171
	for <ell@lists.linux.dev>; Fri, 10 Oct 2025 09:20:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=85.9.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760088030; cv=none; b=TiK0zx+SvAnomDkKgVmdpgLuxoPFOdbIi+YukkvET/JWJsgkpMicFqG0ilAdff8Rt/tCMSmuz4PtxzLH1+4UPBGV+H599Xu1uNCk58gYBP3CTAKgz+h2uzc3OsLEZifYy5RLzi7H6sTD/qL5SCADoU1CX/7BmpgRmHBN6GdcWlY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760088030; c=relaxed/simple;
	bh=/SBqYqKA10TZXHI/31if/7jImIpXwPqEcPEc9oOQiIc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=c5n4lRwTqLcOWEU+L6BvEXSKQnr8+DHo73AmzV4m7Yrw0RSUqwqHKGFe3q5Cht3Y7J18JwplEf+dkdisqiWCTIApMFDalSPw129PX7sVuH5BioKHzLCTMtqlWD1fqTfHl4ia7RAT/CRQaz72KLbDW8pWt8RD8gSBpPUqd+aBV1Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=VE6PfPwt; arc=none smtp.client-ip=85.9.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="VE6PfPwt"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=geanix.com;
	s=protonmail2; t=1760088010; x=1760347210;
	bh=8QK+f+mWtTK/t1qnvdSxXB2cpgsFgx8/IcCV9R4iZFU=;
	h=From:To:Cc:Subject:Date:Message-ID:From:To:Cc:Date:Subject:
	 Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=VE6PfPwtEkfEk+WSo2NEQq/cEeFuYdmEsm3Ua1KRg7UD1JGrlV0XFToVojPIqESQ7
	 Dt2tTJhBgeyNcltxCNp/zHnts8Tuk/lbPZm9L5Q2OdApOluzbJBiCdBG3Smr0vFK/B
	 HP/jiPKxa/dyGzun++YxLuuxAEqQGztS8myoC3bT6ybAxnF5u89E1hxXywgFdszX12
	 KcE9KZ1lAjM8w09mehoniVmcVtcv+qawT2KMyZnI/1hNsLOUurjwFfgR26UIi4SaN1
	 BId3ZiO/LAJSolU0Jtg62gGoScOuhyTn2o5pf77FECPq043/A2wKVhZI4MTVtPWvrX
	 RnrE2jq5K1xUA==
X-Pm-Submission-Id: 4cjh6J0LS7z2Sg3S
From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH 1/4] main: connect instead of binding to systemd notify socket
Date: Fri, 10 Oct 2025 11:20:02 +0200
Message-ID: <20251010092005.2283540-1-martin@geanix.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Binding is for the server (i.e. systemd), while connecting is for the
client (i.e. ell).
---
 ell/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/main.c b/ell/main.c
index 1d591810e836..5e391b7e62b3 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -374,7 +374,7 @@ static void create_sd_notify_socket(void)
 	if (addr.sun_path[0] == '@')
 		addr.sun_path[0] = '\0';
 
-	if (bind(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
+	if (connect(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
 		close(notify_fd);
 		notify_fd = 0;
 		return;
-- 
2.51.0

