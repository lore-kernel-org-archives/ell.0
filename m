Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5426513C69D
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273920; cv=none; b=Y9JTcIi2K12YMPSOsg1pHh9qlzaiVYkQMHErJ10xFtrp33JzuQ2MYvnaX6cd7x4IHaNWvZp7lvAv7k6ow0J2UYYXySr9c/sXJO3n9aCOpc3TsFJhlhTDB7wt2mGtWdApSvn/bqUylOP92Ctk72wFGhtlVHAYtTOodeh65a5M1CY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273920; c=relaxed/simple;
	bh=okeIdHhUZ1icZlhYW80jQY5r40CfxfvI1s2ovB/i2Rk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kj5Hu51pBSXupjGyMltwElZQZjxKRksUfCeHiM7LBpxCGgFpGDsmod7eN92N6T9/fAJpbY1C4FifvFko/78WKDL5PhJpAPON1GxH/9ZaeYoKKe0c6SG+K1Mk/UwiIdGUVuQrBkCTd9fwTaXZYpYlr9rDsFhOB6I+DSggyJEQGGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=FVbXAudH; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="FVbXAudH"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 5BCFC164A86;
	Thu,  4 Apr 2024 19:38:31 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id F0D42124F66;
	Thu,  4 Apr 2024 19:38:30 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] ell/term: Return error on writes if the output descriptor is invalid.
Date: Thu,  4 Apr 2024 16:38:23 -0700
Message-ID: <20240404233826.3466674-7-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=lbtY2FqculPhUhdkvaB112mQju1ZtYoT51+DVW/CE14=; b=FVbXAudHDYEmLqpu53jeWt0JI/XCE88CRG0rT2GL8k4qggoYRpHZrn5ATSKeg0enFZUTzWaNKFBWXKD4NF1bl6N7je2DW8AqoYiDfDev2RIFxe8HsxrSdfV/GwTEfZlykOJYFjFMveYA7IqS/YB2QMKuzY6nog0weMWQOat1Bl6cPfVhE900aXY7mmT/R4Be7wHby5H+5h/9Lz5lGXT3qUe8KFtckEMasQy6l8ePWGuVr46DyHQHKvVQmPMAuH0nbUYNURYXoyTEE2N2clOLaDqDUIpe3fTXlwvomLp4UvLmTOPSMVuE3DEzZFyjJtWOdJ+3aY7ZSZwRpSumwF1XAw==
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

