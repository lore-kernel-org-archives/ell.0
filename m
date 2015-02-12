Content-Type: multipart/mixed; boundary="===============6930957879753413070=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Thu, 12 Feb 2015 13:48:53 +0200
Message-ID: <1423741733-26743-4-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423741733-26743-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6930957879753413070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test the dbus disconnect watch support.
---
 Makefile.am            |   3 +
 unit/test-dbus-watch.c | 388 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 391 insertions(+)
 create mode 100644 unit/test-dbus-watch.c

diff --git a/Makefile.am b/Makefile.am
index 50f81eb..eff88f7 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -102,6 +102,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-dbus-util \
 			unit/test-dbus-message \
 			unit/test-dbus-service \
+			unit/test-dbus-watch \
 			unit/test-gvariant-util \
 			unit/test-gvariant-message \
 			unit/test-siphash \
@@ -147,6 +148,8 @@ unit_test_dbus_util_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_service_LDADD =3D ell/libell-private.la
 =

+unit_test_dbus_watch_LDADD =3D ell/libell-private.la
+
 unit_test_gvariant_util_LDADD =3D ell/libell-private.la
 =

 unit_test_gvariant_message_LDADD =3D ell/libell-private.la
diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
new file mode 100644
index 0000000..6c93a87
--- /dev/null
+++ b/unit/test-dbus-watch.c
@@ -0,0 +1,388 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2015  Intel Corporation. All rights reserved.
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
+#include <unistd.h>
+#include <stdlib.h>
+#include <sys/wait.h>
+#include <assert.h>
+#include <time.h>
+
+#include <ell/ell.h>
+
+#define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-watch-test-bus"
+
+#define SERVICE_TO_WATCH "org.test.watch.service"
+#define SERVICE_MONITOR "org.test.main.service"
+
+static pid_t dbus_daemon_pid =3D -1;
+static pid_t test_daemon_pid =3D -1;
+
+static struct l_timeout *timeout =3D NULL;
+static bool failure =3D false;
+static struct tm *tm =3D NULL;
+
+static pid_t launch(char *name, char **argv, char **envp)
+{
+	pid_t pid;
+
+	l_info("launching %s", name);
+
+	pid =3D fork();
+	if (pid < 0) {
+		l_error("failed to fork new process");
+		return -1;
+	}
+
+	if (pid =3D=3D 0) {
+		execve(argv[0], argv, envp);
+		exit(EXIT_SUCCESS);
+	}
+
+	l_info("%s process %d created", name, pid);
+
+	return pid;
+}
+
+static void start_dbus_daemon(void)
+{
+	char *prg_argv[6];
+	char *prg_envp[1];
+
+	prg_argv[0] =3D "/usr/bin/dbus-daemon";
+	prg_argv[1] =3D "--session";
+	prg_argv[2] =3D "--address=3D" TEST_BUS_ADDRESS;
+	prg_argv[3] =3D "--nopidfile";
+	prg_argv[4] =3D "--nofork";
+	prg_argv[5] =3D NULL;
+
+	prg_envp[0] =3D NULL;
+
+	dbus_daemon_pid =3D launch("dbus-daemon",
+				prg_argv, prg_envp);
+}
+
+static void start_test_daemon(char *argv0, char *argv1)
+{
+	char *prg_argv[3];
+	char *prg_envp[1];
+
+	prg_argv[0] =3D argv0;
+	prg_argv[1] =3D argv1;
+	prg_argv[2] =3D NULL;
+
+	prg_envp[0] =3D NULL;
+
+	test_daemon_pid =3D launch("test daemon",
+				prg_argv, prg_envp);
+}
+
+static void signal_handler(struct l_signal *signal, uint32_t signo,
+							void *user_data)
+{
+	switch (signo) {
+	case SIGINT:
+	case SIGTERM:
+		l_info("Terminate");
+		l_main_quit();
+		break;
+	case SIGCHLD:
+		while (1) {
+			pid_t pid;
+			int status;
+
+			pid =3D waitpid(WAIT_ANY, &status, WNOHANG);
+			if (pid < 0 || pid =3D=3D 0)
+				break;
+
+			l_info("process %d terminated with status=3D%d\n",
+								pid, status);
+
+			if (pid =3D=3D dbus_daemon_pid) {
+				dbus_daemon_pid =3D -1;
+				l_main_quit();
+			}
+		}
+		break;
+	}
+}
+
+static void ready_callback(void *user_data)
+{
+	char *argv0 =3D user_data;
+
+	l_info("test app ready");
+
+	start_test_daemon(argv0, "test");
+}
+
+static void ready_tester(void *user_data)
+{
+	l_info("tester ready");
+
+	return;
+}
+
+struct data {
+	char *name;
+	struct l_dbus *dbus;
+};
+
+static void release_name_setup(struct l_dbus_message *message, void *user_=
data)
+{
+	struct data *data =3D user_data;
+
+	l_dbus_message_set_arguments(message, "s", data->name);
+}
+
+static void release_name_callback(struct l_dbus_message *message,
+							void *user_data)
+{
+	const char *error, *text;
+	uint32_t result;
+
+	if (l_dbus_message_get_error(message, &error, &text)) {
+		l_error("error=3D%s", error);
+		l_error("message=3D%s", text);
+		goto done;
+	}
+
+	if (!l_dbus_message_get_arguments(message, "u", &result))
+		goto done;
+
+	l_info("release name result =3D %d", result);
+
+done:
+	l_main_quit();
+}
+
+static void request_name_setup(struct l_dbus_message *message,
+				void *user_data)
+{
+	struct data *data =3D user_data;
+
+	l_dbus_message_set_arguments(message, "su", data->name, 0);
+}
+
+static void request_name_callback(struct l_dbus_message *message,
+							void *user_data)
+{
+	const char *error, *text;
+	uint32_t result;
+
+	if (l_dbus_message_get_error(message, &error, &text)) {
+		l_error("error=3D%s", error);
+		l_error("message=3D%s", text);
+		goto done;
+	}
+
+	if (!l_dbus_message_get_arguments(message, "u", &result))
+		goto done;
+
+	l_info("request name result =3D %d", result);
+
+done:
+	return;
+}
+
+static void request_name_tester_callback(struct l_dbus_message *message,
+							void *user_data)
+{
+	const char *error, *text;
+	uint32_t result;
+	struct data *data =3D user_data;
+
+	if (l_dbus_message_get_error(message, &error, &text)) {
+		l_error("error=3D%s", error);
+		l_error("message=3D%s", text);
+		goto done;
+	}
+
+	if (!l_dbus_message_get_arguments(message, "u", &result))
+		goto done;
+
+	l_info("request tester name result =3D %d", result);
+
+	l_dbus_method_call(data->dbus, "org.freedesktop.DBus",
+			"/org/freedesktop/DBus",
+			"org.freedesktop.DBus", "ReleaseName",
+			release_name_setup,
+			release_name_callback, data, NULL);
+done:
+	return;
+}
+
+static void disconnected(struct l_dbus *dbus, void *user_data)
+{
+	struct tm *test_tm =3D user_data;
+
+	l_main_quit();
+
+	l_info("client disconnected");
+
+	l_timeout_remove(timeout);
+	timeout =3D NULL;
+
+	assert(test_tm->tm_sec =3D=3D 1);
+	assert(test_tm->tm_min =3D=3D 2);
+	assert(test_tm->tm_hour =3D=3D 3);
+	assert(test_tm->tm_year =3D=3D 1970);
+	assert(test_tm->tm_isdst =3D=3D 0);
+
+	assert(test_tm =3D=3D tm);
+
+	failure =3D false;
+}
+
+static void destroy(void *user_data)
+{
+	struct tm *test_tm =3D user_data;
+
+	assert(test_tm =3D=3D tm);
+
+	l_free(test_tm);
+}
+
+static void timeout_cb(struct l_timeout *timeout, void *user_data)
+{
+	failure =3D true;
+
+	l_main_quit();
+}
+
+static struct l_dbus *get_bus(void)
+{
+	struct l_dbus *dbus =3D NULL;
+	int i;
+
+	for (i =3D 0; i < 10; i++) {
+		usleep(200 * 1000);
+
+		dbus =3D l_dbus_new(TEST_BUS_ADDRESS);
+		if (dbus)
+			break;
+	}
+
+	return dbus;
+}
+
+static void request_tester()
+{
+	struct l_dbus *dbus =3D get_bus();
+	struct data data;
+
+	l_dbus_set_ready_handler(dbus, ready_tester, NULL, NULL);
+
+	data.name =3D SERVICE_TO_WATCH;
+	data.dbus =3D dbus;
+
+	l_dbus_method_call(dbus, "org.freedesktop.DBus",
+			"/org/freedesktop/DBus",
+			"org.freedesktop.DBus", "RequestName",
+			request_name_setup,
+			request_name_tester_callback, &data, NULL);
+
+	l_main_run();
+
+	l_dbus_destroy(dbus);
+
+	exit(1);
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_dbus *dbus;
+	struct l_signal *signal;
+	sigset_t mask;
+	unsigned int watch_id;
+	struct data data;
+
+	l_log_set_stderr();
+
+	if (argc > 1 && !strcmp(argv[1], "test"))
+		request_tester();
+
+	sigemptyset(&mask);
+	sigaddset(&mask, SIGINT);
+	sigaddset(&mask, SIGTERM);
+	sigaddset(&mask, SIGCHLD);
+
+	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
+
+	start_dbus_daemon();
+
+	dbus =3D get_bus();
+
+	l_dbus_set_ready_handler(dbus, ready_callback, argv[0], NULL);
+
+	tm =3D l_new(struct tm, 1);
+
+	tm->tm_sec =3D 1;
+	tm->tm_min =3D 2;
+	tm->tm_hour =3D 3;
+	tm->tm_year =3D 1970;
+	tm->tm_isdst =3D 0;
+
+	failure =3D true;
+
+	watch_id =3D l_dbus_add_disconnect_watch(dbus,
+					SERVICE_TO_WATCH,
+					disconnected,
+					tm,
+					destroy);
+
+	data.name =3D SERVICE_MONITOR;
+	data.dbus =3D dbus;
+
+	l_dbus_method_call(dbus, "org.freedesktop.DBus",
+			"/org/freedesktop/DBus",
+			"org.freedesktop.DBus", "RequestName",
+			request_name_setup,
+			request_name_callback, &data, NULL);
+
+	timeout =3D l_timeout_create(5, timeout_cb, dbus, NULL);
+
+	l_main_run();
+
+	l_dbus_remove_watch(dbus, watch_id);
+
+	if (dbus_daemon_pid > 0)
+		kill(dbus_daemon_pid, SIGKILL);
+
+	if (test_daemon_pid > 0)
+		kill(test_daemon_pid, SIGKILL);
+
+	l_dbus_destroy(dbus);
+
+	l_signal_remove(signal);
+
+	l_timeout_remove(timeout);
+
+	assert(failure =3D=3D false);
+
+	l_info("dbus watch test passed");
+
+	return 0;
+}
-- =

2.1.0


--===============6930957879753413070==--

