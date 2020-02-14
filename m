Content-Type: multipart/mixed; boundary="===============6819422494683299391=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] unit: Update calls to functions from genl-private.h
Date: Sat, 15 Feb 2020 00:37:32 +0100
Message-ID: <20200214233732.20146-4-andrew.zaborowski@intel.com>
In-Reply-To: <20200214233732.20146-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6819422494683299391==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl-msg.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index b1c5275..119d01e 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -29,8 +29,6 @@
 #include <linux/genetlink.h>
 #include <ell/ell.h>
 =

-#include "ell/genl-private.h"
-
 static bool do_print =3D false;
 =

 static void do_debug(const char *str, void *user_data)
@@ -61,7 +59,7 @@ static void parse_set_station(const void *data)
 	const void *payload;
 =

 	nlmsg =3D (struct nlmsghdr *) set_station_request;
-	msg =3D _genl_msg_create(nlmsg);
+	msg =3D l_genl_msg_new_from_data(nlmsg, sizeof(set_station_request));
 	assert(msg);
 =

 	assert(l_genl_msg_get_command(msg) =3D=3D 18);
@@ -113,7 +111,7 @@ static void build_set_station(const void *data)
 	assert(l_genl_msg_append_attr(msg, 6, 6, mac));
 	assert(l_genl_msg_append_attr(msg, 67, 8, flags));
 =

-	raw =3D _genl_msg_as_bytes(msg, 0x17, 0x05, 0x550d538b, 3604, &size);
+	raw =3D l_genl_msg_to_data(msg, 0x17, 0x05, 0x550d538b, 3604, &size);
 =

 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
@@ -157,7 +155,8 @@ static void parse_set_rekey_offload(const void *data)
 	const void *payload;
 =

 	nlmsg =3D (struct nlmsghdr *) set_rekey_offload_request;
-	msg =3D _genl_msg_create(nlmsg);
+	msg =3D l_genl_msg_new_from_data(nlmsg,
+					sizeof(set_rekey_offload_request));
 	assert(msg);
 =

 	assert(l_genl_msg_get_command(msg) =3D=3D 79);
@@ -230,7 +229,7 @@ static void build_set_rekey_offload(const void *data)
 	assert(l_genl_msg_append_attr(msg, 3, 8, replay_counter));
 	assert(l_genl_msg_leave_nested(msg));
 =

-	raw =3D _genl_msg_as_bytes(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba,
+	raw =3D l_genl_msg_to_data(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba,
 					&size);
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
@@ -285,7 +284,7 @@ static void parse_libnl_nested(const void *data)
 	const void *payload;
 =

 	nlmsg =3D (struct nlmsghdr *) libnl_nested;
-	msg =3D _genl_msg_create(nlmsg);
+	msg =3D l_genl_msg_new_from_data(nlmsg, sizeof(libnl_nested));
 	assert(msg);
 =

 	assert(l_genl_msg_get_command(msg) =3D=3D 1);
@@ -353,7 +352,7 @@ static void build_libnl_nested(const void *data)
 	assert(l_genl_msg_leave_nested(msg));
 	assert(l_genl_msg_leave_nested(msg));
 =

-	raw =3D _genl_msg_as_bytes(msg, 0x15, 0x05, 0x55130572, 0x0c406877,
+	raw =3D l_genl_msg_to_data(msg, 0x15, 0x05, 0x55130572, 0x0c406877,
 					&size);
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
-- =

2.20.1

--===============6819422494683299391==--

