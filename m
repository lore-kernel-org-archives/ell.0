Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F176E153560
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164951; cv=none; b=mkzFssmHwBZ1x/h+hOrlOSofh+xuealTSJjuw9wg2UDUNGNlcLMDQ+6bywMaB8QxGSm1zeMWmjeNI4kpsXWhYNH8zQT+FGhB5sot6JU4v0VOfBcSmZYYoFPWsm31yXp3vWTflUS35LvjZpWndhaUK0KYsIyfUnnU+GqQDnFDbHQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164951; c=relaxed/simple;
	bh=9Z0rKuHfX8VpEtPRLAMjBBNyCWEiSo3hmb8Sr6kt4rQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=u5uESgOToekaG6sJvj9D0hA3EXB7oeb4fFwAu08ZRzpILgkWInz0jV36yhgs8RCH4wrvlLofTIGvY40E8Wi+z/61AvE444ylWsSg92uc+IXxbsOlhkz6x2TtTCC7Z6CdrLqbCliUqMSoCB7iJx8rYgmBsnsHmRxU/ek6HCJIK6U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=bij7kg3L; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="bij7kg3L"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 52757164A91;
	Wed,  3 Apr 2024 13:22:25 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id E89AE124F67;
	Wed,  3 Apr 2024 13:22:24 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell/edit: Rename 'l_term_{open,close}'.
Date: Wed,  3 Apr 2024 10:22:15 -0700
Message-ID: <20240403172216.3254805-8-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=EG4tb5xX+mesGJUspLipN+6R8TYDeOji95KDmarHLNA=; b=bij7kg3LxseapeKRO+RRAQEPAorsRBjiOJbr+4gyzbXZdnW8+/jKI4NQ9cA6F/M6MQmia+EXvMAP1S2yWTavgl2W8e1YuUhTAzRuskUwrwuVtDQD+vwzBNwxsL6SeDwpl+FAScC6mHuL15N3TTteD5StytUDy52JJcAJ8Nld+5ZQG1JoW8yMH4s2Nf3E/KE9H1ByQBsGiBFInIpw3wt/ViZV+5Xf9qWzRhbJoxUXNqH+RoDzNEJkxcutj6iYGyq2/AvK9CmUj/gJc6pKFTGuvrJJyrau0/u8IBN175TQb/gCffySCPmZkS4KXAbqtjsf9qRK6L/heqoR+uziCuuI9g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This renames 'l_term_{open,close}' to 'l_term_{acquire,release}' since
this aligns more closely with what is happening with the underlying
file descriptors. In particular, those descriptors are not being
opened or closed. Rather, their TTY parameters are being saved and
altered on 'open' (now 'acquire') and restored on 'close' (now
'release'). At no point are the descriptors being transformed with the
'open' or 'close' system calls.
---
 ell/ell.sym |  4 ++--
 ell/term.c  | 18 ++++++++++++------
 ell/term.h  |  4 ++--
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 2767bf55e079..0026bbe1afcf 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -632,8 +632,8 @@ global:
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
index 29d31987939a..86050740e967 100644
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
2.42.0

