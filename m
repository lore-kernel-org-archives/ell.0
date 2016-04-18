Content-Type: multipart/mixed; boundary="===============8450915127640423352=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] dbus: Add service watch API based on the name cache
Date: Mon, 18 Apr 2016 16:31:16 +0200
Message-ID: <1460989877-20113-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8450915127640423352==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-name-cache.c | 149 ++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 ell/dbus-private.h    |   9 +++
 2 files changed, 157 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index 76b1792..f7d5e50 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -30,6 +30,7 @@
 =

 #include "util.h"
 #include "hashmap.h"
+#include "idle.h"
 #include "dbus.h"
 #include "dbus-private.h"
 =

@@ -37,11 +38,24 @@ struct _dbus_name_cache {
 	struct l_dbus *bus;
 	struct l_hashmap *names;
 	const struct _dbus_name_ops *driver;
+	unsigned int last_watch_id;
+	struct l_idle *watch_remove_work;
+};
+
+struct service_watch {
+	l_dbus_watch_func_t connect_func;
+	l_dbus_watch_func_t disconnect_func;
+	l_dbus_destroy_func_t destroy;
+	void *user_data;
+	unsigned int id;
+	bool removed;
+	struct service_watch *next;
 };
 =

 struct name_cache_entry {
 	int ref_count;
 	char *unique_name;
+	struct service_watch *watches;
 };
 =

 struct _dbus_name_cache *_dbus_name_cache_new(struct l_dbus *bus,
@@ -57,9 +71,27 @@ struct _dbus_name_cache *_dbus_name_cache_new(struct l_d=
bus *bus,
 	return cache;
 }
 =

+static void service_watch_destroy(void *data)
+{
+	struct service_watch *watch =3D data;
+
+	if (watch->destroy)
+		watch->destroy(watch->user_data);
+
+	l_free(watch);
+}
+
 static void name_cache_entry_destroy(void *data)
 {
 	struct name_cache_entry *entry =3D data;
+	struct service_watch *watch;
+
+	while (entry->watches) {
+		watch =3D entry->watches;
+		entry->watches =3D watch->next;
+
+		service_watch_destroy(watch);
+	}
 =

 	l_free(entry->unique_name);
 =

@@ -68,6 +100,9 @@ static void name_cache_entry_destroy(void *data)
 =

 void _dbus_name_cache_free(struct _dbus_name_cache *cache)
 {
+	if (cache->watch_remove_work)
+		l_idle_remove(cache->watch_remove_work);
+
 	l_hashmap_destroy(cache->names, name_cache_entry_destroy);
 =

 	l_free(cache);
@@ -134,6 +169,8 @@ void _dbus_name_cache_notify(struct _dbus_name_cache *c=
ache,
 				const char *name, const char *owner)
 {
 	struct name_cache_entry *entry;
+	struct service_watch *watch;
+	bool prev_connected, connected;
 =

 	if (_dbus_parse_unique_name(name, NULL))
 		return;
@@ -143,7 +180,117 @@ void _dbus_name_cache_notify(struct _dbus_name_cache =
*cache,
 	if (!entry)
 		return;
 =

+	prev_connected =3D !!entry->unique_name;
+	connected =3D owner && *owner !=3D '\0';
+
 	l_free(entry->unique_name);
 =

-	entry->unique_name =3D (owner && *owner !=3D '\0') ? l_strdup(owner) : NU=
LL;
+	entry->unique_name =3D connected ? l_strdup(owner) : NULL;
+
+	/*
+	 * This check also means we notify all watchers who have a connected
+	 * callback when we first learn that the service is in fact connected.
+	 */
+	if (connected =3D=3D prev_connected)
+		return;
+
+	for (watch =3D entry->watches; watch; watch =3D watch->next)
+		if (connected && watch->connect_func)
+			watch->connect_func(cache->bus, watch->user_data);
+		else if (!connected && watch->disconnect_func)
+			watch->disconnect_func(cache->bus, watch->user_data);
+}
+
+unsigned int _dbus_name_cache_add_watch(struct _dbus_name_cache *cache,
+					const char *name,
+					l_dbus_watch_func_t connect_func,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	struct name_cache_entry *entry;
+	struct service_watch *watch;
+
+	if (!_dbus_name_cache_add(cache, name))
+		return 0;
+
+	watch =3D l_new(struct service_watch, 1);
+	watch->id =3D ++cache->last_watch_id;
+	watch->connect_func =3D connect_func;
+	watch->disconnect_func =3D disconnect_func;
+	watch->user_data =3D user_data;
+	watch->destroy =3D destroy;
+
+	entry =3D l_hashmap_lookup(cache->names, name);
+
+	watch->next =3D entry->watches;
+	entry->watches =3D watch;
+
+ 	if (entry->unique_name && connect_func)
+		watch->connect_func(cache->bus, watch->user_data);
+
+	return watch->id;
+}
+
+static void service_watch_remove(const void *key, void *value, void *user_=
data)
+{
+	struct _dbus_name_cache *cache =3D user_data;
+	struct name_cache_entry *entry =3D value;
+	struct service_watch **watch, *tmp;
+
+	for (watch =3D &entry->watches; *watch;) {
+		if (!(*watch)->removed) {
+			watch =3D &(*watch)->next;
+			continue;
+		}
+
+		tmp =3D *watch;
+		*watch =3D tmp->next;
+
+		service_watch_destroy(tmp);
+
+		_dbus_name_cache_remove(cache, key);
+	}
+}
+
+static void service_watch_remove_all(struct l_idle *idle, void *user_data)
+{
+	struct _dbus_name_cache *cache =3D user_data;
+
+	l_idle_remove(cache->watch_remove_work);
+	cache->watch_remove_work =3D NULL;
+
+	l_hashmap_foreach(cache->names, service_watch_remove, cache);
+}
+
+static void service_watch_mark(const void *key, void *value, void *user_da=
ta)
+{
+	struct name_cache_entry *entry =3D value;
+	struct service_watch *watch;
+	unsigned int *id =3D user_data;
+
+	for (watch =3D entry->watches; watch; watch =3D watch->next)
+		if (watch->id =3D=3D *id) {
+			watch->removed =3D true;
+			watch->connect_func =3D NULL;
+			watch->disconnect_func =3D NULL;
+			*id =3D 0;
+			break;
+		}
+}
+
+bool _dbus_name_cache_remove_watch(struct _dbus_name_cache *cache,
+					unsigned int id)
+{
+	l_hashmap_foreach(cache->names, service_watch_mark, &id);
+
+	if (id)
+		return false;
+
+	if (!cache->watch_remove_work)
+		cache->watch_remove_work =3D l_idle_create(
+						service_watch_remove_all,
+						cache, NULL);
+
+	return true;
 }
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 1ade3e0..48541e0 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -291,6 +291,15 @@ const char *_dbus_name_cache_lookup(struct _dbus_name_=
cache *cache,
 void _dbus_name_cache_notify(struct _dbus_name_cache *cache,
 				const char *name, const char *owner);
 =

+unsigned int _dbus_name_cache_add_watch(struct _dbus_name_cache *cache,
+					const char *name,
+					l_dbus_watch_func_t connect_func,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy);
+bool _dbus_name_cache_remove_watch(struct _dbus_name_cache *cache,
+					unsigned int id);
+
 struct _dbus_filter_condition {
 	enum l_dbus_match_type type;
 	const char *value;
-- =

2.5.0


--===============8450915127640423352==--

