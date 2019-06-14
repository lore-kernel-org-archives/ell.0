Content-Type: multipart/mixed; boundary="===============2339474225323358945=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] dbus-client: Introduce l_dbus_client_add_proxy
Date: Fri, 14 Jun 2019 11:12:56 -0700
Message-ID: <20190614181256.7491-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2339474225323358945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Not all DBus services expose their objects trough ObjectManager,
therefore the usage of such objects through the current client
proxy API is impossible. This patch allows to manually add
a proxy object for the well-known DBus object.
---
 ell/dbus-client.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++=
++--
 ell/dbus-client.h |  3 +++
 2 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index d2eb70f..852cf3b 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -37,6 +37,7 @@ struct l_dbus_client {
 	unsigned int removed_watch;
 	char *service;
 	uint32_t objects_call;
+	uint32_t add_proxy_call;
 =

 	l_dbus_watch_func_t connect_cb;
 	void *connect_cb_data;
@@ -647,8 +648,11 @@ LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_cl=
ient *client)
 		client->proxy_cb_data_destroy(client->proxy_cb_data);
 =

 	if (client->objects_call)
-		l_dbus_cancel(client->dbus, client->objects_call)
-;
+		l_dbus_cancel(client->dbus, client->objects_call);
+
+	if (client->add_proxy_call)
+		l_dbus_cancel(client->dbus, client->add_proxy_call);
+
 	l_queue_destroy(client->proxies,
 				(l_queue_destroy_func_t)dbus_proxy_destroy);
 =

@@ -730,3 +734,73 @@ LIB_EXPORT bool l_dbus_client_set_proxy_handlers(struc=
t l_dbus_client *client,
 =

 	return true;
 }
+
+struct add_proxy_data {
+	struct l_dbus_client *client;
+	char *path;
+	char *interafce;
+};
+
+static void add_proxy_data_destroy(void *user_data)
+{
+	struct add_proxy_data *data =3D user_data;
+
+	l_free(data->path);
+	l_free(data->interafce);
+	l_free(data);
+}
+
+static void add_proxy_reply(struct l_dbus_message *message, void *user_dat=
a)
+{
+	struct add_proxy_data *data =3D user_data;
+	struct l_dbus_message_iter properties;
+
+	data->client->add_proxy_call =3D 0;
+
+	if (l_dbus_message_is_error(message))
+		return;
+
+	l_dbus_message_get_arguments(message, "a{sv}", &properties);
+
+	parse_interface(data->client, data->path, data->interafce, &properties);
+}
+
+static void add_proxy_setup(struct l_dbus_message *message, void *user_dat=
a)
+{
+	struct add_proxy_data *data =3D user_data;
+
+	l_dbus_message_set_arguments(message, "s", data->interafce);
+}
+
+LIB_EXPORT bool l_dbus_client_add_proxy(struct l_dbus_client *client,
+							const char *path,
+							const char *interface)
+{
+	struct add_proxy_data *data;
+
+	if (unlikely(!client || !path || !interface))
+		return false;
+
+	if (find_proxy(client, path, interface))
+		return false;
+
+	data =3D l_new(struct add_proxy_data, 1);
+	data->client =3D client;
+	data->path =3D l_strdup(path);
+	data->interafce =3D l_strdup(interface);
+
+	client->add_proxy_call =3D
+			l_dbus_method_call(client->dbus, client->service, path,
+						L_DBUS_INTERFACE_PROPERTIES,
+						"GetAll", add_proxy_setup,
+						add_proxy_reply, data,
+						add_proxy_data_destroy);
+
+	if (!client->add_proxy_call) {
+		add_proxy_data_destroy(data);
+
+		return false;
+	}
+
+	return true;
+}
diff --git a/ell/dbus-client.h b/ell/dbus-client.h
index 699d824..939a6bf 100644
--- a/ell/dbus-client.h
+++ b/ell/dbus-client.h
@@ -72,6 +72,9 @@ bool l_dbus_client_set_proxy_handlers(struct l_dbus_clien=
t *client,
 			l_dbus_client_property_function_t property_changed,
 			void *user_data, l_dbus_destroy_func_t destroy);
 =

+bool l_dbus_client_add_proxy(struct l_dbus_client *client, const char *pat=
h,
+							const char *interface);
+
 const char *l_dbus_proxy_get_path(struct l_dbus_proxy *proxy);
 =

 const char *l_dbus_proxy_get_interface(struct l_dbus_proxy *proxy);
-- =

2.13.6


--===============2339474225323358945==--

