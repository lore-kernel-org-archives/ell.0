Content-Type: multipart/mixed; boundary="===============5560413327285627101=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 7/9] dbus: Remove signature field from gvariant header
Date: Fri, 15 Apr 2016 02:34:00 +0200
Message-ID: <1460680442-15201-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5560413327285627101==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The main reason to do that is that systemd thinks it's an error and will
ignore received messages with a dbus1-like signature field in the
header.
---
 ell/dbus-message.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 00d9838..a409e53 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -972,7 +972,7 @@ static void build_header(struct l_dbus_message *message=
, const char *signature)
 		message->sender =3D NULL;
 	}
 =

-	if (signature[0] !=3D '\0')
+	if (signature[0] !=3D '\0' && !gvariant)
 		add_field(builder, driver, DBUS_MESSAGE_FIELD_SIGNATURE,
 				"g", signature);
 =

@@ -1201,13 +1201,9 @@ static bool append_arguments(struct l_dbus_message *=
message,
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
 =

 	return true;
 =

@@ -1932,10 +1928,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_bui=
lder_finalize(
 =

 	build_header(builder->message, generated_signature);
 	builder->message->sealed =3D true;
-
-	get_header_field(builder->message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
-						&builder->message->signature);
-	l_free(generated_signature);
+	builder->message->signature =3D generated_signature;
 =

 	return builder->message;
 }
-- =

2.5.0


--===============5560413327285627101==--

