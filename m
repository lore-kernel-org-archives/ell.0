Content-Type: multipart/mixed; boundary="===============2605773572352485922=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] dbus: Separate interface registration from instantiation
Date: Fri, 05 Feb 2016 03:58:29 +0100
Message-ID: <1454641114-3421-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2605773572352485922==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Currently l_dbus_register_interface performs three related actions:
 * if needed, creates a new object node in the dbus object tree
 * if needed, sets up internal structs for the new interface
 * adds the interface to the object

With this patch these are three spearate calls, although the first
is still performed automatically by l_dbus_add_interface if
l_dbus_register_object wasn't called first.  This is in preparation for
ObjectManager support.  With this the setup_func parameter and new
interface parameters don't need to be passed every time an interface is
instiated, only when it's being registered/created.

Note that while the client doesn't need to call l_dbus_register_object,
they still need to call l_dbus_unregister_object to free the object
because it's not freed automatically when the last interface gets
removed.  But they can skip the l_dbus_remove_interface calls
because the interfaces will be removed either way.
---
 ell/dbus-private.h       |  22 +++++-
 ell/dbus-service.c       | 185 +++++++++++++++++++++++++++++++++++--------=
----
 ell/dbus.c               | 147 +++++++++++++++++++++++++++++++++++--
 ell/dbus.h               |  19 +++--
 examples/dbus-service.c  |  13 +++-
 unit/test-dbus-service.c |  15 ++--
 unit/test-kdbus.c        |   9 ++-
 7 files changed, 336 insertions(+), 74 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index e60d09e..3eb3847 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -169,11 +169,25 @@ struct object_node *_dbus_object_tree_lookup(struct _=
dbus_object_tree *tree,
 						const char *path);
 void _dbus_object_tree_prune_node(struct object_node *node);
 =

-bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
-				const char *path, const char *interface,
+struct object_node *_dbus_object_tree_new_object(struct _dbus_object_tree =
*tree,
+						const char *path,
+						void *user_data,
+						void (*destroy) (void *));
+bool _dbus_object_tree_object_destroy(struct _dbus_object_tree *tree,
+						const char *path);
+
+bool _dbus_object_tree_register_interface(struct _dbus_object_tree *tree,
+				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
-				void *user_data, void (*destroy) (void *));
-bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
+				void (*destroy) (void *),
+				bool old_style_properties);
+bool _dbus_object_tree_unregister_interface(struct _dbus_object_tree *tree,
+						const char *interface);
+
+bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
+					const char *path, const char *interface,
+					void *user_data);
+bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 					const char *path,
 					const char *interface);
 =

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 772e7a7..2ec2df9 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -72,6 +72,8 @@ struct l_dbus_interface {
 	struct l_queue *methods;
 	struct l_queue *signals;
 	struct l_queue *properties;
+	bool handle_old_style_properties;
+	void (*instance_destroy)(void *);
 	char name[];
 };
 =

@@ -84,13 +86,14 @@ struct child_node {
 struct interface_instance {
 	struct l_dbus_interface *interface;
 	void *user_data;
-	void (*user_destroy) (void *);
 };
 =

 struct object_node {
 	struct object_node *parent;
 	struct l_queue *instances;
 	struct child_node *children;
+	void *user_data;
+	void (*destroy) (void *);
 };
 =

 struct _dbus_object_tree {
@@ -489,8 +492,8 @@ struct _dbus_property *_dbus_interface_find_property(st=
ruct l_dbus_interface *i,
 =

 static void interface_instance_free(struct interface_instance *instance)
 {
-	if (instance->user_destroy)
-		instance->user_destroy(instance->user_data);
+	if (instance->interface->instance_destroy)
+		instance->interface->instance_destroy(instance->user_data);
 =

 	l_free(instance);
 }
@@ -539,6 +542,9 @@ static void subtree_free(struct object_node *node)
 	l_queue_destroy(node->instances,
 			(l_queue_destroy_func_t) interface_instance_free);
 =

+	if (node->destroy)
+		node->destroy(node->user_data);
+
 	l_free(node);
 }
 =

@@ -658,69 +664,164 @@ void _dbus_object_tree_prune_node(struct object_node=
 *node)
 	}
 }
 =

-bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
-				const char *path, const char *interface,
+struct object_node *_dbus_object_tree_new_object(struct _dbus_object_tree =
*tree,
+						const char *path,
+						void *user_data,
+						void (*destroy) (void *))
+{
+	struct object_node *node;
+
+	if (!_dbus_valid_object_path(path))
+		return NULL;
+
+	if (l_hashmap_lookup(tree->objects, path))
+		return NULL;
+
+	node =3D _dbus_object_tree_makepath(tree, path);
+	node->user_data =3D user_data;
+	node->destroy =3D destroy;
+	node->instances =3D l_queue_new();
+
+	l_hashmap_insert(tree->objects, path, node);
+
+	return node;
+}
+
+bool _dbus_object_tree_object_destroy(struct _dbus_object_tree *tree,
+					const char *path)
+{
+	struct object_node *node;
+
+	node =3D l_hashmap_remove(tree->objects, path);
+	if (!node)
+		return false;
+
+	l_queue_destroy(node->instances,
+			(l_queue_destroy_func_t) interface_instance_free);
+	node->instances =3D NULL;
+
+	if (node->destroy) {
+		node->destroy(node->user_data);
+		node->destroy =3D NULL;
+	}
+
+	if (!node->children)
+		_dbus_object_tree_prune_node(node);
+
+	return true;
+}
+
+bool _dbus_object_tree_register_interface(struct _dbus_object_tree *tree,
+				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
-				void *user_data, void (*destroy) (void *))
+				void (*destroy) (void *),
+				bool old_style_properties)
 {
-	struct object_node *object;
 	struct l_dbus_interface *dbi;
-	const struct l_queue_entry *entry;
-	struct interface_instance *instance;
 =

 	if (!_dbus_valid_interface(interface))
 		return false;
 =

-	if (!_dbus_valid_object_path(path))
+	/*
+	 * Check to make sure we do not have this interface already
+	 * registered
+	 */
+	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
+	if (dbi)
+		return false;
+
+	dbi =3D _dbus_interface_new(interface);
+	dbi->instance_destroy =3D destroy;
+	dbi->handle_old_style_properties =3D old_style_properties;
+
+	setup_func(dbi);
+
+	l_hashmap_insert(tree->interfaces, dbi->name, dbi);
+
+	return true;
+}
+
+struct interface_check {
+	struct _dbus_object_tree *tree;
+	const char *interface;
+};
+
+static void check_interface_used(const void *key, void *value, void *user_=
data)
+{
+	const char *path =3D key;
+	struct object_node *node =3D value;
+	struct interface_check *state =3D user_data;
+
+	if (!l_queue_find(node->instances, match_interface_instance,
+				(char *) state->interface))
+		return;
+
+	_dbus_object_tree_remove_interface(state->tree, path, state->interface);
+}
+
+bool _dbus_object_tree_unregister_interface(struct _dbus_object_tree *tree,
+						const char *interface_name)
+{
+	struct l_dbus_interface *interface;
+	struct interface_check state =3D { tree, interface_name };
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+	if (!interface)
+		return false;
+
+	/* Check that the interface is not in use */
+	l_hashmap_foreach(tree->objects, check_interface_used, &state);
+
+	l_hashmap_remove(tree->interfaces, interface_name);
+
+	_dbus_interface_free(interface);
+
+	return true;
+}
+
+bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
+					const char *path, const char *interface,
+					void *user_data)
+{
+	struct object_node *object;
+	struct l_dbus_interface *dbi;
+	struct interface_instance *instance;
+
+	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
+	if (!dbi)
 		return false;
 =

 	object =3D l_hashmap_lookup(tree->objects, path);
 	if (!object) {
-		object =3D _dbus_object_tree_makepath(tree, path);
-		l_hashmap_insert(tree->objects, path, object);
+		object =3D _dbus_object_tree_new_object(tree, path, NULL, NULL);
+
+		if (!object)
+			return false;
 	}
 =

 	/*
 	 * Check to make sure we do not have this interface already
 	 * registered for this object
 	 */
-	entry =3D l_queue_get_entries(object->instances);
-	while (entry) {
-		instance =3D entry->data;
-
-		if (!strcmp(instance->interface->name, interface))
-			return false;
-
-		entry =3D entry->next;
-	}
-
-	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
-	if (!dbi) {
-		dbi =3D _dbus_interface_new(interface);
-		setup_func(dbi);
-		l_hashmap_insert(tree->interfaces, dbi->name, dbi);
-	}
+	if (l_queue_find(object->instances, match_interface_instance,
+				(char *) interface))
+		return false;
 =

 	instance =3D l_new(struct interface_instance, 1);
 	instance->interface =3D dbi;
-	instance->user_destroy =3D destroy;
 	instance->user_data =3D user_data;
 =

-	if (!object->instances)
-		object->instances =3D l_queue_new();
-
 	l_queue_push_tail(object->instances, instance);
 =

 	return true;
 }
 =

-bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
+bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 					const char *path,
 					const char *interface)
 {
 	struct object_node *node;
 	struct interface_instance *instance;
-	bool r;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
 	if (!node)
@@ -728,20 +829,12 @@ bool _dbus_object_tree_unregister(struct _dbus_object=
_tree *tree,
 =

 	instance =3D l_queue_remove_if(node->instances,
 			match_interface_instance, (char *) interface);
+	if (!instance)
+		return false;
 =

-	r =3D instance ? true : false;
-
-	if (instance)
-		interface_instance_free(instance);
-
-	if (l_queue_isempty(node->instances)) {
-		l_hashmap_remove(tree->objects, path);
+	interface_instance_free(instance);
 =

-		if (!node->children)
-			_dbus_object_tree_prune_node(node);
-	}
-
-	return r;
+	return true;
 }
 =

 static void generate_interface_instance(void *data, void *user)
diff --git a/ell/dbus.c b/ell/dbus.c
index 1d9aed5..d825414 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1214,11 +1214,28 @@ int _dbus_get_fd(struct l_dbus *dbus)
 	return l_io_get_fd(dbus->io);
 }
 =

+/**
+ * l_dbus_register_interface:
+ * @dbus: D-Bus connection as returned by @l_dbus_new*
+ * @interface: interface name string
+ * @setup_func: function that sets up the methods, signals and properties =
by
+ *              using the #dbus-service.h API.
+ * @destroy: optional destructor to be called every time an instance of th=
is
+ *           interface is being removed from an object on this bus.
+ * @handle_old_style_properties: whether to automatically handle SetProper=
ty and
+ *                               GetProperties for any properties register=
ed by
+ *                               @setup_func.
+ *
+ * Registers an interface.  If successful the interface can then be added
+ * to any number of objects with @l_dbus_object_add_interface.
+ *
+ * Returns: whether the interface was successfully registered
+ **/
 LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
-				const char *path, const char *interface,
+				const char *interface,
 				l_dbus_interface_setup_func_t setup_func,
-				void *user_data,
-				l_dbus_destroy_func_t destroy)
+				l_dbus_destroy_func_t destroy,
+				bool handle_old_style_properties)
 {
 	if (unlikely(!dbus))
 		return false;
@@ -1226,12 +1243,12 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_=
dbus *dbus,
 	if (unlikely(!dbus->tree))
 		return false;
 =

-	return _dbus_object_tree_register(dbus->tree, path, interface,
-						setup_func, user_data, destroy);
+	return _dbus_object_tree_register_interface(dbus->tree, interface,
+						setup_func, destroy,
+						handle_old_style_properties);
 }
 =

 LIB_EXPORT bool l_dbus_unregister_interface(struct l_dbus *dbus,
-						const char *path,
 						const char *interface)
 {
 	if (unlikely(!dbus))
@@ -1240,7 +1257,123 @@ LIB_EXPORT bool l_dbus_unregister_interface(struct =
l_dbus *dbus,
 	if (unlikely(!dbus->tree))
 		return false;
 =

-	return _dbus_object_tree_unregister(dbus->tree, path, interface);
+	return _dbus_object_tree_unregister_interface(dbus->tree, interface);
+}
+
+/**
+ * l_dbus_register_object:
+ * @dbus: D-Bus connection
+ * @path: new object path
+ * @user_data: user pointer to be passed to @destroy if any
+ * @destroy: optional destructor to be called when object dropped from the=
 tree
+ * @...: NULL-terminated list of 0 or more interfaces to be present on the
+ *       object from the moment of creation.  For every interface the inte=
rface
+ *       name string is expected followed by the @user_data pointer same as
+ *       would be passed as @l_dbus_object_add_interface's last two parame=
ters.
+ *
+ * Create a new D-Bus object on the tree visible to D-Bus peers.  For exam=
ple:
+ * 	success =3D l_dbus_register_object(bus, "/org/example/ExampleManager",
+ * 						NULL, NULL,
+ * 						"org.example.Manager",
+ * 						manager_data,
+ * 						NULL);
+ *
+ * Returns: whether the object path was successfully registered
+ **/
+LIB_EXPORT bool l_dbus_register_object(struct l_dbus *dbus, const char *pa=
th,
+					void *user_data,
+					l_dbus_destroy_func_t destroy, ...)
+{
+	va_list args;
+	const char *interface;
+	void *if_user_data;
+	bool r =3D true;;
+
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	if (!_dbus_object_tree_new_object(dbus->tree, path, user_data, destroy))
+		return false;
+
+	va_start(args, destroy);
+	while ((interface =3D va_arg(args, const char *))) {
+		if_user_data =3D va_arg(args, void *);
+
+		if (!_dbus_object_tree_add_interface(dbus->tree, path,
+							interface,
+							if_user_data)) {
+			_dbus_object_tree_object_destroy(dbus->tree, path);
+			r =3D false;
+
+			break;
+		}
+	}
+	va_end(args);
+
+	return r;
+}
+
+LIB_EXPORT bool l_dbus_unregister_object(struct l_dbus *dbus,
+						const char *object)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_object_destroy(dbus->tree, object);
+}
+
+/**
+ * l_dbus_object_add_interface:
+ * @dbus: D-Bus connection
+ * @object: object path as passed to @l_dbus_register_object
+ * @interface: interface name as passed to @l_dbus_register_interface
+ * @user_data: user data pointer to be passed to any method and property
+ *             callbacks provided by the @setup_func and to the @destroy
+ *             callback as passed to @l_dbus_register_interface
+ *
+ * Creates an instance of given interface at the given path in the
+ * connection's object tree.  If no object was registered at this path
+ * before @l_dbus_register_object gets called automatically.
+ *
+ * The addition of an interface to the object may trigger a query of
+ * all the properties on this interface and
+ * #org.freedesktop.DBus.ObjectManager.InterfacesAdded signals.
+ *
+ * Returns: whether the interface was successfully added.
+ **/
+LIB_EXPORT bool l_dbus_object_add_interface(struct l_dbus *dbus,
+						const char *object,
+						const char *interface,
+						void *user_data)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_add_interface(dbus->tree, object, interface,
+						user_data);
+}
+
+LIB_EXPORT bool l_dbus_object_remove_interface(struct l_dbus *dbus,
+						const char *object,
+						const char *interface)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_remove_interface(dbus->tree, object,
+							interface);
 }
 =

 void _dbus1_filter_format_match(struct dbus1_filter_data *data, char *rule,
diff --git a/ell/dbus.h b/ell/dbus.h
index 39f926b..011d59a 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -191,13 +191,22 @@ bool l_dbus_message_builder_leave_variant(
 struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder);
 =

-bool l_dbus_register_interface(struct l_dbus *dbus,
-				const char *path, const char *interface,
+bool l_dbus_register_interface(struct l_dbus *dbus, const char *interface,
 				l_dbus_interface_setup_func_t setup_func,
-				void *user_data,
-				l_dbus_destroy_func_t destroy);
-bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
+				l_dbus_destroy_func_t destroy,
+				bool handle_old_style_properties);
+bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *interfac=
e);
+
+bool l_dbus_register_object(struct l_dbus *dbus, const char *path,
+				void *user_data, l_dbus_destroy_func_t destroy,
+				...);
+bool l_dbus_unregister_object(struct l_dbus *dbus, const char *object);
+
+bool l_dbus_object_add_interface(struct l_dbus *dbus, const char *object,
+					const char *interface, void *user_data);
+bool l_dbus_object_remove_interface(struct l_dbus *dbus, const char *objec=
t,
 					const char *interface);
+
 unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
 					const char *name,
 					l_dbus_watch_func_t disconnect_func,
diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 2620a96..5b8b086 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -305,17 +305,22 @@ int main(int argc, char *argv[])
 	test->string =3D l_strdup("Default");
 	test->integer =3D 42;
 =

-	if (!l_dbus_register_interface(dbus, "/test", "org.test",
-					setup_test_interface, test,
-					test_data_destroy)) {
+	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
+					test_data_destroy, false)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
 		goto cleanup;
 	}
 =

+	if (!l_dbus_object_add_interface(dbus, "/test", "org.test", test)) {
+		l_info("Unable to instantiate interface");
+		test_data_destroy(test);
+		goto cleanup;
+	}
+
 	l_main_run();
 =

-	l_dbus_unregister_interface(dbus, "/test", "org.test");
+	l_dbus_unregister_object(dbus, "/test");
 =

 cleanup:
 	l_dbus_destroy(dbus);
diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index ea91b87..2438e68 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -276,9 +276,10 @@ static void test_dbus_object_tree_introspection(const =
void *test_data)
 =

 	tree =3D _dbus_object_tree_new();
 =

-	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
-					NULL, NULL);
+	_dbus_object_tree_register_interface(tree, "org.ofono.Manager",
+						build_manager_interface,
+						NULL, false);
+	_dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager", NULL);
 =

 	_dbus_object_tree_makepath(tree, "/phonesim");
 =

@@ -298,9 +299,11 @@ static void test_dbus_object_tree_dispatch(const void =
*test_data)
 =

 	tree =3D _dbus_object_tree_new();
 =

-	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
-					dummy_data, NULL);
+	_dbus_object_tree_register_interface(tree, "org.ofono.Manager",
+						build_manager_interface,
+						NULL, false);
+	_dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager",
+					dummy_data);
 =

 	message =3D _dbus_message_new_method_call(1, "org.ofono", "/",
 						"org.ofono.Manager",
diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 4bf41bb..3a6af3e 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -158,12 +158,17 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(service, service_ready_callback,
 					service, NULL);
 =

-	if (!l_dbus_register_interface(service, "/test", "org.test",
-					setup_test_interface, NULL, NULL)) {
+	if (!l_dbus_register_interface(service, "org.test",
+					setup_test_interface, NULL, false)) {
 		l_info("Unable to register interface");
 		goto error;
 	}
 =

+	if (!l_dbus_object_add_interface(service, "/test", "org.test", NULL)) {
+		l_info("Unable to instantiate interface");
+		goto error;
+	}
+
 	client =3D l_dbus_new(bus_address);
 	assert(client);
 =

-- =

2.5.0


--===============2605773572352485922==--

