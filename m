Content-Type: multipart/mixed; boundary="===============8802664905192758137=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/8] dbus: Handle legacy GetProperties and SetProperty
 automatically.
Date: Mon, 01 Feb 2016 15:07:23 +0100
Message-ID: <1454335644-17088-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454335644-17088-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8802664905192758137==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h      |   6 ++
 ell/dbus-service.c      | 275 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 examples/dbus-service.c |  86 +--------------
 3 files changed, 282 insertions(+), 85 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 558ec50..e8697ce 100644
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
index 0eec91c..93aeb60 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -99,6 +99,7 @@ struct object_node {
 struct _dbus_object_tree {
 	struct l_hashmap *interfaces;
 	struct l_hashmap *objects;
+	struct l_hashmap *property_requests;
 	struct object_node *root;
 };
 =

@@ -522,6 +523,8 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->objects =3D l_hashmap_string_new();
 =

+	tree->property_requests =3D l_hashmap_new();
+
 	tree->root =3D l_new(struct object_node, 1);
 =

 	return tree;
@@ -553,6 +556,7 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 	l_hashmap_destroy(tree->interfaces,
 			(l_hashmap_destroy_func_t) _dbus_interface_free);
 	l_hashmap_destroy(tree->objects, NULL);
+	l_hashmap_destroy(tree->property_requests, NULL);
 =

 	subtree_free(tree->root);
 =

@@ -721,6 +725,252 @@ bool _dbus_object_tree_prune_node(struct _dbus_object=
_tree *tree,
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
+	struct l_dbus_interface *interface;
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
+	struct _dbus_property *property;
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
+struct get_properties_state {
+	struct interface_instance *instance;
+	void (*done)(struct l_dbus *dbus, struct get_properties_state *state,
+			struct l_dbus_message *error);
+	struct l_dbus_message *message, *reply;
+	const struct l_queue_entry *entry;
+	struct l_dbus_message_builder *builder;
+	void *user_data;
+	int count;
+	int busy;
+};
+
+static void get_next_property(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *error)
+{
+	struct get_properties_state *state;
+	struct _dbus_property *property;
+	const char *signature;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	state =3D l_hashmap_lookup(tree->property_requests, message);
+
+	if (error || !state->instance) {
+		state->done(dbus, state, error);
+
+		return;
+	}
+
+	/*
+	 * Loop in the caller as long as the getters complete immediately
+	 * to avoid growing the stack.  The callback will only lower
+	 * state->busy so that the caller knows the getter completed.
+	 */
+	while (!state->busy) {
+		if (state->count) {
+			l_dbus_message_builder_leave_variant(state->builder);
+			l_dbus_message_builder_leave_dict(state->builder);
+		}
+
+		if (!state->entry) {
+			l_dbus_message_builder_leave_array(state->builder);
+
+			state->done(dbus, state, error);
+
+			return;
+		}
+
+		property =3D state->entry->data;
+		signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+		state->entry =3D state->entry->next;
+		state->count +=3D 1;
+
+		l_dbus_message_builder_enter_dict(state->builder, "sv");
+		l_dbus_message_builder_append_basic(state->builder, 's',
+							property->metainfo);
+		l_dbus_message_builder_enter_variant(state->builder,
+							signature);
+
+		state->busy++;
+		property->getter(dbus, state->message, state->builder,
+					get_next_property, state->user_data);
+	}
+
+	state->busy--;
+}
+
+static void get_properties_dict(struct l_dbus *dbus,
+				struct get_properties_state *state)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	l_hashmap_insert(tree->property_requests, state->message, state);
+
+	l_dbus_message_builder_enter_array(state->builder, "{sv}");
+
+	get_next_property(dbus, state->message, NULL);
+}
+
+static void get_properties_done(struct l_dbus *dbus,
+					struct get_properties_state *state,
+					struct l_dbus_message *error)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	if (error) {
+		l_dbus_message_unref(state->reply);
+
+		l_dbus_send(dbus, error);
+	} else {
+		l_dbus_message_builder_finalize(state->builder);
+
+		l_dbus_send(dbus, state->reply);
+	}
+
+	l_hashmap_remove(tree->property_requests, state->message);
+	l_dbus_message_unref(state->message);
+	l_dbus_message_builder_destroy(state->builder);
+	l_free(state);
+}
+
+static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	struct get_properties_state *state;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct object_node *object;
+
+	interface =3D l_hashmap_lookup(tree->interfaces,
+					l_dbus_message_get_interface(message));
+	/* If we got here the interface must exist */
+
+	object =3D l_hashmap_lookup(tree->objects,
+					l_dbus_message_get_path(message));
+
+	state =3D l_new(struct get_properties_state, 1);
+
+	state->instance =3D l_queue_find(object->instances,
+			match_interface_instance,
+			(char *) l_dbus_message_get_interface(message));
+	state->done =3D get_properties_done;
+	state->message =3D l_dbus_message_ref(message);
+	state->reply =3D l_dbus_message_new_method_return(message);
+	state->entry =3D l_queue_get_entries(interface->properties);
+	state->builder =3D l_dbus_message_builder_new(state->reply);
+	state->user_data =3D user_data;
+
+	get_properties_dict(dbus, state);
+
+	return NULL;
+}
+
 bool _dbus_object_tree_register_interface(struct _dbus_object_tree *tree,
 				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
@@ -744,6 +994,19 @@ bool _dbus_object_tree_register_interface(struct _dbus=
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
@@ -829,6 +1092,15 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 	return true;
 }
 =

+static void mark_instance_removed(const void *key, void *value, void *user=
_data)
+{
+	struct get_properties_state *state =3D value;
+	struct interface_instance *instance =3D user_data;
+
+	if (state->instance =3D=3D instance)
+		state->instance =3D NULL;
+}
+
 bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 					const char *path,
 					const char *interface)
@@ -847,6 +1119,9 @@ bool _dbus_object_tree_remove_interface(struct _dbus_o=
bject_tree *tree,
 =

 	interface_instance_free(instance);
 =

+	l_hashmap_foreach(tree->property_requests,
+				mark_instance_removed, instance);
+
 	return true;
 }
 =

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 488cc47..2158bec 100644
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
@@ -260,18 +185,9 @@ static void test_int_setter(struct l_dbus *dbus,
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
@@ -308,7 +224,7 @@ int main(int argc, char *argv[])
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


--===============8802664905192758137==--

