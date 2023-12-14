Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6D9F26C6D6
	for <ell@lists.linux.dev>; Thu, 14 Dec 2023 23:28:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from fedora.. (p5b3d29b7.dip0.t-ipconnect.de [91.61.41.183])
	by mail.holtmann.org (Postfix) with ESMTPSA id 110A2CECD9
	for <ell@lists.linux.dev>; Fri, 15 Dec 2023 00:28:07 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [RFC v3] edit: Add basic support for input line editing
Date: Fri, 15 Dec 2023 00:28:04 +0100
Message-ID: <20231214232804.34777-1-marcel@holtmann.org>
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

The debug option is something that might need to be removed or at least
changed a little bit, but right now it is nice to see the internal
states.

Following features are missing:

1) Work with words (delete, move etc.)
2) Tab completion
3) Hints system

Following features are left to the user:

1) Showing the prompt
2) Switching to masked input

The demo-edit is just for demonstration purposes and requires Curses to
be available without any autoconf magic.
---
 .gitignore  |   1 +
 Makefile.am |   7 +
 demo-edit.c | 501 +++++++++++++++++++++++++++++++++
 ell/edit.c  | 785 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/edit.h  |  59 ++++
 ell/ell.h   |   1 +
 ell/ell.sym |  25 ++
 7 files changed, 1379 insertions(+)
 create mode 100644 demo-edit.c
 create mode 100644 ell/edit.c
 create mode 100644 ell/edit.h

diff --git a/.gitignore b/.gitignore
index 2af4fb2d13b9..60d0b2d95852 100644
--- a/.gitignore
+++ b/.gitignore
@@ -93,3 +93,4 @@ tools/genl-discover
 tools/genl-watch
 tools/genl-request
 tools/gpio
+demo-edit
diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..284bbc0acc8d 100644
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
@@ -406,6 +408,11 @@ tools_genl_request_LDADD = ell/libell-private.la
 tools_gpio_SOURCES = tools/gpio.c
 tools_gpio_LDADD = ell/libell-private.la
 
+noinst_PROGRAMS += demo-edit
+
+demo_edit_SOURCES = demo-edit.c
+demo_edit_LDADD = ell/libell-private.la -lcursesw
+
 EXTRA_DIST = ell/ell.sym \
 		$(unit_test_data_files) unit/gencerts.cnf unit/plaintext.txt
 
diff --git a/demo-edit.c b/demo-edit.c
new file mode 100644
index 000000000000..2346142aabd4
--- /dev/null
+++ b/demo-edit.c
@@ -0,0 +1,501 @@
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
+#define _XOPEN_SOURCE_EXTENDED
+#include <stdio.h>
+#include <unistd.h>
+#include <signal.h>
+#include <locale.h>
+#include <langinfo.h>
+#include <curses.h>
+#include <wctype.h>
+#include <time.h>
+#include <ell/ell.h>
+
+#define ENCODING_UTF8	"UTF-8"
+
+#define UPDATE_RATE (5)
+
+static struct l_edit *edit;
+
+#define last_key_str_size (20)
+static wchar_t last_key_str[last_key_str_size] = L"";
+static int curs_visibility = 0;
+static bool show_time = false;
+static bool masked_input = false;
+
+static short prompt_color[] = { 1, 6, 7 };
+static const char *prompt_list[] = { "hello> ", "fun> ", "long-prompt> " };
+static unsigned int prompt_idx = 0;
+
+static int main_size_list[] = { 50, 70 };
+static unsigned int main_size_idx = 0;
+
+static size_t input_len_list[] = { 0, 12, 20 };
+static unsigned int input_len_idx = 0;
+
+static unsigned int history_size_list[] = { 100, 0, 15, 10 };
+static unsigned int history_size_idx = 0;
+
+static const char *history_pathname = "history.txt";
+static const char *history_alt_pathname = "history-alt.txt";
+
+static WINDOW *main_win;
+static WINDOW *info_win;
+static WINDOW *status_win;
+static WINDOW *command_win;
+
+static void set_cursor(void)
+{
+	curs_set(curs_visibility);
+
+	if (curs_visibility)
+		leaveok(stdscr, FALSE);
+	else
+		leaveok(stdscr, TRUE);
+}
+
+static const char *help_str[] = {
+	"Ctrl-Q  Load alternate history",
+	"Ctrl-R  Set sample input",
+	"Ctrl-S  Set history size",
+	"Ctrl-T  Switch time printouts",
+	"Ctrl-V  Set max input length",
+	"Ctrl-W  Set window size",
+	"Ctrl-X  Switch prompt",
+	"Ctrl-Z  Masked input",
+	NULL
+};
+
+static void update_debug(void)
+{
+	int x, y, max_y, max_x;
+	unsigned int i;
+
+	getyx(main_win, y, x);
+	getmaxyx(stdscr, max_y, max_x);
+
+	wmove(info_win, 0, 0);
+	wprintw(info_win, "(%d,%d) [%d,%d]   ", x, y, max_x, max_y);
+	waddwstr(info_win, last_key_str);
+	wclrtoeol(info_win);
+
+	getmaxyx(info_win, max_y, max_x);
+
+	wmove(info_win, 2, 0);
+	for (i = 0; help_str[i]; i++) {
+		waddnstr(info_win, help_str[i], max_x - 1);
+		waddch(info_win, '\n');
+	}
+
+	wnoutrefresh(info_win);
+	wnoutrefresh(main_win);
+	doupdate();
+}
+
+static void resize_display(void)
+{
+	int main_size = main_size_list[main_size_idx];
+	const char *prompt = prompt_list[prompt_idx];
+	size_t prompt_len;
+	int height, width;
+
+	getmaxyx(stdscr, height, width);
+
+	wresize(main_win, height - 2, main_size);
+	mvwin(main_win, 0, 0);
+
+	wresize(info_win, height - 2, width - main_size);
+	mvwin(info_win, 0, main_size);
+
+	wresize(status_win, 1, width);
+	mvwin(status_win, height - 2, 0);
+
+	wresize(command_win, 1, width);
+	mvwin(command_win, height - 1, 0);
+
+	wnoutrefresh(main_win);
+	wnoutrefresh(info_win);
+	wnoutrefresh(status_win);
+	wnoutrefresh(command_win);
+
+	prompt_len = strlen(prompt);
+	l_edit_set_max_display_length(edit, getmaxx(main_win) - prompt_len);
+
+	update_debug();
+}
+
+static void init_display(void)
+{
+	setlocale(LC_ALL, "");
+	if (strcmp(nl_langinfo(CODESET), ENCODING_UTF8))
+		printf("no %s\n", ENCODING_UTF8);
+
+	initscr();
+	nonl();
+	cbreak();
+	raw();
+	noecho();
+	use_extended_names(TRUE);
+
+	start_color();
+	use_default_colors();
+	init_extended_pair(1, COLOR_BLACK, -1);
+	init_pair(2, COLOR_BLACK, COLOR_WHITE);
+	init_pair(3, COLOR_WHITE, COLOR_BLUE);
+	init_extended_pair(6, COLOR_BLUE, -1);
+	init_extended_pair(7, COLOR_RED, -1);
+
+	main_win = newwin(1, 1, 0, 0);
+	info_win = newwin(1, 1, 0, 1);
+	status_win = newwin(1, 2, 1, 0);
+	command_win = newwin(1, 2, 2, 0);
+
+	wbkgdset(main_win, COLOR_PAIR(1));
+	wbkgdset(info_win, COLOR_PAIR(2));
+	wbkgdset(status_win, COLOR_PAIR(3));
+	wattrset(status_win, A_BOLD);
+	wbkgdset(command_win, COLOR_PAIR(1));
+
+	wclear(main_win);
+	wclear(info_win);
+	wclear(status_win);
+	wclear(command_win);
+	wmove(main_win, 0, 0);
+
+	keypad(main_win, TRUE);
+	meta(main_win, TRUE);
+	nodelay(main_win, TRUE);
+	scrollok(main_win, TRUE);
+
+	set_cursor();
+}
+
+static void reset_display(void)
+{
+	curs_set(1);
+	endwin();
+}
+
+static void update_status(void)
+{
+	wmove(status_win, 0, 0);
+	wprintw(status_win, "Hello %s", "Curses Demo");
+	wclrtoeol(status_win);
+
+	wnoutrefresh(status_win);
+	wnoutrefresh(main_win);
+	doupdate();
+}
+
+static void update_callback(struct l_timeout *timeout, void *user_data)
+{
+	if (show_time) {
+		time_t rawtime;
+		struct tm *tm;
+		char str[80];
+		int y;
+
+		wmove(main_win, getcury(main_win), 0);
+		wclrtoeol(main_win);
+
+		time(&rawtime);
+		tm = localtime(&rawtime);
+
+		strftime(str, sizeof(str), "%H:%M:%S", tm);
+		y = getcury(main_win);
+		mvwprintw(main_win, y, 0, "Time is %s\n", str);
+		wrefresh(main_win);
+
+		l_edit_refresh(edit);
+	}
+
+	l_timeout_modify(timeout, UPDATE_RATE);
+}
+
+static void handle_keycode(wint_t keycode)
+{
+	char *line;
+
+	switch (keycode) {
+	case KEY_DOWN:			/* down-arrow key */
+		l_edit_history_forward(edit);
+		break;
+	case KEY_UP:			/* up-arrow key */
+		l_edit_history_backward(edit);
+		break;
+	case KEY_LEFT:			/* left-arrow key */
+		l_edit_move_left(edit);
+		break;
+	case KEY_RIGHT:			/* right-arrow key */
+		l_edit_move_right(edit);
+		break;
+	case KEY_HOME:			/* home key */
+		l_edit_move_home(edit);
+		break;
+	case KEY_BACKSPACE:		/* backspace key */
+		l_edit_backspace(edit);
+		break;
+	case KEY_DL:			/* delete-line key */
+		l_edit_delete_all(edit);
+		break;
+	case KEY_DC:			/* delete-character key */
+		l_edit_delete(edit);
+		break;
+	case KEY_CLEAR:			/* clear-screen or erase key */
+		wclear(main_win);
+		l_edit_refresh(edit);
+		break;
+	case KEY_EOL:			/* clear-to-end-of-line key */
+		l_edit_truncate(edit);
+		break;
+	case KEY_ENTER:			/* enter/send key */
+		l_edit_move_end(edit);
+		waddch(main_win, '\n');
+		line = l_edit_enter(edit);
+		l_free(line);
+		break;
+	case KEY_RESET:			/* Reset or hard reset (unreliable) */
+		waddstr(main_win, "^C\n");
+		l_edit_reset(edit, NULL);
+		break;
+	case KEY_BTAB:			/* back-tab key */
+		break;
+	case KEY_END:			/* end key */
+		l_edit_move_end(edit);
+		break;
+	case KEY_RESIZE:		/* Terminal resize event */
+		resize_display();
+		break;
+	}
+}
+
+static void handle_cntrl(wint_t wch)
+{
+	switch (wch) {
+	case 1:		/* Ctrl-A */
+		handle_keycode(KEY_HOME);
+		break;
+	case 2:		/* Ctrl-B */
+		handle_keycode(KEY_LEFT);
+		break;
+	case 3:		/* Ctrl-C */
+		handle_keycode(KEY_RESET);
+		break;
+	case 4:		/* Ctrl-D */
+		if (l_edit_is_empty(edit)) {
+			l_edit_history_save(edit, history_pathname);
+			l_main_quit();
+		} else {
+			handle_keycode(KEY_DC);
+		}
+		break;
+	case 5:		/* Ctrl-E */
+		handle_keycode(KEY_END);
+		break;
+	case 6:		/* Ctrl-F */
+		handle_keycode(KEY_RIGHT);
+		break;
+	case 7:		/* Ctrl-G */
+		break;
+	case 8:		/* Ctrl-H */
+		handle_keycode(KEY_BACKSPACE);
+		break;
+	case 9:		/* Ctrl-I */
+		break;
+	case 10:	/* Ctrl-J */
+		break;
+	case 11:	/* Ctrl-K */
+		handle_keycode(KEY_EOL);
+		break;
+	case 12:	/* Ctrl-L */
+		handle_keycode(KEY_CLEAR);
+		break;
+	case 13:	/* Ctrl-M */
+		handle_keycode(KEY_ENTER);
+		break;
+	case 14:	/* Ctrl-N */
+		handle_keycode(KEY_DOWN);
+		break;
+	case 15:	/* Ctrl-O */
+		break;
+	case 16:	/* Ctrl-P */
+		handle_keycode(KEY_UP);
+		break;
+	case 17:	/* Ctrl-Q */
+		l_edit_history_load(edit, history_alt_pathname);
+		break;
+	case 18:	/* Ctrl-R */
+		l_edit_reset(edit, "Sample input string");
+		break;
+	case 19:	/* Ctrl-S */
+		history_size_idx++;
+		if (history_size_idx >= L_ARRAY_SIZE(history_size_list))
+			history_size_idx = 0;
+		l_edit_set_history_size(edit,
+					history_size_list[history_size_idx]);
+		break;
+	case 20:	/* Ctrl-T */
+		show_time = !show_time;
+		break;
+	case 21:	/* Ctrl-U */
+		handle_keycode(KEY_DL);
+		break;
+	case 22:	/* Ctrl-V */
+		input_len_idx++;
+		if (input_len_idx >= L_ARRAY_SIZE(input_len_list))
+			input_len_idx = 0;
+		l_edit_set_max_input_length(edit,
+					input_len_list[input_len_idx]);
+		break;
+	case 23:	/* Ctrl-W */
+		main_size_idx++;
+		if (main_size_idx >= L_ARRAY_SIZE(main_size_list))
+			main_size_idx = 0;
+		resize_display();
+		break;
+	case 24:	/* Ctrl-X */
+		prompt_idx++;
+		if (prompt_idx >= L_ARRAY_SIZE(prompt_list))
+			prompt_idx = 0;
+		resize_display();
+		break;
+	case 25:	/* Ctrl-Y */
+		curs_visibility = !curs_visibility;
+		set_cursor();
+		l_edit_refresh(edit);
+		break;
+	case 26:	/* Ctrl-Z */
+		masked_input = !masked_input;
+		l_edit_refresh(edit);
+		break;
+	}
+}
+
+static void handle_print(wint_t wch)
+{
+	l_edit_insert(edit, wch);
+}
+
+static bool stdin_callback(struct l_io *io, void *user_data)
+{
+	wint_t wch;
+
+	switch (wget_wch(main_win, &wch)) {
+	case OK:
+		if (iswcntrl(wch)) {
+			swprintf(last_key_str, last_key_str_size,
+						L"%s (%d)", unctrl(wch), wch);
+			update_debug();
+			handle_cntrl(wch);
+		} else if (iswprint(wch)) {
+			swprintf(last_key_str, last_key_str_size,
+						L"%lc (%d)", wch, wch);
+			update_debug();
+			handle_print(wch);
+		}
+		break;
+	case KEY_CODE_YES:
+		if (wch >= KEY_MIN) {
+			swprintf(last_key_str, last_key_str_size,
+						L"%s (%d)", keyname(wch), wch);
+			update_debug();
+			handle_keycode(wch);
+		}
+		break;
+	}
+
+	return true;
+}
+
+static void display_handler(const wchar_t *wstr, size_t wlen,
+						size_t pos, void *user_data)
+{
+	const char *prompt = prompt_list[prompt_idx];
+	size_t prompt_len = strlen(prompt);
+	int prompt_attr = COLOR_PAIR(prompt_color[prompt_idx]);
+	int y;
+
+	y = getcury(main_win);
+	wmove(main_win, y, 0);
+	wattron(main_win, prompt_attr);
+	waddnstr(main_win, prompt, prompt_len);
+	wattroff(main_win, prompt_attr);
+	if (wlen > 0) {
+		if (masked_input) {
+			char *tmp = l_malloc(wlen);
+			memset(tmp, '*', wlen);
+			waddnstr(main_win, tmp, wlen);
+			l_free(tmp);
+		} else
+			waddnwstr(main_win, wstr, wlen);
+	}
+	wclrtoeol(main_win);
+
+	if (!curs_visibility)
+		mvwchgat(main_win, y, prompt_len + pos, 1, A_COLOR, 2, NULL);
+	wmove(main_win, y, prompt_len + pos);
+
+	wrefresh(main_win);
+}
+
+static void debug_handler(const char *str, void *user_data)
+{
+	wmove(info_win, 12, 0);
+	if (str)
+		waddstr(info_win, str);
+	wclrtobot(info_win);
+
+	wnoutrefresh(info_win);
+	wnoutrefresh(main_win);
+	doupdate();
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_io *stdin_io;
+	struct l_timeout *update_to;
+	int exit_status;
+
+	l_main_init();
+
+	init_display();
+
+	edit = l_edit_new();
+	l_edit_set_debug_handler(edit, debug_handler, NULL);
+	l_edit_set_max_input_length(edit, input_len_list[input_len_idx]);
+	l_edit_set_history_size(edit, history_size_list[history_size_idx]);
+	l_edit_set_display_handler(edit, display_handler, NULL);
+	l_edit_history_load(edit, history_pathname);
+
+	resize_display();
+	update_debug();
+	update_status();
+
+	stdin_io = l_io_new(STDIN_FILENO);
+	l_io_set_read_handler(stdin_io, stdin_callback, NULL, NULL);
+
+	update_to = l_timeout_create(UPDATE_RATE, update_callback, NULL, NULL);
+
+	exit_status = l_main_run();
+
+	l_timeout_remove(update_to);
+
+	l_io_destroy(stdin_io);
+
+	l_edit_free(edit);
+
+	reset_display();
+
+	l_main_exit();
+
+	return exit_status;
+}
diff --git a/ell/edit.c b/ell/edit.c
new file mode 100644
index 000000000000..899fea4da830
--- /dev/null
+++ b/ell/edit.c
@@ -0,0 +1,785 @@
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
+#include <stdio.h>
+#include <fcntl.h>
+#include <unistd.h>
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
+static struct input_buf *alloc_sized_input_buf(size_t initial_size)
+{
+	struct input_buf *buf;
+
+	buf = l_new(struct input_buf, 1);
+
+	/* Set up new input buffer with initial size */
+	buf->size = initial_size + 1;
+	buf->buf = l_malloc(sizeof(wchar_t) * buf->size);
+	buf->buf[0] = L'\0';
+	buf->pos = 0;
+	buf->len = 0;
+	buf->next = NULL;
+
+	return buf;
+}
+
+static struct input_buf *alloc_duplicate_input_buf(struct input_buf *ref)
+{
+	struct input_buf *buf;
+
+	if (!ref)
+		return NULL;
+
+	buf = l_new(struct input_buf, 1);
+
+	/* Set up new input buffer and copy from the reference */
+	buf->size = ref->len;
+	buf->buf = wcsdup(ref->buf);
+	buf->pos = ref->len;
+	buf->len = ref->len;
+	buf->next = NULL;
+
+	return buf;
+}
+
+static void reset_input_buf(struct input_buf *buf, const char *input)
+{
+	if (input) {
+		size_t len;
+
+		/* Calculate the required size of the wide character string
+		 * including its terminating null character.
+		 */
+		len = mbstowcs(NULL, input, 0) + 1;
+
+		/* If the current buffer is to small, then allocate a new
+		 * one and free the previous one. Since in most cases the
+		 * data is different, there is no need for using re-alloc
+		 * procedure here.
+		 */
+		if (len > buf->size) {
+			l_free(buf->buf);
+
+			buf->size = len;
+			buf->buf = l_malloc(sizeof(wchar_t) * buf->size);
+		}
+
+		/* Convert the multibyte input into a wide character string
+		 * and then move the cursor to the end.
+		 */
+		buf->len = mbstowcs(buf->buf, input, buf->size);
+		buf->pos = buf->len;
+	} else {
+		/* Reset the main item to an empty string */
+		buf->buf[0] = L'\0';
+		buf->pos = 0;
+		buf->len = 0;
+	}
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
+	static size_t initial_size = 15;
+	struct l_edit *edit;
+
+	edit = l_new(struct l_edit, 1);
+
+	edit->head = alloc_sized_input_buf(initial_size);
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
+
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
+	/* Convert the wide character string into the multibyte string
+	 * representation like UTF-8 for example.
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
+			buf = alloc_duplicate_input_buf(edit->main);
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
+LIB_EXPORT bool l_edit_reset(struct l_edit *edit, const char *input)
+{
+	if (!edit)
+		return false;
+
+	/* Reset the main item back to the head of the history before
+	 * resetting it or overwriting it with the provided input.
+	 */
+	edit->main = edit->head;
+
+	reset_input_buf(edit->main, input);
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
+	/* If length is already the same as the max size of a possible
+	 * string, there is nothing more to add.
+	 */
+	if (edit->main->len == SIZE_MAX)
+		return false;
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
+LIB_EXPORT bool l_edit_delete_all(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* Keep the buffer allocated, but reset it to an empty string */
+	edit->main->buf[0] = L'\0';
+	edit->main->pos = 0;
+	edit->main->len = 0;
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_truncate(struct l_edit *edit)
+{
+	if (!edit)
+		return false;
+
+	/* Keep the buffer allocated, but truncate after the cursor */
+	edit->main->buf[edit->main->pos] = L'\0';
+	edit->main->len = edit->main->pos;
+	update_display(edit);
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
+
+LIB_EXPORT bool l_edit_history_load(struct l_edit *edit, const char *pathname)
+{
+	static size_t initial_line_size = 16;
+	struct input_buf *buf;
+	struct l_string *str;
+	size_t count;
+	int fd;
+
+	if (!edit)
+		return false;
+
+	if (!pathname)
+		return false;
+
+	if (!edit->max_list_size)
+		return true;
+
+	fd = open(pathname, O_RDONLY);
+	if (fd < 0)
+		return false;
+
+	str = l_string_new(initial_line_size);
+
+	buf = edit->head;
+	count = 0;
+
+	while (count < edit->max_list_size) {
+		char *tmp;
+		char ch;
+		int res;
+
+		res = read(fd, &ch, 1);
+		if (res != 1)
+			break;
+
+		if (ch != '\n') {
+			l_string_append_c(str, ch);
+			continue;
+		}
+
+		tmp = l_string_unwrap(str);
+
+		/* If there is not next item, but max count has not yet
+		 * reached a new items is created. Otherwise the existing
+		 * item is overwritten.
+		 */
+		if (!buf->next)
+			buf->next = alloc_sized_input_buf(0);
+
+		/* Fill the item with input from the history file */
+		reset_input_buf(buf->next, tmp);
+		buf = buf->next;
+		count++;
+
+		l_free(tmp);
+
+		str = l_string_new(initial_line_size);
+	}
+
+	l_string_free(str);
+
+	close(fd);
+
+	edit->list_count = count;
+	update_display(edit);
+
+	return true;
+}
+
+LIB_EXPORT bool l_edit_history_save(struct l_edit *edit, const char *pathname)
+{
+	struct input_buf *buf;
+	int fd;
+
+	if (!edit)
+		return false;
+
+	if (!pathname)
+		return false;
+
+	fd = open(pathname, O_CREAT|O_WRONLY|O_TRUNC, S_IRUSR|S_IWUSR);
+	if (fd < 0)
+		return false;
+
+	buf = edit->head->next;
+
+	while (buf) {
+		char *tmp;
+		size_t len;
+
+		len = wcstombs(NULL, buf->buf, 0) + 1;
+		tmp = l_malloc(len);
+		wcstombs(tmp, buf->buf, len);
+		dprintf(fd, "%s\n", tmp);
+		l_free(tmp);
+
+		buf = buf->next;
+	}
+
+	close(fd);
+
+	return true;
+}
diff --git a/ell/edit.h b/ell/edit.h
new file mode 100644
index 000000000000..45ad2e657156
--- /dev/null
+++ b/ell/edit.h
@@ -0,0 +1,59 @@
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
+bool l_edit_reset(struct l_edit *edit, const char *input);
+bool l_edit_insert(struct l_edit *edit, wint_t ch);
+bool l_edit_delete(struct l_edit *edit);
+bool l_edit_delete_all(struct l_edit *edit);
+bool l_edit_truncate(struct l_edit *edit);
+bool l_edit_backspace(struct l_edit *edit);
+bool l_edit_move_left(struct l_edit *edit);
+bool l_edit_move_right(struct l_edit *edit);
+bool l_edit_move_home(struct l_edit *edit);
+bool l_edit_move_end(struct l_edit *edit);
+bool l_edit_history_backward(struct l_edit *edit);
+bool l_edit_history_forward(struct l_edit *edit);
+bool l_edit_history_load(struct l_edit *edit, const char *pathname);
+bool l_edit_history_save(struct l_edit *edit, const char *pathname);
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
index a887b2b09520..eaf699a43d34 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -617,6 +617,31 @@ global:
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
+	l_edit_delete_all;
+	l_edit_truncate;
+	l_edit_backspace;
+	l_edit_move_left;
+	l_edit_move_right;
+	l_edit_move_home;
+	l_edit_move_end;
+	l_edit_history_backward;
+	l_edit_history_forward;
+	l_edit_history_load;
+	l_edit_history_save;
 	/* gpio */
 	l_gpio_chips_with_line_label;
 	l_gpio_chip_new;
-- 
2.43.0

