Content-Type: multipart/mixed; boundary="===============6106230993256616422=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: End to end FD passing test
Date: Sat, 30 Apr 2016 00:44:02 +0200
Message-ID: <1461969842-11704-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461969842-11704-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6106230993256616422==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Doesn't really belong in test-dbus-properties.c...
---
 unit/test-dbus-properties.c | 93 +++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 93 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 3238cf6..c5b2f6e 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -28,6 +28,9 @@
 #include <stdlib.h>
 #include <sys/wait.h>
 #include <stdio.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <errno.h>
 =

 #include <ell/ell.h>
 #include <ell/dbus-private.h>
@@ -277,6 +280,22 @@ static bool test_path_getter(struct l_dbus *dbus,
 	return l_dbus_message_builder_append_basic(builder, 'o', "/foo/bar");
 }
 =

+static struct l_dbus_message *get_random_callback(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *reply;
+	int fd;
+
+	reply =3D l_dbus_message_new_method_return(message);
+
+	fd =3D open("/dev/random", O_RDONLY);
+	l_dbus_message_set_arguments(reply, "h", fd);
+	close(fd);
+
+	return reply;
+}
+
 static void setup_test_interface(struct l_dbus_interface *interface)
 {
 	l_dbus_interface_property(interface, "String", 0, "s",
@@ -289,6 +308,9 @@ static void setup_test_interface(struct l_dbus_interfac=
e *interface)
 					test_string_getter, test_error_setter);
 	l_dbus_interface_property(interface, "Path", 0, "o",
 					test_path_getter, NULL);
+
+	l_dbus_interface_method(interface, "GetRandom", 0, get_random_callback,
+				"h", "", "randomfd");
 }
 =

 static void validate_properties(struct l_dbus_message_iter *dict)
@@ -916,6 +938,75 @@ static void test_object_manager_signals(struct l_dbus =
*dbus, void *test_data)
 						NULL));
 }
 =

+static int count_fds(void)
+{
+	int fd;
+	int count =3D 0;
+
+	for (fd =3D 0; fd < FD_SETSIZE; fd++)
+		if (fcntl(fd, F_GETFL) !=3D -1 || errno !=3D EBADF)
+			count++;
+
+	return count;
+}
+
+static bool compare_failed;
+
+static void compare_files(int a, int b)
+{
+	struct stat sa, sb;
+
+	compare_failed =3D true;
+
+	test_assert(fstat(a, &sa) =3D=3D 0);
+	test_assert(fstat(b, &sb) =3D=3D 0);
+
+	test_assert(sa.st_dev =3D=3D sb.st_dev);
+	test_assert(sa.st_ino =3D=3D sb.st_ino);
+	test_assert(sa.st_rdev =3D=3D sb.st_rdev);
+
+	compare_failed =3D false;
+}
+
+static int open_fds;
+
+static void get_random_idle_callback(void *user_data)
+{
+	test_assert(count_fds() =3D=3D open_fds);
+
+	test_next();
+}
+
+static void get_random_return_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	int fd0, fd1;
+
+	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
+
+	test_assert(l_dbus_message_get_arguments(message, "h", &fd1));
+
+	fd0 =3D open("/dev/random", O_RDONLY);
+	test_assert(fd0 !=3D -1);
+
+	compare_files(fd0, fd1);
+	if (compare_failed)
+		return;
+
+	close(fd0);
+	close(fd1);
+
+	test_assert(l_idle_oneshot(get_random_idle_callback, NULL, NULL));
+}
+
+static void test_fd_passing(struct l_dbus *dbus, void *test_data)
+{
+	open_fds =3D count_fds();
+
+	l_dbus_method_call(dbus, "org.test", "/test", "org.test", "GetRandom",
+				NULL, get_random_return_callback, NULL, NULL);
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
@@ -1003,6 +1094,8 @@ int main(int argc, char *argv[])
 	test_add("org.freedesktop.DBus.ObjectManager signals",
 			test_object_manager_signals, NULL);
 =

+	test_add("FD passing", test_fd_passing, NULL);
+
 	l_main_run();
 =

 	l_queue_destroy(tests, l_free);
-- =

2.5.0


--===============6106230993256616422==--

