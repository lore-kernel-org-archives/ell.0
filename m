Content-Type: multipart/mixed; boundary="===============5683097048663241331=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] kdbus: Notifications and get_name_owner for unique names
Date: Wed, 09 Nov 2016 03:51:34 +0100
Message-ID: <1478659894-7142-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1478659894-7142-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5683097048663241331==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is untested and may be of little value anyway.
---
 ell/dbus-kernel.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 2cd1d94..6544a87 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -596,6 +596,7 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 	int r;
 	size_t min_size;
 	const char *error;
+	char unique_bus_name[128];
 =

 	memset(&recv_cmd, 0, sizeof(recv_cmd));
 =

@@ -638,6 +639,27 @@ int _dbus_kernel_recv(int fd, void *kdbus_pool,
 						user_data);
 			break;
 =

+		case KDBUS_ITEM_ID_ADD:
+		case KDBUS_ITEM_ID_REMOVE:
+			min_size =3D KDBUS_ITEM_SIZE(sizeof(item->id_change));
+			if (msg->size < sizeof(*msg) + min_size ||
+					item->size < min_size) {
+				r =3D -EPROTONOSUPPORT;
+				break;
+			}
+
+			sprintf(unique_bus_name, ":1.%llu", item->id_change.id);
+
+			if (item->type =3D=3D KDBUS_ITEM_ID_ADD)
+				name_owner_change_func(unique_bus_name,
+							0, item->id_change.id,
+							user_data);
+			else
+				name_owner_change_func(unique_bus_name,
+							item->id_change.id, 0,
+							user_data);
+			break;
+
 		case KDBUS_ITEM_REPLY_TIMEOUT:
 		case KDBUS_ITEM_REPLY_DEAD:
 			if (item->type =3D=3D KDBUS_ITEM_REPLY_TIMEOUT)
@@ -828,7 +850,9 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 	struct {
 		struct kdbus_cmd_match cmd;
 		uint8_t param[KDBUS_ITEM_SIZE(
-				sizeof(struct kdbus_notify_name_change))];
+				sizeof(struct kdbus_notify_name_change)) +
+				KDBUS_ITEM_SIZE(
+				sizeof(struct kdbus_notify_id_change))];
 	} cmd_match;
 	struct kdbus_item *item;
 	int r;
@@ -869,6 +893,28 @@ int _dbus_kernel_enable_name_owner_notify(int fd)
 	if (r < 0)
 		return -errno;
 =

+	memset(&cmd_match, 0, sizeof(cmd_match));
+	item =3D cmd_match.cmd.items;
+	item->type =3D KDBUS_ITEM_ID_ADD;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->id_change);
+	item->id_change.id =3D KDBUS_MATCH_ID_ANY;
+	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
+
+	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
+	if (r < 0)
+		return -errno;
+
+	memset(&cmd_match, 0, sizeof(cmd_match));
+	item =3D cmd_match.cmd.items;
+	item->type =3D KDBUS_ITEM_ID_REMOVE;
+	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->id_change);
+	item->id_change.id =3D KDBUS_MATCH_ID_ANY;
+	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
+
+	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
+	if (r < 0)
+		return -errno;
+
 	return 0;
 }
 =

@@ -881,10 +927,14 @@ uint64_t _dbus_kernel_get_name_owner(int fd, void *kd=
bus_pool,
 	struct kdbus_item *item;
 	const char *entry_name;
 	uint64_t owner_id =3D 0;
+	bool is_unique;
+	uint64_t uninitialized_var(id);
+
+	is_unique =3D _dbus_parse_unique_name(name, &id);
 =

 	memset(&cmd, 0, sizeof(cmd));
 	cmd.size =3D sizeof(cmd);
-	cmd.flags =3D KDBUS_LIST_NAMES;
+	cmd.flags =3D is_unique ? KDBUS_LIST_UNIQUE : KDBUS_LIST_NAMES;
 =

 	if (ioctl(fd, KDBUS_CMD_LIST, &cmd) < 0)
 		return 0;
@@ -906,6 +956,11 @@ uint64_t _dbus_kernel_get_name_owner(int fd, void *kdb=
us_pool,
 			owner_id =3D entry->id;
 			break;
 		}
+
+		if (is_unique && id =3D=3D entry->id) {
+			owner_id =3D id;
+			break;
+		}
 	}
 =

 	memset(&cmd_free, 0, sizeof(cmd_free));
-- =

2.7.4


--===============5683097048663241331==--

