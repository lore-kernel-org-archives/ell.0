Content-Type: multipart/mixed; boundary="===============8905579484559728248=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/10] unit: org.freedesktop.DBus.ObjectManager signals tests
Date: Mon, 15 Feb 2016 18:03:14 +0100
Message-ID: <1455555794-15731-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8905579484559728248==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 88 +++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 88 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index acbab29..73172c5 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -789,6 +789,89 @@ static void test_object_manager_get(struct l_dbus *dbu=
s, void *test_data)
 						NULL, NULL));
 }
 =

+static struct l_timeout *om_signal_timeout;
+
+static void om_signal_timeout_callback(struct l_timeout *timeout,
+					void *user_data)
+{
+	om_signal_timeout =3D NULL;
+	test_assert(false);
+}
+
+static bool expect_interfaces_added;
+
+static void root_signal_callback(struct l_dbus_message *message)
+{
+	const char *path, *interface, *member;
+	struct l_dbus_message_iter interfaces, properties;
+
+	if (!om_signal_timeout)
+		return;
+
+	interface =3D l_dbus_message_get_interface(message);
+	member =3D l_dbus_message_get_member(message);
+
+	if (strcmp(interface, "org.freedesktop.DBus.ObjectManager"))
+		return;
+
+	if (!strcmp(member, "InterfacesAdded"))
+		test_assert(expect_interfaces_added);
+	else if (!strcmp(member, "InterfacesRemoved"))
+		test_assert(!expect_interfaces_added);
+	else
+		return;
+
+	if (!strcmp(member, "InterfacesAdded")) {
+		test_assert(l_dbus_message_get_arguments(message, "oa{sa{sv}}",
+								&path,
+								&interfaces));
+		test_assert(!strcmp(path, "/test2"));
+
+		test_assert(l_dbus_message_iter_next_entry(&interfaces,
+								&interface,
+								&properties));
+		test_assert(!strcmp(interface, "org.test"));
+		validate_properties(&properties);
+
+		test_assert(!l_dbus_message_iter_next_entry(&interfaces,
+								&interface,
+								&properties));
+
+		/* Now repeat the test for the InterfacesRemoved signal */
+
+		expect_interfaces_added =3D false;
+		test_assert(l_dbus_unregister_object(dbus, "/test2"));
+	} else {
+		test_assert(l_dbus_message_get_arguments(message, "oas",
+								&path,
+								&interfaces));
+		test_assert(!strcmp(path, "/test2"));
+
+		test_assert(l_dbus_message_iter_next_entry(&interfaces,
+								&interface));
+		test_assert(!strcmp(interface, "org.test"));
+
+		test_assert(!l_dbus_message_iter_next_entry(&interfaces,
+								&interface));
+
+		l_timeout_remove(om_signal_timeout);
+		om_signal_timeout =3D NULL;
+
+		test_next();
+	}
+}
+
+static void test_object_manager_signals(struct l_dbus *dbus, void *test_da=
ta)
+{
+	om_signal_timeout =3D l_timeout_create(1, om_signal_timeout_callback,
+						NULL, NULL);
+	test_assert(om_signal_timeout);
+
+	expect_interfaces_added =3D true;
+	test_assert(l_dbus_object_add_interface(dbus, "/test2", "org.test",
+						NULL));
+}
+
 static void signal_message(struct l_dbus_message *message, void *user_data)
 {
 	const char *path;
@@ -797,6 +880,9 @@ static void signal_message(struct l_dbus_message *messa=
ge, void *user_data)
 =

 	if (!strcmp(path, "/test"))
 		test_signal_callback(message);
+
+	if (!strcmp(path, "/"))
+		root_signal_callback(message);
 }
 =

 int main(int argc, char *argv[])
@@ -872,6 +958,8 @@ int main(int argc, char *argv[])
 	test_add("Property changed signals", test_property_signals, NULL);
 	test_add("org.freedesktop.DBus.ObjectManager get",
 			test_object_manager_get, NULL);
+	test_add("org.freedesktop.DBus.ObjectManager signals",
+			test_object_manager_signals, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============8905579484559728248==--

