Content-Type: multipart/mixed; boundary="===============8400970638318305417=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 3/6] dbus: Add support for proxy interface
Date: Fri, 01 Dec 2017 16:06:07 +0100
Message-ID: <20171201150610.9696-4-szymon.janc@codecoup.pl>
In-Reply-To: <20171201150610.9696-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8400970638318305417==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am       |   2 +
 ell/dbus-client.c | 570 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-client.h |  82 ++++++++
 ell/ell.h         |   1 +
 4 files changed, 655 insertions(+)
 create mode 100644 ell/dbus-client.c
 create mode 100644 ell/dbus-client.h

diff --git a/Makefile.am b/Makefile.am
index a95bac4..19b957e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -32,6 +32,7 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/genl.h \
 			ell/dbus.h \
 			ell/dbus-service.h \
+			ell/dbus-client.h \
 			ell/hwdb.h \
 			ell/cipher.h \
 			ell/random.h \
@@ -74,6 +75,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dbus-message.c \
 			ell/dbus-util.c \
 			ell/dbus-service.c \
+			ell/dbus-client.c \
 			ell/dbus-name-cache.c \
 			ell/dbus-filter.c \
 			ell/gvariant-private.h \
diff --git a/ell/dbus-client.c b/ell/dbus-client.c
new file mode 100644
index 0000000..f07a183
--- /dev/null
+++ b/ell/dbus-client.c
@@ -0,0 +1,570 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2017  Codecoup. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include "ell.h"
+#include "private.h"
+
+struct l_dbus_client {
+	struct l_dbus *dbus;
+	unsigned int watch;
+	unsigned int added_watch;
+	unsigned int removed_watch;
+	char *service;
+	char *path;
+	uint32_t objects_call;
+
+	l_dbus_watch_func_t connect_cb;
+	void *connect_cb_data;
+	l_dbus_destroy_func_t connect_cb_data_destroy;
+
+	l_dbus_watch_func_t disconnect_cb;
+	void *disconnect_cb_data;
+	l_dbus_destroy_func_t disconnect_cb_data_destroy;
+
+	l_dbus_client_ready_func_t ready_cb;
+	void *ready_cb_data;
+	l_dbus_destroy_func_t ready_cb_data_destroy;
+
+	l_dbus_client_proxy_func_t proxy_added_cb;
+	l_dbus_client_proxy_func_t proxy_removed_cb;
+	l_dbus_client_property_function_t properties_changed_cb;
+	void *proxy_cb_data;
+	l_dbus_destroy_func_t proxy_cb_data_destroy;
+
+	struct l_queue *proxies;
+};
+
+struct proxy_property {
+	char *name;
+	struct l_dbus_message *msg;
+};
+
+struct l_dbus_proxy {
+	struct l_dbus_client *client;
+	char *interface;
+	char *path;
+	uint32_t properties_watch;
+	bool ready;
+
+	struct l_queue *properties;
+};
+
+LIB_EXPORT const char *l_dbus_proxy_get_path(struct l_dbus_proxy *proxy)
+{
+	if (unlikely(!proxy))
+		return NULL;
+
+	return proxy->path;
+}
+
+LIB_EXPORT const char *l_dbus_proxy_get_interface(struct l_dbus_proxy *pro=
xy)
+{
+	if (unlikely(!proxy))
+		return NULL;
+
+	return proxy->interface;
+}
+
+static bool property_match_by_name(const void *a, const void *b)
+{
+	const struct proxy_property *prop =3D a;
+	const char *name =3D b;
+
+	return !strcmp(prop->name, name);
+}
+
+static struct proxy_property *find_property(struct l_dbus_proxy *proxy,
+							const char *name)
+{
+	return l_queue_find(proxy->properties, property_match_by_name, name);
+}
+
+static struct proxy_property *get_property(struct l_dbus_proxy *proxy,
+							const char *name)
+{
+	struct proxy_property *prop;
+
+	prop =3D find_property(proxy, name);
+	if (prop)
+		return prop;
+
+	prop =3D l_new(struct proxy_property, 1);
+	prop->name =3D l_strdup(name);
+
+	l_queue_push_tail(proxy->properties, prop);
+
+	return prop;
+}
+
+LIB_EXPORT bool l_dbus_proxy_get_property(struct l_dbus_proxy *proxy,
+						const char *name,
+						const char *signature, ...)
+{
+	struct proxy_property *prop;
+	va_list args;
+	bool res;
+
+	if (unlikely(!proxy))
+		return false;
+
+	prop =3D find_property(proxy, name);
+	if (!prop)
+		return false;
+
+	va_start(args, signature);
+	res =3D l_dbus_message_get_arguments_valist(prop->msg, signature, args);
+	va_end(args);
+
+	return res;
+}
+
+static void property_free(void *data)
+{
+	struct proxy_property *prop =3D data;
+
+	if (prop->msg)
+		l_dbus_message_unref(prop->msg);
+
+	l_free(prop->name);
+	l_free(prop);
+}
+
+static void l_dbus_proxy_destroy(struct l_dbus_proxy *proxy)
+{
+	if (unlikely(!proxy))
+		return;
+
+	if (proxy->properties_watch)
+		l_dbus_remove_signal_watch(proxy->client->dbus,
+						proxy->properties_watch);
+
+	l_queue_destroy(proxy->properties, property_free);
+	l_free(proxy->interface);
+	l_free(proxy->path);
+	l_free(proxy);
+}
+
+static void proxy_update_property(struct l_dbus_proxy *proxy,
+					const char *name,
+					struct l_dbus_message_iter *property)
+{
+	struct l_dbus_message_builder *builder;
+	struct proxy_property *prop =3D get_property(proxy, name);
+
+	l_dbus_message_unref(prop->msg);
+
+	if (!property) {
+		prop->msg =3D NULL;
+		goto done;
+	}
+
+	prop->msg =3D l_dbus_message_new_signal(proxy->client->dbus, proxy->path,
+							proxy->interface, name);
+	if (!prop->msg)
+		return;
+
+	builder =3D l_dbus_message_builder_new(prop->msg);
+	l_dbus_message_builder_append_from_iter(builder, property);
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+done:
+	if (proxy->client->properties_changed_cb && proxy->ready)
+		proxy->client->properties_changed_cb(proxy, name, prop->msg,
+					proxy->client->proxy_cb_data_destroy);
+}
+
+static void proxy_invalidate_properties(struct l_dbus_proxy *proxy,
+					struct l_dbus_message_iter* props)
+{
+	const char *name;
+
+	while (l_dbus_message_iter_next_entry(props, &name))
+		proxy_update_property(proxy, name, NULL);
+}
+
+static void proxy_update_properties(struct l_dbus_proxy *proxy,
+					struct l_dbus_message_iter* props)
+{
+	struct l_dbus_message_iter variant;
+	const char *name;
+
+	while (l_dbus_message_iter_next_entry(props, &name, &variant))
+		proxy_update_property(proxy, name, &variant);
+}
+
+static void properties_changed_callback(struct l_dbus_message *message,
+								void *user_data)
+{
+	struct l_dbus_proxy *proxy =3D user_data;
+	const char *interface;
+	struct l_dbus_message_iter changed;
+	struct l_dbus_message_iter invalidated;
+
+	if (!l_dbus_message_get_arguments(message, "sa{sv}as", &interface,
+							&changed, &invalidated))
+		return;
+
+	proxy_update_properties(proxy, &changed);
+	proxy_invalidate_properties(proxy, &invalidated);
+}
+
+static struct l_dbus_proxy *l_dbus_proxy_new(struct l_dbus_client *client,
+					const char *path, const char *interface)
+{
+	struct l_dbus_proxy *proxy;
+
+	proxy =3D l_new(struct l_dbus_proxy, 1);
+
+	proxy->properties_watch =3D l_dbus_add_signal_watch(client->dbus,
+						client->service, path,
+						L_DBUS_INTERFACE_PROPERTIES,
+						"PropertiesChanged",
+						L_DBUS_MATCH_ARGUMENT(0),
+						interface, L_DBUS_MATCH_NONE,
+						properties_changed_callback,
+						proxy);
+	if (!proxy->properties_watch) {
+		l_free(proxy);
+		return NULL;
+	}
+
+	proxy->client =3D client;
+	proxy->interface =3D l_strdup(interface);
+	proxy->path =3D l_strdup(path);
+	proxy->properties =3D l_queue_new();
+
+	l_queue_push_tail(client->proxies, proxy);
+
+	return proxy;
+}
+
+static bool is_ignorable(const char *interface)
+{
+	static const struct {
+		const char *interface;
+	} interfaces_to_ignore[] =3D {
+		{ L_DBUS_INTERFACE_OBJECT_MANAGER },
+		{ L_DBUS_INTERFACE_INTROSPECTABLE },
+		{ L_DBUS_INTERFACE_PROPERTIES },
+	};
+	size_t i;
+
+	for (i =3D 0; i < L_ARRAY_SIZE(interfaces_to_ignore); i++)
+		if (!strcmp(interfaces_to_ignore[i].interface, interface))
+			return true;
+
+	return false;
+}
+
+static struct l_dbus_proxy *find_proxy(struct l_dbus_client *client,
+					const char *path, const char *interface)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(client->proxies); entry;
+							entry =3D entry->next) {
+		struct l_dbus_proxy *proxy =3D entry->data;
+
+		if (!strcmp(proxy->interface, interface) &&
+						!strcmp(proxy->path, path))
+			return proxy;
+	}
+
+	return NULL;
+}
+
+static void parse_interface(struct l_dbus_client *client, const char *path,
+					const char *interface,
+					struct l_dbus_message_iter *properties)
+{
+	struct l_dbus_proxy *proxy;
+
+	if (is_ignorable(interface))
+		return;
+
+	proxy =3D find_proxy(client, path, interface);
+	if (!proxy) {
+		proxy =3D l_dbus_proxy_new(client, path, interface);
+	}
+
+	if (!proxy)
+		return;
+
+	proxy_update_properties(proxy, properties);
+
+	if (!proxy->ready) {
+		proxy->ready =3D true;
+
+		if (client->proxy_added_cb)
+			client->proxy_added_cb(proxy, client->proxy_cb_data);
+	}
+}
+
+static void parse_object(struct l_dbus_client *client, const char *path,
+					struct l_dbus_message_iter *object)
+{
+	const char *interface;
+	struct l_dbus_message_iter properties;
+
+	if (!path)
+		return;
+
+	while (l_dbus_message_iter_next_entry(object, &interface, &properties))
+		parse_interface(client, path, interface, &properties);
+}
+
+static void interfaces_added_callback(struct l_dbus_message *message,
+								void *user_data)
+{
+	struct l_dbus_client *client =3D user_data;
+	struct l_dbus_message_iter object;
+	const char *path;
+
+	if (!l_dbus_message_get_arguments(message, "oa{sa{sv}}", &path,
+								&object))
+		return
+
+	parse_object(client, path, &object);
+}
+
+static void interfaces_removed_callback(struct l_dbus_message *message,
+								void *user_data)
+{
+	struct l_dbus_client *client =3D user_data;
+	struct l_dbus_message_iter interfaces;
+	const char *interface;
+	const char *path;
+
+	if (!l_dbus_message_get_arguments(message, "oas", &path, &interfaces))
+		return;
+
+	while (l_dbus_message_iter_next_entry(&interfaces, &interface)) {
+		struct l_dbus_proxy *proxy;
+
+		proxy =3D find_proxy(client, path, interface);
+		if (!proxy)
+			continue;
+
+		l_queue_remove(proxy->client->proxies, proxy);
+
+		if (client->proxy_removed_cb)
+			client->proxy_removed_cb(proxy, client->proxy_cb_data);
+
+		l_dbus_proxy_destroy(proxy);
+	}
+}
+
+static void get_managed_objects_reply(struct l_dbus_message *message,
+								void *user_data)
+{
+	struct l_dbus_client *client =3D user_data;
+	struct l_dbus_message_iter objects;
+	struct l_dbus_message_iter object;
+	const char *path;
+
+	client->objects_call =3D 0;
+
+	if (l_dbus_message_is_error(message))
+		return;
+
+	l_dbus_message_get_arguments(message, "a{oa{sa{sv}}}", &objects);
+
+	while (l_dbus_message_iter_next_entry(&objects, &path, &object))
+		parse_object(client, path, &object);
+
+	client->added_watch =3D l_dbus_add_signal_watch(client->dbus,
+						client->service, "/",
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesAdded",
+						L_DBUS_MATCH_NONE,
+						interfaces_added_callback,
+						client);
+
+	client->removed_watch =3D l_dbus_add_signal_watch(client->dbus,
+						client->service, "/",
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
+						"InterfacesRemoved",
+						L_DBUS_MATCH_NONE,
+						interfaces_removed_callback,
+						client);
+
+	if (client->ready_cb)
+		client->ready_cb(client, client->ready_cb_data);
+}
+
+static void service_appeared_callback(struct l_dbus *dbus, void *user_data)
+{
+	struct l_dbus_client *client =3D user_data;
+
+	/* TODO should we allow to set different root? */
+	client->objects_call =3D l_dbus_method_call(dbus, client->service, "/",
+						L_DBUS_INTERFACE_OBJECT_MANAGER,
+						"GetManagedObjects", NULL,
+						get_managed_objects_reply,
+						client, NULL);
+
+	if (client->connect_cb)
+		client->connect_cb(client->dbus, client->connect_cb_data);
+}
+
+static void service_disappeared_callback(struct l_dbus *dbus, void *user_d=
ata)
+{
+	struct l_dbus_client *client =3D user_data;
+
+	if (client->disconnect_cb)
+		client->disconnect_cb(client->dbus, client->disconnect_cb_data);
+
+	l_queue_clear(client->proxies,
+				(l_queue_destroy_func_t)l_dbus_proxy_destroy);
+}
+
+LIB_EXPORT struct l_dbus_client *l_dbus_client_new(struct l_dbus *dbus,
+					const char *service, const char *path)
+{
+	struct l_dbus_client *client;
+
+	client =3D l_new(struct l_dbus_client, 1);
+
+	client->dbus =3D dbus;
+
+	client->watch =3D l_dbus_add_service_watch(dbus, service,
+						service_appeared_callback,
+						service_disappeared_callback,
+						client, NULL);
+
+	if (!client->watch) {
+		l_free(client);
+		return NULL;
+	}
+
+	client->service =3D l_strdup(service);
+	client->path =3D l_strdup(path);
+	client->proxies =3D l_queue_new();
+
+	return client;
+}
+
+LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_client *client)
+{
+	if (unlikely(!client))
+		return;
+
+	if (client->watch)
+		l_dbus_remove_signal_watch(client->dbus, client->watch);
+
+	if (client->added_watch)
+		l_dbus_remove_signal_watch(client->dbus, client->added_watch);
+
+	if (client->removed_watch)
+		l_dbus_remove_signal_watch(client->dbus, client->removed_watch);
+
+	if (client->connect_cb_data_destroy)
+		client->connect_cb_data_destroy(client->connect_cb_data);
+
+	if (client->disconnect_cb_data_destroy)
+		client->disconnect_cb_data_destroy(client->disconnect_cb_data);
+
+	if (client->ready_cb_data_destroy)
+		client->ready_cb_data_destroy(client->ready_cb_data);
+
+	if (client->proxy_cb_data_destroy)
+		client->proxy_cb_data_destroy(client->proxy_cb_data);
+
+	if (client->objects_call)
+		l_dbus_cancel(client->dbus, client->objects_call)
+;
+	l_queue_destroy(client->proxies,
+				(l_queue_destroy_func_t)l_dbus_proxy_destroy);
+
+	l_free(client->service);
+	l_free(client->path);
+	l_free(client);
+}
+
+LIB_EXPORT bool l_dbus_client_set_connect_handler(struct l_dbus_client *cl=
ient,
+						l_dbus_watch_func_t function,
+						void *user_data,
+						l_dbus_destroy_func_t destroy)
+{
+	if (unlikely(!client))
+		return false;
+
+	client->connect_cb =3D function;
+	client->connect_cb_data =3D user_data;
+	client->connect_cb_data_destroy =3D destroy;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dbus_client_set_disconnect_handler(struct l_dbus_client =
*client,
+						l_dbus_watch_func_t function,
+						void *user_data,
+						l_dbus_destroy_func_t destroy)
+{
+	if (unlikely(!client))
+		return false;
+
+	client->disconnect_cb =3D function;
+	client->disconnect_cb_data =3D user_data;
+	client->disconnect_cb_data_destroy =3D destroy;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dbus_client_set_ready_handler(struct l_dbus_client *clie=
nt,
+					l_dbus_client_ready_func_t function,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	if (unlikely(!client))
+		return false;
+
+	client->ready_cb =3D function;
+	client->ready_cb_data =3D user_data;
+	client->ready_cb_data_destroy =3D destroy;
+
+	return true;
+}
+
+LIB_EXPORT bool l_dbus_client_set_proxy_handlers(struct l_dbus_client *cli=
ent,
+			l_dbus_client_proxy_func_t proxy_added,
+			l_dbus_client_proxy_func_t proxy_removed,
+			l_dbus_client_property_function_t property_changed,
+			void *user_data, l_dbus_destroy_func_t destroy)
+{
+	if (unlikely(!client))
+		return false;
+
+	client->proxy_added_cb =3D proxy_added;
+	client->proxy_removed_cb =3D proxy_removed;
+	client->properties_changed_cb =3D property_changed;
+	client->proxy_cb_data =3D user_data;
+	client->proxy_cb_data_destroy =3D destroy;
+
+	return true;
+}
diff --git a/ell/dbus-client.h b/ell/dbus-client.h
new file mode 100644
index 0000000..460c6c5
--- /dev/null
+++ b/ell/dbus-client.h
@@ -0,0 +1,82 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2017  Codecoup. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_DBUS_CLIENT_H
+#define __ELL_DBUS_CLIENT_H
+
+#include <stdbool.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_dbus;
+struct l_dbus_message;
+struct l_dbus_client;
+struct l_dbus_proxy;
+
+typedef void (*l_dbus_client_ready_func_t)(struct l_dbus_client *client,
+							void *user_data);
+typedef void (*l_dbus_client_proxy_func_t) (struct l_dbus_proxy *proxy,
+							void *user_data);
+typedef void (*l_dbus_client_property_function_t) (struct l_dbus_proxy *pr=
oxy,
+						const char *name,
+						struct l_dbus_message *msg,
+						void *user_data);
+
+struct l_dbus_client *l_dbus_client_new(struct l_dbus *dbus,
+					const char *service, const char *path);
+void l_dbus_client_destroy(struct l_dbus_client *client);
+
+bool l_dbus_client_set_connect_handler(struct l_dbus_client *client,
+						l_dbus_watch_func_t function,
+						void *user_data,
+						l_dbus_destroy_func_t destroy);
+
+bool l_dbus_client_set_disconnect_handler(struct l_dbus_client *client,
+						l_dbus_watch_func_t function,
+						void *user_data,
+						l_dbus_destroy_func_t destroy);
+
+bool l_dbus_client_set_ready_handler(struct l_dbus_client *client,
+					l_dbus_client_ready_func_t function,
+					void *user_data,
+					l_dbus_destroy_func_t destroy);
+
+bool l_dbus_client_set_proxy_handlers(struct l_dbus_client *client,
+			l_dbus_client_proxy_func_t proxy_added,
+			l_dbus_client_proxy_func_t proxy_removed,
+			l_dbus_client_property_function_t property_changed,
+			void *user_data, l_dbus_destroy_func_t destroy);
+
+const char *l_dbus_proxy_get_path(struct l_dbus_proxy *proxy);
+
+const char *l_dbus_proxy_get_interface(struct l_dbus_proxy *proxy);
+
+bool l_dbus_proxy_get_property(struct l_dbus_proxy *proxy, const char *nam=
e,
+						const char *signature, ...);
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_DBUS_CLIENT_H */
diff --git a/ell/ell.h b/ell/ell.h
index 2efd1c4..4083ee5 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -51,3 +51,4 @@
 #include <ell/genl.h>
 #include <ell/dbus.h>
 #include <ell/dbus-service.h>
+#include <ell/dbus-client.h>
-- =

2.14.3


--===============8400970638318305417==--

