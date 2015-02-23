Content-Type: multipart/mixed; boundary="===============2401558448471935954=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v5 1/4] unit: dbus: Add test for filter rule
Date: Mon, 23 Feb 2015 13:54:57 +0200
Message-ID: <1424692500-21681-2-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424692500-21681-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2401558448471935954==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Testing _dbus1_filter_format_match() function.
---
 Makefile.am            |   3 +
 unit/test-dbus-watch.c | 203 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 206 insertions(+)
 create mode 100644 unit/test-dbus-watch.c

diff --git a/Makefile.am b/Makefile.am
index 36a680b..cea1b7a 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -107,6 +107,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-dbus-util \
 			unit/test-dbus-message \
 			unit/test-dbus-service \
+			unit/test-dbus-watch \
 			unit/test-gvariant-util \
 			unit/test-gvariant-message \
 			unit/test-siphash \
@@ -154,6 +155,8 @@ unit_test_dbus_util_LDADD =3D ell/libell-private.la
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
index 0000000..3868c8f
--- /dev/null
+++ b/unit/test-dbus-watch.c
@@ -0,0 +1,203 @@
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
+#include <stdio.h>
+
+#include <ell/ell.h>
+#include "ell/dbus-private.h"
+
+#define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
+#define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
+#define DBUS_INTERFACE_DBUS	"org.freedesktop.DBus"
+#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
+
+struct watch_test {
+	const char *name;
+	const char *service;
+	const char *path;
+	const char *interface;
+	const char *method;
+	const char *expected;
+};
+
+static const struct watch_test match_test_1 =3D {
+	.name =3D ":1.101",
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"path=3D'/org/freedesktop/DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.101'",
+};
+
+static const struct watch_test match_test_2 =3D {
+	.name =3D ":1.102",
+	.service =3D NULL,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"path=3D'/org/freedesktop/DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.102'",
+};
+
+static const struct watch_test match_test_3 =3D {
+	.name =3D ":1.102",
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D NULL,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.102'",
+};
+
+static const struct watch_test match_test_4 =3D {
+	.name =3D ":1.102",
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D NULL,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"path=3D'/org/freedesktop/DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.102'",
+};
+
+static const struct watch_test match_test_5 =3D {
+	.name =3D ":1.102",
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D NULL,
+	.expected =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"path=3D'/org/freedesktop/DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"arg0=3D':1.102'",
+};
+
+static const struct watch_test match_test_6 =3D {
+	.name =3D NULL,
+	.service =3D DBUS_SERVICE_DBUS,
+	.path =3D DBUS_PATH_DBUS,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"sender=3D'org.freedesktop.DBus',"
+		"path=3D'/org/freedesktop/DBus',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged'",
+};
+
+static const struct watch_test match_test_7 =3D {
+	.name =3D ":1.101",
+	.service =3D NULL,
+	.path =3D NULL,
+	.interface =3D DBUS_INTERFACE_DBUS,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"interface=3D'org.freedesktop.DBus',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.101'",
+};
+
+static const struct watch_test match_test_8 =3D {
+	.name =3D ":1.101",
+	.service =3D NULL,
+	.path =3D NULL,
+	.interface =3D NULL,
+	.method =3D "NameOwnerChanged",
+	.expected =3D "type=3D'signal',"
+		"member=3D'NameOwnerChanged',"
+		"arg0=3D':1.101'",
+};
+
+static const struct watch_test match_test_9 =3D {
+	.name =3D NULL,
+	.service =3D NULL,
+	.path =3D NULL,
+	.interface =3D NULL,
+	.method =3D NULL,
+	.expected =3D "type=3D'signal'",
+};
+
+static void test_match(const void *test_data)
+{
+	const struct watch_test *test =3D test_data;
+	struct dbus1_filter_data *data;
+	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
+
+	data =3D _dbus1_filter_data_get(NULL,
+				NULL,
+				test->service,
+				test->path,
+				test->interface,
+				test->method,
+				test->name,
+				NULL,
+				NULL,
+				NULL);
+
+	_dbus1_filter_format_match(data, rule, sizeof(rule));
+
+	assert(strcmp(rule, test->expected) =3D=3D 0);
+
+	_dbus1_filter_data_destroy(data);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("DBus filter NameOwnerChanged", test_match, &match_test_1);
+	l_test_add("DBus filter NULL service", test_match, &match_test_2);
+	l_test_add("DBus filter NULL path", test_match, &match_test_3);
+	l_test_add("DBus filter NULL interface", test_match, &match_test_4);
+	l_test_add("DBus filter NULL method", test_match, &match_test_5);
+	l_test_add("DBus filter NULL argument", test_match, &match_test_6);
+	l_test_add("DBus filter NULL service and path", test_match,
+								&match_test_7);
+	l_test_add("DBus filter NULL service, path and interface", test_match,
+								&match_test_8);
+	l_test_add("DBus filter NULL all fields", test_match, &match_test_9);
+
+	return l_test_run();
+}
-- =

2.1.0


--===============2401558448471935954==--

