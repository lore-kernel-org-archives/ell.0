Content-Type: multipart/mixed; boundary="===============2333366990619576778=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 9/9] test: update to new dbus API
Date: Wed, 10 Feb 2016 11:45:56 +0100
Message-ID: <1455101156-3587-10-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2333366990619576778==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-service.c | 35 ++++++++++++++++++++++++++++-------
 unit/test-kdbus.c        |  9 +++++++--
 2 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 7452269..2438e68 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -276,9 +276,10 @@ static void test_dbus_object_tree_introspection(const =
void *test_data)
 =

 	tree =3D _dbus_object_tree_new();
 =

-	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
-					NULL, NULL);
+	_dbus_object_tree_register_interface(tree, "org.ofono.Manager",
+						build_manager_interface,
+						NULL, false);
+	_dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager", NULL);
 =

 	_dbus_object_tree_makepath(tree, "/phonesim");
 =

@@ -298,9 +299,11 @@ static void test_dbus_object_tree_dispatch(const void =
*test_data)
 =

 	tree =3D _dbus_object_tree_new();
 =

-	_dbus_object_tree_register(tree, "/", "org.ofono.Manager",
-					build_manager_interface,
-					dummy_data, NULL);
+	_dbus_object_tree_register_interface(tree, "org.ofono.Manager",
+						build_manager_interface,
+						NULL, false);
+	_dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager",
+					dummy_data);
 =

 	message =3D _dbus_message_new_method_call(1, "org.ofono", "/",
 						"org.ofono.Manager",
@@ -315,6 +318,22 @@ static void test_dbus_object_tree_dispatch(const void =
*test_data)
 	_dbus_object_tree_free(tree);
 }
 =

+static bool test_property_getter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_builder *builder,
+					void *if_user_data)
+{
+	return true;
+}
+
+static void test_property_setter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data)
+{
+}
+
 int main(int argc, char *argv[])
 {
 	int ret;
@@ -333,7 +352,9 @@ int main(int argc, char *argv[])
 =

 	l_dbus_interface_signal(interface, "Changed", 0, "b", "new_value");
 =

-	l_dbus_interface_rw_property(interface, "Bar", "y");
+	l_dbus_interface_property(interface, "Bar", 0, "y",
+					test_property_getter,
+					test_property_setter);
 =

 	l_test_add("Test Frobate Introspection", test_introspect_method,
 			&frobate_test);
diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
index 4bf41bb..3a6af3e 100644
--- a/unit/test-kdbus.c
+++ b/unit/test-kdbus.c
@@ -158,12 +158,17 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(service, service_ready_callback,
 					service, NULL);
 =

-	if (!l_dbus_register_interface(service, "/test", "org.test",
-					setup_test_interface, NULL, NULL)) {
+	if (!l_dbus_register_interface(service, "org.test",
+					setup_test_interface, NULL, false)) {
 		l_info("Unable to register interface");
 		goto error;
 	}
 =

+	if (!l_dbus_object_add_interface(service, "/test", "org.test", NULL)) {
+		l_info("Unable to instantiate interface");
+		goto error;
+	}
+
 	client =3D l_dbus_new(bus_address);
 	assert(client);
 =

-- =

2.5.0


--===============2333366990619576778==--

