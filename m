Content-Type: multipart/mixed; boundary="===============5930611970582778324=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] dbus: Move generic DBus paths to header file
Date: Tue, 10 Feb 2015 16:52:50 +0200
Message-ID: <1423579970-14284-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5930611970582778324==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

DBus defines moved to header file so that they can be used
by other source files.
---
 ell/dbus.c | 5 -----
 ell/dbus.h | 4 ++++
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 4c4ba2d..26456ac 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -45,11 +45,6 @@
 =

 #define DEFAULT_SYSTEM_BUS_ADDRESS "unix:path=3D/var/run/dbus/system_bus_s=
ocket"
 =

-#define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
-
-#define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
-
-#define DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
 #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
 #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
 =

diff --git a/ell/dbus.h b/ell/dbus.h
index a6ad109..7622b47 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -32,6 +32,10 @@
 extern "C" {
 #endif
 =

+#define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
+#define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
+#define DBUS_INTERFACE_DBUS	"org.freedesktop.DBus"
+
 enum l_dbus_bus {
 	L_DBUS_SYSTEM_BUS,
 	L_DBUS_SESSION_BUS,
-- =

1.8.3.1


--===============5930611970582778324==--

