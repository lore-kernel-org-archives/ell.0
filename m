Content-Type: multipart/mixed; boundary="===============1074165396121601200=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/15] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Mon, 21 Mar 2016 23:10:14 +0100
Message-ID: <1458598224-29325-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1074165396121601200==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It seems that l_dbus_message_iter_get_type can't be used to get the
value of a single argument and be called repeatedly, it might crash if
the number and types of call arguments don't match the message arguments.
Add a comment explaining why arguments after first non-string argument
are not considered.
---
 ell/dbus-message.c | 34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 0b412b2..a7c9699 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1419,6 +1419,7 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_messa=
ge *message,
 	struct l_dbus_message_iter iter;
 	uint8_t argn;
 	char buf[256];
+	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
 =

 	/* The string "interface:" suffixed by the interface name */
 	attr =3D l_dbus_message_get_interface(message);
@@ -1462,17 +1463,38 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_mes=
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
+	 * Stop iteration on the first non-string argument even though
+	 * this may lead to legitimate signals not reaching peers that
+	 * have set up seemingly correct kernel-side filters.
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


--===============1074165396121601200==--

