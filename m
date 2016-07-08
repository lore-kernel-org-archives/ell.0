Content-Type: multipart/mixed; boundary="===============4222359114137417246=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] dbus-service: Allow property setters to return errors
Date: Fri, 08 Jul 2016 17:55:16 +0200
Message-ID: <1467993318-11918-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4222359114137417246==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow the property setter functions to synchronously return a message
pointer if they need to return an error.  On success complete still
needs to be called because the NULL return value couls also mean that
the setter will complete asynchronously.
---
 ell/dbus-service.c | 21 +++++++++++++++------
 ell/dbus-service.h |  2 +-
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 44baaaf..deffc07 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1180,6 +1180,7 @@ static struct l_dbus_message *old_set_property(struct=
 l_dbus *dbus,
 	const struct _dbus_property *property;
 	struct l_dbus_message_iter variant;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	struct l_dbus_message *reply;
 =

 	interface =3D l_hashmap_lookup(tree->interfaces,
 					l_dbus_message_get_interface(message));
@@ -1207,10 +1208,13 @@ static struct l_dbus_message *old_set_property(stru=
ct l_dbus *dbus,
 						"Property %s is read-only",
 						property_name);
 =

-	property->setter(dbus, l_dbus_message_ref(message), &variant,
-				set_property_complete, user_data);
+	reply =3D property->setter(dbus, l_dbus_message_ref(message), &variant,
+					set_property_complete, user_data);
 =

-	return NULL;
+	if (reply)
+		l_dbus_message_unref(message);
+
+	return reply;
 }
 =

 static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
@@ -1729,6 +1733,7 @@ static struct l_dbus_message *properties_set(struct l=
_dbus *dbus,
 	struct l_dbus_message_iter variant;
 	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
 	const struct object_node *object;
+	struct l_dbus_message *reply;
 =

 	if (!l_dbus_message_get_arguments(message, "ssv", &interface_name,
 						&property_name, &variant))
@@ -1774,10 +1779,14 @@ static struct l_dbus_message *properties_set(struct=
 l_dbus *dbus,
 						"Object has no interface %s",
 						interface_name);
 =

-	property->setter(dbus, l_dbus_message_ref(message), &variant,
-				properties_set_complete, instance->user_data);
+	reply =3D property->setter(dbus, l_dbus_message_ref(message), &variant,
+					properties_set_complete,
+					instance->user_data);
 =

-	return NULL;
+	if (reply)
+		l_dbus_message_unref(message);
+
+	return reply;
 }
 =

 static struct l_dbus_message *properties_get_all(struct l_dbus *dbus,
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 2243b99..153bb3a 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -56,7 +56,7 @@ typedef void (*l_dbus_property_complete_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *,
 						struct l_dbus_message *error);
 =

-typedef void (*l_dbus_property_set_cb_t) (struct l_dbus *,
+typedef struct l_dbus_message *(*l_dbus_property_set_cb_t) (struct l_dbus =
*,
 					struct l_dbus_message *message,
 					struct l_dbus_message_iter *new_value,
 					l_dbus_property_complete_cb_t complete,
-- =

2.7.4


--===============4222359114137417246==--

