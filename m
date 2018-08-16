Content-Type: multipart/mixed; boundary="===============0124963427612997631=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] dbus: Split get_managed_objects and expose in
 dbus-private.h
Date: Thu, 16 Aug 2018 04:04:31 +0200
Message-ID: <20180816020432.11506-2-andrew.zaborowski@intel.com>
In-Reply-To: <20180816020432.11506-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0124963427612997631==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Split the main logic in get_managed_objects out into
_dbus_object_tree_get_objects and expose that in dbus-private.h so it
can be used and/or tested in the unit tests.
---
 ell/dbus-private.h |  5 +++++
 ell/dbus-service.c | 21 +++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index eb8e4ab..799c743 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -225,6 +225,11 @@ void _dbus_object_tree_introspect(struct _dbus_object_=
tree *tree,
 bool _dbus_object_tree_dispatch(struct _dbus_object_tree *tree,
 					struct l_dbus *dbus,
 					struct l_dbus_message *message);
+struct l_dbus_message *_dbus_object_tree_get_objects(
+					struct _dbus_object_tree *tree,
+					struct l_dbus *dbus,
+					const char *path,
+					struct l_dbus_message *message);
 =

 bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index cf787bc..edc46cd 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1990,17 +1990,16 @@ recurse:
 	return true;
 }
 =

-static struct l_dbus_message *get_managed_objects(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
+struct l_dbus_message *_dbus_object_tree_get_objects(
+						struct _dbus_object_tree *tree,
+						struct l_dbus *dbus,
+						const char *path,
+						struct l_dbus_message *message)
 {
-	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 	const struct object_node *node;
 	struct l_dbus_message *reply;
 	struct l_dbus_message_builder *builder;
-	const char *path;
 =

-	path =3D l_dbus_message_get_path(message);
 	node =3D l_hashmap_lookup(tree->objects, path);
 =

 	reply =3D l_dbus_message_new_method_return(message);
@@ -2027,6 +2026,16 @@ static struct l_dbus_message *get_managed_objects(st=
ruct l_dbus *dbus,
 	return reply;
 }
 =

+static struct l_dbus_message *get_managed_objects(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	const char *path =3D l_dbus_message_get_path(message);
+
+	return _dbus_object_tree_get_objects(tree, dbus, path, message);
+}
+
 static void object_manager_setup_func(struct l_dbus_interface *interface)
 {
 	l_dbus_interface_method(interface, "GetManagedObjects", 0,
-- =

2.14.1


--===============0124963427612997631==--

