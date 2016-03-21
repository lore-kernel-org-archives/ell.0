Content-Type: multipart/mixed; boundary="===============7703838661743918859=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 15/15] dbus: Don't send replies to messages with no reply flag.
Date: Mon, 21 Mar 2016 23:10:24 +0100
Message-ID: <1458598224-29325-15-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7703838661743918859==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Kdbus doesn't store the cookies for messages that have the no reply flag
and throws error when a reply is sent with reply_cookie that it doesn't
know.  It's not fatal, but we also save some cycles by not sending the
message.  A further change could be made to not even let users create a
message as a return from a method call but that may be confusing.
---
 ell/dbus-message.c | 32 +++++++++++++++++++++++++++-----
 ell/dbus-private.h |  1 +
 ell/dbus.c         |  5 +++++
 3 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index a7c9699..5ecac8d 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -43,6 +43,7 @@
 =

 #define DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED	0x01
 #define DBUS_MESSAGE_FLAG_NO_AUTO_START		0x02
+#define DBUS_MESSAGE_FLAG_DISCARD		0x04
 =

 #define DBUS_MESSAGE_FIELD_PATH		1
 #define DBUS_MESSAGE_FIELD_INTERFACE	2
@@ -185,6 +186,22 @@ LIB_EXPORT bool l_dbus_message_get_no_autostart(struct=
 l_dbus_message *msg)
 =

 }
 =

+bool _dbus_message_get_discard(struct l_dbus_message *msg)
+{
+	struct dbus_header *hdr;
+
+	if (unlikely(!msg))
+		return false;
+
+	hdr =3D msg->header;
+
+	if (hdr->flags & DBUS_MESSAGE_FLAG_DISCARD)
+		return true;
+
+	return false;
+
+}
+
 static struct l_dbus_message *message_new_common(uint8_t type, uint8_t fla=
gs,
 						uint8_t version)
 {
@@ -285,10 +302,13 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_=
method_return(
 	struct l_dbus_message *message;
 	struct dbus_header *hdr =3D method_call->header;
 	const char *sender;
+	uint8_t flags =3D DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED;
+
+	if (l_dbus_message_get_no_reply(method_call))
+		flags |=3D DBUS_MESSAGE_FLAG_DISCARD;
 =

 	message =3D message_new_common(DBUS_MESSAGE_TYPE_METHOD_RETURN,
-					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
-					hdr->version);
+					flags, hdr->version);
 =

 	message->reply_serial =3D hdr->serial;
 =

@@ -308,14 +328,16 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_=
error_valist(
 	struct l_dbus_message *reply;
 	struct dbus_header *hdr =3D method_call->header;
 	const char *sender;
+	uint8_t flags =3D DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED;
 =

 	if (!_dbus_valid_interface(name))
 		return NULL;
 =

+	if (l_dbus_message_get_no_reply(method_call))
+		flags |=3D DBUS_MESSAGE_FLAG_DISCARD;
+
 	vsnprintf(str, sizeof(str), format, args);
-	reply =3D message_new_common(DBUS_MESSAGE_TYPE_ERROR,
-					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
-					hdr->version);
+	reply =3D message_new_common(DBUS_MESSAGE_TYPE_ERROR, flags, hdr->version=
);
 =

 	reply->reply_serial =3D hdr->serial;
 =

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 0ae4c69..3b40fea 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -108,6 +108,7 @@ void *_dbus_message_get_header(struct l_dbus_message *m=
sg, size_t *out_size);
 void _dbus_message_set_serial(struct l_dbus_message *msg, uint32_t serial);
 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg);
 uint32_t _dbus_message_get_reply_serial(struct l_dbus_message *message);
+bool _dbus_message_get_discard(struct l_dbus_message *msg);
 =

 void _dbus_message_set_sender(struct l_dbus_message *message,
 					const char *sender);
diff --git a/ell/dbus.c b/ell/dbus.c
index b9864bd..d976496 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1323,6 +1323,11 @@ LIB_EXPORT uint32_t l_dbus_send(struct l_dbus *dbus,
 	if (unlikely(!dbus || !message))
 		return 0;
 =

+	if (_dbus_message_get_discard(message)) {
+		l_dbus_message_unref(message);
+		return 0;
+	}
+
 	return send_message(dbus, false, message, NULL, NULL, NULL);
 }
 =

-- =

2.5.0


--===============7703838661743918859==--

