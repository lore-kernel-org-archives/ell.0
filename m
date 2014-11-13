Content-Type: multipart/mixed; boundary="===============7084923225259522338=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 05/21] unit: Apply the DBus interface methods API change to
 the tests
Date: Thu, 13 Nov 2014 12:36:09 +0200
Message-ID: <1415874985-13034-6-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7084923225259522338==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant methods array instead of function calls.
---
 unit/test-dbus-service.c | 38 ++++++++++++++++++++++++++------------
 unit/test-kdbus.c        | 12 ++++++------
 2 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 7452269..6e77e78 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -107,7 +107,7 @@ static const struct introspect_test interface_test =3D {
 static void test_introspect_method(const void *test_data)
 {
 	const struct introspect_test *test =3D test_data;
-	struct _dbus_method *method;
+	const struct l_dbus_method *method;
 	struct l_string *buf;
 	char *xml;
 =

@@ -238,8 +238,6 @@ static struct l_dbus_message *get_modems_callback(struc=
t l_dbus *dbus,
 =

 static void build_manager_interface(struct l_dbus_interface *iface)
 {
-	l_dbus_interface_method(iface, "GetModems", 0, get_modems_callback,
-				"a(oa{sv})", "", "modems");
 	l_dbus_interface_signal(iface, "ModemAdded", 0,
 				"oa{sv}", "path", "properties");
 	l_dbus_interface_signal(iface, "ModemRemoved", 0,
@@ -268,6 +266,13 @@ static const char *ofono_manager_introspection =3D
 	"\t<node name=3D\"phonesim\"/>\n"
 	"</node>\n";
 =

+static const struct l_dbus_method ofono_methods[] =3D {
+	{ L_DBUS_METHOD("GetModems",
+		NULL, L_DBUS_ARGS({ "modems", "a(oa{sv})" }),
+		get_modems_callback) },
+	{ },
+};
+
 static void test_dbus_object_tree_introspection(const void *test_data)
 {
 	struct _dbus_object_tree *tree;
@@ -277,7 +282,7 @@ static void test_dbus_object_tree_introspection(const v=
oid *test_data)
 	tree =3D _dbus_object_tree_new();
 =

 	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
+					ofono_methods, build_manager_interface,
 					NULL, NULL);
 =

 	_dbus_object_tree_makepath(tree, "/phonesim");
@@ -299,7 +304,7 @@ static void test_dbus_object_tree_dispatch(const void *=
test_data)
 	tree =3D _dbus_object_tree_new();
 =

 	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
+					ofono_methods, build_manager_interface,
 					dummy_data, NULL);
 =

 	message =3D _dbus_message_new_method_call(1, "org.ofono", "/",
@@ -315,6 +320,21 @@ static void test_dbus_object_tree_dispatch(const void =
*test_data)
 	_dbus_object_tree_free(tree);
 }
 =

+static const struct l_dbus_method sample_methods[] =3D {
+	{ L_DBUS_DEPRECATED_METHOD("Frobate",
+		L_DBUS_ARGS({ "foo", "i" }),
+		L_DBUS_ARGS({ "bar", "s"}, { "baz", "a{us}"}),
+		NULL) },
+	{ L_DBUS_METHOD("Bazify",
+		L_DBUS_ARGS({ "bar", "(iiu)"}),
+		L_DBUS_ARGS({ "bar", "v"}),
+		NULL) },
+	{ L_DBUS_METHOD("Mogrify",
+		L_DBUS_ARGS({ "bar", "(iiav)" }),
+		NULL, NULL) },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	int ret;
@@ -323,13 +343,7 @@ int main(int argc, char *argv[])
 =

 	l_test_init(&argc, &argv);
 =

-	l_dbus_interface_method(interface, "Frobate",
-				L_DBUS_METHOD_FLAG_DEPRECATED,
-				NULL, "sa{us}", "i", "bar", "baz", "foo");
-	l_dbus_interface_method(interface, "Bazify", 0, NULL, "v", "(iiu)",
-				"bar", "bar");
-	l_dbus_interface_method(interface, "Mogrify", 0, NULL, "",
-				"(iiav)", "bar");
+	_dbus_interface_methods(interface, sample_methods);
 =

 	l_dbus_interface_signal(interface, "Changed", 0, "b", "new_value");
 =

diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 4bf41bb..817a39f 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -116,11 +116,11 @@ static void service_ready_callback(void *user_data)
 	l_dbus_send(dbus, message);
 }
 =

-static void setup_test_interface(struct l_dbus_interface *interface)
-{
-	l_dbus_interface_method(interface, "TestMethod", 0,
-				test_method_call, "", "");
-}
+static const struct l_dbus_method test_methods[] =3D {
+	{ L_DBUS_METHOD("TestMethod",
+		NULL, NULL, test_method_call) },
+	{ },
+};
 =

 int main(int argc, char *argv[])
 {
@@ -159,7 +159,7 @@ int main(int argc, char *argv[])
 					service, NULL);
 =

 	if (!l_dbus_register_interface(service, "/test", "org.test",
-					setup_test_interface, NULL, NULL)) {
+					test_methods, NULL, NULL, NULL)) {
 		l_info("Unable to register interface");
 		goto error;
 	}
-- =

2.0.4


--===============7084923225259522338==--

