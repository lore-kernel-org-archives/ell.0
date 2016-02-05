Content-Type: multipart/mixed; boundary="===============7423402209686202449=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/8] dbus: More complete checks when removing nodes.
Date: Fri, 05 Feb 2016 03:58:27 +0100
Message-ID: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7423402209686202449==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This addresses two problems with nodes being freed from the object tree
but not from tree->objects.
---
 ell/dbus-service.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index e082226..639872b 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -660,6 +660,9 @@ void _dbus_object_tree_prune_node(struct object_node *n=
ode)
 		if (parent->children !=3D NULL)
 			return;
 =

+		if (parent->instances)
+			return;
+
 		node =3D parent;
 		parent =3D node->parent;
 	}
@@ -741,9 +744,11 @@ bool _dbus_object_tree_unregister(struct _dbus_object_=
tree *tree,
 	if (instance)
 		interface_instance_free(instance);
 =

-	if (l_queue_isempty(node->instances) && !node->children) {
+	if (l_queue_isempty(node->instances)) {
 		l_hashmap_remove(tree->objects, path);
-		_dbus_object_tree_prune_node(node);
+
+		if (!node->children)
+			_dbus_object_tree_prune_node(node);
 	}
 =

 	return r;
-- =

2.5.0


--===============7423402209686202449==--

