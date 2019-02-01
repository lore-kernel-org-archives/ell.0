Content-Type: multipart/mixed; boundary="===============5386040915463996226=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH] dbus: Added l_dbus_signal_emit
Date: Fri, 01 Feb 2019 14:41:19 +0100
Message-ID: <20190201134118.28458-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5386040915463996226==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>

After declaring a signal with l_dbus_interface_signal, we need a way to
actually publish it.

This commit adds API for this, along with an updated example.
---
 ell/dbus-service.c      | 98 +++++++++++++++++++++++++++++++++++++++++
 ell/dbus-service.h      |  4 ++
 examples/dbus-service.c | 12 ++++-
 3 files changed, 112 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 531b710..428f590 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -125,12 +125,19 @@ struct property_change_record {
 	struct l_queue *properties;
 };
 =

+struct user_signal_record {
+	char *path;
+	struct object_node *object;
+	struct l_dbus_message *message;
+};
+
 struct _dbus_object_tree {
 	struct l_hashmap *interfaces;
 	struct l_hashmap *objects;
 	struct object_node *root;
 	struct l_queue *object_managers;
 	struct l_queue *property_changes;
+	struct l_queue *user_signals;
 	struct l_idle *emit_signals_work;
 	bool flushing;
 };
@@ -551,6 +558,15 @@ static void property_change_record_free(void *data)
 	l_free(rec);
 }
 =

+static void user_signal_record_free(void *data)
+{
+	struct user_signal_record *rec =3D data;
+
+	l_free(rec->path);
+	l_dbus_message_unref(rec->message);
+	l_free(rec);
+}
+
 static void properties_setup_func(struct l_dbus_interface *);
 static void object_manager_setup_func(struct l_dbus_interface *);
 =

@@ -570,6 +586,7 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 	tree->root =3D l_new(struct object_node, 1);
 =

 	tree->property_changes =3D l_queue_new();
+	tree->user_signals =3D l_queue_new();
 =

 	_dbus_object_tree_register_interface(tree, L_DBUS_INTERFACE_PROPERTIES,
 						properties_setup_func, NULL,
@@ -629,6 +646,8 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 =

 	l_queue_destroy(tree->property_changes, property_change_record_free);
 =

+	l_queue_destroy(tree->user_signals, user_signal_record_free);
+
 	if (tree->emit_signals_work)
 		l_idle_remove(tree->emit_signals_work);
 =

@@ -1100,6 +1119,22 @@ static bool emit_properties_changed(void *data, void=
 *user_data)
 	return true;
 }
 =

+static bool emit_user_signal(void *data, void *user_data)
+{
+	struct user_signal_record *rec =3D data;
+	struct emit_signals_data *es =3D user_data;
+
+	if (es->node && rec->object !=3D es->node)
+		return false;
+
+	l_dbus_send(es->dbus, rec->message);
+	rec->message =3D NULL;
+
+	user_signal_record_free(rec);
+
+	return true;
+}
+
 void _dbus_object_tree_signals_flush(struct l_dbus *dbus, const char *path)
 {
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
@@ -1138,6 +1173,12 @@ void _dbus_object_tree_signals_flush(struct l_dbus *=
dbus, const char *path)
 	if (!l_queue_isempty(tree->property_changes))
 		all_done =3D false;
 =

+	l_queue_foreach_remove(tree->user_signals,
+				emit_user_signal, &data);
+
+	if (!l_queue_isempty(tree->user_signals))
+		all_done =3D false;
+
 	if (all_done) {
 		l_idle_remove(tree->emit_signals_work);
 		tree->emit_signals_work =3D NULL;
@@ -1757,6 +1798,63 @@ LIB_EXPORT bool l_dbus_property_changed(struct l_dbu=
s *dbus, const char *path,
 							property);
 }
 =

+LIB_EXPORT bool l_dbus_signal_emit(struct l_dbus *dbus,
+						const char *path,
+						const char *interface_name,
+						const char *signal_name,
+						const char *signature,
+						...)
+{
+	struct user_signal_record *rec;
+	struct object_node *object;
+	struct interface_instance *instance;
+	struct l_dbus_message_builder *builder;
+	struct _dbus_signal *signal;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	va_list args;
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return false;
+
+	instance =3D l_queue_find(object->instances, match_interface_instance,
+					interface_name);
+	if (!instance)
+		return false;
+
+	signal =3D _dbus_interface_find_signal(instance->interface,
+					signal_name);
+	if (!signal)
+		return false;
+
+	rec =3D l_new(struct user_signal_record, 1);
+	rec->path =3D l_strdup(path);
+	rec->object =3D object;
+	rec->message =3D l_dbus_message_new_signal(dbus, path,
+								interface_name, signal_name);
+
+	builder =3D l_dbus_message_builder_new(rec->message);
+	if (!builder) {
+		l_dbus_message_unref(rec->message);
+		l_free(rec->path);
+		l_free(rec);
+		return false;
+	}
+
+	va_start(args, signature);
+	l_dbus_message_builder_append_from_valist(builder, signature, args);
+	va_end(args);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	l_queue_push_tail(tree->user_signals, rec);
+	schedule_emit_signals(dbus);
+
+	return true;
+}
+
+
 static struct l_dbus_message *properties_get(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 153bb3a..1b442b0 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -86,6 +86,10 @@ bool l_dbus_interface_property(struct l_dbus_interface *=
interface,
 bool l_dbus_property_changed(struct l_dbus *dbus, const char *path,
 				const char *interface, const char *property);
 =

+bool l_dbus_signal_emit(struct l_dbus *dbus, const char *path,
+				const char *interface_name, const char *signal_name,
+				const char *signature, ...);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 280057c..e30a91d 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -87,11 +87,15 @@ static struct l_dbus_message *test_method_call(struct l=
_dbus *dbus,
 {
 	struct l_dbus_message *reply;
 =

-	l_info("Method Call");
+	uint32_t argument;
+	l_dbus_message_get_arguments(message, "u", &argument);
+	l_info("Method Call: %" PRIu32 "", argument);
 =

 	reply =3D l_dbus_message_new_method_return(message);
 	l_dbus_message_set_arguments(reply, "");
 =

+	l_dbus_signal_emit(dbus, "/test", "org.test", "MethodCalled", "u", argume=
nt);
+
 	return reply;
 }
 =

@@ -167,10 +171,14 @@ static struct l_dbus_message *test_int_setter(struct =
l_dbus *dbus,
 static void setup_test_interface(struct l_dbus_interface *interface)
 {
 	l_dbus_interface_method(interface, "MethodCall", 0,
-				test_method_call, "", "");
+				test_method_call, "", "u", "argument");
+
+	l_dbus_interface_signal(interface, "MethodCalled", 0,
+				"u", "argument");
 =

 	l_dbus_interface_property(interface, "String", 0, "s",
 					test_string_getter, test_string_setter);
+
 	l_dbus_interface_property(interface, "Integer", 0, "u",
 					test_int_getter, test_int_setter);
 }
-- =

2.19.1


--===============5386040915463996226==--

