Content-Type: multipart/mixed; boundary="===============0263943561399575012=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 16/21] dbus: Add support for checking if a property exists
Date: Thu, 13 Nov 2014 12:36:20 +0200
Message-ID: <1415874985-13034-17-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0263943561399575012==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As part of the org.freedesktop.DBus.Properties interface, it is
mandatory to provide a mean to check if a property is available or not
for the methods Get, GetAll and Set.
---
 ell/dbus-service.c |  9 +++++++--
 ell/dbus-service.h | 17 ++++++++++++-----
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index d297e68..b0f0063 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -516,7 +516,8 @@ static struct l_dbus_message *properties_get(struct l_d=
bus *dbus,
 					"No such interface '%s'", interface);
 =

 	property =3D _dbus_interface_find_property(instance->interface, name);
-	if (!property)
+	if (!property || (property->exists &&
+			!property->exists(property, instance->user_data)))
 		return l_dbus_message_new_error(message,
 					DBUS_ERROR_INVALID_ARGS,
 					"No such property '%s'", name);
@@ -570,6 +571,9 @@ static void append_properties(struct interface_instance=
 *instance,
 		if (!p->get)
 			continue;
 =

+		if (p->exists && !p->exists(p, instance->user_data))
+			continue;
+
 		append_property(instance, p, builder);
 	}
 =

@@ -655,7 +659,8 @@ static struct l_dbus_message *properties_set(struct l_d=
bus *dbus,
 					"No such interface '%s'", interface);
 =

 	property =3D _dbus_interface_find_property(instance->interface, name);
-	if (!property)
+	if (!property || (property->exists &&
+			!property->exists(property, instance->user_data)))
 		return l_dbus_message_new_error(message,
 					DBUS_ERROR_INVALID_ARGS,
 					"No such property '%s'", name);
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index 8e344f5..d5a9a8e 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -61,6 +61,8 @@ typedef void (*l_dbus_property_setter) (const struct l_db=
us_property *property,
 					struct l_dbus *dbus,
 					struct l_dbus_message_iter *iter,
 					uint32_t id, void *user_data);
+typedef bool (*l_dbus_property_exists) (const struct l_dbus_property *prop=
erty,
+							void *user_data);
 =

 struct l_dbus_argument {
 	const char *name;
@@ -86,6 +88,7 @@ struct l_dbus_property {
 	const char *type;
 	l_dbus_property_getter get;
 	l_dbus_property_setter set;
+	l_dbus_property_exists exists;
 	enum l_dbus_property_flag flags;
 };
 =

@@ -134,29 +137,33 @@ struct l_dbus_property {
 	.args =3D _args, \
 	.flags =3D L_DBUS_SIGNAL_FLAG_DEPRECATED
 =

-#define L_DBUS_RO_PROPERTY(_name, _type, _get) \
+#define L_DBUS_RO_PROPERTY(_name, _type, _get, _exists) \
 	.name =3D _name, \
 	.type =3D _type, \
-	.get =3D _get
+	.get =3D _get, \
+	.exists =3D _exists
 =

-#define L_DBUS_RW_PROPERTY(_name, _type, _get, _set) \
+#define L_DBUS_RW_PROPERTY(_name, _type, _get, _set, _exists) \
 	.name =3D _name, \
 	.type =3D _type, \
 	.get =3D _get, \
 	.set =3D _set, \
+	.exists =3D _exists, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE
 =

-#define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type, _get) \
+#define L_DBUS_RO_DEPRECATED_PROPERTY(_name, _type, _get, _exists) \
 	.name =3D _name, \
 	.type =3D _type, \
 	.get =3D _get, \
+	.exists =3D _exists, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

-#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type, _get, _set) \
+#define L_DBUS_RW_DEPRECATED_PROPERTY(_name, _type, _get, _set, _exists) \
 	.name =3D _name, \
 	.type =3D _type, \
 	.get =3D _get, \
 	.set =3D _set, \
+	.exists =3D _exists, \
 	.flags =3D L_DBUS_PROPERTY_FLAG_WRITABLE | \
 			L_DBUS_PROPERTY_FLAG_DEPRECATED
 =

-- =

2.0.4


--===============0263943561399575012==--

