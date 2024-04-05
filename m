Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BC28639
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276419; cv=none; b=GqBKo5vpi/Z3Bnf6vVolQEwrcaFrb3uyN2/n/57v3leS4big8pSF8qYXO3UTZnpCTs5xywKbykc7/kBMkumCd7VKAuzlawTJgbfMxGttAK5JnSmwYC7sducYE+VzybTp+oe5RIGaJtJNAf9T9lvlCFkKFgaz50U3EQ1T4aIKVXM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276419; c=relaxed/simple;
	bh=nUMELJvOuV+5y32bL1hffSD18n/iiQApT4t3IjxYlwA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hk/xOJn24Mz2c/k4dkWmVwDK825jyvtza77kUj7y+ldzEuyeBM+eOIJ8t8aJqa3zWhvsBOvqmhDynZZjFPJ7SSFQv0FoWo6VhinB1ZALHRaW1CgbbK7aCQ6agpBo8UP4PEpLk8qssV0wDRyMUcwo5xwre4WK8DN+K/biiourLiY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=TJdLPT5F; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="TJdLPT5F"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id D2C22164A14;
	Thu,  4 Apr 2024 20:20:16 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 74CBD124F66;
	Thu,  4 Apr 2024 20:20:16 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] edit: change return signatures from 'bool' to 'int'
Date: Thu,  4 Apr 2024 17:20:09 -0700
Message-ID: <20240405002011.3480886-7-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240405002011.3480886-1-gerickson@nuovations.com>
References: <20240405002011.3480886-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=k3tChCo+HiFC87QnQ8vq0Arb8bv66qm1AwVylkOi9us=; b=TJdLPT5FKQei4DRiBsPpyCrpm96gfgFH8oH2j0EXI1IcXo6onEUd7tGCdcB7OsP1FJqlQ6pmOc82eQBbaqA4iyvu9fBVA0uJb+ve+kWr1vFLPDvcK1U9Mzf47LrXoZbSKki3qDkqXUeAnZ2YgZg+st4Nnf5f9zHCwrAm7ThipXTN5r/abQncYD13LHU3or+u2GizJ61CLiaDyD1a0E8WDGx5oi4Zd/K5/ruRbK7lAEF4AUXfTT3CaWqsef3S81Qex+UFB8bYD+a8VgGXReAzMbG6EGFRhdMsGOI/ZdXK/FgfMoor1G51TnTHZasSL85bO/cm81lbKvPciWxRz+ym4w==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Using an 'int' signature with 0 for success and < 0 for failure with
failure enumerations sources from the negated POSIX errors from errno.h
eases system integration by precluding system integrators from having
to synthesize their own errors on the prior 'false' returns.
---
 ell/edit.c | 136 ++++++++++++++++++++++++++---------------------------
 ell/edit.h |  40 ++++++++--------
 2 files changed, 88 insertions(+), 88 deletions(-)

diff --git a/ell/edit.c b/ell/edit.c
index 54cfc566c4ad..d6329d063c78 100644
--- a/ell/edit.c
+++ b/ell/edit.c
@@ -234,18 +234,18 @@ static void update_debug(struct l_edit *edit)
 	l_free(tmp);
 }
 
-LIB_EXPORT bool l_edit_set_debug_handler(struct l_edit *edit,
+LIB_EXPORT int l_edit_set_debug_handler(struct l_edit *edit,
 				l_edit_debug_func_t handler, void *user_data)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	edit->debug_handler = handler;
 	edit->debug_data = user_data;
 
 	update_debug(edit);
 
-	return true;
+	return 0;
 }
 
 static void update_display(struct l_edit *edit)
@@ -275,36 +275,36 @@ static void update_display(struct l_edit *edit)
 	update_debug(edit);
 }
 
-LIB_EXPORT bool l_edit_set_display_handler(struct l_edit *edit,
+LIB_EXPORT int l_edit_set_display_handler(struct l_edit *edit,
 				l_edit_display_func_t handler, void *user_data)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	edit->display_handler = handler;
 	edit->display_data = user_data;
 
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_set_max_display_length(struct l_edit *edit, size_t len)
+LIB_EXPORT int l_edit_set_max_display_length(struct l_edit *edit, size_t len)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	edit->max_display_len= len;
 
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_set_max_input_length(struct l_edit *edit, size_t len)
+LIB_EXPORT int l_edit_set_max_input_length(struct l_edit *edit, size_t len)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* When switching to unlimited input length, then nothing is there
 	 * do to, except storing the value. Refreshing the display is not
@@ -313,7 +313,7 @@ LIB_EXPORT bool l_edit_set_max_input_length(struct l_edit *edit, size_t len)
 	if (len == 0) {
 		edit->max_input_len = 0;
 		update_debug(edit);
-		return true;
+		return 0;
 	}
 
 	edit->max_input_len = len;
@@ -334,13 +334,13 @@ LIB_EXPORT bool l_edit_set_max_input_length(struct l_edit *edit, size_t len)
 		update_debug(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_set_history_size(struct l_edit *edit, unsigned int size)
+LIB_EXPORT int l_edit_set_history_size(struct l_edit *edit, unsigned int size)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	edit->max_list_size = size;
 
@@ -382,17 +382,17 @@ LIB_EXPORT bool l_edit_set_history_size(struct l_edit *edit, unsigned int size)
 
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_refresh(struct l_edit *edit)
+LIB_EXPORT int l_edit_refresh(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
 LIB_EXPORT bool l_edit_is_empty(struct l_edit *edit)
@@ -463,10 +463,10 @@ LIB_EXPORT char *l_edit_enter(struct l_edit *edit)
 	return str;
 }
 
-LIB_EXPORT bool l_edit_reset(struct l_edit *edit, const char *input)
+LIB_EXPORT int l_edit_reset(struct l_edit *edit, const char *input)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* Reset the main item back to the head of the history before
 	 * resetting it or overwriting it with the provided input.
@@ -476,17 +476,17 @@ LIB_EXPORT bool l_edit_reset(struct l_edit *edit, const char *input)
 	reset_input_buf(edit->main, input);
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_insert(struct l_edit *edit, wint_t ch)
+LIB_EXPORT int l_edit_insert(struct l_edit *edit, wint_t ch)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* Check if the max input length has already been reached */
 	if (edit->max_input_len && edit->main->len >= edit->max_input_len)
-		return false;
+		return -EALREADY;
 
 	/* This will magically grow the buffer to make room for at least
 	 * one wide character.
@@ -497,7 +497,7 @@ LIB_EXPORT bool l_edit_insert(struct l_edit *edit, wint_t ch)
 	 * string, there is nothing more to add.
 	 */
 	if (edit->main->len == SIZE_MAX)
-		return false;
+		return -ENOBUFS;
 
 	/* If the cursor is not at the end, the new character has to be
 	 * inserted and for thus the tail portion needs to move one
@@ -513,13 +513,13 @@ LIB_EXPORT bool l_edit_insert(struct l_edit *edit, wint_t ch)
 	edit->main->buf[edit->main->len] = L'\0';
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_delete(struct l_edit *edit)
+LIB_EXPORT int l_edit_delete(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the end, deletion of a character means
 	 * that the tail moves one character forward.
@@ -533,13 +533,13 @@ LIB_EXPORT bool l_edit_delete(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_delete_all(struct l_edit *edit)
+LIB_EXPORT int l_edit_delete_all(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* Keep the buffer allocated, but reset it to an empty string */
 	edit->main->buf[0] = L'\0';
@@ -547,26 +547,26 @@ LIB_EXPORT bool l_edit_delete_all(struct l_edit *edit)
 	edit->main->len = 0;
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_truncate(struct l_edit *edit)
+LIB_EXPORT int l_edit_truncate(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* Keep the buffer allocated, but truncate after the cursor */
 	edit->main->buf[edit->main->pos] = L'\0';
 	edit->main->len = edit->main->pos;
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_backspace(struct l_edit *edit)
+LIB_EXPORT int l_edit_backspace(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the beginning, the backspace operation
 	 * means that tail has to move one character forward.
@@ -581,13 +581,13 @@ LIB_EXPORT bool l_edit_backspace(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_move_left(struct l_edit *edit)
+LIB_EXPORT int l_edit_move_left(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the beginning, then move it one back */
 	if (edit->main->pos > 0) {
@@ -595,13 +595,13 @@ LIB_EXPORT bool l_edit_move_left(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_move_right(struct l_edit *edit)
+LIB_EXPORT int l_edit_move_right(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the end, then move it one forward */
 	if (edit->main->pos != edit->main->len) {
@@ -609,13 +609,13 @@ LIB_EXPORT bool l_edit_move_right(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_move_home(struct l_edit *edit)
+LIB_EXPORT int l_edit_move_home(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the beginning, move it there */
 	if (edit->main->pos != 0) {
@@ -623,13 +623,13 @@ LIB_EXPORT bool l_edit_move_home(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_move_end(struct l_edit *edit)
+LIB_EXPORT int l_edit_move_end(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If the cursor is not at the end, move it there */
 	if (edit->main->pos != edit->main->len) {
@@ -637,13 +637,13 @@ LIB_EXPORT bool l_edit_move_end(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_history_backward(struct l_edit *edit)
+LIB_EXPORT int l_edit_history_backward(struct l_edit *edit)
 {
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* If there is another item in the history list, move the main
 	 * item to that and enforce the max input length on the new item.
@@ -654,15 +654,15 @@ LIB_EXPORT bool l_edit_history_backward(struct l_edit *edit)
 		update_display(edit);
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_history_forward(struct l_edit *edit)
+LIB_EXPORT int l_edit_history_forward(struct l_edit *edit)
 {
 	struct input_buf *buf;
 
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	/* Walk the list of history items until the current main item
 	 * matches the next item, then move the main item to current
@@ -677,10 +677,10 @@ LIB_EXPORT bool l_edit_history_forward(struct l_edit *edit)
 		}
 	}
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_history_load(struct l_edit *edit, const char *pathname)
+LIB_EXPORT int l_edit_history_load(struct l_edit *edit, const char *pathname)
 {
 	static size_t initial_line_size = 16;
 	struct input_buf *buf;
@@ -689,17 +689,17 @@ LIB_EXPORT bool l_edit_history_load(struct l_edit *edit, const char *pathname)
 	int fd;
 
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	if (!pathname)
-		return false;
+		return -EINVAL;
 
 	if (!edit->max_list_size)
-		return true;
+		return 0;
 
 	fd = open(pathname, O_RDONLY);
 	if (fd < 0)
-		return false;
+		return -errno;
 
 	str = l_string_new(initial_line_size);
 
@@ -746,23 +746,23 @@ LIB_EXPORT bool l_edit_history_load(struct l_edit *edit, const char *pathname)
 	edit->list_count = count;
 	update_display(edit);
 
-	return true;
+	return 0;
 }
 
-LIB_EXPORT bool l_edit_history_save(struct l_edit *edit, const char *pathname)
+LIB_EXPORT int l_edit_history_save(struct l_edit *edit, const char *pathname)
 {
 	struct input_buf *buf;
 	int fd;
 
 	if (!edit)
-		return false;
+		return -EINVAL;
 
 	if (!pathname)
-		return false;
+		return -EINVAL;
 
 	fd = open(pathname, O_CREAT|O_WRONLY|O_TRUNC, S_IRUSR|S_IWUSR);
 	if (fd < 0)
-		return false;
+		return -errno;
 
 	buf = edit->head->next;
 
@@ -781,5 +781,5 @@ LIB_EXPORT bool l_edit_history_save(struct l_edit *edit, const char *pathname)
 
 	close(fd);
 
-	return true;
+	return 0;
 }
diff --git a/ell/edit.h b/ell/edit.h
index decf261c7b9e..811246578894 100644
--- a/ell/edit.h
+++ b/ell/edit.h
@@ -22,35 +22,35 @@ void l_edit_free(struct l_edit *edit);
 
 typedef void (*l_edit_debug_func_t) (struct l_edit *edit, const char *str, void *user_data);
 
-bool l_edit_set_debug_handler(struct l_edit *edit,
+int  l_edit_set_debug_handler(struct l_edit *edit,
 				l_edit_debug_func_t handler, void *user_data);
 
 typedef void (*l_edit_display_func_t) (struct l_edit *edit, const wchar_t *wstr, size_t wlen,
 						size_t pos, void *user_data);
 
-bool l_edit_set_display_handler(struct l_edit *edit,
+int  l_edit_set_display_handler(struct l_edit *edit,
 				l_edit_display_func_t handler, void *user_data);
 
-bool l_edit_set_max_display_length(struct l_edit *edit, size_t len);
-bool l_edit_set_max_input_length(struct l_edit *edit, size_t len);
-bool l_edit_set_history_size(struct l_edit *edit, unsigned int size);
-bool l_edit_refresh(struct l_edit *edit);
+int  l_edit_set_max_display_length(struct l_edit *edit, size_t len);
+int  l_edit_set_max_input_length(struct l_edit *edit, size_t len);
+int  l_edit_set_history_size(struct l_edit *edit, unsigned int size);
+int  l_edit_refresh(struct l_edit *edit);
 bool l_edit_is_empty(struct l_edit *edit);
 char *l_edit_enter(struct l_edit *edit);
-bool l_edit_reset(struct l_edit *edit, const char *input);
-bool l_edit_insert(struct l_edit *edit, wint_t ch);
-bool l_edit_delete(struct l_edit *edit);
-bool l_edit_delete_all(struct l_edit *edit);
-bool l_edit_truncate(struct l_edit *edit);
-bool l_edit_backspace(struct l_edit *edit);
-bool l_edit_move_left(struct l_edit *edit);
-bool l_edit_move_right(struct l_edit *edit);
-bool l_edit_move_home(struct l_edit *edit);
-bool l_edit_move_end(struct l_edit *edit);
-bool l_edit_history_backward(struct l_edit *edit);
-bool l_edit_history_forward(struct l_edit *edit);
-bool l_edit_history_load(struct l_edit *edit, const char *pathname);
-bool l_edit_history_save(struct l_edit *edit, const char *pathname);
+int  l_edit_reset(struct l_edit *edit, const char *input);
+int  l_edit_insert(struct l_edit *edit, wint_t ch);
+int  l_edit_delete(struct l_edit *edit);
+int  l_edit_delete_all(struct l_edit *edit);
+int  l_edit_truncate(struct l_edit *edit);
+int  l_edit_backspace(struct l_edit *edit);
+int  l_edit_move_left(struct l_edit *edit);
+int  l_edit_move_right(struct l_edit *edit);
+int  l_edit_move_home(struct l_edit *edit);
+int  l_edit_move_end(struct l_edit *edit);
+int  l_edit_history_backward(struct l_edit *edit);
+int  l_edit_history_forward(struct l_edit *edit);
+int  l_edit_history_load(struct l_edit *edit, const char *pathname);
+int  l_edit_history_save(struct l_edit *edit, const char *pathname);
 
 #ifdef __cplusplus
 }
-- 
2.42.0

