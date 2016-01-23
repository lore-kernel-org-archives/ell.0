Content-Type: multipart/mixed; boundary="===============7478485551253991928=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [RFC PATCH 3/8] dbus: Don't show Introspectable on intermediate nodes
Date: Sat, 23 Jan 2016 03:59:27 +0100
Message-ID: <1453517972-22833-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1453517972-22833-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7478485551253991928==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

org.freedesktop.* service implementations don't seem to report any
interfaces on non-object paths in the tree, neither does bluez.
http://dbus.freedesktop.org/doc/dbus-specification.html#standard-interfaces=
-introspectable
doesn't say much about this so this is up for discussion.
---
 ell/dbus-service.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index d37989e..4324e2e 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -866,25 +866,28 @@ static void generate_interface_instance(void *data, v=
oid *user)
 void _dbus_object_tree_introspect(struct _dbus_object_tree *tree,
 					const char *path, struct l_string *buf)
 {
-	struct object_node *node;
+	struct object_node *node, *object;
 	struct child_node *child;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
+	object =3D node;
 	if (!node)
 		node =3D _dbus_object_tree_lookup(tree, path);
 =

 	l_string_append(buf, XML_HEAD);
 	l_string_append(buf, "<node>\n");
 =

-	if (node) {
+	if (object) {
 		l_string_append(buf, static_introspectable);
+
 		l_queue_foreach(node->instances,
 					generate_interface_instance, buf);
+	}
 =

+	if (node)
 		for (child =3D node->children; child; child =3D child->next)
 			l_string_append_printf(buf, "\t<node name=3D\"%s\"/>\n",
 						child->subpath);
-	}
 =

 	l_string_append(buf, "</node>\n");
 }
-- =

2.5.0


--===============7478485551253991928==--

