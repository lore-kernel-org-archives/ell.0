Content-Type: multipart/mixed; boundary="===============6706734683059716325=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [RFC 2/6] dbus: Add l_dbus_message_builder_append_from_valist
Date: Wed, 29 Nov 2017 16:16:44 +0100
Message-ID: <20171129151648.24749-3-szymon.janc@codecoup.pl>
In-Reply-To: <20171129151648.24749-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6706734683059716325==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows to build messages from va_list.
---
 ell/dbus-message.c | 220 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h         |   4 +
 2 files changed, 224 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 0314a07..e46ce99 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1930,6 +1930,226 @@ LIB_EXPORT bool l_dbus_message_builder_append_from_=
iter(
 	return true;
 }
 =

+LIB_EXPORT bool l_dbus_message_builder_append_from_valist(
+					struct l_dbus_message_builder *builder,
+					const char *signature, va_list args)
+{
+	struct builder_driver *driver;
+	char subsig[256];
+	const char *sigend;
+	/* Nesting requires an extra stack entry for the base level */
+	struct container stack[DBUS_MAX_NESTING + 1];
+	unsigned int stack_index =3D 0;
+
+	if (unlikely(!builder))
+		return false;
+
+	driver =3D builder->driver;
+
+	stack[stack_index].type =3D DBUS_CONTAINER_TYPE_STRUCT;
+	stack[stack_index].sig_start =3D signature;
+	stack[stack_index].sig_end =3D signature + strlen(signature);
+	stack[stack_index].n_items =3D 0;
+
+	while (stack_index !=3D 0 || stack[0].sig_start !=3D stack[0].sig_end) {
+		const char *s;
+		const char *str;
+
+		if (stack[stack_index].type =3D=3D DBUS_CONTAINER_TYPE_ARRAY &&
+				stack[stack_index].n_items =3D=3D 0)
+			stack[stack_index].sig_start =3D
+				stack[stack_index].sig_end;
+
+		if (stack[stack_index].sig_start =3D=3D
+				stack[stack_index].sig_end) {
+			bool ret;
+
+			/*
+			 * Sanity check in case of an invalid signature that
+			 * isn't caught elsewhere.
+			 */
+			if (unlikely(stack_index =3D=3D 0))
+				return false;
+
+			switch (stack[stack_index].type) {
+			case DBUS_CONTAINER_TYPE_STRUCT:
+				ret =3D driver->leave_struct(builder->builder);
+				break;
+			case DBUS_CONTAINER_TYPE_DICT_ENTRY:
+				ret =3D driver->leave_dict(builder->builder);
+				break;
+			case DBUS_CONTAINER_TYPE_VARIANT:
+				ret =3D driver->leave_variant(builder->builder);
+				break;
+			case DBUS_CONTAINER_TYPE_ARRAY:
+				ret =3D driver->leave_array(builder->builder);
+				break;
+			default:
+				ret =3D false;
+			}
+
+			if (!ret)
+				return false;
+
+			stack_index -=3D 1;
+			continue;
+		}
+
+		s =3D stack[stack_index].sig_start;
+
+		if (stack[stack_index].type !=3D DBUS_CONTAINER_TYPE_ARRAY)
+			stack[stack_index].sig_start +=3D 1;
+		else
+			stack[stack_index].n_items -=3D 1;
+
+		switch (*s) {
+		case 'o':
+		case 's':
+		case 'g':
+			str =3D va_arg(args, const char *);
+
+			if (!driver->append_basic(builder->builder, *s, str))
+				return false;
+			break;
+		case 'b':
+		case 'y':
+		{
+			uint8_t y =3D (uint8_t) va_arg(args, int);
+
+			if (!driver->append_basic(builder->builder, *s, &y))
+				return false;
+
+			break;
+		}
+		case 'n':
+		case 'q':
+		{
+			uint16_t n =3D (uint16_t) va_arg(args, int);
+
+			if (!driver->append_basic(builder->builder, *s, &n))
+				return false;
+
+			break;
+		}
+		case 'i':
+		case 'u':
+		{
+			uint32_t u =3D va_arg(args, uint32_t);
+
+			if (!driver->append_basic(builder->builder, *s, &u))
+				return false;
+
+			break;
+		}
+		case 'h':
+		{
+			int fd =3D va_arg(args, int);
+			struct l_dbus_message *message =3D builder->message;
+
+			if (!driver->append_basic(builder->builder, *s,
+							&message->num_fds))
+				return false;
+
+			if (message->num_fds < L_ARRAY_SIZE(message->fds))
+				message->fds[message->num_fds++] =3D
+					fcntl(fd, F_DUPFD_CLOEXEC, 3);
+
+			break;
+		}
+		case 'x':
+		case 't':
+		{
+			uint64_t x =3D va_arg(args, uint64_t);
+
+			if (!driver->append_basic(builder->builder, *s, &x))
+				return false;
+			break;
+		}
+		case 'd':
+		{
+			double d =3D va_arg(args, double);
+
+			if (!driver->append_basic(builder->builder, *s, &d))
+				return false;
+			break;
+		}
+		case '(':
+		case '{':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				return false;
+
+			sigend =3D _dbus_signature_end(s);
+			memcpy(subsig, s + 1, sigend - s - 1);
+			subsig[sigend - s - 1] =3D '\0';
+
+			if (*s =3D=3D '(' && !driver->enter_struct(builder->builder, subsig))
+				return false;
+
+			if (*s =3D=3D '{' && !driver->enter_dict(builder->builder, subsig))
+				return false;
+
+			if (stack[stack_index].type !=3D
+					DBUS_CONTAINER_TYPE_ARRAY)
+				stack[stack_index].sig_start =3D sigend + 1;
+
+			stack_index +=3D 1;
+			stack[stack_index].sig_start =3D s + 1;
+			stack[stack_index].sig_end =3D sigend;
+			stack[stack_index].n_items =3D 0;
+			stack[stack_index].type =3D *s =3D=3D '(' ?
+						DBUS_CONTAINER_TYPE_STRUCT :
+						DBUS_CONTAINER_TYPE_DICT_ENTRY;
+
+			break;
+		case 'v':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				return false;
+
+			str =3D va_arg(args, const char *);
+
+			if (!str)
+				return false;
+
+			if (!driver->enter_variant(builder->builder, str))
+				return false;
+
+			stack_index +=3D 1;
+			stack[stack_index].type =3D DBUS_CONTAINER_TYPE_VARIANT;
+			stack[stack_index].sig_start =3D str;
+			stack[stack_index].sig_end =3D str + strlen(str);
+			stack[stack_index].n_items =3D 0;
+
+			break;
+		case 'a':
+			if (stack_index =3D=3D DBUS_MAX_NESTING)
+				return false;
+
+			sigend =3D _dbus_signature_end(s + 1) + 1;
+			memcpy(subsig, s + 1, sigend - s - 1);
+			subsig[sigend - s - 1] =3D '\0';
+
+			if (!driver->enter_array(builder->builder, subsig))
+				return false;
+
+			if (stack[stack_index].type !=3D
+					DBUS_CONTAINER_TYPE_ARRAY)
+				stack[stack_index].sig_start =3D sigend;
+
+			stack_index +=3D 1;
+			stack[stack_index].sig_start =3D s + 1;
+			stack[stack_index].sig_end =3D sigend;
+			stack[stack_index].n_items =3D va_arg(args, unsigned int);
+			stack[stack_index].type =3D DBUS_CONTAINER_TYPE_ARRAY;
+
+			break;
+		default:
+			return false;
+		}
+	}
+
+	return true;
+}
+
 LIB_EXPORT struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder)
 {
diff --git a/ell/dbus.h b/ell/dbus.h
index 5c7879f..1b1ec2b 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -214,6 +214,10 @@ bool l_dbus_message_builder_append_from_iter(
 					struct l_dbus_message_builder *builder,
 					struct l_dbus_message_iter *from);
 =

+bool l_dbus_message_builder_append_from_valist(
+					struct l_dbus_message_builder *builder,
+					const char *signature, va_list args);
+
 struct l_dbus_message *l_dbus_message_builder_finalize(
 					struct l_dbus_message_builder *builder);
 =

-- =

2.14.3


--===============6706734683059716325==--

