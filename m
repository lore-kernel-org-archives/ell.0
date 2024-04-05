Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FB1817F8
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277426; cv=none; b=c30MIc7Qe3Lt//wQm10ldfRqsIK+MaUwPdnQJOoSnWrYu2Agz9Q/9HMNf76BlyUtK2SwrtB2U0hGPFWivCIClTvqLRFyXOm/5TLjp3LOWgBIR7qp3o5SSx9KuXLqN9+1m8UYx7sjBkxEQuhyD+5k4fi67pUxPLWX764+O8Wiajo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277426; c=relaxed/simple;
	bh=LRKhE3eEt/KnymzkA2tOO+VUaCc/OFwSL9WBWqAwBXU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ol2OPGEYbvN/ITZWFUbRRigfi4HjIwiPGdj+YT8emiwC1cMKEttyYraNpWwQPmWhtnlX/IxFpaBoWQMWIr13VYtlBLe7J3QdzMfUr+N7aB7ZzUtDj1JOURqPcPgLJ4xVQZgdkSeEmVL6sS5ScYpuz5XnYBY83J3xmWcOD8WzGSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=SOPeTKtu; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="SOPeTKtu"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 933261649CB;
	Thu,  4 Apr 2024 20:37:03 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 37D4F124F66;
	Thu,  4 Apr 2024 20:37:03 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] ell/edit: Rename 'l_term_{open,close}'.
Date: Thu,  4 Apr 2024 17:36:56 -0700
Message-ID: <20240405003658.3490494-8-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=n9I9oHSw5Ej7rbI8RLp5blPEzIJHLFM/BZcyEPnT9EQ=; b=SOPeTKtuBcYeFh/Zjy1M9Q+vR359L4V9iVhxHjSd9oMh+SxpcwL1mvkH1SCUH0VnpcyCoqbGMYTYDQwLqjem/2h5HV+cRvLT7fqsIPGC8/LukGnMrKoW3qbb9WAwPkzEyiHC2u7dNsTA4HnCbIA1sg6JT4MzsLg4nzoFmX1WZiMAlTY+/fsREWX7N7WSUC21QhNm/D9g4MyYRu4c8oDv20NYrDHpzGgcC7Hi/K1BVbEgSoq98bRePgeVdeo/55oZu13TU0wDfkVHC+g+wk8tzllZcA89svQR6bnDXEYOvCozKJjbknM9D5twYTW/ggL17AG4abNHs7XBJIGIHsDpdg==
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
2.42.0

