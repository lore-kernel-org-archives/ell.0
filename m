Content-Type: multipart/mixed; boundary="===============7964588852699803246=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] dbus: Coalesce PropertiesChanged signals
Date: Thu, 18 Feb 2016 04:20:09 +0100
Message-ID: <1455765612-6577-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7964588852699803246==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When multiple properties are changed in one main loop cycle emit only
one signal per interface with all the changes.
---
 ell/dbus-private.h |   3 +-
 ell/dbus-service.c | 256 ++++++++++++++++++++++++++++++++++++-------------=
----
 2 files changed, 177 insertions(+), 82 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 873396d..f676bdb 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -200,8 +200,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
-					const char *property_name,
-					struct l_dbus_message_iter *variant);
+					const char *property_name);
 =

 void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
 				const char *prefix, const char *str);
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 3e8005d..063cdd3 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -121,11 +121,19 @@ struct interface_remove_record {
 	struct l_queue *interface_names;
 };
 =

+struct property_changes {
+	char *path;
+	struct object_node *object;
+	struct interface_instance *instance;
+	struct l_queue *properties;
+};
+
 struct _dbus_object_tree {
 	struct l_hashmap *interfaces;
 	struct l_hashmap *objects;
 	struct object_node *root;
 	struct l_queue *object_managers;
+	struct l_queue *property_changes;
 	struct l_idle *emit_signals_work;
 };
 =

@@ -554,6 +562,15 @@ static void interfaces_removed_rec_free(void *data)
 	l_free(rec);
 }
 =

+static void property_change_rec_free(void *data)
+{
+	struct property_changes *rec =3D data;
+
+	l_free(rec->path);
+	l_queue_destroy(rec->properties, NULL);
+	l_free(rec);
+}
+
 static void properties_setup_func(struct l_dbus_interface *);
 static void object_manager_setup_func(struct l_dbus_interface *);
 =

@@ -572,6 +589,8 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->root =3D l_new(struct object_node, 1);
 =

+	tree->property_changes =3D l_queue_new();
+
 	_dbus_object_tree_register_interface(tree, DBUS_INTERFACE_PROPERTIES,
 						properties_setup_func, NULL,
 						false);
@@ -627,6 +646,8 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 =

 	l_queue_destroy(tree->object_managers, object_manager_free);
 =

+	l_queue_destroy(tree->property_changes, property_change_rec_free);
+
 	if (tree->emit_signals_work)
 		l_idle_remove(tree->emit_signals_work);
 =

@@ -910,6 +931,93 @@ static struct l_dbus_message *build_interfaces_added_s=
ignal(
 	return signal;
 }
 =

+static struct l_dbus_message *build_old_property_changed_signal(
+					struct l_dbus *dbus,
+					const struct property_changes *rec,
+					const struct _dbus_property *property)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	const char *signature;
+
+	signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+	signal =3D l_dbus_message_new_signal(dbus, rec->path,
+						rec->instance->interface->name,
+						"PropertyChanged");
+
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 's', property->metainfo);
+	l_dbus_message_builder_enter_variant(builder, signature);
+
+	if (!property->getter(dbus, signal, builder,
+				rec->instance->user_data)) {
+		l_dbus_message_builder_destroy(builder);
+		l_dbus_message_unref(signal);
+
+		return NULL;
+	}
+
+	l_dbus_message_builder_leave_variant(builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return signal;
+}
+
+static struct l_dbus_message *build_properties_changed_signal(
+					struct l_dbus *dbus,
+					const struct property_changes *rec)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	const struct l_queue_entry *entry;
+	const struct _dbus_property *property;
+	const char *signature;
+
+	signal =3D l_dbus_message_new_signal(dbus, rec->path,
+						DBUS_INTERFACE_PROPERTIES,
+						"PropertiesChanged");
+
+	builder =3D l_dbus_message_builder_new(signal);
+
+	l_dbus_message_builder_append_basic(builder, 's',
+						rec->instance->interface->name);
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	for (entry =3D l_queue_get_entries(rec->properties); entry;
+			entry =3D entry->next) {
+		property =3D entry->data;
+		signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+		l_dbus_message_builder_enter_dict(builder, "sv");
+		l_dbus_message_builder_append_basic(builder, 's',
+							property->metainfo);
+		l_dbus_message_builder_enter_variant(builder, signature);
+
+		if (!property->getter(dbus, signal, builder,
+					rec->instance->user_data)) {
+			l_dbus_message_builder_destroy(builder);
+			l_dbus_message_unref(signal);
+
+			return NULL;
+		}
+
+		l_dbus_message_builder_leave_variant(builder);
+		l_dbus_message_builder_leave_dict(builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_enter_array(builder, "s");
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return signal;
+}
+
 static void emit_signals(struct l_idle *idle, void *user_data)
 {
 	struct l_dbus *dbus =3D user_data;
@@ -948,6 +1056,33 @@ static void emit_signals(struct l_idle *idle, void *u=
ser_data)
 				l_dbus_send(manager->dbus, signal);
 		}
 	}
+
+	while ((property_changes_rec =3D
+			l_queue_pop_head(tree->property_changes))) {
+		if (property_changes_rec->instance->interface->
+				handle_old_style_properties)
+			for (entry =3D l_queue_get_entries(property_changes_rec->
+								properties);
+					entry; entry =3D entry->next) {
+				signal =3D build_old_property_changed_signal(dbus,
+							property_changes_rec,
+							entry->data);
+				if (signal)
+					l_dbus_send(dbus, signal);
+			}
+
+
+		if (l_queue_find(property_changes_rec->object->instances,
+					match_interface_instance,
+					DBUS_INTERFACE_PROPERTIES)) {
+			signal =3D build_properties_changed_signal(dbus,
+							property_changes_rec);
+			if (signal)
+				l_dbus_send(dbus, signal);
+		}
+
+		property_change_rec_free(property_changes_rec);
+	}
 }
 =

 static void schedule_emit_signals(struct l_dbus *dbus)
@@ -960,22 +1095,28 @@ static void schedule_emit_signals(struct l_dbus *dbu=
s)
 	tree->emit_signals_work =3D l_idle_create(emit_signals, dbus, NULL);
 }
 =

-/* Send the signals associated with a property value change */
+static bool match_property_changes_instance(const void *a, const void *b)
+{
+	const struct property_changes *rec =3D a;
+
+	return rec->instance =3D=3D b;
+}
+
+static bool match_pointer(const void *a, const void *b)
+{
+	return a =3D=3D b;
+}
+
 bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
-					const char *property_name,
-					struct l_dbus_message_iter *variant)
+					const char *property_name)
 {
-	struct l_dbus_message *signal;
-	struct l_dbus_message_builder *builder;
-	const struct _dbus_property *property;
-	const char *signature;
-	const struct interface_instance *instance;
-	const struct object_node *object;
-	struct l_dbus_message_iter value;
+	struct property_changes *rec;
+	struct object_node *object;
+	struct interface_instance *instance;
+	struct _dbus_property *property;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
-	bool r;
 =

 	object =3D l_hashmap_lookup(tree->objects, path);
 	if (!object)
@@ -991,76 +1132,25 @@ bool _dbus_object_tree_property_changed(struct l_dbu=
s *dbus,
 	if (!property)
 		return false;
 =

-	signature =3D property->metainfo + strlen(property->metainfo) + 1;
-
-	if (instance->interface->handle_old_style_properties) {
-		signal =3D l_dbus_message_new_signal(dbus, path,
-							interface_name,
-							"PropertyChanged");
+	rec =3D l_queue_find(tree->property_changes,
+				match_property_changes_instance, instance);
 =

-		builder =3D l_dbus_message_builder_new(signal);
-
-		l_dbus_message_builder_append_basic(builder, 's',
-							property_name);
-		l_dbus_message_builder_enter_variant(builder, signature);
+	if (rec) {
+		if (l_queue_find(rec->properties, match_pointer, property))
+			return true;
+	} else {
+		rec =3D l_new(struct property_changes, 1);
+		rec->path =3D l_strdup(path);
+		rec->object =3D object;
+		rec->instance =3D instance;
+		rec->properties =3D l_queue_new();
 =

-		if (variant) {
-			memcpy(&value, variant, sizeof(value));
-			r =3D l_dbus_message_builder_append_from_iter(builder,
-								&value);
-		} else {
-			r =3D property->getter(dbus, signal, builder,
-						instance->user_data);
-		}
-
-		if (r) {
-			l_dbus_message_builder_leave_variant(builder);
-
-			l_dbus_message_builder_finalize(builder);
-			l_dbus_send(dbus, signal);
-		}
-
-		l_dbus_message_builder_destroy(builder);
+		l_queue_push_tail(tree->property_changes, rec);
 	}
 =

-	if (l_queue_find(object->instances, match_interface_instance,
-				DBUS_INTERFACE_PROPERTIES)) {
-		signal =3D l_dbus_message_new_signal(dbus, path,
-						DBUS_INTERFACE_PROPERTIES,
-						"PropertiesChanged");
-
-		builder =3D l_dbus_message_builder_new(signal);
-
-		l_dbus_message_builder_append_basic(builder, 's',
-							interface_name);
-		l_dbus_message_builder_enter_array(builder, "{sv}");
-		l_dbus_message_builder_enter_dict(builder, "sv");
-		l_dbus_message_builder_append_basic(builder, 's',
-							property_name);
-		l_dbus_message_builder_enter_variant(builder, signature);
+	l_queue_push_tail(rec->properties, property);
 =

-		if (variant) {
-			memcpy(&value, variant, sizeof(value));
-			r =3D l_dbus_message_builder_append_from_iter(builder,
-								&value);
-		} else {
-			r =3D property->getter(dbus, signal, builder,
-						instance->user_data);
-		}
-
-		if (r) {
-			l_dbus_message_builder_leave_variant(builder);
-			l_dbus_message_builder_leave_dict(builder);
-			l_dbus_message_builder_leave_array(builder);
-			l_dbus_message_builder_enter_array(builder, "s");
-			l_dbus_message_builder_leave_array(builder);
-
-			l_dbus_message_builder_finalize(builder);
-			l_dbus_send(dbus, signal);
-		}
-
-		l_dbus_message_builder_destroy(builder);
-	}
+	schedule_emit_signals(dbus);
 =

 	return true;
 }
@@ -1090,7 +1180,7 @@ static void set_property_complete(struct l_dbus *dbus,
 	_dbus_object_tree_property_changed(dbus,
 					l_dbus_message_get_path(message),
 					l_dbus_message_get_interface(message),
-					property_name, &variant);
+					property_name);
 =

 	l_dbus_message_unref(message);
 }
@@ -1360,6 +1450,7 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 	size_t path_len;
 	struct interface_add_record *interfaces_added_rec;
 	struct interface_remove_record *interfaces_removed_rec;
+	struct property_changes *property_change_rec;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
 	if (!node)
@@ -1426,6 +1517,12 @@ bool _dbus_object_tree_remove_interface(struct _dbus=
_object_tree *tree,
 		schedule_emit_signals(manager->dbus);
 	}
 =

+	property_change_rec =3D l_queue_remove_if(tree->property_changes,
+						match_property_changes_instance,
+						instance);
+	if (property_change_rec)
+		property_change_rec_free(property_change_rec);
+
 	return true;
 }
 =

@@ -1534,7 +1631,7 @@ LIB_EXPORT bool l_dbus_property_changed(struct l_dbus=
 *dbus, const char *path,
 					const char *property)
 {
 	return _dbus_object_tree_property_changed(dbus, path, interface,
-							property, NULL);
+							property);
 }
 =

 static struct l_dbus_message *properties_get(struct l_dbus *dbus,
@@ -1630,8 +1727,7 @@ static void properties_set_complete(struct l_dbus *db=
us,
 =

 	_dbus_object_tree_property_changed(dbus,
 					l_dbus_message_get_path(message),
-					interface_name, property_name,
-					&variant);
+					interface_name, property_name);
 =

 	l_dbus_message_unref(message);
 }
-- =

2.5.0


--===============7964588852699803246==--

