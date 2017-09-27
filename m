Content-Type: multipart/mixed; boundary="===============5427952801540240146=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Free instance only after all references removed
Date: Wed, 27 Sep 2017 14:58:45 +0200
Message-ID: <20170927125845.20880-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5427952801540240146==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In _dbus_object_tree_remove_interface move the freeing of the instance
object to after we've dropped any queued Property Change and Interface
Added/Removed records referring to that instance.  We didn't really need
the object around for that (only the pointer) but we want to be extra
careful.
---
 ell/dbus-service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index c27ca84..43c7a5c 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1529,8 +1529,6 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 	if (!instance)
 		return false;
 =

-	interface_instance_free(instance);
-
 	if (!strcmp(interface, L_DBUS_INTERFACE_OBJECT_MANAGER)) {
 		manager =3D l_queue_remove_if(tree->object_managers,
 						match_object_manager_path,
@@ -1591,6 +1589,8 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 	if (property_change_rec)
 		property_change_record_free(property_change_rec);
 =

+	interface_instance_free(instance);
+
 	return true;
 }
 =

-- =

2.11.0


--===============5427952801540240146==--

