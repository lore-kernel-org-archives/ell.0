Content-Type: multipart/mixed; boundary="===============7152621536597159520=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] unit: Try dbus-properties tests on Dbus1 and kdbus
Date: Fri, 06 May 2016 12:18:52 +0200
Message-ID: <1462529934-6714-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1462529934-6714-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7152621536597159520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Same as test-dbus-message-fds.
---
 unit/test-dbus-properties.c | 124 +++++++++++++++++++++++++---------------=
----
 1 file changed, 70 insertions(+), 54 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 3238cf6..6eae592 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -40,7 +40,7 @@ static int kdbus_fd =3D -1;
 =

 static char bus_address[128];
 =

-static void start_dbus_daemon(void)
+static bool start_dbus_daemon(void)
 {
 	char *prg_argv[6];
 	char *prg_envp[1];
@@ -60,7 +60,7 @@ static void start_dbus_daemon(void)
 	pid =3D fork();
 	if (pid < 0) {
 		l_error("failed to fork new process");
-		return;
+		return false;
 	}
 =

 	if (pid =3D=3D 0) {
@@ -73,9 +73,11 @@ static void start_dbus_daemon(void)
 	dbus_daemon_pid =3D pid;
 =

 	strcpy(bus_address, TEST_BUS_ADDRESS);
+
+	return true;
 }
 =

-static void create_kdbus(void)
+static bool create_kdbus(void)
 {
 	char bus_name[64];
 =

@@ -84,11 +86,13 @@ static void create_kdbus(void)
 	kdbus_fd =3D _dbus_kernel_create_bus(bus_name);
 	if (kdbus_fd < 0) {
 		l_warn("kdbus not available");
-		return;
+		return false;
 	}
 =

 	snprintf(bus_address, sizeof(bus_address),
 				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
+
+	return true;
 }
 =

 static void signal_handler(struct l_signal *signal, uint32_t signo,
@@ -131,6 +135,7 @@ struct dbus_test {
 =

 static bool success;
 static struct l_queue *tests;
+static const struct l_queue_entry *current;
 =

 static void test_add(const char *name,
 			void (*start)(struct l_dbus *dbus, void *),
@@ -150,19 +155,24 @@ static void test_add(const char *name,
 =

 static void test_next()
 {
-	struct dbus_test *test =3D l_queue_pop_head(tests);
+	struct dbus_test *test;
 =

-	if (!test) {
+	if (current)
+		current =3D current->next;
+	else
+		current =3D l_queue_get_entries(tests);
+
+	if (!current) {
 		success =3D true;
 		l_main_quit();
 		return;
 	}
 =

+	test =3D current->data;
+
 	l_info("TEST: %s", test->name);
 =

 	test->start(dbus, test->data);
-
-	l_free(test);
 }
 =

 #define test_assert(cond)	\
@@ -916,42 +926,9 @@ static void test_object_manager_signals(struct l_dbus =
*dbus, void *test_data)
 						NULL));
 }
 =

-int main(int argc, char *argv[])
+static void test_run(void)
 {
-	struct l_signal *signal;
-	sigset_t mask;
-	int i;
-	bool kdbus =3D false;
-
-	for (i =3D 1; i < argc; i++) {
-		if (!strcmp(argv[i], "--kdbus"))
-			kdbus =3D true;
-	}
-
-	sigemptyset(&mask);
-	sigaddset(&mask, SIGINT);
-	sigaddset(&mask, SIGTERM);
-	sigaddset(&mask, SIGCHLD);
-
-	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
-
-	l_log_set_stderr();
-
-	if (kdbus)
-		create_kdbus();
-	else
-		start_dbus_daemon();
-
-	if (!bus_address[0])
-		return -1;
-
-	for (i =3D 0; i < 10; i++) {
-		usleep(200 * 1000);
-
-		dbus =3D l_dbus_new(bus_address);
-		if (dbus)
-			break;
-	}
+	success =3D false;
 =

 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
@@ -959,18 +936,18 @@ int main(int argc, char *argv[])
 	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
 					NULL, true)) {
 		l_info("Unable to register interface");
-		goto done;
+		return;
 	}
 =

 	if (!l_dbus_object_add_interface(dbus, "/test", "org.test", NULL)) {
 		l_info("Unable to instantiate interface");
-		goto done;
+		return;
 	}
 =

 	if (!l_dbus_object_add_interface(dbus, "/test",
 				"org.freedesktop.DBus.Properties", NULL)) {
 		l_info("Unable to instantiate the properties interface");
-		goto done;
+		return;
 	}
 =

 	l_dbus_add_signal_watch(dbus, "org.test", "/test", "org.test",
@@ -984,7 +961,7 @@ int main(int argc, char *argv[])
 =

 	if (!l_dbus_object_manager_enable(dbus)) {
 		l_info("Unable to enable Object Manager");
-		goto done;
+		return;
 	}
 =

 	l_dbus_add_signal_watch(dbus, "org.test", "/",
@@ -992,6 +969,15 @@ int main(int argc, char *argv[])
 				NULL, L_DBUS_MATCH_NONE,
 				om_signal_callback, NULL);
 =

+	l_main_run();
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_signal *signal;
+	sigset_t mask;
+	int i;
+
 	test_add("Legacy properties get", test_old_get, NULL);
 	test_add("Legacy properties set", test_old_set, NULL);
 	test_add("Legacy optional property", test_old_optional_get, NULL);
@@ -1003,21 +989,51 @@ int main(int argc, char *argv[])
 	test_add("org.freedesktop.DBus.ObjectManager signals",
 			test_object_manager_signals, NULL);
 =

-	l_main_run();
+	sigemptyset(&mask);
+	sigaddset(&mask, SIGINT);
+	sigaddset(&mask, SIGTERM);
+	sigaddset(&mask, SIGCHLD);
 =

-	l_queue_destroy(tests, l_free);
+	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
+
+	l_log_set_stderr();
+
+	if (!start_dbus_daemon())
+		return -1;
+
+	for (i =3D 0; i < 10; i++) {
+		usleep(200 * 1000);
+
+		dbus =3D l_dbus_new(bus_address);
+		if (dbus)
+			break;
+	}
+
+	test_run();
 =

-done:
 	l_dbus_destroy(dbus);
 =

-	if (dbus_daemon_pid > 0)
-		kill(dbus_daemon_pid, SIGKILL);
+	kill(dbus_daemon_pid, SIGKILL);
 =

-	if (kdbus_fd >=3D 0)
-		close(kdbus_fd);
+	if (!success)
+		goto done;
 =

+	if (!create_kdbus())
+		goto done;
+
+	dbus =3D l_dbus_new(bus_address);
+
+	test_run();
+
+	l_dbus_destroy(dbus);
+
+	close(kdbus_fd);
+
+done:
 	l_signal_remove(signal);
 =

+	l_queue_destroy(tests, l_free);
+
 	if (!success)
 		abort();
 =

-- =

2.7.4


--===============7152621536597159520==--

