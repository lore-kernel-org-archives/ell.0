Content-Type: multipart/mixed; boundary="===============3586685448923810962=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] dbus: Add a Bus Name cache
Date: Mon, 18 Apr 2016 16:31:13 +0200
Message-ID: <1460989877-20113-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3586685448923810962==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am           |   1 +
 ell/dbus-name-cache.c | 149 ++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-private.h    |  18 ++++++
 ell/dbus.c            |  35 +++++++++---
 4 files changed, 196 insertions(+), 7 deletions(-)
 create mode 100644 ell/dbus-name-cache.c

diff --git a/Makefile.am b/Makefile.am
index 7283a7e..3e8e3ef 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -75,6 +75,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dbus-message.c \
 			ell/dbus-util.c \
 			ell/dbus-service.c \
+			ell/dbus-name-cache.c \
 			ell/dbus-filter.c \
 			ell/gvariant-private.h \
 			ell/gvariant-util.c \
diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
new file mode 100644
index 0000000..76b1792
--- /dev/null
+++ b/ell/dbus-name-cache.c
@@ -0,0 +1,149 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2016  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <stdlib.h>
+#include <stdio.h>
+
+#include "util.h"
+#include "hashmap.h"
+#include "dbus.h"
+#include "dbus-private.h"
+
+struct _dbus_name_cache {
+	struct l_dbus *bus;
+	struct l_hashmap *names;
+	const struct _dbus_name_ops *driver;
+};
+
+struct name_cache_entry {
+	int ref_count;
+	char *unique_name;
+};
+
+struct _dbus_name_cache *_dbus_name_cache_new(struct l_dbus *bus,
+					const struct _dbus_name_ops *driver)
+{
+	struct _dbus_name_cache *cache;
+
+	cache =3D l_new(struct _dbus_name_cache, 1);
+
+	cache->bus =3D bus;
+	cache->driver =3D driver;
+
+	return cache;
+}
+
+static void name_cache_entry_destroy(void *data)
+{
+	struct name_cache_entry *entry =3D data;
+
+	l_free(entry->unique_name);
+
+	l_free(entry);
+}
+
+void _dbus_name_cache_free(struct _dbus_name_cache *cache)
+{
+	l_hashmap_destroy(cache->names, name_cache_entry_destroy);
+
+	l_free(cache);
+}
+
+bool _dbus_name_cache_add(struct _dbus_name_cache *cache, const char *name)
+{
+	struct name_cache_entry *entry;
+
+	if (!_dbus_valid_bus_name(name))
+		return false;
+
+	if (!cache->names)
+		cache->names =3D l_hashmap_string_new();
+
+	entry =3D l_hashmap_lookup(cache->names, name);
+
+	if (!entry) {
+		entry =3D l_new(struct name_cache_entry, 1);
+
+		l_hashmap_insert(cache->names, name, entry);
+
+		cache->driver->get_name_owner(cache->bus, name);
+	}
+
+	entry->ref_count++;
+
+	return true;
+}
+
+bool _dbus_name_cache_remove(struct _dbus_name_cache *cache, const char *n=
ame)
+{
+	struct name_cache_entry *entry;
+
+	entry =3D l_hashmap_lookup(cache->names, name);
+
+	if (!entry)
+		return false;
+
+	if (--entry->ref_count)
+		return true;
+
+	l_hashmap_remove(cache->names, name);
+
+	name_cache_entry_destroy(entry);
+
+	return true;
+}
+
+const char *_dbus_name_cache_lookup(struct _dbus_name_cache *cache,
+					const char *name)
+{
+	struct name_cache_entry *entry;
+
+	entry =3D l_hashmap_lookup(cache->names, name);
+
+	if (!entry)
+		return NULL;
+
+	return entry->unique_name;
+}
+
+void _dbus_name_cache_notify(struct _dbus_name_cache *cache,
+				const char *name, const char *owner)
+{
+	struct name_cache_entry *entry;
+
+	if (_dbus_parse_unique_name(name, NULL))
+		return;
+
+	entry =3D l_hashmap_lookup(cache->names, name);
+
+	if (!entry)
+		return;
+
+	l_free(entry->unique_name);
+
+	entry->unique_name =3D (owner && *owner !=3D '\0') ? l_strdup(owner) : NU=
LL;
+}
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 030ce0b..327f0e3 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -273,6 +273,24 @@ uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
 struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus);
 =

+struct _dbus_name_ops {
+	bool (*get_name_owner)(struct l_dbus *bus, const char *name);
+};
+
+struct _dbus_name_cache;
+
+struct _dbus_name_cache *_dbus_name_cache_new(struct l_dbus *bus,
+					const struct _dbus_name_ops *driver);
+void _dbus_name_cache_free(struct _dbus_name_cache *cache);
+
+bool _dbus_name_cache_add(struct _dbus_name_cache *cache, const char *name=
);
+bool _dbus_name_cache_remove(struct _dbus_name_cache *cache, const char *n=
ame);
+const char *_dbus_name_cache_lookup(struct _dbus_name_cache *cache,
+					const char *name);
+
+void _dbus_name_cache_notify(struct _dbus_name_cache *cache,
+				const char *name, const char *owner);
+
 struct _dbus_filter_condition {
 	enum l_dbus_match_type type;
 	const char *value;
diff --git a/ell/dbus.c b/ell/dbus.c
index 84b3fa1..529a26a 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -64,6 +64,7 @@ struct l_dbus_ops {
 				struct l_dbus_message *message);
 	struct l_dbus_message *(*recv_message)(struct l_dbus *bus);
 	void (*free)(struct l_dbus *bus);
+	struct _dbus_name_ops name_ops;
 	struct _dbus_filter_ops filter_ops;
 	uint32_t (*name_acquire)(struct l_dbus *dbus, const char *name,
 				bool allow_replacement, bool replace_existing,
@@ -93,6 +94,7 @@ struct l_dbus {
 	l_dbus_destroy_func_t debug_destroy;
 	void *debug_data;
 	struct _dbus_object_tree *tree;
+	struct _dbus_name_cache *name_cache;
 	struct _dbus_filter *filter;
 =

 	const struct l_dbus_ops *driver;
@@ -571,6 +573,8 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 =

 	dbus->tree =3D _dbus_object_tree_new();
 =

+	dbus->name_cache =3D _dbus_name_cache_new(dbus, &dbus->driver->name_ops);
+
 	dbus->filter =3D _dbus_filter_new(dbus, &dbus->driver->filter_ops);
 }
 =

@@ -768,6 +772,8 @@ static void get_name_owner_reply_cb(struct l_dbus_messa=
ge *reply,
 		return;
 =

 	_dbus_filter_name_owner_notify(req->dbus->filter, name, owner);
+
+	_dbus_name_cache_notify(req->dbus->name_cache, name, owner);
 }
 =

 static bool classic_get_name_owner(struct l_dbus *bus, const char *name)
@@ -879,6 +885,9 @@ static const struct l_dbus_ops classic_ops =3D {
 	.send_message =3D classic_send_message,
 	.recv_message =3D classic_recv_message,
 	.free =3D classic_free,
+	.name_ops =3D {
+		.get_name_owner =3D classic_get_name_owner,
+	},
 	.filter_ops =3D {
 		.add_match =3D classic_add_match,
 		.remove_match =3D classic_remove_match,
@@ -897,6 +906,8 @@ static void name_owner_changed_cb(struct l_dbus_message=
 *message,
 		return;
 =

 	_dbus_filter_name_owner_notify(dbus->filter, name, new);
+
+	_dbus_name_cache_notify(dbus->name_cache, name, new);
 }
 =

 static struct l_dbus *setup_dbus1(int fd, const char *guid)
@@ -1102,9 +1113,14 @@ static void kdbus_name_owner_change_func(const char =
*name, uint64_t old_owner,
 			recv_data->dbus->debug_data,
 			"Read KDBUS Name Owner Change notification");
 =

-	snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
+	if (new_owner)
+		snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
+	else
+		owner[0] =3D '\0';
 =

 	_dbus_filter_name_owner_notify(recv_data->dbus->filter, name, owner);
+
+	_dbus_name_cache_notify(recv_data->dbus->name_cache, name, owner);
 }
 =

 static struct l_dbus_message *kdbus_recv_message(struct l_dbus *dbus)
@@ -1166,16 +1182,16 @@ static bool kdbus_get_name_owner(struct l_dbus *dbu=
s, const char *name)
 	char owner[32];
 =

 	owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_pool, name);
-	if (!owner_id) {
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, "Error getting name owner");
-		return false;
-	}
 =

-	snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
+	if (owner_id)
+		snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
+	else
+		owner[0] =3D '\0';
 =

 	_dbus_filter_name_owner_notify(dbus->filter, name, owner);
 =

+	_dbus_name_cache_notify(dbus->name_cache, name, owner);
+
 	return true;
 }
 =

@@ -1210,6 +1226,9 @@ static const struct l_dbus_ops kdbus_ops =3D {
 	.free =3D kdbus_free,
 	.send_message =3D kdbus_send_message,
 	.recv_message =3D kdbus_recv_message,
+	.name_ops =3D {
+		.get_name_owner =3D kdbus_get_name_owner,
+	},
 	.filter_ops =3D {
 		.add_match =3D kdbus_add_match,
 		.remove_match =3D kdbus_remove_match,
@@ -1355,6 +1374,8 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
 =

 	_dbus_filter_free(dbus->filter);
 =

+	_dbus_name_cache_free(dbus->name_cache);
+
 	l_hashmap_destroy(dbus->signal_list, signal_list_destroy);
 	l_hashmap_destroy(dbus->message_list, message_list_destroy);
 	l_queue_destroy(dbus->message_queue, message_queue_destroy);
-- =

2.5.0


--===============3586685448923810962==--

