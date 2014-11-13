Content-Type: multipart/mixed; boundary="===============6807555224097161859=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 07/21] dbus: Refactor the interface API so it uses constant
 signals array
Date: Thu, 13 Nov 2014 12:36:11 +0200
Message-ID: <1415874985-13034-8-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6807555224097161859==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This makes ELL DBus interface API more in line with what exists in
GDBus.
---
 ell/dbus-private.h |  11 ++--
 ell/dbus-service.c | 144 ++++++++++---------------------------------------=
----
 ell/dbus-service.h |  19 +++++--
 3 files changed, 48 insertions(+), 126 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 0fe5946..5248dd6 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -60,7 +60,7 @@ struct l_string;
 struct l_dbus_interface;
 struct l_dbus_argument;
 struct l_dbus_method;
-struct _dbus_signal;
+struct l_dbus_signal;
 struct _dbus_property;
 struct l_dbus_message_iter;
 struct l_dbus_message;
@@ -146,8 +146,8 @@ void _dbus_print_arguments(const struct l_dbus_argument=
 *args,
 				const char *direction, struct l_string *buf);
 void _dbus_method_introspection(const struct l_dbus_method *info,
 						struct l_string *buf);
-void _dbus_signal_introspection(struct _dbus_signal *info,
-					struct l_string *buf);
+void _dbus_signal_introspection(const struct l_dbus_signal *info,
+						struct l_string *buf);
 void _dbus_property_introspection(struct _dbus_property *info,
 						struct l_string *buf);
 void _dbus_interface_introspection(struct l_dbus_interface *interface,
@@ -158,10 +158,12 @@ void _dbus_interface_free(struct l_dbus_interface *in=
terface);
 =

 bool _dbus_interface_methods(struct l_dbus_interface *interface,
 				const struct l_dbus_method *methods);
+bool _dbus_interface_signals(struct l_dbus_interface *interface,
+				const struct l_dbus_signal *signals);
 =

 const struct l_dbus_method *_dbus_interface_find_method(struct l_dbus_inte=
rface *i,
 							const char *method);
-struct _dbus_signal *_dbus_interface_find_signal(struct l_dbus_interface *=
i,
+const struct l_dbus_signal *_dbus_interface_find_signal(struct l_dbus_inte=
rface *i,
 							const char *signal);
 struct _dbus_property *_dbus_interface_find_property(struct l_dbus_interfa=
ce *i,
 						const char *property);
@@ -178,6 +180,7 @@ void _dbus_object_tree_prune_node(struct object_node *n=
ode);
 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
+				const struct l_dbus_signal *signals,
 				void (*setup_func)(struct l_dbus_interface *),
 				void *user_data, void (*destroy) (void *));
 bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 6f2eee7..8996407 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -47,12 +47,6 @@ static const char *static_introspectable =3D
 		"\t\t\t<arg name=3D\"xml\" type=3D\"s\" direction=3D\"out\"/>\n"
 		"\t\t</method>\n\t</interface>\n";
 =

-struct _dbus_signal {
-	uint32_t flags;
-	unsigned char name_len;
-	char metainfo[];
-};
-
 struct _dbus_property {
 	uint32_t flags;
 	unsigned char name_len;
@@ -61,7 +55,7 @@ struct _dbus_property {
 =

 struct l_dbus_interface {
 	const struct l_dbus_method *methods;
-	struct l_queue *signals;
+	const struct l_dbus_signal *signals;
 	struct l_queue *properties;
 	char name[];
 };
@@ -127,30 +121,12 @@ void _dbus_method_introspection(const struct l_dbus_m=
ethod *info,
 	l_string_append(buf, "\t\t</method>\n");
 }
 =

-void _dbus_signal_introspection(struct _dbus_signal *info,
-					struct l_string *buf)
+void _dbus_signal_introspection(const struct l_dbus_signal *info,
+						struct l_string *buf)
 {
-	const char *sig;
-	const char *end;
-	const char *pname;
-	unsigned int offset =3D info->name_len + 1;
+	l_string_append_printf(buf, "\t\t<signal name=3D\"%s\">\n", info->name);
 =

-	l_string_append_printf(buf, "\t\t<signal name=3D\"%s\">\n",
-				info->metainfo);
-
-	sig =3D info->metainfo + offset;
-	offset +=3D strlen(sig) + 1;
-
-	for (; *sig; sig++) {
-		end =3D _dbus_signature_end(sig);
-		pname =3D info->metainfo + offset;
-
-		l_string_append_printf(buf, "\t\t\t<arg name=3D\"%s\" "
-					"type=3D\"%.*s\"/>\n",
-					pname, (int) (end - sig + 1), sig);
-		sig =3D end;
-		offset +=3D strlen(pname) + 1;
-	}
+	_dbus_print_arguments(info->args, NULL, buf);
 =

 	if (info->flags & L_DBUS_SIGNAL_FLAG_DEPRECATED)
 		l_string_append(buf, "\t\t\t<annotation name=3D\""
@@ -188,54 +164,21 @@ void _dbus_interface_introspection(struct l_dbus_inte=
rface *interface,
 						struct l_string *buf)
 {
 	const struct l_dbus_method *method;
+	const struct l_dbus_signal *signal;
 =

 	l_string_append_printf(buf, "\t<interface name=3D\"%s\">\n",
 				interface->name);
 =

 	for (method =3D interface->methods; method && method->name; method++)
 		_dbus_method_introspection(method, buf);
-	l_queue_foreach(interface->signals,
-		(l_queue_foreach_func_t) _dbus_signal_introspection, buf);
+	for (signal =3D interface->signals; signal && signal->name; signal++)
+		_dbus_signal_introspection(signal, buf);
 	l_queue_foreach(interface->properties,
 		(l_queue_foreach_func_t) _dbus_property_introspection, buf);
 =

 	l_string_append(buf, "\t</interface>\n");
 }
 =

-static char *copy_params(char *dest, const char *signature, va_list args)
-{
-	const char *pname;
-	const char *sig;
-
-	for (sig =3D signature; *sig; sig++) {
-		sig =3D _dbus_signature_end(sig);
-		if (!sig)
-			return NULL;
-
-		pname =3D va_arg(args, const char *);
-		dest =3D stpcpy(dest, pname) + 1;
-	}
-
-	return dest;
-}
-
-static bool size_params(const char *signature, va_list args, unsigned int =
*len)
-{
-	const char *pname;
-	const char *sig;
-
-	for (sig =3D signature; *sig; sig++) {
-		sig =3D _dbus_signature_end(sig);
-		if (!sig)
-			return false;
-
-		pname =3D va_arg(args, const char *);
-		*len +=3D strlen(pname) + 1;
-	}
-
-	return true;
-}
-
 bool _dbus_interface_methods(struct l_dbus_interface *interface,
 					const struct l_dbus_method *methods)
 {
@@ -250,49 +193,16 @@ bool _dbus_interface_methods(struct l_dbus_interface =
*interface,
 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_interface *interface,
-					const char *name, uint32_t flags,
-					const char *signature, ...)
+bool _dbus_interface_signals(struct l_dbus_interface *interface,
+					const struct l_dbus_signal *signals)
 {
-	va_list args;
-	unsigned int metainfo_len;
-	struct _dbus_signal *info;
-	char *p;
-
-	if (!_dbus_valid_method(name))
-		return false;
-
-	if (unlikely(!signature))
-		return false;
-
-	if (signature[0] && !_dbus_valid_signature(signature))
+	if (unlikely(!interface))
 		return false;
 =

-	/* Pre-calculate the needed meta-info length */
-	metainfo_len =3D strlen(name) + 1;
-	metainfo_len +=3D strlen(signature) + 1;
-
-	va_start(args, signature);
-
-	if (!size_params(signature, args, &metainfo_len)) {
-		va_end(args);
+	if (unlikely(!signals))
 		return false;
-	}
 =

-	va_end(args);
-
-	info =3D l_malloc(sizeof(*info) + metainfo_len);
-	info->flags =3D flags;
-	info->name_len =3D strlen(name);
-
-	p =3D stpcpy(info->metainfo, name) + 1;
-
-	va_start(args, signature);
-	p =3D stpcpy(p, signature) + 1;
-	p =3D copy_params(p, signature, args);
-	va_end(args);
-
-	l_queue_push_tail(interface->signals, info);
+	interface->signals =3D signals;
 =

 	return true;
 }
@@ -352,7 +262,6 @@ struct l_dbus_interface *_dbus_interface_new(const char=
 *name)
 =

 	interface =3D l_malloc(sizeof(*interface) + strlen(name) + 1);
 =

-	interface->signals =3D l_queue_new();
 	interface->properties =3D l_queue_new();
 =

 	strcpy(interface->name, name);
@@ -362,7 +271,6 @@ struct l_dbus_interface *_dbus_interface_new(const char=
 *name)
 =

 void _dbus_interface_free(struct l_dbus_interface *interface)
 {
-	l_queue_destroy(interface->signals, l_free);
 	l_queue_destroy(interface->properties, l_free);
 =

 	l_free(interface);
@@ -381,21 +289,17 @@ const struct l_dbus_method *_dbus_interface_find_meth=
od(struct l_dbus_interface
 	return NULL;
 }
 =

-static bool match_signal(const void *a, const void *b)
+const struct l_dbus_signal *_dbus_interface_find_signal(struct l_dbus_inte=
rface *i,
+							const char *signal)
 {
-	const struct _dbus_signal *signal =3D a;
-	const char *name =3D b;
+	const struct l_dbus_signal *s;
 =

-	if (!strcmp(signal->metainfo, name))
-		return true;
-
-	return false;
-}
+	for (s =3D i->signals; s && s->name; s++) {
+		if (!strcmp(s->name, signal))
+			return s;
+	}
 =

-struct _dbus_signal *_dbus_interface_find_signal(struct l_dbus_interface *=
i,
-							const char *signal)
-{
-	return l_queue_find(i->signals, match_signal, (char *) signal);
+	return NULL;
 }
 =

 static bool match_property(const void *a, const void *b)
@@ -586,6 +490,7 @@ void _dbus_object_tree_prune_node(struct object_node *n=
ode)
 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
+				const struct l_dbus_signal *signals,
 				void (*setup_func)(struct l_dbus_interface *),
 				void *user_data, void (*destroy) (void *))
 {
@@ -624,6 +529,7 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 	if (!dbi) {
 		dbi =3D _dbus_interface_new(interface);
 		dbi->methods =3D methods;
+		dbi->signals =3D signals;
 		setup_func(dbi);
 		l_hashmap_insert(tree->interfaces, dbi->name, dbi);
 	}
@@ -789,6 +695,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
+				const struct l_dbus_signal *signals,
 				l_dbus_interface_setup_func_t setup_func,
 				void *user_data,
 				l_dbus_destroy_func_t destroy)
@@ -802,7 +709,8 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_dbus=
 *dbus,
 	if (unlikely(!tree))
 		return false;
 =

-	return _dbus_object_tree_register(tree, path, interface, methods,
+	return _dbus_object_tree_register(tree, path, interface,
+						methods, signals,
 						setup_func, user_data, destroy);
 }
 =

diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index f3dceae..880e27c 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -67,6 +67,12 @@ struct l_dbus_method {
 	const struct l_dbus_argument *out_args;
 };
 =

+struct l_dbus_signal {
+	const char *name;
+	enum l_dbus_signal_flag flags;
+	const struct l_dbus_argument *args;
+};
+
 #define L_DBUS_ARGS(args...) (const struct l_dbus_argument[]) { args, { } }
 =

 #define L_DBUS_METHOD(_name, _in_args, _out_args, _cb) \
@@ -103,10 +109,19 @@ struct l_dbus_method {
 	.cb =3D _cb, \
 	.flags =3D L_DBUS_METHOD_FLAG_DEPRECATED | L_DBUS_METHOD_FLAG_ASYNC
 =

+#define L_DBUS_SIGNAL(_name, _args) \
+	.name =3D _name, \
+	.args =3D _args
+
+#define L_DBUS_DEPRECATED_SIGNAL(_name, _args) \
+	.name =3D _name, \
+	.args =3D _args, \
+	.flags =3D L_DBUS_SIGNAL_FLAG_DEPRECATED
 =

 bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
 				const struct l_dbus_method *methods,
+				const struct l_dbus_signal *signals,
 				l_dbus_interface_setup_func_t setup_func,
 				void *user_data,
 				l_dbus_destroy_func_t destroy);
@@ -114,10 +129,6 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
 bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
 					const char *interface);
 =

-bool l_dbus_interface_signal(struct l_dbus_interface *interface,
-				const char *name, uint32_t flags,
-				const char *signature, ...);
-
 bool l_dbus_interface_property(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
 				const char *signature);
-- =

2.0.4


--===============6807555224097161859==--

