Content-Type: multipart/mixed; boundary="===============6635007093524475334=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] dbus: NULL check proxy on method calls
Date: Tue, 17 Dec 2019 09:27:46 -0800
Message-ID: <20191217172746.3814-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6635007093524475334==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_proxy_method_call() seg-faults when called with a NULL proxy
pointer.  This NULL check follows the pattern of NULL checks in the
other LIB_EXPORT methods in module.
---
 ell/dbus-client.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 541f3e8..f735f33 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -301,6 +301,9 @@ LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_d=
bus_proxy *proxy,
 {
 	struct method_call_request *req;
 =

+	if (unlikely(!proxy))
+		return 0;
+
 	req =3D l_new(struct method_call_request, 1);
 	req->proxy =3D proxy;
 	req->setup =3D setup;
@@ -648,8 +651,8 @@ LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_cli=
ent *client)
 		client->proxy_cb_data_destroy(client->proxy_cb_data);
 =

 	if (client->objects_call)
-		l_dbus_cancel(client->dbus, client->objects_call)
-;
+		l_dbus_cancel(client->dbus, client->objects_call);
+
 	l_queue_destroy(client->proxies,
 				(l_queue_destroy_func_t)dbus_proxy_destroy);
 =

-- =

2.21.0

--===============6635007093524475334==--

