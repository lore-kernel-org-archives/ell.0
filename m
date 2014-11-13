Content-Type: multipart/mixed; boundary="===============4024284923785740653=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 09/21] examples: Apply the DBus interface signals API change
Date: Thu, 13 Nov 2014 12:36:13 +0200
Message-ID: <1415874985-13034-10-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4024284923785740653==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant signals array instead of function calls.
---
 examples/dbus-service.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 5630cad..cb9a308 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -189,9 +189,6 @@ static struct l_dbus_message *test_method_call(struct l=
_dbus *dbus,
 =

 static void setup_test_interface(struct l_dbus_interface *interface)
 {
-	l_dbus_interface_signal(interface, "PropertyChanged", 0,
-				"sv", "name", "value");
-
 	l_dbus_interface_rw_property(interface, "String", "s");
 	l_dbus_interface_rw_property(interface, "Integer", "u");
 }
@@ -208,6 +205,12 @@ static const struct l_dbus_method test_methods[]  =3D {
 	{ },
 };
 =

+static const struct l_dbus_signal test_signals[] =3D {
+	{ L_DBUS_SIGNAL("PropertyChanged",
+		L_DBUS_ARGS({ "name", "s" }, { "value", "v" })) },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	struct l_dbus *dbus;
@@ -238,7 +241,8 @@ int main(int argc, char *argv[])
 	test->integer =3D 42;
 =

 	if (!l_dbus_register_interface(dbus, "/test", "org.test",
-					test_methods, setup_test_interface,
+					test_methods, test_signals,
+					setup_test_interface,
 					test, test_data_destroy)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
-- =

2.0.4


--===============4024284923785740653==--

