Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B82FB13C697
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273918; cv=none; b=b/7APxDJEkQYSipCPXH4JGx0wkINpvK2w1tXC6yvWTDyA5iX9b6iOhojJ6Yg+eWyRY7mVTAwlMR0nmakXn/UOAzuGqLuWF4LACesTe51bZ6DfBc/ycGBCW1l/7pe964IxwLzKKdKz4l4fBXE4lqlx7moJfmUZLvWTITheJtXKaY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273918; c=relaxed/simple;
	bh=iZ/RA8XVoPeKVnzjVCnulrf8rQ6LZt9cF/0nP7kLDbY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aempm7yHgR9TL2QtOx1OoZuF54iVl1DwU/SI00cURCgAx255KahsF3woJJJF++NdrBHmPB/rGX5B83PUCCwwiCG/wHsIrfQLH0iK/nbELf4Ta+Rjt+ObiG6jErjlP6py6TrGTSihzwZzmC0o1NfZ+ZIaSf4pCxKhtFQhRl4Q2Xw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=Gp8C30a0; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="Gp8C30a0"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id BF9611649D3;
	Thu,  4 Apr 2024 19:38:29 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 590F0124F66;
	Thu,  4 Apr 2024 19:38:29 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
Date: Thu,  4 Apr 2024 16:38:20 -0700
Message-ID: <20240404233826.3466674-4-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240404233826.3466674-1-gerickson@nuovations.com>
References: <20240404233826.3466674-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=A4lGAn0XrWXIA8QFoY7e4UOgcDitezEd7I5VUnfs1sQ=; b=Gp8C30a0wGTmrB287UsvPAJPYkVB+f+pS/o7kgWxnIVI1Mdy52jPt3QRA0e/hWUGL0EJM9K+3Wh/zzZUWJkl9tR8LxccMciAWjurEvMPuKBCq3k6yQz+SqcNT85g280CrthVI04u5StqB/gi67NT+XQcA2bxeL0RnlKWnTEuU0lPUEtJwYPeDuv1RHYS8v3/kowRZEh06TjkGOa8GidweWU6Qff5+6KZE3c9H42H1/FQKDlahx3dMhn+5KN3LSc77TZC49l9EAXBhOevw0yOYzsq+Ik2WG/T9dhfA5sIDwnBiW4+ViAwDtgXOQ1CV2JFd1n7dtSiu2E1oSGVh+QKRw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 Makefile.am | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..5059682eec5f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -55,6 +55,7 @@ pkginclude_HEADERS = ell/ell.h \
 			ell/ecc.h \
 			ell/ecdh.h \
 			ell/time.h \
+			ell/term.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
@@ -145,6 +146,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/term.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-- 
2.42.0

