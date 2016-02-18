Content-Type: multipart/mixed; boundary="===============7429568969034066663=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] dbus: Coalesce InterfacesAdded/Removed signals
Date: Thu, 18 Feb 2016 04:20:08 +0100
Message-ID: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7429568969034066663==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When multiple interfaces are added or removed during the same main loop
cycle emit one signal per object with all the interfaces added or
removed.  Move the signals to the idle callback.
---
 ell/dbus-service.c | 337 ++++++++++++++++++++++++++++++++++++++++---------=
----
 1 file changed, 257 insertions(+), 80 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index afd0ed9..3e8005d 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -38,6 +38,7 @@
 #include "dbus-service.h"
 #include "dbus-private.h"
 #include "private.h"
+#include "idle.h"
 =

 #define XML_ID "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
 #define XML_DTD "http://www.freedesktop.org/standards/dbus/1.0/introspect.=
dtd"
@@ -104,6 +105,20 @@ struct object_node {
 struct object_manager {
 	char *path;
 	struct l_dbus *dbus;
+	struct l_queue *announce_added;
+	struct l_queue *announce_removed;
+};
+
+struct interface_add_record {
+	char *path;
+	struct object_node *object;
+	struct l_queue *instances;
+};
+
+struct interface_remove_record {
+	char *path;
+	struct object_node *object;
+	struct l_queue *interface_names;
 };
 =

 struct _dbus_object_tree {
@@ -111,6 +126,7 @@ struct _dbus_object_tree {
 	struct l_hashmap *objects;
 	struct object_node *root;
 	struct l_queue *object_managers;
+	struct l_idle *emit_signals_work;
 };
 =

 void _dbus_method_introspection(struct _dbus_method *info,
@@ -520,6 +536,24 @@ static bool match_interface_instance(const void *a, co=
nst void *b)
 	return false;
 }
 =

+static void interfaces_added_rec_free(void *data)
+{
+	struct interface_add_record *rec =3D data;
+
+	l_free(rec->path);
+	l_queue_destroy(rec->instances, NULL);
+	l_free(rec);
+}
+
+static void interfaces_removed_rec_free(void *data)
+{
+	struct interface_remove_record *rec =3D data;
+
+	l_free(rec->path);
+	l_queue_destroy(rec->interface_names, l_free);
+	l_free(rec);
+}
+
 static void properties_setup_func(struct l_dbus_interface *);
 static void object_manager_setup_func(struct l_dbus_interface *);
 =

@@ -578,6 +612,8 @@ static void object_manager_free(void *data)
 	struct object_manager *manager =3D data;
 =

 	l_free(manager->path);
+	l_queue_destroy(manager->announce_added, interfaces_added_rec_free);
+	l_queue_destroy(manager->announce_removed, interfaces_removed_rec_free);
 	l_free(manager);
 }
 =

@@ -591,6 +627,9 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 =

 	l_queue_destroy(tree->object_managers, object_manager_free);
 =

+	if (tree->emit_signals_work)
+		l_idle_remove(tree->emit_signals_work);
+
 	l_free(tree);
 }
 =

@@ -764,6 +803,163 @@ bool _dbus_object_tree_object_destroy(struct _dbus_ob=
ject_tree *tree,
 	return true;
 }
 =

+static bool get_properties_dict(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				const struct l_dbus_interface *interface,
+				void *user_data)
+{
+	const struct l_queue_entry *entry;
+	const struct _dbus_property *property;
+	const char *signature;
+
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	for (entry =3D l_queue_get_entries(interface->properties); entry;
+			entry =3D entry->next) {
+		property =3D entry->data;
+		signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+		l_dbus_message_builder_enter_dict(builder, "sv");
+		l_dbus_message_builder_append_basic(builder, 's',
+							property->metainfo);
+		l_dbus_message_builder_enter_variant(builder, signature);
+
+		if (!property->getter(dbus, message, builder, user_data))
+			return false;
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
+static struct l_dbus_message *build_interfaces_removed_signal(
+				const struct object_manager *manager,
+				const struct interface_remove_record *rec)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	const struct l_queue_entry *entry;
+
+	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesRemoved");
+
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 'o', rec->path);
+	l_dbus_message_builder_enter_array(builder, "s");
+
+	for (entry =3D l_queue_get_entries(rec->interface_names); entry;
+			entry =3D entry->next)
+		l_dbus_message_builder_append_basic(builder, 's', entry->data);
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return signal;
+}
+
+static struct l_dbus_message *build_interfaces_added_signal(
+					const struct object_manager *manager,
+					const struct interface_add_record *rec)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	const struct l_queue_entry *entry;
+	const struct interface_instance *instance;
+
+	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
+						DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesAdded");
+
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 'o', rec->path);
+	l_dbus_message_builder_enter_array(builder, "{sa{sv}}");
+
+	for (entry =3D l_queue_get_entries(rec->instances); entry;
+			entry =3D entry->next) {
+		instance =3D entry->data;
+
+		l_dbus_message_builder_enter_dict(builder, "sa{sv}");
+		l_dbus_message_builder_append_basic(builder, 's',
+						instance->interface->name);
+
+		if (!get_properties_dict(manager->dbus, signal, builder,
+						instance->interface,
+						instance->user_data)) {
+			l_dbus_message_builder_destroy(builder);
+			l_dbus_message_unref(signal);
+
+			return NULL;
+		}
+
+		l_dbus_message_builder_leave_dict(builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return signal;
+}
+
+static void emit_signals(struct l_idle *idle, void *user_data)
+{
+	struct l_dbus *dbus =3D user_data;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct interface_add_record *interfaces_added_rec;
+	struct interface_remove_record *interfaces_removed_rec;
+	struct property_changes *property_changes_rec;
+	const struct l_queue_entry *entry;
+	struct object_manager *manager;
+	struct l_dbus_message *signal;
+
+	l_idle_remove(tree->emit_signals_work);
+	tree->emit_signals_work =3D NULL;
+
+	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
+			entry =3D entry->next) {
+		manager =3D entry->data;
+
+		while ((interfaces_removed_rec =3D
+				l_queue_pop_head(manager->announce_removed))) {
+			signal =3D build_interfaces_removed_signal(manager,
+							interfaces_removed_rec);
+			interfaces_removed_rec_free(interfaces_removed_rec);
+
+			if (signal)
+				l_dbus_send(manager->dbus, signal);
+		}
+
+		while ((interfaces_added_rec =3D
+				l_queue_pop_head(manager->announce_added))) {
+			signal =3D build_interfaces_added_signal(manager,
+							interfaces_added_rec);
+			interfaces_added_rec_free(interfaces_added_rec);
+
+			if (signal)
+				l_dbus_send(manager->dbus, signal);
+		}
+	}
+}
+
+static void schedule_emit_signals(struct l_dbus *dbus)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	if (tree->emit_signals_work)
+		return;
+
+	tree->emit_signals_work =3D l_idle_create(emit_signals, dbus, NULL);
+}
+
 /* Send the signals associated with a property value change */
 bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
@@ -941,40 +1137,6 @@ static struct l_dbus_message *old_set_property(struct=
 l_dbus *dbus,
 	return NULL;
 }
 =

-static bool get_properties_dict(struct l_dbus *dbus,
-				struct l_dbus_message *message,
-				struct l_dbus_message_builder *builder,
-				const struct l_dbus_interface *interface,
-				void *user_data)
-{
-	const struct l_queue_entry *entry;
-	const struct _dbus_property *property;
-	const char *signature;
-
-	l_dbus_message_builder_enter_array(builder, "{sv}");
-
-	for (entry =3D l_queue_get_entries(interface->properties); entry;
-			entry =3D entry->next) {
-		property =3D entry->data;
-		signature =3D property->metainfo + strlen(property->metainfo) + 1;
-
-		l_dbus_message_builder_enter_dict(builder, "sv");
-		l_dbus_message_builder_append_basic(builder, 's',
-							property->metainfo);
-		l_dbus_message_builder_enter_variant(builder, signature);
-
-		if (!property->getter(dbus, message, builder, user_data))
-			return false;
-
-		l_dbus_message_builder_leave_variant(builder);
-		l_dbus_message_builder_leave_dict(builder);
-	}
-
-	l_dbus_message_builder_leave_array(builder);
-
-	return true;
-}
-
 static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
@@ -1088,42 +1250,18 @@ bool _dbus_object_tree_unregister_interface(struct =
_dbus_object_tree *tree,
 	return true;
 }
 =

-static bool build_interfaces_added_signal(const struct object_manager *man=
ager,
-				const char *path,
-				const struct interface_instance *instance)
+static bool match_interfaces_added_object(const void *a, const void *b)
 {
-	struct l_dbus_message *signal;
-	struct l_dbus_message_builder *builder;
-
-	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
-						DBUS_INTERFACE_OBJECT_MANAGER,
-						"InterfacesAdded");
-	builder =3D l_dbus_message_builder_new(signal);
-
-	l_dbus_message_builder_append_basic(builder, 'o', path);
-	l_dbus_message_builder_enter_array(builder, "{sa{sv}}");
-	l_dbus_message_builder_enter_dict(builder, "sa{sv}");
-	l_dbus_message_builder_append_basic(builder, 's',
-						instance->interface->name);
-
-	if (!get_properties_dict(manager->dbus, signal, builder,
-					instance->interface,
-					instance->user_data)) {
-		l_dbus_message_builder_destroy(builder);
-		l_dbus_message_unref(signal);
-
-		return false;
-	}
-
-	l_dbus_message_builder_leave_dict(builder);
-	l_dbus_message_builder_leave_array(builder);
+	const struct interface_add_record *rec =3D a;
 =

-	l_dbus_message_builder_finalize(builder);
-	l_dbus_message_builder_destroy(builder);
+	return rec->object =3D=3D b;
+}
 =

-	l_dbus_send(manager->dbus, signal);
+static bool match_interfaces_removed_object(const void *a, const void *b)
+{
+	const struct interface_add_record *rec =3D a;
 =

-	return true;
+	return rec->object =3D=3D b;
 }
 =

 bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
@@ -1136,6 +1274,7 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 	const struct l_queue_entry *entry;
 	struct object_manager *manager;
 	size_t path_len;
+	struct interface_add_record *change_rec;
 =

 	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
 	if (!dbi)
@@ -1173,13 +1312,30 @@ bool _dbus_object_tree_add_interface(struct _dbus_o=
bject_tree *tree,
 				 path[path_len] !=3D '/' && path_len > 1))
 			continue;
 =

-		build_interfaces_added_signal(manager, path, instance);
+		change_rec =3D l_queue_find(manager->announce_added,
+						match_interfaces_added_object,
+						object);
+		if (!change_rec) {
+			change_rec =3D l_new(struct interface_add_record, 1);
+			change_rec->path =3D l_strdup(path);
+			change_rec->object =3D object;
+			change_rec->instances =3D l_queue_new();
+
+			l_queue_push_tail(manager->announce_added, change_rec);
+		}
+
+		/* No need to check for duplicates here */
+		l_queue_push_tail(change_rec->instances, instance);
+
+		schedule_emit_signals(manager->dbus);
 	}
 =

 	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
 		manager =3D l_new(struct object_manager, 1);
 		manager->path =3D l_strdup(path);
 		manager->dbus =3D instance->user_data;
+		manager->announce_added =3D l_queue_new();
+		manager->announce_removed =3D l_queue_new();
 =

 		l_queue_push_tail(tree->object_managers, manager);
 	}
@@ -1201,9 +1357,9 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 	struct interface_instance *instance;
 	const struct l_queue_entry *entry;
 	struct object_manager *manager;
-	struct l_dbus_message *signal;
-	struct l_dbus_message_builder *builder;
 	size_t path_len;
+	struct interface_add_record *interfaces_added_rec;
+	struct interface_remove_record *interfaces_removed_rec;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
 	if (!node)
@@ -1234,19 +1390,40 @@ bool _dbus_object_tree_remove_interface(struct _dbu=
s_object_tree *tree,
 				 path[path_len] !=3D '/' && path_len > 1))
 			continue;
 =

-		signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
-						DBUS_INTERFACE_OBJECT_MANAGER,
-						"InterfacesRemoved");
+		interfaces_added_rec =3D l_queue_find(manager->announce_added,
+						match_interfaces_added_object,
+						node);
+		if (interfaces_added_rec && l_queue_remove(
+						interfaces_added_rec->instances,
+						instance)) {
+			if (l_queue_isempty(interfaces_added_rec->instances))
+				l_queue_remove(manager->announce_added,
+						interfaces_added_rec);
 =

-		builder =3D l_dbus_message_builder_new(signal);
+			interfaces_added_rec_free(interfaces_added_rec);
 =

-		l_dbus_message_builder_append_basic(builder, 'o', path);
-		l_dbus_message_builder_enter_array(builder, "s");
-		l_dbus_message_builder_append_basic(builder, 's', interface);
-		l_dbus_message_builder_leave_array(builder);
-		l_dbus_message_builder_finalize(builder);
-		l_dbus_message_builder_destroy(builder);
-		l_dbus_send(manager->dbus, signal);
+			continue;
+		}
+
+		interfaces_removed_rec =3D l_queue_find(manager->announce_removed,
+						match_interfaces_removed_object,
+						node);
+		if (!interfaces_removed_rec) {
+			interfaces_removed_rec =3D
+				l_new(struct interface_remove_record, 1);
+			interfaces_removed_rec->path =3D l_strdup(path);
+			interfaces_removed_rec->object =3D node;
+			interfaces_removed_rec->interface_names =3D
+				l_queue_new();
+			l_queue_push_tail(manager->announce_removed,
+						interfaces_removed_rec);
+		}
+
+		/* No need to check for duplicates here */
+		l_queue_push_tail(interfaces_removed_rec->interface_names,
+					l_strdup(interface));
+
+		schedule_emit_signals(manager->dbus);
 	}
 =

 	return true;
-- =

2.5.0


--===============7429568969034066663==--

