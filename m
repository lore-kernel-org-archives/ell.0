Content-Type: multipart/mixed; boundary="===============5875327869687866588=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/8] dbus: More complete checks when removing nodes.
Date: Mon, 01 Feb 2016 15:07:17 +0100
Message-ID: <1454335644-17088-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5875327869687866588==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This addresses two problems with nodes being freed from the object tree
but not from tree->objects.

With the current semantics for _dbus_object_tree_prune_node to not
incorrectly remove parent nodes that are still in tree->objects it
would be sufficient to check if the node has any interface instances
left. But with the ongoing ObjectManager it's better to directly check
the path against tree->objects.
---
 ell/dbus-private.h |  4 ++-
 ell/dbus-service.c | 72 ++++++++++++++++++++++++++++++++++++++++----------=
----
 2 files changed, 56 insertions(+), 20 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index e60d09e..a0ddb35 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -167,7 +167,9 @@ struct object_node *_dbus_object_tree_makepath(struct _=
dbus_object_tree *tree,
 						const char *path);
 struct object_node *_dbus_object_tree_lookup(struct _dbus_object_tree *tre=
e,
 						const char *path);
-void _dbus_object_tree_prune_node(struct object_node *node);
+bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
+					struct object_node *node,
+					const char *path);
 =

 bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
 				const char *path, const char *interface,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index e082226..9380740 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -636,33 +636,65 @@ struct object_node *_dbus_object_tree_lookup(struct _=
dbus_object_tree *tree,
 	return lookup_recurse(tree->root, path);
 }
 =

-void _dbus_object_tree_prune_node(struct object_node *node)
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
+	if (node->children || !node->parent)
+		return true;
 =

-	while (parent) {
-		for (c =3D parent->children, p =3D NULL; c; p =3D c, c =3D c->next) {
-			if (c->node !=3D node)
-				continue;
+	/*
+	 * Walk up the tree until a node that either has more than one
+	 * child, is the root or is in the objects hashmap.
+	 */
+	strcpy(parentpath, path);
 =

-			if (p)
-				p->next =3D c->next;
-			else
-				parent->children =3D c->next;
+	while (true) {
+		parent =3D node->parent;
 =

-			subtree_free(c->node);
-			l_free(c);
+		if (parent =3D=3D tree->root)
+			break;
 =

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
@@ -741,9 +773,11 @@ bool _dbus_object_tree_unregister(struct _dbus_object_=
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
+			_dbus_object_tree_prune_node(tree, node, path);
 	}
 =

 	return r;
-- =

2.5.0


--===============5875327869687866588==--

