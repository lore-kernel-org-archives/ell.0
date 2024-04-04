Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6AD213C690
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273920; cv=none; b=r72m9qEanaODaOuqxiBf19O4ngVQsuVA5HJnmidVuxCegvY5lXFVFdVHMVjRb03QTcDIlP8R5T6FdWgWhdFvV4ORt9CT+P+liCU+bnZ1BbGd6vk5Y9eOvh+L1d740nFshxvWhUUyaZQa6H8IQDoZHlyeniZa7js14BAFwcN9MiE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273920; c=relaxed/simple;
	bh=w7v9PXLKRqDmvEB/Z0cl44dV5ooVf2hi5mRAxlUd218=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Izb1wlcCgfoPSJCUOhI6MfjgVHUVH32Q9NwMO7wM6eTvn/smA1CH7Onbwt5AovKUNd8RpW8B12vomh37tQeVTvefqu90DEEvTY74Z+vlrzuGfOFt/OjfsGg3enUNgToDypBHsipGjM1Q15mdObgzDMFbFuDUw6GIjWXIbPRiUC0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=C/OoXXVa; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="C/OoXXVa"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 6DF5D164A89;
	Thu,  4 Apr 2024 19:38:32 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 08957124F66;
	Thu,  4 Apr 2024 19:38:31 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] ell/term: Add an 'l_term_is_acquired' introspection function.
Date: Thu,  4 Apr 2024 16:38:25 -0700
Message-ID: <20240404233826.3466674-9-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=IGoxOEqSCZeLt0jVOG3enFSsdkeiOOI8XAKHiJX8QyA=; b=C/OoXXVaQNxdJ0V1ruoHH6oFG6hCBvNxGdi5gVal5GYQQ3tZY46C1V5flUoSu/nkCe8f8HoHQBaTtOiBedETC2tgr4h3KKE4/Rw/8kQQs296uzSDh59SfQlWWM4ks+69vr5UQAY/2BzNNtMknv6mmhnPh49CNyW9cKRBImQkjsgzyzfKdEduJt6exSrjV8nLx44khvNFCJz4MzFqGjBT7w8VHAhguW8OQM4+ZXf70FIx9UAUlPwn/slqmaSTWKqxeQQEAVtVlgW21NHre5JeDVtl++sZTj++j/YdtdS3fsh8txsdo3579LChK0/7EBtBSqrzuUIWez9SIz3HHAfPVA==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Adds an 'l_term_is_acquired' introspection function that indicates
whether the terminal has acquired and modified the TTY settings for
the input and output descriptors associated with the terminal.
---
 ell/ell.sym | 1 +
 ell/term.c  | 8 ++++++++
 ell/term.h  | 2 ++
 3 files changed, 11 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0026bbe1afcf..e288d6c32f67 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -632,6 +632,7 @@ global:
 	l_term_set_output;
 	l_term_set_output_stdout;
 	l_term_set_key_handler;
+	l_term_is_acquired;
 	l_term_acquire;
 	l_term_release;
 	l_term_io_callback;
diff --git a/ell/term.c b/ell/term.c
index f3801bcb1200..a56ede4e98ec 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -241,6 +241,14 @@ static void sigwinch_handler(void *user_data)
 					&term->num_row, &term->num_col);
 }
 
+LIB_EXPORT bool l_term_is_acquired(struct l_term *term)
+{
+	if (!term)
+		return false;
+
+	return term->is_acquired;
+}
+
 LIB_EXPORT int l_term_acquire(struct l_term *term)
 {
 	struct termios termios;
diff --git a/ell/term.h b/ell/term.h
index 50831c166c78..66059212b436 100644
--- a/ell/term.h
+++ b/ell/term.h
@@ -44,6 +44,8 @@ typedef void (*l_term_key_func_t) (struct l_term *term, wint_t wch, void *user_d
 int  l_term_set_key_handler(struct l_term *term,
 				l_term_key_func_t handler, void *user_data);
 
+bool l_term_is_acquired(struct l_term *term);
+
 int  l_term_acquire(struct l_term *term);
 int  l_term_release(struct l_term *term);
 
-- 
2.42.0

