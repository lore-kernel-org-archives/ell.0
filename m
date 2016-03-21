Content-Type: multipart/mixed; boundary="===============0551813865958856129=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/15] dbus: Support 2+ arguments in l_dbus_message_get_error
Date: Mon, 21 Mar 2016 23:10:13 +0100
Message-ID: <1458598224-29325-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0551813865958856129==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Error messages may have any number of arguments, the first one is still
the error string if it's a string.
---
 ell/dbus-message.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index d35b5a6..0b412b2 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1101,7 +1101,6 @@ error:
 LIB_EXPORT bool l_dbus_message_get_error(struct l_dbus_message *message,
 					const char **name, const char **text)
 {
-	struct l_dbus_message_iter iter;
 	struct dbus_header *hdr;
 	const char *str;
 =

@@ -1116,17 +1115,11 @@ LIB_EXPORT bool l_dbus_message_get_error(struct l_d=
bus_message *message,
 	if (!message->signature)
 		return false;
 =

-	if (strcmp(message->signature, "s"))
+	if (message->signature[0] !=3D 's')
 		return false;
 =

-	if (_dbus_message_is_gvariant(message))
-		_gvariant_iter_init(&iter, message, message->signature, NULL,
-					message->body, message->body_size);
-	else
-		_dbus1_iter_init(&iter, message, message->signature, NULL,
-				message->body, message->body_size);
-
-	if (!message_iter_next_entry(&iter, &str))
+	str =3D _dbus_message_get_nth_string_argument(message, 0);
+	if (!str)
 		return false;
 =

 	if (!message->error_name)
-- =

2.5.0


--===============0551813865958856129==--

