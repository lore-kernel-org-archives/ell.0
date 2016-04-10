Content-Type: multipart/mixed; boundary="===============3551101450105340263=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/12] dbus: GVariant header field identifiers are 64-bit
Date: Sun, 10 Apr 2016 06:02:36 +0200
Message-ID: <1460260961-9183-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460260961-9183-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3551101450105340263==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For little-endian messages the 8-bit field identifiers were always
right-padded with zeros (or should have been) which worked out to look
same as 64-bit values in encoded messages so things would have
magically worked, but not with big-endian messages.
---
 ell/dbus-message.c | 47 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 32 insertions(+), 15 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 92054d1..085c5e1 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -559,14 +559,16 @@ static bool get_header_field_from_iter_valist(struct =
l_dbus_message *message,
 {
 	struct l_dbus_message_iter header;
 	struct l_dbus_message_iter array, iter;
-	uint8_t endian, message_type, flags, version, field_type;
+	uint8_t endian, message_type, flags, version;
 	uint32_t body_length, serial;
+	bool found;
 =

 	if (!message->sealed)
 		return false;
 =

 	if (_dbus_message_is_gvariant(message)) {
 		uint32_t header_length;
+		uint64_t field_type;
 =

 		if (!_gvariant_iter_init(&header, message, "yyyyuuu", NULL,
 					message->header, message->header_size))
@@ -577,13 +579,19 @@ static bool get_header_field_from_iter_valist(struct =
l_dbus_message *message,
 						&serial, &header_length))
 			return false;
 =

-		if (!_gvariant_iter_init(&header, message, "a(yv)", NULL,
-					message->header + 16, header_length))
+		if (!_gvariant_iter_init(&header, message, "a(tv)", NULL,
 			return false;
 =

 		if (!_gvariant_iter_enter_array(&header, &array))
 			return false;
+
+		while ((found =3D message_iter_next_entry(&array,
+							&field_type, &iter)))
+			if (field_type =3D=3D type)
+				break;
 	} else {
+		uint8_t field_type;
+
 		_dbus1_iter_init(&header, message, "yyyyuua(yv)", NULL,
 				message->header, message->header_size);
 =

@@ -591,19 +599,20 @@ static bool get_header_field_from_iter_valist(struct =
l_dbus_message *message,
 						&message_type, &flags, &version,
 						&body_length, &serial, &array))
 			return false;
-	}
 =

-	while (message_iter_next_entry(&array, &field_type, &iter)) {
-		if (field_type !=3D type)
-			continue;
+		while ((found =3D message_iter_next_entry(&array,
+							&field_type, &iter)))
+			if (field_type =3D=3D type)
+				break;
+	}
 =

-		if (iter.sig_start[iter->sig_pos] !=3D data_type)
-			return false;
+	if (!found)
+		return false;
 =

-		return message_iter_next_entry_valist(&iter, args);
-	}
+	if (iter.sig_start[iter.sig_pos] !=3D data_type)
+		return false;
 =

-	return false;
+	return message_iter_next_entry_valist(&iter, args);
 }
 =

 static inline bool get_header_field(struct l_dbus_message *message,
@@ -796,8 +805,15 @@ static void add_field(struct dbus_builder *builder,
 			struct builder_driver *driver,
 			uint8_t field, const char *type, const void *value)
 {
-	driver->enter_struct(builder, "yv");
-	driver->append_basic(builder, 'y', &field);
+	if (driver =3D=3D &gvariant_driver) {
+		uint64_t long_field =3D field;
+
+		driver->enter_struct(builder, "tv");
+		driver->append_basic(builder, 't', &long_field);
+	} else {
+		driver->enter_struct(builder, "yv");
+		driver->append_basic(builder, 'y', &field);
+	}
 	driver->enter_variant(builder, type);
 	driver->append_basic(builder, type[0], value);
 	driver->leave_variant(builder);
@@ -824,7 +840,8 @@ static void build_header(struct l_dbus_message *message=
, const char *signature)
 		driver->append_basic(builder, 'u', &field_length);
 	}
 =

-	driver->enter_array(builder, "(yv)");
+	driver->enter_array(builder, _dbus_message_is_gvariant(message) ?
+				"(tv)" : "(yv)");
 =

 	if (message->path) {
 		add_field(builder, driver, DBUS_MESSAGE_FIELD_PATH,
-- =

2.5.0


--===============3551101450105340263==--

