Content-Type: multipart/mixed; boundary="===============2652724637931525586=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [RFC 1/6] dbus: Add l_dbus_message_get_arguments_valist
Date: Wed, 29 Nov 2017 16:16:43 +0100
Message-ID: <20171129151648.24749-2-szymon.janc@codecoup.pl>
In-Reply-To: <20171129151648.24749-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2652724637931525586==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is a variant of l_dbus_message_get_arguments() that accepts
va_list as parameter.
---
 ell/dbus-message.c | 18 +++++++++++++-----
 ell/dbus.h         |  2 ++
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 7653c03..0314a07 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1372,12 +1372,11 @@ LIB_EXPORT bool l_dbus_message_is_error(struct l_db=
us_message *message)
 	return hdr->message_type =3D=3D DBUS_MESSAGE_TYPE_ERROR;
 }
 =

-LIB_EXPORT bool l_dbus_message_get_arguments(struct l_dbus_message *messag=
e,
-						const char *signature, ...)
+LIB_EXPORT bool l_dbus_message_get_arguments_valist(
+					struct l_dbus_message *message,
+					const char *signature, va_list args)
 {
 	struct l_dbus_message_iter iter;
-	va_list args;
-	bool result;
 =

 	if (unlikely(!message))
 		return false;
@@ -1402,8 +1401,17 @@ LIB_EXPORT bool l_dbus_message_get_arguments(struct =
l_dbus_message *message,
 		_dbus1_iter_init(&iter, message, message->signature, NULL,
 				message->body, message->body_size);
 =

+	return message_iter_next_entry_valist(&iter, args);
+}
+
+LIB_EXPORT bool l_dbus_message_get_arguments(struct l_dbus_message *messag=
e,
+						const char *signature, ...)
+{
+	va_list args;
+	bool result;
+
 	va_start(args, signature);
-	result =3D message_iter_next_entry_valist(&iter, args);
+	result =3D l_dbus_message_get_arguments_valist(message, signature, args);
 	va_end(args);
 =

 	return result;
diff --git a/ell/dbus.h b/ell/dbus.h
index 6705edd..5c7879f 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -164,6 +164,8 @@ bool l_dbus_message_get_error(struct l_dbus_message *me=
ssage,
 					const char **name, const char **text);
 bool l_dbus_message_get_arguments(struct l_dbus_message *message,
 						const char *signature, ...);
+bool l_dbus_message_get_arguments_valist(struct l_dbus_message *message,
+					const char *signature, va_list args);
 =

 bool l_dbus_message_iter_next_entry(struct l_dbus_message_iter *iter, ...);
 bool l_dbus_message_iter_get_variant(struct l_dbus_message_iter *iter,
-- =

2.14.3


--===============2652724637931525586==--

