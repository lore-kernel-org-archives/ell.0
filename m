Content-Type: multipart/mixed; boundary="===============6683323753721226277=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/20] dbus: kdbus filter_ops implementation.
Date: Mon, 14 Mar 2016 04:41:25 +0100
Message-ID: <1457926896-9843-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6683323753721226277==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For the name owner tracking I decided to subscribe to all name
owner changes instead of adding separate rules for every name because
in some scenarios that saves us cycles/memory and we don't have
to hold a list of IDs of every such rule so that we could remove them
when no longer needed.
---
 ell/dbus-kernel.c  | 205 ++++++++++++++++++++++++++++++++++++++++++++++++-=
----
 ell/dbus-private.h |  17 ++++-
 ell/dbus.c         | 152 +++++++++++++++++++++++++++++----------
 3 files changed, 317 insertions(+), 57 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 6ce3e6f..25510ad 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -543,11 +543,16 @@ static int _dbus_kernel_make_message(struct kdbus_msg=
 *kmsg,
 }
 =

 int _dbus_kernel_recv(int fd, void *kdbus_pool,
-				struct l_dbus_message **out_message)
+			l_dbus_message_func_t message_func,
+			_dbus_name_owner_change_func_t name_owner_change_func,
+			void *user_data)
 {
 	struct kdbus_cmd_recv recv_cmd;
 	struct kdbus_msg *msg;
+	struct l_dbus_message *dbus_msg;
+	struct kdbus_item *item;
 	int r;
+	size_t min_size;
 =

 	memset(&recv_cmd, 0, sizeof(recv_cmd));
 =

@@ -559,9 +564,39 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 =

 	switch (msg->payload_type) {
 	case KDBUS_PAYLOAD_DBUS:
-		r =3D _dbus_kernel_make_message(msg, out_message);
+		r =3D _dbus_kernel_make_message(msg, &dbus_msg);
+		if (!r)
+			message_func(dbus_msg, user_data);
 		break;
 	case KDBUS_PAYLOAD_KERNEL:
+		if (msg->size < sizeof(*msg) + KDBUS_ITEM_HEADER_SIZE) {
+			r =3D -EPROTONOSUPPORT;
+			break;
+		}
+
+		item =3D msg->items;
+
+		switch (item->type) {
+		case KDBUS_ITEM_NAME_ADD:
+		case KDBUS_ITEM_NAME_CHANGE:
+		case KDBUS_ITEM_NAME_REMOVE:
+			min_size =3D KDBUS_ITEM_SIZE(sizeof(item->name_change));
+			if (msg->size < sizeof(*msg) + min_size ||
+					item->size < min_size) {
+				r =3D -EPROTONOSUPPORT;
+				break;
+			}
+
+			name_owner_change_func(item->name_change.name,
+						item->name_change.old.id,
+						item->name_change.new.id,
+						user_data);
+			break;
+
+		default:
+			break;
+		}
+
 		break;
 	default:
 		r =3D -EPROTONOSUPPORT;
@@ -600,47 +635,107 @@ int _dbus_kernel_name_acquire(int fd, const char *na=
me)
 }
 =

 int _dbus_kernel_add_match(int fd, uint64_t bloom_size, uint64_t bloom_n_h=
ash,
-				uint64_t *out_cookie)
+				const struct _dbus_filter_condition *rule,
+				int rule_len, unsigned int id)
 {
-	static uint64_t cookie =3D 1;
-	struct kdbus_item *item;
+	struct kdbus_item *bloom, *item;
 	struct kdbus_cmd_match *cmd;
 	size_t cmd_size;
-	int r;
+	const char *prefix;
+	char argstr[8];
+	int r, i;
+	uint64_t sender_id;
 =

 	cmd_size =3D sizeof(struct kdbus_cmd_match);
 	cmd_size +=3D KDBUS_ITEM_SIZE(bloom_size);
 =

+	for (i =3D 0; i < rule_len; i++) {
+		switch (rule[i].type) {
+		case L_DBUS_MATCH_SENDER:
+			if (_dbus_parse_unique_name(rule->value, NULL))
+				cmd_size +=3D KDBUS_ITEM_SIZE(sizeof(item->id));
+			else
+				cmd_size +=3D KDBUS_ITEM_SIZE(
+						strlen(rule[i].value) + 1);
+			break;
+		default:
+			break;
+		}
+	}
+
 	cmd =3D alloca(cmd_size);
 	memset(cmd, 0, cmd_size);
 	cmd->size =3D cmd_size;
-	cmd->cookie =3D cookie++;
+	cmd->cookie =3D id;
 	item =3D cmd->items;
 =

-	item->size =3D KDBUS_ITEM_HEADER_SIZE + bloom_size;
-	item->type =3D KDBUS_ITEM_BLOOM_MASK;
-	_dbus_kernel_bloom_add((uint64_t *) item->data64, bloom_size,
-				bloom_n_hash, "message-type", "signal");
+	bloom =3D item;
+	bloom->size =3D KDBUS_ITEM_HEADER_SIZE + bloom_size;
+	bloom->type =3D KDBUS_ITEM_BLOOM_MASK;
+
+	for (; rule_len; rule++, rule_len--) {
+		switch ((int) rule->type) {
+		case L_DBUS_MATCH_SENDER:
+			item =3D KDBUS_ITEM_NEXT(item);
+
+			if (_dbus_parse_unique_name(rule->value, &sender_id)) {
+				item->size =3D KDBUS_ITEM_HEADER_SIZE +
+					strlen(rule->value) + 1;
+				item->type =3D KDBUS_ITEM_ID;
+				item->id =3D id;
+			} else {
+				item->size =3D KDBUS_ITEM_HEADER_SIZE +
+					strlen(rule->value) + 1;
+				item->type =3D KDBUS_ITEM_NAME;
+				strcpy(item->str, rule->value);
+			}
+
+			continue;
+		case L_DBUS_MATCH_DESTINATION:
+			prefix =3D "destination";
+			break;
+		case L_DBUS_MATCH_TYPE:
+			prefix =3D "message-type";
+			break;
+		case L_DBUS_MATCH_PATH:
+			prefix =3D "path";
+			break;
+		case L_DBUS_MATCH_INTERFACE:
+			prefix =3D "interface";
+			break;
+		case L_DBUS_MATCH_MEMBER:
+			prefix =3D "member";
+			break;
+		case L_DBUS_MATCH_ARG0...(L_DBUS_MATCH_ARG0 + 63):
+			prefix =3D argstr;
+			snprintf(argstr, sizeof(argstr), "arg%i",
+					rule->type - L_DBUS_MATCH_ARG0);
+			break;
+		default:
+			return -ENOTSUP;
+		}
+
+		_dbus_kernel_bloom_add((uint64_t *) bloom->data64, bloom_size,
+					bloom_n_hash, prefix, rule->value);
+	}
+
 	item =3D KDBUS_ITEM_NEXT(item);
 =

 	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, cmd);
 	if (r < 0)
 		return -errno;
 =

-	if (out_cookie)
-		*out_cookie =3D cmd->cookie;
-
 	return 0;
 }
 =

-int _dbus_kernel_remove_match(int fd, uint64_t cookie)
+int _dbus_kernel_remove_match(int fd, unsigned int id)
 {
 	struct kdbus_cmd_match cmd;
 	int r;
 =

 	memset(&cmd, 0, sizeof(cmd));
 	cmd.size =3D sizeof(cmd);
-	cmd.cookie =3D cookie;
+	cmd.cookie =3D id;
 =

 	r =3D ioctl(fd, KDBUS_CMD_MATCH_REMOVE, &cmd);
 	if (r < 0)
@@ -648,3 +743,81 @@ int _dbus_kernel_remove_match(int fd, uint64_t cookie)
 =

 	return 0;
 }
+
+int _dbus_kernel_enable_name_owner_notify(int fd)
+{
+	struct {
+		struct kdbus_cmd_match cmd;
+		uint8_t param[KDBUS_ITEM_SIZE(
+				sizeof(struct kdbus_notify_name_change))];
+	} cmd_match;
+	struct kdbus_item *item;
+	int r;
+
+	memset(&cmd_match, 0, sizeof(cmd_match));
+	item =3D cmd_match.cmd.items;
+	item->type =3D KDBUS_ITEM_NAME_ADD;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
+	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
+
+	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
+	if (r < 0)
+		return -errno;
+
+	memset(&cmd_match, 0, sizeof(cmd_match));
+	item =3D cmd_match.cmd.items;
+	item->type =3D KDBUS_ITEM_NAME_CHANGE;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
+	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
+
+	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
+	if (r < 0)
+		return -errno;
+
+	memset(&cmd_match, 0, sizeof(cmd_match));
+	item =3D cmd_match.cmd.items;
+	item->type =3D KDBUS_ITEM_NAME_REMOVE;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
+	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
+
+	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
+	if (r < 0)
+		return -errno;
+
+	return 0;
+}
+
+uint64_t _dbus_kernel_get_name_owner(int fd, void *kdbus_pool,
+					const char *name)
+{
+	struct kdbus_cmd_name_list cmd;
+	struct kdbus_name_list *list;
+	const struct kdbus_cmd_name *entry, *end;
+	uint64_t owner_id =3D 0;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.flags =3D KDBUS_NAME_LIST_NAMES;
+
+	if (ioctl(fd, KDBUS_CMD_NAME_LIST, &cmd) < 0)
+		return 0;
+
+	list =3D (struct kdbus_name_list *) (kdbus_pool + cmd.offset);
+	end =3D (void *) list + list->size;
+
+	for (entry =3D list->names; entry < end;
+			entry =3D (void *) entry + entry->size)
+		if (!strcmp(entry->name, name)) {
+			owner_id =3D entry->owner_id;
+			break;
+		}
+
+	ioctl(fd, KDBUS_CMD_FREE, cmd.offset);
+
+	return owner_id;
+}
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index de4e706..f210a3c 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -230,15 +230,26 @@ int _dbus_kernel_hello(int fd, const char *connection=
_name,
 			uint64_t *id, void **pool, char **guid);
 void _dbus_kernel_unmap_pool(void *pool);
 =

+typedef void (*_dbus_name_owner_change_func_t)(const char *name,
+						uint64_t old_owner,
+						uint64_t new_owner,
+						void *user_data);
+
 int _dbus_kernel_send(int fd, size_t bloom_size, uint8_t n_bloom_hash,
 			struct l_dbus_message *message);
 int _dbus_kernel_recv(int fd, void *kdbus_pool,
-				struct l_dbus_message **out_message);
+			l_dbus_message_func_t message_func,
+			_dbus_name_owner_change_func_t name_owner_change_func,
+			void *user_data);
 =

 int _dbus_kernel_name_acquire(int fd, const char *name);
 int _dbus_kernel_add_match(int fd, uint64_t bloom_size, uint64_t bloom_n_h=
ash,
-				uint64_t *out_cookie);
-int _dbus_kernel_remove_match(int fd, uint64_t cookie);
+				const struct _dbus_filter_condition *rule,
+				int rule_len, unsigned int id);
+int _dbus_kernel_remove_match(int fd, unsigned int it);
+int _dbus_kernel_enable_name_owner_notify(int fd);
+uint64_t _dbus_kernel_get_name_owner(int fd, void *kdbus_pool,
+					const char *name);
 =

 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
diff --git a/ell/dbus.c b/ell/dbus.c
index e9d3424..487208b 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -277,7 +277,7 @@ static bool message_read_handler(struct l_io *io, void =
*user_data)
 =

 	message =3D dbus->driver->recv_message(dbus);
 	if (!message)
-		return false;
+		return true;
 =

 	header =3D _dbus_message_get_header(message, &header_size);
 	body =3D _dbus_message_get_body(message, &body_size);
@@ -347,6 +347,22 @@ static uint32_t send_message(struct l_dbus *dbus, bool=
 priority,
 	return callback->serial;
 }
 =

+static void bus_ready(struct l_dbus *dbus)
+{
+	dbus->is_ready =3D true;
+
+	if (dbus->ready_handler)
+		dbus->ready_handler(dbus->ready_data);
+
+	l_io_set_read_handler(dbus->io, message_read_handler, dbus, NULL);
+
+	/* Check for messages added before the connection was ready */
+	if (l_queue_isempty(dbus->message_queue))
+		return;
+
+	l_io_set_write_handler(dbus->io, message_write_handler, dbus, NULL);
+}
+
 static void hello_callback(struct l_dbus_message *message, void *user_data)
 {
 	struct l_dbus *dbus =3D user_data;
@@ -366,16 +382,7 @@ static void hello_callback(struct l_dbus_message *mess=
age, void *user_data)
 =

 	dbus->unique_name =3D l_strdup(unique_name);
 =

-	dbus->is_ready =3D true;
-
-	if (dbus->ready_handler)
-		dbus->ready_handler(dbus->ready_data);
-
-	/* Check for messages added before the connection was ready */
-	if (l_queue_isempty(dbus->message_queue))
-		return;
-
-	l_io_set_write_handler(dbus->io, message_write_handler, dbus, NULL);
+	bus_ready(dbus);
 }
 =

 static bool auth_write_handler(struct l_io *io, void *user_data)
@@ -934,29 +941,8 @@ static struct l_dbus *setup_unix(char *params)
 static void kdbus_ready(void *user_data)
 {
 	struct l_dbus *dbus =3D user_data;
-	struct l_dbus_kdbus *kdbus =3D
-		container_of(dbus, struct l_dbus_kdbus, super);
-	int fd =3D l_io_get_fd(dbus->io);
-	int r;
-
-	r =3D _dbus_kernel_add_match(fd, kdbus->bloom_size, kdbus->bloom_n_hash,
-					NULL);
-	if (r < 0)
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-
-	dbus->is_ready =3D true;
 =

-	if (dbus->ready_handler)
-		dbus->ready_handler(dbus->ready_data);
-
-	l_io_set_read_handler(dbus->io, message_read_handler, dbus, NULL);
-
-	/* Check for messages added before the connection was ready */
-	if (l_queue_isempty(dbus->message_queue))
-		return;
-
-	l_io_set_write_handler(dbus->io, message_write_handler, dbus, NULL);
+	bus_ready(dbus);
 }
 =

 static void kdbus_free(struct l_dbus *dbus)
@@ -989,25 +975,103 @@ static bool kdbus_send_message(struct l_dbus *dbus,
 	return true;
 }
 =

+struct kdbus_message_recv_data {
+	struct l_dbus_message *message;
+	struct l_dbus *dbus;
+};
+
+static void kdbus_message_func(struct l_dbus_message *message, void *user_=
data)
+{
+	struct kdbus_message_recv_data *recv_data =3D user_data;
+
+	recv_data->message =3D message;
+
+	l_util_debug(recv_data->dbus->debug_handler,
+			recv_data->dbus->debug_data, "Read KDBUS Message");
+}
+
+static void kdbus_name_owner_change_func(const char *name, uint64_t old_ow=
ner,
+						uint64_t new_owner,
+						void *user_data)
+{
+	struct kdbus_message_recv_data *recv_data =3D user_data;
+	char owner[32];
+
+	snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
+
+	_dbus_filter_name_owner_notify(recv_data->dbus->filter, name, owner);
+}
+
 static struct l_dbus_message *kdbus_recv_message(struct l_dbus *dbus)
 {
 	struct l_dbus_kdbus *kdbus =3D
 			container_of(dbus, struct l_dbus_kdbus, super);
 	int fd =3D l_io_get_fd(dbus->io);
-	struct l_dbus_message *message =3D NULL;
+	struct kdbus_message_recv_data recv_data =3D { NULL, dbus };
 	int r;
 =

-	r =3D _dbus_kernel_recv(fd, kdbus->kdbus_pool, &message);
+	r =3D _dbus_kernel_recv(fd, kdbus->kdbus_pool, kdbus_message_func,
+				kdbus_name_owner_change_func, &recv_data);
 	if (r < 0) {
 		l_util_debug(dbus->debug_handler,
 				dbus->debug_data, strerror(-r));
 		return NULL;
 	}
 =

-	l_util_debug(dbus->debug_handler, dbus->debug_data,
-			"Read KDBUS Message");
+	return recv_data.message;
+}
+
+static bool kdbus_add_match(struct l_dbus *dbus, unsigned int id,
+				const struct _dbus_filter_condition *rule,
+				int rule_len)
+{
+	struct l_dbus_kdbus *kdbus =3D
+		container_of(dbus, struct l_dbus_kdbus, super);
+	int fd =3D l_io_get_fd(dbus->io);
+	int r;
+
+	r =3D _dbus_kernel_add_match(fd, kdbus->bloom_size, kdbus->bloom_n_hash,
+					rule, rule_len, id);
+	if (r < 0)
+		l_util_debug(dbus->debug_handler,
+				dbus->debug_data, strerror(-r));
+
+	return !r;
+}
+
+static bool kdbus_remove_match(struct l_dbus *dbus, unsigned int id)
+{
+	int fd =3D l_io_get_fd(dbus->io);
+	int r;
+
+	r =3D _dbus_kernel_remove_match(fd, id);
+	if (r < 0)
+		l_util_debug(dbus->debug_handler,
+				dbus->debug_data, strerror(-r));
+
+	return !r;
+}
+
+static bool kdbus_get_name_owner(struct l_dbus *dbus, const char *name)
+{
+	struct l_dbus_kdbus *kdbus =3D
+		container_of(dbus, struct l_dbus_kdbus, super);
+	int fd =3D l_io_get_fd(dbus->io);
+	uint64_t owner_id;
+	char owner[32];
+
+	owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_pool, name);
+	if (!owner_id) {
+		l_util_debug(dbus->debug_handler,
+				dbus->debug_data, "Error getting name owner");
+		return false;
+	}
+
+	snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
+
+	_dbus_filter_name_owner_notify(dbus->filter, name, owner);
 =

-	return message;
+	return true;
 }
 =

 static const struct l_dbus_ops kdbus_ops =3D {
@@ -1015,12 +1079,19 @@ static const struct l_dbus_ops kdbus_ops =3D {
 	.free =3D kdbus_free,
 	.send_message =3D kdbus_send_message,
 	.recv_message =3D kdbus_recv_message,
+	.filter_ops =3D {
+		.track_name_owner_change =3D true,
+		.add_match =3D kdbus_add_match,
+		.remove_match =3D kdbus_remove_match,
+		.get_name_owner =3D kdbus_get_name_owner,
+	},
 };
 =

 static struct l_dbus *setup_kdbus(int fd)
 {
 	struct l_dbus *dbus;
 	struct l_dbus_kdbus *kdbus;
+	int r;
 =

 	kdbus =3D l_new(struct l_dbus_kdbus, 1);
 	dbus =3D &kdbus->super;
@@ -1041,6 +1112,11 @@ static struct l_dbus *setup_kdbus(int fd)
 =

 	l_idle_oneshot(kdbus_ready, dbus, NULL);
 =

+	r =3D _dbus_kernel_enable_name_owner_notify(fd);
+	if (r < 0)
+		l_util_debug(dbus->debug_handler,
+				dbus->debug_data, strerror(-r));
+
 	return dbus;
 }
 =

-- =

2.5.0


--===============6683323753721226277==--

