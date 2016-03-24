Content-Type: multipart/mixed; boundary="===============6204346243238342725=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] dbus: Remove now unused filter logic
Date: Thu, 24 Mar 2016 03:07:04 +0100
Message-ID: <1458785229-23266-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458785229-23266-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6204346243238342725==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h |  20 -----
 ell/dbus.c         | 209 -------------------------------------------------=
----
 2 files changed, 229 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 3b40fea..b455df2 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -287,23 +287,3 @@ char *_dbus_filter_rule_to_str(const struct _dbus_filt=
er_condition *rule,
 void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data=
);
 void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
 					const char *name, const char *owner);
-
-struct dbus1_filter_data;
-
-void _dbus1_filter_format_match(struct dbus1_filter_data *data, char *rule,
-								size_t size);
-
-struct dbus1_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
-					l_dbus_message_func_t filter,
-					const char *sender,
-					const char *path,
-					const char *interface,
-					const char *member,
-					const char *argument,
-					l_dbus_watch_func_t disconnect_func,
-					void *user_data,
-					l_dbus_destroy_func_t destroy);
-void _dbus1_filter_data_destroy(void *user_data);
-void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata);
-void _dbus1_name_owner_changed_filter(struct l_dbus_message *message,
-							void *user_data);
diff --git a/ell/dbus.c b/ell/dbus.c
index 6bf5734..b52192d 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -139,23 +139,6 @@ struct service_watch_data {
 	bool removed;
 };
 =

-struct dbus1_filter_data {
-	struct l_dbus *dbus;
-	char *sender;
-	char *path;
-	char *interface;
-	char *member;
-	char *argument;
-	void *user_data;
-	l_dbus_message_func_t handle_func;
-	l_dbus_destroy_func_t destroy_func;
-
-	l_dbus_watch_func_t connect_func;
-	l_dbus_watch_func_t disconnect_func;
-	char *owner;
-	uint32_t get_name_owner_id;
-};
-
 static void message_queue_destroy(void *data)
 {
 	struct message_callback *callback =3D data;
@@ -1683,198 +1666,6 @@ LIB_EXPORT bool l_dbus_object_manager_enable(struct=
 l_dbus *dbus)
 						dbus);
 }
 =

-void _dbus1_filter_format_match(struct dbus1_filter_data *data, char *rule,
-					size_t size)
-{
-	int offset;
-
-	offset =3D snprintf(rule, size, "type=3D'signal'");
-
-	if (data->sender)
-		offset +=3D snprintf(rule + offset, size - offset,
-				",sender=3D'%s'", data->sender);
-	if (data->path)
-		offset +=3D snprintf(rule + offset, size - offset,
-				",path=3D'%s'", data->path);
-	if (data->interface)
-		offset +=3D snprintf(rule + offset, size - offset,
-				",interface=3D'%s'", data->interface);
-	if (data->member)
-		offset +=3D snprintf(rule + offset, size - offset,
-				",member=3D'%s'", data->member);
-	if (data->argument)
-		snprintf(rule + offset, size - offset,
-				",arg0=3D'%s'", data->argument);
-}
-
-struct dbus1_filter_data *_dbus1_filter_data_get(struct l_dbus *dbus,
-					l_dbus_message_func_t filter,
-					const char *sender,
-					const char *path,
-					const char *interface,
-					const char *member,
-					const char *argument,
-					l_dbus_watch_func_t disconnect_func,
-					void *user_data,
-					l_dbus_destroy_func_t destroy)
-{
-	struct dbus1_filter_data *data;
-
-	data =3D l_new(struct dbus1_filter_data, 1);
-
-	data->dbus =3D dbus;
-	data->handle_func =3D filter;
-	data->sender =3D l_strdup(sender);
-	data->path =3D l_strdup(path);
-	data->interface =3D l_strdup(interface);
-	data->member =3D l_strdup(member);
-	data->argument =3D l_strdup(argument);
-	data->user_data =3D user_data;
-	data->destroy_func =3D destroy;
-
-	data->disconnect_func =3D disconnect_func;
-
-	return data;
-}
-
-void _dbus1_filter_data_destroy(void *user_data)
-{
-	struct dbus1_filter_data *data =3D user_data;
-
-	l_free(data->sender);
-	l_free(data->path);
-	l_free(data->interface);
-	l_free(data->member);
-	l_free(data->argument);
-
-	l_free(data->owner);
-
-	if (data->get_name_owner_id)
-		l_dbus_cancel(data->dbus, data->get_name_owner_id);
-
-	if (data->destroy_func)
-		data->destroy_func(data->user_data);
-
-	l_free(data);
-}
-
-static void dbus1_send_match(struct l_dbus *dbus, const char *rule,
-						const char *method)
-{
-	struct l_dbus_message *message;
-
-	message =3D l_dbus_message_new_method_call(dbus,
-						DBUS_SERVICE_DBUS,
-						DBUS_PATH_DBUS,
-						L_DBUS_INTERFACE_DBUS,
-						method);
-
-	l_dbus_message_set_arguments(message, "s", rule);
-
-	send_message(dbus, false, message, NULL, NULL, NULL);
-}
-
-static void dbus1_bus_add_match(struct l_dbus *dbus, const char *rule)
-{
-	dbus1_send_match(dbus, rule, "AddMatch");
-}
-
-static void dbus1_bus_remove_match(struct l_dbus *dbus, const char *rule)
-{
-	dbus1_send_match(dbus, rule, "RemoveMatch");
-}
-
-static void add_match(struct dbus1_filter_data *data)
-{
-	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
-
-	_dbus1_filter_format_match(data, rule, sizeof(rule));
-
-	dbus1_bus_add_match(data->dbus, rule);
-}
-
-static void remove_match(struct dbus1_filter_data *data)
-{
-	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
-
-	_dbus1_filter_format_match(data, rule, sizeof(rule));
-
-	dbus1_bus_remove_match(data->dbus, rule);
-}
-
-static void filter_data_destroy(void *user_data)
-{
-	remove_match(user_data);
-
-	_dbus1_filter_data_destroy(user_data);
-}
-
-void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata)
-{
-	struct dbus1_filter_data *data =3D user_data;
-	const char *sender, *path, *iface, *member;
-
-	if (_dbus_message_get_type(message) !=3D DBUS_MESSAGE_TYPE_SIGNAL)
-		return;
-
-	sender =3D l_dbus_message_get_sender(message);
-	if (!sender)
-		return;
-
-	if (data->sender && strcmp(sender, data->sender))
-		return;
-
-	path =3D l_dbus_message_get_path(message);
-	if (data->path && strcmp(path, data->path))
-		return;
-
-	iface =3D l_dbus_message_get_interface(message);
-	if (data->interface && strcmp(iface, data->interface))
-		return;
-
-	member =3D l_dbus_message_get_member(message);
-	if (data->member && strcmp(member, data->member))
-		return;
-
-	if (data->handle_func)
-		data->handle_func(message, data);
-}
-
-void _dbus1_name_owner_changed_filter(struct l_dbus_message *message,
-							void *user_data)
-{
-	struct dbus1_filter_data *data =3D user_data;
-	char *name, *old, *new;
-
-	if (!l_dbus_message_get_arguments(message, "sss",
-						&name, &old, &new))
-		return;
-
-	if (strcmp(name, data->argument))
-		return;
-
-	if (!data->owner) {
-		if (data->get_name_owner_id)
-			l_dbus_cancel(data->dbus, data->get_name_owner_id);
-
-		data->get_name_owner_id =3D 0;
-	} else {
-		if (!strcmp(data->owner, new))
-			return;
-	}
-
-	l_free(data->owner);
-	data->owner =3D l_strdup(new);
-
-	if (*new =3D=3D '\0') {
-		if (data->disconnect_func)
-			data->disconnect_func(data->dbus, data->user_data);
-	} else {
-		if (data->connect_func)
-			data->connect_func(data->dbus, data->user_data);
-	}
-}
-
 LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
 					const char *name,
 					l_dbus_watch_func_t disconnect_func,
-- =

2.5.0


--===============6204346243238342725==--

