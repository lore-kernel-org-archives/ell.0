Content-Type: multipart/mixed; boundary="===============3339359671561856441=="
MIME-Version: 1.0
From: Arseny Maslennikov <ar@cs.msu.ru>
Subject: [PATCH] dbus: emit DBus.Introspectable for real objects only
Date: Mon, 19 Apr 2021 10:11:19 +0300
Message-ID: <20210419071119.117008-1-ar@cs.msu.ru>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3339359671561856441==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Arseny Maslennikov <arseny@altlinux.org>

In a similar vein to GDBus, we now explicitly declare
org.freedesktop.DBus.Introspectable in the introspection output for
registered objects only, not for every node. This removes clutter from
introspection trees.

For example, if a service exports the following object paths on the bus:
* /org/freedesktop/LogControl1
* /org/bluez
* /org/bluez/hci0
then /org is now described in the introspection output as a node
containing two subnodes "bluez" and "freedesktop" and no interface
elements.
Inspection tools like d-feet only list the objects themselves, while
before this change they would uselessly list:
* /
* /org
* /org/bluez
* /org/bluez/hci0
* /org/freedesktop
* /org/freedesktop/LogControl1

We still conform to the spec by responding to
org.freedesktop.DBus.Introspectable.Introspect calls on every node =E2=80=
=94 we
just don't advertise the interface in the xml response.
---
 ell/dbus-service.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 84fca3a..94afc14 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1709,16 +1709,28 @@ void _dbus_object_tree_introspect(struct _dbus_obje=
ct_tree *tree,
 {
 	struct object_node *node;
 	struct child_node *child;
+	bool path_is_object =3D true;
 =

 	node =3D l_hashmap_lookup(tree->objects, path);
-	if (!node)
+	if (!node) {
+		path_is_object =3D false;
 		node =3D _dbus_object_tree_lookup(tree, path);
+	}
 =

 	l_string_append(buf, XML_HEAD);
 	l_string_append(buf, "<node>\n");
 =

 	if (node) {
-		l_string_append(buf, static_introspectable);
+		/* We emit org.freedesktop.DBus.Introspectable only in case the
+		 * object node corresponds to a registered object, i. e.
+		 * exposes anything other than:
+		 * - org.freedesktop.DBus.Introspectable
+		 * - org.freedesktop.DBus.Peer
+		 * - org.freedesktop.DBus.Properties
+		 */
+		if (path_is_object)
+			l_string_append(buf, static_introspectable);
+
 		l_queue_foreach(node->instances,
 					generate_interface_instance, buf);
 =

-- =

2.31.0

--===============3339359671561856441==--

