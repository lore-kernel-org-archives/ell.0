Content-Type: multipart/mixed; boundary="===============7794149101274995110=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] unit: Update _dbus_object_tree_prune_node call parameters.
Date: Mon, 01 Feb 2016 15:07:18 +0100
Message-ID: <1454335644-17088-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454335644-17088-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7794149101274995110==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-service.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 7452269..68c35c1 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -205,16 +205,16 @@ static void test_dbus_object_tree(const void *test_da=
ta)
 =

 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf3);
+	_dbus_object_tree_prune_node(tree, leaf3, "/foo/bee/boo");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
 	assert(!tmp);
 =

 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf2);
+	_dbus_object_tree_prune_node(tree, leaf2, "/foo/bar/ble");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(tmp);
-	_dbus_object_tree_prune_node(leaf1);
+	_dbus_object_tree_prune_node(tree, leaf1, "/foo/bar/baz");
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
 	assert(!tmp);
 	tmp =3D _dbus_object_tree_lookup(tree, "/foo");
-- =

2.5.0


--===============7794149101274995110==--

