Content-Type: multipart/mixed; boundary="===============3445468173477826946=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 03/21] dbus: All interface related code is found in
 dbus-service.c
Date: Thu, 13 Nov 2014 12:36:07 +0200
Message-ID: <1415874985-13034-4-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3445468173477826946==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is necessary so it will be possible to register an interface at
once through description tables. Also makes the overall code split
more relevant.
---
 ell/dbus-service.c | 35 +++++++++++++++++++++++++++++++++++
 ell/dbus-service.h | 10 ++++++++++
 ell/dbus.c         | 29 -----------------------------
 ell/dbus.h         |  9 ---------
 4 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index e082226..a38de64 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -848,3 +848,38 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tr=
ee *tree,
 =

 	return true;
 }
+
+LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
+				const char *path, const char *interface,
+				l_dbus_interface_setup_func_t setup_func,
+				void *user_data,
+				l_dbus_destroy_func_t destroy)
+{
+	struct _dbus_object_tree *tree;
+
+	if (unlikely(!dbus))
+		return false;
+
+	tree =3D _dbus_object_tree_get_from_dbus(dbus);
+	if (unlikely(!tree))
+		return false;
+
+	return _dbus_object_tree_register(tree, path, interface,
+						setup_func, user_data, destroy);
+}
+
+LIB_EXPORT bool l_dbus_unregister_interface(struct l_dbus *dbus,
+						const char *path,
+						const char *interface)
+{
+	struct _dbus_object_tree *tree;
+
+	if (unlikely(!dbus))
+		return false;
+
+	tree =3D _dbus_object_tree_get_from_dbus(dbus);
+	if (unlikely(!tree))
+		return false;
+
+	return _dbus_object_tree_unregister(tree, path, interface);
+}
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index ce53082..6071740 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -49,10 +49,20 @@ enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_WRITABLE	=3D 2,
 };
 =

+typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface *);
 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *message,
 						void *user_data);
 =

+bool l_dbus_register_interface(struct l_dbus *dbus,
+				const char *path, const char *interface,
+				l_dbus_interface_setup_func_t setup_func,
+				void *user_data,
+				l_dbus_destroy_func_t destroy);
+
+bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
+					const char *interface);
+
 bool l_dbus_interface_method(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
 				l_dbus_interface_method_cb_t cb,
diff --git a/ell/dbus.c b/ell/dbus.c
index d5d58a9..ff7e814 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1203,32 +1203,3 @@ struct _dbus_object_tree *_dbus_object_tree_get_from=
_dbus(struct l_dbus *dbus)
 {
 	return dbus->tree;
 }
-
-LIB_EXPORT bool l_dbus_register_interface(struct l_dbus *dbus,
-				const char *path, const char *interface,
-				l_dbus_interface_setup_func_t setup_func,
-				void *user_data,
-				l_dbus_destroy_func_t destroy)
-{
-	if (unlikely(!dbus))
-		return false;
-
-	if (unlikely(!dbus->tree))
-		return false;
-
-	return _dbus_object_tree_register(dbus->tree, path, interface,
-						setup_func, user_data, destroy);
-}
-
-LIB_EXPORT bool l_dbus_unregister_interface(struct l_dbus *dbus,
-						const char *path,
-						const char *interface)
-{
-	if (unlikely(!dbus))
-		return false;
-
-	if (unlikely(!dbus->tree))
-		return false;
-
-	return _dbus_object_tree_unregister(dbus->tree, path, interface);
-}
diff --git a/ell/dbus.h b/ell/dbus.h
index 6dc9fc6..cec7c8c 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -46,7 +46,6 @@ typedef void (*l_dbus_disconnect_func_t) (void *user_data=
);
 =

 typedef void (*l_dbus_debug_func_t) (const char *str, void *user_data);
 typedef void (*l_dbus_destroy_func_t) (void *user_data);
-typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface *);
 =

 struct l_dbus *l_dbus_new(const char *address);
 struct l_dbus *l_dbus_new_default(enum l_dbus_bus bus);
@@ -190,14 +189,6 @@ bool l_dbus_message_builder_leave_variant(
 =

 struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder);
-
-bool l_dbus_register_interface(struct l_dbus *dbus,
-				const char *path, const char *interface,
-				l_dbus_interface_setup_func_t setup_func,
-				void *user_data,
-				l_dbus_destroy_func_t destroy);
-bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
-					const char *interface);
 #ifdef __cplusplus
 }
 #endif
-- =

2.0.4


--===============3445468173477826946==--

