Content-Type: multipart/mixed; boundary="===============1768239319760162026=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/2] unit: Update to the new dbus property behavior
Date: Tue, 28 Jan 2020 14:13:48 -0600
Message-ID: <20200128201348.28916-2-denkenz@gmail.com>
In-Reply-To: <20200128201348.28916-1-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1768239319760162026==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-properties.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index d9e26799c220..b43506236938 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -280,9 +280,11 @@ static bool test_path_getter(struct l_dbus *dbus,
 =

 static void setup_test_interface(struct l_dbus_interface *interface)
 {
-	l_dbus_interface_property(interface, "String", 0, "s",
+	l_dbus_interface_property(interface, "String",
+					L_DBUS_PROPERTY_FLAG_AUTO_EMIT, "s",
 					test_string_getter, test_string_setter);
-	l_dbus_interface_property(interface, "Integer", 0, "u",
+	l_dbus_interface_property(interface, "Integer",
+					L_DBUS_PROPERTY_FLAG_AUTO_EMIT, "u",
 					test_int_getter, test_int_setter);
 	l_dbus_interface_property(interface, "Readonly", 0, "s",
 					test_string_getter, NULL);
-- =

2.21.0

--===============1768239319760162026==--

