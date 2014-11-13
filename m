Content-Type: multipart/mixed; boundary="===============8093994452386054339=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 15/21] dbus: Add support for
 org.freedesktop.DBus.Properties.Set method
Date: Thu, 13 Nov 2014 12:36:19 +0200
Message-ID: <1415874985-13034-16-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8093994452386054339==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It is thus possible to set a property following this freedesktop
standard interface.
---
 ell/dbus-private.h |   4 ++
 ell/dbus-service.c | 166 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-service.h |  22 ++++++-
 3 files changed, 190 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 0694a12..cbdd01f 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -37,6 +37,10 @@ enum dbus_container_type {
 };
 =

 #define DBUS_ERROR_INVALID_ARGS "org.freedesktop.DBus.Error.InvalidArgs"
+#define DBUS_ERROR_UNKNOWN_PROPERTY \
+				"org.freedesktop.DBus.Error.UnknownProperty"
+#define DBUS_ERROR_INVALID_SIGNATURE \
+				"org.freedesktop.DBus.Error.InvalidSignature"
 =

 #if __BYTE_ORDER =3D=3D __LITTLE_ENDIAN
 #define DBUS_NATIVE_ENDIAN 'l'
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index dbb52a6..d297e68 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -78,6 +78,14 @@ struct _dbus_object_tree {
 	struct l_hashmap *interfaces;
 	struct l_hashmap *objects;
 	struct object_node *root;
+	uint32_t next_property_set;
+	struct l_queue *pending_data;
+};
+
+struct _dbus_pending_data {
+	uint32_t id;
+	struct l_dbus *dbus;
+	struct l_dbus_message *message;
 };
 =

 void _dbus_print_arguments(const struct l_dbus_argument *args,
@@ -305,6 +313,9 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->root =3D l_new(struct object_node, 1);
 =

+	tree->next_property_set =3D 1;
+	tree->pending_data =3D l_queue_new();
+
 	return tree;
 }
 =

@@ -326,6 +337,17 @@ static void subtree_free(struct object_node *node)
 	l_free(node);
 }
 =

+static void destroy_pending_data(void *data)
+{
+	struct _dbus_pending_data *pending_data =3D data;
+
+	if (!pending_data)
+		return;
+
+	l_dbus_message_unref(pending_data->message);
+	l_free(pending_data);
+}
+
 void _dbus_object_tree_free(struct _dbus_object_tree *tree)
 {
 	l_hashmap_destroy(tree->interfaces,
@@ -334,6 +356,9 @@ void _dbus_object_tree_free(struct _dbus_object_tree *t=
ree)
 =

 	subtree_free(tree->root);
 =

+	if (tree->pending_data)
+		l_queue_destroy(tree->pending_data,
+					destroy_pending_data);
 	l_free(tree);
 }
 =

@@ -596,6 +621,66 @@ static struct l_dbus_message *properties_get_all(
 	return reply;
 }
 =

+static struct l_dbus_message *properties_set(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const char *interface;
+	const char *name;
+	struct l_dbus_message_iter variant;
+	const char *path;
+	struct _dbus_object_tree *tree;
+	struct object_node *object;
+	struct interface_instance *instance;
+	const struct l_dbus_property *property;
+	struct _dbus_pending_data *pending_data;
+
+	if (!l_dbus_message_get_arguments(message, "ssv",
+						&interface, &name, &variant))
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
+	if (property->set =3D=3D NULL)
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_ARGS,
+					"Property '%s' is not writable", name);
+
+	if (!l_dbus_message_iter_has_signature(&variant, property->type))
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_SIGNATURE,
+					"Invalid signature for '%s'", name);
+
+	pending_data =3D l_new(struct _dbus_pending_data, 1);
+	pending_data->id =3D tree->next_property_set++;
+	pending_data->message =3D l_dbus_message_ref(message);
+
+	l_queue_push_tail(tree->pending_data, pending_data);
+
+	property->set(property, dbus, &variant,
+				pending_data->id, instance->user_data);
+
+	return NULL;
+}
+
 static const struct l_dbus_method properties_methods[] =3D {
 	{ L_DBUS_METHOD("Get",
 			L_DBUS_ARGS({ "interface", "s" }, { "name", "s" }),
@@ -605,6 +690,11 @@ static const struct l_dbus_method properties_methods[]=
 =3D {
 			L_DBUS_ARGS({ "interface", "s" }),
 			L_DBUS_ARGS({ "properties", "a{sv}" }),
 			properties_get_all) },
+	{ L_DBUS_ASYNC_METHOD("Set",
+			L_DBUS_ARGS({ "interface", "s" },
+					{ "name", "s" }, { "value", "v" }),
+			NULL,
+			properties_set) },
 	{ }
 };
 =

@@ -854,3 +944,79 @@ LIB_EXPORT bool l_dbus_unregister_interface(struct l_d=
bus *dbus,
 =

 	return _dbus_object_tree_unregister(tree, path, interface);
 }
+
+static bool match_pending_data_by_id(const void *data, const void *user_da=
ta)
+{
+	const struct _dbus_pending_data *pending_data =3D data;
+	uint32_t id =3D L_PTR_TO_UINT(user_data);
+
+	if (pending_data->id =3D=3D id)
+		return true;
+
+	return false;
+}
+
+LIB_EXPORT void l_dbus_pending_property_success(struct l_dbus *dbus,
+							uint32_t id)
+{
+	struct _dbus_object_tree *tree =3D _dbus_object_tree_get_from_dbus(dbus);
+	struct _dbus_pending_data *pending_data;
+	struct l_dbus_message *reply;
+
+	if (unlikely(!dbus))
+		return;
+
+	pending_data =3D l_queue_remove_if(tree->pending_data,
+						match_pending_data_by_id,
+						L_UINT_TO_PTR(id));
+	if (!pending_data)
+		return;
+
+	reply =3D l_dbus_message_new_method_return(pending_data->message);
+	if (reply) {
+		l_dbus_message_set_arguments(reply, "");
+		l_dbus_send(dbus, reply);
+	}
+
+	destroy_pending_data(pending_data);
+}
+
+LIB_EXPORT void l_dbus_pending_property_error_valist(struct l_dbus *dbus,
+							uint32_t id,
+							const char *name,
+							const char *format,
+							va_list args)
+{
+	struct _dbus_object_tree *tree =3D _dbus_object_tree_get_from_dbus(dbus);
+	struct _dbus_pending_data *pending_data;
+	struct l_dbus_message *error;
+
+	if (unlikely(!dbus))
+		return;
+
+	pending_data =3D l_queue_remove_if(tree->pending_data,
+						match_pending_data_by_id,
+						L_UINT_TO_PTR(id));
+	if (!pending_data)
+		return;
+
+	error =3D l_dbus_message_new_error_valist(pending_data->message,
+							name, format, args);
+	if (error)
+		l_dbus_send(dbus, error);
+
+	destroy_pending_data(pending_data);
+}
+
+LIB_EXPORT void l_dbus_pending_property_error(struct l_dbus *dbus, uint32_=
t id,
+						const char *name,
+						const char *format, ...)
+{
+	va_list args;
+
+	va_start(args, format);
+
+	l_dbus_pending_property_error_valist(dbus, id, name, format, args);
+
+	va_end(args);
+}
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index efda8b8..8e344f5 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -57,6 +57,10 @@ typedef struct l_dbus_message *(*l_dbus_interface_method=
_cb_t) (struct l_dbus *,
 typedef bool (*l_dbus_property_getter) (const struct l_dbus_property *prop=
erty,
 					struct l_dbus_message_builder *builder,
 					void *user_data);
+typedef void (*l_dbus_property_setter) (const struct l_dbus_property *prop=
erty,
+					struct l_dbus *dbus,
+					struct l_dbus_message_iter *iter,
+					uint32_t id, void *user_data);
 =

 struct l_dbus_argument {
 	const char *name;
@@ -81,6 +85,7 @@ struct l_dbus_property {
 	const char *name;
 	const char *type;
 	l_dbus_property_getter get;
+	l_dbus_property_setter set;
 	enum l_dbus_property_flag flags;
 };
 =

@@ -134,10 +139,11 @@ struct l_dbus_property {
 	.type =3D _type, \
 	.get =3D _get
 =

-#define L_DBUS_RW_PROPERTY(_name, _type, _get) \
+#define L_DBUS_RW_PROPERTY(_name, _type, _get, _set) \
 	.name =3D _name, \
 	.type =3D _type, \
 	.get =3D _get, \
+	.set =3D _set, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE
 =

 #define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type, _get) \
@@ -146,10 +152,11 @@ struct l_dbus_property {
 	.get =3D _get, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

-#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type, _get) \
+#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type, _get, _set) \
 	.name =3D _name, \
 	.type =3D _type, \
 	.get =3D _get, \
+	.set =3D _set, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE | \
 			L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

@@ -164,6 +171,17 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
 bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
 					const char *interface);
 =

+void l_dbus_pending_property_success(struct l_dbus *dbus, uint32_t id);
+
+void l_dbus_pending_property_error_valist(struct l_dbus *dbus, uint32_t id,
+							const char *name,
+							const char *format,
+							va_list args);
+
+void l_dbus_pending_property_error(struct l_dbus *dbus, uint32_t id,
+						const char *name,
+						const char *format, ...);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.0.4


--===============8093994452386054339==--

