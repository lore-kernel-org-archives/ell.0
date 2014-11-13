Content-Type: multipart/mixed; boundary="===============5596849827081974553=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 14/21] dbus: Add support for
 org.freedesktop.DBus.Properties.GetAll method
Date: Thu, 13 Nov 2014 12:36:18 +0200
Message-ID: <1415874985-13034-15-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5596849827081974553==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It is thus possible to get the whole subset of properties at once.
---
 ell/dbus-service.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 80 insertions(+)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index c745972..dbb52a6 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -520,11 +520,91 @@ static struct l_dbus_message *properties_get(struct l=
_dbus *dbus,
 	return reply;
 }
 =

+static void append_property(struct interface_instance *instance,
+				const struct l_dbus_property *property,
+				struct l_dbus_message_builder *builder)
+{
+	l_dbus_message_builder_enter_dict(builder, "sv");
+	l_dbus_message_builder_append_basic(builder, 's', property->name);
+	l_dbus_message_builder_enter_variant(builder, property->type);
+
+	property->get(property, builder, instance->user_data);
+
+	l_dbus_message_builder_leave_variant(builder);
+	l_dbus_message_builder_leave_dict(builder);
+}
+
+static void append_properties(struct interface_instance *instance,
+				struct l_dbus_message_builder *builder)
+{
+	const struct l_dbus_property *p;
+
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	for (p =3D instance->interface->properties; p && p->name; p++) {
+		if (!p->get)
+			continue;
+
+		append_property(instance, p, builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+}
+
+static struct l_dbus_message *properties_get_all(
+						struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const char *interface;
+	const char *path;
+	struct _dbus_object_tree *tree;
+	struct object_node *object;
+	struct interface_instance *instance;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+
+	if (!l_dbus_message_get_arguments(message, "s", &interface))
+		return NULL;
+
+	path =3D l_dbus_message_get_path(message);
+	tree =3D _dbus_object_tree_get_from_dbus(dbus);
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+	if (!object)
+		return l_dbus_message_new_error(message,
+						DBUS_ERROR_INVALID_ARGS,
+						"No such object '%s'", path);
+
+	instance =3D _dbus_object_find_instance(object, interface);
+	if (!instance)
+		return l_dbus_message_new_error(message,
+					DBUS_ERROR_INVALID_ARGS,
+					"No such interface '%s'", interface);
+
+	reply =3D l_dbus_message_new_method_return(message);
+	if (!reply)
+		return NULL;
+
+	builder =3D l_dbus_message_builder_new(reply);
+
+	append_properties(instance, builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
+}
+
 static const struct l_dbus_method properties_methods[] =3D {
 	{ L_DBUS_METHOD("Get",
 			L_DBUS_ARGS({ "interface", "s" }, { "name", "s" }),
 			L_DBUS_ARGS({ "value", "v" }),
 			properties_get) },
+	{ L_DBUS_METHOD("GetAll",
+			L_DBUS_ARGS({ "interface", "s" }),
+			L_DBUS_ARGS({ "properties", "a{sv}" }),
+			properties_get_all) },
 	{ }
 };
 =

-- =

2.0.4


--===============5596849827081974553==--

