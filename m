Content-Type: multipart/mixed; boundary="===============1009688482857593934=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 13/21] dbus: Add support for
 org.freedesktop.DBus.Properties.Get method
Date: Thu, 13 Nov 2014 12:36:17 +0200
Message-ID: <1415874985-13034-14-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1009688482857593934==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

First part of the org.freedesktop.DBus.Properties standard interface
support.
---
 ell/dbus-private.h |   5 +++
 ell/dbus-service.c | 117 ++++++++++++++++++++++++++++++++++++++++++++++++-=
----
 ell/dbus-service.h |  20 ++++++---
 ell/dbus.c         |   1 -
 4 files changed, 126 insertions(+), 17 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 6ead02d..0694a12 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -36,6 +36,8 @@ enum dbus_container_type {
 	DBUS_CONTAINER_TYPE_DICT_ENTRY	=3D 'e',
 };
 =

+#define DBUS_ERROR_INVALID_ARGS "org.freedesktop.DBus.Error.InvalidArgs"
+
 #if __BYTE_ORDER =3D=3D __LITTLE_ENDIAN
 #define DBUS_NATIVE_ENDIAN 'l'
 #elif __BYTE_ORDER =3D=3D __BIG_ENDIAN
@@ -178,6 +180,9 @@ struct object_node *_dbus_object_tree_makepath(struct _=
dbus_object_tree *tree,
 struct object_node *_dbus_object_tree_lookup(struct _dbus_object_tree *tre=
e,
 						const char *path);
 void _dbus_object_tree_prune_node(struct object_node *node);
+struct interface_instance *_dbus_object_find_instance(
+						struct object_node *object,
+						const char *interface);
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 8dc394a..c745972 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -37,6 +37,8 @@
 #include "dbus-private.h"
 #include "private.h"
 =

+#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
+
 #define XML_ID "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
 #define XML_DTD "http://www.freedesktop.org/standards/dbus/1.0/introspect.=
dtd"
 #define XML_HEAD "<!DOCTYPE node PUBLIC \""XML_ID"\"\n\""XML_DTD"\">\n"
@@ -437,6 +439,95 @@ void _dbus_object_tree_prune_node(struct object_node *=
node)
 	}
 }
 =

+struct interface_instance *_dbus_object_find_instance(
+						struct object_node *object,
+						const char *interface)
+{
+	const struct l_queue_entry *entry;
+
+	entry =3D l_queue_get_entries(object->instances);
+	while (entry) {
+		struct interface_instance *instance =3D entry->data;
+
+		if (!strcmp(instance->interface->name, interface))
+			return instance;
+
+		entry =3D entry->next;
+	}
+
+	return NULL;
+}
+
+static struct l_dbus_message *properties_get(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const char *interface;
+	const char *name;
+	const char *path;
+	struct _dbus_object_tree *tree;
+	struct object_node *object;
+	struct interface_instance *instance;
+	const struct l_dbus_property *property;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+
+	if (!l_dbus_message_get_arguments(message, "ss", &interface, &name))
+		return NULL;
+
+	path =3D l_dbus_message_get_path(message);
+	tree =3D _dbus_object_tree_get_from_dbus(dbus);
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return l_dbus_message_new_error(message,
+						DBUS_ERROR_INVALID_ARGS,
+						"No such object '%s'", path);
+
+	instance =3D _dbus_object_find_instance(object, interface);
+	if (!instance)
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_ARGS,
+					"No such interface '%s'", interface);
+
+	property =3D _dbus_interface_find_property(instance->interface, name);
+	if (!property)
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_ARGS,
+					"No such property '%s'", name);
+	if (property->get =3D=3D NULL)
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_ARGS,
+					"Property '%s' is not readable", name);
+
+	reply =3D l_dbus_message_new_method_return(message);
+	if (!reply)
+		return NULL;
+
+	builder =3D l_dbus_message_builder_new(reply);
+	l_dbus_message_builder_enter_variant(builder, property->type);
+
+	if (!property->get(property, builder, instance->user_data)) {
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_message_unref(reply);
+		return NULL;
+	}
+
+	l_dbus_message_builder_leave_variant(builder);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
+}
+
+static const struct l_dbus_method properties_methods[] =3D {
+	{ L_DBUS_METHOD("Get",
+			L_DBUS_ARGS({ "interface", "s" }, { "name", "s" }),
+			L_DBUS_ARGS({ "value", "v" }),
+			properties_get) },
+	{ }
+};
+
 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
@@ -446,7 +537,6 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 {
 	struct object_node *object;
 	struct l_dbus_interface *dbi;
-	const struct l_queue_entry *entry;
 	struct interface_instance *instance;
 =

 	if (!_dbus_valid_interface(interface))
@@ -465,15 +555,8 @@ bool _dbus_object_tree_register(struct _dbus_object_tr=
ee *tree,
 	 * Check to make sure we do not have this interface already
 	 * registered for this object
 	 */
-	entry =3D l_queue_get_entries(object->instances);
-	while (entry) {
-		instance =3D entry->data;
-
-		if (!strcmp(instance->interface->name, interface))
-			return false;
-
-		entry =3D entry->next;
-	}
+	if (_dbus_object_find_instance(object, interface))
+		return false;
 =

 	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
 	if (!dbi) {
@@ -494,6 +577,13 @@ bool _dbus_object_tree_register(struct _dbus_object_tr=
ee *tree,
 =

 	l_queue_push_tail(object->instances, instance);
 =

+	if (properties) {
+		_dbus_object_tree_register(tree, path,
+						DBUS_INTERFACE_PROPERTIES,
+						properties_methods,
+						NULL, NULL, instance, NULL);
+	}
+
 	return true;
 }
 =

@@ -514,8 +604,13 @@ bool _dbus_object_tree_unregister(struct _dbus_object_=
tree *tree,
 =

 	r =3D instance ? true : false;
 =

-	if (instance)
+	if (instance) {
+		if (instance->interface->properties)
+			_dbus_object_tree_unregister(tree, path,
+						DBUS_INTERFACE_PROPERTIES);
+
 		interface_instance_free(instance);
+	}
 =

 	if (l_queue_isempty(node->instances) && !node->children) {
 		l_hashmap_remove(tree->objects, path);
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 1a210f0..efda8b8 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -49,9 +49,14 @@ enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_WRITABLE	=3D 2,
 };
 =

+struct l_dbus_property;
+
 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *message,
 						void *user_data);
+typedef bool (*l_dbus_property_getter) (const struct l_dbus_property *prop=
erty,
+					struct l_dbus_message_builder *builder,
+					void *user_data);
 =

 struct l_dbus_argument {
 	const char *name;
@@ -75,6 +80,7 @@ struct l_dbus_signal {
 struct l_dbus_property {
 	const char *name;
 	const char *type;
+	l_dbus_property_getter get;
 	enum l_dbus_property_flag flags;
 };
 =

@@ -123,23 +129,27 @@ struct l_dbus_property {
 	.args =3D _args, \
 	.flags =3D L_DBUS_SIGNAL_FLAG_DEPRECATED
 =

-#define L_DBUS_RO_PROPERTY(_name, _type) \
+#define L_DBUS_RO_PROPERTY(_name, _type, _get) \
 	.name =3D _name, \
-	.type =3D _type
+	.type =3D _type, \
+	.get =3D _get
 =

-#define L_DBUS_RW_PROPERTY(_name, _type) \
+#define L_DBUS_RW_PROPERTY(_name, _type, _get) \
 	.name =3D _name, \
 	.type =3D _type, \
+	.get =3D _get, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE
 =

-#define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type) \
+#define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type, _get) \
 	.name =3D _name, \
 	.type =3D _type, \
+	.get =3D _get, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

-#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type) \
+#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type, _get) \
 	.name =3D _name, \
 	.type =3D _type, \
+	.get =3D _get, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE | \
 			L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index ff7e814..2741912 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -51,7 +51,6 @@
 =

 #define DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
 #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
-#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
 =

 enum auth_state {
 	WAITING_FOR_OK,
-- =

2.0.4


--===============1009688482857593934==--

