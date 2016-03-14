Content-Type: multipart/mixed; boundary="===============4466133272604543706=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 14/20] dbus: Don't send replies to messages with no reply flag.
Date: Mon, 14 Mar 2016 04:41:30 +0100
Message-ID: <1457926896-9843-14-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4466133272604543706==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Kdbus doesn't store the cookies for messages that have the no reply flag
and throws error when a reply is sent with reply_cookie that it doesn't
know.  It's not fatal, but we also save some cycles by not sending the
message.  A further change could be made to not even let users create a
message as a return from a method call but that may be confusing.
---
 ell/dbus-service.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index b4e0b60..c1ed9ec 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1624,8 +1624,12 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_=
tree *tree,
 		return false;
 =

 	reply =3D method->cb(dbus, message, instance->user_data);
-	if (reply)
-		l_dbus_send(dbus, reply);
+	if (reply) {
+		if (l_dbus_message_get_no_reply(message))
+			l_dbus_message_unref(reply);
+		else
+			l_dbus_send(dbus, reply);
+	}
 =

 	return true;
 }
-- =

2.5.0


--===============4466133272604543706==--

