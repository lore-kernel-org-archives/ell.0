Content-Type: multipart/mixed; boundary="===============8656927823715314228=="
MIME-Version: 1.0
From: Claudio Takahasi <ckt@cesar.org.br>
Subject: [PATCH] dbus: Fix l_dbus_client_set_proxy_handlers user data
Date: Tue, 27 Feb 2018 10:43:19 -0300
Message-ID: <20180227134319.1657-1-ckt@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8656927823715314228==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Proxy property changed callback is passing wrong argument. The argument
should be user data instead of destroy function.
---
 ell/dbus-client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 2684df2..1628b67 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -349,7 +349,7 @@ static void proxy_update_property(struct l_dbus_proxy *=
proxy,
 done:
 	if (proxy->client->properties_changed_cb && proxy->ready)
 		proxy->client->properties_changed_cb(proxy, name, prop->msg,
-					proxy->client->proxy_cb_data_destroy);
+					proxy->client->proxy_cb_data);
 }
 =

 static void proxy_invalidate_properties(struct l_dbus_proxy *proxy,
-- =

2.16.2


--===============8656927823715314228==--

