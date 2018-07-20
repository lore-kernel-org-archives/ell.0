Content-Type: multipart/mixed; boundary="===============8190043313161692841=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Add an fswatch unit test
Date: Fri, 20 Jul 2018 18:49:51 +0200
Message-ID: <20180720164951.9338-3-andrew.zaborowski@intel.com>
In-Reply-To: <20180720164951.9338-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8190043313161692841==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore          |   1 +
 Makefile.am         |   5 +-
 unit/test-fswatch.c | 293 ++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 3 files changed, 298 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-fswatch.c

diff --git a/.gitignore b/.gitignore
index 4dc3777..6c9ffb0 100644
--- a/.gitignore
+++ b/.gitignore
@@ -55,6 +55,7 @@ unit/test-uuid
 unit/test-key
 unit/test-pbkdf2
 unit/test-dhcp
+unit/test-fswatch
 unit/cert-*.pem
 unit/cert-*.csr
 unit/cert-*.srl
diff --git a/Makefile.am b/Makefile.am
index 8203fd4..9fe00fb 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -147,7 +147,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-base64 \
 			unit/test-uuid \
 			unit/test-pbkdf2 \
-			unit/test-dhcp
+			unit/test-dhcp \
+			unit/test-fswatch
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
@@ -264,6 +265,8 @@ unit_test_uuid_LDADD =3D ell/libell-private.la
 =

 unit_test_dhcp_LDADD =3D ell/libell-private.la
 =

+unit_test_fswatch_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-fswatch.c b/unit/test-fswatch.c
new file mode 100644
index 0000000..d8b5f7b
--- /dev/null
+++ b/unit/test-fswatch.c
@@ -0,0 +1,293 @@
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
+#include <unistd.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <stdio.h>
+#include <assert.h>
+
+#include <ell/ell.h>
+
+#define TEST_DIR "/tmp/ell-test-dir"
+#define TEST_FILE1 "/tmp/ell-test-dir/file1"
+#define TEST_FILE2 "/tmp/ell-test-dir/file2"
+
+static struct l_fswatch *dir_watch;
+static struct l_fswatch *file_watch;
+static int data;
+
+static enum {
+	TEST_DIR_DESTROY_CB_1,
+	TEST_FILE_CREATE,
+	TEST_FILE_MOVE,
+	TEST_FILE_MODIFY,
+	TEST_FILE_REMOVE,
+	TEST_DIR_REMOVE,
+	TEST_DIR_DESTROY_CB_2,
+} state;
+
+static int substate;
+
+enum {
+	TEST_FILE_MOVE_DIR_FROM_EVENT =3D 1 << 0,
+	TEST_FILE_MOVE_DIR_TO_EVENT =3D 1 << 1,
+	TEST_FILE_MOVE_FILE_EVENT =3D 1 << 2,
+	TEST_FILE_MOVE_ALL =3D 7,
+};
+
+enum {
+	TEST_FILE_MODIFY_DIR_EVENT =3D 1 << 0,
+	TEST_FILE_MODIFY_FILE_EVENT =3D 1 << 1,
+	TEST_FILE_MODIFY_ALL =3D 3,
+};
+
+enum {
+	TEST_FILE_REMOVE_DIR_EVENT =3D 1 << 0,
+	TEST_FILE_REMOVE_FILE_EVENT =3D 1 << 1,
+	TEST_FILE_REMOVE_DESTROY_CB =3D 1 << 2,
+	TEST_FILE_REMOVE_ALL =3D 7,
+};
+
+static void test_file_move_check(void)
+{
+	if (substate =3D=3D TEST_FILE_MOVE_ALL) {
+		l_info("TEST_FILE_MODIFY");
+		state =3D TEST_FILE_MODIFY;
+		substate =3D 0;
+		assert(close(creat(TEST_FILE2, 0600)) =3D=3D 0);
+	}
+}
+
+static void test_file_modify_check(void)
+{
+	if (substate =3D=3D TEST_FILE_MODIFY_ALL) {
+		l_info("TEST_FILE_REMOVE");
+		state =3D TEST_FILE_REMOVE;
+		substate =3D 0;
+		assert(unlink(TEST_FILE2) =3D=3D 0);
+	}
+}
+
+static void test_file_remove_check(void)
+{
+	if (substate =3D=3D TEST_FILE_REMOVE_ALL) {
+		l_info("TEST_DIR_REMOVE");
+		state =3D TEST_DIR_REMOVE;
+		substate =3D 0;
+		assert(rmdir(TEST_DIR) =3D=3D 0);
+	}
+}
+
+static void file_watch_destroy(void *user_data)
+{
+	assert(user_data =3D=3D &data);
+	assert(state =3D=3D TEST_FILE_REMOVE);
+	assert(!(substate & TEST_FILE_REMOVE_DESTROY_CB));
+	assert(substate & TEST_FILE_REMOVE_FILE_EVENT);
+
+	substate |=3D TEST_FILE_REMOVE_DESTROY_CB;
+
+	test_file_remove_check();
+}
+
+static void file_watch_cb(struct l_fswatch *watch, const char *filename,
+				enum l_fswatch_event event, void *user_data)
+{
+	assert(watch =3D=3D file_watch);
+	assert(user_data =3D=3D &data);
+	assert(filename =3D=3D NULL);
+
+	switch (state) {
+	case TEST_FILE_MOVE:
+		assert(event =3D=3D L_FSWATCH_EVENT_MOVE);
+		assert(!(substate & TEST_FILE_MOVE_FILE_EVENT));
+
+		substate |=3D TEST_FILE_MOVE_FILE_EVENT;
+
+		test_file_move_check();
+		break;
+	case TEST_FILE_MODIFY:
+		assert(event =3D=3D L_FSWATCH_EVENT_MODIFY);
+		assert(!(substate & TEST_FILE_MODIFY_FILE_EVENT));
+
+		substate |=3D TEST_FILE_MODIFY_FILE_EVENT;
+
+		test_file_modify_check();
+		break;
+	case TEST_FILE_REMOVE:
+		assert(event =3D=3D L_FSWATCH_EVENT_DELETE);
+		assert(!(substate & TEST_FILE_REMOVE_FILE_EVENT));
+
+		substate |=3D TEST_FILE_REMOVE_FILE_EVENT;
+
+		test_file_remove_check();
+		break;
+	default:
+		assert(false);
+	}
+}
+
+static void dir_watch_destroy_1(void *user_data)
+{
+	assert(user_data =3D=3D &data);
+	assert(state =3D=3D TEST_DIR_DESTROY_CB_1);
+	assert(dir_watch);
+
+	dir_watch =3D NULL;
+}
+
+static void dir_watch_destroy_2(void *user_data)
+{
+	assert(user_data =3D=3D &data);
+	assert(state =3D=3D TEST_DIR_DESTROY_CB_2);
+	assert(dir_watch);
+
+	l_main_quit();
+
+	dir_watch =3D NULL;
+}
+
+static void dir_watch_cb(struct l_fswatch *watch, const char *filename,
+				enum l_fswatch_event event, void *user_data)
+{
+	assert(watch =3D=3D dir_watch);
+	assert(user_data =3D=3D &data);
+
+	switch (state) {
+	case TEST_FILE_CREATE:
+		assert(event =3D=3D L_FSWATCH_EVENT_CREATE);
+		assert(filename);
+		assert(strstr(TEST_FILE1, filename));
+
+		file_watch =3D l_fswatch_new(TEST_FILE1, file_watch_cb, &data,
+						file_watch_destroy);
+		assert(file_watch);
+
+		l_info("TEST_FILE_MOVE");
+		state =3D TEST_FILE_MOVE;
+		substate =3D 0;
+		assert(rename(TEST_FILE1, TEST_FILE2) =3D=3D 0);
+		break;
+	case TEST_FILE_MOVE:
+		assert(event =3D=3D L_FSWATCH_EVENT_MOVE);
+		assert(filename);
+
+		if (strstr(TEST_FILE1, filename)) {
+			assert(!(substate & TEST_FILE_MOVE_DIR_FROM_EVENT));
+
+			substate |=3D TEST_FILE_MOVE_DIR_FROM_EVENT;
+		} else if (strstr(TEST_FILE2, filename)) {
+			assert(!(substate & TEST_FILE_MOVE_DIR_TO_EVENT));
+
+			substate |=3D TEST_FILE_MOVE_DIR_TO_EVENT;
+		} else
+			assert(false);
+
+		test_file_move_check();
+		break;
+	case TEST_FILE_MODIFY:
+		assert(event =3D=3D L_FSWATCH_EVENT_MODIFY);
+		assert(filename);
+		assert(strstr(TEST_FILE2, filename));
+		assert(!(substate & TEST_FILE_MODIFY_DIR_EVENT));
+
+		substate |=3D TEST_FILE_MODIFY_DIR_EVENT;
+
+		test_file_modify_check();
+		break;
+	case TEST_FILE_REMOVE:
+		assert(event =3D=3D L_FSWATCH_EVENT_DELETE);
+		assert(filename);
+		assert(strstr(TEST_FILE2, filename));
+		assert(!(substate & TEST_FILE_REMOVE_DIR_EVENT));
+
+		substate |=3D TEST_FILE_REMOVE_DIR_EVENT;
+
+		test_file_remove_check();
+		break;
+	case TEST_DIR_REMOVE:
+		assert(event =3D=3D L_FSWATCH_EVENT_DELETE);
+		assert(filename =3D=3D NULL);
+
+		l_info("TEST_DIR_DESTROY_CB_2");
+		state =3D TEST_DIR_DESTROY_CB_2;
+		break;
+	default:
+		assert(false);
+	}
+}
+
+static void timeout_cb(struct l_timeout *timeout, void *user_data)
+{
+	assert(false);
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_timeout *timeout;
+
+	assert(l_main_init());
+
+	l_log_set_stderr();
+
+	unlink(TEST_FILE1);
+	unlink(TEST_FILE2);
+	rmdir(TEST_DIR);
+	assert(mkdir(TEST_DIR, 0700) =3D=3D 0);
+
+	timeout =3D l_timeout_create(1, timeout_cb, NULL, NULL);
+
+	l_info("TEST_DIR_DESTROY_CB_1");
+	state =3D TEST_DIR_DESTROY_CB_1;
+
+	dir_watch =3D l_fswatch_new(TEST_DIR, dir_watch_cb, &data,
+					dir_watch_destroy_1);
+
+	assert(dir_watch);
+	l_fswatch_destroy(dir_watch);
+	assert(!dir_watch);
+
+	dir_watch =3D l_fswatch_new(TEST_DIR, dir_watch_cb, &data,
+					dir_watch_destroy_2);
+
+	assert(dir_watch);
+	assert(!l_fswatch_new(TEST_FILE1, file_watch_cb, &data,
+				file_watch_destroy));
+
+	l_info("TEST_FILE_CREATE");
+	state =3D TEST_FILE_CREATE;
+	assert(close(creat(TEST_FILE1, 0600)) =3D=3D 0);
+
+	l_main_run();
+
+	l_timeout_remove(timeout);
+
+	l_main_exit();
+
+	return 0;
+}
-- =

2.14.1


--===============8190043313161692841==--

