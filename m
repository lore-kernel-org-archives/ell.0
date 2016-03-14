Content-Type: multipart/mixed; boundary="===============3027840172144388044=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: free previous sender string in _dbus_message_set_sender
Date: Mon, 14 Mar 2016 15:49:39 +0100
Message-ID: <1457966979-3259-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3027840172144388044==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow _dbus_message_set_sender and _dbus_message_set_destination to be
called multiple times.
---
 ell/dbus-message.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index a123a8a..84d42d4 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1390,6 +1390,8 @@ void _dbus_message_set_sender(struct l_dbus_message *=
message,
 	if (!_dbus_message_is_gvariant(message))
 		return;
 =

+	l_free(message->sender);
+
 	message->sender =3D l_strdup(sender);
 	message->kdbus_sender =3D true;
 }
@@ -1400,6 +1402,8 @@ void _dbus_message_set_destination(struct l_dbus_mess=
age *message,
 	if (!_dbus_message_is_gvariant(message))
 		return;
 =

+	l_free(message->destination);
+
 	message->destination =3D l_strdup(destination);
 	message->kdbus_destination =3D true;
 }
-- =

2.5.0


--===============3027840172144388044==--

