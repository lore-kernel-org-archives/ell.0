Content-Type: multipart/mixed; boundary="===============6527099901732404866=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Emit InterfacesAdded on new ObjectManager addition
Date: Tue, 21 Aug 2018 05:12:54 +0200
Message-ID: <20180821031254.31527-2-andrew.zaborowski@intel.com>
In-Reply-To: <20180821031254.31527-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6527099901732404866==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When an Object Manager interface is added to the tree emit
InterfaceAdded signals for all the now-managed objects that may have
existed already.

This way clients that register the Object Manager in the dbus ready
callback will have no issues with InterfacesAdded signals missing if
other interfaces have been registered and added before the callback.
---
 ell/dbus-service.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 4e70b7b..3ad6c7e 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1410,6 +1410,43 @@ bool _dbus_object_tree_unregister_interface(struct _=
dbus_object_tree *tree,
 	return true;
 }
 =

+static void collect_instances(struct object_node *node,
+				const char *path,
+				struct l_queue *announce)
+{
+	const struct l_queue_entry *entry;
+	struct interface_add_record *change_rec;
+	const struct child_node *child;
+
+	if (!node->instances)
+		goto recurse;
+
+	change_rec =3D l_new(struct interface_add_record, 1);
+	change_rec->path =3D l_strdup(path);
+	change_rec->object =3D node;
+	change_rec->instances =3D l_queue_new();
+
+	for (entry =3D l_queue_get_entries(node->instances); entry;
+			entry =3D entry->next)
+		l_queue_push_tail(change_rec->instances, entry->data);
+
+	l_queue_push_tail(announce, change_rec);
+
+recurse:
+	if (!strcmp(path, "/"))
+		path =3D "";
+
+	for (child =3D node->children; child; child =3D child->next) {
+		char *child_path;
+
+		child_path =3D l_strdup_printf("%s/%s", path, child->subpath);
+
+		collect_instances(child->node, child_path, announce);
+
+		l_free(child_path);
+	}
+}
+
 static bool match_interfaces_added_object(const void *a, const void *b)
 {
 	const struct interface_add_record *rec =3D a;
@@ -1498,6 +1535,12 @@ bool _dbus_object_tree_add_interface(struct _dbus_ob=
ject_tree *tree,
 		manager->announce_removed =3D l_queue_new();
 =

 		l_queue_push_tail(tree->object_managers, manager);
+
+		/* Emit InterfacesAdded for interfaces added before OM */
+		collect_instances(object, path, manager->announce_added);
+
+		if (manager->dbus && !l_queue_isempty(manager->announce_added))
+			schedule_emit_signals(manager->dbus);
 	}
 =

 	return true;
-- =

2.14.1


--===============6527099901732404866==--

