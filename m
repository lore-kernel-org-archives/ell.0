Content-Type: multipart/mixed; boundary="===============2746433576841955207=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Don't call l_hashmap_remove within l_hashmap_foreach
Date: Mon, 09 May 2016 11:24:57 +0200
Message-ID: <1462785897-2202-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2746433576841955207==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-name-cache.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index 6d723d7..24ca619 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -232,9 +232,8 @@ unsigned int _dbus_name_cache_add_watch(struct _dbus_na=
me_cache *cache,
 	return watch->id;
 }
 =

-static void service_watch_remove(const void *key, void *value, void *user_=
data)
+static bool service_watch_remove(const void *key, void *value, void *user_=
data)
 {
-	struct _dbus_name_cache *cache =3D user_data;
 	struct name_cache_entry *entry =3D value;
 	struct service_watch **watch, *tmp;
 =

@@ -249,8 +248,15 @@ static void service_watch_remove(const void *key, void=
 *value, void *user_data)
 =

 		service_watch_destroy(tmp);
 =

-		_dbus_name_cache_remove(cache, key);
+		entry->ref_count--;
 	}
+
+	if (entry->ref_count)
+		return false;
+
+	name_cache_entry_destroy(entry);
+
+	return true;
 }
 =

 static void service_watch_remove_all(struct l_idle *idle, void *user_data)
@@ -260,7 +266,7 @@ static void service_watch_remove_all(struct l_idle *idl=
e, void *user_data)
 	l_idle_remove(cache->watch_remove_work);
 	cache->watch_remove_work =3D NULL;
 =

-	l_hashmap_foreach(cache->names, service_watch_remove, cache);
+	l_hashmap_foreach_remove(cache->names, service_watch_remove, cache);
 }
 =

 static void service_watch_mark(const void *key, void *value, void *user_da=
ta)
-- =

2.7.4


--===============2746433576841955207==--

