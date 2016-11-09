Content-Type: multipart/mixed; boundary="===============2082467829928637904=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Don't send replies to messages with no reply flag
Date: Wed, 09 Nov 2016 11:22:46 +0100
Message-ID: <1478686966-15117-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2082467829928637904==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Kdbus doesn't store the cookies for messages that have the no reply flag
and throws error when a reply is sent with reply_cookie that it doesn't
know.  It's not fatal, but we save some cycles by not sending the message
with both dbus versions.

We mark those replies with reply_serial =3D=3D 0, rather than setting a
"discard" flag on the message, because the method call's serial is
effectively an invalid reply_serial value.
---
 ell/dbus-message.c | 10 +++++++---
 ell/dbus.c         | 10 ++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 072a902..3b44fb8 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -326,7 +326,8 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_me=
thod_return(
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
 					hdr->version);
 =

-	message->reply_serial =3D _dbus_message_get_serial(method_call);
+	if (!l_dbus_message_get_no_reply(method_call))
+		message->reply_serial =3D _dbus_message_get_serial(method_call);
 =

 	sender =3D l_dbus_message_get_sender(method_call);
 	if (sender)
@@ -369,11 +370,14 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_=
error_valist(
 {
 	char str[1024];
 	struct dbus_header *hdr =3D method_call->header;
+	uint32_t reply_serial =3D 0;
 =

 	vsnprintf(str, sizeof(str), format, args);
 =

-	return _dbus_message_new_error(hdr->version,
-					_dbus_message_get_serial(method_call),
+	if (!l_dbus_message_get_no_reply(method_call))
+		reply_serial =3D _dbus_message_get_serial(method_call);
+
+	return _dbus_message_new_error(hdr->version, reply_serial,
 					l_dbus_message_get_sender(method_call),
 					name, str);
 }
diff --git a/ell/dbus.c b/ell/dbus.c
index 236c35a..2c04ec9 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -313,6 +313,16 @@ static uint32_t send_message(struct l_dbus *dbus, bool=
 priority,
 				void *user_data, l_dbus_destroy_func_t destroy)
 {
 	struct message_callback *callback;
+	enum dbus_message_type type;
+
+	type =3D _dbus_message_get_type(message);
+
+	if ((type =3D=3D DBUS_MESSAGE_TYPE_METHOD_RETURN ||
+				type =3D=3D DBUS_MESSAGE_TYPE_ERROR) &&
+			_dbus_message_get_reply_serial(message) =3D=3D 0) {
+		l_dbus_message_unref(message);
+		return 0;
+	}
 =

 	callback =3D l_new(struct message_callback, 1);
 =

-- =

2.7.4


--===============2082467829928637904==--

