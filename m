Content-Type: multipart/mixed; boundary="===============0664966838113848298=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 18/21] examples: Apply the changes related to interface
 property API
Date: Thu, 13 Nov 2014 12:36:22 +0200
Message-ID: <1415874985-13034-19-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0664966838113848298==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Now providing pointer for get, set and exists methods, part of
org.freedesktop.DBus.Properties interface standard support.
---
 examples/dbus-service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 06cf1d9..261f311 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -206,8 +206,8 @@ static const struct l_dbus_signal test_signals[] =3D {
 };
 =

 static const struct l_dbus_property test_properties[] =3D {
-	{ L_DBUS_RW_PROPERTY("String", "s") },
-	{ L_DBUS_RW_PROPERTY("Integer", "u") },
+	{ L_DBUS_RW_PROPERTY("String", "s", NULL, NULL, NULL) },
+	{ L_DBUS_RW_PROPERTY("Integer", "u", NULL, NULL, NULL) },
 	{ },
 };
 =

-- =

2.0.4


--===============0664966838113848298==--

