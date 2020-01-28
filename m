Content-Type: multipart/mixed; boundary="===============1085999067292503634=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/2] dbus-service: Do not auto-emit property changes
Date: Tue, 28 Jan 2020 14:13:47 -0600
Message-ID: <20200128201348.28916-1-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1085999067292503634==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is a behavioral change to not emit property changes by default
after the set callback 'complete' method is called.  This allows
applications a bit more flexibility in if & when they actually emit the
property changed signal.  Two common scenarios are:

	- The property is set to value 'A' and a D-Bus client requests
	the property to be set to 'A'.  Generally most D-Bus
	applications would want to silently accept such a request and
	not emit a PropertyChanged signal needlessly.  With ell's
	current behavior the signal is emitted regardless.
	- A property 'set' might be set successfully, but its actual
	value is updated via some asynchronous means (perhaps inotify,
	netlink, etc).  So it would be advantageous for applications to
	call the 'complete' callback and have the property changed
	signal be emitted when the relevant async notification arrives.

The implications of this behavior change is that property setter
implementations must manually invoke l_dbus_property_changed whenever
the underlying property value has been updated in order for the relevant
signal to be emitted.  Alternatively, supplying
L_DBUS_PROPERTY_FLAG_AUTO_EMIT flag in l_dbus_interface_property() will
preserve the current behavior.
---
 ell/dbus-service.c | 43 +++++++++++++++++++++++++++++++++++--------
 ell/dbus-service.h |  1 +
 2 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index fb839f9da6a5..e60eafc28221 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1230,9 +1230,10 @@ bool _dbus_object_tree_property_changed(struct l_dbu=
s *dbus,
 	return true;
 }
 =

-static void pending_property_set_done(struct l_dbus *dbus,
+static void pending_property_set_done_common(struct l_dbus *dbus,
 					struct l_dbus_message *message,
-					struct l_dbus_message *reply)
+					struct l_dbus_message *reply,
+					bool auto_emit)
 {
 	const char *member;
 	const char *interface_name;
@@ -1260,7 +1261,8 @@ static void pending_property_set_done(struct l_dbus *=
dbus,
 							&variant))
 		goto done;
 =

-	_dbus_object_tree_property_changed(dbus,
+	if (auto_emit)
+		_dbus_object_tree_property_changed(dbus,
 					l_dbus_message_get_path(message),
 					interface_name, property_name);
 done:
@@ -1268,6 +1270,20 @@ done:
 	l_dbus_message_unref(reply);
 }
 =

+static void pending_property_set_done_emit(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *reply)
+{
+	pending_property_set_done_common(dbus, message, reply, true);
+}
+
+static void pending_property_set_done(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *reply)
+{
+	pending_property_set_done_common(dbus, message, reply, false);
+}
+
 static struct l_dbus_message *old_set_property(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
@@ -1278,6 +1294,7 @@ static struct l_dbus_message *old_set_property(struct=
 l_dbus *dbus,
 	struct l_dbus_message_iter variant;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 	struct l_dbus_message *reply;
+	l_dbus_property_complete_cb_t complete_cb;
 =

 	interface =3D l_hashmap_lookup(tree->interfaces,
 					l_dbus_message_get_interface(message));
@@ -1305,11 +1322,16 @@ static struct l_dbus_message *old_set_property(stru=
ct l_dbus *dbus,
 						"Property %s is read-only",
 						property_name);
 =

+	if (property->flags & L_DBUS_PROPERTY_FLAG_AUTO_EMIT)
+		complete_cb =3D pending_property_set_done_emit;
+	else
+		complete_cb =3D pending_property_set_done;
+
 	reply =3D property->setter(dbus, l_dbus_message_ref(message), &variant,
-					pending_property_set_done, user_data);
+					complete_cb, user_data);
 =

 	if (reply)
-		pending_property_set_done(dbus, message, reply);
+		complete_cb(dbus, message, reply);
 =

 	return NULL;
 }
@@ -1863,6 +1885,7 @@ static struct l_dbus_message *properties_set(struct l=
_dbus *dbus,
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 	const struct object_node *object;
 	struct l_dbus_message *reply;
+	l_dbus_property_complete_cb_t complete_cb;
 =

 	if (!l_dbus_message_get_arguments(message, "ssv", &interface_name,
 						&property_name, &variant))
@@ -1907,12 +1930,16 @@ static struct l_dbus_message *properties_set(struct=
 l_dbus *dbus,
 						"Object has no interface %s",
 						interface_name);
 =

+	if (property->flags & L_DBUS_PROPERTY_FLAG_AUTO_EMIT)
+		complete_cb =3D pending_property_set_done_emit;
+	else
+		complete_cb =3D pending_property_set_done;
+
 	reply =3D property->setter(dbus, l_dbus_message_ref(message), &variant,
-					pending_property_set_done,
-					instance->user_data);
+					complete_cb, instance->user_data);
 =

 	if (reply)
-		pending_property_set_done(dbus, message, reply);
+		complete_cb(dbus, message, reply);
 =

 	return NULL;
 }
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 153bb3a22798..1a150498a703 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -46,6 +46,7 @@ enum l_dbus_signal_flag {
 =

 enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_DEPRECATED =3D 1,
+	L_DBUS_PROPERTY_FLAG_AUTO_EMIT	=3D 2,
 };
 =

 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
-- =

2.21.0

--===============1085999067292503634==--

