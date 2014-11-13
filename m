Content-Type: multipart/mixed; boundary="===============6468895034039841357=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 19/21] dbus: Add
 org.freedesktop.DBus.Properties.PropertiesChanged signal
Date: Thu, 13 Nov 2014 12:36:23 +0200
Message-ID: <1415874985-13034-20-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6468895034039841357==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Finalizing the support for org.freedesktop.DBus.Properties standard
interface via supporting its PropertiesChanged signal.
---
 ell/dbus-service.c | 176 +++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 ell/dbus-service.h |   4 ++
 2 files changed, 179 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index b0f0063..ab6fafe 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -32,6 +32,7 @@
 #include "queue.h"
 #include "string.h"
 #include "hashmap.h"
+#include "idle.h"
 #include "dbus.h"
 #include "dbus-service.h"
 #include "dbus-private.h"
@@ -86,6 +87,10 @@ struct _dbus_pending_data {
 	uint32_t id;
 	struct l_dbus *dbus;
 	struct l_dbus_message *message;
+	struct l_idle *idler;
+	char *path;
+	struct interface_instance *instance;
+	struct l_queue *properties_changed;
 };
 =

 void _dbus_print_arguments(const struct l_dbus_argument *args,
@@ -344,6 +349,11 @@ static void destroy_pending_data(void *data)
 	if (!pending_data)
 		return;
 =

+	if (pending_data->idler) {
+		l_idle_remove(pending_data->idler);
+		return;
+	}
+
 	l_dbus_message_unref(pending_data->message);
 	l_free(pending_data);
 }
@@ -703,6 +713,14 @@ static const struct l_dbus_method properties_methods[]=
 =3D {
 	{ }
 };
 =

+static const struct l_dbus_signal properties_signals[] =3D {
+	{ L_DBUS_SIGNAL("PropertiesChanged",
+			L_DBUS_ARGS({ "interface", "s" },
+					{ "changed_properties", "a{sv}" },
+					{ "invalidated_properties", "as"})) },
+	{ }
+};
+
 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
@@ -756,7 +774,8 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 		_dbus_object_tree_register(tree, path,
 						DBUS_INTERFACE_PROPERTIES,
 						properties_methods,
-						NULL, NULL, instance, NULL);
+						properties_signals,
+						NULL, instance, NULL);
 	}
 =

 	return true;
@@ -1025,3 +1044,158 @@ LIB_EXPORT void l_dbus_pending_property_error(struc=
t l_dbus *dbus, uint32_t id,
 =

 	va_end(args);
 }
+
+static bool match_pending_data_by_instance(const void *data,
+						const void *user_data)
+{
+	const struct _dbus_pending_data *pending_data =3D data;
+	const struct interface_instance *instance =3D user_data;
+
+	if (pending_data->instance =3D=3D instance)
+		return true;
+
+	return false;
+}
+
+static void process_property_change(struct l_idle *idle, void *data)
+{
+	struct _dbus_pending_data *pending_data =3D data;
+	struct l_dbus_message *signal =3D NULL;
+	struct interface_instance *instance;
+	struct l_dbus_message_builder *builder;
+	struct l_queue *invalidated =3D NULL;
+	const struct l_queue_entry *entry;
+	struct _dbus_object_tree *tree;
+
+	if (l_queue_isempty(pending_data->properties_changed))
+		goto out;
+
+	signal =3D l_dbus_message_new_signal(pending_data->dbus,
+						pending_data->path,
+						DBUS_INTERFACE_PROPERTIES,
+						"PropertiesChanged");
+	if (!signal)
+		goto out;
+
+	instance =3D pending_data->instance;
+
+	builder =3D l_dbus_message_builder_new(signal);
+	l_dbus_message_builder_append_basic(builder, 's',
+						instance->interface->name);
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	entry =3D l_queue_get_entries(pending_data->properties_changed);
+	while (entry) {
+		const struct l_dbus_property *p =3D entry->data;
+
+		if (!p->get)
+			goto next;
+
+		if (p->exists && !p->exists(p, instance->user_data)) {
+			if (!invalidated)
+				invalidated =3D l_queue_new();
+
+			l_queue_push_tail(invalidated, (void *) p);
+			goto next;
+		}
+
+		append_property(instance, p, builder);
+	next:
+		entry =3D entry->next;
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_enter_array(builder, "s");
+
+	entry =3D l_queue_get_entries(invalidated);
+	while (entry) {
+		const struct l_dbus_property *p =3D entry->data;
+
+		l_dbus_message_builder_append_basic(builder, 's', p->name);
+
+		entry =3D entry->next;
+	}
+
+	l_queue_destroy(invalidated, NULL);
+
+	l_dbus_message_builder_leave_array(builder);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	l_dbus_send(pending_data->dbus, signal);
+out:
+	tree =3D _dbus_object_tree_get_from_dbus(pending_data->dbus);
+	l_queue_remove(tree->pending_data, pending_data);
+	l_idle_remove(idle);
+}
+
+static void destroy_property_idler(void *data)
+{
+	struct _dbus_pending_data *pending_data =3D data;
+
+	l_queue_destroy(pending_data->properties_changed, NULL);
+	l_free(pending_data->path);
+	l_free(pending_data);
+}
+
+static bool match_data(const void *data, const void *user_data)
+{
+	if (data =3D=3D user_data)
+		return true;
+
+	return false;
+}
+
+LIB_EXPORT void l_dbus_emit_property_changed(struct l_dbus *dbus,
+							const char *path,
+							const char *interface,
+							const char *name)
+{
+	struct _dbus_object_tree *tree;
+	struct object_node *object;
+	struct interface_instance *instance;
+	const struct l_dbus_property *property;
+	struct _dbus_pending_data *pending_data;
+
+	if (unlikely(!dbus))
+		return;
+
+	if (!_dbus_valid_interface(interface))
+		return;
+
+	if (!_dbus_valid_object_path(path))
+		return;
+
+	tree =3D _dbus_object_tree_get_from_dbus(dbus);
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return;
+
+	instance =3D _dbus_object_find_instance(object, interface);
+	if (!instance)
+		return;
+
+	property =3D _dbus_interface_find_property(instance->interface, name);
+	if (!property)
+		return;
+
+	pending_data =3D l_queue_find(tree->pending_data,
+				match_pending_data_by_instance, instance);
+	if (!pending_data) {
+		pending_data =3D l_new(struct _dbus_pending_data, 1);
+		pending_data->dbus =3D dbus;
+		pending_data->path =3D l_strdup(path);
+		pending_data->instance =3D instance;
+		pending_data->properties_changed =3D l_queue_new();
+
+		pending_data->idler =3D l_idle_create(process_property_change,
+					pending_data, destroy_property_idler);
+		l_queue_push_tail(tree->pending_data, pending_data);
+	}
+
+	if (!l_queue_find(pending_data->properties_changed,
+						match_data, (void *) property))
+		l_queue_push_tail(pending_data->properties_changed,
+							(void *) property);
+}
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index d5a9a8e..d13c9f1 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -189,6 +189,10 @@ void l_dbus_pending_property_error(struct l_dbus *dbus=
, uint32_t id,
 						const char *name,
 						const char *format, ...);
 =

+void l_dbus_emit_property_changed(struct l_dbus *dbus, const char *path,
+							const char *interface,
+							const char *name);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.0.4


--===============6468895034039841357==--

