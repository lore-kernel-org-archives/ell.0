Content-Type: multipart/mixed; boundary="===============6554211716387502499=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] dbus: Move standard interface name defines to public
 header.
Date: Thu, 18 Feb 2016 04:20:10 +0100
Message-ID: <1455765612-6577-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6554211716387502499==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c | 19 ++++++++-----------
 ell/dbus.c         | 12 ++++--------
 ell/dbus.h         |  5 +++++
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 063cdd3..f875437 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -50,9 +50,6 @@ static const char *static_introspectable =3D
 		"\t\t\t<arg name=3D\"xml\" type=3D\"s\" direction=3D\"out\"/>\n"
 		"\t\t</method>\n\t</interface>\n";
 =

-#define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
-#define DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManager"
-
 struct _dbus_method {
 	l_dbus_interface_method_cb_t cb;
 	uint32_t flags;
@@ -591,14 +588,14 @@ struct _dbus_object_tree *_dbus_object_tree_new()
 =

 	tree->property_changes =3D l_queue_new();
 =

-	_dbus_object_tree_register_interface(tree, DBUS_INTERFACE_PROPERTIES,
+	_dbus_object_tree_register_interface(tree, L_DBUS_INTERFACE_PROPERTIES,
 						properties_setup_func, NULL,
 						false);
 =

 	tree->object_managers =3D l_queue_new();
 =

 	_dbus_object_tree_register_interface(tree,
-						DBUS_INTERFACE_OBJECT_MANAGER,
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
 						object_manager_setup_func, NULL,
 						false);
 =

@@ -867,7 +864,7 @@ static struct l_dbus_message *build_interfaces_removed_=
signal(
 	const struct l_queue_entry *entry;
 =

 	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
-						DBUS_INTERFACE_OBJECT_MANAGER,
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
 						"InterfacesRemoved");
 =

 	builder =3D l_dbus_message_builder_new(signal);
@@ -896,7 +893,7 @@ static struct l_dbus_message *build_interfaces_added_si=
gnal(
 	const struct interface_instance *instance;
 =

 	signal =3D l_dbus_message_new_signal(manager->dbus, manager->path,
-						DBUS_INTERFACE_OBJECT_MANAGER,
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
 						"InterfacesAdded");
 =

 	builder =3D l_dbus_message_builder_new(signal);
@@ -978,7 +975,7 @@ static struct l_dbus_message *build_properties_changed_=
signal(
 	const char *signature;
 =

 	signal =3D l_dbus_message_new_signal(dbus, rec->path,
-						DBUS_INTERFACE_PROPERTIES,
+						L_DBUS_INTERFACE_PROPERTIES,
 						"PropertiesChanged");
 =

 	builder =3D l_dbus_message_builder_new(signal);
@@ -1074,7 +1071,7 @@ static void emit_signals(struct l_idle *idle, void *u=
ser_data)
 =

 		if (l_queue_find(property_changes_rec->object->instances,
 					match_interface_instance,
-					DBUS_INTERFACE_PROPERTIES)) {
+					L_DBUS_INTERFACE_PROPERTIES)) {
 			signal =3D build_properties_changed_signal(dbus,
 							property_changes_rec);
 			if (signal)
@@ -1420,7 +1417,7 @@ bool _dbus_object_tree_add_interface(struct _dbus_obj=
ect_tree *tree,
 		schedule_emit_signals(manager->dbus);
 	}
 =

-	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
+	if (!strcmp(interface, L_DBUS_INTERFACE_OBJECT_MANAGER)) {
 		manager =3D l_new(struct object_manager, 1);
 		manager->path =3D l_strdup(path);
 		manager->dbus =3D instance->user_data;
@@ -1463,7 +1460,7 @@ bool _dbus_object_tree_remove_interface(struct _dbus_=
object_tree *tree,
 =

 	interface_instance_free(instance);
 =

-	if (!strcmp(interface, DBUS_INTERFACE_OBJECT_MANAGER)) {
+	if (!strcmp(interface, L_DBUS_INTERFACE_OBJECT_MANAGER)) {
 		manager =3D l_queue_remove_if(tree->object_managers,
 						match_object_manager_path,
 						(char *) path);
diff --git a/ell/dbus.c b/ell/dbus.c
index 153bd0b..730eb74 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -49,10 +49,6 @@
 =

 #define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
 =

-#define DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
-#define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
-#define DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManager"
-
 #define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
 =

 enum auth_state {
@@ -408,7 +404,7 @@ static bool auth_write_handler(struct l_io *io, void *u=
ser_data)
 		message =3D l_dbus_message_new_method_call(dbus,
 							DBUS_SERVICE_DBUS,
 							DBUS_PATH_DBUS,
-							DBUS_INTERFACE_DBUS,
+							L_DBUS_INTERFACE_DBUS,
 							"Hello");
 		l_dbus_message_set_arguments(message, "");
 =

@@ -1390,7 +1386,7 @@ LIB_EXPORT bool l_dbus_object_manager_enable(struct l=
_dbus *dbus)
 		return false;
 =

 	return _dbus_object_tree_add_interface(dbus->tree, "/",
-						DBUS_INTERFACE_OBJECT_MANAGER,
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
 						dbus);
 }
 =

@@ -1471,7 +1467,7 @@ static void dbus1_send_match(struct l_dbus *dbus, con=
st char *rule,
 	message =3D l_dbus_message_new_method_call(dbus,
 						DBUS_SERVICE_DBUS,
 						DBUS_PATH_DBUS,
-						DBUS_INTERFACE_DBUS,
+						L_DBUS_INTERFACE_DBUS,
 						method);
 =

 	l_dbus_message_set_arguments(message, "s", rule);
@@ -1577,7 +1573,7 @@ LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(s=
truct l_dbus *dbus,
 =

 	data =3D _dbus1_filter_data_get(dbus, _dbus1_name_owner_changed_filter,
 				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
-				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
+				L_DBUS_INTERFACE_DBUS, "NameOwnerChanged",
 				name,
 				disconnect_func,
 				user_data,
diff --git a/ell/dbus.h b/ell/dbus.h
index 84bf7a4..3f1a5f7 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -32,6 +32,11 @@
 extern "C" {
 #endif
 =

+#define L_DBUS_INTERFACE_DBUS		"org.freedesktop.DBus"
+#define L_DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectab=
le"
+#define L_DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
+#define L_DBUS_INTERFACE_OBJECT_MANAGER	"org.freedesktop.DBus.ObjectManage=
r"
+
 enum l_dbus_bus {
 	L_DBUS_SYSTEM_BUS,
 	L_DBUS_SESSION_BUS,
-- =

2.5.0


--===============6554211716387502499==--

