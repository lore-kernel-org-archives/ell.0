Content-Type: multipart/mixed; boundary="===============0754199638335889182=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Replace service_watch.removed by zeroing .id
Date: Thu, 30 Apr 2020 15:23:40 +0200
Message-ID: <20200430132340.58244-2-andrew.zaborowski@intel.com>
In-Reply-To: <20200430132340.58244-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0754199638335889182==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_remove_watch would set service_watch::removed true and return
success, but another call to l_dbus_remove_watch would still succeed
because we weren't checking if removed was already true.  We could add
that check but we can also zero the id instead and simplify the struct
slightly.
---
This is almost a cosmetic change but I think it may be in the right
direction, feel free to ignore it if you think otherwise.
---
 ell/dbus-name-cache.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index b09cc97..000cdb5 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -48,7 +48,6 @@ struct service_watch {
 	l_dbus_destroy_func_t destroy;
 	void *user_data;
 	unsigned int id;
-	bool removed;
 	struct service_watch *next;
 };
 =

@@ -241,7 +240,7 @@ static bool service_watch_remove(const void *key, void =
*value, void *user_data)
 	struct service_watch **watch, *tmp;
 =

 	for (watch =3D &entry->watches; *watch;) {
-		if (!(*watch)->removed) {
+		if ((*watch)->id) {
 			watch =3D &(*watch)->next;
 			continue;
 		}
@@ -278,9 +277,12 @@ static void service_watch_mark(const void *key, void *=
value, void *user_data)
 	struct service_watch *watch;
 	unsigned int *id =3D user_data;
 =

+	if (!*id)
+		return;
+
 	for (watch =3D entry->watches; watch; watch =3D watch->next)
 		if (watch->id =3D=3D *id) {
-			watch->removed =3D true;
+			watch->id =3D 0;
 			watch->connect_func =3D NULL;
 			watch->disconnect_func =3D NULL;
 =

-- =

2.25.1

--===============0754199638335889182==--

