Content-Type: multipart/mixed; boundary="===============6886968898481985244=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Add l_dbus_object_get_data
Date: Sat, 24 Aug 2019 02:53:36 +0200
Message-ID: <20190824005337.24469-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6886968898481985244==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This function can be used by DBus method implementations that receive
an object path as a parameter to directly look up the user_data by the
path and interface name.
---
 ell/dbus-private.h |  3 +++
 ell/dbus-service.c | 19 +++++++++++++++++++
 ell/dbus.c         | 13 +++++++++++++
 ell/dbus.h         |  2 ++
 ell/ell.sym        |  1 +
 5 files changed, 38 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 799c743..be62691 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -219,6 +219,9 @@ bool _dbus_object_tree_add_interface(struct _dbus_objec=
t_tree *tree,
 bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 					const char *path,
 					const char *interface);
+void *_dbus_object_tree_get_interface_data(struct _dbus_object_tree *tree,
+						const char *path,
+						const char *interface);
 =

 void _dbus_object_tree_introspect(struct _dbus_object_tree *tree,
 					const char *path, struct l_string *buf);
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 531b710..a1a7a74 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1556,6 +1556,25 @@ bool _dbus_object_tree_add_interface(struct _dbus_ob=
ject_tree *tree,
 	return true;
 }
 =

+void *_dbus_object_tree_get_interface_data(struct _dbus_object_tree *tree,
+						const char *path,
+						const char *interface)
+{
+	struct object_node *object;
+	struct interface_instance *instance;
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return NULL;
+
+	instance =3D l_queue_find(object->instances, match_interface_instance,
+				(char *) interface);
+	if (!instance)
+		return NULL;
+
+	return instance->user_data;
+}
+
 static bool match_object_manager_path(const void *a, const void *b)
 {
 	const struct object_manager *manager =3D a;
diff --git a/ell/dbus.c b/ell/dbus.c
index b11225f..fb44b86 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1585,6 +1585,19 @@ LIB_EXPORT bool l_dbus_object_remove_interface(struc=
t l_dbus *dbus,
 							interface);
 }
 =

+LIB_EXPORT void *l_dbus_object_get_data(struct l_dbus *dbus, const char *o=
bject,
+					const char *interface)
+{
+	if (unlikely(!dbus))
+		return false;
+
+	if (unlikely(!dbus->tree))
+		return false;
+
+	return _dbus_object_tree_get_interface_data(dbus->tree, object,
+							interface);
+}
+
 LIB_EXPORT bool l_dbus_object_manager_enable(struct l_dbus *dbus)
 {
 	if (unlikely(!dbus))
diff --git a/ell/dbus.h b/ell/dbus.h
index d3af5d7..212c60e 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -239,6 +239,8 @@ bool l_dbus_object_add_interface(struct l_dbus *dbus, c=
onst char *object,
 					const char *interface, void *user_data);
 bool l_dbus_object_remove_interface(struct l_dbus *dbus, const char *objec=
t,
 					const char *interface);
+void *l_dbus_object_get_data(struct l_dbus *dbus, const char *object,
+				const char *interface);
 =

 bool l_dbus_object_manager_enable(struct l_dbus *dbus);
 =

diff --git a/ell/ell.sym b/ell/ell.sym
index 0d6422f..d54a874 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -210,6 +210,7 @@ global:
 	l_dbus_unregister_object;
 	l_dbus_object_add_interface;
 	l_dbus_object_remove_interface;
+	l_dbus_object_get_data;
 	l_dbus_object_manager_enable;
 	l_dbus_add_disconnect_watch;
 	l_dbus_add_service_watch;
-- =

2.20.1


--===============6886968898481985244==--

