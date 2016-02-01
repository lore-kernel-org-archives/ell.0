Content-Type: multipart/mixed; boundary="===============6267910378426382364=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/8] dbus: Implement org.freedesktop.DBus.Properties
Date: Mon, 01 Feb 2016 15:07:24 +0100
Message-ID: <1454335644-17088-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454335644-17088-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6267910378426382364==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c      | 287 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.c              |   1 -
 examples/dbus-service.c |   7 ++
 3 files changed, 294 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 93aeb60..962bbaf 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -47,6 +47,8 @@ static const char *static_introspectable =3D
 		"\t\t\t<arg name=3D\"xml\" type=3D\"s\" direction=3D\"out\"/>\n"
 		"\t\t</method>\n\t</interface>\n";
 =

+#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
+
 struct _dbus_method {
 	l_dbus_interface_method_cb_t cb;
 	uint32_t flags;
@@ -510,6 +512,8 @@ static bool match_interface_instance(const void *a, con=
st void *b)
 	return false;
 }
 =

+static void properties_setup_func(struct l_dbus_interface *);
+
 struct _dbus_object_tree *_dbus_object_tree_new()
 {
 	struct _dbus_object_tree *tree;
@@ -527,6 +531,10 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->root =3D l_new(struct object_node, 1);
 =

+	_dbus_object_tree_register_interface(tree, DBUS_INTERFACE_PROPERTIES,
+						properties_setup_func, NULL,
+						false);
+
 	return tree;
 }
 =

@@ -725,6 +733,7 @@ bool _dbus_object_tree_prune_node(struct _dbus_object_t=
ree *tree,
 	return true;
 }
 =

+/* Send the signals associated with a property value change */
 void _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
@@ -735,6 +744,7 @@ void _dbus_object_tree_property_changed(struct l_dbus *=
dbus,
 	struct l_dbus_message_builder *builder;
 	char signature[256];
 	struct l_dbus_interface *interface;
+	struct object_node *object;
 	struct l_dbus_message_iter value;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 =

@@ -762,6 +772,37 @@ void _dbus_object_tree_property_changed(struct l_dbus =
*dbus,
 		l_dbus_message_builder_destroy(builder);
 		l_dbus_send(dbus, signal);
 	}
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+
+	if (l_queue_find(object->instances, match_interface_instance,
+				DBUS_INTERFACE_PROPERTIES)) {
+		memcpy(&value, variant, sizeof(value));
+
+		signal =3D l_dbus_message_new_signal(dbus, path,
+						DBUS_INTERFACE_PROPERTIES,
+						"PropertiesChanged");
+
+		builder =3D l_dbus_message_builder_new(signal);
+
+		l_dbus_message_builder_append_basic(builder, 's',
+							interface_name);
+		l_dbus_message_builder_enter_array(builder, "{sv}");
+		l_dbus_message_builder_enter_dict(builder, "sv");
+		l_dbus_message_builder_append_basic(builder, 's',
+							property_name);
+		l_dbus_message_builder_enter_variant(builder, signature);
+		l_dbus_message_builder_append_from_iter(builder, &value);
+		l_dbus_message_builder_leave_variant(builder);
+		l_dbus_message_builder_leave_dict(builder);
+		l_dbus_message_builder_leave_array(builder);
+		l_dbus_message_builder_enter_array(builder, "s");
+		l_dbus_message_builder_leave_array(builder);
+
+		l_dbus_message_builder_finalize(builder);
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_send(dbus, signal);
+	}
 }
 =

 static void set_property_complete(struct l_dbus *dbus,
@@ -1224,3 +1265,249 @@ bool _dbus_object_tree_dispatch(struct _dbus_object=
_tree *tree,
 =

 	return true;
 }
+
+static void properties_get_complete(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *error)
+{
+	struct get_properties_state *state;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	state =3D l_hashmap_lookup(tree->property_requests, message);
+
+	l_dbus_message_builder_leave_variant(state->builder);
+
+	get_properties_done(dbus, state, error);
+}
+
+static struct l_dbus_message *properties_get(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	struct interface_instance *instance;
+	const char *interface_name, *property_name, *signature;
+	struct _dbus_property *property;
+	struct get_properties_state *state;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct object_node *object;
+
+	if (!l_dbus_message_get_arguments(message, "ss", &interface_name,
+						&property_name))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+	if (!interface)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Interface %s",
+						interface_name);
+
+	property =3D _dbus_interface_find_property(interface, property_name);
+	if (!property)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Property %s",
+						property_name);
+
+	object =3D l_hashmap_lookup(tree->objects,
+					l_dbus_message_get_path(message));
+	/* If we got here the object must exist */
+
+	instance =3D l_queue_find(object->instances,
+				match_interface_instance,
+				(char *) interface_name);
+	if (!instance)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Object has no interface %s",
+						interface_name);
+
+	state =3D l_new(struct get_properties_state, 1);
+
+	state->message =3D l_dbus_message_ref(message);
+	state->reply =3D l_dbus_message_new_method_return(message);
+	state->builder =3D l_dbus_message_builder_new(state->reply);
+
+	l_hashmap_insert(tree->property_requests, message, state);
+
+	signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+	l_dbus_message_builder_enter_variant(state->builder,
+						signature);
+
+	property->getter(dbus, state->message, state->builder,
+				properties_get_complete, instance->user_data);
+
+	return NULL;
+}
+
+static void properties_set_complete(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *error)
+{
+	struct l_dbus_message *reply;
+	const char *interface_name, *property_name;
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
+	l_dbus_message_get_arguments(message, "ssv", &interface_name,
+					&property_name, &variant);
+
+	_dbus_object_tree_property_changed(dbus,
+					l_dbus_message_get_path(message),
+					interface_name, property_name,
+					&variant);
+
+	l_dbus_message_unref(message);
+}
+
+static struct l_dbus_message *properties_set(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	struct interface_instance *instance;
+	const char *interface_name, *property_name;
+	struct _dbus_property *property;
+	struct l_dbus_message_iter variant;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct object_node *object;
+
+	if (!l_dbus_message_get_arguments(message, "ssv", &interface_name,
+						&property_name, &variant))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+	if (!interface)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Interface %s",
+						interface_name);
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
+	object =3D l_hashmap_lookup(tree->objects,
+					l_dbus_message_get_path(message));
+	/* If we got here the object must exist */
+
+	instance =3D l_queue_find(object->instances,
+				match_interface_instance,
+				(char *) interface_name);
+	if (!instance)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Object has no interface %s",
+						interface_name);
+
+	property->setter(dbus, l_dbus_message_ref(message), &variant,
+				properties_set_complete, instance->user_data);
+
+	return NULL;
+}
+
+static struct l_dbus_message *properties_get_all(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	struct interface_instance *instance;
+	const char *interface_name;
+	struct get_properties_state *state;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct object_node *object;
+
+	if (!l_dbus_message_get_arguments(message, "s", &interface_name))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+	if (!interface)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Interface %s",
+						interface_name);
+
+	object =3D l_hashmap_lookup(tree->objects,
+					l_dbus_message_get_path(message));
+	/* If we got here the object must exist */
+
+	instance =3D l_queue_find(object->instances,
+				match_interface_instance,
+				(char *) interface_name);
+	if (!instance)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Object has no interface %s",
+						interface_name);
+
+	state =3D l_new(struct get_properties_state, 1);
+
+	state->instance =3D instance;
+	state->done =3D get_properties_done;
+	state->message =3D l_dbus_message_ref(message);
+	state->reply =3D l_dbus_message_new_method_return(message);
+	state->entry =3D l_queue_get_entries(interface->properties);
+	state->builder =3D l_dbus_message_builder_new(state->reply);
+	state->user_data =3D instance->user_data;
+
+	get_properties_dict(dbus, state);
+
+	return NULL;
+}
+
+static void properties_setup_func(struct l_dbus_interface *interface)
+{
+	l_dbus_interface_method(interface, "Get", 0,
+				properties_get, "v", "ss",
+				"value", "interface_name", "property_name");
+	l_dbus_interface_method(interface, "Set", 0,
+				properties_set, "", "ssv",
+				"interface_name", "property_name", "value");
+	l_dbus_interface_method(interface, "GetAll", 0,
+				properties_get_all, "a{sv}", "s",
+				"props", "interface_name");
+
+	l_dbus_interface_signal(interface, "PropertiesChanged", 0, "sa{sv}as",
+				"interface_name", "changed_properties",
+				"invalidated_properties");
+}
diff --git a/ell/dbus.c b/ell/dbus.c
index 70c6f32..6a55d42 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -51,7 +51,6 @@
 =

 #define DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
 #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
-#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
 =

 #define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
 =

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 2158bec..6a838cc 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -236,6 +236,13 @@ int main(int argc, char *argv[])
 		goto cleanup;
 	}
 =

+	if (!l_dbus_object_add_interface(dbus, "/test",
+				"org.freedesktop.DBus.Properties", NULL)) {
+		l_info("Unable to instantiate the properties interface");
+		test_data_destroy(test);
+		goto cleanup;
+	}
+
 	l_main_run();
 =

 	l_dbus_unregister_object(dbus, "/test");
-- =

2.5.0


--===============6267910378426382364==--

