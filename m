Content-Type: multipart/mixed; boundary="===============5207573806037609625=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/10] unit:
 org.freedesktop.DBus.ObjectManager.GetManagedObject test
Date: Mon, 15 Feb 2016 17:44:22 +0100
Message-ID: <1455554662-15608-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5207573806037609625==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 64 +++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 64 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index 289ece7..acbab29 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -727,6 +727,68 @@ static void test_property_signals(struct l_dbus *dbus,=
 void *test_data)
 						"org.test", "String"));
 }
 =

+static void object_manager_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message_iter objects, interfaces, properties, variant;
+	const char *path, *interface, *name;
+	bool object_manager_found =3D false;
+	bool test_found =3D false;
+	bool properties_found =3D false;
+
+	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(l_dbus_message_get_arguments(message, "a{oa{sa{sv}}}",
+							&objects));
+
+	while (l_dbus_message_iter_next_entry(&objects, &path, &interfaces)) {
+		while (l_dbus_message_iter_next_entry(&interfaces, &interface,
+							&properties)) {
+			if (!strcmp(path, "/") && !strcmp(interface,
+					"org.freedesktop.DBus.ObjectManager")) {
+				test_assert(!object_manager_found);
+				object_manager_found =3D true;
+				test_assert(!l_dbus_message_iter_next_entry(
+							&properties, &name,
+							&variant));
+			}
+
+			if (!strcmp(path, "/test") && !strcmp(interface,
+					"org.freedesktop.DBus.Properties")) {
+				test_assert(!properties_found);
+				properties_found =3D true;
+				test_assert(!l_dbus_message_iter_next_entry(
+							&properties, &name,
+							&variant));
+			}
+
+			if (!strcmp(path, "/test") && !strcmp(interface,
+								"org.test")) {
+				test_assert(!test_found);
+				test_found =3D true;
+				validate_properties(&properties);
+			}
+		}
+	}
+
+	test_assert(object_manager_found && test_found && properties_found);
+
+	test_next();
+}
+
+static void test_object_manager_get(struct l_dbus *dbus, void *test_data)
+{
+	struct l_dbus_message *call =3D
+		l_dbus_message_new_method_call(dbus, "org.test", "/",
+					"org.freedesktop.DBus.ObjectManager",
+					"GetManagedObjects");
+
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, ""));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, object_manager_callback,
+						NULL, NULL));
+}
+
 static void signal_message(struct l_dbus_message *message, void *user_data)
 {
 	const char *path;
@@ -808,6 +870,8 @@ int main(int argc, char *argv[])
 	test_add("org.freedesktop.DBus.Properties get", test_new_get, NULL);
 	test_add("org.freedesktop.DBus.Properties set", test_new_set, NULL);
 	test_add("Property changed signals", test_property_signals, NULL);
+	test_add("org.freedesktop.DBus.ObjectManager get",
+			test_object_manager_get, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============5207573806037609625==--

