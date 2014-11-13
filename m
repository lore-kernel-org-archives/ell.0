Content-Type: multipart/mixed; boundary="===============1739717940187425085=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 08/21] unit: Apply the DBus interface signals API change to
 the tests
Date: Thu, 13 Nov 2014 12:36:12 +0200
Message-ID: <1415874985-13034-9-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1739717940187425085==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use constant signals array instead of function calls.
---
 unit/test-dbus-service.c | 37 ++++++++++++++++++++++---------------
 unit/test-kdbus.c        |  3 ++-
 2 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 6e77e78..25b0951 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -125,7 +125,7 @@ static void test_introspect_method(const void *test_dat=
a)
 static void test_introspect_signal(const void *test_data)
 {
 	const struct introspect_test *test =3D test_data;
-	struct _dbus_signal *signal;
+	const struct l_dbus_signal *signal;
 	struct l_string *buf;
 	char *xml;
 =

@@ -236,14 +236,6 @@ static struct l_dbus_message *get_modems_callback(stru=
ct l_dbus *dbus,
 	return NULL;
 }
 =

-static void build_manager_interface(struct l_dbus_interface *iface)
-{
-	l_dbus_interface_signal(iface, "ModemAdded", 0,
-				"oa{sv}", "path", "properties");
-	l_dbus_interface_signal(iface, "ModemRemoved", 0,
-				"o", "path");
-}
-
 static const char *ofono_manager_introspection =3D
 	"<!DOCTYPE node PUBLIC \""
 	"-//freedesktop//DTD D-BUS Object Introspection 1.0//EN\"\n"
@@ -261,7 +253,8 @@ static const char *ofono_manager_introspection =3D
 	"\t\t\t<arg name=3D\"path\" type=3D\"o\"/>\n"
 	"\t\t\t<arg name=3D\"properties\" type=3D\"a{sv}\"/>\n"
 	"\t\t</signal>\n"
-	"\t\t<signal name=3D\"ModemRemoved\">\n"						"\t\t\t<arg name=3D\"path\"=
 type=3D\"o\"/>\n"
+	"\t\t<signal name=3D\"ModemRemoved\">\n"
+	"\t\t\t<arg name=3D\"path\" type=3D\"o\"/>\n"
 	"\t\t</signal>\n\t</interface>\n"
 	"\t<node name=3D\"phonesim\"/>\n"
 	"</node>\n";
@@ -273,6 +266,14 @@ static const struct l_dbus_method ofono_methods[] =3D {
 	{ },
 };
 =

+static const struct l_dbus_signal ofono_signals[] =3D {
+	{ L_DBUS_SIGNAL("ModemAdded",
+		L_DBUS_ARGS({ "path", "o" }, { "properties", "a{sv}" })) },
+	{ L_DBUS_SIGNAL("ModemRemoved",
+		L_DBUS_ARGS({ "path", "o" })) },
+	{ },
+};
+
 static void test_dbus_object_tree_introspection(const void *test_data)
 {
 	struct _dbus_object_tree *tree;
@@ -282,8 +283,8 @@ static void test_dbus_object_tree_introspection(const v=
oid *test_data)
 	tree =3D _dbus_object_tree_new();
 =

 	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					ofono_methods, build_manager_interface,
-					NULL, NULL);
+					ofono_methods, ofono_signals,
+					NULL, NULL, NULL);
 =

 	_dbus_object_tree_makepath(tree, "/phonesim");
 =

@@ -304,8 +305,8 @@ static void test_dbus_object_tree_dispatch(const void *=
test_data)
 	tree =3D _dbus_object_tree_new();
 =

 	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					ofono_methods, build_manager_interface,
-					dummy_data, NULL);
+					ofono_methods, ofono_signals,
+					NULL, dummy_data, NULL);
 =

 	message =3D _dbus_message_new_method_call(1, "org.ofono", "/",
 						"org.ofono.Manager",
@@ -335,6 +336,12 @@ static const struct l_dbus_method sample_methods[] =3D=
 {
 	{ },
 };
 =

+static const struct l_dbus_signal sample_signals[] =3D {
+	{ L_DBUS_SIGNAL("Changed",
+		L_DBUS_ARGS({ "new_value", "b" })) },
+	{ },
+};
+
 int main(int argc, char *argv[])
 {
 	int ret;
@@ -345,7 +352,7 @@ int main(int argc, char *argv[])
 =

 	_dbus_interface_methods(interface, sample_methods);
 =

-	l_dbus_interface_signal(interface, "Changed", 0, "b", "new_value");
+	_dbus_interface_signals(interface, sample_signals);
 =

 	l_dbus_interface_rw_property(interface, "Bar", "y");
 =

diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 817a39f..9470f75 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -159,7 +159,8 @@ int main(int argc, char *argv[])
 					service, NULL);
 =

 	if (!l_dbus_register_interface(service, "/test", "org.test",
-					test_methods, NULL, NULL, NULL)) {
+						test_methods, NULL,
+						NULL, NULL, NULL)) {
 		l_info("Unable to register interface");
 		goto error;
 	}
-- =

2.0.4


--===============1739717940187425085==--

