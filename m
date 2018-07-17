Content-Type: multipart/mixed; boundary="===============6564960746227827504=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] fswatch: Add fswatch API
Date: Tue, 17 Jul 2018 19:08:21 +0200
Message-ID: <20180717170822.22416-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6564960746227827504==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the header and the implementation for a filesystem watch API.  It's
a simple wrapper around the Linux inotify mechanism but not named inotify
so as not to preclude using other mechanisms in the implemntation.
---
 Makefile.am   |   6 +-
 ell/ell.h     |   1 +
 ell/fswatch.c | 231 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/fswatch.h |  35 +++++++++
 4 files changed, 271 insertions(+), 2 deletions(-)
 create mode 100644 ell/fswatch.c
 create mode 100644 ell/fswatch.h

diff --git a/Makefile.am b/Makefile.am
index 100e24c..8203fd4 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -45,7 +45,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/pkcs5.h \
 			ell/file.h \
 			ell/net.h \
-			ell/dhcp.h
+			ell/dhcp.h \
+			ell/fswatch.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -104,7 +105,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp-private.h \
 			ell/dhcp.c \
 			ell/dhcp-transport.c \
-			ell/dhcp-lease.c
+			ell/dhcp-lease.c \
+			ell/fswatch.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/ell.h b/ell/ell.h
index 03bb61d..c03faf2 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -53,3 +53,4 @@
 #include <ell/dbus-service.h>
 #include <ell/dbus-client.h>
 #include <ell/dhcp.h>
+#include <ell/fswatch.h>
diff --git a/ell/fswatch.c b/ell/fswatch.c
new file mode 100644
index 0000000..1ac80e4
--- /dev/null
+++ b/ell/fswatch.c
@@ -0,0 +1,231 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#include <dirent.h>
+#include <unistd.h>
+#include <sys/inotify.h>
+
+#include "private.h"
+#include "util.h"
+#include "io.h"
+#include "queue.h"
+#include "fswatch.h"
+
+static struct l_io *inotify_io;
+static struct l_queue *watches;
+static bool in_notify;
+static bool stale_items;
+
+struct l_fswatch {
+	char *path;
+	int id;
+	l_fswatch_cb_t cb;
+	void *user_data;
+};
+
+#define EVENT_MASK	(IN_CREATE | IN_DELETE | IN_DELETE_SELF | \
+				IN_MODIFY | IN_MOVE | IN_MOVE_SELF)
+
+typedef void (*l_fswatch_cb_t) (struct l_fswatch *watch, const char *filen=
ame,
+				void *user_data);
+
+static void l_fswatch_destroy(void *data)
+{
+	struct l_fswatch *watch =3D data;
+
+	l_free(watch->path);
+	l_free(watch);
+}
+
+static void l_fswatch_shutdown(void)
+{
+	if (!inotify_io)
+		return;
+
+	l_io_destroy(inotify_io);
+	inotify_io =3D NULL;
+
+	l_queue_destroy(watches, l_fswatch_destroy);
+	watches =3D NULL;
+}
+
+static bool l_fswatch_remove_func(void *data, void *user_data)
+{
+	struct l_fswatch *watch =3D data;
+
+	if (watch->cb)
+		return false;
+
+	l_fswatch_destroy(watch);
+
+	return true;
+}
+
+static bool inotify_read_cb(struct l_io *io, void *user_data)
+{
+	uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1];
+	const struct inotify_event *event;
+	ssize_t len;
+
+	len =3D read(l_io_get_fd(io), buf, sizeof(buf));
+	if (unlikely(len <=3D 0))
+		return true;
+
+	event =3D (struct inotify_event *) buf;
+	in_notify =3D true;
+
+	while ((size_t) len >=3D sizeof(struct inotify_event) + event->len) {
+		const struct l_queue_entry *entry;
+		const uint8_t *next_ptr;
+		const char *name =3D NULL;
+
+		if (event->len)
+			name =3D event->name;
+
+		for (entry =3D l_queue_get_entries(watches); entry;
+				entry =3D entry->next) {
+			struct l_fswatch *watch =3D entry->data;
+
+			if (watch->id !=3D event->wd)
+				continue;
+
+			if (event->mask & IN_IGNORED)
+				watch->id =3D -1;
+
+			if ((event->mask & EVENT_MASK) && watch->cb)
+				watch->cb(watch, name, watch->user_data);
+		}
+
+		len -=3D sizeof(struct inotify_event) + event->len;
+		/* event->len is supposed to include alignment */
+		next_ptr =3D (const uint8_t *) (event + 1) + event->len;
+		event =3D (struct inotify_event *) next_ptr;
+	}
+
+	in_notify =3D false;
+
+	if (stale_items) {
+		l_queue_foreach_remove(watches, l_fswatch_remove_func, NULL);
+		stale_items =3D false;
+
+		if (l_queue_isempty(watches))
+			l_fswatch_shutdown();
+	}
+
+	return true;
+}
+
+LIB_EXPORT struct l_fswatch *l_fswatch_new(const char *path, l_fswatch_cb_=
t cb,
+						void *user_data)
+{
+	struct l_fswatch *watch;
+	int id;
+
+	if (!inotify_io) {
+		int inotify_fd =3D inotify_init1(IN_CLOEXEC);
+
+		if (unlikely(inotify_fd < 0))
+			return NULL;
+
+		inotify_io =3D l_io_new(inotify_fd);
+		if (unlikely(!inotify_io)) {
+			close(inotify_fd);
+			return NULL;
+		}
+
+		l_io_set_close_on_destroy(inotify_io, true);
+
+		if (unlikely(!l_io_set_read_handler(inotify_io, inotify_read_cb,
+							NULL, NULL))) {
+			l_io_destroy(inotify_io);
+			return NULL;
+		}
+	}
+
+	/*
+	 * inotify_watch_add already checks if the path is already being
+	 * watched and will return the old watch ID so we're fine.
+	 */
+	id =3D inotify_add_watch(l_io_get_fd(inotify_io), path,
+						EVENT_MASK | IN_EXCL_UNLINK);
+	if (unlikely(id < 0)) {
+		if (l_queue_isempty(watches))
+			l_fswatch_shutdown();
+
+		return NULL;
+	}
+
+	watch =3D l_new(struct l_fswatch, 1);
+	watch->path =3D l_strdup(path);
+	watch->id =3D id;
+	watch->cb =3D cb;
+	watch->user_data =3D user_data;
+
+	if (!watches)
+		watches =3D l_queue_new();
+
+	l_queue_push_tail(watches, watch);
+
+	return watch;
+}
+
+LIB_EXPORT bool l_fswatch_remove(struct l_fswatch *watch)
+{
+	const struct l_queue_entry *entry;
+	int id;
+
+	if (unlikely(!inotify_io || !watch))
+		return false;
+
+	id =3D watch->id;
+
+	/* Check if we have any other watch with the same inotify ID */
+	for (entry =3D l_queue_get_entries(watches); entry;
+			entry =3D entry->next) {
+		struct l_fswatch *watch2 =3D entry->data;
+
+		if (watch2 !=3D watch && watch2->id =3D=3D id)
+			break;
+	}
+
+	if (!entry && id !=3D -1)
+		if (inotify_rm_watch(l_io_get_fd(inotify_io), id) < 0)
+			return false;
+
+	if (in_notify) {
+		watch->cb =3D NULL;
+		stale_items =3D false;
+		return true;
+	}
+
+	l_queue_remove(watches, watch);
+	l_fswatch_destroy(watch);
+
+	if (l_queue_isempty(watches))
+		l_fswatch_shutdown();
+
+	return true;
+}
diff --git a/ell/fswatch.h b/ell/fswatch.h
new file mode 100644
index 0000000..1aa18ad
--- /dev/null
+++ b/ell/fswatch.h
@@ -0,0 +1,35 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_FSWATCH_H
+#define __ELL_FSWATCH_H
+
+struct l_fswatch;
+
+typedef void (*l_fswatch_cb_t) (struct l_fswatch *watch, const char *filen=
ame,
+				void *user_data);
+
+struct l_fswatch *l_fswatch_new(const char *path, l_fswatch_cb_t cb,
+				void *user_data);
+bool l_fswatch_remove(struct l_fswatch *watch);
+
+#endif /* __ELL_FSWATCH_H */
-- =

2.14.1


--===============6564960746227827504==--

