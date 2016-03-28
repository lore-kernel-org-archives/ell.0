Content-Type: multipart/mixed; boundary="===============4803251534634866813=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] dbus: l_dbus_name_acquire public API and driver
 declarations
Date: Tue, 29 Mar 2016 00:09:19 +0200
Message-ID: <1459202963-12390-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4803251534634866813==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 34 ++++++++++++++++++++++++++++++++++
 ell/dbus.h |  8 ++++++++
 2 files changed, 42 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index b9864bd..7d873ff 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -64,6 +64,10 @@ struct l_dbus_ops {
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
@@ -2011,3 +2015,33 @@ LIB_EXPORT bool l_dbus_remove_signal_watch(struct l_=
dbus *dbus, unsigned int id)
 {
 	return _dbus_filter_remove_rule(dbus->filter, id);
 }
+
+/**
+ * l_dbus_name_acquire:
+ * @dbus: D-Bus connection
+ * @name: Well-known bus name to be acquired
+ * @allow_replacement: Whether to allow another peer's name request to
+ *                     take the name ownership away from this connection
+ * @replace_existing: Whether to allow D-Bus to take the name's ownership
+ *                    away from another peer in case the name is already
+ *                    owned and allows replacement.  Ignored if name is
+ *                    currently free.
+ * @queue: Whether to allow the name request to be queued by D-Bus in
+ *         case it cannot be acquired now, rather than to return a failure.
+ * @callback: Callback to receive the request result when done.
+ *
+ * Acquire a well-known bus name (service name) on the bus.
+ *
+ * Returns: a non-zero request serial that can be passed to l_dbus_cancel
+ *          while waiting for the callback or zero if the callback has
+ *          has happened while l_dbus_name_acquire was running.
+ **/
+LIB_EXPORT uint32_t l_dbus_name_acquire(struct l_dbus *dbus, const char *n=
ame,
+				bool allow_replacement, bool replace_existing,
+				bool queue, l_dbus_name_acquire_func_t callback,
+				void *user_data)
+{
+	return dbus->driver->name_acquire(dbus, name, allow_replacement,
+						replace_existing, queue,
+						callback, user_data);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index 0f20499..b096ed3 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -67,6 +67,9 @@ typedef void (*l_dbus_interface_setup_func_t) (struct l_d=
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
@@ -252,6 +255,11 @@ unsigned int l_dbus_add_signal_watch(struct l_dbus *db=
us,
 					const char *member, ...);
 bool l_dbus_remove_signal_watch(struct l_dbus *dbus, unsigned int id);
 =

+uint32_t l_dbus_name_acquire(struct l_dbus *dbus, const char *name,
+				bool allow_replacement, bool replace_existing,
+				bool queue, l_dbus_name_acquire_func_t callback,
+				void *user_data);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.5.0


--===============4803251534634866813==--

