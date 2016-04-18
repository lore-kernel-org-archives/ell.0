Content-Type: multipart/mixed; boundary="===============1890273522839738753=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] dbus: Use the name cache for public service watches
Date: Mon, 18 Apr 2016 16:31:17 +0200
Message-ID: <1460989877-20113-10-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1890273522839738753==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This also removes the now unused dbus.c functions to fix compilation but
doesn't remove the rest of the logic which is now only used by the unit
test I think and can be removed separately.
---
 ell/dbus.c | 120 +++------------------------------------------------------=
----
 1 file changed, 5 insertions(+), 115 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index bc6aaed..af0000d 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1822,57 +1822,6 @@ void _dbus1_filter_data_destroy(void *user_data)
 	l_free(data);
 }
 =

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
 void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata)
 {
 	struct dbus1_filter_data *data =3D user_data;
@@ -1939,33 +1888,6 @@ void _dbus1_name_owner_changed_filter(struct l_dbus_=
message *message,
 	}
 }
 =

-static void _dbus1_get_name_owner_reply(struct l_dbus_message *message,
-							void *user_data)
-{
-	struct dbus1_filter_data *data =3D user_data;
-	const char *name;
-
-	data->get_name_owner_id =3D 0;
-
-	/* No name owner yet */
-	if (l_dbus_message_is_error(message))
-		return;
-
-	/* Shouldn't happen */
-	if (!l_dbus_message_get_arguments(message, "s", &name))
-		return;
-
-	/* If the signal arrived before the reply, don't do anything */
-	if (data->owner && !strcmp(data->owner, name))
-		return;
-
-	l_free(data->owner);
-	data->owner =3D l_strdup(name);
-
-	if (data->connect_func)
-		data->connect_func(data->dbus, data->user_data);
-}
-
 LIB_EXPORT unsigned int l_dbus_add_disconnect_watch(struct l_dbus *dbus,
 					const char *name,
 					l_dbus_watch_func_t disconnect_func,
@@ -1976,56 +1898,24 @@ LIB_EXPORT unsigned int l_dbus_add_disconnect_watch=
(struct l_dbus *dbus,
 					user_data, destroy);
 }
 =

-unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
+LIB_EXPORT unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
 					const char *name,
 					l_dbus_watch_func_t connect_func,
 					l_dbus_watch_func_t disconnect_func,
 					void *user_data,
 					l_dbus_destroy_func_t destroy)
 {
-	struct dbus1_filter_data *data;
-
 	if (!name)
 		return 0;
 =

-	data =3D _dbus1_filter_data_get(dbus, _dbus1_name_owner_changed_filter,
-				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
-				L_DBUS_INTERFACE_DBUS, "NameOwnerChanged",
-				name,
-				disconnect_func,
-				user_data,
-				destroy);
-	if (!data)
-		return 0;
-
-	add_match(data);
-
-	if (connect_func) {
-		struct l_dbus_message *message;
-
-		data->connect_func =3D connect_func;
-
-		message =3D l_dbus_message_new_method_call(dbus,
-							DBUS_SERVICE_DBUS,
-							DBUS_PATH_DBUS,
-							L_DBUS_INTERFACE_DBUS,
-							"GetNameOwner");
-
-		l_dbus_message_set_arguments(message, "s", name);
-
-		data->get_name_owner_id =3D
-			l_dbus_send_with_reply(dbus, message,
-						_dbus1_get_name_owner_reply,
-						data, NULL);
-	}
-
-	return l_dbus_register(dbus, _dbus1_signal_dispatcher, data,
-							filter_data_destroy);
+	return _dbus_name_cache_add_watch(dbus->name_cache, name, connect_func,
+						disconnect_func, user_data,
+						destroy);
 }
 =

 LIB_EXPORT bool l_dbus_remove_watch(struct l_dbus *dbus, unsigned int id)
 {
-	return l_dbus_unregister(dbus, id);
+	return _dbus_name_cache_remove_watch(dbus->name_cache, id);
 }
 =

 /**
-- =

2.5.0


--===============1890273522839738753==--

