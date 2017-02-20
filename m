Content-Type: multipart/mixed; boundary="===============4097142798688783829=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] dbus: Allow property setters to return method return
 message
Date: Tue, 21 Feb 2017 00:30:35 +0100
Message-ID: <20170220233036.8741-2-andrew.zaborowski@intel.com>
In-Reply-To: <20170220233036.8741-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4097142798688783829==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Synchronous property setters can now either call complete with a NULL
error argument and return NULL, or return a method return message with
an empty signature on success.  Previously only error messages could
be directly returned like that.
---
 ell/dbus-service.c | 51 ++++++++++++++++++++++-----------------------------
 1 file changed, 22 insertions(+), 29 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 8bc9244..1df8f1b 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1163,30 +1163,27 @@ bool _dbus_object_tree_property_changed(struct l_db=
us *dbus,
 =

 static void set_property_complete(struct l_dbus *dbus,
 					struct l_dbus_message *message,
-					struct l_dbus_message *error)
+					struct l_dbus_message *reply)
 {
-	struct l_dbus_message *reply;
 	const char *property_name;
 	struct l_dbus_message_iter variant;
 =

-	if (error) {
-		l_dbus_message_unref(message);
-
-		l_dbus_send(dbus, error);
-
-		return;
+	if (!reply) {
+		reply =3D l_dbus_message_new_method_return(message);
+		l_dbus_message_set_arguments(reply, "");
 	}
 =

-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "");
 	l_dbus_send(dbus, reply);
 =

-	l_dbus_message_get_arguments(message, "sv", &property_name, &variant);
+	if (!l_dbus_message_is_error(reply)) {
+		l_dbus_message_get_arguments(message, "sv", &property_name,
+						&variant);
 =

-	_dbus_object_tree_property_changed(dbus,
+		_dbus_object_tree_property_changed(dbus,
 					l_dbus_message_get_path(message),
 					l_dbus_message_get_interface(message),
 					property_name);
+	}
 =

 	l_dbus_message_unref(message);
 }
@@ -1232,9 +1229,9 @@ static struct l_dbus_message *old_set_property(struct=
 l_dbus *dbus,
 					set_property_complete, user_data);
 =

 	if (reply)
-		l_dbus_message_unref(message);
+		set_property_complete(dbus, message, reply);
 =

-	return reply;
+	return NULL;
 }
 =

 static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
@@ -1714,30 +1711,26 @@ static struct l_dbus_message *properties_get(struct=
 l_dbus *dbus,
 =

 static void properties_set_complete(struct l_dbus *dbus,
 					struct l_dbus_message *message,
-					struct l_dbus_message *error)
+					struct l_dbus_message *reply)
 {
-	struct l_dbus_message *reply;
 	const char *interface_name, *property_name;
 	struct l_dbus_message_iter variant;
 =

-	if (error) {
-		l_dbus_message_unref(message);
-
-		l_dbus_send(dbus, error);
-
-		return;
+	if (!reply) {
+		reply =3D l_dbus_message_new_method_return(message);
+		l_dbus_message_set_arguments(reply, "");
 	}
 =

-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "");
 	l_dbus_send(dbus, reply);
 =

-	l_dbus_message_get_arguments(message, "ssv", &interface_name,
-					&property_name, &variant);
+	if (!l_dbus_message_is_error(reply)) {
+		l_dbus_message_get_arguments(message, "ssv", &interface_name,
+						&property_name, &variant);
 =

-	_dbus_object_tree_property_changed(dbus,
+		_dbus_object_tree_property_changed(dbus,
 					l_dbus_message_get_path(message),
 					interface_name, property_name);
+	}
 =

 	l_dbus_message_unref(message);
 }
@@ -1804,9 +1797,9 @@ static struct l_dbus_message *properties_set(struct l=
_dbus *dbus,
 					instance->user_data);
 =

 	if (reply)
-		l_dbus_message_unref(message);
+		properties_set_complete(dbus, message, reply);
 =

-	return reply;
+	return NULL;
 }
 =

 static struct l_dbus_message *properties_get_all(struct l_dbus *dbus,
-- =

2.9.3


--===============4097142798688783829==--

