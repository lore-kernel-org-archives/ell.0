Content-Type: multipart/mixed; boundary="===============0512383050359288782=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v2 1/2] dbus: Add private _dbus_message_new_error
Date: Fri, 22 Apr 2016 02:57:17 +0200
Message-ID: <1461286637-30810-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461286637-30810-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0512383050359288782==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 41 +++++++++++++++++++++++++----------------
 ell/dbus-private.h |  5 +++++
 2 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 6b89f67..1034acd 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -328,33 +328,26 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_=
method_return(
 	return message;
 }
 =

-LIB_EXPORT struct l_dbus_message *l_dbus_message_new_error_valist(
-					struct l_dbus_message *method_call,
-					const char *name,
-					const char *format, va_list args)
+struct l_dbus_message *_dbus_message_new_error(uint8_t version,
+						uint32_t reply_serial,
+						const char *destination,
+						const char *name,
+						const char *error)
 {
-	char str[1024];
 	struct l_dbus_message *reply;
-	struct dbus_header *hdr =3D method_call->header;
-	const char *sender;
 =

 	if (!_dbus_valid_interface(name))
 		return NULL;
 =

-	vsnprintf(str, sizeof(str), format, args);
 	reply =3D message_new_common(DBUS_MESSAGE_TYPE_ERROR,
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
-					hdr->version);
-
-	reply->reply_serial =3D _dbus_message_get_serial(method_call);
-
-	sender =3D l_dbus_message_get_sender(method_call);
-	if (sender)
-		reply->destination =3D l_strdup(sender);
+					version);
 =

 	reply->error_name =3D l_strdup(name);
+	reply->destination =3D l_strdup(destination);
+	reply->reply_serial =3D reply_serial;
 =

-	if (!l_dbus_message_set_arguments(reply, "s", str)) {
+	if (!l_dbus_message_set_arguments(reply, "s", error)) {
 		l_dbus_message_unref(reply);
 		return NULL;
 	}
@@ -362,6 +355,22 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_e=
rror_valist(
 	return reply;
 }
 =

+LIB_EXPORT struct l_dbus_message *l_dbus_message_new_error_valist(
+					struct l_dbus_message *method_call,
+					const char *name,
+					const char *format, va_list args)
+{
+	char str[1024];
+	struct dbus_header *hdr =3D method_call->header;
+
+	vsnprintf(str, sizeof(str), format, args);
+
+	return _dbus_message_new_error(hdr->version,
+					_dbus_message_get_serial(method_call),
+					l_dbus_message_get_sender(method_call),
+					name, str);
+}
+
 LIB_EXPORT struct l_dbus_message *l_dbus_message_new_error(
 					struct l_dbus_message *method_call,
 					const char *name,
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index be43aba..ab52895 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -141,6 +141,11 @@ struct l_dbus_message *_dbus_message_new_signal(uint8_=
t version,
 						const char *path,
 						const char *interface,
 						const char *name);
+struct l_dbus_message *_dbus_message_new_error(uint8_t version,
+						uint32_t reply_serial,
+						const char *destination,
+						const char *name,
+						const char *error);
 =

 struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e);
 struct l_dbus_message *dbus_message_build(void *header, size_t header_size,
-- =

2.5.0


--===============0512383050359288782==--

