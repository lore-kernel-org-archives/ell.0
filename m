Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6A2B1534E1
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164948; cv=none; b=Mz2yM5PSJ2OhvelWtd4oLj81sH2m74rVnijhgOf1sj9ScbA2FZTKxqWJnflpUiOVTvGA8uAI0Cc5gUBiFJks8dRUWCPP2dAS9cH4kBeFm3PKSNVrT2yTe6F4rGoPcfs0dUJYs6TiU8gl2EM5cCP8EByGFQGwIsLbHfqHPkX4mXo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164948; c=relaxed/simple;
	bh=HV8xC4QkddTHpIR+MvHFtfq47f1HwVl3PmbRl59BTu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=idL/ZCAPo26P9QUdIYx/V31ktsq262eCvrcBwMCbPA5ubG2BXpFvmowKz7QYtfB1DnlZpSS3DNbGZh1Glu2x1Hv2nmfF6HUWi7T6IXAvZg81TSAfTIlCvcwKnZ2gk8c5dER9NsdiWBoKO2/1cBijyEKxeB0C/OmLckzSjwfKvBM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=eZNvRpVG; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="eZNvRpVG"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 3990A164A89;
	Wed,  3 Apr 2024 13:22:19 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id B995E124F66;
	Wed,  3 Apr 2024 13:22:18 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell: Add include directive for 'ell/term.h'.
Date: Wed,  3 Apr 2024 10:22:10 -0700
Message-ID: <20240403172216.3254805-3-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=e2IMjXnGOf4cD3mE8zrZzIJAPok5u2I1JSviK3kZevo=; b=eZNvRpVGTE4If/TDdjsiqxqr8NDeKC64q83BBlkMOgoSvSS/B+1wGLTE6CYBvo5o2TYYe9Ex0ixFFPmlnSxTjtAfFfH4RRR9wCWQndozW3iLquePalcRuYmRmIXn04du1L4V+AkiSllq+5APOSXNUE37KlZHzO0miErouCetcBFdgPNVAqKicdkMfn1NZNp+jr6jZm4Lr+UFXRvPEZXqJSgtoQj9uMwqy64wxrNrUhJ5ULa6oSSSm9TmEalM4IqBrTAQ+C/3naKs7Xqpie+okiV9yNCV4/Ho0FAI0uk16dmvZkopHo0ksxVxLKXsWazp6fKD342gCVe0L+5Kw9Gbew==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.h b/ell/ell.h
index f67339105e8f..c648715e9bce 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -46,6 +46,7 @@
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
 #include <ell/time.h>
+#include <ell/term.h>
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
-- 
2.42.0

