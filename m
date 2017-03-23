Content-Type: multipart/mixed; boundary="===============0896740818783502147=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Thu, 23 Mar 2017 16:12:35 +0100
Message-ID: <20170323151235.11997-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0896740818783502147==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the PropertiesChanged and InterfacesAdded/Removed signals
related to one object path are sent to the dbus socket in the order
that they are generated in.
---
 ell/dbus-private.h |  2 ++
 ell/dbus-service.c | 85 +++++++++++++++++++++++++++++++++++++++-----------=
----
 ell/dbus.c         |  5 ++++
 3 files changed, 68 insertions(+), 24 deletions(-)

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
index 1df8f1b..7212340 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1024,9 +1024,29 @@ done:
 	return signal;
 }
 =

-static void emit_signals(struct l_idle *idle, void *user_data)
+static bool match_interfaces_added_object(const void *a, const void *b)
+{
+	const struct interface_add_record *rec =3D a;
+
+	return rec->object =3D=3D b || !b;
+}
+
+static bool match_interfaces_removed_object(const void *a, const void *b)
+{
+	const struct interface_remove_record *rec =3D a;
+
+	return rec->object =3D=3D b || !b;
+}
+
+static bool match_properties_changed_object(const void *a, const void *b)
+{
+	const struct property_change_record *rec =3D a;
+
+	return rec->object =3D=3D b || !b;
+}
+
+void _dbus_object_tree_signals_flush(struct l_dbus *dbus, const char *path)
 {
-	struct l_dbus *dbus =3D user_data;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 	struct interface_add_record *interfaces_added_rec;
 	struct interface_remove_record *interfaces_removed_rec;
@@ -1034,16 +1054,23 @@ static void emit_signals(struct l_idle *idle, void =
*user_data)
 	const struct l_queue_entry *entry;
 	struct object_manager *manager;
 	struct l_dbus_message *signal;
+	struct object_node *node =3D NULL;
+	bool all_done =3D true;
 =

-	l_idle_remove(tree->emit_signals_work);
-	tree->emit_signals_work =3D NULL;
+	if (!tree->emit_signals_work)
+		return;
+
+	if (path)
+		node =3D _dbus_object_tree_lookup(tree, path);
 =

 	for (entry =3D l_queue_get_entries(tree->object_managers); entry;
 			entry =3D entry->next) {
 		manager =3D entry->data;
 =

-		while ((interfaces_removed_rec =3D
-				l_queue_pop_head(manager->announce_removed))) {
+		while ((interfaces_removed_rec =3D l_queue_remove_if(
+						manager->announce_removed,
+						match_interfaces_removed_object,
+						node))) {
 			signal =3D build_interfaces_removed_signal(manager,
 							interfaces_removed_rec);
 			interface_removed_record_free(interfaces_removed_rec);
@@ -1052,8 +1079,13 @@ static void emit_signals(struct l_idle *idle, void *=
user_data)
 				l_dbus_send(manager->dbus, signal);
 		}
 =

-		while ((interfaces_added_rec =3D
-				l_queue_pop_head(manager->announce_added))) {
+		if (!l_queue_isempty(manager->announce_removed))
+			all_done =3D false;
+
+		while ((interfaces_added_rec =3D l_queue_remove_if(
+						manager->announce_added,
+						match_interfaces_added_object,
+						node))) {
 			signal =3D build_interfaces_added_signal(manager,
 							interfaces_added_rec);
 			interface_add_record_free(interfaces_added_rec);
@@ -1061,10 +1093,14 @@ static void emit_signals(struct l_idle *idle, void =
*user_data)
 			if (signal)
 				l_dbus_send(manager->dbus, signal);
 		}
+
+		if (!l_queue_isempty(manager->announce_added))
+			all_done =3D false;
 	}
 =

-	while ((property_changes_rec =3D
-			l_queue_pop_head(tree->property_changes))) {
+	while ((property_changes_rec =3D l_queue_remove_if(tree->property_changes,
+						match_properties_changed_object,
+						node))) {
 		if (property_changes_rec->instance->interface->
 				handle_old_style_properties)
 			for (entry =3D l_queue_get_entries(property_changes_rec->
@@ -1089,6 +1125,21 @@ static void emit_signals(struct l_idle *idle, void *=
user_data)
 =

 		property_change_record_free(property_changes_rec);
 	}
+
+	if (!l_queue_isempty(tree->property_changes))
+		all_done =3D false;
+
+	if (all_done) {
+		l_idle_remove(tree->emit_signals_work);
+		tree->emit_signals_work =3D NULL;
+	}
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
@@ -1347,20 +1398,6 @@ bool _dbus_object_tree_unregister_interface(struct _=
dbus_object_tree *tree,
 	return true;
 }
 =

-static bool match_interfaces_added_object(const void *a, const void *b)
-{
-	const struct interface_add_record *rec =3D a;
-
-	return rec->object =3D=3D b;
-}
-
-static bool match_interfaces_removed_object(const void *a, const void *b)
-{
-	const struct interface_add_record *rec =3D a;
-
-	return rec->object =3D=3D b;
-}
-
 bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
 					const char *path, const char *interface,
 					void *user_data)
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


--===============0896740818783502147==--

