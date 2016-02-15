Content-Type: multipart/mixed; boundary="===============5767042587865393306=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/10] dbus: Send InterfacesRemoved on object unregister
Date: Mon, 15 Feb 2016 17:44:14 +0100
Message-ID: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5767042587865393306==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure we call _dbus_object_tree_remove_interface to do all the
necessary steps of interface removal when an object from the tree
together with its interfaces.
---
 ell/dbus-service.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 1e3bb66..53e2512 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -733,13 +733,24 @@ bool _dbus_object_tree_object_destroy(struct _dbus_ob=
ject_tree *tree,
 					const char *path)
 {
 	struct object_node *node;
+	const struct l_queue_entry *entry;
+	const struct interface_instance *instance;
 =

-	node =3D l_hashmap_remove(tree->objects, path);
+	node =3D l_hashmap_lookup(tree->objects, path);
 	if (!node)
 		return false;
 =

-	l_queue_destroy(node->instances,
-			(l_queue_destroy_func_t) interface_instance_free);
+	while ((entry =3D l_queue_get_entries(node->instances))) {
+		instance =3D entry->data;
+
+		if (!_dbus_object_tree_remove_interface(tree, path,
+						instance->interface->name))
+			return false;
+	}
+
+	l_hashmap_remove(tree->objects, path);
+
+	l_queue_destroy(node->instances, NULL);
 	node->instances =3D NULL;
 =

 	if (node->destroy) {
-- =

2.5.0


--===============5767042587865393306==--

