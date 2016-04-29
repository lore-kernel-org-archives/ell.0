Content-Type: multipart/mixed; boundary="===============3516844221454559143=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/11] dbus: Check the FD array size in
 l_dbus_message_builder_append_from_iter
Date: Fri, 29 Apr 2016 05:32:02 +0200
Message-ID: <1461900728-20662-10-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3516844221454559143==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Also make sure an invalid FD in the input message is reflected as an
invalid FD in the output message and non-fatal.
---
 ell/dbus-message.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 5f91360..628f994 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1862,7 +1862,6 @@ LIB_EXPORT bool l_dbus_message_builder_append_from_it=
er(
 	void *basic_ptr;
 	uint64_t basic;
 	uint32_t uint32_val;
-	int fd;
 	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
 	bool (*enter_func)(struct l_dbus_message_iter *,
 				struct l_dbus_message_iter *);
@@ -1908,17 +1907,22 @@ LIB_EXPORT bool l_dbus_message_builder_append_from_=
iter(
 		if (!get_basic(from, type, &uint32_val))
 			return false;
 =

-		if (uint32_val >=3D from->message->num_fds)
+		if (!l_dbus_message_builder_append_basic(builder, type,
+						&builder->message->num_fds))
 			return false;
 =

-		fd =3D fcntl(from->message->fds[uint32_val], F_DUPFD_CLOEXEC, 3);
+		if (builder->message->num_fds <
+				L_ARRAY_SIZE(builder->message->fds)) {
+			int fd;
 =

-		uint32_val =3D builder->message->num_fds;
-		builder->message->fds[builder->message->num_fds++] =3D fd;
+			if (uint32_val < from->message->num_fds)
+				fd =3D fcntl(from->message->fds[uint32_val],
+						F_DUPFD_CLOEXEC, 3);
+			else
+				fd =3D -1;
 =

-		if (!l_dbus_message_builder_append_basic(builder, type,
-								&uint32_val))
-			return false;
+			builder->message->fds[builder->message->num_fds++] =3D fd;
+		}
 =

 		return true;
 	case '(':
-- =

2.5.0


--===============3516844221454559143==--

