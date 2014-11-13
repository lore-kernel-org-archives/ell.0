Content-Type: multipart/mixed; boundary="===============2832016353334579765=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 06/21] examples: Apply the DBus interface methods API change
Date: Thu, 13 Nov 2014 12:36:10 +0200
Message-ID: <1415874985-13034-7-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2832016353334579765==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant methods array instead of function calls.
---
 examples/dbus-service.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 40c1646..5630cad 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -189,15 +189,6 @@ static struct l_dbus_message *test_method_call(struct =
l_dbus *dbus,
 =

 static void setup_test_interface(struct l_dbus_interface *interface)
 {
-	l_dbus_interface_method(interface, "GetProperties", 0,
-				test_get_properties,
-				"a{sv}", "", "properties");
-	l_dbus_interface_method(interface, "SetProperty", 0,
-				test_set_property,
-				"", "sv", "name", "value");
-	l_dbus_interface_method(interface, "MethodCall", 0,
-				test_method_call, "", "");
-
 	l_dbus_interface_signal(interface, "PropertyChanged", 0,
 				"sv", "name", "value");
 =

@@ -205,6 +196,18 @@ static void setup_test_interface(struct l_dbus_interfa=
ce *interface)
 	l_dbus_interface_rw_property(interface, "Integer", "u");
 }
 =

+static const struct l_dbus_method test_methods[]  =3D {
+	{ L_DBUS_METHOD("GetProperties",
+		L_DBUS_ARGS({ "properties", "a{sv}" }), NULL,
+		test_get_properties) },
+	{ L_DBUS_METHOD("SetProperty",
+		NULL, L_DBUS_ARGS({ "name", "s" }, { "value", "v"}),
+		test_set_property) },
+	{ L_DBUS_METHOD("MethodCall",
+		NULL, NULL, test_method_call) },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	struct l_dbus *dbus;
@@ -235,8 +238,8 @@ int main(int argc, char *argv[])
 	test->integer =3D 42;
 =

 	if (!l_dbus_register_interface(dbus, "/test", "org.test",
-					setup_test_interface, test,
-					test_data_destroy)) {
+					test_methods, setup_test_interface,
+					test, test_data_destroy)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
 		goto cleanup;
-- =

2.0.4


--===============2832016353334579765==--

