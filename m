Content-Type: multipart/mixed; boundary="===============1856271788266977890=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/9] dbus: Handle legacy GetProperties and SetProperty
 automatically.
Date: Wed, 10 Feb 2016 11:45:52 +0100
Message-ID: <1455101156-3587-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455101156-3587-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1856271788266977890==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In this version, for technical reasons, get_properties_dict just
returns false if any getter fails, and the builder is left in an
undefined state so the caller must return an error rather than
leaving out the property that failed (applies for .GetProperties,
Properties.GetAll, ObjectManager.GetManagedObjects and the
.InterfacesAdded signal).
---
 ell/dbus-private.h |   6 ++
 ell/dbus-service.c | 208 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 2 files changed, 214 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 8c58218..1af7201 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -197,6 +197,12 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_tr=
ee *tree,
 					struct l_dbus *dbus,
 					struct l_dbus_message *message);
 =

+void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+					const char *path,
+					const char *interface_name,
+					const char *property_name,
+					struct l_dbus_message_iter *variant);
+
 void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
 				const char *prefix, const char *str);
 void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 564b90f..01a60e3 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -718,6 +718,199 @@ bool _dbus_object_tree_object_destroy(struct _dbus_ob=
ject_tree *tree,
 	return true;
 }
 =

+void _dbus_object_tree_property_changed(struct l_dbus *dbus,
+					const char *path,
+					const char *interface_name,
+					const char *property_name,
+					struct l_dbus_message_iter *variant)
+{
+	struct l_dbus_message *signal;
+	struct l_dbus_message_builder *builder;
+	const struct _dbus_property *property;
+	const char *signature;
+	const struct interface_instance *instance;
+	const struct object_node *object;
+	struct l_dbus_message_iter value;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+	bool r;
+
+	object =3D l_hashmap_lookup(tree->objects, path);
+
+	instance =3D l_queue_find(object->instances, match_interface_instance,
+				interface_name);
+
+	property =3D _dbus_interface_find_property(instance->interface,
+							property_name);
+
+	signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+	if (instance->interface->handle_old_style_properties) {
+		signal =3D l_dbus_message_new_signal(dbus, path,
+							interface_name,
+							"PropertyChanged");
+
+		builder =3D l_dbus_message_builder_new(signal);
+
+		l_dbus_message_builder_append_basic(builder, 's',
+							property_name);
+		l_dbus_message_builder_enter_variant(builder, signature);
+
+		if (variant) {
+			memcpy(&value, variant, sizeof(value));
+			r =3D l_dbus_message_builder_append_from_iter(builder,
+								&value);
+		} else {
+			r =3D property->getter(dbus, signal, builder,
+						instance->user_data);
+		}
+
+		l_dbus_message_builder_leave_variant(builder);
+
+		l_dbus_message_builder_finalize(builder);
+		l_dbus_message_builder_destroy(builder);
+		if (r)
+			l_dbus_send(dbus, signal);
+	}
+}
+
+static void set_property_complete(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message *error)
+{
+	struct l_dbus_message *reply;
+	const char *property_name;
+	struct l_dbus_message_iter variant;
+
+	if (error) {
+		l_dbus_message_unref(message);
+
+		l_dbus_send(dbus, error);
+
+		return;
+	}
+
+	reply =3D l_dbus_message_new_method_return(message);
+	l_dbus_message_set_arguments(reply, "");
+	l_dbus_send(dbus, reply);
+
+	l_dbus_message_get_arguments(message, "sv", &property_name, &variant);
+
+	_dbus_object_tree_property_changed(dbus,
+					l_dbus_message_get_path(message),
+					l_dbus_message_get_interface(message),
+					property_name, &variant);
+
+	l_dbus_message_unref(message);
+}
+
+static struct l_dbus_message *old_set_property(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	struct l_dbus_interface *interface;
+	const char *property_name;
+	const struct _dbus_property *property;
+	struct l_dbus_message_iter variant;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	interface =3D l_hashmap_lookup(tree->interfaces,
+					l_dbus_message_get_interface(message));
+	/* If we got here the interface must exist */
+
+	if (!l_dbus_message_get_arguments(message, "sv", &property_name,
+						&variant))
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Invalid arguments");
+
+	property =3D _dbus_interface_find_property(interface, property_name);
+	if (!property)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Unknown Property %s",
+						property_name);
+
+	if (!property->setter)
+		return l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"InvalidArgs",
+						"Property %s is read-only",
+						property_name);
+
+	property->setter(dbus, l_dbus_message_ref(message), &variant,
+				set_property_complete, user_data);
+
+	return NULL;
+}
+
+static bool get_properties_dict(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				const struct l_dbus_interface *interface,
+				void *user_data)
+{
+	const struct l_queue_entry *entry;
+	const struct _dbus_property *property;
+	const char *signature;
+
+	l_dbus_message_builder_enter_array(builder, "{sv}");
+
+	for (entry =3D l_queue_get_entries(interface->properties); entry;
+			entry =3D entry->next) {
+		property =3D entry->data;
+		signature =3D property->metainfo + strlen(property->metainfo) + 1;
+
+		l_dbus_message_builder_enter_dict(builder, "sv");
+		l_dbus_message_builder_append_basic(builder, 's',
+							property->metainfo);
+		l_dbus_message_builder_enter_variant(builder, signature);
+
+		if (!property->getter(dbus, message, builder, user_data))
+			return false;
+
+		l_dbus_message_builder_leave_variant(builder);
+		l_dbus_message_builder_leave_dict(builder);
+	}
+
+	l_dbus_message_builder_leave_array(builder);
+
+	return true;
+}
+
+static struct l_dbus_message *old_get_properties(struct l_dbus *dbus,
+						struct l_dbus_message *message,
+						void *user_data)
+{
+	const struct l_dbus_interface *interface;
+	struct l_dbus_message *reply;
+	struct l_dbus_message_builder *builder;
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	interface =3D l_hashmap_lookup(tree->interfaces,
+					l_dbus_message_get_interface(message));
+	/* If we got here the interface must exist */
+
+	reply =3D l_dbus_message_new_method_return(message);
+	builder =3D l_dbus_message_builder_new(reply);
+
+	if (!get_properties_dict(dbus, message, builder, interface,
+					user_data)) {
+		l_dbus_message_unref(reply);
+
+		reply =3D l_dbus_message_new_error(message,
+						"org.freedesktop.DBus.Error."
+						"Failed",
+						"Getting properties failed");
+	} else
+		l_dbus_message_builder_finalize(builder);
+
+	l_dbus_message_builder_destroy(builder);
+
+	return reply;
+}
+
 bool _dbus_object_tree_register_interface(struct _dbus_object_tree *tree,
 				const char *interface,
 				void (*setup_func)(struct l_dbus_interface *),
@@ -741,6 +934,19 @@ bool _dbus_object_tree_register_interface(struct _dbus=
_object_tree *tree,
 	dbi->instance_destroy =3D destroy;
 	dbi->handle_old_style_properties =3D old_style_properties;
 =

+	/* Add our methods first so we don't have to check for conflicts. */
+	if (old_style_properties) {
+		l_dbus_interface_method(dbi, "SetProperty", 0,
+					old_set_property, "", "sv",
+					"name", "value");
+		l_dbus_interface_method(dbi, "GetProperties", 0,
+					old_get_properties, "a{sv}", "",
+					"properties");
+
+		l_dbus_interface_signal(dbi, "PropertyChanged", 0, "sv",
+					"name", "value");
+	}
+
 	setup_func(dbi);
 =

 	l_hashmap_insert(tree->interfaces, dbi->name, dbi);
@@ -948,4 +1154,6 @@ LIB_EXPORT void l_dbus_property_changed(struct l_dbus =
*dbus, const char *path,
 					const char *interface,
 					const char *property)
 {
+	_dbus_object_tree_property_changed(dbus, path, interface, property,
+						NULL);
 }
-- =

2.5.0


--===============1856271788266977890==--

