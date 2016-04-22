Content-Type: multipart/mixed; boundary="===============0571151314683736310=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v4] dbus: Remove signature field from gvariant header
Date: Fri, 22 Apr 2016 02:57:16 +0200
Message-ID: <1461286637-30810-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461286637-30810-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0571151314683736310==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The main reason to do that is that systemd thinks it's an error and will
ignore received messages with a dbus1-like signature field in the
header.
---
 ell/dbus-message.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 8cbe1a5..6b89f67 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -973,7 +973,7 @@ static void build_header(struct l_dbus_message *message=
, const char *signature)
 		message->sender =3D NULL;
 	}
 =

-	if (signature[0] !=3D '\0')
+	if (signature[0] !=3D '\0' && !gvariant)
 		add_field(builder, driver, DBUS_MESSAGE_FIELD_SIGNATURE,
 				"g", signature);
 =

@@ -1202,13 +1202,10 @@ static bool append_arguments(struct l_dbus_message =
*message,
 	if (strcmp(signature, generated_signature))
 		return false;
 =

-	l_free(generated_signature);
-
 	build_header(message, signature);
 	message->sealed =3D true;
-
-	get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
-						&message->signature);
+	message->signature =3D generated_signature;
+	message->signature_free =3D true;
 =

 	return true;
 =

@@ -1933,10 +1930,8 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_bui=
lder_finalize(
 =

 	build_header(builder->message, generated_signature);
 	builder->message->sealed =3D true;
-
-	get_header_field(builder->message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
-						&builder->message->signature);
-	l_free(generated_signature);
+	builder->message->signature =3D generated_signature;
+	builder->message->signature_free =3D true;
 =

 	return builder->message;
 }
-- =

2.5.0


--===============0571151314683736310==--

