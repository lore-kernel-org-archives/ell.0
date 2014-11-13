Content-Type: multipart/mixed; boundary="===============0274361769933736783=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 17/21] unit: Apply the changes related to interface property
 API
Date: Thu, 13 Nov 2014 12:36:21 +0200
Message-ID: <1415874985-13034-18-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0274361769933736783==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Now providing pointer for get, set and exists methods, part of
org.freedesktop.DBus.Properties interface standard support.
---
 unit/test-dbus-service.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 825a159..a4a6c85 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -343,7 +343,7 @@ static const struct l_dbus_signal sample_signals[] =3D {
 };
 =

 static const struct l_dbus_property sample_properties[] =3D {
-	{ L_DBUS_RW_PROPERTY("Bar", "y") },
+	{ L_DBUS_RW_PROPERTY("Bar", "y", NULL, NULL, NULL) },
 	{ },
 };
 =

-- =

2.0.4


--===============0274361769933736783==--

