Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 08E445B5DC
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 21:23:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from fedora.. (p5b3d29b7.dip0.t-ipconnect.de [91.61.41.183])
	by mail.holtmann.org (Postfix) with ESMTPSA id 2E5ADCECD5
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 22:23:23 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [RFC] edit: Add basic support for input line editing
Date: Wed, 13 Dec 2023 22:23:20 +0100
Message-ID: <20231213212320.35741-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This allows for simple line editing with history capabilities. On
purpose this has no concept of terminal input or terminal output and
just allows manipulation of an internal wide character string.

The history storing and loading is currently missing, but would be easy
to add. The other two items are missing completion and hints handling.

This feature is not yet complete, but good enough for a first review and
a sample application using it in a curses environment will follow.

The debug option is something that might need to be removed or at least
changed a little bit, but right now it is nice to see the internal
states.
---
 Makefile.am |   2 +
 ell/edit.c  | 595 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/edit.h  |  55 +++++
 ell/ell.h   |   1 +
 ell/ell.sym |  21 ++
 5 files changed, 674 insertions(+)
 create mode 100644 ell/edit.c
 create mode 100644 ell/edit.h

diff --git a/Makefile.am b/Makefile.am
index b77db391be56..eab450f71618 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -55,6 +55,7 @@ pkginclude_HEADERS = ell/ell.h \
 			ell/ecc.h \
 			ell/ecdh.h \
 			ell/time.h \
+			ell/edit.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
@@ -145,6 +146,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/edit.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
diff --git a/ell/edit.c b/ell/edit.c
new file mode 100644
index 000000000000..42a6a016175e
--- /dev/null
+++ b/ell/edit.c
@@ -0,0 +1,595 @@
+/*
+ * Embedded Linux library
+ * Copyright (C) 2023  Intel Corporation
+ *
+ * SPDX-License-Identifier: LGPL-2.1-or-later
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <stdlib.h>
+
+#include "private.h"
+#include "string.h"
+#include "edit.h"
+
+#define DEFAULT_BUFFER_SIZE	(15)
+
+struct input_buf {
+	wchar_t *buf;
+	size_t size;
+	size_t len;
+	size_t pos;
+	struct input_buf *next;
+};
+
+struct l_edit {
+	struct input_buf *head;
+	struct input_buf *main;
+	size_t list_count;
+	size_t max_list_size;
+	size_t max_input_len;
+	size_t max_display_len;
+	l_edit_display_func_t display_handler;
+	void *display_data;
+	l_edit_debug_func_t debug_handler;
+	void *debug_data;
+};
+
+static inline size_t next_power(size_t len)
+{
+	size_t n = 1;
+
+	if (len > SIZE_MAX / 2)
+		return SIZE_MAX;
+
+	while (n < len)
+		n = n << 1;
+
+	return n;
+}
+
+static void grow_input_buf(struct input_buf *buf, size_t extra)
+{
+	if (buf->len + extra < buf->size)
+		return;
+
+	buf->size = next_power(buf->len + extra + 1);
+	buf->buf = l_realloc(buf->buf, sizeof(wchar_t) * buf->size);
+}
+
+static struct input_buf *alloc_input_buf(struct input_buf *ref)
+{
+	struct input_buf *buf;
+
+	buf = l_new(struct input_buf, 1);
+
+	if (ref) {
+		/* Set up new input buffer from the reference */
+		buf->size = ref->len;
+		buf->buf = wcsdup(ref->buf);
+		buf->pos = ref->len;
+		buf->len = ref->len;
+		buf->next = NULL;
+	} else {
+		/* Set up new input buffer with default buffer size */
+		grow_input_buf(buf, DEFAULT_BUFFER_SIZE);
+		buf->buf[0] = L'\0';
+		buf->pos = 0;
+		buf->len = 0;
+		buf->next = NULL;
+	}
+
+	return buf;
+}
+
+static void enforce_max_input_len(struct input_buf *buf, size_t max_len)
+{
+	/* When no limit is set, then nothing to do here */
+	if (max_len == 0)
+		return;
+
+	/* If the current buffer is to large, then truncate it and move
+	 * the cursor to the end if needed.
+	 */
+	if (buf->len > max_len) {
+		buf->len = max_len;
+		if (buf->pos > buf->len)
+			buf->pos = buf->len;
+		buf->buf[buf->len] = L'\0';
+	}
+}
+
+static void free_input_buf(struct input_buf *buf)
+{
+	l_free(buf->buf);
+	l_free(buf);
+}
+
+LIB_EXPORT struct l_edit *l_edit_new(void)
+{
+	struct l_edit *edit;
+
+	edit = l_new(struct l_edit, 1);
+
+	edit->head = alloc_input_buf(NULL);
+	edit->main = edit->head;
+	edit->list_count = 0;
+	edit->max_list_size = 0;
+	edit->max_input_len = 0;
+	edit->max_display_len = 0;
+
+	return edit;
+}
+
+LIB_EXPORT void l_edit_free(struct l_edit *edit)
+{
+	struct input_buf *buf;
+
+	if (!edit)
+		return;
+
+	buf = edit->head;
+	while (buf) {
+		struct input_buf *tmp = buf->next;
+		free_input_buf(buf);
+		buf = tmp;
+	}
+
+	l_free(edit);
+}
+
+static void update_debug(struct l_edit *edit)
+{
+	struct input_buf *buf;
+	struct l_string *str;
+	char *tmp;
+	size_t len;
+	unsigned int pos = 0;
+
+	if (!edit->debug_handler)
+		return;
+
+	str = l_string_new(edit->head->len + 32);
+
+	l_string_append_printf(str, "Display : %zu\n", edit->max_display_len);
+	l_string_append_printf(str, "Buffer  : %zu\n", edit->main->size);
+	if (edit->max_input_len)
+		l_string_append_printf(str, "Input   : %zu/%zu\n",
+					edit->main->len, edit->max_input_len);
+	else
+		l_string_append_printf(str, "Input   : %zu/unlimited\n",
+							edit->main->len);
+	l_string_append_printf(str, "Cursor  : %zu\n", edit->main->pos);
+	l_string_append_printf(str, "History : %zu/%zu\n",
+				edit->list_count, edit->max_list_size);
+
+	buf = edit->head;
+	while (buf) {
+		len = wcstombs(NULL, buf->buf, 0) + 1;
+		tmp = l_malloc(len);
+		wcstombs(tmp, buf->buf, len);
+		l_string_append_printf(str, "%3u %s\n", pos, tmp);
+		l_free(tmp);
+		pos++;
+		buf = buf->next;
+	}
+
+	tmp = l_string_unwrap(str);
+
+	edit->debug_handler(tmp, edit->debug_data);
+
+	l_free(tmp);
+}
+
+LIB_EXPORT bool l_edit_set_debug_handler(struct l_edit *edit,
+				l_edit_debug_func_t handler, void *user_data)
+{
+	if (!edit)
+		return false;
+
+	edit->debug_handler = handler;
+	edit->debug_data = user_data;
+
+	update_debug(edit);
+
+	return true;
+}
+
+static void update_display(struct l_edit *edit)
+{
+	const wchar_t *buf = edit->main->buf;
+	size_t len = edit->main->len;
+	size_t pos = edit->main->pos;
+
+	if (!edit->display_handler)
+		return;
+
+	if (edit->max_display_len > 0) {
+		/* Move buffer until current position is in display size */
+		while (pos >= edit->max_display_len) {
+			buf++;
+			len--;
+			pos--;
+		}
+
+		/* Reduce the length until it fits in display size */
+		while (len > edit->max_display_len)
+			len--;
+	}
+
+	edit->display_handler(buf, len, pos, edit->display_data);
+
+	update_debug(edit);
+}
+
+LIB_EXPORT bool l_edit_set_display_handler(struct l_edit *edit,
+				l_edit_display_func_t handler, void *user_data)
+{
+	if (!edit)
+		return false;
+
+	edit->display_handler = handler;
+	edit->display_data = user_data;
+
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_set_max_display_length(struct l_edit *edit, size_t len)
+{
+	if (!edit)
+		return false;
+
+	edit->max_display_len= len;
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_set_max_input_length(struct l_edit *edit, size_t len)
+{
+	if (!edit)
+		return false;
+
+	/* When switching to unlimited input length, then nothing is there
+	 * do to, except storing the value. Refreshing the display is not
+	 * needed since everything is already present.
+	 */
+	if (len == 0) {
+		edit->max_input_len = 0;
+		update_debug(edit);
+		return true;
+	}
+
+	edit->max_input_len = len;
+
+	if (edit->main->len > edit->max_input_len) {
+		/* If the current length is longer, then it is required to
+		 * truncate and if needed move the cursor to the end.
+		 */
+		edit->main->len = edit->max_input_len;
+		if (edit->main->pos > edit->main->len)
+			edit->main->pos = edit->main->len;
+		edit->main->buf[edit->main->len] = L'\0';
+		update_display(edit);
+	} else {
+		/* Since nothing has to be updated for the display, make
+		 * sure the debug output is updated manually.
+		 */
+		update_debug(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_set_history_size(struct l_edit *edit, unsigned int size)
+{
+	if (!edit)
+		return false;
+
+	edit->max_list_size = size;
+
+	if (edit->list_count > edit->max_list_size) {
+		struct input_buf *buf = edit->head;
+		struct input_buf *last;
+		size_t count = 0;
+
+		/* Truncating the history means, thattthe last still valid
+		 * entry needs to be found.
+		 */
+		while (count < edit->max_list_size) {
+			if (!buf->next)
+				break;
+			count++;
+			buf = buf->next;
+		}
+
+		/* Terminate the list on the last item and store it for
+		 * later use.
+		 */
+		last = buf;
+		buf = last->next;
+		last->next = NULL;
+
+		/* Now free the tail of the list. In case the history index
+		 * was present in the tail, move it to the last item.
+		 */
+		while (buf) {
+			struct input_buf *tmp = buf->next;
+			if (buf == edit->main)
+				edit->main = last;
+			free_input_buf(buf);
+			buf = tmp;
+		}
+
+		edit->list_count = count;
+	}
+
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_refresh(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_is_empty(struct l_edit *edit)
+{
+	if (!edit)
+		return true;
+
+	return (edit->main->len == 0);
+}
+
+LIB_EXPORT char *l_edit_enter(struct l_edit *edit)
+{
+	struct input_buf *buf;
+	char *str;
+	size_t len;
+
+	if (!edit)
+		return NULL;
+
+	/* Convert the wide character into the multibytes representation
+	 * like UTF-8 for example.
+	 */
+	len = wcstombs(NULL, edit->main->buf, 0) + 1;
+	str = l_malloc(len);
+	wcstombs(str, edit->main->buf, len);
+
+	if (edit->main->len > 0) {
+		/* If the current entered item is different from the first
+		 * one in history (if history is present), then allocate
+		 * a copy of that item and push it to the head of the
+		 * history list.
+		 */
+		if (!edit->head->next || wcscmp(edit->main->buf,
+						edit->head->next->buf)) {
+			buf = alloc_input_buf(edit->main);
+			buf->next = edit->head->next;
+			edit->head->next = buf;
+			edit->list_count++;
+		}
+
+		/* Reset the head item, since that becomes the next
+		 * main input item.
+		 */
+		edit->head->buf[0] = L'\0';
+		edit->head->pos = 0;
+		edit->head->len = 0;
+
+		/* If the history size has grown to large, remove the
+		 * last item from the list.
+		 */
+		if (edit->list_count > edit->max_list_size) {
+			buf = edit->head;
+			while (buf->next) {
+				if (!buf->next->next) {
+					free_input_buf(buf->next);
+					buf->next = NULL;
+					edit->list_count--;
+					break;
+				}
+				buf = buf->next;
+			}
+		}
+	}
+
+	edit->main = edit->head;
+	update_display(edit);
+
+	return str;
+}
+
+LIB_EXPORT bool l_edit_reset(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* Keep the buffer allocated, but reset it to an empty string */
+        edit->main->buf[0] = L'\0';
+	edit->main->pos = 0;
+	edit->main->len = 0;
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_insert(struct l_edit *edit, wint_t ch)
+{
+	if (!edit)
+		return false;
+
+	/* Check if the max input length has already been reached */
+	if (edit->max_input_len && edit->main->len >= edit->max_input_len)
+		return false;
+
+	/* This will magically grow the buffer to make room for at least
+	 * one wide character.
+	 */
+	grow_input_buf(edit->main, 1);
+
+	/* If the cursor is not at the end, the new character has to be
+	 * inserted and for thus the tail portion needs to move one
+	 * character back.
+	 */
+	if (edit->main->len != edit->main->pos)
+		wmemmove(edit->main->buf + edit->main->pos + 1,
+				edit->main->buf + edit->main->pos,
+				edit->main->len - edit->main->pos);
+	edit->main->buf[edit->main->pos] = ch;
+	edit->main->pos++;
+	edit->main->len++;
+	edit->main->buf[edit->main->len] = L'\0';
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_delete(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the end, deletion of a character means
+	 * that the tail moves one character forward.
+	 */
+	if (edit->main->len > 0 && edit->main->pos < edit->main->len) {
+		wmemmove(edit->main->buf + edit->main->pos,
+				edit->main->buf + edit->main->pos + 1,
+				edit->main->len - edit->main->pos - 1);
+		edit->main->len--;
+		edit->main->buf[edit->main->len] = L'\0';
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_backspace(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the beginning, the backspace operation
+	 * means that tail has to move one character forward.
+	 */
+	if (edit->main->pos > 0 && edit->main->len > 0) {
+	        wmemmove(edit->main->buf + edit->main->pos - 1,
+				edit->main->buf + edit->main->pos,
+				edit->main->len - edit->main->pos);
+		edit->main->pos--;
+		edit->main->len--;
+		edit->main->buf[edit->main->len] = L'\0';
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_move_left(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the beginning, then move it one back */
+	if (edit->main->pos > 0) {
+		edit->main->pos--;
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_move_right(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the end, then move it one forward */
+	if (edit->main->pos != edit->main->len) {
+		edit->main->pos++;
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_move_home(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the beginning, move it there */
+	if (edit->main->pos != 0) {
+		edit->main->pos = 0;
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_move_end(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If the cursor is not at the end, move it there */
+	if (edit->main->pos != edit->main->len) {
+		edit->main->pos = edit->main->len;
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_history_backward(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* If there is another item in the history list, move the main
+	 * item to that and enforce the max input length on the new item.
+	 */
+	if (edit->main->next) {
+		edit->main = edit->main->next;
+		enforce_max_input_len(edit->main, edit->max_input_len);
+		update_display(edit);
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_history_forward(struct l_edit *edit)
+{
+	struct input_buf *buf;
+
+	if (!edit)
+		return false;
+
+	/* Walk the list of history items until the current main item
+	 * matches the next item, then move the main item to current
+	 * item and ensure that the max input length requirement is met.
+	 */
+	for (buf = edit->head; buf; buf = buf->next) {
+		if (buf->next == edit->main) {
+			edit->main = buf;
+			enforce_max_input_len(edit->main, edit->max_input_len);
+			update_display(edit);
+			break;
+		}
+	}
+
+	return true;
+}
diff --git a/ell/edit.h b/ell/edit.h
new file mode 100644
index 000000000000..442e253e11bf
--- /dev/null
+++ b/ell/edit.h
@@ -0,0 +1,55 @@
+/*
+ * Embedded Linux library
+ * Copyright (C) 2023  Intel Corporation
+ *
+ * SPDX-License-Identifier: LGPL-2.1-or-later
+ */
+
+#ifndef __ELL_EDIT_H
+#define __ELL_EDIT_H
+
+#include <stdbool.h>
+#include <wchar.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_edit;
+
+struct l_edit *l_edit_new(void);
+void l_edit_free(struct l_edit *edit);
+
+typedef void (*l_edit_debug_func_t) (const char *str, void *user_data);
+
+bool l_edit_set_debug_handler(struct l_edit *edit,
+				l_edit_debug_func_t handler, void *user_data);
+
+typedef void (*l_edit_display_func_t) (const wchar_t *wstr, size_t wlen,
+						size_t pos, void *user_data);
+
+bool l_edit_set_display_handler(struct l_edit *edit,
+				l_edit_display_func_t handler, void *user_data);
+
+bool l_edit_set_max_display_length(struct l_edit *edit, size_t len);
+bool l_edit_set_max_input_length(struct l_edit *edit, size_t len);
+bool l_edit_set_history_size(struct l_edit *edit, unsigned int size);
+bool l_edit_refresh(struct l_edit *edit);
+bool l_edit_is_empty(struct l_edit *edit);
+char *l_edit_enter(struct l_edit *edit);
+bool l_edit_reset(struct l_edit *edit);
+bool l_edit_insert(struct l_edit *edit, wint_t ch);
+bool l_edit_delete(struct l_edit *edit);
+bool l_edit_backspace(struct l_edit *edit);
+bool l_edit_move_left(struct l_edit *edit);
+bool l_edit_move_right(struct l_edit *edit);
+bool l_edit_move_home(struct l_edit *edit);
+bool l_edit_move_end(struct l_edit *edit);
+bool l_edit_history_backward(struct l_edit *edit);
+bool l_edit_history_forward(struct l_edit *edit);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_EDIT_H */
diff --git a/ell/ell.h b/ell/ell.h
index f67339105e8f..875bbb2cd43f 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -46,6 +46,7 @@
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
 #include <ell/time.h>
+#include <ell/edit.h>
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index a887b2b09520..586f0fb54f54 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -617,6 +617,27 @@ global:
 	l_ecdh_generate_shared_secret;
 	/* time */
 	l_time_now;
+	/* edit */
+	l_edit_new;
+	l_edit_free;
+	l_edit_set_debug_handler;
+	l_edit_set_display_handler;
+	l_edit_set_max_display_length;
+	l_edit_set_max_input_length;
+	l_edit_set_history_size;
+	l_edit_refresh;
+	l_edit_is_empty;
+	l_edit_enter;
+	l_edit_reset;
+	l_edit_insert;
+	l_edit_delete;
+	l_edit_backspace;
+	l_edit_move_left;
+	l_edit_move_right;
+	l_edit_move_home;
+	l_edit_move_end;
+	l_edit_history_backward;
+	l_edit_history_forward;
 	/* gpio */
 	l_gpio_chips_with_line_label;
 	l_gpio_chip_new;
-- 
2.43.0

