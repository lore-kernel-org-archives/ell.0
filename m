Content-Type: multipart/mixed; boundary="===============5623442456944513277=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/15] dbus: Add message filter public API.
Date: Mon, 21 Mar 2016 23:10:22 +0100
Message-ID: <1458598224-29325-13-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5623442456944513277==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A do-it-all single method to add a signal filter, an alternative would
be to add a bunch of functions for specific use cases.
---
 ell/dbus.c | 123 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h |   7 ++++
 2 files changed, 130 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index 0276fe3..b9864bd 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -555,6 +555,8 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 	dbus->signal_list =3D l_hashmap_new();
 =

 	dbus->tree =3D _dbus_object_tree_new();
+
+	dbus->filter =3D _dbus_filter_new(dbus, &dbus->driver->filter_ops);
 }
 =

 static void classic_free(struct l_dbus *dbus)
@@ -1228,6 +1230,8 @@ LIB_EXPORT void l_dbus_destroy(struct l_dbus *dbus)
 	if (dbus->ready_destroy)
 		dbus->ready_destroy(dbus->ready_data);
 =

+	_dbus_filter_free(dbus->filter);
+
 	l_hashmap_destroy(dbus->signal_list, signal_list_destroy);
 	l_hashmap_destroy(dbus->message_list, message_list_destroy);
 	l_queue_destroy(dbus->message_queue, message_queue_destroy);
@@ -1888,3 +1892,122 @@ LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *=
dbus, unsigned int id)
 {
 	return l_dbus_unregister(dbus, id);
 }
+
+/**
+ * l_dbus_add_signal_watch:
+ * @dbus: D-Bus connection
+ * @sender: bus name to match the signal sender against or NULL to
+ *          match any sender
+ * @path: object path to match the signal path against or NULL to
+ *        match any path
+ * @interface: interface name to match the signal interface against
+ *             or NULL to match any interface
+ * @member: name to match the signal name against or NULL to match any
+ *          signal
+ * @...: a list of further conditions to be met by the signal followed
+ *       by three more mandatory parameters:
+ *       enum l_dbus_match_type list_end_marker,
+ *       l_dbus_message_func callback,
+ *       void *user_data,
+ *       The value L_DBUS_MATCH_NONE must be passed as the end of list
+ *       marker, followed by the signal match callback and user_data.
+ *       In the list, every condition is a pair of parameters:
+ *       enum l_dbus_match_type match_type, const char *value.
+ *
+ * Subscribe to a group of signals based on a set of conditions that
+ * compare the signal's header fields and string arguments against given
+ * values.  For example:
+ * 	signal_id =3D l_dbus_add_signal_watch(bus, "org.example", "/"
+ * 						"org.example.Manager",
+ * 						"PropertyChanged",
+ * 						L_DBUS_MATCH_ARGUMENT(0),
+ * 						"ExampleProperty",
+ * 						L_DBUS_MATCH_NONE
+ * 						manager_property_change_cb,
+ * 						NULL);
+  *
+ * Returns: a non-zero signal filter identifier that can be passed to
+ *          l_dbus_remove_signal_watch to remove this filter rule, or
+ *          zero on failure.
+ **/
+LIB_EXPORT unsigned int l_dbus_add_signal_watch(struct l_dbus *dbus,
+						const char *sender,
+						const char *path,
+						const char *interface,
+						const char *member, ...)
+{
+	struct _dbus_filter_condition *rule;
+	int rule_len;
+	va_list args;
+	const char *value;
+	l_dbus_message_func_t signal_func;
+	enum l_dbus_match_type type;
+	void *user_data;
+	unsigned int id;
+
+	va_start(args, member);
+
+	rule_len =3D 0;
+	while ((type =3D va_arg(args, enum l_dbus_match_type)) !=3D
+			L_DBUS_MATCH_NONE)
+		rule_len++;
+
+	va_end(args);
+
+	rule =3D l_new(struct _dbus_filter_condition, rule_len + 5);
+
+	rule_len =3D 0;
+
+	rule[rule_len].type =3D L_DBUS_MATCH_TYPE;
+	rule[rule_len++].value =3D "signal";
+
+	if (sender) {
+		rule[rule_len].type =3D L_DBUS_MATCH_SENDER;
+		rule[rule_len++].value =3D sender;
+	}
+
+	if (path) {
+		rule[rule_len].type =3D L_DBUS_MATCH_PATH;
+		rule[rule_len++].value =3D path;
+	}
+
+	if (interface) {
+		rule[rule_len].type =3D L_DBUS_MATCH_INTERFACE;
+		rule[rule_len++].value =3D interface;
+	}
+
+	if (member) {
+		rule[rule_len].type =3D L_DBUS_MATCH_MEMBER;
+		rule[rule_len++].value =3D member;
+	}
+
+	va_start(args, member);
+
+	while (true) {
+		type =3D va_arg(args, enum l_dbus_match_type);
+		if (type =3D=3D L_DBUS_MATCH_NONE)
+			break;
+
+		value =3D va_arg(args, const char *);
+
+		rule[rule_len].type =3D type;
+		rule[rule_len++].value =3D value;
+	}
+
+	signal_func =3D va_arg(args, l_dbus_message_func_t);
+	user_data =3D va_arg(args, void *);
+
+	va_end(args);
+
+	id =3D _dbus_filter_add_rule(dbus->filter, rule, rule_len,
+					signal_func, user_data);
+
+	l_free(rule);
+
+	return id;
+}
+
+LIB_EXPORT bool l_dbus_remove_signal_watch(struct l_dbus *dbus, unsigned i=
nt id)
+{
+	return _dbus_filter_remove_rule(dbus->filter, id);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index 083f2ff..0f20499 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -245,6 +245,13 @@ unsigned int l_dbus_add_disconnect_watch(struct l_dbus=
 *dbus,
 					l_dbus_destroy_func_t destroy);
 bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id);
 =

+unsigned int l_dbus_add_signal_watch(struct l_dbus *dbus,
+					const char *sender,
+					const char *path,
+					const char *interface,
+					const char *member, ...);
+bool l_dbus_remove_signal_watch(struct l_dbus *dbus, unsigned int id);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.5.0


--===============5623442456944513277==--

