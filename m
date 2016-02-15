Content-Type: multipart/mixed; boundary="===============6146975160990532592=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/10] unit: org.freedesktop.DBus.Properties getter tests
Date: Mon, 15 Feb 2016 17:44:19 +0100
Message-ID: <1455554662-15608-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6146975160990532592==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 73 +++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 73 insertions(+)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index d61a6b9..cca3ef8 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -425,6 +425,78 @@ static void test_old_set(struct l_dbus *dbus, void *te=
st_data)
 						NULL, NULL));
 }
 =

+static void new_get_invalid_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"GetAll");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "s", "org.test"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, get_properties_callback,
+						NULL, NULL));
+}
+
+static void new_get_bad_if_callback(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus_message *call;
+
+	test_assert(l_dbus_message_get_error(message, NULL, NULL));
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Get");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ss",
+							"org.test", "Invalid"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_get_invalid_callback,
+						NULL, NULL));
+}
+
+static void new_get_callback(struct l_dbus_message *message, void *user_da=
ta)
+{
+	struct l_dbus_message_iter variant;
+	const char *strval;
+	struct l_dbus_message *call;
+
+	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
+	test_assert(l_dbus_message_get_arguments(message, "v", &variant));
+	test_assert(l_dbus_message_iter_get_variant(&variant, "s", &strval));
+	test_assert(!strcmp(strval, "foo"));
+
+	call =3D l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Get");
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ss", "org.invalid",
+							"String"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_get_bad_if_callback,
+						NULL, NULL));
+}
+
+static void test_new_get(struct l_dbus *dbus, void *test_data)
+{
+	struct l_dbus_message *call =3D
+		l_dbus_message_new_method_call(dbus, "org.test", "/test",
+					"org.freedesktop.DBus.Properties",
+					"Get");
+
+	test_assert(call);
+	test_assert(l_dbus_message_set_arguments(call, "ss",
+							"org.test", "String"));
+
+	test_assert(l_dbus_send_with_reply(dbus, call, new_get_callback,
+						NULL, NULL));
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_signal *signal;
@@ -483,6 +555,7 @@ int main(int argc, char *argv[])
 =

 	test_add("Legacy properties get", test_old_get, NULL);
 	test_add("Legacy properties set", test_old_set, NULL);
+	test_add("org.freedesktop.DBus.Properties get", test_new_get, NULL);
 =

 	l_main_run();
 =

-- =

2.5.0


--===============6146975160990532592==--

