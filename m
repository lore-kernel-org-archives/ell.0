Content-Type: multipart/mixed; boundary="===============5520766699704105020=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH v2 2/4] dbus: Add support for setting properties on D-Bus
 proxy interface
Date: Tue, 05 Dec 2017 17:22:31 +0100
Message-ID: <20171205162233.22452-2-szymon.janc@codecoup.pl>
In-Reply-To: <20171205162233.22452-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5520766699704105020==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_proxy_set_property function allows to set properties via proxy
interface.
---
 ell/dbus-client.c | 113 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-client.h |   8 ++++
 2 files changed, 121 insertions(+)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index e4ca4ad..3e68ba1 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -70,6 +70,7 @@ struct l_dbus_proxy {
 	bool ready;
 =

 	struct l_queue *properties;
+	struct l_queue *pending_calls;
 };
 =

 LIB_EXPORT const char *l_dbus_proxy_get_path(struct l_dbus_proxy *proxy)
@@ -152,6 +153,18 @@ static void property_free(void *data)
 	l_free(prop);
 }
 =

+static void cancel_pending_calls(struct l_dbus_proxy *proxy)
+{
+	const struct l_queue_entry *entry;
+
+	for (entry =3D l_queue_get_entries(proxy->pending_calls); entry;
+							entry =3D entry->next) {
+		uint32_t call_id =3D L_PTR_TO_UINT(entry->data);
+
+		l_dbus_cancel(proxy->client->dbus, call_id);
+	}
+}
+
 static void dbus_proxy_destroy(struct l_dbus_proxy *proxy)
 {
 	if (unlikely(!proxy))
@@ -161,12 +174,111 @@ static void dbus_proxy_destroy(struct l_dbus_proxy *=
proxy)
 		l_dbus_remove_signal_watch(proxy->client->dbus,
 						proxy->properties_watch);
 =

+	cancel_pending_calls(proxy);
+	l_queue_destroy(proxy->pending_calls, NULL);
 	l_queue_destroy(proxy->properties, property_free);
 	l_free(proxy->interface);
 	l_free(proxy->path);
 	l_free(proxy);
 }
 =

+struct method_call_request
+{
+	struct l_dbus_proxy *proxy;
+	uint32_t call_id;
+	l_dbus_client_proxy_result_func_t result;
+	void *user_data;
+	l_dbus_destroy_func_t destroy;
+};
+
+static void method_call_request_free(void *user_data)
+{
+	struct method_call_request *req =3D user_data;
+
+	l_queue_remove(req->proxy->pending_calls, L_UINT_TO_PTR(req->call_id));
+
+	if (req->destroy)
+		req->destroy(req->user_data);
+
+	l_free(req);
+}
+
+static void method_call_reply(struct l_dbus_message *message, void *user_d=
ata)
+{
+	struct method_call_request *req =3D user_data;
+
+	if (req->result)
+		req->result(req->proxy, message, req->user_data);
+}
+
+LIB_EXPORT bool l_dbus_proxy_set_property(struct l_dbus_proxy *proxy,
+				l_dbus_client_proxy_result_func_t result,
+				void *user_data, l_dbus_destroy_func_t destroy,
+				const char *name, const char *signature, ...)
+{
+	struct l_dbus_client *client =3D proxy->client;
+	struct l_dbus_message_builder *builder;
+	struct method_call_request *req;
+	struct l_dbus_message *message;
+	struct proxy_property *prop;
+	va_list args;
+
+	if (unlikely(!proxy))
+		return false;
+
+	prop =3D find_property(proxy, name);
+	if (!prop)
+		return false;
+
+	if (strcmp(l_dbus_message_get_signature(prop->msg), signature))
+		return false;
+
+	message =3D l_dbus_message_new_method_call(client->dbus, client->service,
+						proxy->path,
+						L_DBUS_INTERFACE_PROPERTIES,
+						"Set");
+	if (!message)
+		return false;
+
+	builder =3D l_dbus_message_builder_new(message);
+	if (!builder) {
+		l_dbus_message_unref(message);
+		return false;
+	}
+
+	l_dbus_message_builder_append_basic(builder, 's', proxy->interface);
+	l_dbus_message_builder_append_basic(builder, 's', name);
+
+	l_dbus_message_builder_enter_variant(builder, signature);
+
+	va_start(args, signature);
+	l_dbus_message_builder_append_from_valist(builder, signature, args);
+	va_end(args);
+
+	l_dbus_message_builder_leave_variant(builder);
+
+	l_dbus_message_builder_finalize(builder);
+	l_dbus_message_builder_destroy(builder);
+
+	req =3D l_new(struct method_call_request, 1);
+	req->proxy =3D proxy;
+	req->result =3D result;
+	req->user_data =3D user_data;
+	req->destroy =3D destroy;
+
+	req->call_id =3D l_dbus_send_with_reply(client->dbus, message,
+						method_call_reply, req,
+						method_call_request_free);
+	if (!req->call_id) {
+		l_free(req);
+		return false;
+	}
+
+	l_queue_push_tail(proxy->pending_calls, L_UINT_TO_PTR(req->call_id));
+
+	return true;
+}
+
 static void proxy_update_property(struct l_dbus_proxy *proxy,
 					const char *name,
 					struct l_dbus_message_iter *property)
@@ -254,6 +366,7 @@ static struct l_dbus_proxy *dbus_proxy_new(struct l_dbu=
s_client *client,
 	proxy->interface =3D l_strdup(interface);
 	proxy->path =3D l_strdup(path);
 	proxy->properties =3D l_queue_new();
+	proxy->pending_calls =3D l_queue_new();;
 =

 	l_queue_push_tail(client->proxies, proxy);
 =

diff --git a/ell/dbus-client.h b/ell/dbus-client.h
index 460c6c5..928dcec 100644
--- a/ell/dbus-client.h
+++ b/ell/dbus-client.h
@@ -39,6 +39,9 @@ typedef void (*l_dbus_client_ready_func_t)(struct l_dbus_=
client *client,
 							void *user_data);
 typedef void (*l_dbus_client_proxy_func_t) (struct l_dbus_proxy *proxy,
 							void *user_data);
+typedef void (*l_dbus_client_proxy_result_func_t) (struct l_dbus_proxy *pr=
oxy,
+						struct l_dbus_message *result,
+						void *user_data);
 typedef void (*l_dbus_client_property_function_t) (struct l_dbus_proxy *pr=
oxy,
 						const char *name,
 						struct l_dbus_message *msg,
@@ -75,6 +78,11 @@ const char *l_dbus_proxy_get_interface(struct l_dbus_pro=
xy *proxy);
 =

 bool l_dbus_proxy_get_property(struct l_dbus_proxy *proxy, const char *nam=
e,
 						const char *signature, ...);
+
+bool l_dbus_proxy_set_property(struct l_dbus_proxy *proxy,
+				l_dbus_client_proxy_result_func_t result,
+				void *user_data, l_dbus_destroy_func_t destroy,
+				const char *name, const char *signature, ...);
 #ifdef __cplusplus
 }
 #endif
-- =

2.14.3


--===============5520766699704105020==--

