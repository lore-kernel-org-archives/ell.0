Content-Type: multipart/mixed; boundary="===============5774598889564210772=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/12] dbus: Validate field type in get_header_field
Date: Sun, 10 Apr 2016 06:02:34 +0200
Message-ID: <1460260961-9183-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460260961-9183-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5774598889564210772==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It seems there's no place where we are validating the header
fields of incoming messages so let's do it here.
---
 ell/dbus-message.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index ece98a4..6e2831b 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -554,7 +554,8 @@ static inline bool message_iter_next_entry(struct l_dbu=
s_message_iter *iter,
 }
 =

 static bool get_header_field_from_iter_valist(struct l_dbus_message *messa=
ge,
-						uint8_t type, va_list args)
+						uint8_t type, char data_type,
+						va_list args)
 {
 	struct l_dbus_message_iter header;
 	struct l_dbus_message_iter array, iter;
@@ -591,6 +592,9 @@ static bool get_header_field_from_iter_valist(struct l_=
dbus_message *message,
 		if (field_type !=3D type)
 			continue;
 =

+		if (iter.sig_start[iter->sig_pos] !=3D data_type)
+			return false;
+
 		return message_iter_next_entry_valist(&iter, args);
 	}
 =

@@ -598,13 +602,14 @@ static bool get_header_field_from_iter_valist(struct =
l_dbus_message *message,
 }
 =

 static inline bool get_header_field(struct l_dbus_message *message,
-                                                uint8_t type, ...)
+					uint8_t type, char data_type, ...)
 {
 	va_list args;
 	bool result;
 =

-	va_start(args, type);
-	result =3D get_header_field_from_iter_valist(message, type, args);
+	va_start(args, data_type);
+	result =3D get_header_field_from_iter_valist(message, type, data_type,
+							args);
 	va_end(args);
 =

 	return result;
@@ -658,7 +663,7 @@ struct l_dbus_message *dbus_message_from_blob(const voi=
d *data, size_t size)
 =

 	message->sealed =3D true;
 =

-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
+	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
 						&message->signature);
 =

 	return message;
@@ -690,7 +695,7 @@ struct l_dbus_message *dbus_message_build(void *header,=
 size_t header_size,
 =

 	message->sealed =3D true;
 =

-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
+	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
 						&message->signature);
 =

 	return message;
@@ -1095,7 +1100,7 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 	build_header(message, signature);
 	message->sealed =3D true;
 =

-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
+	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
 						&message->signature);
 =

 	return true;
@@ -1130,7 +1135,7 @@ LIB_EXPORT bool l_dbus_message_get_error(struct l_dbu=
s_message *message,
 		return false;
 =

 	if (!message->error_name)
-		get_header_field(message, DBUS_MESSAGE_FIELD_ERROR_NAME,
+		get_header_field(message, DBUS_MESSAGE_FIELD_ERROR_NAME, 's',
 					&message->error_name);
 =

 	if (name)
@@ -1213,7 +1218,7 @@ LIB_EXPORT const char *l_dbus_message_get_path(struct=
 l_dbus_message *message)
 		return NULL;
 =

 	if (!message->path)
-		get_header_field(message, DBUS_MESSAGE_FIELD_PATH,
+		get_header_field(message, DBUS_MESSAGE_FIELD_PATH, 'o',
 					&message->path);
 =

 	return message->path;
@@ -1225,7 +1230,7 @@ LIB_EXPORT const char *l_dbus_message_get_interface(s=
truct l_dbus_message *messa
 		return NULL;
 =

 	if (!message->interface)
-		get_header_field(message, DBUS_MESSAGE_FIELD_INTERFACE,
+		get_header_field(message, DBUS_MESSAGE_FIELD_INTERFACE, 's',
 					&message->interface);
 =

 	return message->interface;
@@ -1237,7 +1242,7 @@ LIB_EXPORT const char *l_dbus_message_get_member(stru=
ct l_dbus_message *message)
 		return NULL;
 =

 	if (!message->member)
-		get_header_field(message, DBUS_MESSAGE_FIELD_MEMBER,
+		get_header_field(message, DBUS_MESSAGE_FIELD_MEMBER, 's',
 					&message->member);
 =

 	return message->member;
@@ -1249,7 +1254,7 @@ LIB_EXPORT const char *l_dbus_message_get_destination=
(struct l_dbus_message *mes
 		return NULL;
 =

 	if (!message->destination)
-		get_header_field(message, DBUS_MESSAGE_FIELD_DESTINATION,
+		get_header_field(message, DBUS_MESSAGE_FIELD_DESTINATION, 's',
 							&message->destination);
 =

 	return message->destination;
@@ -1261,7 +1266,7 @@ LIB_EXPORT const char *l_dbus_message_get_sender(stru=
ct l_dbus_message *message)
 		return NULL;
 =

 	if (!message->sender)
-		get_header_field(message, DBUS_MESSAGE_FIELD_SENDER,
+		get_header_field(message, DBUS_MESSAGE_FIELD_SENDER, 's',
 					&message->sender);
 =

 	return message->sender;
@@ -1282,7 +1287,7 @@ uint32_t _dbus_message_get_reply_serial(struct l_dbus=
_message *message)
 		return 0;
 =

 	if (message->reply_serial =3D=3D 0)
-		get_header_field(message, DBUS_MESSAGE_FIELD_REPLY_SERIAL,
+		get_header_field(message, DBUS_MESSAGE_FIELD_REPLY_SERIAL, 'u',
 					&message->reply_serial);
 =

 	return message->reply_serial;
@@ -1809,7 +1814,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_buil=
der_finalize(
 	build_header(builder->message, generated_signature);
 	builder->message->sealed =3D true;
 =

-	get_header_field(builder->message, DBUS_MESSAGE_FIELD_SIGNATURE,
+	get_header_field(builder->message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
 						&builder->message->signature);
 	l_free(generated_signature);
 =

-- =

2.5.0


--===============5774598889564210772==--

