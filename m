Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DEB82538A
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277425; cv=none; b=cAI8hAA/UbmIW6rG7eYT8GQVnDVyEX7qVOFf3Pcw4GEzXpoFZzCFfFhKZm9YVl1ZJaNQs+XSm/LGeB1GePBmk8pzHLBE/P7mRXOrhgt3WagkSiWccI3znWMDyQDwWc/42SSmn99MmS5WGSPWqE6rdY5jM4GaqRMjQNeyHZluWpk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277425; c=relaxed/simple;
	bh=okeIdHhUZ1icZlhYW80jQY5r40CfxfvI1s2ovB/i2Rk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=koUcs9ys9gm3TBJM0CWIU04zNxPvz/3XvNt9S03Y/7674wGf1HC+Dt+7u9gxSP3Jo9nfLCW74uGYZ5iJGRRoxMajGUwBMWt4NpV9/1a7diKknCKdbkGh+zg2bFqFomFQpSiMgKgFN7Ru7nivOeUxSJX4Um3a2JgioDKgvUPf4jU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=OFHB571+; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="OFHB571+"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 143E216491C;
	Thu,  4 Apr 2024 20:37:03 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id A523F124F66;
	Thu,  4 Apr 2024 20:37:02 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] ell/term: Return error on writes if the output descriptor is invalid.
Date: Thu,  4 Apr 2024 17:36:55 -0700
Message-ID: <20240405003658.3490494-7-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240405003658.3490494-1-gerickson@nuovations.com>
References: <20240405003658.3490494-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=lbtY2FqculPhUhdkvaB112mQju1ZtYoT51+DVW/CE14=; b=OFHB571+K1NCs4e9y+gEn49gPZ60ufN774kDOeZ0Q7XNmjOxg7NEkCO+dF+nAmH67WcRfnxW8ufcoUvqRNNVcHyuKVukyhsDwR0YlyOO5N15xhqidOtNY6sYfGGQ7Q3y99T1LsTdeopGgN4bn2BvTACHYzfj8FB5wlvFnjHhdXRMyoRQe1BfyOgjMJjxP0qmOv1uRz/SqYQ/t9qKpBy+210YKdxO6Mm42HKw99jwvSa5Oo07CNJi9o6mAdUmhN2wmbmimlxDz7mioXwZqej/KsmMqB0yrJjh1vdLelbY7/4A8SWSn+EQQ/uyddcWPtI3I3jWIepwXsCoq63Y4SOY/Q==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Returns -EBADF for 'putnstr' and 'vdprintf' if the output descriptor
for the terminal is invalid.
---
 ell/term.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/term.c b/ell/term.c
index c867b240090c..7ec92476e14e 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -391,6 +391,9 @@ LIB_EXPORT int l_term_putnstr(struct l_term *term, const char *str, size_t n)
 	if (!term)
 		return -EINVAL;
 
+	if (term->out_fd < 0)
+		return -EBADF;
+
 	res = write(term->out_fd, str, n);
 	if (res < 0)
 		return -errno;
@@ -432,6 +435,9 @@ LIB_EXPORT int l_term_vprint(struct l_term *term, const char *str, va_list ap)
 	if (!term || !str)
 		return -EINVAL;
 
+	if (term->out_fd < 0)
+		return -EBADF;
+
 	if (vdprintf(term->out_fd, str, ap) < 0)
 		return -errno;
 
-- 
2.42.0

