Content-Type: multipart/mixed; boundary="===============1946132443755371208=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH v2 3/4] dbus: Add convenient API for calling method on proxy
 interface
Date: Tue, 05 Dec 2017 17:22:32 +0100
Message-ID: <20171205162233.22452-3-szymon.janc@codecoup.pl>
In-Reply-To: <20171205162233.22452-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1946132443755371208==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is wrapper around l_dbus_method_call that allows to cancel call
both by removed proxy and caller.
---
 ell/dbus-client.c | 31 +++++++++++++++++++++++++++++++
 ell/dbus-client.h |  8 ++++++++
 2 files changed, 39 insertions(+)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 3e68ba1..b74bb27 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -279,6 +279,37 @@ LIB_EXPORT bool l_dbus_proxy_set_property(struct l_dbu=
s_proxy *proxy,
 	return true;
 }
 =

+LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_dbus_proxy *proxy,
+					const char *method,
+					l_dbus_message_func_t setup,
+					l_dbus_client_proxy_result_func_t reply,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	struct method_call_request *req;
+
+	req =3D l_new(struct method_call_request, 1);
+	req->proxy =3D proxy;
+	req->result =3D reply;
+	req->user_data =3D user_data;
+	req->destroy =3D destroy;
+
+	req->call_id =3D l_dbus_method_call(proxy->client->dbus,
+						proxy->client->service,
+						proxy->path, proxy->interface,
+						method, setup,
+						method_call_reply, req,
+						method_call_request_free);
+	if (!req->call_id) {
+		l_free(req);
+		return 0;
+	}
+
+	l_queue_push_tail(proxy->pending_calls, L_UINT_TO_PTR(req->call_id));
+
+	return req->call_id;
+}
+
 static void proxy_update_property(struct l_dbus_proxy *proxy,
 					const char *name,
 					struct l_dbus_message_iter *property)
diff --git a/ell/dbus-client.h b/ell/dbus-client.h
index 928dcec..699d824 100644
--- a/ell/dbus-client.h
+++ b/ell/dbus-client.h
@@ -83,6 +83,14 @@ bool l_dbus_proxy_set_property(struct l_dbus_proxy *prox=
y,
 				l_dbus_client_proxy_result_func_t result,
 				void *user_data, l_dbus_destroy_func_t destroy,
 				const char *name, const char *signature, ...);
+
+uint32_t l_dbus_proxy_method_call(struct l_dbus_proxy *proxy,
+					const char *method,
+					l_dbus_message_func_t setup,
+					l_dbus_client_proxy_result_func_t reply,
+					void *user_data,
+					l_dbus_destroy_func_t destroy);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.14.3


--===============1946132443755371208==--

