Content-Type: multipart/mixed; boundary="===============5929097972914549499=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Test dbus object tree with complicated paths
Date: Thu, 16 Aug 2018 04:04:32 +0200
Message-ID: <20180816020432.11506-3-andrew.zaborowski@intel.com>
In-Reply-To: <20180816020432.11506-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5929097972914549499==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In test-dbus-service build an object tree with all sorts of relations
between path elements including new subpath being a prefix of an
existing subpath.  The new test takes about a minute under valgrind.
---
 unit/test-dbus-service.c | 99 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 99 insertions(+)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 269e0e6..358aa94 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -299,6 +299,102 @@ static void test_dbus_object_tree_2(const void *test_=
data)
 	_dbus_object_tree_free(tree);
 }
 =

+#define TEST_3_OBJ_COUNT 20000
+static void test_dbus_object_tree_3(const void *test_data)
+{
+	struct _dbus_object_tree *tree;
+	char path[50];
+	struct l_hashmap *paths;
+	unsigned int count =3D 0;
+	struct l_dbus_message *message, *reply;
+	struct l_dbus_message_iter objects, interfaces;
+	const char *obj_path;
+
+	tree =3D _dbus_object_tree_new();
+	assert(tree);
+
+	assert(_dbus_object_tree_register_interface(tree, "org.example",
+						setup_dummy_interface,
+						NULL, false));
+
+	srand48(50);
+	paths =3D l_hashmap_string_new();
+	while (count < TEST_3_OBJ_COUNT) {
+		unsigned int len =3D 0;
+		unsigned int subpath_len =3D 0;
+		bool repeat;
+
+		/* Generate a random legal path composed of a, b and / chars */
+		path[len++] =3D '/';
+
+		while (len < sizeof(path) - 1) {
+			const char *allowed;
+			char ch;
+
+			if (subpath_len)
+				allowed =3D "aabb/E";
+			else /* At least one letter required after a / */
+				allowed =3D "ab";
+
+			ch =3D allowed[lrand48() % strlen(allowed)];
+
+			if (ch =3D=3D 'E')
+				break;
+			else if (ch =3D=3D '/')
+				subpath_len =3D 0;
+			else
+				subpath_len++;
+
+			path[len++] =3D ch;
+		}
+
+		/* Last character can't be a / */
+		if (path[len - 1] =3D=3D '/')
+			len--;
+		path[len] =3D '\0';
+
+		repeat =3D l_hashmap_lookup(paths, path) !=3D NULL;
+
+		assert(_dbus_object_tree_add_interface(tree, path,
+					"org.example", NULL) =3D=3D !repeat);
+
+		if (!repeat) {
+			l_hashmap_insert(paths, path, path);
+			count++;
+		}
+	}
+
+	assert(_dbus_object_tree_add_interface(tree, "/",
+					L_DBUS_INTERFACE_OBJECT_MANAGER, NULL));
+	l_hashmap_insert(paths, "/", path);
+
+	message =3D _dbus_message_new_method_call(1, "org.example", "/",
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
+						"GetManagedObjects");
+	l_dbus_message_set_arguments(message, "");
+	_dbus_message_set_serial(message, 0);
+
+	reply =3D _dbus_object_tree_get_objects(tree, NULL, "/", message);
+	assert(reply);
+	assert(!l_dbus_message_get_error(reply, NULL, NULL));
+	assert(l_dbus_message_get_arguments(reply, "a{oa{sa{sv}}}", &objects));
+
+	while (l_dbus_message_iter_next_entry(&objects, &obj_path, &interfaces))
+		assert(l_hashmap_remove(paths, obj_path));
+
+	l_dbus_message_unref(message);
+	l_dbus_message_unref(reply);
+
+	assert(l_hashmap_isempty(paths));
+	l_hashmap_destroy(paths, NULL);
+
+	assert(_dbus_object_tree_remove_interface(tree, "/",
+					L_DBUS_INTERFACE_OBJECT_MANAGER));
+
+	assert(_dbus_object_tree_unregister_interface(tree, "org.example"));
+	_dbus_object_tree_free(tree);
+}
+
 static struct l_dbus_message *get_modems_callback(struct l_dbus *dbus,
 					struct l_dbus_message *message,
 					void *user_data)
@@ -452,6 +548,9 @@ int main(int argc, char *argv[])
 	l_test_add("_dbus_object_tree Sanity Tests 2",
 					test_dbus_object_tree_2, NULL);
 =

+	l_test_add("_dbus_object_tree Sanity Tests 3",
+					test_dbus_object_tree_3, NULL);
+
 	l_test_add("_dbus_object_tree Introspection",
 					test_dbus_object_tree_introspection,
 					NULL);
-- =

2.14.1


--===============5929097972914549499==--

