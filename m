Content-Type: multipart/mixed; boundary="===============3343724736902021705=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v3 3/4] dbus: Add disconnect watch support
Date: Wed, 18 Feb 2015 18:08:35 +0200
Message-ID: <1424275716-7198-4-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424275716-7198-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3343724736902021705==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow caller to monitor the disconnect status of a service.
---
 ell/dbus-private.h |  35 ++++++++++
 ell/dbus.c         | 195 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h         |   9 +++
 3 files changed, 239 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 9987294..cbde2fd 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -212,3 +212,38 @@ int _dbus_kernel_remove_match(int fd, uint64_t cookie);
 =

 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
+
+struct _dbus_filter_data {
+	struct l_dbus *dbus;
+	l_dbus_message_func_t handle_func;
+	l_dbus_watch_func_t connect_func;
+	l_dbus_watch_func_t disconnect_func;
+	char *sender;
+	char *path;
+	char *interface;
+	char *member;
+	char *argument;
+	void *user_data;
+	l_dbus_destroy_func_t destroy_func;
+};
+
+typedef void (*l_dbus_match_func_t) (struct _dbus_filter_data *data,
+					l_dbus_message_func_t filter);
+
+void _dbus_message_filter_dispatcher(struct l_dbus_message *message,
+				     void *user_data);
+void _dbus1_format_rule(struct _dbus_filter_data *data, char *rule,
+			size_t size);
+struct _dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
+					l_dbus_message_func_t filter,
+					const char *sender,
+					const char *path,
+					const char *interface,
+					const char *member,
+					const char *argument,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy,
+					l_dbus_match_func_t match);
+void _dbus1_filter_data_destroy(void *user_data, l_dbus_match_func_t match=
);
+void _dbus1_service_filter(struct l_dbus_message *message, void *user_data=
);
diff --git a/ell/dbus.c b/ell/dbus.c
index c10e0ed..8596449 100644
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
@@ -1253,3 +1255,196 @@ static void _dbus_bus_remove_match(struct l_dbus *d=
bus, const char *rule)
 {
 	send_match(dbus, rule, "RemoveMatch");
 }
+
+void _dbus1_format_rule(struct _dbus_filter_data *data, char *rule,
+			size_t size)
+{
+	int offset;
+
+	offset =3D snprintf(rule, size, "type=3D'signal'");
+
+	if (data->sender)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",sender=3D'%s'", data->sender);
+	if (data->path)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",path=3D'%s'", data->path);
+	if (data->interface)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",interface=3D'%s'", data->interface);
+	if (data->member)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",member=3D'%s'", data->member);
+	if (data->argument)
+		snprintf(rule + offset, size - offset,
+				",arg0=3D'%s'", data->argument);
+}
+
+static void add_match(struct _dbus_filter_data *data,
+						l_dbus_message_func_t filter)
+{
+	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
+
+	_dbus1_format_rule(data, rule, sizeof(rule));
+
+	_dbus_bus_add_match(data->dbus, rule);
+
+	data->handle_func =3D filter;
+}
+
+static void remove_match(struct _dbus_filter_data *data,
+						l_dbus_message_func_t filter)
+{
+	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
+
+	_dbus1_format_rule(data, rule, sizeof(rule));
+
+	_dbus_bus_remove_match(data->dbus, rule);
+}
+
+struct _dbus_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
+					l_dbus_message_func_t filter,
+					const char *sender,
+					const char *path,
+					const char *interface,
+					const char *member,
+					const char *argument,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy,
+					l_dbus_match_func_t add_match)
+{
+	struct _dbus_filter_data *data;
+
+	data =3D l_new(struct _dbus_filter_data, 1);
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
+	add_match(data, filter);
+
+	return data;
+}
+
+void _dbus1_filter_data_destroy(void *user_data,
+				l_dbus_match_func_t remove_match)
+{
+	struct _dbus_filter_data *data =3D user_data;
+
+	remove_match(data, NULL);
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
+	_dbus1_filter_data_destroy(user_data, remove_match);
+}
+
+void _dbus_message_filter_dispatcher(struct l_dbus_message *message,
+				     void *user_data)
+{
+	struct _dbus_filter_data *data =3D user_data;
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
+void _dbus1_service_filter(struct l_dbus_message *message, void *user_data)
+{
+	struct _dbus_filter_data *data =3D user_data;
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
+static unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
+					const char *name,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	struct _dbus_filter_data *data;
+
+	if (!name)
+		return 0;
+
+	data =3D _dbus1_filter_data_get(dbus, _dbus1_service_filter,
+				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
+				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
+				name,
+				disconnect_func,
+				user_data,
+				destroy,
+				add_match);
+	if (!data)
+		return 0;
+
+	return l_dbus_register(dbus, _dbus_message_filter_dispatcher, data,
+							filter_data_destroy);
+}
+
+LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
+					const char *name,
+					l_dbus_watch_func_t disconnect_func,
+					void *user_data,
+					l_dbus_destroy_func_t destroy)
+{
+	return l_dbus_add_service_watch(dbus, name, disconnect_func,
+							user_data, destroy);
+}
+
+LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
+{
+	return l_dbus_unregister(dbus, id);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index a6ad109..39f926b 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -48,6 +48,8 @@ typedef void (*l_dbus_debug_func_t) (const char *str, voi=
d *user_data);
 typedef void (*l_dbus_destroy_func_t) (void *user_data);
 typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface *);
 =

+typedef void (*l_dbus_watch_func_t) (struct l_dbus *dbus, void *user_data);
+
 struct l_dbus *l_dbus_new(const char *address);
 struct l_dbus *l_dbus_new_default(enum l_dbus_bus bus);
 void l_dbus_destroy(struct l_dbus *dbus);
@@ -196,6 +198,13 @@ bool l_dbus_register_interface(struct l_dbus *dbus,
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


--===============3343724736902021705==--

