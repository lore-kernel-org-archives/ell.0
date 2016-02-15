Content-Type: multipart/mixed; boundary="===============5711425541116875731=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/10] dbus: Error checking in l_dbus_property_changed
Date: Mon, 15 Feb 2016 17:44:15 +0100
Message-ID: <1455554662-15608-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5711425541116875731==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Before adding l_dbus_property_changed, _dbus_object_tree_property_changed
was only used internally and no path/interface/property errors were
possible.  With l_dbus_property_changed they need to be validated.

While there also make sure that we don't call
l_dbus_message_builder_finalize after a getter has returned an error
and may have left the builder state inconsistent since that could
probably cause l_dbus_message_builder_finalize to segfault.  We already
take care to do that everywhere else.
---
 ell/dbus-private.h |  2 +-
 ell/dbus-service.c | 44 ++++++++++++++++++++++++++++----------------
 ell/dbus-service.h |  2 +-
 3 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 1af7201..873396d 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -197,7 +197,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 					struct l_dbus *dbus,
 					struct l_dbus_message *message);
 =

-void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
 					const char *property_name,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 53e2512..afd0ed9 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -765,7 +765,7 @@ bool _dbus_object_tree_object_destroy(struct _dbus_obje=
ct_tree *tree,
 }
 =

 /* Send the signals associated with a property value change */
-void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+bool _dbus_object_tree_property_changed(struct l_dbus *dbus,
 					const char *path,
 					const char *interface_name,
 					const char *property_name,
@@ -782,12 +782,18 @@ void _dbus_object_tree_property_changed(struct l_dbus=
 *dbus,
 	bool r;
 =

 	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return false;
 =

 	instance =3D l_queue_find(object->instances, match_interface_instance,
 				interface_name);
+	if (!instance)
+		return false;
 =

 	property =3D _dbus_interface_find_property(instance->interface,
 							property_name);
+	if (!property)
+		return false;
 =

 	signature =3D property->metainfo + strlen(property->metainfo) + 1;
 =

@@ -811,12 +817,14 @@ void _dbus_object_tree_property_changed(struct l_dbus=
 *dbus,
 						instance->user_data);
 		}
 =

-		l_dbus_message_builder_leave_variant(builder);
+		if (r) {
+			l_dbus_message_builder_leave_variant(builder);
 =

-		l_dbus_message_builder_finalize(builder);
-		l_dbus_message_builder_destroy(builder);
-		if (r)
+			l_dbus_message_builder_finalize(builder);
 			l_dbus_send(dbus, signal);
+		}
+
+		l_dbus_message_builder_destroy(builder);
 	}
 =

 	if (l_queue_find(object->instances, match_interface_instance,
@@ -844,17 +852,21 @@ void _dbus_object_tree_property_changed(struct l_dbus=
 *dbus,
 						instance->user_data);
 		}
 =

-		l_dbus_message_builder_leave_variant(builder);
-		l_dbus_message_builder_leave_dict(builder);
-		l_dbus_message_builder_leave_array(builder);
-		l_dbus_message_builder_enter_array(builder, "s");
-		l_dbus_message_builder_leave_array(builder);
+		if (r) {
+			l_dbus_message_builder_leave_variant(builder);
+			l_dbus_message_builder_leave_dict(builder);
+			l_dbus_message_builder_leave_array(builder);
+			l_dbus_message_builder_enter_array(builder, "s");
+			l_dbus_message_builder_leave_array(builder);
 =

-		l_dbus_message_builder_finalize(builder);
-		l_dbus_message_builder_destroy(builder);
-		if (r)
+			l_dbus_message_builder_finalize(builder);
 			l_dbus_send(dbus, signal);
+		}
+
+		l_dbus_message_builder_destroy(builder);
 	}
+
+	return true;
 }
 =

 static void set_property_complete(struct l_dbus *dbus,
@@ -1340,12 +1352,12 @@ bool _dbus_object_tree_dispatch(struct _dbus_object=
_tree *tree,
 	return true;
 }
 =

-LIB_EXPORT void l_dbus_property_changed(struct l_dbus *dbus, const char *p=
ath,
+LIB_EXPORT bool l_dbus_property_changed(struct l_dbus *dbus, const char *p=
ath,
 					const char *interface,
 					const char *property)
 {
-	_dbus_object_tree_property_changed(dbus, path, interface, property,
-						NULL);
+	return _dbus_object_tree_property_changed(dbus, path, interface,
+							property, NULL);
 }
 =

 static struct l_dbus_message *properties_get(struct l_dbus *dbus,
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 619d9a6..2243b99 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -83,7 +83,7 @@ bool l_dbus_interface_property(struct l_dbus_interface *i=
nterface,
 				l_dbus_property_get_cb_t getter,
 				l_dbus_property_set_cb_t setter);
 =

-void l_dbus_property_changed(struct l_dbus *dbus, const char *path,
+bool l_dbus_property_changed(struct l_dbus *dbus, const char *path,
 				const char *interface, const char *property);
 =

 #ifdef __cplusplus
-- =

2.5.0


--===============5711425541116875731==--

