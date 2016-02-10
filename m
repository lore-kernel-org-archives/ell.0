Content-Type: multipart/mixed; boundary="===============1562695284733491954=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/9] examples: update dbus-service to new API
Date: Wed, 10 Feb 2016 11:45:55 +0100
Message-ID: <1455101156-3587-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1562695284733491954==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dbus-service.c | 168 +++++++++++++++++++++++++-------------------=
----
 1 file changed, 86 insertions(+), 82 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 40c1646..964d735 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -98,111 +98,98 @@ static void test_data_destroy(void *data)
 	l_free(test);
 }
 =

-static struct l_dbus_message *test_set_property(struct l_dbus *dbus,
+static struct l_dbus_message *test_method_call(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
 {
-	struct test_data *test =3D user_data;
 	struct l_dbus_message *reply;
-	struct l_dbus_message *signal;
-	struct l_dbus_message_iter variant;
-	const char *property;
-
-	if (!l_dbus_message_get_arguments(message, "sv", &property, &variant))
-		return l_dbus_message_new_error(message,
-						"org.test.InvalidArguments",
-						"Invalid arguments");
-
-	if (!strcmp(property, "String")) {
-		const char *strvalue;
-
-		if (!l_dbus_message_iter_get_variant(&variant, "s",
-							&strvalue))
-			return l_dbus_message_new_error(message,
-						"org.test.InvalidArguments",
-						"String value expected");
-
-		l_info("New String value: %s", strvalue);
-		l_free(test->string);
-		test->string =3D l_strdup(strvalue);
-
-		signal =3D l_dbus_message_new_signal(dbus, "/test",
-					"org.test", "PropertyChanged");
-		l_dbus_message_set_arguments(signal, "sv",
-						"String", "s", test->string);
-	} else if (!strcmp(property, "Integer")) {
-		uint32_t u;
-
-		if (!l_dbus_message_iter_get_variant(&variant, "u", &u))
-			return l_dbus_message_new_error(message,
-						"org.test.InvalidArguments",
-						"Integer value expected");
-
-		l_info("New Integer value: %u", u);
-		test->integer =3D u;
-		signal =3D l_dbus_message_new_signal(dbus, "/test",
-					"org.test", "PropertyChanged");
-		l_dbus_message_set_arguments(signal, "sv",
-						"Integer", "u", test->integer);
-	} else
-		return l_dbus_message_new_error(message,
-						"org.test.InvalidArguments",
-						"Unknown Property %s",
-						property);
+
+	l_info("Method Call");
 =

 	reply =3D l_dbus_message_new_method_return(message);
 	l_dbus_message_set_arguments(reply, "");
-	l_dbus_send(dbus, reply);
 =

-	l_dbus_send(dbus, signal);
-	return NULL;
+	return reply;
 }
 =

-static struct l_dbus_message *test_get_properties(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
+static bool test_string_getter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
 {
 	struct test_data *test =3D user_data;
-	struct l_dbus_message *reply;
 =

-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "a{sv}", 2,
-					"String", "s", test->string,
-					"Integer", "u", test->integer);
+	l_dbus_message_builder_append_basic(builder, 's', test->string);
 =

-	return reply;
+	return true;
 }
 =

-static struct l_dbus_message *test_method_call(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
+static void test_string_setter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_iter *new_value,
+				l_dbus_property_complete_cb_t complete,
+				void *user_data)
 {
-	struct l_dbus_message *reply;
+	const char *strvalue;
+	struct test_data *test =3D user_data;
 =

-	l_info("Method Call");
+	if (!l_dbus_message_iter_get_variant(new_value, "s", &strvalue)) {
+		complete(dbus, message, l_dbus_message_new_error(message,
+					"org.test.InvalidArguments",
+					"String value expected"));
+		return;
+	}
 =

-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "");
+	l_info("New String value: %s", strvalue);
+	l_free(test->string);
+	test->string =3D l_strdup(strvalue);
 =

-	return reply;
+	complete(dbus, message, NULL);
+}
+
+static bool test_int_getter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	struct test_data *test =3D user_data;
+
+	l_dbus_message_builder_append_basic(builder, 'u', &test->integer);
+
+	return true;
+}
+
+static void test_int_setter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_iter *new_value,
+				l_dbus_property_complete_cb_t complete,
+				void *user_data)
+{
+	uint32_t u;
+	struct test_data *test =3D user_data;
+
+	if (!l_dbus_message_iter_get_variant(new_value, "u", &u)) {
+		complete(dbus, message, l_dbus_message_new_error(message,
+					"org.test.InvalidArguments",
+					"Integer value expected"));
+		return;
+	}
+
+	l_info("New Integer value: %u", u);
+	test->integer =3D u;
+
+	complete(dbus, message, NULL);
 }
 =

 static void setup_test_interface(struct l_dbus_interface *interface)
 {
-	l_dbus_interface_method(interface, "GetProperties", 0,
-				test_get_properties,
-				"a{sv}", "", "properties");
-	l_dbus_interface_method(interface, "SetProperty", 0,
-				test_set_property,
-				"", "sv", "name", "value");
 	l_dbus_interface_method(interface, "MethodCall", 0,
 				test_method_call, "", "");
 =

-	l_dbus_interface_signal(interface, "PropertyChanged", 0,
-				"sv", "name", "value");
-
-	l_dbus_interface_rw_property(interface, "String", "s");
-	l_dbus_interface_rw_property(interface, "Integer", "u");
+	l_dbus_interface_property(interface, "String", 0, "s",
+					test_string_getter, test_string_setter);
+	l_dbus_interface_property(interface, "Integer", 0, "u",
+					test_int_getter, test_int_setter);
 }
 =

 int main(int argc, char *argv[])
@@ -230,21 +217,38 @@ int main(int argc, char *argv[])
 				request_name_setup,
 				request_name_callback, NULL, NULL);
 =

+	if (!l_dbus_object_manager_enable(dbus)) {
+		l_info("Unable to enable Object Manager");
+		goto cleanup;
+	}
+
 	test =3D l_new(struct test_data, 1);
 	test->string =3D l_strdup("Default");
 	test->integer =3D 42;
 =

-	if (!l_dbus_register_interface(dbus, "/test", "org.test",
-					setup_test_interface, test,
-					test_data_destroy)) {
+	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
+					test_data_destroy, true)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
 		goto cleanup;
 	}
 =

+	if (!l_dbus_object_add_interface(dbus, "/test", "org.test", test)) {
+		l_info("Unable to instantiate interface");
+		test_data_destroy(test);
+		goto cleanup;
+	}
+
+	if (!l_dbus_object_add_interface(dbus, "/test",
+				"org.freedesktop.DBus.Properties", NULL)) {
+		l_info("Unable to instantiate the properties interface");
+		test_data_destroy(test);
+		goto cleanup;
+	}
+
 	l_main_run();
 =

-	l_dbus_unregister_interface(dbus, "/test", "org.test");
+	l_dbus_unregister_object(dbus, "/test");
 =

 cleanup:
 	l_dbus_destroy(dbus);
-- =

2.5.0


--===============1562695284733491954==--

