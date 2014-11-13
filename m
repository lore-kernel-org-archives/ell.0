Content-Type: multipart/mixed; boundary="===============8648641743471046134=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 04/21] dbus: Refactor the interface API so it uses constants
 methods array
Date: Thu, 13 Nov 2014 12:36:08 +0200
Message-ID: <1415874985-13034-5-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8648641743471046134==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This makes ELL DBus interface API more in line with what exists in
GDBus. The only drawback is when processing incoming message: the
signature comparison is slightly slower since it does not compare it at
once. This will need to be fixed if that proves to be an issue.
---
 ell/dbus-private.h |  15 +++--
 ell/dbus-service.c | 190 ++++++++++++++++++-------------------------------=
----
 ell/dbus-service.h |  57 ++++++++++++++--
 3 files changed, 126 insertions(+), 136 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index a34f444..0fe5946 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -58,7 +58,8 @@ struct dbus_header {
 struct dbus_builder;
 struct l_string;
 struct l_dbus_interface;
-struct _dbus_method;
+struct l_dbus_argument;
+struct l_dbus_method;
 struct _dbus_signal;
 struct _dbus_property;
 struct l_dbus_message_iter;
@@ -141,8 +142,10 @@ bool _dbus_valid_bus_name(const char *bus_name);
 =

 bool _dbus_header_is_valid(void *data, size_t size);
 =

-void _dbus_method_introspection(struct _dbus_method *info,
-					struct l_string *buf);
+void _dbus_print_arguments(const struct l_dbus_argument *args,
+				const char *direction, struct l_string *buf);
+void _dbus_method_introspection(const struct l_dbus_method *info,
+						struct l_string *buf);
 void _dbus_signal_introspection(struct _dbus_signal *info,
 					struct l_string *buf);
 void _dbus_property_introspection(struct _dbus_property *info,
@@ -153,7 +156,10 @@ void _dbus_interface_introspection(struct l_dbus_inter=
face *interface,
 struct l_dbus_interface *_dbus_interface_new(const char *interface);
 void _dbus_interface_free(struct l_dbus_interface *interface);
 =

-struct _dbus_method *_dbus_interface_find_method(struct l_dbus_interface *=
i,
+bool _dbus_interface_methods(struct l_dbus_interface *interface,
+				const struct l_dbus_method *methods);
+
+const struct l_dbus_method *_dbus_interface_find_method(struct l_dbus_inte=
rface *i,
 							const char *method);
 struct _dbus_signal *_dbus_interface_find_signal(struct l_dbus_interface *=
i,
 							const char *signal);
@@ -171,6 +177,7 @@ void _dbus_object_tree_prune_node(struct object_node *n=
ode);
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
+				const struct l_dbus_method *methods,
 				void (*setup_func)(struct l_dbus_interface *),
 				void *user_data, void (*destroy) (void *));
 bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index a38de64..6f2eee7 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -47,13 +47,6 @@ static const char *static_introspectable =3D
 		"\t\t\t<arg name=3D\"xml\" type=3D\"s\" direction=3D\"out\"/>\n"
 		"\t\t</method>\n\t</interface>\n";
 =

-struct _dbus_method {
-	l_dbus_interface_method_cb_t cb;
-	uint32_t flags;
-	unsigned char name_len;
-	char metainfo[];
-};
-
 struct _dbus_signal {
 	uint32_t flags;
 	unsigned char name_len;
@@ -67,7 +60,7 @@ struct _dbus_property {
 };
 =

 struct l_dbus_interface {
-	struct l_queue *methods;
+	const struct l_dbus_method *methods;
 	struct l_queue *signals;
 	struct l_queue *properties;
 	char name[];
@@ -97,44 +90,29 @@ struct _dbus_object_tree {
 	struct object_node *root;
 };
 =

-void _dbus_method_introspection(struct _dbus_method *info,
-					struct l_string *buf)
-{
-	const char *sig;
-	const char *end;
-	const char *pname;
-	unsigned int offset =3D info->name_len + 1;
-
-	l_string_append_printf(buf, "\t\t<method name=3D\"%s\">\n",
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
-					"type=3D\"%.*s\" direction=3D\"in\"/>\n",
-					pname, (int) (end - sig + 1), sig);
-		sig =3D end;
-		offset +=3D strlen(pname) + 1;
+void _dbus_print_arguments(const struct l_dbus_argument *args,
+				const char *direction, struct l_string *buf)
+{
+	for (; args && args->name; args++) {
+		l_string_append_printf(buf,
+					"\t\t\t<arg name=3D\"%s\" type=3D\"%s\"",
+					 args->name, args->signature);
+		if (direction)
+			l_string_append_printf(buf,
+						" direction=3D\"%s\"/>\n",
+						direction);
+		else
+			l_string_append_printf(buf, "/>\n");
 	}
+}
 =

-	sig =3D info->metainfo + offset;
-	offset +=3D strlen(sig) + 1;
+void _dbus_method_introspection(const struct l_dbus_method *info,
+						struct l_string *buf)
+{
+	l_string_append_printf(buf, "\t\t<method name=3D\"%s\">\n", info->name);
 =

-	for (; *sig; sig++) {
-		end =3D _dbus_signature_end(sig);
-		pname =3D info->metainfo + offset;
-
-		l_string_append_printf(buf, "\t\t\t<arg name=3D\"%s\" "
-					"type=3D\"%.*s\" direction=3D\"out\"/>\n",
-					pname, (int) (end - sig + 1), sig);
-		sig =3D end;
-		offset +=3D strlen(pname) + 1;
-	}
+	_dbus_print_arguments(info->in_args, "in", buf);
+	_dbus_print_arguments(info->out_args, "out", buf);
 =

 	if (info->flags & L_DBUS_METHOD_FLAG_DEPRECATED)
 		l_string_append(buf, "\t\t\t<annotation name=3D\""
@@ -209,11 +187,13 @@ void _dbus_property_introspection(struct _dbus_proper=
ty *info,
 void _dbus_interface_introspection(struct l_dbus_interface *interface,
 						struct l_string *buf)
 {
+	const struct l_dbus_method *method;
+
 	l_string_append_printf(buf, "\t<interface name=3D\"%s\">\n",
 				interface->name);
 =

-	l_queue_foreach(interface->methods,
-		(l_queue_foreach_func_t) _dbus_method_introspection, buf);
+	for (method =3D interface->methods; method && method->name; method++)
+		_dbus_method_introspection(method, buf);
 	l_queue_foreach(interface->signals,
 		(l_queue_foreach_func_t) _dbus_signal_introspection, buf);
 	l_queue_foreach(interface->properties,
@@ -256,74 +236,18 @@ static bool size_params(const char *signature, va_lis=
t args, unsigned int *len)
 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_method(struct l_dbus_interface *interface,
-					const char *name, uint32_t flags,
-					l_dbus_interface_method_cb_t cb,
-					const char *return_sig,
-					const char *param_sig, ...)
+bool _dbus_interface_methods(struct l_dbus_interface *interface,
+					const struct l_dbus_method *methods)
 {
-	va_list args;
-	unsigned int return_info_len;
-	unsigned int param_info_len;
-	struct _dbus_method *info;
-	char *p;
-
-	if (!_dbus_valid_method(name))
-		return false;
-
-	if (unlikely(!return_sig || !param_sig))
-		return false;
-
-	if (return_sig[0] && !_dbus_valid_signature(return_sig))
+	if (unlikely(!interface))
 		return false;
 =

-	if (param_sig[0] && !_dbus_valid_signature(param_sig))
+	if (unlikely(!methods))
 		return false;
 =

-	/* Pre-calculate the needed meta-info length */
-	return_info_len =3D strlen(return_sig) + 1;
-	param_info_len =3D strlen(param_sig) + 1;
-
-	va_start(args, param_sig);
-
-	if (!size_params(return_sig, args, &return_info_len))
-		goto error;
-
-	if (!size_params(param_sig, args, &param_info_len))
-		goto error;
-
-	va_end(args);
-
-	info =3D l_malloc(sizeof(*info) + return_info_len +
-					param_info_len + strlen(name) + 1);
-	info->cb =3D cb;
-	info->flags =3D flags;
-	info->name_len =3D strlen(name);
-	strcpy(info->metainfo, name);
-
-	va_start(args, param_sig);
-
-	/*
-	 * We store param signature + parameter names first, to speed up
-	 * lookups during the message dispatch procedures.
-	 */
-	p =3D info->metainfo + info->name_len + param_info_len + 1;
-	p =3D stpcpy(p, return_sig) + 1;
-	p =3D copy_params(p, return_sig, args);
-
-	p =3D info->metainfo + info->name_len + 1;
-	p =3D stpcpy(p, param_sig) + 1;
-	p =3D copy_params(p, param_sig, args);
-
-	va_end(args);
-
-	l_queue_push_tail(interface->methods, info);
+	interface->methods =3D methods;
 =

 	return true;
-
-error:
-	va_end(args);
-	return false;
 }
 =

 LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_interface *interface,
@@ -428,7 +352,6 @@ struct l_dbus_interface *_dbus_interface_new(const char=
 *name)
 =

 	interface =3D l_malloc(sizeof(*interface) + strlen(name) + 1);
 =

-	interface->methods =3D l_queue_new();
 	interface->signals =3D l_queue_new();
 	interface->properties =3D l_queue_new();
 =

@@ -439,28 +362,23 @@ struct l_dbus_interface *_dbus_interface_new(const ch=
ar *name)
 =

 void _dbus_interface_free(struct l_dbus_interface *interface)
 {
-	l_queue_destroy(interface->methods, l_free);
 	l_queue_destroy(interface->signals, l_free);
 	l_queue_destroy(interface->properties, l_free);
 =

 	l_free(interface);
 }
 =

-static bool match_method(const void *a, const void *b)
+const struct l_dbus_method *_dbus_interface_find_method(struct l_dbus_inte=
rface *i,
+							const char *method)
 {
-	const struct _dbus_method *method =3D a;
-	const char *name =3D b;
-
-	if (!strcmp(method->metainfo, name))
-		return true;
+	const struct l_dbus_method *m;
 =

-	return false;
-}
+	for (m =3D i->methods; m && m->name; m++) {
+		if (!strcmp(m->name, method))
+			return m;
+	}
 =

-struct _dbus_method *_dbus_interface_find_method(struct l_dbus_interface *=
i,
-							const char *method)
-{
-	return l_queue_find(i->methods, match_method, (char *) method);
+	return NULL;
 }
 =

 static bool match_signal(const void *a, const void *b)
@@ -667,6 +585,7 @@ void _dbus_object_tree_prune_node(struct object_node *n=
ode)
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
+				const struct l_dbus_method *methods,
 				void (*setup_func)(struct l_dbus_interface *),
 				void *user_data, void (*destroy) (void *))
 {
@@ -704,6 +623,7 @@ bool _dbus_object_tree_register(struct _dbus_object_tre=
e *tree,
 	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
 	if (!dbi) {
 		dbi =3D _dbus_interface_new(interface);
+		dbi->methods =3D methods;
 		setup_func(dbi);
 		l_hashmap_insert(tree->interfaces, dbi->name, dbi);
 	}
@@ -783,6 +703,26 @@ void _dbus_object_tree_introspect(struct _dbus_object_=
tree *tree,
 	l_string_append(buf, "</node>\n");
 }
 =

+static bool compare_signature(const struct l_dbus_argument *args,
+						const char *sig)
+{
+	const char *p =3D NULL;
+
+	for (; args && args->signature && *sig; args++) {
+		p =3D args->signature;
+
+		for (; *sig && *p; sig++, p++) {
+			if (*p !=3D *sig)
+				return false;
+		}
+	}
+
+	if (*sig || (p && *p) || (args && args->signature))
+		return false;
+
+	return true;
+}
+
 bool _dbus_object_tree_dispatch(struct _dbus_object_tree *tree,
 					struct l_dbus *dbus,
 					struct l_dbus_message *message)
@@ -791,10 +731,9 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tr=
ee *tree,
 	const char *interface;
 	const char *member;
 	const char *msg_sig;
-	const char *sig;
 	struct object_node *node;
 	struct interface_instance *instance;
-	struct _dbus_method *method;
+	const struct l_dbus_method *method;
 	struct l_dbus_message *reply;
 =

 	path =3D l_dbus_message_get_path(message);
@@ -837,9 +776,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 	if (!method)
 		return false;
 =

-	sig =3D method->metainfo + method->name_len + 1;
-
-	if (strcmp(msg_sig, sig))
+	if (!compare_signature(method->in_args, msg_sig))
 		return false;
 =

 	reply =3D method->cb(dbus, message, instance->user_data);
@@ -851,6 +788,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 =

 LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
+				const struct l_dbus_method *methods,
 				l_dbus_interface_setup_func_t setup_func,
 				void *user_data,
 				l_dbus_destroy_func_t destroy)
@@ -864,7 +802,7 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_dbus=
 *dbus,
 	if (unlikely(!tree))
 		return false;
 =

-	return _dbus_object_tree_register(tree, path, interface,
+	return _dbus_object_tree_register(tree, path, interface, methods,
 						setup_func, user_data, destroy);
 }
 =

diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 6071740..f3dceae 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -54,8 +54,59 @@ typedef struct l_dbus_message *(*l_dbus_interface_method=
_cb_t) (struct l_dbus *,
 						struct l_dbus_message *message,
 						void *user_data);
 =

+struct l_dbus_argument {
+	const char *name;
+	const char *signature;
+};
+
+struct l_dbus_method {
+	const char *name;
+	l_dbus_interface_method_cb_t cb;
+	enum l_dbus_method_flag flags;
+	const struct l_dbus_argument *in_args;
+	const struct l_dbus_argument *out_args;
+};
+
+#define L_DBUS_ARGS(args...) (const struct l_dbus_argument[]) { args, { } }
+
+#define L_DBUS_METHOD(_name, _in_args, _out_args, _cb) \
+	.name =3D _name, \
+	.in_args =3D _in_args, \
+	.out_args =3D _out_args, \
+	.cb =3D _cb
+
+#define L_DBUS_DEPRECATED_METHOD(_name, _in_args, _out_args, _cb) \
+	.name =3D _name, \
+	.in_args =3D _in_args, \
+	.out_args =3D _out_args, \
+	.cb =3D _cb, \
+	.flags =3D L_DBUS_METHOD_FLAG_DEPRECATED
+
+#define L_DBUS_NOREPLY_METHOD(_name, _in_args, _out_args, _cb) \
+	.name =3D _name, \
+	.in_args =3D _in_args, \
+	.out_args =3D _out_args, \
+	.cb =3D _cb, \
+	.flags =3D L_DBUS_METHOD_FLAG_NOREPLY
+
+#define L_DBUS_ASYNC_METHOD(_name, _in_args, _out_args, _cb) \
+	.name =3D _name, \
+	.in_args =3D _in_args, \
+	.out_args =3D _out_args, \
+	.cb =3D _cb, \
+	.flags =3D L_DBUS_METHOD_FLAG_ASYNC
+
+#define L_DBUS_DEPRECATED_ASYNC_METHOD(_name, _in_args, _out_args, _cb) \
+	.name =3D _name, \
+	.in_args =3D _in_args, \
+	.out_args =3D _out_args, \
+	.cb =3D _cb, \
+	.flags =3D L_DBUS_METHOD_FLAG_DEPRECATED | L_DBUS_METHOD_FLAG_ASYNC
+
+
 bool l_dbus_register_interface(struct l_dbus *dbus,
 				const char *path, const char *interface,
+				const struct l_dbus_method *methods,
 				l_dbus_interface_setup_func_t setup_func,
 				void *user_data,
 				l_dbus_destroy_func_t destroy);
@@ -63,12 +114,6 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
 bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
 					const char *interface);
 =

-bool l_dbus_interface_method(struct l_dbus_interface *interface,
-				const char *name, uint32_t flags,
-				l_dbus_interface_method_cb_t cb,
-				const char *return_sig, const char *param_sig,
-				...);
-
 bool l_dbus_interface_signal(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
 				const char *signature, ...);
-- =

2.0.4


--===============8648641743471046134==--

