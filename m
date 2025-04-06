Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AACF195B37
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:06:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977177; cv=none; b=GqtAff3q6ZPvjfYKI9QvEu51ODZwZmsc1tslQ0PMR9T/aC+8EG5toAHxe+83RjkWhy4duoPEhFrCnA5rocJVNXujVvwd7gsJOOQFQ9q+30Z64gmfHr3h7gLJEoz4m/XK09EBkNeCQsrNEZu9e5xF5YR6a4l11VgiptimNq/T5tQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977177; c=relaxed/simple;
	bh=5A7aExH5CXnnl7ZSrAAxqeZ0qj7gifHHSe5hE/cYEOw=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eDGAeFbr/gMxuHh9WXYG0UCvZigQEz4AaGTX3rIz8EvArL2G96MuEagsv5x4YVQ8CeE2/qtKTETyV5MQHyCgt89I4ywg/J4YOa7U0USvsdDoAWKes/DO00Q7JXHh0L0Q72sTEYs0+y/6MBs1BvWwUtBKsKbF56bv5febAIO7Teg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=VEtnzkDt; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="VEtnzkDt"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 7C6BD164A6C
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 36870124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 5/9] ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not running.
Date: Sun,  6 Apr 2025 15:06:01 -0700
Message-ID: <a4ceba53f91fc4018127de406706ef9b743e97dd.1743976923.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743976923.git.gerickson@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=UguIu9Ao5RDzjbSZyHL7echnIxZePIlVRFyTddcKvsI=; b=VEtnzkDtde9mLe3q/d2iEB52A4FEqruq0tp8iFKoRQ/t1VdyJa59jlmRvdXVTpGUs8Rl2vkXShXLggRIu4aPSsIFdGhzfKztOS9nM6Wo7+0Mh4fRqBD5prQPcKJMuWpnaQRxQq5RscRY0IeaIpis2eZ9WUAZDAc0DcuWnIkaqjfFicJFbpFBQFKR+HTto0URzXEwjyibrkc6u7YZy7Rl5D2SXDnTk975YCAbboQki3Pibi5QK1IcQsRXKdb1JiDyzuJtLN6ST2kvrdKhB5BHRZMEFedFXUxewAYTSMis+l5IS/EGR2Ae09lTx1IdFVr+22iA4wD/HluD5ylKN46HlQ==
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
2.45.0

