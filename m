Content-Type: multipart/mixed; boundary="===============2524161716561947582=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] dbus: Fix use-after-free in property changed signals
Date: Wed, 12 Jul 2017 13:23:02 -0700
Message-ID: <20170712202302.6373-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2524161716561947582==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Configuring with --enable-asan and running test-dbus-properties revealed
that properties_set_complete() was accessing a reply message after it
was sent, but l_dbus_send() had already unref'd and freed the message.

Grabbing a reference to the reply before sending fixes the problem.
---
 ell/dbus-service.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 5ee7d27..17e9053 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1781,7 +1781,7 @@ static void properties_set_complete(struct l_dbus *db=
us,
 		l_dbus_message_set_arguments(reply, "");
 	}
 =

-	l_dbus_send(dbus, reply);
+	l_dbus_send(dbus, l_dbus_message_ref(reply));
 =

 	if (!l_dbus_message_is_error(reply)) {
 		l_dbus_message_get_arguments(message, "ssv", &interface_name,
@@ -1793,6 +1793,7 @@ static void properties_set_complete(struct l_dbus *db=
us,
 	}
 =

 	l_dbus_message_unref(message);
+	l_dbus_message_unref(reply);
 }
 =

 static struct l_dbus_message *properties_set(struct l_dbus *dbus,
-- =

2.13.2


--===============2524161716561947582==--

