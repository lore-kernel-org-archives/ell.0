Content-Type: multipart/mixed; boundary="===============2820876875031841886=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/10] unit: DBus old-style property setter tests
Date: Mon, 15 Feb 2016 17:44:18 +0100
Message-ID: <1455554662-15608-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2820876875031841886==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 102 ++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 102 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index ff9ecbf..d61a6b9 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -324,6 +324,107 @@ static void test_old_get(struct l_dbus *dbus, void *t=
est_data)
 						NULL, NULL));
 }
 =

+static void set_invalid_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(!setter_called);
+
+	test_next();
+}
+
+static void old_set_error_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(setter_called);
+	setter_called =3D false;
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+						"org.test", "SetProperty");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "sv", "Invalid",
+							"s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, set_invalid_callback,
+						NULL, NULL));
+}
+
+static void old_set_ro_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(!setter_called);
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+						"org.test", "SetProperty");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "sv", "SetError",
+							"s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, old_set_error_callback,
+						NULL, NULL));
+}
+
+static void old_set_int_callback(struct l_dbus_message *message,
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
+						"org.test", "SetProperty");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "sv", "Readonly",
+							"s", "bar"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, old_set_ro_callback,
+						NULL, NULL));
+}
+
+static void old_set_string_callback(struct l_dbus_message *message,
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
+						"org.test", "SetProperty");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "sv", "Integer",
+							"u", 42));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, old_set_int_callback,
+						NULL, NULL));
+}
+
+static void test_old_set(struct l_dbus *dbus, void *test_data)
+{
+	struct l_dbus_message *call =3D
+		l_dbus_message_new_method_call(dbus, "org.test", "/test",
+						"org.test", "SetProperty");
+
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "sv", "String",
+							"s", "bar"));
+
+	test_assert(!setter_called);
+	test_assert(l_dbus_send_with_reply(dbus, call, old_set_string_callback,
+						NULL, NULL));
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
@@ -381,6 +482,7 @@ int main(int argc, char *argv[])
 	}
 =

 	test_add("Legacy properties get", test_old_get, NULL);
+	test_add("Legacy properties set", test_old_set, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============2820876875031841886==--

