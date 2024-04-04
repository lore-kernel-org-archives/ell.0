Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 542A413C69E
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273921; cv=none; b=X6ldDzP7quL5uui1Zrm8ZjfHY0AIMTVp7Jmd6NcPQGJqtThQ2ww9c7Zna508jWERO5Wpwsg9m27dTRQWpF3nEomJorWuy43kwY2d1GdN41B+hwZwQ59FrpsficT0qnT9LR5ptsmhY3mEh8IntvJ1/VSLPRrFthtKoXFuDWvkbxE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273921; c=relaxed/simple;
	bh=bKIgiMGXER/w124NpG61+uYKp4i5XSXdJByRmQUfihI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sG/g/JvloVXFoMLCK+0ydr/BrO6052vzUWIsHvkoAz71or8z7yLfHPFEtcwxtaxY1CoKtk6mf5/syRR9lywQw1La7CxZBzyA+nLwxI0DBPF8tUcAKo3zEzmVXzTkEuLUfjbCNr/cnfFbVdvQUlYGunOtCfMk5n3svp34OqbGYrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=jqE8Sqjs; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="jqE8Sqjs"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id CCEF7164A14;
	Thu,  4 Apr 2024 19:38:30 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 70025124F66;
	Thu,  4 Apr 2024 19:38:30 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not running.
Date: Thu,  4 Apr 2024 16:38:22 -0700
Message-ID: <20240404233826.3466674-6-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=tLzGtTpxNVOzQJ2CLEmJ8f8tTor+0i1u/vhUX80qsSc=; b=jqE8Sqjsr9m+MrtjicEDrUNzduUpsqx15v0hPbEeFnDnTs3RDhsmnoP+Vrlde1BOk7Lzrd9AkwLzIziMOVrJ/ByWPFnuCbeSjhnuhjuKL18Sj4Uab5NJi+5GXE7UBxxaxeT4TFLWsiTpq75vK1jH9A2bvvq41oeZ2FEXWZx+AqQQz6q5iusvxTnLBtBLrNUwTgqGwjPGKpPUv6VvulenJ5o1GmOT6AMwNFeWRaTZDp/yYvtivhFxAUxtxB8Psly+A5zizWUDj6kHNKFCDMWXZiSsB7kiC6DoV3EeoNmeuiiK0pwvDxB1ufRCzNpPQvNipAxEMADtelKoULqk0fqZuQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

If the 'is_running' flag is not asserted there is no need to return
-EPERM since it is still valid to write to the terminal when it is not
running.
---
 ell/term.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/ell/term.c b/ell/term.c
index 81df771ff07f..c867b240090c 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -391,9 +391,6 @@ LIB_EXPORT int l_term_putnstr(struct l_term *term, const char *str, size_t n)
 	if (!term)
 		return -EINVAL;
 
-	if (!term->is_running)
-		return -EPERM;
-
 	res = write(term->out_fd, str, n);
 	if (res < 0)
 		return -errno;
@@ -435,9 +432,6 @@ LIB_EXPORT int l_term_vprint(struct l_term *term, const char *str, va_list ap)
 	if (!term || !str)
 		return -EINVAL;
 
-	if (!term->is_running)
-		return -EPERM;
-
 	if (vdprintf(term->out_fd, str, ap) < 0)
 		return -errno;
 
-- 
2.42.0

