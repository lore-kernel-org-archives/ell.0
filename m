Content-Type: multipart/mixed; boundary="===============2059819874465662185=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Use ptr match instead of string match where possible
Date: Sat, 24 Aug 2019 02:53:37 +0200
Message-ID: <20190824005337.24469-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190824005337.24469-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2059819874465662185==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Slightly optimize the interface lookup where we already have the pointer
to the interface struct to only look for that pointer instead of the
interface name match.
---
 ell/dbus-service.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index a1a7a74..9b23613 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -524,6 +524,13 @@ static bool match_interface_instance(const void *a, co=
nst void *b)
 	return false;
 }
 =

+static bool match_interface_instance_ptr(const void *a, const void *b)
+{
+	const struct interface_instance *instance =3D a;
+
+	return instance->interface =3D=3D b;
+}
+
 static void interface_add_record_free(void *data)
 {
 	struct interface_add_record *rec =3D data;
@@ -1499,8 +1506,7 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 	 * Check to make sure we do not have this interface already
 	 * registered for this object
 	 */
-	if (l_queue_find(object->instances, match_interface_instance,
-				(char *) interface))
+	if (l_queue_find(object->instances, match_interface_instance_ptr, dbi))
 		return false;
 =

 	instance =3D l_new(struct interface_instance, 1);
@@ -1892,8 +1898,7 @@ static struct l_dbus_message *properties_set(struct l=
_dbus *dbus,
 	/* If we got here the object must exist */
 =

 	instance =3D l_queue_find(object->instances,
-				match_interface_instance,
-				(char *) interface_name);
+				match_interface_instance_ptr, interface);
 	if (!instance)
 		return l_dbus_message_new_error(message,
 						"org.freedesktop.DBus.Error."
-- =

2.20.1


--===============2059819874465662185==--

