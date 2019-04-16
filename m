Content-Type: multipart/mixed; boundary="===============1380742046711655879=="
MIME-Version: 1.0
From: Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH v2 2/2] unit: dbus: Add unit test to dbus tcp address
Date: Tue, 16 Apr 2019 10:05:38 -0300
Message-ID: <1555419938-28430-3-git-send-email-rhpr@cesar.org.br>
In-Reply-To: <1555419938-28430-1-git-send-email-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1380742046711655879==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore           |   1 +
 Makefile.am          |   3 +
 unit/dbus.conf       |   2 +
 unit/test-dbus-tcp.c | 261 +++++++++++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 267 insertions(+)
 create mode 100644 unit/test-dbus-tcp.c

diff --git a/.gitignore b/.gitignore
index 520c509..7d938f2 100644
--- a/.gitignore
+++ b/.gitignore
@@ -34,6 +34,7 @@ unit/test-netlink
 unit/test-genl
 unit/test-genl-msg
 unit/test-dbus
+unit/test-dbus-tcp
 unit/test-dbus-message
 unit/test-dbus-message-fds
 unit/test-dbus-util
diff --git a/Makefile.am b/Makefile.am
index 5bc13bd..28b8452 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -175,6 +175,7 @@ unit_tests =3D unit/test-unit \
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
+			unit/test-dbus-tcp \
 			unit/test-dbus-util \
 			unit/test-dbus-message \
 			unit/test-dbus-message-fds \
@@ -243,6 +244,8 @@ unit_test_genl_msg_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_LDADD =3D ell/libell-private.la
 =

+unit_test_dbus_tcp_LDADD =3D ell/libell-private.la
+
 unit_test_dbus_message_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_message_fds_LDADD =3D ell/libell-private.la
diff --git a/unit/dbus.conf b/unit/dbus.conf
index 97e1bb5..6b1fccd 100644
--- a/unit/dbus.conf
+++ b/unit/dbus.conf
@@ -7,6 +7,8 @@
   <allow_anonymous />
 =

   <listen>unix:path=3D/tmp/ell-test-bus</listen>
+  <listen>tcp:host=3Dlocalhost,bind=3D*,port=3D1234,family=3Dipv4</listen>
+  <apparmor mode=3D"disabled" />
 =

   <policy context=3D"default">
     <!-- Allow everything to be sent -->
diff --git a/unit/test-dbus-tcp.c b/unit/test-dbus-tcp.c
new file mode 100644
index 0000000..4e11ca9
--- /dev/null
+++ b/unit/test-dbus-tcp.c
@@ -0,0 +1,261 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
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
+#define _GNU_SOURCE
+#include <unistd.h>
+#include <stdlib.h>
+#include <sys/wait.h>
+
+#include <ell/ell.h>
+
+#ifndef WAIT_ANY
+#define WAIT_ANY (-1) /* Any process */
+#endif
+
+#define TEST_BUS_ADDRESS "tcp:host=3Dlocalhost,port=3D1234"
+
+static pid_t dbus_daemon_pid =3D -1;
+
+static void start_dbus_daemon(void)
+{
+	char *prg_argv[6];
+	char *prg_envp[1];
+	pid_t pid;
+
+	prg_argv[0] =3D "/usr/bin/dbus-daemon";
+	prg_argv[1] =3D "--nopidfile";
+	prg_argv[2] =3D "--nofork";
+	prg_argv[3] =3D "--config-file=3D" UNITDIR "dbus.conf";
+	prg_argv[4] =3D "--print-address";
+	prg_argv[5] =3D NULL;
+
+	prg_envp[0] =3D NULL;
+
+	l_info("launching dbus-daemon");
+
+	pid =3D fork();
+	if (pid < 0) {
+		l_error("failed to fork new process");
+		return;
+	}
+
+	if (pid =3D=3D 0) {
+		execve(prg_argv[0], prg_argv, prg_envp);
+		exit(EXIT_SUCCESS);
+	}
+
+	l_info("dbus-daemon process %d created", pid);
+
+	dbus_daemon_pid =3D pid;
+}
+
+static void signal_handler(uint32_t signo, void *user_data)
+{
+	switch (signo) {
+	case SIGINT:
+	case SIGTERM:
+		l_info("Terminate");
+		l_main_quit();
+		break;
+	}
+}
+
+static void sigchld_handler(void *user_data)
+{
+	while (1) {
+		pid_t pid;
+		int status;
+
+		pid =3D waitpid(WAIT_ANY, &status, WNOHANG);
+		if (pid < 0 || pid =3D=3D 0)
+			break;
+
+		l_info("process %d terminated with status=3D%d\n", pid, status);
+
+		if (pid =3D=3D dbus_daemon_pid) {
+			dbus_daemon_pid =3D -1;
+			l_main_quit();
+		}
+	}
+}
+
+static void do_debug(const char *str, void *user_data)
+{
+	const char *prefix =3D user_data;
+
+	l_info("%s%s", prefix, str);
+}
+
+static void signal_message(struct l_dbus_message *message, void *user_data)
+{
+	const char *path, *interface, *member, *destination, *sender;
+
+	path =3D l_dbus_message_get_path(message);
+	destination =3D l_dbus_message_get_destination(message);
+
+	l_info("path=3D%s destination=3D%s", path, destination);
+
+	interface =3D l_dbus_message_get_interface(message);
+	member =3D l_dbus_message_get_member(message);
+
+	l_info("interface=3D%s member=3D%s", interface, member);
+
+	sender =3D l_dbus_message_get_sender(message);
+
+	l_info("sender=3D%s", sender);
+
+	if (!strcmp(member, "NameOwnerChanged")) {
+		const char *name, *old_owner, *new_owner;
+
+		if (!l_dbus_message_get_arguments(message, "sss",
+					&name, &old_owner, &new_owner))
+			return;
+
+		l_info("name=3D%s old=3D%s new=3D%s", name, old_owner, new_owner);
+	}
+}
+
+static void request_name_setup(struct l_dbus_message *message, void *user_=
data)
+{
+	const char *name =3D "org.test";
+
+	l_dbus_message_set_arguments(message, "su", name, 0);
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
+	l_info("request name result=3D%d", result);
+
+done:
+	l_main_quit();
+}
+
+static const char *match_rule =3D "type=3Dsignal,sender=3Dorg.freedesktop.=
DBus";
+
+static void add_match_setup(struct l_dbus_message *message, void *user_dat=
a)
+{
+	l_dbus_message_set_arguments(message, "s", match_rule);
+}
+
+static void add_match_callback(struct l_dbus_message *message, void *user_=
data)
+{
+	const char *error, *text;
+
+	if (l_dbus_message_get_error(message, &error, &text)) {
+		l_error("error=3D%s", error);
+		l_error("message=3D%s", text);
+		return;
+	}
+
+	if (!l_dbus_message_get_arguments(message, ""))
+		return;
+
+	l_info("add match");
+}
+
+static void ready_callback(void *user_data)
+{
+	l_info("ready");
+}
+
+static void disconnect_callback(void *user_data)
+{
+	l_main_quit();
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_dbus *dbus;
+	struct l_signal *sigchld;
+	int i;
+
+	if (!l_main_init())
+		return -1;
+
+	l_log_set_stderr();
+
+	start_dbus_daemon();
+
+	for (i =3D 0; i < 10; i++) {
+		usleep(200 * 1000);
+
+		dbus =3D l_dbus_new(TEST_BUS_ADDRESS);
+		if (dbus)
+			break;
+
+	}
+
+	sigchld =3D l_signal_create(SIGCHLD, sigchld_handler, NULL, NULL);
+
+	if (!dbus)
+		goto done;
+
+	l_dbus_set_debug(dbus, do_debug, "[DBUS] ", NULL);
+
+	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
+	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
+
+	l_dbus_register(dbus, signal_message, NULL, NULL);
+
+	l_dbus_method_call(dbus, "org.freedesktop.DBus",
+				"/org/freedesktop/DBus",
+				"org.freedesktop.DBus", "AddMatch",
+				add_match_setup,
+				add_match_callback, NULL, NULL);
+
+	l_dbus_method_call(dbus, "org.freedesktop.DBus",
+				"/org/freedesktop/DBus",
+				"org.freedesktop.DBus", "RequestName",
+				request_name_setup,
+				request_name_callback, NULL, NULL);
+
+	l_main_run_with_signal(signal_handler, NULL);
+
+	l_dbus_destroy(dbus);
+
+done:
+	if (dbus_daemon_pid > 0)
+		kill(dbus_daemon_pid, SIGKILL);
+
+	l_signal_remove(sigchld);
+
+	l_main_exit();
+
+	return 0;
+}
-- =

2.7.4


--===============1380742046711655879==--

