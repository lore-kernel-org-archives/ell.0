Content-Type: multipart/mixed; boundary="===============7385838007551236001=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/9] dbus: Implement org.freedesktop.DBus.Properties
Date: Wed, 10 Feb 2016 11:45:53 +0100
Message-ID: <1455101156-3587-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7385838007551236001==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c | 275 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.c         |   1 -
 2 files changed, 275 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 01a60e3..577bbfb 100644
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
@@ -509,6 +511,8 @@ static bool match_interface_instance(const void *a, con=
st void *b)
 	return false;
 }
 =

+static void properties_setup_func(struct l_dbus_interface *);
+
 struct _dbus_object_tree *_dbus_object_tree_new()
 {
 	struct _dbus_object_tree *tree;
@@ -524,6 +528,10 @@ struct _dbus_object_tree *_dbus_object_tree_new()
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

@@ -718,6 +726,7 @@ bool _dbus_object_tree_object_destroy(struct _dbus_obje=
ct_tree *tree,
 	return true;
 }
 =

+/* Send the signals associated with a property value change */
 void _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
@@ -771,6 +780,43 @@ void _dbus_object_tree_property_changed(struct l_dbus =
*dbus,
 		if (r)
 			l_dbus_send(dbus, signal);
 	}
+
+	if (l_queue_find(object->instances, match_interface_instance,
+				DBUS_INTERFACE_PROPERTIES)) {
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
+
+		if (variant) {
+			memcpy(&value, variant, sizeof(value));
+			r =3D l_dbus_message_builder_append_from_iter(builder,
+								&value);
+		} else {
+			r =3D property->getter(dbus, signal, builder,
+						instance->user_data);
+		}
+
+		l_dbus_message_builder_leave_variant(builder);
+		l_dbus_message_builder_leave_dict(builder);
+		l_dbus_message_builder_leave_array(builder);
+		l_dbus_message_builder_enter_array(builder, "s");
+		l_dbus_message_builder_leave_array(builder);
+
+		l_dbus_message_builder_finalize(builder);
+		l_dbus_message_builder_destroy(builder);
+		if (r)
+			l_dbus_send(dbus, signal);
+	}
 }
 =

 static void set_property_complete(struct l_dbus *dbus,
@@ -1157,3 +1203,232 @@ LIB_EXPORT void l_dbus_property_changed(struct l_db=
us *dbus, const char *path,
 	_dbus_object_tree_property_changed(dbus, path, interface, property,
 						NULL);
 }
+
+static struct l_dbus_message *properties_get(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const struct interface_instance *instance;
+	const char *interface_name, *property_name, *signature;
+	const struct _dbus_property *property;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const struct object_node *object;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+
+	if (!l_dbus_message_get_arguments(message, "ss", &interface_name,
+						&property_name))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
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
+	property =3D _dbus_interface_find_property(instance->interface,
+							property_name);
+	if (!property)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Property %s",
+						property_name);
+
+
+	reply =3D l_dbus_message_new_method_return(message);
+	builder =3D l_dbus_message_builder_new(reply);
+
+	signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+	l_dbus_message_builder_enter_variant(builder, signature);
+
+	if (property->getter(dbus, message, builder, instance->user_data))
+		l_dbus_message_builder_leave_variant(builder);
+	else {
+		l_dbus_message_unref(reply);
+
+		reply =3D l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"Failed",
+						"Getting property value "
+						"failed");
+	}
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
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
+	const struct interface_instance *instance;
+	const char *interface_name, *property_name;
+	const struct _dbus_property *property;
+	struct l_dbus_message_iter variant;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const struct object_node *object;
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
+	const struct interface_instance *instance;
+	const char *interface_name;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const struct object_node *object;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+
+	if (!l_dbus_message_get_arguments(message, "s", &interface_name))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
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
+	reply =3D l_dbus_message_new_method_return(message);
+	builder =3D l_dbus_message_builder_new(reply);
+
+	if (!get_properties_dict(dbus, message, builder, instance->interface,
+					instance->user_data)) {
+		l_dbus_message_unref(reply);
+
+		reply =3D l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"Failed",
+						"Getting property values "
+						"failed");
+	} else
+		l_dbus_message_builder_finalize(builder);
+
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
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
index 796240f..873a8c2 100644
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

-- =

2.5.0


--===============7385838007551236001==--

