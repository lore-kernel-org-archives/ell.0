Content-Type: multipart/mixed; boundary="===============8565491221461911646=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Create dbus->filter and name_cache lazily
Date: Wed, 11 May 2016 11:36:08 +0200
Message-ID: <1462959370-30764-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1462959370-30764-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8565491221461911646==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 96 +++++++++++++++++++++++++++++++++++++++++-----------------=
----
 1 file changed, 63 insertions(+), 33 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 7cb4740..69222e9 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -96,6 +96,7 @@ struct l_dbus {
 	struct _dbus_object_tree *tree;
 	struct _dbus_name_cache *name_cache;
 	struct _dbus_filter *filter;
+	bool name_notify_enabled;
 =

 	const struct l_dbus_ops *driver;
 };
@@ -545,11 +546,6 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 	dbus->signal_list =3D l_hashmap_new();
 =

 	dbus->tree =3D _dbus_object_tree_new();
-
-	dbus->name_cache =3D _dbus_name_cache_new(dbus, &dbus->driver->name_ops);
-
-	dbus->filter =3D _dbus_filter_new(dbus, &dbus->driver->filter_ops,
-					dbus->name_cache);
 }
 =

 static void classic_free(struct l_dbus *dbus)
@@ -742,6 +738,18 @@ static bool classic_remove_match(struct l_dbus *dbus, =
unsigned int id)
 	return true;
 }
 =

+static void name_owner_changed_cb(struct l_dbus_message *message,
+					void *user_data)
+{
+	struct l_dbus *dbus =3D user_data;
+	char *name, *old, *new;
+
+	if (!l_dbus_message_get_arguments(message, "sss", &name, &old, &new))
+		return;
+
+	_dbus_name_cache_notify(dbus->name_cache, name, new);
+}
+
 struct get_name_owner_request {
 	struct l_dbus_message *message;
 	struct l_dbus *dbus;
@@ -789,6 +797,26 @@ static bool classic_get_name_owner(struct l_dbus *bus,=
 const char *name)
 	send_message(bus, false, req->message, get_name_owner_reply_cb,
 			req, l_free);
 =

+	if (!bus->name_notify_enabled) {
+		static struct _dbus_filter_condition rule[] =3D {
+			{ L_DBUS_MATCH_TYPE,		"signal" },
+			{ L_DBUS_MATCH_SENDER,		DBUS_SERVICE_DBUS },
+			{ L_DBUS_MATCH_PATH,		DBUS_PATH_DBUS },
+			{ L_DBUS_MATCH_INTERFACE,	L_DBUS_INTERFACE_DBUS },
+			{ L_DBUS_MATCH_MEMBER,		"NameOwnerChanged" },
+		};
+
+		if (!bus->filter)
+			bus->filter =3D _dbus_filter_new(bus,
+						&bus->driver->filter_ops,
+						bus->name_cache);
+
+		_dbus_filter_add_rule(bus->filter, rule, L_ARRAY_SIZE(rule),
+					name_owner_changed_cb, bus);
+
+		bus->name_notify_enabled =3D true;
+	}
+
 	return true;
 }
 =

@@ -887,18 +915,6 @@ static const struct l_dbus_ops classic_ops =3D {
 	.name_acquire =3D classic_name_acquire,
 };
 =

-static void name_owner_changed_cb(struct l_dbus_message *message,
-					void *user_data)
-{
-	struct l_dbus *dbus =3D user_data;
-	char *name, *old, *new;
-
-	if (!l_dbus_message_get_arguments(message, "sss", &name, &old, &new))
-		return;
-
-	_dbus_name_cache_notify(dbus->name_cache, name, new);
-}
-
 static struct l_dbus *setup_dbus1(int fd, const char *guid)
 {
 	static const unsigned char creds =3D 0x00;
@@ -908,13 +924,6 @@ static struct l_dbus *setup_dbus1(int fd, const char *=
guid)
 	ssize_t written;
 	unsigned int i;
 	long flags;
-	static struct _dbus_filter_condition rule[] =3D {
-		{ L_DBUS_MATCH_TYPE,		"signal" },
-		{ L_DBUS_MATCH_SENDER,		DBUS_SERVICE_DBUS },
-		{ L_DBUS_MATCH_PATH,		DBUS_PATH_DBUS },
-		{ L_DBUS_MATCH_INTERFACE,	L_DBUS_INTERFACE_DBUS },
-		{ L_DBUS_MATCH_MEMBER,		"NameOwnerChanged" },
-	};
 =

 	if (snprintf(uid, sizeof(uid), "%d", geteuid()) < 1) {
 		close(fd);
@@ -963,9 +972,6 @@ static struct l_dbus *setup_dbus1(int fd, const char *g=
uid)
 	l_io_set_read_handler(dbus->io, auth_read_handler, dbus, NULL);
 	l_io_set_write_handler(dbus->io, auth_write_handler, dbus, NULL);
 =

-	_dbus_filter_add_rule(dbus->filter, rule, L_ARRAY_SIZE(rule),
-				name_owner_changed_cb, dbus);
-
 	return dbus;
 }
 =

@@ -1167,6 +1173,7 @@ static bool kdbus_get_name_owner(struct l_dbus *dbus,=
 const char *name)
 	int fd =3D l_io_get_fd(dbus->io);
 	uint64_t owner_id;
 	char owner[32];
+	int r;
 =

 	owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_pool, name);
 =

@@ -1177,6 +1184,15 @@ static bool kdbus_get_name_owner(struct l_dbus *dbus=
, const char *name)
 =

 	_dbus_name_cache_notify(dbus->name_cache, name, owner);
 =

+	if (!dbus->name_notify_enabled) {
+		r =3D _dbus_kernel_enable_name_owner_notify(fd);
+		if (r < 0)
+			l_util_debug(dbus->debug_handler,
+					dbus->debug_data, strerror(-r));
+
+		dbus->name_notify_enabled =3D true;
+	}
+
 	return true;
 }
 =

@@ -1225,7 +1241,6 @@ static struct l_dbus *setup_kdbus(int fd)
 {
 	struct l_dbus *dbus;
 	struct l_dbus_kdbus *kdbus;
-	int r;
 =

 	kdbus =3D l_new(struct l_dbus_kdbus, 1);
 	dbus =3D &kdbus->super;
@@ -1246,11 +1261,6 @@ static struct l_dbus *setup_kdbus(int fd)
 =

 	l_idle_oneshot(kdbus_ready, dbus, NULL);
 =

-	r =3D _dbus_kernel_enable_name_owner_notify(fd);
-	if (r < 0)
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-
 	return dbus;
 }
 =

@@ -1760,6 +1770,10 @@ LIB_EXPORT unsigned int l_dbus_add_service_watch(str=
uct l_dbus *dbus,
 	if (!name)
 		return 0;
 =

+	if (!dbus->name_cache)
+		dbus->name_cache =3D _dbus_name_cache_new(dbus,
+						&dbus->driver->name_ops);
+
 	return _dbus_name_cache_add_watch(dbus->name_cache, name, connect_func,
 						disconnect_func, user_data,
 						destroy);
@@ -1767,6 +1781,9 @@ LIB_EXPORT unsigned int l_dbus_add_service_watch(stru=
ct l_dbus *dbus,
 =

 LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
 {
+	if (!dbus->name_cache)
+		return false;
+
 	return _dbus_name_cache_remove_watch(dbus->name_cache, id);
 }
 =

@@ -1876,6 +1893,16 @@ LIB_EXPORT unsigned int l_dbus_add_signal_watch(stru=
ct l_dbus *dbus,
 =

 	va_end(args);
 =

+	if (!dbus->filter) {
+		if (!dbus->name_cache)
+			dbus->name_cache =3D _dbus_name_cache_new(dbus,
+						&dbus->driver->name_ops);
+
+		dbus->filter =3D _dbus_filter_new(dbus,
+						&dbus->driver->filter_ops,
+						dbus->name_cache);
+	}
+
 	id =3D _dbus_filter_add_rule(dbus->filter, rule, rule_len,
 					signal_func, user_data);
 =

@@ -1886,6 +1913,9 @@ LIB_EXPORT unsigned int l_dbus_add_signal_watch(struc=
t l_dbus *dbus,
 =

 LIB_EXPORT bool l_dbus_remove_signal_watch(struct l_dbus *dbus, unsigned i=
nt id)
 {
+	if (!dbus->filter)
+		return false;
+
 	return _dbus_filter_remove_rule(dbus->filter, id);
 }
 =

-- =

2.7.4


--===============8565491221461911646==--

