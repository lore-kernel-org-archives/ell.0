Content-Type: multipart/mixed; boundary="===============1762218185682167670=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH v2] [RFC PATCH] tester: Add framework for serialized test
 execution
Date: Mon, 15 Mar 2021 09:59:26 -0700
Message-ID: <20210315165926.17690-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1762218185682167670==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This adds a framework for running series of noninteractive tests
that are capable of executing more complex scenarios than a usual unit
test.

The framework enables staging of a test case processing:
- test pre-setup: can be used to prepare an initial testing environment
                  potentially common to between several test cases, e.g.,
		  put an emulator in a certain well known state.
- test setup: used to setup conditions specific for the test case
- test run: execute actual test case
- test teardown: Cleans up after test setup
- test post-teardown: Cleans up after test pre-setup

Additional command line options allow to run a selected group of tests
based either on a group prefix of the test name or a substring in test
description.
---
 Makefile.am  |   6 +-
 ell/ell.h    |   1 +
 ell/ell.sym  |  21 ++
 ell/tester.c | 780 +++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/tester.h |  97 +++++++
 5 files changed, 903 insertions(+), 2 deletions(-)
 create mode 100644 ell/tester.c
 create mode 100644 ell/tester.h

diff --git a/Makefile.am b/Makefile.am
index 2f9a4ce..4c65e9d 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -58,7 +58,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
-			ell/acd.h
+			ell/acd.h \
+			ell/tester.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -141,7 +142,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/path.c \
 			ell/icmp6.c \
 			ell/icmp6-private.h \
-			ell/acd.c
+			ell/acd.c \
+			ell/tester.c
 =

 ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index 22fddf7..d47d5cf 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -64,3 +64,4 @@
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
+#include <ell/tester.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 9938216..606513c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -665,6 +665,27 @@ global:
 	l_acd_set_debug;
 	l_acd_set_skip_probes;
 	l_acd_set_defend_policy;
+	/* tester */
+	l_tester_new;
+	l_tester_destroy;
+	l_tester_start;
+	l_tester_summarize;
+	l_tester_test_add;
+	l_tester_test_add_full;
+	l_tester_test_get_stage;
+	l_tester_get_data;
+	l_tester_pre_setup_complete;
+	l_tester_pre_setup_failed;
+	l_tester_setup_complete;
+	l_tester_setup_failed;
+	l_tester_test_passed;
+	l_tester_test_failed;
+	l_tester_test_abort;
+	l_tester_teardown_complete;
+	l_tester_teardown_failed;
+	l_tester_post_teardown_complete;
+	l_tester_post_teardown_failed;
+	l_tester_wait;
 local:
 	*;
 };
diff --git a/ell/tester.c b/ell/tester.c
new file mode 100644
index 0000000..5c5386e
--- /dev/null
+++ b/ell/tester.c
@@ -0,0 +1,780 @@
+/*
+ *
+ *  Embedded library
+ *
+ *  Copyright (C) 2021  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <getopt.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <signal.h>
+
+#include <sys/time.h>
+
+#include <ell/ell.h>
+
+#include "log.h"
+#include "private.h"
+#include "tester.h"
+
+/**
+ * SECTION:tester
+ * @short_description: Non-interactive test framework
+ *
+ * Non-interactive test framework
+ */
+
+#define COLOR_OFF	"\x1B[0m"
+#define COLOR_BLACK	"\x1B[0;30m"
+#define COLOR_RED	"\x1B[0;31m"
+#define COLOR_GREEN	"\x1B[0;32m"
+#define COLOR_YELLOW	"\x1B[0;33m"
+#define COLOR_BLUE	"\x1B[0;34m"
+#define COLOR_MAGENTA	"\x1B[0;35m"
+#define COLOR_HIGHLIGHT	"\x1B[1;39m"
+
+#define print_text(color, fmt, args...) \
+		l_info(color fmt COLOR_OFF, ## args)
+
+#define print_summary(label, color, value, fmt, args...) \
+		l_info("%-52s " color "%-10s" COLOR_OFF fmt, \
+							label, value, ## args)
+
+#define print_progress(name, color, fmt, args...) \
+		l_info(COLOR_HIGHLIGHT "%s" COLOR_OFF " - " \
+				color fmt COLOR_OFF, name, ## args)
+
+enum test_result {
+	TEST_RESULT_NOT_RUN,
+	TEST_RESULT_PASSED,
+	TEST_RESULT_FAILED,
+	TEST_RESULT_TIMED_OUT,
+};
+
+struct l_tester {
+	uint64_t start_time;
+	struct l_queue *tests;
+	const struct l_queue_entry *test_entry;
+	bool list_cases;
+	const char *prefix;
+	const char *substring;
+	l_tester_finish_func_t finish_callback;
+};
+
+struct test_case {
+	uint64_t start_time;
+	uint64_t end_time;
+	char *name;
+	enum test_result result;
+	enum l_tester_stage stage;
+	const void *test_data;
+	l_tester_data_func_t pre_setup_func;
+	l_tester_data_func_t setup_func;
+	l_tester_data_func_t test_func;
+	l_tester_data_func_t teardown_func;
+	l_tester_data_func_t post_teardown_func;
+	unsigned int timeout;
+	struct l_timeout *run_timer;
+	l_tester_destroy_func_t destroy;
+	void *user_data;
+	bool teardown;
+};
+
+static void destroy_test(void *data)
+{
+	struct test_case *test =3D data;
+
+	l_timeout_remove(test->run_timer);
+
+	if (test->destroy)
+		test->destroy(test->user_data);
+
+	l_free(test->name);
+	l_free(test);
+}
+
+static uint64_t get_elapsed_time(uint64_t base)
+{
+	uint64_t now;
+
+	now =3D l_time_now();
+
+	return l_time_diff(base, now);
+}
+
+static void teardown_callback(void *user_data)
+{
+	struct l_tester *tester =3D user_data;
+	struct test_case *test;
+
+	printf("teardown %p\n", tester->test_entry);
+
+	test =3D tester->test_entry->data;
+	printf("teardown data %p\n", tester->test_entry->data);
+	test->stage =3D L_TESTER_STAGE_TEARDOWN;
+	test->teardown =3D false;
+
+	printf("Test name %p\n", test->name);
+	printf("Test name %s\n", test->name);
+	print_progress(test->name, COLOR_MAGENTA, "teardown");
+	printf("teardown\n");
+
+
+	if (test->teardown_func)
+		test->teardown_func(test->test_data);
+	else
+		l_tester_teardown_complete(tester);
+}
+
+static void test_timeout(struct l_timeout *timer, void *user_data)
+{
+	struct l_tester *tester =3D user_data;
+	struct test_case *test;
+
+	test =3D tester->test_entry->data;
+
+	l_timeout_remove(timer);
+	test->run_timer =3D NULL;
+
+	test->result =3D TEST_RESULT_TIMED_OUT;
+	print_progress(test->name, COLOR_RED, "test timed out");
+
+	l_idle_oneshot(teardown_callback, tester, NULL);
+}
+
+static void next_test_case(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (tester->test_entry)
+		tester->test_entry =3D tester->test_entry->next;
+	else
+		tester->test_entry =3D l_queue_get_entries(tester->tests);
+
+	if (!tester->test_entry) {
+		if (tester->finish_callback)
+			tester->finish_callback(tester);
+		return;
+	}
+
+	test =3D tester->test_entry->data;
+
+	print_progress(test->name, COLOR_BLACK, "init");
+
+	test->start_time =3D get_elapsed_time(tester->start_time);
+
+	if (test->timeout > 0)
+		test->run_timer =3D l_timeout_create(test->timeout, test_timeout,
+								test, NULL);
+
+	test->stage =3D L_TESTER_STAGE_PRE_SETUP;
+
+	if (test->pre_setup_func)
+		test->pre_setup_func(test->test_data);
+	else
+		l_tester_pre_setup_complete(tester);
+}
+
+static void setup_callback(void *user_data)
+{
+	struct l_tester *tester =3D user_data;
+	struct test_case *test =3D tester->test_entry->data;
+
+	test->stage =3D L_TESTER_STAGE_SETUP;
+
+	print_progress(test->name, COLOR_BLUE, "setup");
+
+	if (test->setup_func)
+		test->setup_func(test->test_data);
+	else
+		l_tester_setup_complete(tester);
+}
+
+static void run_callback(void *user_data)
+{
+	struct l_tester *tester =3D user_data;
+	struct test_case *test =3D tester->test_entry->data;
+
+	test->stage =3D L_TESTER_STAGE_RUN;
+
+	print_progress(test->name, COLOR_BLACK, "run");
+	test->test_func(test->test_data);
+}
+
+static void done_callback(void *user_data)
+{
+	struct l_tester *tester =3D user_data;
+	struct test_case *test =3D tester->test_entry->data;
+
+	test->end_time =3D get_elapsed_time(tester->start_time);
+
+	print_progress(test->name, COLOR_BLACK, "done");
+	next_test_case(tester);
+}
+
+LIB_EXPORT void *l_tester_get_data(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return NULL;
+
+	if (!tester->test_entry)
+		return NULL;
+
+	test =3D tester->test_entry->data;
+
+	return test->user_data;
+}
+
+LIB_EXPORT void l_tester_pre_setup_complete(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_PRE_SETUP)
+		return;
+
+	l_idle_oneshot(setup_callback, tester, NULL);
+}
+
+LIB_EXPORT void l_tester_pre_setup_failed(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_PRE_SETUP)
+		return;
+
+	print_progress(test->name, COLOR_RED, "pre setup failed");
+
+	l_idle_oneshot(done_callback, tester, NULL);
+}
+
+LIB_EXPORT void l_tester_setup_complete(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_SETUP)
+		return;
+
+	print_progress(test->name, COLOR_BLUE, "setup complete");
+
+	l_idle_oneshot(run_callback, tester, NULL);
+}
+
+LIB_EXPORT void l_tester_setup_failed(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_SETUP)
+		return;
+
+	test->stage =3D L_TESTER_STAGE_POST_TEARDOWN;
+
+	l_timeout_remove(test->run_timer);
+	test->run_timer =3D NULL;
+
+	print_progress(test->name, COLOR_RED, "setup failed");
+	print_progress(test->name, COLOR_MAGENTA, "teardown");
+
+	test->post_teardown_func(test->test_data);
+}
+
+static void test_result(struct l_tester *tester, enum test_result result)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_RUN)
+		return;
+
+	l_timeout_remove(test->run_timer);
+	test->run_timer =3D NULL;
+
+	test->result =3D result;
+	switch (result) {
+	case TEST_RESULT_PASSED:
+		print_progress(test->name, COLOR_GREEN, "test passed");
+		break;
+	case TEST_RESULT_FAILED:
+		print_progress(test->name, COLOR_RED, "test failed");
+		break;
+	case TEST_RESULT_NOT_RUN:
+		print_progress(test->name, COLOR_YELLOW, "test not run");
+		break;
+	case TEST_RESULT_TIMED_OUT:
+		print_progress(test->name, COLOR_RED, "test timed out");
+		break;
+	}
+
+	if (test->teardown)
+		return;
+
+	test->teardown =3D true;
+
+	l_idle_oneshot(teardown_callback, tester, NULL);
+}
+
+LIB_EXPORT void l_tester_test_passed(struct l_tester *tester)
+{
+	if (unlikely(!tester))
+		return;
+
+	test_result(tester, TEST_RESULT_PASSED);
+}
+
+LIB_EXPORT void l_tester_test_failed(struct l_tester *tester)
+{
+	if (unlikely(!tester))
+		return;
+
+	test_result(tester, TEST_RESULT_FAILED);
+}
+
+LIB_EXPORT void l_tester_test_abort(struct l_tester *tester)
+{
+	if (unlikely(!tester))
+		return;
+
+	test_result(tester, TEST_RESULT_NOT_RUN);
+}
+
+LIB_EXPORT void l_tester_teardown_complete(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_TEARDOWN)
+		return;
+
+	test->stage =3D L_TESTER_STAGE_POST_TEARDOWN;
+
+	if (test->post_teardown_func)
+		test->post_teardown_func(test->test_data);
+	else
+		l_tester_post_teardown_complete(tester);
+}
+
+LIB_EXPORT void l_tester_teardown_failed(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_TEARDOWN)
+		return;
+
+	test->stage =3D L_TESTER_STAGE_POST_TEARDOWN;
+
+	l_tester_post_teardown_failed(tester);
+}
+
+LIB_EXPORT void l_tester_post_teardown_complete(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_POST_TEARDOWN)
+		return;
+
+	print_progress(test->name, COLOR_MAGENTA, "teardown complete");
+
+	l_idle_oneshot(done_callback, tester, NULL);
+}
+
+LIB_EXPORT void l_tester_post_teardown_failed(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_POST_TEARDOWN)
+		return;
+
+	print_progress(test->name, COLOR_RED, "teardown failed");
+
+	l_idle_oneshot(done_callback, tester, NULL);
+}
+
+struct wait_data {
+	unsigned int seconds;
+	struct test_case *test;
+	l_tester_wait_func_t func;
+	void *user_data;
+};
+
+static void wait_callback(struct l_timeout *timer, void *user_data)
+{
+	struct wait_data *wait =3D user_data;
+	struct test_case *test =3D wait->test;
+
+	wait->seconds--;
+
+	if (wait->seconds > 0) {
+		print_progress(test->name, COLOR_BLACK, "%u seconds left",
+								wait->seconds);
+		return;
+	}
+
+	print_progress(test->name, COLOR_BLACK, "waiting done");
+
+	wait->func(wait->user_data);
+
+	free(wait);
+
+	l_timeout_remove(timer);
+}
+
+LIB_EXPORT void l_tester_wait(struct l_tester *tester, unsigned int second=
s,
+				l_tester_wait_func_t func, void *user_data)
+{
+	struct test_case *test;
+	struct wait_data *wait;
+
+	if (unlikely(!tester))
+		return;
+
+	if (!func || seconds < 1)
+		return;
+
+	if (!tester->test_entry)
+		return;
+
+	test =3D tester->test_entry->data;
+
+	wait =3D l_new(struct wait_data, 1);
+	wait->seconds =3D seconds;
+	wait->test =3D test;
+	wait->func =3D func;
+	wait->user_data =3D user_data;
+
+	l_timeout_create(seconds, wait_callback, wait, NULL);
+
+	print_progress(test->name, COLOR_BLACK, "waiting %u seconds", seconds);
+}
+
+/**
+ * l_tester_add_full:
+ * @tester: tester instance
+ * @name: test case name
+ * @test_data: test data
+ * @pre_setup_func: test pre-setup function
+ * @setup_func: test setup function
+ * @test_func: test function
+ * @teardown_func: test teardown function
+ * @teardown_func: test post-teardown function
+ * @timeout: test teardown function
+ * @user_data: user data
+ * @destroy: user data destroy function
+ *
+ * Add a new test case.
+ **/
+LIB_EXPORT void l_tester_add_full(struct l_tester *tester, const char *nam=
e,
+							const void *test_data,
+					l_tester_data_func_t pre_setup_func,
+					l_tester_data_func_t setup_func,
+					l_tester_data_func_t test_func,
+					l_tester_data_func_t teardown_func,
+					l_tester_data_func_t post_teardown_func,
+					unsigned int timeout,
+					void *user_data,
+					l_tester_destroy_func_t destroy)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester || !test_func))
+		return;
+
+	if (tester->prefix && !l_str_has_prefix(name, tester->prefix)) {
+		if (destroy)
+			destroy(user_data);
+		return;
+	}
+
+	if (tester->substring && !strstr(name, tester->substring)) {
+		if (destroy)
+			destroy(user_data);
+		return;
+	}
+
+	if (tester->list_cases) {
+		l_info("%s", name);
+
+		if (destroy)
+			destroy(user_data);
+		return;
+	}
+
+	test =3D l_new(struct test_case, 1);
+	test->name =3D l_strdup(name);
+	test->result =3D TEST_RESULT_NOT_RUN;
+	test->stage =3D L_TESTER_STAGE_INVALID;
+
+	test->test_data =3D test_data;
+	test->pre_setup_func =3D pre_setup_func;
+	test->setup_func =3D setup_func;
+	test->test_func =3D test_func;
+	test->teardown_func =3D teardown_func;
+	test->post_teardown_func =3D post_teardown_func;
+	test->timeout =3D timeout;
+	test->destroy =3D destroy;
+	test->user_data =3D user_data;
+
+	l_queue_push_tail(tester->tests, test);
+}
+
+/**
+ * l_tester_add:
+ * @tester: tester instance
+ * @name: test case name
+ * @test_data: test data
+ * @setup_func: test setup function
+ * @test_func: test function
+ * @teardown_func: test teardown function
+ *
+ * Add a new test with default settings for timeout and no pre-setup proce=
dure.
+ **/
+LIB_EXPORT void l_tester_add(struct l_tester *tester, const char *name,
+					const void *test_data,
+					l_tester_data_func_t setup_func,
+					l_tester_data_func_t test_func,
+					l_tester_data_func_t teardown_func)
+{
+	l_tester_add_full(tester, name, test_data, NULL, setup_func, test_func,
+					teardown_func, NULL, 0, NULL, NULL);
+}
+
+/**
+ * l_tester_new:
+ *
+ * Initialize tester framework.
+ *
+ * Returns: new tester instance
+ **/
+LIB_EXPORT struct l_tester *l_tester_new(const char *prefix,
+					const char *substring, bool list_cases)
+{
+	struct l_tester *tester =3D l_new(struct l_tester, 1);
+
+	tester->prefix =3D prefix;
+	tester->substring =3D substring;
+	tester->list_cases =3D list_cases;
+	tester->tests =3D l_queue_new();
+	return tester;
+}
+
+/**
+ * l_tester_start:
+ * @tester: tester instance
+ *
+ * Kick off execution of the test queue
+ *
+ **/
+LIB_EXPORT void l_tester_start(struct l_tester *tester,
+					l_tester_finish_func_t finish_func)
+{
+	if (unlikely(!tester))
+		return;
+
+	if (!tester->tests)
+		return;
+
+	tester->finish_callback =3D finish_func;
+
+	tester->start_time =3D l_time_now();
+	next_test_case(tester);
+}
+
+/**
+ * l_tester_summarize:
+ * @tester: tester instance
+ *
+ * Print summary of all added test cases.
+ *
+ * Returns: true, if all the tests passed
+ *          false, if any of the tests failed
+ **/
+LIB_EXPORT bool l_tester_summarize(struct l_tester *tester)
+{
+	unsigned int not_run =3D 0, passed =3D 0, failed =3D 0;
+	double execution_time;
+	const struct l_queue_entry *entry;
+
+	if (unlikely(!tester))
+		return false;
+
+	l_info(COLOR_HIGHLIGHT "%s" COLOR_OFF,
+					"\n\nTest Summary\n------------");
+
+	entry =3D l_queue_get_entries(tester->tests);
+
+	for (; entry; entry =3D entry->next) {
+		struct test_case *test =3D entry->data;
+		double exec_time;
+
+		exec_time =3D (test->end_time - test->start_time) /
+							(double)L_USEC_PER_SEC;
+
+		switch (test->result) {
+		case TEST_RESULT_NOT_RUN:
+			print_summary(test->name, COLOR_YELLOW, "Not Run", "");
+			not_run++;
+			break;
+		case TEST_RESULT_PASSED:
+			print_summary(test->name, COLOR_GREEN, "Passed",
+					"%8.3f seconds", exec_time);
+			passed++;
+			break;
+		case TEST_RESULT_FAILED:
+			print_summary(test->name, COLOR_RED, "Failed",
+						"%8.3f seconds", exec_time);
+			failed++;
+			break;
+		case TEST_RESULT_TIMED_OUT:
+			print_summary(test->name, COLOR_RED, "Timed out",
+						"%8.3f seconds", exec_time);
+			failed++;
+			break;
+		}
+	}
+
+	l_info("Total: %d, "
+		COLOR_GREEN "Passed: %d (%.1f%%)" COLOR_OFF ", "
+		COLOR_RED "Failed: %d" COLOR_OFF ", "
+		COLOR_YELLOW "Not Run: %d" COLOR_OFF,
+			not_run + passed + failed, passed,
+			(not_run + passed + failed) ?
+			(float) passed * 100 / (not_run + passed + failed) : 0,
+			failed, not_run);
+
+	execution_time =3D get_elapsed_time(tester->start_time);
+
+	l_info("Overall execution time: %8.3f seconds",
+				execution_time / (double)L_USEC_PER_SEC);
+
+	return failed;
+}
+
+/**
+ * l_tester_destroy:
+ * @tester: tester instance
+ *
+ * Free up the teter framework resources
+ *
+ **/
+LIB_EXPORT void l_tester_destroy(struct l_tester *tester)
+{
+	if (unlikely(!tester))
+		return;
+
+	l_queue_destroy(tester->tests, destroy_test);
+	l_free(tester);
+}
+
+/**
+ * l_tester_get_stage:
+ * @tester: tester instance
+ *
+ * Get the current test stage
+ *
+ * Returns: the stage of the current test that is being processing.
+ *
+ **/
+LIB_EXPORT enum l_tester_stage l_tester_get_stage(struct l_tester *tester)
+{
+	struct test_case *test;
+
+	if (unlikely(!tester))
+		return L_TESTER_STAGE_INVALID;
+
+	if (!tester->test_entry)
+		return L_TESTER_STAGE_INVALID;
+
+	test =3D tester->test_entry->data;
+
+	return test->stage;
+}
diff --git a/ell/tester.h b/ell/tester.h
new file mode 100644
index 0000000..b5aa1be
--- /dev/null
+++ b/ell/tester.h
@@ -0,0 +1,97 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2021  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_TESTER_H
+#define __ELL_TESTER_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include <stdbool.h>
+#include <stddef.h>
+#include <stdint.h>
+
+struct l_tester;
+
+enum l_tester_stage {
+	L_TESTER_STAGE_INVALID,
+	L_TESTER_STAGE_PRE_SETUP,
+	L_TESTER_STAGE_SETUP,
+	L_TESTER_STAGE_RUN,
+	L_TESTER_STAGE_TEARDOWN,
+	L_TESTER_STAGE_POST_TEARDOWN,
+};
+
+typedef void (*l_tester_destroy_func_t)(void *user_data);
+typedef void (*l_tester_data_func_t)(const void *test_data);
+typedef void (*l_tester_finish_func_t)(struct l_tester *tester);
+typedef void (*l_tester_wait_func_t)(void *user_data);
+
+struct l_tester *l_tester_new(const char *prefix, const char *substring,
+							bool list_cases);
+void l_tester_destroy(struct l_tester *tester);
+void l_tester_start(struct l_tester *tester,
+					l_tester_finish_func_t finish_func);
+
+bool l_tester_summarize(struct l_tester *tester);
+
+void l_tester_add_full(struct l_tester *tester, const char *name,
+				const void *test_data,
+				l_tester_data_func_t pre_setup_func,
+				l_tester_data_func_t setup_func,
+				l_tester_data_func_t test_func,
+				l_tester_data_func_t teardown_func,
+				l_tester_data_func_t post_teardown_func,
+				unsigned int timeout,
+				void *user_data,
+				l_tester_destroy_func_t destroy);
+
+void l_tester_add(struct l_tester *tester, const char *name,
+					const void *test_data,
+					l_tester_data_func_t setup_func,
+					l_tester_data_func_t test_func,
+					l_tester_data_func_t teardown_func);
+
+void l_tester_pre_setup_complete(struct l_tester *tester);
+void l_tester_pre_setup_failed(struct l_tester *tester);
+void l_tester_setup_complete(struct l_tester *tester);
+void l_tester_setup_failed(struct l_tester *tester);
+void l_tester_test_passed(struct l_tester *tester);
+void l_tester_test_failed(struct l_tester *tester);
+void l_tester_test_abort(struct l_tester *tester);
+void l_tester_teardown_complete(struct l_tester *tester);
+void l_tester_teardown_failed(struct l_tester *tester);
+void l_tester_post_teardown_complete(struct l_tester *tester);
+void l_tester_post_teardown_failed(struct l_tester *tester);
+
+enum l_tester_stage l_tester_get_stage(struct l_tester *tester);
+void *l_tester_get_data(struct l_tester *tester);
+
+void l_tester_wait(struct l_tester *tester, unsigned int seconds,
+				l_tester_wait_func_t func, void *user_data);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_TESTER_H */
-- =

2.26.2

--===============1762218185682167670==--

