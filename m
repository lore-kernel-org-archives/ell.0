Content-Type: multipart/mixed; boundary="===============5695887494834871123=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] dbus: Default empty signature for method return messages
Date: Tue, 21 Feb 2017 00:30:34 +0100
Message-ID: <20170220233036.8741-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5695887494834871123==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow Dbus method or setter handlers to return the result of a
l_dbus_message_new_method_return call directly without calling
l_dbus_message_set_arguments on the result.  This will result in an
empty signature message being built inside l_dbus_send.

Note l_dbus_send now modifies the message being passed to it.

Instead of checking if the signature returned by
l_dbus_message_get_signature is NULL we could also just call
l_dbus_message_builder_new and write an empty message.
l_dbus_message_builder_new would return NULL if message->sealed was
true.
---
 ell/dbus.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index 5318794..ddc51aa 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -324,6 +324,11 @@ static uint32_t send_message(struct l_dbus *dbus, bool=
 priority,
 		return 0;
 	}
 =

+	/* Default empty signature for method return messages */
+	if (type =3D=3D DBUS_MESSAGE_TYPE_METHOD_RETURN &&
+			!l_dbus_message_get_signature(message))
+		l_dbus_message_set_arguments(message, "");
+
 	callback =3D l_new(struct message_callback, 1);
 =

 	callback->serial =3D dbus->next_serial++;
-- =

2.9.3


--===============5695887494834871123==--

