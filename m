Content-Type: multipart/mixed; boundary="===============9010081690305538094=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/10] unit: Property change notifications signal tests
Date: Mon, 15 Feb 2016 17:44:21 +0100
Message-ID: <1455554662-15608-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9010081690305538094==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 133 ++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 133 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 19a25f5..289ece7 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -615,11 +615,134 @@ static void test_new_set(struct l_dbus *dbus, void *=
test_data)
 						NULL, NULL));
 }
 =

+static struct l_timeout *signal_timeout;
+
+static void signal_timeout_callback(struct l_timeout *timeout, void *user_=
data)
+{
+	signal_timeout =3D NULL;
+	test_assert(false);
+}
+
+static bool old_signal_received, new_signal_received;
+static const char *signal_string_value;
+
+static void test_signal_callback(struct l_dbus_message *message)
+{
+	const char *interface, *member, *property, *value;
+	struct l_dbus_message_iter variant, changed, invalidated;
+	struct l_dbus_message *call;
+
+	if (!signal_timeout)
+		return;
+
+	interface =3D l_dbus_message_get_interface(message);
+	member =3D l_dbus_message_get_member(message);
+
+	if (!strcmp(interface, "org.test") &&
+			!strcmp(member, "PropertyChanged")) {
+		test_assert(l_dbus_message_get_arguments(message, "sv",
+								&property,
+								&variant));
+		test_assert(!strcmp(property, "String"));
+		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
+								&value));
+		test_assert(!strcmp(value, signal_string_value));
+
+		test_assert(!old_signal_received);
+		old_signal_received =3D true;
+	}
+
+	if (!strcmp(interface, "org.freedesktop.DBus.Properties") &&
+			!strcmp(member, "PropertiesChanged")) {
+		test_assert(l_dbus_message_get_arguments(message, "sa{sv}as",
+								&interface,
+								&changed,
+								&invalidated));
+		test_assert(!strcmp(interface, "org.test"));
+
+		test_assert(l_dbus_message_iter_next_entry(&changed, &property,
+								&variant));
+		test_assert(!strcmp(property, "String"));
+		test_assert(l_dbus_message_iter_get_variant(&variant, "s",
+								&value));
+		test_assert(!strcmp(value, signal_string_value));
+
+		test_assert(!l_dbus_message_iter_next_entry(&changed, &property,
+								&variant));
+		test_assert(!l_dbus_message_iter_next_entry(&invalidated,
+								&property));
+
+		test_assert(!new_signal_received);
+		new_signal_received =3D true;
+	}
+
+	if (!old_signal_received || !new_signal_received)
+		return;
+
+	l_timeout_remove(signal_timeout);
+	signal_timeout =3D NULL;
+
+	if (!strcmp(signal_string_value, "foo")) {
+		/* Now repeat the test for the signal triggered by Set */
+
+		old_signal_received =3D false;
+		new_signal_received =3D false;
+
+		signal_timeout =3D l_timeout_create(1, signal_timeout_callback,
+							NULL, NULL);
+		test_assert(signal_timeout);
+
+		signal_string_value =3D "bar";
+
+		call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+		test_assert(call);
+		test_assert(l_dbus_message_set_arguments(call, "ssv",
+							"org.test", "String",
+							"s", "bar"));
+
+		test_assert(!setter_called);
+		test_assert(l_dbus_send(dbus, call));
+	} else {
+		test_assert(setter_called);
+		setter_called =3D false;
+
+		test_next();
+	}
+}
+
+static void test_property_signals(struct l_dbus *dbus, void *test_data)
+{
+	old_signal_received =3D false;
+	new_signal_received =3D false;
+
+	signal_timeout =3D l_timeout_create(1, signal_timeout_callback,
+						NULL, NULL);
+	test_assert(signal_timeout);
+
+	signal_string_value =3D "foo";
+
+	test_assert(l_dbus_property_changed(dbus, "/test",
+						"org.test", "String"));
+}
+
+static void signal_message(struct l_dbus_message *message, void *user_data)
+{
+	const char *path;
+
+	path =3D l_dbus_message_get_path(message);
+
+	if (!strcmp(path, "/test"))
+		test_signal_callback(message);
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
 	sigset_t mask;
 	int i;
+	struct l_dbus_message *call;
 =

 	sigemptyset(&mask);
 	sigaddset(&mask, SIGINT);
@@ -643,6 +766,15 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

+	l_dbus_register(dbus, signal_message, NULL, NULL);
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.freedesktop.DBus",
+						"/org/freedesktop/DBus",
+						"org.freedesktop.DBus",
+						"AddMatch");
+	l_dbus_message_set_arguments(call, "s", "type=3Dsignal,sender=3Dorg.test"=
);
+	l_dbus_send(dbus, call);
+
 	l_dbus_method_call(dbus, "org.freedesktop.DBus",
 				"/org/freedesktop/DBus",
 				"org.freedesktop.DBus", "RequestName",
@@ -675,6 +807,7 @@ int main(int argc, char *argv[])
 	test_add("Legacy properties set", test_old_set, NULL);
 	test_add("org.freedesktop.DBus.Properties get", test_new_get, NULL);
 	test_add("org.freedesktop.DBus.Properties set", test_new_set, NULL);
+	test_add("Property changed signals", test_property_signals, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============9010081690305538094==--

