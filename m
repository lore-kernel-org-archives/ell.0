Content-Type: multipart/mixed; boundary="===============0110151642197901452=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Tue, 28 Mar 2017 01:23:01 +0200
Message-ID: <20170327232301.30258-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0110151642197901452==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the PropertiesChanged and InterfacesAdded/Removed signals
related to one object path are sent to the dbus socket in the order
that they are generated in.
---
 ell/dbus-private.h |   2 +
 ell/dbus-service.c | 160 ++++++++++++++++++++++++++++++++++++-------------=
----
 ell/dbus.c         |   5 ++
 3 files changed, 117 insertions(+), 50 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 441e668..9ffedb2 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -229,6 +229,8 @@ bool _dbus_object_tree_property_changed(struct l_dbus *=
dbus,
 					const char *interface_name,
 					const char *property_name);
 =

+void _dbus_object_tree_signals_flush(struct l_dbus *dbus, const char *path=
);
+
 typedef void (*_dbus_name_owner_change_func_t)(const char *name,
 						uint64_t old_owner,
 						uint64_t new_owner,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 1df8f1b..5ee7d27 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -132,6 +132,7 @@ struct _dbus_object_tree {
 	struct l_queue *object_managers;
 	struct l_queue *property_changes;
 	struct l_idle *emit_signals_work;
+	bool flushing;
 };
 =

 void _dbus_method_introspection(struct _dbus_method *info,
@@ -1024,71 +1025,130 @@ done:
 	return signal;
 }
 =

-static void emit_signals(struct l_idle *idle, void *user_data)
-{
-	struct l_dbus *dbus =3D user_data;
-	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
-	struct interface_add_record *interfaces_added_rec;
-	struct interface_remove_record *interfaces_removed_rec;
-	struct property_change_record *property_changes_rec;
-	const struct l_queue_entry *entry;
+struct emit_signals_data {
+	struct l_dbus *dbus;
 	struct object_manager *manager;
+	struct object_node *node;
+};
+
+static bool emit_interfaces_removed(void *data, void *user_data)
+{
+	struct interface_remove_record *rec =3D data;
+	struct emit_signals_data *es =3D user_data;
 	struct l_dbus_message *signal;
 =

-	l_idle_remove(tree->emit_signals_work);
-	tree->emit_signals_work =3D NULL;
+	if (es->node && rec->object !=3D es->node)
+		return false;
 =

-	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
-			entry =3D entry->next) {
-		manager =3D entry->data;
+	signal =3D build_interfaces_removed_signal(es->manager, rec);
+	interface_removed_record_free(rec);
 =

-		while ((interfaces_removed_rec =3D
-				l_queue_pop_head(manager->announce_removed))) {
-			signal =3D build_interfaces_removed_signal(manager,
-							interfaces_removed_rec);
-			interface_removed_record_free(interfaces_removed_rec);
+	if (signal)
+		l_dbus_send(es->manager->dbus, signal);
 =

-			if (signal)
-				l_dbus_send(manager->dbus, signal);
-		}
+	return true;
+}
 =

-		while ((interfaces_added_rec =3D
-				l_queue_pop_head(manager->announce_added))) {
-			signal =3D build_interfaces_added_signal(manager,
-							interfaces_added_rec);
-			interface_add_record_free(interfaces_added_rec);
+static bool emit_interfaces_added(void *data, void *user_data)
+{
+	struct interface_add_record *rec =3D data;
+	struct emit_signals_data *es =3D user_data;
+	struct l_dbus_message *signal;
+
+	if (es->node && rec->object !=3D es->node)
+		return false;
 =

+	signal =3D build_interfaces_added_signal(es->manager, rec);
+	interface_add_record_free(rec);
+
+	if (signal)
+		l_dbus_send(es->manager->dbus, signal);
+
+	return true;
+}
+
+static bool emit_properties_changed(void *data, void *user_data)
+{
+	struct property_change_record *rec =3D data;
+	struct emit_signals_data *es =3D user_data;
+	struct l_dbus_message *signal;
+	const struct l_queue_entry *entry;
+
+	if (es->node && rec->object !=3D es->node)
+		return false;
+
+	if (rec->instance->interface->handle_old_style_properties)
+		for (entry =3D l_queue_get_entries(rec->properties);
+				entry; entry =3D entry->next) {
+			signal =3D build_old_property_changed_signal(es->dbus,
+							rec, entry->data);
 			if (signal)
-				l_dbus_send(manager->dbus, signal);
+				l_dbus_send(es->dbus, signal);
 		}
+
+	if (l_queue_find(rec->object->instances, match_interface_instance,
+				L_DBUS_INTERFACE_PROPERTIES)) {
+		signal =3D build_properties_changed_signal(es->dbus, rec);
+		if (signal)
+			l_dbus_send(es->dbus, signal);
 	}
 =

-	while ((property_changes_rec =3D
-			l_queue_pop_head(tree->property_changes))) {
-		if (property_changes_rec->instance->interface->
-				handle_old_style_properties)
-			for (entry =3D l_queue_get_entries(property_changes_rec->
-								properties);
-					entry; entry =3D entry->next) {
-				signal =3D build_old_property_changed_signal(dbus,
-							property_changes_rec,
-							entry->data);
-				if (signal)
-					l_dbus_send(dbus, signal);
-			}
+	property_change_record_free(rec);
 =

+	return true;
+}
 =

-		if (l_queue_find(property_changes_rec->object->instances,
-					match_interface_instance,
-					L_DBUS_INTERFACE_PROPERTIES)) {
-			signal =3D build_properties_changed_signal(dbus,
-							property_changes_rec);
-			if (signal)
-				l_dbus_send(dbus, signal);
-		}
+void _dbus_object_tree_signals_flush(struct l_dbus *dbus, const char *path)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const struct l_queue_entry *entry;
+	struct emit_signals_data data;
+	bool all_done =3D true;
+
+	if (!tree->emit_signals_work || tree->flushing)
+		return;
 =

-		property_change_record_free(property_changes_rec);
+	tree->flushing =3D true;
+
+	data.dbus =3D dbus;
+	data.node =3D path ? _dbus_object_tree_lookup(tree, path) : NULL;
+
+	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
+			entry =3D entry->next) {
+		data.manager =3D entry->data;
+
+		l_queue_foreach_remove(data.manager->announce_removed,
+					emit_interfaces_removed, &data);
+
+		if (!l_queue_isempty(data.manager->announce_removed))
+			all_done =3D false;
+
+		l_queue_foreach_remove(data.manager->announce_added,
+					emit_interfaces_added, &data);
+
+		if (!l_queue_isempty(data.manager->announce_added))
+			all_done =3D false;
+	}
+
+	l_queue_foreach_remove(tree->property_changes,
+				emit_properties_changed, &data);
+
+	if (!l_queue_isempty(tree->property_changes))
+		all_done =3D false;
+
+	if (all_done) {
+		l_idle_remove(tree->emit_signals_work);
+		tree->emit_signals_work =3D NULL;
 	}
+
+	tree->flushing =3D false;
+}
+
+static void emit_signals(struct l_idle *idle, void *user_data)
+{
+	struct l_dbus *dbus =3D user_data;
+
+	_dbus_object_tree_signals_flush(dbus, NULL);
 }
 =

 static void schedule_emit_signals(struct l_dbus *dbus)
@@ -1356,7 +1416,7 @@ static bool match_interfaces_added_object(const void =
*a, const void *b)
 =

 static bool match_interfaces_removed_object(const void *a, const void *b)
 {
-	const struct interface_add_record *rec =3D a;
+	const struct interface_remove_record *rec =3D a;
 =

 	return rec->object =3D=3D b;
 }
diff --git a/ell/dbus.c b/ell/dbus.c
index db69c0d..59795a7 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -306,6 +306,7 @@ static uint32_t send_message(struct l_dbus *dbus, bool =
priority,
 {
 	struct message_callback *callback;
 	enum dbus_message_type type;
+	const char *path;
 =

 	type =3D _dbus_message_get_type(message);
 =

@@ -338,6 +339,10 @@ static uint32_t send_message(struct l_dbus *dbus, bool=
 priority,
 		return callback->serial;
 	}
 =

+	path =3D l_dbus_message_get_path(message);
+	if (path)
+		_dbus_object_tree_signals_flush(dbus, path);
+
 	l_queue_push_tail(dbus->message_queue, callback);
 =

 	if (dbus->is_ready)
-- =

2.9.3


--===============0110151642197901452==--

