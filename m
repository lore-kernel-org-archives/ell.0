Content-Type: multipart/mixed; boundary="===============7568580298114421180=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] dbus: Check nesting depth and set proper D-Bus stack depth
Date: Fri, 29 Sep 2017 13:42:14 -0700
Message-ID: <20170929204215.9897-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7568580298114421180==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The maximum nesting level was not being enforced, and the stack array used =
to
generate D-Bus messages was not large enough.
---
 ell/dbus-message.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index ae132c4..9b24752 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -54,6 +54,8 @@
 #define DBUS_MESSAGE_FIELD_SIGNATURE	8
 #define DBUS_MESSAGE_FIELD_UNIX_FDS	9
 =

+#define DBUS_MAX_NESTING	32
+
 struct l_dbus_message {
 	int refcount;
 	void *header;
@@ -486,7 +488,7 @@ static bool message_iter_next_entry_valist(struct l_dbu=
s_message_iter *orig,
 	const char *signature =3D orig->sig_start + orig->sig_pos;
 	const char *end;
 	struct l_dbus_message_iter *sub_iter;
-	struct l_dbus_message_iter stack[32];
+	struct l_dbus_message_iter stack[DBUS_MAX_NESTING];
 	unsigned int indent =3D 0;
 	uint32_t uint32_val;
 	int fd;
@@ -540,6 +542,9 @@ static bool message_iter_next_entry_valist(struct l_dbu=
s_message_iter *orig,
 			signature +=3D 1;
 			indent +=3D 1;
 =

+			if (indent > DBUS_MAX_NESTING)
+				return false;
+
 			if (!enter_struct(iter, &stack[indent - 1]))
 				return false;
 =

@@ -548,6 +553,9 @@ static bool message_iter_next_entry_valist(struct l_dbu=
s_message_iter *orig,
 			break;
 		case ')':
 		case '}':
+			if (indent =3D=3D 0)
+				return false;
+
 			signature +=3D 1;
 			indent -=3D 1;
 =

@@ -1082,7 +1090,8 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 	char *generated_signature;
 	char subsig[256];
 	const char *sigend;
-	struct container stack[32];
+	/* Nesting requires an extra stack entry for the base level */
+	struct container stack[DBUS_MAX_NESTING + 1];
 	unsigned int stack_index =3D 0;
 =

 	if (_dbus_message_is_gvariant(message))
@@ -1127,7 +1136,7 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 				ret =3D false;
 			}
 =

-			if (!ret)
+			if (!ret || !stack_index)
 				goto error;
 =

 			stack_index -=3D 1;
@@ -1213,6 +1222,9 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 		}
 		case '(':
 		case '{':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				goto error;
+
 			sigend =3D _dbus_signature_end(s);
 			memcpy(subsig, s + 1, sigend - s - 1);
 			subsig[sigend - s - 1] =3D '\0';
@@ -1237,6 +1249,9 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 =

 			break;
 		case 'v':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				goto error;
+
 			str =3D va_arg(args, const char *);
 =

 			if (!str)
@@ -1253,6 +1268,9 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 =

 			break;
 		case 'a':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				goto error;
+
 			sigend =3D _dbus_signature_end(s + 1) + 1;
 			memcpy(subsig, s + 1, sigend - s - 1);
 			subsig[sigend - s - 1] =3D '\0';
-- =

2.14.2


--===============7568580298114421180==--

