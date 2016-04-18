Content-Type: multipart/mixed; boundary="===============5979563594797452754=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Check message->sealed before get_header_field()
Date: Mon, 18 Apr 2016 16:31:10 +0200
Message-ID: <1460989877-20113-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5979563594797452754==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Also make sure _dbus_message_get_reply_serial on kdbus doesn't overwrite
message->reply_serial with uninitialised value.
---
 ell/dbus-message.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 86cec96..aecf398 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1336,7 +1336,7 @@ LIB_EXPORT const char *l_dbus_message_get_path(struct=
 l_dbus_message *message)
 	if (unlikely(!message))
 		return NULL;
 =

-	if (!message->path)
+	if (!message->path && message->sealed)
 		get_header_field(message, DBUS_MESSAGE_FIELD_PATH, 'o',
 					&message->path);
 =

@@ -1348,7 +1348,7 @@ LIB_EXPORT const char *l_dbus_message_get_interface(s=
truct l_dbus_message *messa
 	if (unlikely(!message))
 		return NULL;
 =

-	if (!message->interface)
+	if (!message->interface && message->sealed)
 		get_header_field(message, DBUS_MESSAGE_FIELD_INTERFACE, 's',
 					&message->interface);
 =

@@ -1360,7 +1360,7 @@ LIB_EXPORT const char *l_dbus_message_get_member(stru=
ct l_dbus_message *message)
 	if (unlikely(!message))
 		return NULL;
 =

-	if (!message->member)
+	if (!message->member && message->sealed)
 		get_header_field(message, DBUS_MESSAGE_FIELD_MEMBER, 's',
 					&message->member);
 =

@@ -1372,7 +1372,7 @@ LIB_EXPORT const char *l_dbus_message_get_destination=
(struct l_dbus_message *mes
 	if (unlikely(!message))
 		return NULL;
 =

-	if (!message->destination)
+	if (!message->destination && message->sealed)
 		get_header_field(message, DBUS_MESSAGE_FIELD_DESTINATION, 's',
 							&message->destination);
 =

@@ -1384,7 +1384,7 @@ LIB_EXPORT const char *l_dbus_message_get_sender(stru=
ct l_dbus_message *message)
 	if (unlikely(!message))
 		return NULL;
 =

-	if (!message->sender)
+	if (!message->sender && message->sealed)
 		get_header_field(message, DBUS_MESSAGE_FIELD_SENDER, 's',
 					&message->sender);
 =

@@ -1405,9 +1405,9 @@ uint32_t _dbus_message_get_reply_serial(struct l_dbus=
_message *message)
 	if (unlikely(!message))
 		return 0;
 =

-	if (message->reply_serial =3D=3D 0) {
+	if (message->reply_serial =3D=3D 0 && message->sealed) {
 		if (_dbus_message_is_gvariant(message)) {
-			uint64_t reply_serial;
+			uint64_t reply_serial =3D 0;
 =

 			get_header_field(message,
 					DBUS_MESSAGE_FIELD_REPLY_SERIAL, 't',
-- =

2.5.0


--===============5979563594797452754==--

