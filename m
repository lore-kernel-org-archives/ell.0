Content-Type: multipart/mixed; boundary="===============1234209300990114983=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 12/21] examples: Apply the DBus interface properties API change
Date: Thu, 13 Nov 2014 12:36:16 +0200
Message-ID: <1415874985-13034-13-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1234209300990114983==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant properties array instead of function calls.
---
 examples/dbus-service.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index cb9a308..06cf1d9 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -187,12 +187,6 @@ static struct l_dbus_message *test_method_call(struct =
l_dbus *dbus,
 	return reply;
 }
 =

-static void setup_test_interface(struct l_dbus_interface *interface)
-{
-	l_dbus_interface_rw_property(interface, "String", "s");
-	l_dbus_interface_rw_property(interface, "Integer", "u");
-}
-
 static const struct l_dbus_method test_methods[]  =3D {
 	{ L_DBUS_METHOD("GetProperties",
 		L_DBUS_ARGS({ "properties", "a{sv}" }), NULL,
@@ -211,6 +205,12 @@ static const struct l_dbus_signal test_signals[] =3D {
 	{ },
 };
 =

+static const struct l_dbus_property test_properties[] =3D {
+	{ L_DBUS_RW_PROPERTY("String", "s") },
+	{ L_DBUS_RW_PROPERTY("Integer", "u") },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	struct l_dbus *dbus;
@@ -242,8 +242,8 @@ int main(int argc, char *argv[])
 =

 	if (!l_dbus_register_interface(dbus, "/test", "org.test",
 					test_methods, test_signals,
-					setup_test_interface,
-					test, test_data_destroy)) {
+					test_properties, test,
+					test_data_destroy)) {
 		l_info("Unable to register interface");
 		test_data_destroy(test);
 		goto cleanup;
-- =

2.0.4


--===============1234209300990114983==--

