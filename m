Content-Type: multipart/mixed; boundary="===============1383846922423156043=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [RFC PATCH 2/8] dbus: Separate interface registration from
 instantiation
Date: Sat, 23 Jan 2016 03:59:26 +0100
Message-ID: <1453517972-22833-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1453517972-22833-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1383846922423156043==
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

One thing that may be unclear is that as a side effect
_dbus_object_tree_prune_node takes not only the reference to the node
being pruned but also to the object tree and a path to the object.  The
latter two are needed because when the function is walking the tree
upwards to free any intermediate nodes that no longer have any
dbus-visible objects in their subtree, the function needs to be able to
check if these nodes are visible on dbus (i.e. are in tree->objects).  I
found that currently if you've got a tree with objects /a and /a/b in
it, and remove all interfaces from /a first, then from /a/b, the
_dbus_object_tree_prune_node call will free /a without removing it from
tree->objects.  The node reference parameter is no longer needed except
for the unit/test-dbus-service to be able to test adding and removing
intermediate nodes from the tree.

Note that while the client doesn't need to call l_dbus_register_object,
they still need to call l_dbus_unregister_object to free the object
because it's not freed automatically when the last interface gets
removed.  But they can skip the l_dbus_remove_interface calls
because the interfaces will be removed either way.
---
 ell/dbus-private.h       |  20 ++++-
 ell/dbus-service.c       | 224 +++++++++++++++++++++++++++++++++++--------=
----
 ell/dbus.c               |  91 +++++++++++++++++--
 ell/dbus.h               |  19 ++--
 examples/dbus-service.c  |  13 ++-
 unit/test-dbus-service.c |  17 ++--
 unit/test-kdbus.c        |   9 +-
 7 files changed, 311 insertions(+), 82 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index e60d09e..fc26aa2 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -167,13 +167,27 @@ struct object_node *_dbus_object_tree_makepath(struct=
 _dbus_object_tree *tree,
 						const char *path);
 struct object_node *_dbus_object_tree_lookup(struct _dbus_object_tree *tre=
e,
 						const char *path);
-void _dbus_object_tree_prune_node(struct object_node *node);
+
+struct object_node *_dbus_object_tree_new_object(struct _dbus_object_tree =
*tree,
+						const char *path,
+						void *user_data,
+						void (*destroy) (void *));
+bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
+					struct object_node *node,
+					const char *path);
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
-				const char *path, const char *interface,
+				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
-				void *user_data, void (*destroy) (void *));
+				void (*destroy) (void *),
+				bool old_style_properties);
 bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
+				const char *interface);
+
+bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
+					const char *path, const char *interface,
+					void *user_data);
+bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 					const char *path,
 					const char *interface);
 =

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 77310c6..d37989e 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -72,6 +72,9 @@ struct l_dbus_interface {
 	struct l_queue *methods;
 	struct l_queue *signals;
 	struct l_queue *properties;
+	bool handle_old_style_properties;
+	void (*setup_func)(struct l_dbus_interface *);
+	void (*instance_destroy)(void *);
 	char name[];
 };
 =

@@ -84,13 +87,14 @@ struct child_node {
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
@@ -489,8 +493,8 @@ struct _dbus_property *_dbus_interface_find_property(st=
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
@@ -539,6 +543,9 @@ static void subtree_free(struct object_node *node)
 	l_queue_destroy(node->instances,
 			(l_queue_destroy_func_t) interface_instance_free);
 =

+	if (node->destroy)
+		node->destroy(node->user_data);
+
 	l_free(node);
 }
 =

@@ -626,81 +633,197 @@ struct object_node *_dbus_object_tree_lookup(struct =
_dbus_object_tree *tree,
 	return lookup_recurse(tree->root, path);
 }
 =

-void _dbus_object_tree_prune_node(struct object_node *node)
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
+
+	l_hashmap_insert(tree->objects, path, node);
+
+	return node;
+}
+
+bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
+					struct object_node *node,
+					const char *path)
 {
-	struct object_node *parent =3D node->parent;
-	struct child_node *p =3D NULL, *c;
+	struct object_node *parent;
+	struct child_node *p, *c;
+	struct interface_instance *instance;
+	char parentpath[strlen(path) + 1];
+
+	if (!node) {
+		node =3D l_hashmap_remove(tree->objects, path);
+		if (!node)
+			return false;
+	}
+
+	while ((instance =3D l_queue_pop_head(node->instances)))
+		interface_instance_free(instance);
+
+	if (node->destroy) {
+		node->destroy(node->user_data);
 =

-	while (parent) {
-		for (c =3D parent->children, p =3D NULL; c; p =3D c, c =3D c->next) {
-			if (c->node !=3D node)
-				continue;
+		node->destroy =3D NULL;
+	}
 =

-			if (p)
-				p->next =3D c->next;
-			else
-				parent->children =3D c->next;
+	if (node->children || !node->parent)
+		return true;
 =

-			subtree_free(c->node);
-			l_free(c);
+	/*
+	 * Walk up the tree until a node that either has more than one
+	 * child, is the root or is in the objects hashmap.
+	 */
+	strcpy(parentpath, path);
 =

+	while (true) {
+		parent =3D node->parent;
+
+		if (parent =3D=3D tree->root)
+			break;
+
+		if (parent->children->next)
 			break;
-		}
 =

-		if (parent->children !=3D NULL)
-			return;
+		/* Parent's path */
+		parentpath[strlen(parentpath) -
+			strlen(parent->children->subpath) - 1] =3D '\0';
+
+		if (l_hashmap_lookup(tree->objects, parentpath))
+			break;
 =

 		node =3D parent;
-		parent =3D node->parent;
 	}
+
+	for (c =3D parent->children, p =3D NULL; c; p =3D c, c =3D c->next)
+		if (c->node =3D=3D node)
+			break;
+
+	if (p)
+		p->next =3D c->next;
+	else
+		parent->children =3D c->next;
+
+	l_free(c);
+	subtree_free(node);
+
+	return true;
 }
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
-				const char *path, const char *interface,
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
+	dbi->setup_func =3D setup_func;
+	dbi->handle_old_style_properties =3D old_style_properties;
+
+	l_hashmap_insert(tree->interfaces, dbi->name, dbi);
+
+	return true;
+}
+
+struct interface_check {
+	const char *interface;
+	bool result;
+};
+
+static void check_interface_used(const void *key, void *value, void *user_=
data)
+{
+	struct object_node *node =3D value;
+	struct interface_check *state =3D user_data;
+
+	if (l_queue_find(node->instances, match_interface_instance,
+				(char *) state->interface))
+		state->result =3D true;
+}
+
+bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
+					const char *interface_name)
+{
+	struct l_dbus_interface *interface;
+	struct interface_check state =3D { interface_name, false };
+
+	interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
+	if (!interface)
+		return false;
+
+	/* Check that the interface is not in use */
+	l_hashmap_foreach(tree->objects, check_interface_used, &state);
+	if (state.result)
+		return false;
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
+	if (l_queue_find(object->instances, match_interface_instance,
+				(char *) interface))
+		return false;
 =

-		entry =3D entry->next;
-	}
+	if (dbi->setup_func) {
+		dbi->setup_func(dbi);
 =

-	dbi =3D l_hashmap_lookup(tree->interfaces, interface);
-	if (!dbi) {
-		dbi =3D _dbus_interface_new(interface);
-		setup_func(dbi);
-		l_hashmap_insert(tree->interfaces, dbi->name, dbi);
+		dbi->setup_func =3D NULL;
 	}
 =

 	instance =3D l_new(struct interface_instance, 1);
 	instance->interface =3D dbi;
-	instance->user_destroy =3D destroy;
 	instance->user_data =3D user_data;
 =

 	if (!object->instances)
@@ -711,13 +834,12 @@ bool _dbus_object_tree_register(struct _dbus_object_t=
ree *tree,
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
@@ -725,18 +847,12 @@ bool _dbus_object_tree_unregister(struct _dbus_object=
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
-	if (l_queue_isempty(node->instances) && !node->children) {
-		l_hashmap_remove(tree->objects, path);
-		_dbus_object_tree_prune_node(node);
-	}
+	interface_instance_free(instance);
 =

-	return r;
+	return true;
 }
 =

 static void generate_interface_instance(void *data, void *user)
diff --git a/ell/dbus.c b/ell/dbus.c
index 1d9aed5..a9bb314 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1215,10 +1215,10 @@ int _dbus_get_fd(struct l_dbus *dbus)
 }
 =

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
@@ -1226,12 +1226,12 @@ LIB_EXPORT bool l_dbus_register_interface(struct l_=
dbus *dbus,
 	if (unlikely(!dbus->tree))
 		return false;
 =

-	return _dbus_object_tree_register(dbus->tree, path, interface,
-						setup_func, user_data, destroy);
+	return _dbus_object_tree_register(dbus->tree, interface,
+						setup_func, destroy,
+						handle_old_style_properties);
 }
 =

 LIB_EXPORT bool l_dbus_unregister_interface(struct l_dbus *dbus,
-						const char *path,
 						const char *interface)
 {
 	if (unlikely(!dbus))
@@ -1240,7 +1240,84 @@ LIB_EXPORT bool l_dbus_unregister_interface(struct l=
_dbus *dbus,
 	if (unlikely(!dbus->tree))
 		return false;
 =

-	return _dbus_object_tree_unregister(dbus->tree, path, interface);
+	return _dbus_object_tree_unregister(dbus->tree, interface);
+}
+
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
+			_dbus_object_tree_prune_node(dbus->tree, NULL, path);
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
+	return _dbus_object_tree_prune_node(dbus->tree, NULL, object);
+}
+
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
index e4e5fa7..488cc47 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -307,17 +307,22 @@ int main(int argc, char *argv[])
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
index d0bf174..16fc00e 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -205,16 +205,16 @@ static void test_dbus_object_tree(const void *test_da=
ta)
 =

 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf3);
+	_dbus_object_tree_prune_node(tree, leaf3, "/foo/bee/boo");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
 	assert(!tmp);
 =

 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf2);
+	_dbus_object_tree_prune_node(tree, leaf2, "/foo/bar/ble");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf1);
+	_dbus_object_tree_prune_node(tree, leaf1, "/foo/bar/baz");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(!tmp);
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo");
@@ -276,9 +276,10 @@ static void test_dbus_object_tree_introspection(const =
void *test_data)
 =

 	tree =3D _dbus_object_tree_new();
 =

-	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
+	_dbus_object_tree_register(tree, "org.ofono.Manager",
 					build_manager_interface,
-					NULL, NULL);
+					NULL, false);
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
+	_dbus_object_tree_register(tree, "org.ofono.Manager",
 					build_manager_interface,
-					dummy_data, NULL);
+					NULL, false);
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


--===============1383846922423156043==--

