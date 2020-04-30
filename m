Content-Type: multipart/mixed; boundary="===============6895781305439068022=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Call destroy function in l_dbus_remove_watch
Date: Thu, 30 Apr 2020 15:23:39 +0200
Message-ID: <20200430132340.58244-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6895781305439068022==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_remove_watch (_dbus_name_cache_remove_watch) marks name watches
as removed and schedules a service_watch_remove_all call.  Do the
watch's destroy callback when marking the watch as removed instead of
waiting until the service_watch_remove_all idle callback to do this.

Semantically it may be ok to do the destroy callback later but I think
it's easier on the user if they can be sure they'll get no more
callbacks after using l_dbus_remove_watch.
---
 ell/dbus-name-cache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index cb6a516..b09cc97 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -283,6 +283,12 @@ static void service_watch_mark(const void *key, void *=
value, void *user_data)
 			watch->removed =3D true;
 			watch->connect_func =3D NULL;
 			watch->disconnect_func =3D NULL;
+
+			if (watch->destroy) {
+				watch->destroy(watch->user_data);
+				watch->destroy =3D NULL;
+			}
+
 			*id =3D 0;
 			break;
 		}
-- =

2.25.1

--===============6895781305439068022==--

