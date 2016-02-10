Content-Type: multipart/mixed; boundary="===============5570525727431424877=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Fix read after free during cleanup
Date: Wed, 10 Feb 2016 11:45:47 +0100
Message-ID: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5570525727431424877==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

subtree_free will be checking if interfaces of objects being freed have
a destroy callback so the interfaces should not be freed before that.
---
 ell/dbus-service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 5d49836..1e3bb66 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -583,12 +583,12 @@ static void object_manager_free(void *data)
 =

 void _dbus_object_tree_free(struct _dbus_object_tree *tree)
 {
+	subtree_free(tree->root);
+
 	l_hashmap_destroy(tree->interfaces,
 			(l_hashmap_destroy_func_t) _dbus_interface_free);
 	l_hashmap_destroy(tree->objects, NULL);
 =

-	subtree_free(tree->root);
-
 	l_queue_destroy(tree->object_managers, object_manager_free);
 =

 	l_free(tree);
-- =

2.5.0


--===============5570525727431424877==--

