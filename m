Content-Type: multipart/mixed; boundary="===============8078588518437647064=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [RFC 6/6] dbus: Add convenient API for calling method on proxy
 interface
Date: Wed, 29 Nov 2017 16:16:48 +0100
Message-ID: <20171129151648.24749-7-szymon.janc@codecoup.pl>
In-Reply-To: <20171129151648.24749-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8078588518437647064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is simple wrapper around l_dbus_method_call.
---
 ell/dbus-client.c | 41 +++++++++++++++++++++++++++++++++++++++++
 ell/dbus-client.h |  7 +++++++
 2 files changed, 48 insertions(+)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 3f8c49f..4eacd01 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -278,6 +278,47 @@ LIB_EXPORT bool l_dbus_proxy_set_property(struct l_dbu=
s_proxy *proxy,
 	return true;
 }
 =

+struct proxy_call_data
+{
+	struct l_dbus_proxy *proxy;
+	l_dbus_client_proxy_result_func_t reply;
+	void *user_data;
+	l_dbus_destroy_func_t destroy;
+};
+
+static void proxy_call_data_reply(struct l_dbus_message *message,
+							void *user_data)
+{
+	struct proxy_call_data *data =3D user_data;
+
+	if (data->reply)
+		data->reply(data->proxy, message, data->user_data);
+}
+
+LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_dbus_proxy *proxy,
+						const char *method,
+						l_dbus_message_func_t setup,
+						l_dbus_client_proxy_result_func_t reply,
+						void *user_data,
+						l_dbus_destroy_func_t destroy)
+{
+	struct proxy_call_data *call_data;
+
+	if (unlikely(!proxy))
+		return 0;
+
+	call_data =3D l_new(struct proxy_call_data, 1);
+	call_data->proxy =3D proxy;
+	call_data->reply =3D reply;
+	call_data->user_data =3D user_data;
+	call_data->destroy =3D destroy;
+
+	return l_dbus_method_call(proxy->client->dbus, proxy->client->service,
+					proxy->path, proxy->interface, method,
+					setup, proxy_call_data_reply, call_data,
+					l_free);
+}
+
 static void proxy_update_property(struct l_dbus_proxy *proxy,
 					const char *name,
 					struct l_dbus_message_iter *property)
diff --git a/ell/dbus-client.h b/ell/dbus-client.h
index a65d8bb..ebfbd77 100644
--- a/ell/dbus-client.h
+++ b/ell/dbus-client.h
@@ -88,6 +88,13 @@ bool l_dbus_proxy_set_property(struct l_dbus_proxy *prox=
y,
 				l_dbus_client_proxy_result_func_t result,
 				void *user_data, l_dbus_destroy_func_t destroy,
 				const char *name, const char *signature, ...);
+
+uint32_t l_dbus_proxy_method_call(struct l_dbus_proxy *proxy,
+				const char *method,
+				l_dbus_message_func_t setup,
+				l_dbus_client_proxy_result_func_t reply,
+				void *user_data, l_dbus_destroy_func_t destroy);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.14.3


--===============8078588518437647064==--

