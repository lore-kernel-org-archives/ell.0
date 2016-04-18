Content-Type: multipart/mixed; boundary="===============8601875762754687479=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] unit: Add test-dbus-properties --kdbus option
Date: Mon, 18 Apr 2016 16:31:12 +0200
Message-ID: <1460989877-20113-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8601875762754687479==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 49 ++++++++++++++++++++++++++++++++++++++++-=
----
 1 file changed, 44 insertions(+), 5 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index c7ed384..3238cf6 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -27,13 +27,19 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <sys/wait.h>
+#include <stdio.h>
 =

 #include <ell/ell.h>
+#include <ell/dbus-private.h>
 =

 #define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
 =

 static pid_t dbus_daemon_pid =3D -1;
 =

+static int kdbus_fd =3D -1;
+
+static char bus_address[128];
+
 static void start_dbus_daemon(void)
 {
 	char *prg_argv[6];
@@ -65,6 +71,24 @@ static void start_dbus_daemon(void)
 	l_info("dbus-daemon process %d created", pid);
 =

 	dbus_daemon_pid =3D pid;
+
+	strcpy(bus_address, TEST_BUS_ADDRESS);
+}
+
+static void create_kdbus(void)
+{
+	char bus_name[64];
+
+	snprintf(bus_name, sizeof(bus_name), "%u-ell-test", getuid());
+
+	kdbus_fd =3D _dbus_kernel_create_bus(bus_name);
+	if (kdbus_fd < 0) {
+		l_warn("kdbus not available");
+		return;
+	}
+
+	snprintf(bus_address, sizeof(bus_address),
+				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
 }
 =

 static void signal_handler(struct l_signal *signal, uint32_t signo,
@@ -164,6 +188,9 @@ static void request_name_callback(struct l_dbus *dbus, =
bool success,
 static void ready_callback(void *user_data)
 {
 	l_info("ready");
+
+	l_dbus_name_acquire(dbus, "org.test", false, false, false,
+				request_name_callback, NULL);
 }
 =

 static void disconnect_callback(void *user_data)
@@ -894,6 +921,12 @@ int main(int argc, char *argv[])
 	struct l_signal *signal;
 	sigset_t mask;
 	int i;
+	bool kdbus =3D false;
+
+	for (i =3D 1; i < argc; i++) {
+		if (!strcmp(argv[i], "--kdbus"))
+			kdbus =3D true;
+	}
 =

 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
@@ -904,12 +937,18 @@ int main(int argc, char *argv[])
 =

 	l_log_set_stderr();
 =

-	start_dbus_daemon();
+	if (kdbus)
+		create_kdbus();
+	else
+		start_dbus_daemon();
+
+	if (!bus_address[0])
+		return -1;
 =

 	for (i =3D 0; i < 10; i++) {
 		usleep(200 * 1000);
 =

-		dbus =3D l_dbus_new(TEST_BUS_ADDRESS);
+		dbus =3D l_dbus_new(bus_address);
 		if (dbus)
 			break;
 	}
@@ -917,9 +956,6 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

-	l_dbus_name_acquire(dbus, "org.test", false, false, false,
-				request_name_callback, NULL);
-
 	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
 					NULL, true)) {
 		l_info("Unable to register interface");
@@ -977,6 +1013,9 @@ done:
 	if (dbus_daemon_pid > 0)
 		kill(dbus_daemon_pid, SIGKILL);
 =

+	if (kdbus_fd >=3D 0)
+		close(kdbus_fd);
+
 	l_signal_remove(signal);
 =

 	if (!success)
-- =

2.5.0


--===============8601875762754687479==--

