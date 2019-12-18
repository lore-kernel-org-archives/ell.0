Content-Type: multipart/mixed; boundary="===============7849167179933516245=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH v3] dbus: Minor whitespace clean-up
Date: Wed, 18 Dec 2019 07:14:43 -0800
Message-ID: <20191218151443.29490-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7849167179933516245==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 2d8120e..f735f33 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -651,8 +651,8 @@ LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_cli=
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

--===============7849167179933516245==--

