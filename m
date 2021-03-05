Content-Type: multipart/mixed; boundary="===============1956422053005621877=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] [RFC PATCH] tester: Add framework for serialized test
 execution
Date: Fri, 05 Mar 2021 13:37:33 -0800
Message-ID: <20210305213733.131497-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1956422053005621877==
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
 ell/tester.c | 786 +++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/tester.h |  94 ++++++
 3 files changed, 884 insertions(+), 2 deletions(-)
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
diff --git a/ell/tester.c b/ell/tester.c
new file mode 100644
index 0000000..887dee9
--- /dev/null
+++ b/ell/tester.c
@@ -0,0 +1,786 @@
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
+struct test_case {
+	char *name;
+	enum test_result result;
+	enum l_tester_stage stage;
+	const void *test_data;
+	l_tester_data_func_t pre_setup_func;
+	l_tester_data_func_t setup_func;
+	l_tester_data_func_t test_func;
+	l_tester_data_func_t teardown_func;
+	l_tester_data_func_t post_teardown_func;
+	double start_time;
+	double end_time;
+	unsigned int timeout;
+	struct l_timeout *run_timer;
+	l_tester_destroy_func_t destroy;
+	void *user_data;
+	bool teardown;
+};
+
+static char *tester_name;
+
+static struct l_queue *test_list;
+static const struct l_queue_entry *test_entry;
+static struct timeval tester_start;
+
+static bool option_list;
+static const char *option_prefix;
+static const char *option_string;
+
+static bool terminated;
+
+static void test_destroy(void *data)
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
+static void default_pre_setup(const void *test_data)
+{
+	l_tester_pre_setup_complete();
+}
+
+static void default_setup(const void *test_data)
+{
+	l_tester_setup_complete();
+}
+
+static void default_teardown(const void *test_data)
+{
+	l_tester_teardown_complete();
+}
+
+static void default_post_teardown(const void *test_data)
+{
+	l_tester_post_teardown_complete();
+}
+
+void *l_tester_get_data(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return NULL;
+
+	test =3D test_entry->data;
+
+	return test->user_data;
+}
+
+static double get_elapsed_time(struct timeval *base)
+{
+	static struct timeval now, elapsed;
+
+	gettimeofday(&now, NULL);
+	timersub(&now, base, &elapsed);
+
+	return elapsed.tv_sec + ((double) elapsed.tv_usec) / 1000000;
+}
+
+static int tester_summarize(void)
+{
+	unsigned int not_run =3D 0, passed =3D 0, failed =3D 0;
+	double execution_time;
+	const struct l_queue_entry *entry;
+
+	l_info(COLOR_HIGHLIGHT "%s" COLOR_OFF,
+					"\n\nTest Summary\n------------");
+
+	entry =3D l_queue_get_entries(test_list);
+
+	for (; entry; entry =3D entry->next) {
+		struct test_case *test =3D entry->data;
+		double exec_time;
+
+		exec_time =3D test->end_time - test->start_time;
+
+		switch (test->result) {
+		case TEST_RESULT_NOT_RUN:
+			print_summary(test->name, COLOR_YELLOW, "Not Run", "");
+			not_run++;
+			break;
+		case TEST_RESULT_PASSED:
+			print_summary(test->name, COLOR_GREEN, "Passed",
+						"%8.3f seconds", exec_time);
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
+	execution_time =3D get_elapsed_time(&tester_start);
+	l_info("Overall execution time: %.3g seconds", execution_time);
+
+	return failed;
+}
+
+static void teardown_callback(void *user_data)
+{
+	struct test_case *test =3D user_data;
+
+	test->stage =3D L_TESTER_STAGE_TEARDOWN;
+	test->teardown =3D false;
+
+	print_progress(test->name, COLOR_MAGENTA, "teardown");
+	test->teardown_func(test->test_data);
+}
+
+static void test_timeout(struct l_timeout *timer, void *user_data)
+{
+	struct test_case *test =3D user_data;
+
+	l_timeout_remove(timer);
+	test->run_timer =3D NULL;
+
+	test->result =3D TEST_RESULT_TIMED_OUT;
+	print_progress(test->name, COLOR_RED, "test timed out");
+
+	l_idle_oneshot(teardown_callback, test, NULL);
+}
+
+static void next_test_case(void)
+{
+	struct test_case *test;
+
+	if (test_entry)
+		test_entry =3D test_entry->next;
+	else
+		test_entry =3D l_queue_get_entries(test_list);
+
+	if (!test_entry) {
+		l_main_quit();
+		return;
+	}
+
+	test =3D test_entry->data;
+
+	l_info("");
+	print_progress(test->name, COLOR_BLACK, "init");
+
+	test->start_time =3D get_elapsed_time(&tester_start);
+
+	if (test->timeout > 0)
+		test->run_timer =3D l_timeout_create(test->timeout, test_timeout,
+								test, NULL);
+
+	test->stage =3D L_TESTER_STAGE_PRE_SETUP;
+
+	test->pre_setup_func(test->test_data);
+}
+
+static void setup_callback(void *user_data)
+{
+	struct test_case *test =3D user_data;
+
+	test->stage =3D L_TESTER_STAGE_SETUP;
+
+	print_progress(test->name, COLOR_BLUE, "setup");
+	test->setup_func(test->test_data);
+}
+
+static void run_callback(void *user_data)
+{
+	struct test_case *test =3D user_data;
+
+	test->stage =3D L_TESTER_STAGE_RUN;
+
+	print_progress(test->name, COLOR_BLACK, "run");
+	test->test_func(test->test_data);
+}
+
+static void done_callback(void *user_data)
+{
+	struct test_case *test =3D user_data;
+
+	test->end_time =3D get_elapsed_time(&tester_start);
+
+	print_progress(test->name, COLOR_BLACK, "done");
+	next_test_case();
+}
+
+LIB_EXPORT void l_tester_pre_setup_complete(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_PRE_SETUP)
+		return;
+
+	l_idle_oneshot(setup_callback, test, NULL);
+}
+
+LIB_EXPORT void l_tester_pre_setup_failed(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_PRE_SETUP)
+		return;
+
+	print_progress(test->name, COLOR_RED, "pre setup failed");
+
+	l_idle_oneshot(done_callback, test, NULL);
+}
+
+LIB_EXPORT void l_tester_setup_complete(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_SETUP)
+		return;
+
+	print_progress(test->name, COLOR_BLUE, "setup complete");
+
+	l_idle_oneshot(run_callback, test, NULL);
+}
+
+LIB_EXPORT void l_tester_setup_failed(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
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
+static void test_result(enum test_result result)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
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
+	l_idle_oneshot(teardown_callback, test, NULL);
+}
+
+LIB_EXPORT void l_tester_test_passed(void)
+{
+	test_result(TEST_RESULT_PASSED);
+}
+
+LIB_EXPORT void l_tester_test_failed(void)
+{
+	test_result(TEST_RESULT_FAILED);
+}
+
+LIB_EXPORT void l_tester_test_abort(void)
+{
+	test_result(TEST_RESULT_NOT_RUN);
+}
+
+LIB_EXPORT void l_tester_teardown_complete(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_TEARDOWN)
+		return;
+
+	test->stage =3D L_TESTER_STAGE_POST_TEARDOWN;
+
+	test->post_teardown_func(test->test_data);
+}
+
+LIB_EXPORT void l_tester_teardown_failed(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_TEARDOWN)
+		return;
+
+	test->stage =3D L_TESTER_STAGE_POST_TEARDOWN;
+
+	l_tester_post_teardown_failed();
+}
+
+LIB_EXPORT void l_tester_post_teardown_complete(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_POST_TEARDOWN)
+		return;
+
+	print_progress(test->name, COLOR_MAGENTA, "teardown complete");
+
+	l_idle_oneshot(done_callback, test, NULL);
+}
+
+LIB_EXPORT void l_tester_post_teardown_failed(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
+
+	if (test->stage !=3D L_TESTER_STAGE_POST_TEARDOWN)
+		return;
+
+	print_progress(test->name, COLOR_RED, "teardown failed");
+
+	l_idle_oneshot(done_callback, test, NULL);
+}
+
+static void start_tester(void *user_data)
+{
+	gettimeofday(&tester_start, NULL);
+	next_test_case();
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
+LIB_EXPORT void l_tester_wait(unsigned int seconds, l_tester_wait_func_t f=
unc,
+							void *user_data)
+{
+	struct test_case *test;
+	struct wait_data *wait;
+
+	if (!func || seconds < 1)
+		return;
+
+	if (!test_entry)
+		return;
+
+	test =3D test_entry->data;
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
+static void signal_callback(unsigned int signum, void *user_data)
+{
+	switch (signum) {
+	case SIGINT:
+	case SIGTERM:
+		if (!terminated)
+			l_main_quit();
+
+		terminated =3D true;
+		break;
+	}
+}
+
+static const struct option options[] =3D {
+	{ "version",	no_argument,		NULL, 'v' },
+	{ "quiet",	no_argument,		NULL, 'q' },
+	{ "debug",	no_argument,		NULL, 'd' },
+	{ "monitor",	no_argument,		NULL, 'm' },
+	{ "list",	no_argument,		NULL, 'l' },
+	{ "prefix",	required_argument,	NULL, 'p' },
+	{ "string",	required_argument,	NULL, 's' },
+	{ }
+};
+
+static void usage(void)
+{
+	fprintf(stderr,
+		"Usage:\n"
+		"\%s [options]\n", tester_name);
+	fprintf(stderr,
+		"Options:\n"
+		"\t-v, --version	Show version information and exit\n"
+		"\t-d, --debug	Run tests with debug output\n"
+		"\t-l, --list	Only list the tests to be run\n"
+		"\t-p, --prefix	Run tests matching the provided prefix\n"
+		"\t-s, --string	Run tests matching the provided string\n");
+}
+
+/**
+ * l_tester_add_full:
+ * @name: test name
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
+LIB_EXPORT void l_tester_add_full(const char *name, const void *test_data,
+				l_tester_data_func_t pre_setup_func,
+				l_tester_data_func_t setup_func,
+				l_tester_data_func_t test_func,
+				l_tester_data_func_t teardown_func,
+				l_tester_data_func_t post_teardown_func,
+				unsigned int timeout,
+				void *user_data,
+				l_tester_destroy_func_t destroy)
+{
+	struct test_case *test;
+
+	if (!test_func)
+		return;
+
+	if (option_prefix && !l_str_has_prefix(name, option_prefix)) {
+		if (destroy)
+			destroy(user_data);
+		return;
+	}
+
+	if (option_string && !strstr(name, option_string)) {
+		if (destroy)
+			destroy(user_data);
+		return;
+	}
+
+	if (option_list) {
+		l_info("%s", name);
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
+
+	if (pre_setup_func)
+		test->pre_setup_func =3D pre_setup_func;
+	else
+		test->pre_setup_func =3D default_pre_setup;
+
+	if (setup_func)
+		test->setup_func =3D setup_func;
+	else
+		test->setup_func =3D default_setup;
+
+	test->test_func =3D test_func;
+
+	if (teardown_func)
+		test->teardown_func =3D teardown_func;
+	else
+		test->teardown_func =3D default_teardown;
+
+	if (post_teardown_func)
+		test->post_teardown_func =3D post_teardown_func;
+	else
+		test->post_teardown_func =3D default_post_teardown;
+
+	test->timeout =3D timeout;
+
+	test->destroy =3D destroy;
+	test->user_data =3D user_data;
+
+	l_queue_push_tail(test_list, test);
+}
+
+/**
+ * l_tester_add:
+ * @name: test name
+ * @test_data: test data
+ * @setup_func: test setup function
+ * @test_func: test function
+ * @teardown_func: test teardown function
+ *
+ * Add a new test with default settings for timeout and no pre-setup proce=
dure.
+ **/
+LIB_EXPORT void l_tester_add(const char *name, const void *test_data,
+					l_tester_data_func_t setup_func,
+					l_tester_data_func_t test_func,
+					l_tester_data_func_t teardown_func)
+{
+	l_tester_add_full(name, test_data, NULL, setup_func, test_func,
+					teardown_func, NULL, 0, NULL, NULL);
+}
+
+/**
+ * l_tester_init:
+ * @argc: pointer to @argc parameter of main() function
+ * @argv: pointer to @argv parameter of main() function
+ *
+ * Initialize tester framework.
+ **/
+LIB_EXPORT void l_tester_init(int *argc, char ***argv)
+{
+	tester_name =3D strrchr(*argv[0], '/');
+	if (!tester_name)
+		tester_name =3D strdup(*argv[0]);
+	else
+		tester_name =3D strdup(++tester_name);
+
+	for (;;) {
+		int opt;
+
+		opt =3D getopt_long(*argc, *argv, "ps:vdl", options, NULL);
+		if (opt < 0)
+			break;
+
+		switch (opt) {
+		case 'v':
+			printf("%s\n", VERSION);
+			exit(EXIT_SUCCESS);
+		case 'l':
+			option_list =3D true;
+			break;
+		case 'p':
+			option_prefix =3D optarg;
+			break;
+		case 's':
+			option_string =3D optarg;
+			break;
+		default:
+			usage();
+			exit(0);
+		}
+	}
+
+	l_main_init();
+
+	test_list =3D l_queue_new();
+}
+
+/**
+ * l_test_run:
+ *
+ * Run all added test cases.
+ *
+ * Returns: EXIT_SUCCESS (0) on success and
+ *          EXIT_FAILURE (1) on failure
+ **/
+LIB_EXPORT int l_tester_run(void)
+{
+	int ret;
+
+	if (option_list)
+		return EXIT_SUCCESS;
+
+	l_idle_oneshot(start_tester, NULL, NULL);
+
+	l_main_run_with_signal(signal_callback, NULL);
+
+	ret =3D tester_summarize();
+
+	l_queue_destroy(test_list, test_destroy);
+
+	return ret =3D=3D 0 ? EXIT_SUCCESS : EXIT_FAILURE;
+}
+
+/**
+ * l_test_get_stage:
+ *
+ * Get the test stage
+ *
+ * Returns: the stage of the current test that is being processing.
+ *
+ **/
+LIB_EXPORT enum l_tester_stage l_tester_get_stage(void)
+{
+	struct test_case *test;
+
+	if (!test_entry)
+		return L_TESTER_STAGE_INVALID;
+
+	test =3D test_entry->data;
+
+	return test->stage;
+}
diff --git a/ell/tester.h b/ell/tester.h
new file mode 100644
index 0000000..125f0b8
--- /dev/null
+++ b/ell/tester.h
@@ -0,0 +1,94 @@
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
+enum l_tester_stage {
+	L_TESTER_STAGE_INVALID,
+	L_TESTER_STAGE_PRE_SETUP,
+	L_TESTER_STAGE_SETUP,
+	L_TESTER_STAGE_RUN,
+	L_TESTER_STAGE_TEARDOWN,
+	L_TESTER_STAGE_POST_TEARDOWN,
+};
+
+void l_tester_init(int *argc, char ***argv);
+int l_tester_run(void);
+
+enum l_tester_stage l_tester_get_stage(void);
+
+typedef void (*l_tester_destroy_func_t)(void *user_data);
+typedef void (*l_tester_data_func_t)(const void *test_data);
+
+void l_tester_add_full(const char *name, const void *test_data,
+				l_tester_data_func_t pre_setup_func,
+				l_tester_data_func_t setup_func,
+				l_tester_data_func_t test_func,
+				l_tester_data_func_t teardown_func,
+				l_tester_data_func_t post_teardown_func,
+				unsigned int timeout,
+				void *user_data,
+				l_tester_destroy_func_t destroy);
+
+void l_tester_add(const char *name, const void *test_data,
+					l_tester_data_func_t setup_func,
+					l_tester_data_func_t test_func,
+					l_tester_data_func_t teardown_func);
+
+void *l_tester_get_data(void);
+
+void l_tester_pre_setup_complete(void);
+void l_tester_pre_setup_failed(void);
+void l_tester_pre_setup_continue(void);
+
+void l_tester_setup_complete(void);
+void l_tester_setup_failed(void);
+
+void l_tester_test_passed(void);
+void l_tester_test_failed(void);
+void l_tester_test_abort(void);
+
+void l_tester_teardown_complete(void);
+void l_tester_teardown_failed(void);
+
+void l_tester_post_teardown_complete(void);
+void l_tester_post_teardown_failed(void);
+
+typedef void (*l_tester_wait_func_t)(void *user_data);
+
+void l_tester_wait(unsigned int seconds, l_tester_wait_func_t func,
+							void *user_data);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_TESTER_H */
-- =

2.26.2

--===============1956422053005621877==--

