Content-Type: multipart/mixed; boundary="===============4563679057866419965=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v4 5/6] dbus: Add disconnect watch support
Date: Fri, 20 Feb 2015 14:16:40 +0200
Message-ID: <1424434601-2211-6-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424434601-2211-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4563679057866419965==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow caller to monitor the disconnect status of a service.
---
 ell/dbus-private.h |  14 +++++
 ell/dbus.c         | 154 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h         |   7 +++
 3 files changed, 175 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 0123ddb..868bfb5 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -217,3 +217,17 @@ struct dbus_filter_data;
 =

 void _dbus1_format_rule(struct dbus_filter_data *data, char *rule,
 								size_t size);
+void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata);
+struct dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
+					l_dbus_message_func_t filter,
+					const char *sender,
+					const char *path,
+					const char *interface,
+					const char *member,
+					const char *argument,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy);
+void _dbus1_filter_data_destroy(void *user_data);
+void _dbus1_name_owner_changed_filter(struct l_dbus_message *message,
+							void *user_data);
diff --git a/ell/dbus.c b/ell/dbus.c
index a3d8070..361d462 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -53,6 +53,8 @@
 #define DBUS_INTERFACE_INTROSPECTABLE	"org.freedesktop.DBus.Introspectable"
 #define DBUS_INTERFACE_PROPERTIES	"org.freedesktop.DBus.Properties"
 =

+#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
+
 enum auth_state {
 	WAITING_FOR_OK,
 	WAITING_FOR_AGREE_UNIX_FD,
@@ -1290,3 +1292,155 @@ void _dbus1_format_rule(struct dbus_filter_data *da=
ta, char *rule,
 		snprintf(rule + offset, size - offset,
 				",arg0=3D'%s'", data->argument);
 }
+
+static void add_match(struct dbus_filter_data *data)
+{
+	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
+
+	_dbus1_format_rule(data, rule, sizeof(rule));
+
+	dbus1_bus_add_match(data->dbus, rule);
+}
+
+static void remove_match(struct dbus_filter_data *data)
+{
+	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
+
+	_dbus1_format_rule(data, rule, sizeof(rule));
+
+	dbus1_bus_remove_match(data->dbus, rule);
+}
+
+struct dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
+					l_dbus_message_func_t filter,
+					const char *sender,
+					const char *path,
+					const char *interface,
+					const char *member,
+					const char *argument,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	struct dbus_filter_data *data;
+
+	data =3D l_new(struct dbus_filter_data, 1);
+
+	data->dbus =3D dbus;
+	data->handle_func =3D filter;
+	data->disconnect_func =3D disconnect_func;
+	data->sender =3D l_strdup(sender);
+	data->path =3D l_strdup(path);
+	data->interface =3D l_strdup(interface);
+	data->member =3D l_strdup(member);
+	data->argument =3D l_strdup(argument);
+	data->user_data =3D user_data;
+	data->destroy_func =3D destroy;
+
+	return data;
+}
+
+void _dbus1_filter_data_destroy(void *user_data)
+{
+	struct dbus_filter_data *data =3D user_data;
+
+	l_free(data->sender);
+	l_free(data->path);
+	l_free(data->interface);
+	l_free(data->member);
+	l_free(data->argument);
+
+	if (data->destroy_func)
+		data->destroy_func(data->user_data);
+
+	l_free(data);
+}
+
+static void filter_data_destroy(void *user_data)
+{
+	remove_match(user_data);
+
+	_dbus1_filter_data_destroy(user_data);
+}
+
+void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata)
+{
+	struct dbus_filter_data *data =3D user_data;
+	const char *sender, *path, *iface, *member;
+
+	if (_dbus_message_get_type(message) !=3D DBUS_MESSAGE_TYPE_SIGNAL)
+		return;
+
+	sender =3D l_dbus_message_get_sender(message);
+	if (!sender)
+		return;
+
+	if (data->sender && strcmp(sender, data->sender))
+		return;
+
+	path =3D l_dbus_message_get_path(message);
+	if (data->path && strcmp(path, data->path))
+		return;
+
+	iface =3D l_dbus_message_get_interface(message);
+	if (data->interface && strcmp(iface, data->interface))
+		return;
+
+	member =3D l_dbus_message_get_member(message);
+	if (data->member && strcmp(member, data->member))
+		return;
+
+	if (data->handle_func)
+		data->handle_func(message, data);
+}
+
+void _dbus1_name_owner_changed_filter(struct l_dbus_message *message,
+							void *user_data)
+{
+	struct dbus_filter_data *data =3D user_data;
+	char *name, *old, *new;
+
+	if (!l_dbus_message_get_arguments(message, "sss",
+						&name, &old, &new))
+		return;
+
+	if (strcmp(name, data->argument))
+		return;
+
+	if (*new =3D=3D '\0') {
+		if (data->disconnect_func)
+			data->disconnect_func(data->dbus, data->user_data);
+	}
+}
+
+LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
+					const char *name,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	struct dbus_filter_data *data;
+
+	if (!name)
+		return 0;
+
+	data =3D _dbus1_filter_data_get(dbus, _dbus1_name_owner_changed_filter,
+				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
+				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
+				name,
+				disconnect_func,
+				user_data,
+				destroy);
+	if (!data)
+		return 0;
+
+	add_match(data);
+
+	return l_dbus_register(dbus, _dbus1_signal_dispatcher, data,
+							filter_data_destroy);
+}
+
+LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
+{
+	return l_dbus_unregister(dbus, id);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index b2469f3..39f926b 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -198,6 +198,13 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
 				l_dbus_destroy_func_t destroy);
 bool l_dbus_unregister_interface(struct l_dbus *dbus, const char *path,
 					const char *interface);
+unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
+					const char *name,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy);
+bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.1.0


--===============4563679057866419965==--

