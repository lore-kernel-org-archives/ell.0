Content-Type: multipart/mixed; boundary="===============1145787206403849871=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 20/21] unit: Add a test for the
 org.freedesktop.DBus.Properties interface
Date: Thu, 13 Nov 2014 12:36:24 +0200
Message-ID: <1415874985-13034-21-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1145787206403849871==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will run a properties interface, without any specific methods or
signals. Instead, it will test only the org.freedesktop.DBus.Properties
interface which is automatically created by ell. These methods will be
tested: GetAll, Set and Get. PropertiesChanged signal cannot be caught
since ell does not provide yet a mean to catch a signal.
---
 Makefile.am                  |   3 +
 unit/test-dbus-freedesktop.c | 347 +++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 350 insertions(+)
 create mode 100644 unit/test-dbus-freedesktop.c

diff --git a/Makefile.am b/Makefile.am
index beda08b..e86b740 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -101,6 +101,7 @@ unit_tests =3D unit/test-unit \
 			unit/test-dbus-util \
 			unit/test-dbus-message \
 			unit/test-dbus-service \
+			unit/test-dbus-freedesktop \
 			unit/test-gvariant-util \
 			unit/test-gvariant-message \
 			unit/test-siphash \
@@ -144,6 +145,8 @@ unit_test_dbus_util_LDADD =3D ell/libell-private.la
 =

 unit_test_dbus_service_LDADD =3D ell/libell-private.la
 =

+unit_test_dbus_freedesktop_LDADD =3D ell/libell-private.la
+
 unit_test_gvariant_util_LDADD =3D ell/libell-private.la
 =

 unit_test_gvariant_message_LDADD =3D ell/libell-private.la
diff --git a/unit/test-dbus-freedesktop.c b/unit/test-dbus-freedesktop.c
new file mode 100644
index 0000000..385707d
--- /dev/null
+++ b/unit/test-dbus-freedesktop.c
@@ -0,0 +1,347 @@
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
+#include <assert.h>
+#include <stdbool.h>
+
+#include <ell/ell.h>
+#include "ell/dbus-private.h"
+
+#define DBUS_TEST_PATH			"/"
+#define DBUS_TEST_INTERFACE		"net.test.dbus"
+#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
+
+static struct l_dbus *dbus;
+static int status =3D -1;
+static char *bar_value =3D NULL;
+
+static void dbus_method_error(struct l_dbus_message *message)
+{
+	const char *error, *text;
+
+	if (!l_dbus_message_get_error(message, &error, &text))
+		return;
+
+	l_error("error=3D%s", error);
+	l_error("message=3D%s", text);
+	l_main_quit();
+}
+
+static void get_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct l_dbus_message_iter variant;
+	const char *sval;
+
+	l_info("Get result");
+
+	dbus_method_error(message);
+
+	l_dbus_message_get_arguments(message, "v", &variant);
+	l_dbus_message_iter_get_variant(&variant, "s", &sval);
+
+	if (!strcmp(sval, "done"))
+		status =3D 0;
+
+	l_main_quit();
+}
+
+static void build_get_call(struct l_dbus_message *message, void *user_data)
+{
+	const char *interface =3D DBUS_TEST_INTERFACE;
+	const char *name =3D "bar";
+
+	l_dbus_message_set_arguments(message, "ss", interface, name);
+}
+
+static void test_get_bar(void *user_data)
+{
+	l_dbus_method_call(dbus, DBUS_TEST_INTERFACE,
+				DBUS_TEST_PATH,
+				DBUS_INTERFACE_PROPERTIES,
+				"Get",  build_get_call,
+				get_cb, NULL, NULL);
+}
+
+static void set_cb(struct l_dbus_message *message, void *user_data)
+{
+	l_info("Set result");
+
+	dbus_method_error(message);
+
+	l_idle_oneshot(test_get_bar, NULL, NULL);
+}
+
+static void build_set_call(struct l_dbus_message *message, void *user_data)
+{
+	const char *interface =3D DBUS_TEST_INTERFACE;
+	const char *name =3D "bar";
+	const char *value =3D "done";
+
+	l_dbus_message_set_arguments(message, "ssv",
+					interface, name, "s", value);
+}
+
+static void test_set_bar(void *user_data)
+{
+	l_dbus_method_call(dbus, DBUS_TEST_INTERFACE,
+				DBUS_TEST_PATH,
+				DBUS_INTERFACE_PROPERTIES,
+				"Set",  build_set_call,
+				set_cb, NULL, NULL);
+}
+
+static void get_all_cb(struct l_dbus_message *message, void *user_data)
+{
+	struct l_dbus_message_iter dict, variant;
+	const char *name, *sval;
+	int ival;
+
+	l_info("GetAll result");
+
+	dbus_method_error(message);
+
+	if (!l_dbus_message_get_arguments(message, "a{sv}", &dict))
+		goto error;
+
+	while (l_dbus_message_iter_next_entry(&dict, &name, &variant)) {
+		if (!strcmp(name, "foo")) {
+			l_dbus_message_iter_get_variant(&variant, "i", &ival);
+			if (ival !=3D 7)
+				goto error;
+		} else if (!strcmp(name, "bar")) {
+			l_dbus_message_iter_get_variant(&variant, "s", &sval);
+			if (strcmp(sval, "bapapa"))
+				goto error;
+		} else if (!strcmp(name, "not")) {
+			l_dbus_message_iter_get_variant(&variant, "i", &ival);
+			if (ival !=3D 42)
+				goto error;
+		} else
+			goto error;
+	}
+
+	l_idle_oneshot(test_set_bar, NULL, NULL);
+
+	return;
+error:
+	l_main_quit();
+}
+
+static void build_get_all_call(struct l_dbus_message *message, void *user_=
data)
+{
+	const char *interface =3D DBUS_TEST_INTERFACE;
+
+	l_dbus_message_set_arguments(message, "s", interface);
+}
+
+static void test_get_all(void *user_data)
+{
+	l_dbus_method_call(dbus, DBUS_TEST_INTERFACE,
+				DBUS_TEST_PATH,
+				DBUS_INTERFACE_PROPERTIES,
+				"GetAll", build_get_all_call,
+				get_all_cb, NULL, NULL);
+}
+
+static void request_name_setup(struct l_dbus_message *message, void *user_=
data)
+{
+	const char *name =3D DBUS_TEST_INTERFACE;
+
+	l_dbus_message_set_arguments(message, "su", name, 0);
+}
+
+static void request_name_callback(struct l_dbus_message *message,
+							void *user_data)
+{
+	uint32_t result;
+
+	dbus_method_error(message);
+
+	if (!l_dbus_message_get_arguments(message, "u", &result))
+		return;
+
+	l_info("request name result=3D%d", result);
+	l_idle_oneshot(test_get_all, NULL, NULL);
+}
+
+static void ready_callback(void *user_data)
+{
+	l_info("DBus is ready");
+}
+
+static void disconnect_callback(void *user_data)
+{
+	l_main_quit();
+}
+
+static bool get_foo(const struct l_dbus_property *property,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	int value =3D 7;
+
+	l_dbus_message_builder_append_basic(builder, 'i', &value);
+
+	return true;
+}
+
+static bool get_bar(const struct l_dbus_property *property,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	const char *value =3D bar_value;
+
+	if (!value)
+		value =3D "bapapa";
+
+	l_dbus_message_builder_append_basic(builder, 's', value);
+
+	return true;
+}
+
+static bool get_not(const struct l_dbus_property *property,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	int value =3D 42;
+
+	l_dbus_message_builder_append_basic(builder, 'i', &value);
+
+	return true;
+}
+
+static void set_bar(const struct l_dbus_property *property,
+				struct l_dbus *dbus,
+				struct l_dbus_message_iter *iter,
+				uint32_t id, void *user_data)
+{
+	const char *error_str =3D "Invalid arguments";
+	const char *value;
+
+	if (strcmp(property->name, "bar"))
+		goto invalid;
+
+	if (!l_dbus_message_iter_get_variant(iter, "s", &value)) {
+		error_str =3D "Could not get the value";
+		goto invalid;
+	}
+
+	if (bar_value)
+		l_free(bar_value);
+
+	bar_value =3D l_strdup(value);
+
+	l_dbus_pending_property_success(dbus, id);
+	l_dbus_emit_property_changed(dbus, DBUS_TEST_PATH,
+					DBUS_TEST_INTERFACE, property->name);
+	return;
+invalid:
+	l_dbus_pending_property_error(dbus, id, "org.test.InvalidArguments",
+							"%s", error_str);
+}
+
+static bool property_exists(const struct l_dbus_property *property,
+							void *user_data)
+{
+	if (!strcmp(property->name, "foo") ||
+				!strcmp(property->name, "bar") ||
+				!strcmp(property->name, "not") ||
+				!strcmp(property->name, "nOne"))
+		return true;
+	return false;
+}
+
+static void do_debug(const char *str, void *user_data)
+{
+	const char *prefix =3D user_data;
+
+	l_info("%s%s", prefix, str);
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
+	}
+}
+
+static struct l_dbus_property test_properties[] =3D {
+	{ L_DBUS_RO_PROPERTY("foo", "i", get_foo, property_exists) },
+	{ L_DBUS_RW_PROPERTY("bar", "s", get_bar, set_bar, property_exists) },
+	{ L_DBUS_RO_PROPERTY("nOne", "s", NULL, property_exists) },
+	{ L_DBUS_RO_PROPERTY("nope", "s", NULL, NULL) },
+	{ L_DBUS_RW_PROPERTY("not", "i", get_not, NULL, property_exists) },
+	{ }
+};
+
+int main(int argc, char *argv[])
+{
+	struct l_signal *signal;
+	sigset_t mask;
+
+	sigemptyset(&mask);
+	sigaddset(&mask, SIGINT);
+	sigaddset(&mask, SIGTERM);
+	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
+
+	l_log_set_stderr();
+
+	dbus =3D l_dbus_new_default(L_DBUS_SESSION_BUS);
+
+	l_dbus_set_debug(dbus, do_debug, "[DBUS] ", NULL);
+	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
+	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
+
+	l_dbus_method_call(dbus, "org.freedesktop.DBus",
+				"/org/freedesktop/DBus",
+				"org.freedesktop.DBus", "RequestName",
+				request_name_setup,
+				request_name_callback, NULL, NULL);
+
+	if (!l_dbus_register_interface(dbus, DBUS_TEST_PATH,
+					DBUS_TEST_INTERFACE, NULL, NULL,
+					test_properties, NULL, NULL))
+		goto cleanup;
+
+	l_main_run();
+
+	if (bar_value)
+		l_free(bar_value);
+
+	if (status < 0)
+		l_info("Test failed");
+
+cleanup:
+	l_dbus_destroy(dbus);
+	l_signal_remove(signal);
+
+	return status;
+}
-- =

2.0.4


--===============1145787206403849871==--

