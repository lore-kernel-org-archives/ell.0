Content-Type: multipart/mixed; boundary="===============0686152544753096120=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v2 05/11] dbus: GVariant message cookie and reply cookie are
 64-bit
Date: Tue, 12 Apr 2016 03:56:09 +0200
Message-ID: <1460426175-25501-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460426175-25501-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0686152544753096120==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

They're 64-bit but the systemd docs discourage using the upper 32 bits,
so we take advantage of that and only support cookie values that fit 32
bits to avoid too big code changes (we use the dbus1 header layout for
the cookie storage so we'd have to move the cookie/serial out of that
header like we do with sender, path, etc.).  This only tries to fix the
parsing and encoding.
---
 ell/dbus-message.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++----=
----
 1 file changed, 52 insertions(+), 8 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 964b925..eb47eb3 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -111,13 +111,27 @@ void _dbus_message_set_serial(struct l_dbus_message *=
msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

-	hdr->serial =3D serial;
+	if (_dbus_message_is_gvariant(msg)) {
+		if (_dbus_message_get_endian(msg) =3D=3D
+				DBUS_MESSAGE_LITTLE_ENDIAN) {
+			hdr->serial =3D serial;
+			hdr->field_length =3D 0;
+		} else {
+			hdr->serial =3D 0;
+			hdr->field_length =3D serial;
+		}
+	} else
+		hdr->serial =3D serial;
 }
 =

 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

+	if (_dbus_message_is_gvariant(msg) && _dbus_message_get_endian(msg) =3D=
=3D
+			DBUS_MESSAGE_BIG_ENDIAN)
+		return hdr->field_length;
+
 	return hdr->serial;
 }
 =

@@ -294,7 +308,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_me=
thod_return(
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
 					hdr->version);
 =

-	message->reply_serial =3D hdr->serial;
+	message->reply_serial =3D _dbus_message_get_serial(method_call);
 =

 	sender =3D l_dbus_message_get_sender(method_call);
 	if (sender)
@@ -321,7 +335,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_new_er=
ror_valist(
 					DBUS_MESSAGE_FLAG_NO_REPLY_EXPECTED,
 					hdr->version);
 =

-	reply->reply_serial =3D hdr->serial;
+	reply->reply_serial =3D _dbus_message_get_serial(method_call);
 =

 	sender =3D l_dbus_message_get_sender(method_call);
 	if (sender)
@@ -641,8 +655,17 @@ static bool valid_header(const struct dbus_header *hdr)
 	if (hdr->version !=3D 1 && hdr->version !=3D 2)
 		return false;
 =

-	if (hdr->serial =3D=3D 0)
-		return false;
+	if (hdr->version =3D=3D 1) {
+		if (hdr->serial =3D=3D 0)
+			return false;
+	} else if (hdr->endian =3D=3D DBUS_MESSAGE_LITTLE_ENDIAN) {
+		/* We don't support 64-bit GVariant cookies */
+		if (hdr->serial =3D=3D 0 || hdr->field_length !=3D 0)
+			return false;
+	} else
+		/* We don't support 64-bit GVariant cookies */
+		if (hdr->serial !=3D 0 || hdr->field_length =3D=3D 0)
+			return false;
 =

 	return true;
 }
@@ -916,8 +939,18 @@ static void build_header(struct l_dbus_message *messag=
e, const char *signature)
 	}
 =

 	if (message->reply_serial !=3D 0) {
-		add_field(builder, driver, DBUS_MESSAGE_FIELD_REPLY_SERIAL,
+		if (gvariant) {
+			uint64_t reply_serial =3D message->reply_serial;
+
+			add_field(builder, driver,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL,
+					"t", &reply_serial);
+		} else {
+			add_field(builder, driver,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL,
 					"u", &message->reply_serial);
+		}
+
 		message->reply_serial =3D 0;
 	}
 =

@@ -1351,9 +1384,20 @@ uint32_t _dbus_message_get_reply_serial(struct l_dbu=
s_message *message)
 	if (unlikely(!message))
 		return 0;
 =

-	if (message->reply_serial =3D=3D 0)
-		get_header_field(message, DBUS_MESSAGE_FIELD_REPLY_SERIAL, 'u',
+	if (message->reply_serial =3D=3D 0) {
+		if (_dbus_message_is_gvariant(message)) {
+			uint64_t reply_serial;
+
+			get_header_field(message,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL, 't',
+					&reply_serial);
+
+			message->reply_serial =3D reply_serial;
+		} else
+			get_header_field(message,
+					DBUS_MESSAGE_FIELD_REPLY_SERIAL, 'u',
 					&message->reply_serial);
+	}
 =

 	return message->reply_serial;
 }
-- =

2.5.0


--===============0686152544753096120==--

