Content-Type: multipart/mixed; boundary="===============1596907229440538896=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/8] dbus: Handle legacy GetProperties and SetProperty
 automatically.
Date: Fri, 05 Feb 2016 03:58:32 +0100
Message-ID: <1454641114-3421-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1596907229440538896==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h      |   6 ++
 ell/dbus-service.c      | 190 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 examples/dbus-service.c |  86 +---------------------
 3 files changed, 197 insertions(+), 85 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 8c58218..1af7201 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -197,6 +197,12 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tr=
ee *tree,
 					struct l_dbus *dbus,
 					struct l_dbus_message *message);
 =

+void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+					const char *path,
+					const char *interface_name,
+					const char *property_name,
+					struct l_dbus_message_iter *variant);
+
 void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
 				const char *prefix, const char *str);
 void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 2ec2df9..c9e465c 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -711,6 +711,183 @@ bool _dbus_object_tree_object_destroy(struct _dbus_ob=
ject_tree *tree,
 	return true;
 }
 =

+void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+					const char *path,
+					const char *interface_name,
+					const char *property_name,
+					struct l_dbus_message_iter *variant)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	char signature[256];
+	const struct l_dbus_interface *interface;
+	struct l_dbus_message_iter value;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	memcpy(signature, variant->sig_start, variant->sig_len);
+	signature[variant->sig_len] =3D '\0';
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+
+	if (interface->handle_old_style_properties) {
+		memcpy(&value, variant, sizeof(value));
+
+		signal =3D l_dbus_message_new_signal(dbus, path,
+							interface_name,
+							"PropertyChanged");
+
+		builder =3D l_dbus_message_builder_new(signal);
+
+		l_dbus_message_builder_append_basic(builder, 's',
+							property_name);
+		l_dbus_message_builder_enter_variant(builder, signature);
+		l_dbus_message_builder_append_from_iter(builder, &value);
+		l_dbus_message_builder_leave_variant(builder);
+
+		l_dbus_message_builder_finalize(builder);
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_send(dbus, signal);
+	}
+}
+
+static void set_property_complete(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *error)
+{
+	struct l_dbus_message *reply;
+	const char *property_name;
+	struct l_dbus_message_iter variant;
+
+	if (error) {
+		l_dbus_message_unref(message);
+
+		l_dbus_send(dbus, error);
+
+		return;
+	}
+
+	reply =3D l_dbus_message_new_method_return(message);
+	l_dbus_message_set_arguments(reply, "");
+	l_dbus_send(dbus, reply);
+
+	l_dbus_message_get_arguments(message, "sv", &property_name, &variant);
+
+	_dbus_object_tree_property_changed(dbus,
+					l_dbus_message_get_path(message),
+					l_dbus_message_get_interface(message),
+					property_name, &variant);
+
+	l_dbus_message_unref(message);
+}
+
+static struct l_dbus_message *old_set_property(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	const char *property_name;
+	const struct _dbus_property *property;
+	struct l_dbus_message_iter variant;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	interface =3D l_hashmap_lookup(tree->interfaces,
+					l_dbus_message_get_interface(message));
+	/* If we got here the interface must exist */
+
+	if (!l_dbus_message_get_arguments(message, "sv", &property_name,
+						&variant))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
+
+	property =3D _dbus_interface_find_property(interface, property_name);
+	if (!property)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Property %s",
+						property_name);
+
+	if (!property->setter)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Property %s is read-only",
+						property_name);
+
+	property->setter(dbus, l_dbus_message_ref(message), &variant,
+				set_property_complete, user_data);
+
+	return NULL;
+}
+
+static bool get_properties_dict(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				const struct l_dbus_interface *interface,
+				void *user_data)
+{
+	const struct l_queue_entry *entry;
+	const struct _dbus_property *property;
+	const char *signature;
+	bool r =3D true;
+
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	for (entry =3D l_queue_get_entries(interface->properties); entry && r;
+			entry =3D entry->next) {
+		property =3D entry->data;
+		signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+		l_dbus_message_builder_enter_dict(builder, "sv");
+		l_dbus_message_builder_append_basic(builder, 's',
+							property->metainfo);
+		l_dbus_message_builder_enter_variant(builder, signature);
+
+		r =3D property->getter(dbus, message, builder, user_data);
+
+		l_dbus_message_builder_leave_variant(builder);
+		l_dbus_message_builder_leave_dict(builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+
+	return true;
+}
+
+static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const struct l_dbus_interface *interface;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	interface =3D l_hashmap_lookup(tree->interfaces,
+					l_dbus_message_get_interface(message));
+	/* If we got here the interface must exist */
+
+	reply =3D l_dbus_message_new_method_return(message);
+	builder =3D l_dbus_message_builder_new(reply);
+
+	if (!get_properties_dict(dbus, message, builder, interface,
+					user_data)) {
+		l_dbus_message_unref(reply);
+
+		reply =3D l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"Failed",
+						"Getting properties failed");
+	}
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
+}
+
 bool _dbus_object_tree_register_interface(struct _dbus_object_tree *tree,
 				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
@@ -734,6 +911,19 @@ bool _dbus_object_tree_register_interface(struct _dbus=
_object_tree *tree,
 	dbi->instance_destroy =3D destroy;
 	dbi->handle_old_style_properties =3D old_style_properties;
 =

+	/* Add our methods first so we don't have to check for conflicts. */
+	if (old_style_properties) {
+		l_dbus_interface_method(dbi, "SetProperty", 0,
+					old_set_property, "", "sv",
+					"name", "value");
+		l_dbus_interface_method(dbi, "GetProperties", 0,
+					old_get_properties, "a{sv}", "",
+					"properties");
+
+		l_dbus_interface_signal(dbi, "PropertyChanged", 0, "sv",
+					"name", "value");
+	}
+
 	setup_func(dbi);
 =

 	l_hashmap_insert(tree->interfaces, dbi->name, dbi);
diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 5b8b086..8abeba4 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -98,81 +98,6 @@ static void test_data_destroy(void *data)
 	l_free(test);
 }
 =

-static struct l_dbus_message *test_set_property(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
-{
-	struct test_data *test =3D user_data;
-	struct l_dbus_message *reply;
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
-
-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "");
-	l_dbus_send(dbus, reply);
-
-	l_dbus_send(dbus, signal);
-	return NULL;
-}
-
-static struct l_dbus_message *test_get_properties(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
-{
-	struct test_data *test =3D user_data;
-	struct l_dbus_message *reply;
-
-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "a{sv}", 2,
-					"String", "s", test->string,
-					"Integer", "u", test->integer);
-
-	return reply;
-}
-
 static struct l_dbus_message *test_method_call(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
@@ -258,18 +183,9 @@ static void test_int_setter(struct l_dbus *dbus,
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
 	l_dbus_interface_property(interface, "String", 0, "s",
 					test_string_getter, test_string_setter);
 	l_dbus_interface_property(interface, "Integer", 0, "u",
@@ -306,7 +222,7 @@ int main(int argc, char *argv[])
 	test->integer =3D 42;
 =

 	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
-					test_data_destroy, false)) {
+					test_data_destroy, true)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
 		goto cleanup;
-- =

2.5.0


--===============1596907229440538896==--

