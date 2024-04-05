Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEA19A2A
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277425; cv=none; b=brlbHG+1LnhFEaOVYPCNGGJlua3bI4lPdQcTL48d0vF3k/qYC4qKynXpAxtEsP3Xli1xygPMBBk7b+kEkXoKqOw8XagjquXcsBwGrpoS8X601AVRn5tYc2wPCruRAXql92Sqm01WG9dKSOj81S9neGABa9G3c9Ivgc8FVaZafGk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277425; c=relaxed/simple;
	bh=bKIgiMGXER/w124NpG61+uYKp4i5XSXdJByRmQUfihI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=U6SIsUxwIU+mTrQjXUQRom683QnbNLWFs2ZRmIwXwN4WNB7YQwakFRuEoksZgEgkP3I9r8DAx8BbcgAKdEtGioA72ROF0hY2wSFTaczOVvktnQuH3BDBwPFWrtLGTTcpm16nANMU1idwLCZmSLwwy9SOg94odoW8eETGDzmHgnM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=NwIkSg0m; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="NwIkSg0m"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 7FC4E1649E7;
	Thu,  4 Apr 2024 20:37:02 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 235DD124F66;
	Thu,  4 Apr 2024 20:37:02 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not running.
Date: Thu,  4 Apr 2024 17:36:54 -0700
Message-ID: <20240405003658.3490494-6-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=tLzGtTpxNVOzQJ2CLEmJ8f8tTor+0i1u/vhUX80qsSc=; b=NwIkSg0mwd9gTYRRBXlFVtsve8qVtPRGppVj6T49yWNHed7NMBFN2wONLjWvKnPRHE5wZ2kX3sAhSsIv7WVkUh+ZkHksn/sW/sq2RYov7Jb+SQK1bo8Z3hp+wbs4WhXL3Jqkyxth7KISnPj18dBrhdRyHsiSt1yQdFp2qY//uRzsOVdHsMTMvRL2te0bP/bWmeKfgWNLZmGmpJIHxNTHDrMhfT5ocgQgvc25Ubqjpdl+rPbhAgZcfMBdfDZx6i+GVw2tUpk7jouP/AqYWXgJJBkETu1IrtLqBMRN6hGbospmoo7KWnx7IhQWjEYerjAjtqZMaUDyAHaPbqmmtg1h4w==
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

