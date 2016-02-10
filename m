Content-Type: multipart/mixed; boundary="===============0240295523378972861=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/9] dbus: Implement org.freedesktop.DBus.ObjectManager
Date: Wed, 10 Feb 2016 11:45:54 +0100
Message-ID: <1455101156-3587-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0240295523378972861==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c | 242 +++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 ell/dbus.c         |  14 ++++
 ell/dbus.h         |   2 +
 3 files changed, 256 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 577bbfb..5d49836 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -27,6 +27,8 @@
 #define _GNU_SOURCE
 #include <stdarg.h>
 #include <string.h>
+#include <stdio.h>
+#include <stdlib.h>
 =

 #include "util.h"
 #include "queue.h"
@@ -48,6 +50,7 @@ static const char *static_introspectable =3D
 		"\t\t</method>\n\t</interface>\n";
 =

 #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
+#define DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManager"
 =

 struct _dbus_method {
 	l_dbus_interface_method_cb_t cb;
@@ -98,10 +101,16 @@ struct object_node {
 	void (*destroy) (void *);
 };
 =

+struct object_manager {
+	char *path;
+	struct l_dbus *dbus;
+};
+
 struct _dbus_object_tree {
 	struct l_hashmap *interfaces;
 	struct l_hashmap *objects;
 	struct object_node *root;
+	struct l_queue *object_managers;
 };
 =

 void _dbus_method_introspection(struct _dbus_method *info,
@@ -512,6 +521,7 @@ static bool match_interface_instance(const void *a, con=
st void *b)
 }
 =

 static void properties_setup_func(struct l_dbus_interface *);
+static void object_manager_setup_func(struct l_dbus_interface *);
 =

 struct _dbus_object_tree *_dbus_object_tree_new()
 {
@@ -532,6 +542,13 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 						properties_setup_func, NULL,
 						false);
 =

+	tree->object_managers =3D l_queue_new();
+
+	_dbus_object_tree_register_interface(tree,
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						object_manager_setup_func, NULL,
+						false);
+
 	return tree;
 }
 =

@@ -556,6 +573,14 @@ static void subtree_free(struct object_node *node)
 	l_free(node);
 }
 =

+static void object_manager_free(void *data)
+{
+	struct object_manager *manager =3D data;
+
+	l_free(manager->path);
+	l_free(manager);
+}
+
 void _dbus_object_tree_free(struct _dbus_object_tree *tree)
 {
 	l_hashmap_destroy(tree->interfaces,
@@ -564,6 +589,8 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 =

 	subtree_free(tree->root);
 =

+	l_queue_destroy(tree->object_managers, object_manager_free);
+
 	l_free(tree);
 }
 =

@@ -1038,6 +1065,44 @@ bool _dbus_object_tree_unregister_interface(struct _=
dbus_object_tree *tree,
 	return true;
 }
 =

+static bool build_interfaces_added_signal(const struct object_manager *man=
ager,
+				const char *path,
+				const struct interface_instance *instance)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+
+	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesAdded");
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 'o', path);
+	l_dbus_message_builder_enter_array(builder, "{sa{sv}}");
+	l_dbus_message_builder_enter_dict(builder, "sa{sv}");
+	l_dbus_message_builder_append_basic(builder, 's',
+						instance->interface->name);
+
+	if (!get_properties_dict(manager->dbus, signal, builder,
+					instance->interface,
+					instance->user_data)) {
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_message_unref(signal);
+
+		return false;
+	}
+
+	l_dbus_message_builder_leave_dict(builder);
+	l_dbus_message_builder_leave_array(builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	l_dbus_send(manager->dbus, signal);
+
+	return true;
+}
+
 bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
 					const char *path, const char *interface,
 					void *user_data)
@@ -1045,6 +1110,9 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 	struct object_node *object;
 	struct l_dbus_interface *dbi;
 	struct interface_instance *instance;
+	const struct l_queue_entry *entry;
+	struct object_manager *manager;
+	size_t path_len;
 =

 	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
 	if (!dbi)
@@ -1072,15 +1140,47 @@ bool _dbus_object_tree_add_interface(struct _dbus_o=
bject_tree *tree,
 =

 	l_queue_push_tail(object->instances, instance);
 =

+	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
+			entry =3D entry->next) {
+		manager =3D entry->data;
+		path_len =3D strlen(manager->path);
+
+		if (memcmp(path, manager->path, path_len) ||
+				(path[path_len] !=3D '\0' &&
+				 path[path_len] !=3D '/' && path_len > 1))
+			continue;
+
+		build_interfaces_added_signal(manager, path, instance);
+	}
+
+	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
+		manager =3D l_new(struct object_manager, 1);
+		manager->path =3D l_strdup(path);
+		manager->dbus =3D instance->user_data;
+
+		l_queue_push_tail(tree->object_managers, manager);
+	}
+
 	return true;
 }
 =

+static bool match_object_manager_path(const void *a, const void *b)
+{
+	const struct object_manager *manager =3D a;
+
+	return !strcmp(manager->path, b);
+}
+
 bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
-					const char *path,
-					const char *interface)
+					const char *path, const char *interface)
 {
 	struct object_node *node;
 	struct interface_instance *instance;
+	const struct l_queue_entry *entry;
+	struct object_manager *manager;
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	size_t path_len;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
 	if (!node)
@@ -1093,6 +1193,39 @@ bool _dbus_object_tree_remove_interface(struct _dbus=
_object_tree *tree,
 =

 	interface_instance_free(instance);
 =

+	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
+		manager =3D l_queue_remove_if(tree->object_managers,
+						match_object_manager_path,
+						(char *) path);
+
+		object_manager_free(manager);
+	}
+
+	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
+			entry =3D entry->next) {
+		manager =3D entry->data;
+		path_len =3D strlen(manager->path);
+
+		if (memcmp(path, manager->path, path_len) ||
+				(path[path_len] !=3D '\0' &&
+				 path[path_len] !=3D '/' && path_len > 1))
+			continue;
+
+		signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesRemoved");
+
+		builder =3D l_dbus_message_builder_new(signal);
+
+		l_dbus_message_builder_append_basic(builder, 'o', path);
+		l_dbus_message_builder_enter_array(builder, "s");
+		l_dbus_message_builder_append_basic(builder, 's', interface);
+		l_dbus_message_builder_leave_array(builder);
+		l_dbus_message_builder_finalize(builder);
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_send(manager->dbus, signal);
+	}
+
 	return true;
 }
 =

@@ -1432,3 +1565,108 @@ static void properties_setup_func(struct l_dbus_int=
erface *interface)
 				"interface_name", "changed_properties",
 				"invalidated_properties");
 }
+
+static bool collect_objects(struct l_dbus *dbus, struct l_dbus_message *me=
ssage,
+				struct l_dbus_message_builder *builder,
+				const struct object_node *node,
+				const char *path)
+{
+	const struct l_queue_entry *entry;
+	const struct child_node *child;
+	char *child_path;
+	const struct interface_instance *instance;
+	bool r;
+
+	if (!node->instances)
+		goto recurse;
+
+	l_dbus_message_builder_enter_dict(builder, "oa{sa{sv}}");
+	l_dbus_message_builder_append_basic(builder, 'o', path);
+	l_dbus_message_builder_enter_array(builder, "{sa{sv}}");
+
+	for (entry =3D l_queue_get_entries(node->instances); entry;
+			entry =3D entry->next) {
+		instance =3D entry->data;
+
+		l_dbus_message_builder_enter_dict(builder, "sa{sv}");
+		l_dbus_message_builder_append_basic(builder, 's',
+						instance->interface->name);
+
+		if (!get_properties_dict(dbus, message, builder,
+						instance->interface,
+						instance->user_data))
+			return false;
+
+		l_dbus_message_builder_leave_dict(builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_leave_dict(builder);
+
+recurse:
+	if (!strcmp(path, "/"))
+		path =3D "";
+
+	for (child =3D node->children; child; child =3D child->next) {
+		child_path =3D l_strdup_printf("%s/%s", path, child->subpath);
+
+		r =3D collect_objects(dbus, message, builder,
+					child->node, child_path);
+
+		l_free(child_path);
+
+		if (!r)
+			return false;
+	}
+
+	return true;
+}
+
+static struct l_dbus_message *get_managed_objects(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const struct object_node *node;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+	const char *path;
+
+	path =3D l_dbus_message_get_path(message);
+	node =3D l_hashmap_lookup(tree->objects, path);
+
+	reply =3D l_dbus_message_new_method_return(message);
+	builder =3D l_dbus_message_builder_new(reply);
+
+	l_dbus_message_builder_enter_array(builder, "{oa{sa{sv}}}");
+
+	if (!collect_objects(dbus, message, builder, node, path)) {
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_message_unref(reply);
+
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"Failed",
+						"Getting property values "
+						"failed");
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
+}
+
+static void object_manager_setup_func(struct l_dbus_interface *interface)
+{
+	l_dbus_interface_method(interface, "GetManagedObjects", 0,
+				get_managed_objects, "a{oa{sa{sv}}}", "",
+				"objpath_interfaces_and_properties");
+
+	l_dbus_interface_signal(interface, "InterfacesAdded", 0, "oa{sa{sv}}",
+				"object_path", "interfaces_and_properties");
+	l_dbus_interface_signal(interface, "InterfacesRemoved", 0, "oas",
+				"object_path", "interfaces");
+}
diff --git a/ell/dbus.c b/ell/dbus.c
index 873a8c2..153bd0b 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -51,6 +51,7 @@
 =

 #define DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
 #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
+#define DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManager"
 =

 #define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
 =

@@ -1380,6 +1381,19 @@ LIB_EXPORT bool l_dbus_object_remove_interface(struc=
t l_dbus *dbus,
 							interface);
 }
 =

+LIB_EXPORT bool l_dbus_object_manager_enable(struct l_dbus *dbus)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_add_interface(dbus->tree, "/",
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						dbus);
+}
+
 void _dbus1_filter_format_match(struct dbus1_filter_data *data, char *rule,
 					size_t size)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index 29253b6..84bf7a4 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -211,6 +211,8 @@ bool l_dbus_object_add_interface(struct l_dbus *dbus, c=
onst char *object,
 bool l_dbus_object_remove_interface(struct l_dbus *dbus, const char *objec=
t,
 					const char *interface);
 =

+bool l_dbus_object_manager_enable(struct l_dbus *dbus);
+
 unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
 					const char *name,
 					l_dbus_watch_func_t disconnect_func,
-- =

2.5.0


--===============0240295523378972861==--

