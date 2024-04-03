Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A833D152E1B
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164950; cv=none; b=EfcyNfG9DghlpSGb6QaemzmOK4avs5O+FuRO0dVUDFhFWzgg379xNZ17SH6+UwvotE0kXnMegR0qx4JrAXd11svkAL/5EmKjcwEbGvuL5G6mHDZEyKFmmAncZE4uBsfucgLCmxfECEmx2p1oWOYt1D6ObBP4IjYHXlxFMsZlQZs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164950; c=relaxed/simple;
	bh=f+wjLY/yAfIyQESnU5+twd+qOr6N9iGCI6NPA0DSx/Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h3JJ/+/ROGD+95qnfvTT2KPopTr7rxvT7VkOjJ5LAjMA1WgmamrHZUELsypJpbNOb9e5BbkSRsEMJwhrnxo6PZ7UuK60gfA9EPm8CQzOi/cP/p9ssvKRRGBlMtDr0f6yZ3EhfmVPJY+AhW5VLxJty6VslxYgLDRUzElyVbhnl/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=Gi6hDVs8; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="Gi6hDVs8"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id D1795164A8E;
	Wed,  3 Apr 2024 13:22:20 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 7754A124F66;
	Wed,  3 Apr 2024 13:22:20 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not running.
Date: Wed,  3 Apr 2024 10:22:13 -0700
Message-ID: <20240403172216.3254805-6-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240403172216.3254805-1-gerickson@nuovations.com>
References: <20240403172216.3254805-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=g6yxEYuoa17UgIAy65I0hlCoXoP74X2j1svjlGY+UWk=; b=Gi6hDVs8u72kMNepGXcYSM2rYtSt3E7Gp7TNJI0JAN/hDoTdLzKEmEfuKa8iQZp4ofHk8UcvXTgfLrTQ2N8IyEspB0KRR1SOdVzinDKHvWNc2YT3Ww9nwInLW6/GlTj4uaCqNvpj8CY0F30eQPhVGsnTa+/N+yvJYiRf0PfGVG8T+tsoLDS5B0H/IoLD3St2x20VDFYaOH3CTpTZK/44siRVdmfnIBSIFYs2pISclWcRujapGv+C0LEkMfiBioMtEyReYpPIkc6t9wmSvQN4Rnt5v/Eo5T+jI1qaIJmMfe83csoEiAd1NNX4theyMqi8YbCMbI77qvIwpLXMa4ucvg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

If the 'is_running' flag is not asserted there is no need to return
-EPERM since it is still valid to write to the terminal when it is not
running.
---
 ell/term.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/ell/term.c b/ell/term.c
index 65ddbcbb7600..4c31c0761a79 100644
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

