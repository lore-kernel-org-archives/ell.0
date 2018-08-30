Content-Type: multipart/mixed; boundary="===============7985400704686319877=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2][RFC] dbus: Don't automatically emit PropertyChanged after
 Set
Date: Thu, 30 Aug 2018 03:05:40 +0200
Message-ID: <20180830010541.8687-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7985400704686319877==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Remove the _dbus_object_tree_property_changed call in the complete
handler for property setters so a PropertyChanged/PropertiesChanged
signal is not sent for every successful Set().  This means that the
setter functions will have to emit the signals when the property's value
has changed so it affects ell's clients.  This attempts to allow clients
to solve an issue where PropertyChanged signals were generated even if
Set was called with a value equal to the property's current value so the
values was not effectively chaning.

I'm not 100% convinced this small benefit is worth the added work for
clients.  Another possibilty would be for the setter functions to give
the complete callback some hint when they want an property change to be
signalled.  For example an additional parameter or always when the
'reply' parameter is NULL (as opposed to an successful method return
message).  It could also be argued that a Set with a new value same as
old value should return an error reply but that's probably best left to
the client to decide.
---
 ell/dbus-service.c | 48 +++-------------------------------------------
 1 file changed, 3 insertions(+), 45 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 3ad6c7e..d97eb62 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1227,28 +1227,13 @@ static void set_property_complete(struct l_dbus *db=
us,
 					struct l_dbus_message *message,
 					struct l_dbus_message *reply)
 {
-	const char *property_name;
-	struct l_dbus_message_iter variant;
-
 	if (!reply) {
 		reply =3D l_dbus_message_new_method_return(message);
 		l_dbus_message_set_arguments(reply, "");
 	}
 =

-	l_dbus_send(dbus, l_dbus_message_ref(reply));
-
-	if (!l_dbus_message_is_error(reply)) {
-		l_dbus_message_get_arguments(message, "sv", &property_name,
-						&variant);
-
-		_dbus_object_tree_property_changed(dbus,
-					l_dbus_message_get_path(message),
-					l_dbus_message_get_interface(message),
-					property_name);
-	}
-
 	l_dbus_message_unref(message);
-	l_dbus_message_unref(reply);
+	l_dbus_send(dbus, reply);
 }
 =

 static struct l_dbus_message *old_set_property(struct l_dbus *dbus,
@@ -1815,33 +1800,6 @@ static struct l_dbus_message *properties_get(struct =
l_dbus *dbus,
 	return reply;
 }
 =

-static void properties_set_complete(struct l_dbus *dbus,
-					struct l_dbus_message *message,
-					struct l_dbus_message *reply)
-{
-	const char *interface_name, *property_name;
-	struct l_dbus_message_iter variant;
-
-	if (!reply) {
-		reply =3D l_dbus_message_new_method_return(message);
-		l_dbus_message_set_arguments(reply, "");
-	}
-
-	l_dbus_send(dbus, l_dbus_message_ref(reply));
-
-	if (!l_dbus_message_is_error(reply)) {
-		l_dbus_message_get_arguments(message, "ssv", &interface_name,
-						&property_name, &variant);
-
-		_dbus_object_tree_property_changed(dbus,
-					l_dbus_message_get_path(message),
-					interface_name, property_name);
-	}
-
-	l_dbus_message_unref(message);
-	l_dbus_message_unref(reply);
-}
-
 static struct l_dbus_message *properties_set(struct l_dbus *dbus,
 						struct l_dbus_message *message,
 						void *user_data)
@@ -1900,11 +1858,11 @@ static struct l_dbus_message *properties_set(struct=
 l_dbus *dbus,
 						interface_name);
 =

 	reply =3D property->setter(dbus, l_dbus_message_ref(message), &variant,
-					properties_set_complete,
+					set_property_complete,
 					instance->user_data);
 =

 	if (reply)
-		properties_set_complete(dbus, message, reply);
+		set_property_complete(dbus, message, reply);
 =

 	return NULL;
 }
-- =

2.17.1


--===============7985400704686319877==--

