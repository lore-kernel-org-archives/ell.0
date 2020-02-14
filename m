Content-Type: multipart/mixed; boundary="===============7083813922208070825=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] genl: Export genl-private.h functions as public
Date: Sat, 15 Feb 2020 00:37:30 +0100
Message-ID: <20200214233732.20146-2-andrew.zaborowski@intel.com>
In-Reply-To: <20200214233732.20146-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7083813922208070825==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rename and upgrade _genl_msg_create and _genl_msg_as_bytes from
-private.h functions (for unit test use only) to public library
functions, specifically to be usable in IWD for encoding and decoding
raw genl messages.
---
 Makefile.am        |  1 -
 ell/ell.sym        |  2 ++
 ell/genl-private.h | 27 ----------------
 ell/genl.c         | 80 +++++++++++++++++++++++++++++-----------------
 ell/genl.h         |  5 +++
 5 files changed, 57 insertions(+), 58 deletions(-)
 delete mode 100644 ell/genl-private.h

diff --git a/Makefile.am b/Makefile.am
index 3ead678..8e025cb 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -83,7 +83,6 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/checksum.c \
 			ell/netlink-private.h \
 			ell/netlink.c \
-			ell/genl-private.h \
 			ell/genl.c \
 			ell/dbus-private.h \
 			ell/dbus.c \
diff --git a/ell/ell.sym b/ell/ell.sym
index 46df1bd..0c83b87 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -258,6 +258,8 @@ global:
 	l_genl_request_family;
 	l_genl_msg_new;
 	l_genl_msg_new_sized;
+	l_genl_msg_new_from_data;
+	l_genl_msg_to_data;
 	l_genl_msg_ref;
 	l_genl_msg_unref;
 	l_genl_msg_get_command;
diff --git a/ell/genl-private.h b/ell/genl-private.h
deleted file mode 100644
index 3c3e525..0000000
--- a/ell/genl-private.h
+++ /dev/null
@@ -1,27 +0,0 @@
-/*
- *
- *  Embedded Linux library
- *
- *  Copyright (C) 2011-2015  Intel Corporation. All rights reserved.
- *
- *  This library is free software; you can redistribute it and/or
- *  modify it under the terms of the GNU Lesser General Public
- *  License as published by the Free Software Foundation; either
- *  version 2.1 of the License, or (at your option) any later version.
- *
- *  This library is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  Lesser General Public License for more details.
- *
- *  You should have received a copy of the GNU Lesser General Public
- *  License along with this library; if not, write to the Free Software
- *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
- *
- */
-
-struct l_genl_msg *_genl_msg_create(const struct nlmsghdr *nlmsg);
-const void *_genl_msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
-					uint16_t flags, uint32_t seq,
-					uint32_t pid,
-					size_t *out_size);
diff --git a/ell/genl.c b/ell/genl.c
index ca4fa62..815af90 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -34,7 +34,6 @@
 #include "io.h"
 #include "netlink-private.h"
 #include "genl.h"
-#include "genl-private.h"
 #include "private.h"
 =

 #define MAX_NESTING_LEVEL 4
@@ -767,7 +766,7 @@ static bool msg_grow(struct l_genl_msg *msg, uint32_t n=
eeded)
 	return true;
 }
 =

-struct l_genl_msg *_genl_msg_create(const struct nlmsghdr *nlmsg)
+static struct l_genl_msg *msg_create(const struct nlmsghdr *nlmsg)
 {
 	struct l_genl_msg *msg;
 =

@@ -796,6 +795,32 @@ done:
 	return l_genl_msg_ref(msg);
 }
 =

+static const void *msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
+				uint16_t flags, uint32_t seq, uint32_t pid,
+				size_t *out_size)
+{
+	struct nlmsghdr *nlmsg;
+	struct genlmsghdr *genlmsg;
+
+	nlmsg =3D msg->data;
+
+	nlmsg->nlmsg_len =3D msg->len;
+	nlmsg->nlmsg_type =3D type;
+	nlmsg->nlmsg_flags =3D flags;
+	nlmsg->nlmsg_seq =3D seq;
+	nlmsg->nlmsg_pid =3D pid;
+
+	genlmsg =3D msg->data + NLMSG_HDRLEN;
+
+	genlmsg->cmd =3D msg->cmd;
+	genlmsg->version =3D msg->version;
+
+	if (out_size)
+		*out_size =3D msg->len;
+
+	return msg->data;
+}
+
 static void write_watch_destroy(void *user_data)
 {
 	struct l_genl *genl =3D user_data;
@@ -912,7 +937,7 @@ static void process_unicast(struct l_genl *genl, const =
struct nlmsghdr *nlmsg)
 					nlmsg->nlmsg_type =3D=3D NLMSG_OVERRUN)
 		return;
 =

-	msg =3D _genl_msg_create(nlmsg);
+	msg =3D msg_create(nlmsg);
 	if (!nlmsg->nlmsg_seq) {
 		if (msg)
 			dispatch_unicast_watches(genl, nlmsg->nlmsg_type, msg);
@@ -947,7 +972,7 @@ static void process_multicast(struct l_genl *genl, uint=
32_t group,
 						const struct nlmsghdr *nlmsg)
 {
 	const struct l_queue_entry *entry;
-	struct l_genl_msg *msg =3D _genl_msg_create(nlmsg);
+	struct l_genl_msg *msg =3D msg_create(nlmsg);
 =

 	if (!msg)
 		return;
@@ -1492,41 +1517,36 @@ LIB_EXPORT bool l_genl_request_family(struct l_genl=
 *genl, const char *name,
 	return false;
 }
 =

-const void *_genl_msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
-					uint16_t flags, uint32_t seq,
-					uint32_t pid,
-					size_t *out_size)
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new(uint8_t cmd)
 {
-	struct nlmsghdr *nlmsg;
-	struct genlmsghdr *genlmsg;
-
-	nlmsg =3D msg->data;
-
-	nlmsg->nlmsg_len =3D msg->len;
-	nlmsg->nlmsg_type =3D type;
-	nlmsg->nlmsg_flags =3D flags;
-	nlmsg->nlmsg_seq =3D seq;
-	nlmsg->nlmsg_pid =3D pid;
+	return l_genl_msg_new_sized(cmd, 0);
+}
 =

-	genlmsg =3D msg->data + NLMSG_HDRLEN;
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t s=
ize)
+{
+	return msg_alloc(cmd, 0x00, size);
+}
 =

-	genlmsg->cmd =3D msg->cmd;
-	genlmsg->version =3D msg->version;
+LIB_EXPORT struct l_genl_msg *l_genl_msg_new_from_data(const void *data,
+							size_t size)
+{
+	const struct nlmsghdr *nlmsg =3D (const void *) data;
 =

-	if (out_size)
-		*out_size =3D msg->len;
+	if (size < sizeof(struct nlmsghdr))
+		return NULL;
 =

-	return msg->data;
-}
+	if (size < nlmsg->nlmsg_len)
+		return NULL;
 =

-LIB_EXPORT struct l_genl_msg *l_genl_msg_new(uint8_t cmd)
-{
-	return l_genl_msg_new_sized(cmd, 0);
+	return msg_create(nlmsg);
 }
 =

-LIB_EXPORT struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t s=
ize)
+LIB_EXPORT const void *l_genl_msg_to_data(struct l_genl_msg *msg, uint16_t=
 type,
+						uint16_t flags, uint32_t seq,
+						uint32_t pid,
+						size_t *out_size)
 {
-	return msg_alloc(cmd, 0x00, size);
+	return msg_as_bytes(msg, type, flags, seq, pid, out_size);
 }
 =

 LIB_EXPORT struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg)
diff --git a/ell/genl.h b/ell/genl.h
index c3f641f..312a6b2 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -85,6 +85,11 @@ struct l_genl_attr {
 =

 struct l_genl_msg* l_genl_msg_new(uint8_t cmd);
 struct l_genl_msg *l_genl_msg_new_sized(uint8_t cmd, uint32_t size);
+struct l_genl_msg *l_genl_msg_new_from_data(const void *data, size_t size);
+
+const void *l_genl_msg_to_data(struct l_genl_msg *msg, uint16_t type,
+				uint16_t flags, uint32_t seq, uint32_t pid,
+				size_t *out_size);
 =

 struct l_genl_msg *l_genl_msg_ref(struct l_genl_msg *msg);
 void l_genl_msg_unref(struct l_genl_msg *msg);
-- =

2.20.1

--===============7083813922208070825==--

