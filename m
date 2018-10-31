Content-Type: multipart/mixed; boundary="===============0362612140687458690=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 1/3] watchlist: added watchlist functionality
Date: Wed, 31 Oct 2018 13:31:43 -0700
Message-ID: <20181031203145.5637-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0362612140687458690==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These two files (watchlist.[ch]) were copied from IWD, and public
API's changed to l_ prefix.
---
 Makefile.am     |   6 +-
 ell/ell.h       |   1 +
 ell/watchlist.c | 149 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/watchlist.h | 129 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 283 insertions(+), 2 deletions(-)
 create mode 100644 ell/watchlist.c
 create mode 100644 ell/watchlist.h

diff --git a/Makefile.am b/Makefile.am
index 0a8d0f6..31612a7 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -48,7 +48,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/file.h \
 			ell/dir.h \
 			ell/net.h \
-			ell/dhcp.h
+			ell/dhcp.h \
+			ell/watchlist.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -109,7 +110,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp-private.h \
 			ell/dhcp.c \
 			ell/dhcp-transport.c \
-			ell/dhcp-lease.c
+			ell/dhcp-lease.c \
+			ell/watchlist.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index ba1928d..0d8e74e 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -56,3 +56,4 @@
 #include <ell/dbus-service.h>
 #include <ell/dbus-client.h>
 #include <ell/dhcp.h>
+#include <ell/watchlist.h>
diff --git a/ell/watchlist.c b/ell/watchlist.c
new file mode 100644
index 0000000..d300756
--- /dev/null
+++ b/ell/watchlist.c
@@ -0,0 +1,149 @@
+/*
+ *
+ *  Wireless daemon for Linux
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
+#include <ell/ell.h>
+
+static bool watchlist_item_match(const void *a, const void *b)
+{
+	const struct l_watchlist_item *item =3D a;
+	uint32_t id =3D L_PTR_TO_UINT(b);
+
+	return item->id =3D=3D id;
+}
+
+static void __watchlist_item_free(struct l_watchlist *watchlist,
+						struct l_watchlist_item *item)
+{
+	if (item->destroy)
+		item->destroy(item->notify_data);
+
+	if (watchlist->ops && watchlist->ops->item_free)
+		watchlist->ops->item_free(item);
+	else
+		l_free(item);
+}
+
+struct l_watchlist *l_watchlist_new(const struct l_watchlist_ops *ops)
+{
+	struct l_watchlist *watchlist;
+
+	watchlist =3D l_new(struct l_watchlist, 1);
+	watchlist->items =3D l_queue_new();
+	watchlist->ops =3D ops;
+	return watchlist;
+}
+
+void l_watchlist_init(struct l_watchlist *watchlist,
+					const struct l_watchlist_ops *ops)
+{
+	watchlist->next_id =3D 0;
+	watchlist->items =3D l_queue_new();
+	watchlist->ops =3D ops;
+}
+
+unsigned int l_watchlist_link(struct l_watchlist *watchlist,
+					struct l_watchlist_item *item,
+					void *notify, void *notify_data,
+					l_watchlist_item_destroy_func_t destroy)
+{
+	item->id =3D ++watchlist->next_id;
+	item->notify =3D notify;
+	item->notify_data =3D notify_data;
+	item->destroy =3D destroy;
+
+	l_queue_push_tail(watchlist->items, item);
+
+	return item->id;
+}
+
+unsigned int l_watchlist_add(struct l_watchlist *watchlist, void *notify,
+					void *notify_data,
+					l_watchlist_item_destroy_func_t destroy)
+{
+	struct l_watchlist_item *item;
+
+	item =3D l_new(struct l_watchlist_item, 1);
+	return l_watchlist_link(watchlist, item, notify, notify_data, destroy);
+}
+
+bool l_watchlist_remove(struct l_watchlist *watchlist, unsigned int id)
+{
+	struct l_watchlist_item *item;
+
+	if (watchlist->in_notify) {
+		item =3D l_queue_find(watchlist->items, watchlist_item_match,
+							L_UINT_TO_PTR(id));
+		if (!item)
+			return false;
+
+		item->id =3D 0;	/* Mark stale */
+		watchlist->stale_items =3D true;
+
+		return true;
+	}
+
+	item =3D l_queue_remove_if(watchlist->items, watchlist_item_match,
+							L_UINT_TO_PTR(id));
+	if (!item)
+		return false;
+
+	__watchlist_item_free(watchlist, item);
+
+	return true;
+}
+
+static void __watchlist_clear(struct l_watchlist *watchlist)
+{
+	struct l_watchlist_item *item;
+
+	while ((item =3D l_queue_pop_head(watchlist->items)))
+		__watchlist_item_free(watchlist, item);
+}
+
+void l_watchlist_destroy(struct l_watchlist *watchlist)
+{
+	__watchlist_clear(watchlist);
+	l_queue_destroy(watchlist->items, NULL);
+	watchlist->items =3D NULL;
+}
+
+void l_watchlist_free(struct l_watchlist *watchlist)
+{
+	__watchlist_clear(watchlist);
+	l_queue_destroy(watchlist->items, NULL);
+	l_free(watchlist);
+}
+
+void __watchlist_prune_stale(struct l_watchlist *watchlist)
+{
+	struct l_watchlist_item *item;
+
+	while ((item =3D l_queue_remove_if(watchlist->items, watchlist_item_match,
+							L_UINT_TO_PTR(0))))
+		__watchlist_item_free(watchlist, item);
+
+	watchlist->stale_items =3D false;
+}
diff --git a/ell/watchlist.h b/ell/watchlist.h
new file mode 100644
index 0000000..89a6374
--- /dev/null
+++ b/ell/watchlist.h
@@ -0,0 +1,129 @@
+/*
+ *
+ *  Wireless daemon for Linux
+ *
+ *  Copyright (C) 2016-2017  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_WATCHLIST_H
+#define __ELL_WATCHLIST_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+typedef void (*l_watchlist_item_destroy_func_t)(void *data);
+
+struct l_watchlist_item {
+	unsigned int id;
+	void *notify;
+	void *notify_data;
+	l_watchlist_item_destroy_func_t destroy;
+};
+
+struct l_watchlist_ops {
+	void (*item_free)(struct l_watchlist_item *item);
+};
+
+struct l_watchlist {
+	int next_id;
+	struct l_queue *items;
+	bool in_notify : 1;
+	bool stale_items : 1;
+	const struct l_watchlist_ops *ops;
+};
+
+struct l_watchlist *l_watchlist_new(const struct l_watchlist_ops *ops);
+void l_watchlist_init(struct l_watchlist *watchlist,
+				const struct l_watchlist_ops *ops);
+unsigned int l_watchlist_add(struct l_watchlist *watchlist, void *notify,
+				void *notify_data,
+				l_watchlist_item_destroy_func_t destroy);
+unsigned int l_watchlist_link(struct l_watchlist *watchlist,
+				struct l_watchlist_item *item,
+				void *notify, void *notify_data,
+				l_watchlist_item_destroy_func_t destroy);
+bool l_watchlist_remove(struct l_watchlist *watchlist, unsigned int id);
+void l_watchlist_destroy(struct l_watchlist *watchlist);
+void l_watchlist_free(struct l_watchlist *watchlist);
+
+void __watchlist_prune_stale(struct l_watchlist *watchlist);
+
+#define L_WATCHLIST_NOTIFY(watchlist, type, args...)			\
+	do {								\
+		const struct l_queue_entry *entry =3D			\
+				l_queue_get_entries((watchlist)->items);\
+									\
+		(watchlist)->in_notify =3D true;				\
+		for (; entry; entry =3D entry->next) {			\
+			struct l_watchlist_item *item =3D entry->data;	\
+			type t =3D item->notify;				\
+			if (item->id =3D=3D 0)				\
+				continue;				\
+			t(args, item->notify_data);			\
+		}							\
+		(watchlist)->in_notify =3D false;				\
+		if ((watchlist)->stale_items)				\
+			__watchlist_prune_stale(watchlist);		\
+	} while	(false)							\
+
+#define L_WATCHLIST_NOTIFY_MATCHES(watchlist, match, match_data, type, arg=
s...) \
+	do {								\
+		const struct l_queue_entry *entry =3D			\
+				l_queue_get_entries((watchlist)->items);\
+									\
+		(watchlist)->in_notify =3D true;				\
+		for (; entry; entry =3D entry->next) {			\
+			struct l_watchlist_item *item =3D entry->data;	\
+			type t =3D item->notify;				\
+									\
+			if (item->id =3D=3D 0)				\
+				continue;				\
+			if (!match(item, match_data))			\
+				continue;				\
+									\
+			t(args, item->notify_data);			\
+		}							\
+		(watchlist)->in_notify =3D false;				\
+		if ((watchlist)->stale_items)				\
+			__watchlist_prune_stale(watchlist);		\
+	} while	(false)
+
+#define L_WATCHLIST_NOTIFY_NO_ARGS(watchlist, type)			\
+	do {								\
+		const struct l_queue_entry *entry =3D			\
+				l_queue_get_entries((watchlist)->items);\
+									\
+		(watchlist)->in_notify =3D true;				\
+		for (; entry; entry =3D entry->next) {			\
+			struct l_watchlist_item *item =3D entry->data;	\
+			type t =3D item->notify;				\
+			if (item->id =3D=3D 0)				\
+				continue;				\
+			t(item->notify_data);			\
+		}							\
+		(watchlist)->in_notify =3D false;				\
+		if ((watchlist)->stale_items)				\
+			__watchlist_prune_stale(watchlist);		\
+	} while	(false)
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_WATCHLIST_H */
\ No newline at end of file
-- =

2.17.1


--===============0362612140687458690==--

