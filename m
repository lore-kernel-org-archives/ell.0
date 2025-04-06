Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AA3751C5A
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:06:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977176; cv=none; b=rvFf+vAAf4S8yGer/B68XMdxVTJv8zaOHELQMzOgACKKGi1XMlCBI5qPsFxpoeno1Y9+5xp+7S15ruBjEXJGmWYdL0CBeMd/AJtTxlb4w0fJml78uJuVLL3LeEtx6zB83p1OZ9w0J7ncc/PXS794nvOTaICBLg3cgq/HZM76nZM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977176; c=relaxed/simple;
	bh=FjOKYUsw/TLYpzGX/kd3ZkR8//BoH7jon518qSbAluI=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=s/EeHJhy+Esdenovb+6gFS5LzVGKd0Wkz277sTFP/RrueFOSQmL2VLYySaNOwu4Hk/0PVyaE9EkaVHpFsSGtmm/BOeF7ybqCaQu5n4TjTXv2Uw406OdER0LD4KyAR4APGTEIgjFe31goTEV8eCJYo6/3JxSl+u1Bmk8vuUegBtg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=lxSavuDA; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="lxSavuDA"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 56733164A70
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:10 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 0DBD4124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 7/9] ell/edit: Rename 'l_term_{open,close}'.
Date: Sun,  6 Apr 2025 15:06:03 -0700
Message-ID: <0d4caa68d67e0a8f4e0e56c8208c6839248e8c65.1743976923.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=V7ZWljNcSGf85DkFCs4DEofrQf9uRpcrAMQ7kJxeKtA=; b=lxSavuDAUWMvixILq2vL2/lp/qlUXUeHf3MEk5xPtsRXPeghnP6R/UigmSHlf8WhTOSvJbGQEgMdknp86ckbspK5u5yhcK/cL8PXXWzfa2eOucJXFVIKD1VWdLxDHd3gGUCmtQKYV+jk3UQ+obDpQJzccCaBK40MDnqi3xwSMpyLEnXNSGkUkNfb823XTGSmvhFuX+jsEgrV3qKYewaxe43ckDzyLGl1OEVr7kGHROs0ewwMSRqQZyjSV/0wDVolSBFR6HZnykx4nBiVtEwftKMcPZ7ygp9itWaFeWQHrDo2XE5YvZQ7Yez9GJ6ZVElJzgKmIrur3xMrKlDDef5tyg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Renames 'l_term_{open,close}' to 'l_term_{acquire,release}' since this
aligns more closely with what is happening with the underlying file
descriptors. In particular, those descriptors are not being opened or
closed. Rather, their TTY parameters are being saved and altered on
'open' (now 'acquire') and restored on 'close' (now 'release'). At no
point are the descriptors being transformed with the 'open' or 'close'
system calls.
---
 ell/ell.sym |  4 ++--
 ell/term.c  | 18 ++++++++++++------
 ell/term.h  |  4 ++--
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0d009e2d1927..2e198bd57461 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -652,8 +652,8 @@ global:
 	l_term_set_output;
 	l_term_set_output_stdout;
 	l_term_set_key_handler;
-	l_term_open;
-	l_term_close;
+	l_term_acquire;
+	l_term_release;
 	l_term_io_callback;
 	l_term_process;
 	l_term_putnstr;
diff --git a/ell/term.c b/ell/term.c
index 7ec92476e14e..f3801bcb1200 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -126,7 +126,7 @@ struct l_term {
 	unsigned short num_row;
 	unsigned short num_col;
 	struct l_signal *sigwinch;
-	bool is_running;
+	bool is_acquired;
 	char key_buf[8];
 	size_t key_len;
 	l_term_key_func_t key_handler;
@@ -145,7 +145,7 @@ LIB_EXPORT struct l_term *l_term_new(void)
 	term->out_fd = -1;
 	term->out_ops = NULL;
 
-	term->is_running = false;
+	term->is_acquired = false;
 
 	return term;
 }
@@ -241,7 +241,7 @@ static void sigwinch_handler(void *user_data)
 					&term->num_row, &term->num_col);
 }
 
-LIB_EXPORT int l_term_open(struct l_term *term)
+LIB_EXPORT int l_term_acquire(struct l_term *term)
 {
 	struct termios termios;
 	int retval = 0;
@@ -249,6 +249,9 @@ LIB_EXPORT int l_term_open(struct l_term *term)
 	if (!term)
 		return -EINVAL;
 
+	if (term->is_acquired)
+		return -EALREADY;
+
 	/* Missing input or output file descriptor is a non-recoverable
 	 * situation at this point.
 	 */
@@ -317,19 +320,20 @@ LIB_EXPORT int l_term_open(struct l_term *term)
 	IO_HANDLER(term, term->in_fd, 1, 0);
 	IO_HANDLER(term, term->out_fd, 0, 1);
 
-	term->is_running = true;
+	term->is_acquired = true;
 
 	return retval;
 }
 
-LIB_EXPORT int l_term_close(struct l_term *term)
+LIB_EXPORT int l_term_release(struct l_term *term)
 {
 	int retval = 0;
 
 	if (!term)
 		return -EINVAL;
 
-	term->is_running = false;
+	if (!term->is_acquired)
+		return -EALREADY;
 
 	IO_HANDLER(term, term->in_fd, 0, 0);
 	IO_HANDLER(term, term->out_fd, 0, 0);
@@ -347,6 +351,8 @@ LIB_EXPORT int l_term_close(struct l_term *term)
 	if (retval < 0)
 		return retval;
 
+	term->is_acquired = false;
+
 	return retval;
 }
 
diff --git a/ell/term.h b/ell/term.h
index 89ed6c97c7ce..50831c166c78 100644
--- a/ell/term.h
+++ b/ell/term.h
@@ -44,8 +44,8 @@ typedef void (*l_term_key_func_t) (struct l_term *term, wint_t wch, void *user_d
 int  l_term_set_key_handler(struct l_term *term,
 				l_term_key_func_t handler, void *user_data);
 
-int  l_term_open(struct l_term *term);
-int  l_term_close(struct l_term *term);
+int  l_term_acquire(struct l_term *term);
+int  l_term_release(struct l_term *term);
 
 bool l_term_io_callback(struct l_io *io, void *user_data);
 
-- 
2.45.0

