Content-Type: multipart/mixed; boundary="===============1791548018796107776=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 07/10] unit: org.freedesktop.DBus.Properties setter tests
Date: Mon, 15 Feb 2016 17:44:20 +0100
Message-ID: <1455554662-15608-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1791548018796107776==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 119 ++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 119 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index cca3ef8..19a25f5 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -497,6 +497,124 @@ static void test_new_get(struct l_dbus *dbus, void *t=
est_data)
 						NULL, NULL));
 }
 =

+static void new_set_bad_if_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(!setter_called);
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.test",
+							"Invalid", "s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, set_invalid_callback,
+						NULL, NULL));
+}
+
+static void new_set_error_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(setter_called);
+	setter_called =3D false;
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.invalid",
+							"String", "s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_set_bad_if_callback,
+						NULL, NULL));
+}
+
+static void new_set_ro_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(!setter_called);
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.test",
+							"SetError",
+							"s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_set_error_callback,
+						NULL, NULL));
+}
+
+static void new_set_int_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(l_dbus_message_get_arguments(message, ""));
+	test_assert(setter_called);
+	setter_called =3D false;
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.test",
+							"Readonly",
+							"s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_set_ro_callback,
+						NULL, NULL));
+}
+
+static void new_set_string_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(l_dbus_message_get_arguments(message, ""));
+	test_assert(setter_called);
+	setter_called =3D false;
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.test",
+							"Integer", "u", 42));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_set_int_callback,
+						NULL, NULL));
+}
+
+static void test_new_set(struct l_dbus *dbus, void *test_data)
+{
+	struct l_dbus_message *call =3D
+		l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Set");
+
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ssv", "org.test",
+							"String", "s", "bar"));
+
+	test_assert(!setter_called);
+	test_assert(l_dbus_send_with_reply(dbus, call, new_set_string_callback,
+						NULL, NULL));
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
@@ -556,6 +674,7 @@ int main(int argc, char *argv[])
 	test_add("Legacy properties get", test_old_get, NULL);
 	test_add("Legacy properties set", test_old_set, NULL);
 	test_add("org.freedesktop.DBus.Properties get", test_new_get, NULL);
+	test_add("org.freedesktop.DBus.Properties set", test_new_set, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============1791548018796107776==--

