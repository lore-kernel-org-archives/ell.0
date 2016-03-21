Content-Type: multipart/mixed; boundary="===============7824744971851853216=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/15] dbus: Classic dbus filter_ops implementation.
Date: Mon, 21 Mar 2016 23:10:18 +0100
Message-ID: <1458598224-29325-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7824744971851853216==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For the name owner tracking I decided to subscribe to all name
owner changes instead of adding separate rules for every name because
in some scenarios that saves us cycles/memory and we don't have
to hold a list of IDs of every such rule so that we could remove them
when no longer needed.
---
 ell/dbus.c | 135 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 135 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index 2ac9e58..52a9192 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -63,6 +63,7 @@ struct l_dbus_ops {
 				struct l_dbus_message *message);
 	struct l_dbus_message *(*recv_message)(struct l_dbus *bus);
 	void (*free)(struct l_dbus *bus);
+	struct _dbus_filter_ops filter_ops;
 };
 =

 struct l_dbus {
@@ -87,6 +88,7 @@ struct l_dbus {
 	l_dbus_destroy_func_t debug_destroy;
 	void *debug_data;
 	struct _dbus_object_tree *tree;
+	struct _dbus_filter *filter;
 =

 	const struct l_dbus_ops *driver;
 };
@@ -103,6 +105,7 @@ struct l_dbus_classic {
 	struct l_dbus super;
 	void *auth_command;
 	enum auth_state auth_state;
+	struct l_hashmap *match_strings;
 };
 =

 struct message_callback {
@@ -553,6 +556,7 @@ static void classic_free(struct l_dbus *dbus)
 		container_of(dbus, struct l_dbus_classic, super);
 =

 	l_free(classic->auth_command);
+	l_hashmap_destroy(classic->match_strings, l_free);
 	l_free(classic);
 }
 =

@@ -664,13 +668,132 @@ cmsg_fail:
 	return NULL;
 }
 =

+static bool classic_add_match(struct l_dbus *dbus, unsigned int id,
+				const struct _dbus_filter_condition *rule,
+				int rule_len)
+{
+	struct l_dbus_classic *classic =3D
+		container_of(dbus, struct l_dbus_classic, super);
+	char *match_str;
+	struct l_dbus_message *message;
+
+	match_str =3D _dbus_filter_rule_to_str(rule, rule_len);
+
+	l_hashmap_insert(classic->match_strings, L_UINT_TO_PTR(id), match_str);
+
+	message =3D l_dbus_message_new_method_call(dbus,
+						DBUS_SERVICE_DBUS,
+						DBUS_PATH_DBUS,
+						L_DBUS_INTERFACE_DBUS,
+						"AddMatch");
+
+	l_dbus_message_set_arguments(message, "s", match_str);
+
+	send_message(dbus, false, message, NULL, NULL, NULL);
+
+	return true;
+}
+
+static bool classic_remove_match(struct l_dbus *dbus, unsigned int id)
+{
+	struct l_dbus_classic *classic =3D
+		container_of(dbus, struct l_dbus_classic, super);
+	char *match_str =3D l_hashmap_remove(classic->match_strings,
+						L_UINT_TO_PTR(id));
+	struct l_dbus_message *message;
+
+	if (!match_str)
+		return false;
+
+	message =3D l_dbus_message_new_method_call(dbus,
+						DBUS_SERVICE_DBUS,
+						DBUS_PATH_DBUS,
+						L_DBUS_INTERFACE_DBUS,
+						"RemoveMatch");
+
+	l_dbus_message_set_arguments(message, "s", match_str);
+
+	send_message(dbus, false, message, NULL, NULL, NULL);
+
+	l_free(match_str);
+
+	return true;
+}
+
+struct get_name_owner_request {
+	struct l_dbus_message *message;
+	struct l_dbus *dbus;
+};
+
+static void get_name_owner_reply_cb(struct l_dbus_message *reply,
+					void *user_data)
+{
+	struct get_name_owner_request *req =3D user_data;
+	const char *name, *owner;
+
+	/* No name owner yet */
+	if (l_dbus_message_is_error(reply))
+		return;
+
+	/* Shouldn't happen */
+	if (!l_dbus_message_get_arguments(reply, "s", &owner))
+		return;
+
+	/* Shouldn't happen */
+	if (!l_dbus_message_get_arguments(req->message, "s", &name))
+		return;
+
+	_dbus_filter_name_owner_notify(req->dbus->filter, name, owner);
+}
+
+static bool classic_get_name_owner(struct l_dbus *bus, const char *name)
+{
+	struct get_name_owner_request *req;
+
+	/* Name resolution is not performed for DBUS_SERVICE_DBUS */
+	if (!strcmp(name, DBUS_SERVICE_DBUS))
+		return false;
+
+	req =3D l_new(struct get_name_owner_request, 1);
+	req->dbus =3D bus;
+	req->message =3D l_dbus_message_new_method_call(bus,
+							DBUS_SERVICE_DBUS,
+							DBUS_PATH_DBUS,
+							L_DBUS_INTERFACE_DBUS,
+							"GetNameOwner");
+
+	l_dbus_message_set_arguments(req->message, "s", name);
+
+	send_message(bus, false, req->message, get_name_owner_reply_cb,
+			req, l_free);
+
+	return true;
+}
+
 static const struct l_dbus_ops classic_ops =3D {
 	.version =3D 1,
 	.send_message =3D classic_send_message,
 	.recv_message =3D classic_recv_message,
 	.free =3D classic_free,
+	.filter_ops =3D {
+		.add_match =3D classic_add_match,
+		.remove_match =3D classic_remove_match,
+		.get_name_owner =3D classic_get_name_owner,
+	},
 };
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
+	_dbus_filter_name_owner_notify(dbus->filter, name, new);
+}
+
 static struct l_dbus *setup_dbus1(int fd, const char *guid)
 {
 	static const unsigned char creds =3D 0x00;
@@ -680,6 +803,13 @@ static struct l_dbus *setup_dbus1(int fd, const char *=
guid)
 	ssize_t written;
 	unsigned int i;
 	long flags;
+	static struct _dbus_filter_condition rule[] =3D {
+		{ L_DBUS_MATCH_TYPE,		"signal" },
+		{ L_DBUS_MATCH_SENDER,		DBUS_SERVICE_DBUS },
+		{ L_DBUS_MATCH_PATH,		DBUS_PATH_DBUS },
+		{ L_DBUS_MATCH_INTERFACE,	L_DBUS_INTERFACE_DBUS },
+		{ L_DBUS_MATCH_MEMBER,		"NameOwnerChanged" },
+	};
 =

 	if (snprintf(uid, sizeof(uid), "%d", geteuid()) < 1) {
 		close(fd);
@@ -714,6 +844,8 @@ static struct l_dbus *setup_dbus1(int fd, const char *g=
uid)
 	dbus =3D &classic->super;
 	dbus->driver =3D &classic_ops;
 =

+	classic->match_strings =3D l_hashmap_new();
+
 	dbus_init(dbus, fd);
 	dbus->guid =3D l_strdup(guid);
 =

@@ -726,6 +858,9 @@ static struct l_dbus *setup_dbus1(int fd, const char *g=
uid)
 	l_io_set_read_handler(dbus->io, auth_read_handler, dbus, NULL);
 	l_io_set_write_handler(dbus->io, auth_write_handler, dbus, NULL);
 =

+	_dbus_filter_add_rule(dbus->filter, rule, L_ARRAY_SIZE(rule),
+				name_owner_changed_cb, dbus);
+
 	return dbus;
 }
 =

-- =

2.5.0


--===============7824744971851853216==--

