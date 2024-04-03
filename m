Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A837F15351D
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164950; cv=none; b=sN/AWJ3/FAsGkdrevMshP/sHCPlh/qCjO0UAILcp+4csPM1rmMCRB9wlgREOliRCpI88cjnuJxwnIgHlepABMBttWq/wEFVHZiUNBncsfcaMc6k4W5qY3bJTAhNZGfI3TBQRmpksCdqQj8el6wVdnW4zOwB6mJKeW2JKQC0Z8no=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164950; c=relaxed/simple;
	bh=qaayyhel/lgwPi8tU7qQ9bIhFro7Dz09iplXE05KDr4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hJ5TCPSFB+85NtvO1QI04McnbfA5ID2BVdiDE4zk6MjZNDST4arCHtKXQXKlG5A8EcWWqEVZRoinkbYDn/Ov3AGIzBBSH12RaMMkvStxqPqT7Xj6Ioj4J1nQy2VOPYNA2+jRWsHdN5kyR5/JdfaMvbsErU2QZkesR5yD3Mdrhcw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=iuK9EGCt; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="iuK9EGCt"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id C7471164A8F;
	Wed,  3 Apr 2024 13:22:24 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 069DD124F66;
	Wed,  3 Apr 2024 13:22:20 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell/term: Return error on writes if the output descriptor is invalid.
Date: Wed,  3 Apr 2024 10:22:14 -0700
Message-ID: <20240403172216.3254805-7-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=zC24mif91dTj+qBt8WN3bdUJGuwcq3ux2wvMyETQQyg=; b=iuK9EGCta7EcVxWj6ctqL6xkdYZY0AIi/waB0+IuP+75SzJ+HQ4RPIiUvLOekjNu/SYM4LTeaX4EEmIhQhX79gjlAau89qbhcdbZtHFV5RblfpZOOBmtojsvSNSY9Y4mQQOVbd9sDEp+VTLW8+/IEFvw8sQjoo2hvhUYM/bgBFWcm70YgbWh3Cc+ARzqE2RgtV5K+Y27w+U4Ko1eezcYhSYH94aVIcUx3vehl3vP8nQe9finviEi4eY6Xbypy70yGWwn1qHWI3SZ/xOcmGQH9XCp6LYnWxNs/Qqvwme6yiuYdH7Vuj70+DiLYkkCrv5nA980h1DK3CJRTOptICQJxg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This returns -EBADF for 'putnstr' and 'vdprintf' if the output
descriptor for the terminal is invalid.
---
 ell/term.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/term.c b/ell/term.c
index 4c31c0761a79..29d31987939a 100644
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

