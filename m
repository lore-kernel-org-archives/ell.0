Content-Type: multipart/mixed; boundary="===============3180176125364531792=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/9] dbus: setters and getters API for properties.
Date: Wed, 10 Feb 2016 11:45:50 +0100
Message-ID: <1455101156-3587-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3180176125364531792==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c | 34 +++++++++++++++-------------------
 ell/dbus-service.h | 29 +++++++++++++++++++++--------
 2 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 639872b..81036e5 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -61,6 +61,8 @@ struct _dbus_signal {
 };
 =

 struct _dbus_property {
+	l_dbus_property_get_cb_t getter;
+	l_dbus_property_set_cb_t setter;
 	uint32_t flags;
 	unsigned char name_len;
 	char metainfo[];
@@ -191,7 +193,7 @@ void _dbus_property_introspection(struct _dbus_property=
 *info,
 	l_string_append_printf(buf, "\t\t<property name=3D\"%s\" type=3D\"%s\" ",
 				info->metainfo, signature);
 =

-	if (info->flags & L_DBUS_PROPERTY_FLAG_WRITABLE)
+	if (info->setter)
 		l_string_append(buf, "access=3D\"readwrite\"");
 	else
 		l_string_append(buf, "access=3D\"read\"");
@@ -375,7 +377,9 @@ LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_i=
nterface *interface,
 =

 LIB_EXPORT bool l_dbus_interface_property(struct l_dbus_interface *interfa=
ce,
 					const char *name, uint32_t flags,
-					const char *signature)
+					const char *signature,
+					l_dbus_property_get_cb_t getter,
+					l_dbus_property_set_cb_t setter)
 {
 	unsigned int metainfo_len;
 	struct _dbus_property *info;
@@ -384,7 +388,7 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbus=
_interface *interface,
 	if (!_dbus_valid_method(name))
 		return false;
 =

-	if (unlikely(!signature))
+	if (unlikely(!signature || !getter))
 		return false;
 =

 	if (!_dbus_valid_signature(signature))
@@ -397,6 +401,8 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbus=
_interface *interface,
 	info =3D l_malloc(sizeof(*info) + metainfo_len);
 	info->flags =3D flags;
 	info->name_len =3D strlen(name);
+	info->getter =3D getter;
+	info->setter =3D setter;
 =

 	p =3D stpcpy(info->metainfo, name) + 1;
 	strcpy(p, signature);
@@ -406,22 +412,6 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbu=
s_interface *interface,
 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_ro_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name, 0, signature);
-}
-
-LIB_EXPORT bool l_dbus_interface_rw_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name,
-					L_DBUS_PROPERTY_FLAG_WRITABLE,
-					signature);
-}
-
 struct l_dbus_interface *_dbus_interface_new(const char *name)
 {
 	struct l_dbus_interface *interface;
@@ -853,3 +843,9 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tre=
e *tree,
 =

 	return true;
 }
+
+LIB_EXPORT void l_dbus_property_changed(struct l_dbus *dbus, const char *p=
ath,
+					const char *interface,
+					const char *property)
+{
+}
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index ce53082..619d9a6 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -46,13 +46,27 @@ enum l_dbus_signal_flag {
 =

 enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_DEPRECATED =3D 1,
-	L_DBUS_PROPERTY_FLAG_WRITABLE	=3D 2,
 };
 =

 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *message,
 						void *user_data);
 =

+typedef void (*l_dbus_property_complete_cb_t) (struct l_dbus *,
+						struct l_dbus_message *,
+						struct l_dbus_message *error);
+
+typedef void (*l_dbus_property_set_cb_t) (struct l_dbus *,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data);
+
+typedef bool (*l_dbus_property_get_cb_t) (struct l_dbus *,
+					struct l_dbus_message *message,
+					struct l_dbus_message_builder *builder,
+					void *user_data);
+
 bool l_dbus_interface_method(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
 				l_dbus_interface_method_cb_t cb,
@@ -65,13 +79,12 @@ bool l_dbus_interface_signal(struct l_dbus_interface *i=
nterface,
 =

 bool l_dbus_interface_property(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
-				const char *signature);
-bool l_dbus_interface_ro_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
-bool l_dbus_interface_rw_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
+				const char *signature,
+				l_dbus_property_get_cb_t getter,
+				l_dbus_property_set_cb_t setter);
+
+void l_dbus_property_changed(struct l_dbus *dbus, const char *path,
+				const char *interface, const char *property);
 =

 #ifdef __cplusplus
 }
-- =

2.5.0


--===============3180176125364531792==--

