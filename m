Received: from mail-08.mail-europe.com (mail-08.mail-europe.com [57.129.93.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5231259CA7
	for <ell@lists.linux.dev>; Fri, 10 Oct 2025 09:20:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=57.129.93.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760088030; cv=none; b=bF3HClac1jDOIcfbG1FPEItgEk7fi15USgWYaW8pDF8igBipHF8s+xyLazvvSUrUfEydYa4UrHSAQ82XFhuncff1VaP/szAPD+36XqDejPOM7ZI9hG+qiNVcVEonJ4/qiSg3R5B53wxhqQiGrJdS6quRyoinuGxvu4pLH8WogpI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760088030; c=relaxed/simple;
	bh=cnUBV7h48wcjnqiO6lyc299M3yzILRi5UvqIPfFfz3o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jqjJI0I1hnnJuBDMa2aHuNUe9DZSueyCZCmg002hq0ieRf/ovt6/UpG/0D/mSGXiIdSHm4HOhJNRLJH+ihWn/BdKPBfuDO3CdEwd2s+hCK/PR0Dv76o+dOkw0MNJQmoGnGrhPk+WCvbX5D3frZU16lBxprgYIJkrsGCU7Z1CUwk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=nMU+Icw+; arc=none smtp.client-ip=57.129.93.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="nMU+Icw+"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=geanix.com;
	s=protonmail2; t=1760088010; x=1760347210;
	bh=Mq0ivLkVQdGevRln0df8YpczHkodqWP+J3vd0EGvLv0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:From:To:
	 Cc:Date:Subject:Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=nMU+Icw+dGCMjwpgbJ4x/pxjI2jL3tR2O78J6sK/W4RMt1sgNm0U43f+jtDgTeaqF
	 A6GZSOLp0SSGO8Titds7SDx3ioy+WGufcAFD8q7qszq7lQijg2o0IJ3cFDIJjvynkF
	 MQRMgxQKch2SzN42CAFFJ4+QKD1bjXZoqGwNtC2tfTpyaT6MljyHUXnMY2ruPRww0A
	 U/qLj85sXhwwCEPDQxZzyM2aO0LGZvLdx6lNhe4aixLWWYISXzwSfYsZ1OzwTxClrD
	 V3Ji5lZ6AP1da8rxG0xlr2MfyWKjGcoEJDzcVOVf5mEVSUNt1MQB5svcfjCHErc0ht
	 2i9Lj1MPK7gpA==
X-Pm-Submission-Id: 4cjh6K6r03z2Sg3T
From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH 2/4] main: strip trailing null bytes from systemd notify socket path
Date: Fri, 10 Oct 2025 11:20:03 +0200
Message-ID: <20251010092005.2283540-2-martin@geanix.com>
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

When connecting to abstract unix sockets, the trailing null bytes are
considered as part of the (abstract) socket path, hence failing the
connection if the abstract name doesn't fill up the socket pacth member.

Fix support for abstract notify socket names by only passing the
absolutely needed size of the socket address structure when connecting
(i.e. the two family bytes, the null path prefix, and the path name).
---
 ell/main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/main.c b/ell/main.c
index 5e391b7e62b3..be9d96377f07 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -350,6 +350,7 @@ static void create_sd_notify_socket(void)
 	const char *sock;
 	struct sockaddr_un addr;
 	const char *watchdog_usec;
+	socklen_t len;
 	int msec;
 
 	/* check if NOTIFY_SOCKET has been set */
@@ -370,11 +371,12 @@ static void create_sd_notify_socket(void)
 	memset(&addr, 0, sizeof(addr));
 	addr.sun_family = AF_UNIX;
 	strncpy(addr.sun_path, sock, sizeof(addr.sun_path) - 1);
+	len = offsetof(struct sockaddr_un, sun_path) + strlen(sock);
 
 	if (addr.sun_path[0] == '@')
 		addr.sun_path[0] = '\0';
 
-	if (connect(notify_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
+	if (connect(notify_fd, (struct sockaddr *) &addr, len) < 0) {
 		close(notify_fd);
 		notify_fd = 0;
 		return;
-- 
2.51.0

