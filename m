Content-Type: multipart/mixed; boundary="===============1437843657267021244=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/20] dbus-kernel: Update with kdbus API changes.
Date: Mon, 14 Mar 2016 04:41:27 +0100
Message-ID: <1457926896-9843-11-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1437843657267021244==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 105 ++++++++++++++++++++++++++++++++++----------------=
----
 ell/dbus.c        |   4 +++
 2 files changed, 70 insertions(+), 39 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 25510ad..54d7d4d 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -33,6 +33,7 @@
 #include <alloca.h>
 #include <errno.h>
 #include <sys/mman.h>
+#include <sys/ioctl.h>
 =

 #include "linux/kdbus.h"
 =

@@ -180,7 +181,7 @@ void _dbus_kernel_bloom_add_parents(uint64_t filter[], =
size_t size,
 int _dbus_kernel_create_bus(const char *name)
 {
 	struct {
-		struct kdbus_cmd_make head;
+		struct kdbus_cmd head;
 		/* bloom size item */
 		uint64_t bloom_size;
 		uint64_t bloom_type;
@@ -244,13 +245,14 @@ int _dbus_kernel_hello(int fd, const char *connection=
_name,
 	memset(hello, 0, size);
 =

 	hello->size =3D size;
-	hello->conn_flags |=3D KDBUS_HELLO_ACCEPT_FD;
-	hello->attach_flags |=3D KDBUS_ATTACH_NAMES;
+	hello->flags |=3D KDBUS_HELLO_ACCEPT_FD;
+	hello->attach_flags_send |=3D KDBUS_ATTACH_NAMES;
+	hello->attach_flags_recv |=3D KDBUS_ATTACH_NAMES;
 	hello->pool_size =3D KDBUS_POOL_SIZE;
 =

 	item =3D hello->items;
 	item->size =3D KDBUS_ITEM_HEADER_SIZE + len + 1;
-	item->type =3D KDBUS_ITEM_CONN_NAME;
+	item->type =3D KDBUS_ITEM_CONN_DESCRIPTION;
 	strcpy(item->str, connection_name);
 =

 	ret =3D ioctl(fd, KDBUS_CMD_HELLO, hello);
@@ -259,7 +261,7 @@ int _dbus_kernel_hello(int fd, const char *connection_n=
ame,
 =

         /* Check for incompatible flags (upper 32 bits) */
         if (hello->bus_flags > 0xFFFFFFFFULL ||
-			hello->conn_flags > 0xFFFFFFFFULL)
+			hello->flags > 0xFFFFFFFFULL)
                 return -ENOTSUP;
 =

 	*pool =3D mmap(NULL, KDBUS_POOL_SIZE, PROT_READ, MAP_SHARED, fd, 0);
@@ -268,8 +270,9 @@ int _dbus_kernel_hello(int fd, const char *connection_n=
ame,
 		return -errno;
 	}
 =

-	*bloom_size =3D hello->bloom.size;
-	*bloom_n_hash =3D hello->bloom.n_hash;
+	*bloom_size =3D DEFAULT_BLOOM_SIZE;
+	*bloom_n_hash =3D DEFAULT_BLOOM_N_HASH;
+
 	*id =3D hello->id;
 	*guid =3D l_strdup_printf("%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
 				"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
@@ -300,6 +303,7 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	void *body;
 	size_t body_size;
 	int ret;
+	struct kdbus_cmd_send cmd;
 	L_AUTO_FREE_VAR(struct kdbus_msg *, kmsg);
 =

 	dest =3D l_dbus_message_get_destination(message);
@@ -337,10 +341,10 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint=
8_t bloom_n_hash,
 	kmsg->cookie =3D _dbus_message_get_serial(message);
 =

 	if (l_dbus_message_get_no_autostart(message))
-		kmsg->flags |=3D KDBUS_MSG_FLAGS_NO_AUTO_START;
+		kmsg->flags |=3D KDBUS_MSG_NO_AUTO_START;
 =

 	if (!l_dbus_message_get_no_reply(message))
-		kmsg->flags |=3D KDBUS_MSG_FLAGS_EXPECT_REPLY;
+		kmsg->flags |=3D KDBUS_MSG_EXPECT_REPLY;
 =

 	if (!unique && dest) {
 		kmsg->dst_id =3D KDBUS_DST_ID_NAME;
@@ -366,9 +370,12 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8=
_t bloom_n_hash,
 		break;
 	}
 	case DBUS_MESSAGE_TYPE_METHOD_CALL:
-		kmsg->timeout_ns =3D 30000 * 1000ULL;
+		if (!l_dbus_message_get_no_reply(message))
+			kmsg->timeout_ns =3D 30000 * 1000ULL;
 		break;
 	case DBUS_MESSAGE_TYPE_SIGNAL:
+		kmsg->flags |=3D KDBUS_MSG_SIGNAL;
+
 		item->size =3D KDBUS_ITEM_HEADER_SIZE +
 				sizeof(struct kdbus_bloom_filter) + bloom_size;
 		item->type =3D KDBUS_ITEM_BLOOM_FILTER;
@@ -400,7 +407,11 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8=
_t bloom_n_hash,
 =

 	kmsg->size =3D (void *)item - (void *)kmsg;
 =

-	ret =3D ioctl(fd, KDBUS_CMD_MSG_SEND, kmsg);
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.size =3D sizeof(cmd);
+	cmd.msg_address =3D (uint64_t) kmsg;
+
+	ret =3D ioctl(fd, KDBUS_CMD_SEND, &cmd);
 	if (ret < 0)
 		return -errno;
 =

@@ -556,11 +567,13 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 =

 	memset(&recv_cmd, 0, sizeof(recv_cmd));
 =

-	r =3D ioctl(fd, KDBUS_CMD_MSG_RECV, &recv_cmd);
+	recv_cmd.size =3D sizeof(recv_cmd);
+
+	r =3D ioctl(fd, KDBUS_CMD_RECV, &recv_cmd);
 	if (r < 0)
 		return -errno;
 =

-	msg =3D (struct kdbus_msg *)(kdbus_pool + recv_cmd.offset);
+	msg =3D (struct kdbus_msg *)(kdbus_pool + recv_cmd.msg.offset);
 =

 	switch (msg->payload_type) {
 	case KDBUS_PAYLOAD_DBUS:
@@ -588,8 +601,8 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 			}
 =

 			name_owner_change_func(item->name_change.name,
-						item->name_change.old.id,
-						item->name_change.new.id,
+						item->name_change.old_id.id,
+						item->name_change.new_id.id,
 						user_data);
 			break;
 =

@@ -603,7 +616,7 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 		break;
 	}
 =

-	ioctl(fd, KDBUS_CMD_FREE, &recv_cmd.offset);
+	ioctl(fd, KDBUS_CMD_FREE, &recv_cmd.msg.offset);
 =

 	return r;
 }
@@ -611,22 +624,27 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 int _dbus_kernel_name_acquire(int fd, const char *name)
 {
 	struct {
-		struct kdbus_cmd_name head;
+		struct kdbus_cmd head;
 		char param[64];
 	} cmd_name;
+	struct kdbus_item *item;
 	size_t nlen;
 =

 	if (!name)
 		return false;
 =

 	nlen =3D strlen(name) + 1;
-	if (nlen > sizeof(cmd_name.param))
+	if (KDBUS_ITEM_SIZE(nlen) > sizeof(cmd_name.param))
 		return false;
 =

 	memset(&cmd_name, 0, sizeof(cmd_name));
 =

-	strcpy(cmd_name.param, name);
-	cmd_name.head.size =3D sizeof(cmd_name.head) + nlen;
+	cmd_name.head.size =3D sizeof(cmd_name.head) + KDBUS_ITEM_SIZE(nlen);
+
+	item =3D cmd_name.head.items;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + nlen;
+	item->type =3D KDBUS_ITEM_NAME;
+	strcpy(item->str, name);
 =

 	if (ioctl(fd, KDBUS_CMD_NAME_ACQUIRE, &cmd_name) < 0)
 		return -errno;
@@ -719,8 +737,6 @@ int _dbus_kernel_add_match(int fd, uint64_t bloom_size,=
 uint64_t bloom_n_hash,
 					bloom_n_hash, prefix, rule->value);
 	}
 =

-	item =3D KDBUS_ITEM_NEXT(item);
-
 	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, cmd);
 	if (r < 0)
 		return -errno;
@@ -758,8 +774,8 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 	item =3D cmd_match.cmd.items;
 	item->type =3D KDBUS_ITEM_NAME_ADD;
 	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
 	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
 =

 	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
@@ -770,8 +786,8 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 	item =3D cmd_match.cmd.items;
 	item->type =3D KDBUS_ITEM_NAME_CHANGE;
 	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
 	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
 =

 	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
@@ -782,8 +798,8 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 	item =3D cmd_match.cmd.items;
 	item->type =3D KDBUS_ITEM_NAME_REMOVE;
 	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
+	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
 	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
 =

 	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
@@ -796,26 +812,37 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 uint64_t _dbus_kernel_get_name_owner(int fd, void *kdbus_pool,
 					const char *name)
 {
-	struct kdbus_cmd_name_list cmd;
-	struct kdbus_name_list *list;
-	const struct kdbus_cmd_name *entry, *end;
+	struct kdbus_cmd_list cmd;
+	struct kdbus_info *entry, *end;
+	struct kdbus_item *item;
+	const char *entry_name;
 	uint64_t owner_id =3D 0;
 =

 	memset(&cmd, 0, sizeof(cmd));
-	cmd.flags =3D KDBUS_NAME_LIST_NAMES;
+	cmd.size =3D sizeof(cmd);
+	cmd.flags =3D KDBUS_LIST_NAMES;
 =

-	if (ioctl(fd, KDBUS_CMD_NAME_LIST, &cmd) < 0)
+	if (ioctl(fd, KDBUS_CMD_LIST, &cmd) < 0)
 		return 0;
 =

-	list =3D (struct kdbus_name_list *) (kdbus_pool + cmd.offset);
-	end =3D (void *) list + list->size;
+	entry =3D kdbus_pool + cmd.offset;
+	end =3D (void *) entry + cmd.list_size;
 =

-	for (entry =3D list->names; entry < end;
-			entry =3D (void *) entry + entry->size)
-		if (!strcmp(entry->name, name)) {
-			owner_id =3D entry->owner_id;
+	for (; entry < end; entry =3D (void *) entry + entry->size) {
+		entry_name =3D NULL;
+
+		KDBUS_ITEM_FOREACH(item, entry, items) {
+			if (item->type =3D=3D KDBUS_ITEM_OWNED_NAME) {
+				entry_name =3D item->name.name;
+				break;
+			}
+		}
+
+		if (entry_name && !strcmp(entry_name, name)) {
+			owner_id =3D entry->id;
 			break;
 		}
+	}
 =

 	ioctl(fd, KDBUS_CMD_FREE, cmd.offset);
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index 487208b..dbfa1be 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -997,6 +997,10 @@ static void kdbus_name_owner_change_func(const char *n=
ame, uint64_t old_owner,
 	struct kdbus_message_recv_data *recv_data =3D user_data;
 	char owner[32];
 =

+	l_util_debug(recv_data->dbus->debug_handler,
+			recv_data->dbus->debug_data,
+			"Read KDBUS Name Owner Change notification");
+
 	snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
 =

 	_dbus_filter_name_owner_notify(recv_data->dbus->filter, name, owner);
-- =

2.5.0


--===============1437843657267021244==--

