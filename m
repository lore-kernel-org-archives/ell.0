Content-Type: multipart/mixed; boundary="===============8658994146046306115=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 10/21] dbus: Refactor the interface API so it uses constant
 properties array
Date: Thu, 13 Nov 2014 12:36:14 +0200
Message-ID: <1415874985-13034-11-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8658994146046306115==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This makes ELL DBus interface API more in line with what exists in
GDBus.
---
 ell/dbus-private.h |  12 ++++---
 ell/dbus-service.c | 104 ++++++++++++++-----------------------------------=
----
 ell/dbus-service.h |  39 +++++++++++++-------
 3 files changed, 61 insertions(+), 94 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 5248dd6..6ead02d 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -61,7 +61,7 @@ struct l_dbus_interface;
 struct l_dbus_argument;
 struct l_dbus_method;
 struct l_dbus_signal;
-struct _dbus_property;
+struct l_dbus_property;
 struct l_dbus_message_iter;
 struct l_dbus_message;
 struct l_dbus;
@@ -148,7 +148,7 @@ void _dbus_method_introspection(const struct l_dbus_met=
hod *info,
 						struct l_string *buf);
 void _dbus_signal_introspection(const struct l_dbus_signal *info,
 						struct l_string *buf);
-void _dbus_property_introspection(struct _dbus_property *info,
+void _dbus_property_introspection(const struct l_dbus_property *info,
 						struct l_string *buf);
 void _dbus_interface_introspection(struct l_dbus_interface *interface,
 						struct l_string *buf);
@@ -160,13 +160,15 @@ bool _dbus_interface_methods(struct l_dbus_interface =
*interface,
 				const struct l_dbus_method *methods);
 bool _dbus_interface_signals(struct l_dbus_interface *interface,
 				const struct l_dbus_signal *signals);
+bool _dbus_interface_properties(struct l_dbus_interface *interface,
+				const struct l_dbus_property *properties);
 =

 const struct l_dbus_method *_dbus_interface_find_method(struct l_dbus_inte=
rface *i,
 							const char *method);
 const struct l_dbus_signal *_dbus_interface_find_signal(struct l_dbus_inte=
rface *i,
 							const char *signal);
-struct _dbus_property *_dbus_interface_find_property(struct l_dbus_interfa=
ce *i,
-						const char *property);
+const struct l_dbus_property *_dbus_interface_find_property(struct l_dbus_=
interface *i,
+							const char *property);
 =

 struct _dbus_object_tree *_dbus_object_tree_new();
 void _dbus_object_tree_free(struct _dbus_object_tree *tree);
@@ -181,7 +183,7 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
 				const struct l_dbus_signal *signals,
-				void (*setup_func)(struct l_dbus_interface *),
+				const struct l_dbus_property *properties,
 				void *user_data, void (*destroy) (void *));
 bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
 					const char *path,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 8996407..8dc394a 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -47,16 +47,10 @@ static const char *static_introspectable =3D
 		"\t\t\t<arg name=3D\"xml\" type=3D\"s\" direction=3D\"out\"/>\n"
 		"\t\t</method>\n\t</interface>\n";
 =

-struct _dbus_property {
-	uint32_t flags;
-	unsigned char name_len;
-	char metainfo[];
-};
-
 struct l_dbus_interface {
 	const struct l_dbus_method *methods;
 	const struct l_dbus_signal *signals;
-	struct l_queue *properties;
+	const struct l_dbus_property *properties;
 	char name[];
 };
 =

@@ -136,21 +130,18 @@ void _dbus_signal_introspection(const struct l_dbus_s=
ignal *info,
 	l_string_append(buf, "\t\t</signal>\n");
 }
 =

-void _dbus_property_introspection(struct _dbus_property *info,
+void _dbus_property_introspection(const struct l_dbus_property *info,
 						struct l_string *buf)
 {
-	unsigned int offset =3D info->name_len + 1;
-	const char *signature =3D info->metainfo + offset;
-
 	l_string_append_printf(buf, "\t\t<property name=3D\"%s\" type=3D\"%s\" ",
-				info->metainfo, signature);
+				info->name, info->type);
 =

 	if (info->flags & L_DBUS_PROPERTY_FLAG_WRITABLE)
 		l_string_append(buf, "access=3D\"readwrite\"");
 	else
 		l_string_append(buf, "access=3D\"read\"");
 =

-	if (info->flags & L_DBUS_METHOD_FLAG_DEPRECATED) {
+	if (info->flags & L_DBUS_PROPERTY_FLAG_DEPRECATED) {
 		l_string_append(buf, ">\n");
 		l_string_append(buf, "\t\t\t<annotation name=3D\""
 				"org.freedesktop.DBus.Deprecated\" "
@@ -165,6 +156,7 @@ void _dbus_interface_introspection(struct l_dbus_interf=
ace *interface,
 {
 	const struct l_dbus_method *method;
 	const struct l_dbus_signal *signal;
+	const struct l_dbus_property *property;
 =

 	l_string_append_printf(buf, "\t<interface name=3D\"%s\">\n",
 				interface->name);
@@ -173,8 +165,9 @@ void _dbus_interface_introspection(struct l_dbus_interf=
ace *interface,
 		_dbus_method_introspection(method, buf);
 	for (signal =3D interface->signals; signal && signal->name; signal++)
 		_dbus_signal_introspection(signal, buf);
-	l_queue_foreach(interface->properties,
-		(l_queue_foreach_func_t) _dbus_property_introspection, buf);
+	for (property =3D interface->properties;
+				property && property->name; property++)
+		_dbus_property_introspection(property, buf);
 =

 	l_string_append(buf, "\t</interface>\n");
 }
@@ -207,63 +200,26 @@ bool _dbus_interface_signals(struct l_dbus_interface =
*interface,
 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_property(struct l_dbus_interface *interfa=
ce,
-					const char *name, uint32_t flags,
-					const char *signature)
+bool _dbus_interface_properties(struct l_dbus_interface *interface,
+				const struct l_dbus_property *properties)
 {
-	unsigned int metainfo_len;
-	struct _dbus_property *info;
-	char *p;
-
-	if (!_dbus_valid_method(name))
-		return false;
-
-	if (unlikely(!signature))
+	if (unlikely(!interface))
 		return false;
 =

-	if (!_dbus_valid_signature(signature))
+	if (unlikely(!properties))
 		return false;
 =

-	/* Pre-calculate the needed meta-info length */
-	metainfo_len =3D strlen(name) + 1;
-	metainfo_len +=3D strlen(signature) + 1;
-
-	info =3D l_malloc(sizeof(*info) + metainfo_len);
-	info->flags =3D flags;
-	info->name_len =3D strlen(name);
-
-	p =3D stpcpy(info->metainfo, name) + 1;
-	strcpy(p, signature);
-
-	l_queue_push_tail(interface->properties, info);
+	interface->properties =3D properties;
 =

 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_ro_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name, 0, signature);
-}
-
-LIB_EXPORT bool l_dbus_interface_rw_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name,
-					L_DBUS_PROPERTY_FLAG_WRITABLE,
-					signature);
-}
-
 struct l_dbus_interface *_dbus_interface_new(const char *name)
 {
 	struct l_dbus_interface *interface;
 =

 	interface =3D l_malloc(sizeof(*interface) + strlen(name) + 1);
 =

-	interface->properties =3D l_queue_new();
-
 	strcpy(interface->name, name);
 =

 	return interface;
@@ -271,8 +227,6 @@ struct l_dbus_interface *_dbus_interface_new(const char=
 *name)
 =

 void _dbus_interface_free(struct l_dbus_interface *interface)
 {
-	l_queue_destroy(interface->properties, l_free);
-
 	l_free(interface);
 }
 =

@@ -302,21 +256,17 @@ const struct l_dbus_signal *_dbus_interface_find_sign=
al(struct l_dbus_interface
 	return NULL;
 }
 =

-static bool match_property(const void *a, const void *b)
+const struct l_dbus_property *_dbus_interface_find_property(struct l_dbus_=
interface *i,
+							const char *property)
 {
-	const struct _dbus_property *property =3D a;
-	const char *name =3D b;
-
-	if (!strcmp(property->metainfo, name))
-		return true;
+	const struct l_dbus_property *p;
 =

-	return false;
-}
+	for (p =3D i->properties; p && p->name; p++) {
+		if (!strcmp(p->name, property))
+			return p;
+	}
 =

-struct _dbus_property *_dbus_interface_find_property(struct l_dbus_interfa=
ce *i,
-							const char *property)
-{
-	return l_queue_find(i->properties, match_property, (char *) property);
+	return NULL;
 }
 =

 static void interface_instance_free(struct interface_instance *instance)
@@ -491,7 +441,7 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
 				const struct l_dbus_signal *signals,
-				void (*setup_func)(struct l_dbus_interface *),
+				const struct l_dbus_property *properties,
 				void *user_data, void (*destroy) (void *))
 {
 	struct object_node *object;
@@ -530,7 +480,7 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 		dbi =3D _dbus_interface_new(interface);
 		dbi->methods =3D methods;
 		dbi->signals =3D signals;
-		setup_func(dbi);
+		dbi->properties =3D properties;
 		l_hashmap_insert(tree->interfaces, dbi->name, dbi);
 	}
 =

@@ -696,7 +646,7 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_dbus=
 *dbus,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
 				const struct l_dbus_signal *signals,
-				l_dbus_interface_setup_func_t setup_func,
+				const struct l_dbus_property *properties,
 				void *user_data,
 				l_dbus_destroy_func_t destroy)
 {
@@ -709,9 +659,9 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_dbus=
 *dbus,
 	if (unlikely(!tree))
 		return false;
 =

-	return _dbus_object_tree_register(tree, path, interface,
-						methods, signals,
-						setup_func, user_data, destroy);
+	return _dbus_object_tree_register(tree, path, interface, methods,
+							signals, properties,
+							user_data, destroy);
 }
 =

 LIB_EXPORT bool l_dbus_unregister_interface(struct l_dbus *dbus,
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 880e27c..1a210f0 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -49,7 +49,6 @@ enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_WRITABLE	=3D 2,
 };
 =

-typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface *);
 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *message,
 						void *user_data);
@@ -73,6 +72,12 @@ struct l_dbus_signal {
 	const struct l_dbus_argument *args;
 };
 =

+struct l_dbus_property {
+	const char *name;
+	const char *type;
+	enum l_dbus_property_flag flags;
+};
+
 #define L_DBUS_ARGS(args...) (const struct l_dbus_argument[]) { args, { } }
 =

 #define L_DBUS_METHOD(_name, _in_args, _out_args, _cb) \
@@ -118,27 +123,37 @@ struct l_dbus_signal {
 	.args =3D _args, \
 	.flags =3D L_DBUS_SIGNAL_FLAG_DEPRECATED
 =

+#define L_DBUS_RO_PROPERTY(_name, _type) \
+	.name =3D _name, \
+	.type =3D _type
+
+#define L_DBUS_RW_PROPERTY(_name, _type) \
+	.name =3D _name, \
+	.type =3D _type, \
+	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE
+
+#define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type) \
+	.name =3D _name, \
+	.type =3D _type, \
+	.flags =3D L_DBUS_PROPERTY_FLAG_DEPRECATED
+
+#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type) \
+	.name =3D _name, \
+	.type =3D _type, \
+	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE | \
+			L_DBUS_PROPERTY_FLAG_DEPRECATED
+
 bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
 				const struct l_dbus_signal *signals,
-				l_dbus_interface_setup_func_t setup_func,
+				const struct l_dbus_property *properties,
 				void *user_data,
 				l_dbus_destroy_func_t destroy);
 =

 bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
 					const char *interface);
 =

-bool l_dbus_interface_property(struct l_dbus_interface *interface,
-				const char *name, uint32_t flags,
-				const char *signature);
-bool l_dbus_interface_ro_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
-bool l_dbus_interface_rw_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
-
 #ifdef __cplusplus
 }
 #endif
-- =

2.0.4


--===============8658994146046306115==--

