Content-Type: multipart/mixed; boundary="===============9088741906960750677=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH] dbus: Fix setup in l_dbus_proxy_method_call
Date: Fri, 08 Dec 2017 16:44:07 +0100
Message-ID: <20171208154407.11552-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9088741906960750677==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This fix passing invalid user_data to setup callback in
l_dbus_proxy_method_call.
---
 ell/dbus-client.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index b74bb27..2684df2 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -186,6 +186,7 @@ struct method_call_request
 {
 	struct l_dbus_proxy *proxy;
 	uint32_t call_id;
+	l_dbus_message_func_t setup;
 	l_dbus_client_proxy_result_func_t result;
 	void *user_data;
 	l_dbus_destroy_func_t destroy;
@@ -203,6 +204,16 @@ static void method_call_request_free(void *user_data)
 	l_free(req);
 }
 =

+static void method_call_setup(struct l_dbus_message *message, void *user_d=
ata)
+{
+	struct method_call_request *req =3D user_data;
+
+	if (req->setup)
+		req->setup(message, req->user_data);
+	else
+		l_dbus_message_set_arguments(message, "");
+}
+
 static void method_call_reply(struct l_dbus_message *message, void *user_d=
ata)
 {
 	struct method_call_request *req =3D user_data;
@@ -290,6 +301,7 @@ LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_d=
bus_proxy *proxy,
 =

 	req =3D l_new(struct method_call_request, 1);
 	req->proxy =3D proxy;
+	req->setup =3D setup;
 	req->result =3D reply;
 	req->user_data =3D user_data;
 	req->destroy =3D destroy;
@@ -297,7 +309,7 @@ LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_d=
bus_proxy *proxy,
 	req->call_id =3D l_dbus_method_call(proxy->client->dbus,
 						proxy->client->service,
 						proxy->path, proxy->interface,
-						method, setup,
+						method, method_call_setup,
 						method_call_reply, req,
 						method_call_request_free);
 	if (!req->call_id) {
-- =

2.14.3


--===============9088741906960750677==--

