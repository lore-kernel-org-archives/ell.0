Content-Type: multipart/mixed; boundary="===============5506528234979307376=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/10] unit: More Dbus object tree sanity tests
Date: Mon, 15 Feb 2016 17:44:16 +0100
Message-ID: <1455554662-15608-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455554662-15608-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5506528234979307376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test situations where interfaces are present on some nodes in the object
tree.
---
 unit/test-dbus-service.c | 82 ++++++++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 79 insertions(+), 3 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 2438e68..8a395b1 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -172,7 +172,7 @@ static void test_introspect_interface(const void *test_=
data)
 	l_free(xml);
 }
 =

-static void test_dbus_object_tree(const void *test_data)
+static void test_dbus_object_tree_1(const void *test_data)
 {
 	struct _dbus_object_tree *tree;
 	struct object_node *leaf1, *leaf2, *leaf3;
@@ -226,6 +226,79 @@ static void test_dbus_object_tree(const void *test_dat=
a)
 	_dbus_object_tree_free(tree);
 }
 =

+static void setup_dummy_interface(struct l_dbus_interface *iface)
+{
+}
+
+static void interface_destroy(void *data)
+{
+	bool *destroyed =3D data;
+
+	*destroyed =3D true;
+}
+
+static void test_dbus_object_tree_2(const void *test_data)
+{
+	struct _dbus_object_tree *tree;
+	bool destroyed[2] =3D { false, false };
+
+	tree =3D _dbus_object_tree_new();
+	assert(tree);
+
+	assert(_dbus_object_tree_new_object(tree, "/foo", NULL, NULL));
+	assert(_dbus_object_tree_new_object(tree, "/foo/bar/baz", NULL, NULL));
+
+	assert(_dbus_object_tree_lookup(tree, "/foo"));
+	assert(_dbus_object_tree_lookup(tree, "/foo/bar"));
+	assert(_dbus_object_tree_lookup(tree, "/foo/bar/baz"));
+
+	assert(_dbus_object_tree_register_interface(tree, "org.example",
+						setup_dummy_interface,
+						interface_destroy, false));
+
+	assert(_dbus_object_tree_add_interface(tree, "/foo",
+						"org.example", &destroyed[0]));
+	assert(!_dbus_object_tree_add_interface(tree, "/foo",
+						"org.other", NULL));
+	assert(_dbus_object_tree_add_interface(tree, "/foo/bar/baz",
+						"org.example", &destroyed[1]));
+
+	assert(!_dbus_object_tree_remove_interface(tree, "/foo", "org.other"));
+	assert(_dbus_object_tree_remove_interface(tree, "/foo", "org.example"));
+	assert(destroyed[0]);
+
+	assert(_dbus_object_tree_object_destroy(tree, "/foo"));
+	assert(!_dbus_object_tree_object_destroy(tree, "/foo/bar"));
+
+	assert(_dbus_object_tree_lookup(tree, "/foo"));
+	assert(_dbus_object_tree_lookup(tree, "/foo/bar"));
+	assert(_dbus_object_tree_lookup(tree, "/foo/bar/baz"));
+
+	destroyed[0] =3D false;
+	assert(_dbus_object_tree_add_interface(tree, "/foo",
+						"org.example", &destroyed[0]));
+
+	assert(_dbus_object_tree_object_destroy(tree, "/foo/bar/baz"));
+
+	assert(_dbus_object_tree_lookup(tree, "/foo"));
+	assert(!_dbus_object_tree_lookup(tree, "/foo/bar"));
+	assert(!_dbus_object_tree_lookup(tree, "/foo/bar/baz"));
+
+	assert(_dbus_object_tree_object_destroy(tree, "/foo"));
+	assert(destroyed[0] && destroyed[1]);
+	assert(!_dbus_object_tree_lookup(tree, "/foo"));
+
+	destroyed[0] =3D false;
+	assert(_dbus_object_tree_add_interface(tree, "/foo",
+						"org.example", &destroyed[0]));
+
+	assert(!_dbus_object_tree_unregister_interface(tree, "org.other"));
+	assert(_dbus_object_tree_unregister_interface(tree, "org.example"));
+	assert(destroyed[0]);
+
+	_dbus_object_tree_free(tree);
+}
+
 static struct l_dbus_message *get_modems_callback(struct l_dbus *dbus,
 					struct l_dbus_message *message,
 					void *user_data)
@@ -372,8 +445,11 @@ int main(int argc, char *argv[])
 	l_test_add("Test Interface Introspection", test_introspect_interface,
 			&interface_test);
 =

-	l_test_add("_dbus_object_tree Sanity Tests",
-					test_dbus_object_tree, NULL);
+	l_test_add("_dbus_object_tree Sanity Tests 1",
+					test_dbus_object_tree_1, NULL);
+
+	l_test_add("_dbus_object_tree Sanity Tests 2",
+					test_dbus_object_tree_2, NULL);
 =

 	l_test_add("_dbus_object_tree Introspection",
 					test_dbus_object_tree_introspection,
-- =

2.5.0


--===============5506528234979307376==--

