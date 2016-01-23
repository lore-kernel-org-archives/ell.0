Content-Type: multipart/mixed; boundary="===============0180820666782264499=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [RFC PATCH 7/8] dbus: Implement org.freedesktop.DBus.Properties
Date: Sat, 23 Jan 2016 03:59:31 +0100
Message-ID: <1453517972-22833-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1453517972-22833-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0180820666782264499==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c      | 302 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.c              |   1 -
 examples/dbus-service.c |   7 ++
 3 files changed, 309 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 2db6cbe..4802b21 100644
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
@@ -511,6 +513,8 @@ static bool match_interface_instance(const void *a, con=
st void *b)
 	return false;
 }
 =

+static void properties_setup_func(struct l_dbus_interface *);
+
 struct _dbus_object_tree *_dbus_object_tree_new()
 {
 	struct _dbus_object_tree *tree;
@@ -528,6 +532,9 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->root =3D l_new(struct object_node, 1);
 =

+	_dbus_object_tree_register(tree, DBUS_INTERFACE_PROPERTIES,
+					properties_setup_func, NULL, false);
+
 	return tree;
 }
 =

@@ -1163,3 +1170,298 @@ bool _dbus_object_tree_dispatch(struct _dbus_object=
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
+	if (error) {
+		l_dbus_message_unref(state->reply);
+
+		l_dbus_send(dbus, error);
+
+		goto done;
+	}
+
+	l_dbus_message_builder_leave_variant(state->builder);
+	l_dbus_message_builder_finalize(state->builder);
+
+	l_dbus_send(dbus, state->reply);
+
+done:
+	l_hashmap_remove(tree->property_requests, state->message);
+	l_dbus_message_unref(state->message);
+	l_dbus_message_builder_destroy(state->builder);
+	l_free(state);
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
+	struct l_dbus_message *signal;
+	const char *interface_name, *property_name;
+	char signature[256];
+	struct l_dbus_message_iter variant;
+	struct l_dbus_message_builder *builder;
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
+	memcpy(signature, variant.sig_start, variant.sig_len);
+	signature[variant.sig_len] =3D '\0';
+
+	signal =3D l_dbus_message_new_signal(dbus,
+					l_dbus_message_get_path(message),
+					DBUS_INTERFACE_PROPERTIES,
+					"PropertiesChanged");
+
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 's', interface_name);
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+	l_dbus_message_builder_enter_dict(builder, "sv");
+	l_dbus_message_builder_append_basic(builder, 's', property_name);
+	l_dbus_message_builder_enter_variant(builder, signature);
+	l_dbus_message_builder_append_from_iter(builder, &variant);
+	l_dbus_message_builder_leave_variant(builder);
+	l_dbus_message_builder_leave_dict(builder);
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_enter_array(builder, "s");
+	l_dbus_message_builder_leave_array(builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+	l_dbus_send(dbus, signal);
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
+	const char *interface_name, *property_name, *signature;
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
+	signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+	if (l_dbus_message_iter_get_type(&variant) !=3D signature[0])
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Expected type '%s'",
+						signature);
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
+	state->message =3D l_dbus_message_ref(message);
+	state->reply =3D l_dbus_message_new_method_return(message);
+	state->entry =3D l_queue_get_entries(interface->properties);
+	state->builder =3D l_dbus_message_builder_new(state->reply);
+	state->user_data =3D instance->user_data;
+
+	l_hashmap_insert(tree->property_requests, message, state);
+
+	l_dbus_message_builder_enter_array(state->builder, "{sv}");
+
+	get_next_property(dbus, message, NULL);
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
index 50a8cd3..2089750 100644
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


--===============0180820666782264499==--

