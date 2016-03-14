Content-Type: multipart/mixed; boundary="===============4376357983662703770=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 17/20] dbus: kdbus driver->name_acquire implementation.
Date: Mon, 14 Mar 2016 04:41:33 +0100
Message-ID: <1457926896-9843-17-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4376357983662703770==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c  | 13 ++++++++++++-
 ell/dbus-private.h |  4 +++-
 ell/dbus.c         | 34 ++++++++++++++++++++++++++++++++++
 ell/dbus.h         |  3 +++
 4 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 54d7d4d..e054863 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -621,7 +621,8 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 	return r;
 }
 =

-int _dbus_kernel_name_acquire(int fd, const char *name)
+int _dbus_kernel_name_acquire(int fd, const char *name, bool allow_replace=
ment,
+				bool replace_existing, bool queue, bool *queued)
 {
 	struct {
 		struct kdbus_cmd head;
@@ -646,9 +647,19 @@ int _dbus_kernel_name_acquire(int fd, const char *name)
 	item->type =3D KDBUS_ITEM_NAME;
 	strcpy(item->str, name);
 =

+	if (replace_existing)
+		cmd_name.head.flags |=3D KDBUS_NAME_REPLACE_EXISTING;
+	if (allow_replacement)
+		cmd_name.head.flags |=3D KDBUS_NAME_ALLOW_REPLACEMENT;
+	if (queue)
+		cmd_name.head.flags |=3D KDBUS_NAME_QUEUE;
+
 	if (ioctl(fd, KDBUS_CMD_NAME_ACQUIRE, &cmd_name) < 0)
 		return -errno;
 =

+	if (queued)
+		*queued =3D !!(cmd_name.head.flags & KDBUS_NAME_IN_QUEUE);
+
 	return 0;
 }
 =

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index f210a3c..0dfdc82 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -242,7 +242,9 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 			_dbus_name_owner_change_func_t name_owner_change_func,
 			void *user_data);
 =

-int _dbus_kernel_name_acquire(int fd, const char *name);
+int _dbus_kernel_name_acquire(int fd, const char *name, bool allow_replace=
ment,
+				bool replace_existing, bool queue,
+				bool *queued);
 int _dbus_kernel_add_match(int fd, uint64_t bloom_size, uint64_t bloom_n_h=
ash,
 				const struct _dbus_filter_condition *rule,
 				int rule_len, unsigned int id);
diff --git a/ell/dbus.c b/ell/dbus.c
index 35afd1f..c5cc1fc 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -33,6 +33,7 @@
 #include <string.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <errno.h>
 =

 #include "util.h"
 #include "io.h"
@@ -64,6 +65,10 @@ struct l_dbus_ops {
 	struct l_dbus_message *(*recv_message)(struct l_dbus *bus);
 	void (*free)(struct l_dbus *bus);
 	struct _dbus_filter_ops filter_ops;
+	uint32_t (*name_acquire)(struct l_dbus *dbus, const char *name,
+				bool allow_replacement, bool replace_existing,
+				bool queue, l_dbus_name_acquire_func_t callback,
+				void *user_data);
 };
 =

 struct l_dbus {
@@ -1127,6 +1132,34 @@ static bool kdbus_get_name_owner(struct l_dbus *dbus=
, const char *name)
 	return true;
 }
 =

+static uint32_t kdbus_name_acquire(struct l_dbus *dbus, const char *name,
+					bool allow_replacement,
+					bool replace_existing, bool queue,
+					l_dbus_name_acquire_func_t callback,
+					void *user_data)
+{
+	int fd =3D l_io_get_fd(dbus->io);
+	bool queued =3D false;
+	int r;
+
+	r =3D _dbus_kernel_name_acquire(fd, name, allow_replacement,
+					replace_existing, queue, &queued);
+	if (r < 0 && r !=3D -EALREADY) {
+		l_util_debug(dbus->debug_handler,
+				dbus->debug_data, strerror(-r));
+
+		if (callback)
+			callback(dbus, false, false, user_data);
+
+		return 0;
+	}
+
+	if (callback)
+		callback(dbus, true, queued, user_data);
+
+	return 0;
+}
+
 static const struct l_dbus_ops kdbus_ops =3D {
 	.version  =3D 2,
 	.free =3D kdbus_free,
@@ -1138,6 +1171,7 @@ static const struct l_dbus_ops kdbus_ops =3D {
 		.remove_match =3D kdbus_remove_match,
 		.get_name_owner =3D kdbus_get_name_owner,
 	},
+	.name_acquire =3D kdbus_name_acquire,
 };
 =

 static struct l_dbus *setup_kdbus(int fd)
diff --git a/ell/dbus.h b/ell/dbus.h
index c527058..0b82899 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -68,6 +68,9 @@ typedef void (*l_dbus_interface_setup_func_t) (struct l_d=
bus_interface *);
 =

 typedef void (*l_dbus_watch_func_t) (struct l_dbus *dbus, void *user_data);
 =

+typedef void (*l_dbus_name_acquire_func_t) (struct l_dbus *dbus, bool succ=
ess,
+						bool queued, void *user_data);
+
 struct l_dbus *l_dbus_new(const char *address);
 struct l_dbus *l_dbus_new_default(enum l_dbus_bus bus);
 void l_dbus_destroy(struct l_dbus *dbus);
-- =

2.5.0


--===============4376357983662703770==--

