Content-Type: multipart/mixed; boundary="===============4088900917136538481=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] dbus: Declaration of l_dbus_message_builder was missing
Date: Mon, 03 Nov 2014 13:58:07 +0200
Message-ID: <1415015887-14158-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4088900917136538481==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Project using ell dbus fail because of compilation error.
---
 ell/dbus.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dbus.h b/ell/dbus.h
index b438323..a6ad109 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -39,6 +39,7 @@ enum l_dbus_bus {
 =

 struct l_dbus;
 struct l_dbus_interface;
+struct l_dbus_message_builder;
 =

 typedef void (*l_dbus_ready_func_t) (void *user_data);
 typedef void (*l_dbus_disconnect_func_t) (void *user_data);
-- =

1.8.3.1


--===============4088900917136538481==--

