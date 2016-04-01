Content-Type: multipart/mixed; boundary="===============2629014965770022516=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Fix _dbus_kernel_calculate_bloom for multiple arguments
Date: Fri, 01 Apr 2016 04:41:06 +0200
Message-ID: <1459478466-6299-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1459478466-6299-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2629014965770022516==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_message_iter_get_type can't be used to get the value of a
single argument and be called repeatedly, might crash if the number
and types of call arguments don't match the message arguments.
Add a comment explaining why arguments after first non-string argument
are not considered.
---
 ell/dbus-message.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 4d64115..ece98a4 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1427,6 +1427,7 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_messa=
ge *message,
 	struct l_dbus_message_iter iter;
 	uint8_t argn;
 	char buf[256];
+	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
 =

 	/* The string "interface:" suffixed by the interface name */
 	attr =3D l_dbus_message_get_interface(message);
@@ -1470,17 +1471,36 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_mes=
sage *message,
 =

 	body =3D _dbus_message_get_body(message, &body_size);
 =

-	if (_dbus_message_is_gvariant(message))
-		_gvariant_iter_init(&iter, message, signature, NULL,
-					body, body_size);
-	else
+	if (_dbus_message_is_gvariant(message)) {
+		if (!_gvariant_iter_init(&iter, message, signature, NULL,
+						body, body_size))
+			return false;
+
+		get_basic =3D _gvariant_iter_next_entry_basic;
+	} else {
 		_dbus1_iter_init(&iter, message, signature, NULL,
-				body, body_size);
+					body, body_size);
+
+		get_basic =3D _dbus1_iter_next_entry_basic;
+	}
 =

 	argn =3D 0;
 =

+	/*
+	 * systemd-master/src/libsystemd/sd-bus/PORTING-DBUS1:
+	 *
+	 * "If the first argument of the message is a string,
+	 * "arg0-slash-prefix" suffixed with the first argument, and also
+	 * all prefixes of the argument (cut off at "/"), also prefixed
+	 * with "arg0-slash-prefix".
+	 *
+	 * Similar for all further arguments that are strings up to 63,
+	 * for the arguments and their "dot" and "slash" prefixes. On the
+	 * first argument that is not a string, addition to the bloom
+	 * filter should be stopped however."
+	 */
 	while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *signature =3D=
=3D 'g') {
-		if (!message_iter_next_entry(&iter, &attr))
+		if (!get_basic(&iter, *signature, &attr))
 			return false;
 =

 		sprintf(buf, "arg%hhu", argn);
-- =

2.5.0


--===============2629014965770022516==--

