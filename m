Content-Type: multipart/mixed; boundary="===============0771890823853368587=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Handle kdbus KDBUS_ITEM_REPLY_TIMEOUT / _DEAD
Date: Sat, 23 Apr 2016 03:10:02 +0200
Message-ID: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0771890823853368587==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Generate DBus1-like error messages on kernel error notifications.
---
 ell/dbus-kernel.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index b5a07a5..4fd2f29 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -559,6 +559,7 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 	struct kdbus_item *item;
 	int r;
 	size_t min_size;
+	const char *error;
 =

 	memset(&recv_cmd, 0, sizeof(recv_cmd));
 =

@@ -601,6 +602,23 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 						user_data);
 			break;
 =

+		case KDBUS_ITEM_REPLY_TIMEOUT:
+		case KDBUS_ITEM_REPLY_DEAD:
+			if (item->type =3D=3D KDBUS_ITEM_REPLY_TIMEOUT)
+				error =3D "Did not receive a reply.";
+			else
+				error =3D "Message recipient disconnected from "
+					"message bus without replying.";
+
+			dbus_msg =3D _dbus_message_new_error(
+					2, msg->cookie_reply, NULL,
+					"org.freedesktop.DBus.Error.NoReply",
+					error);
+			if (dbus_msg)
+				message_func(dbus_msg, user_data);
+
+			break;
+
 		default:
 			break;
 		}
-- =

2.5.0


--===============0771890823853368587==--

