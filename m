Content-Type: multipart/mixed; boundary="===============0718876431411430414=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [RFC 3/6] dbus: Use l_dbus_message_builder_append_from_valist in
 append_arguments
Date: Wed, 29 Nov 2017 16:16:45 +0100
Message-ID: <20171129151648.24749-4-szymon.janc@codecoup.pl>
In-Reply-To: <20171129151648.24749-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0718876431411430414==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Those functions do similar things and code duplication can be avoided.
---
 ell/dbus-message.c | 238 +++----------------------------------------------=
----
 1 file changed, 12 insertions(+), 226 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index e46ce99..9878de5 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1089,239 +1089,25 @@ struct container {
 static bool append_arguments(struct l_dbus_message *message,
 					const char *signature, va_list args)
 {
-	struct dbus_builder *builder;
-	struct builder_driver *driver;
-	char *generated_signature;
-	char subsig[256];
-	const char *sigend;
-	/* Nesting requires an extra stack entry for the base level */
-	struct container stack[DBUS_MAX_NESTING + 1];
-	unsigned int stack_index =3D 0;
-
-	if (_dbus_message_is_gvariant(message))
-		driver =3D &gvariant_driver;
-	else
-		driver =3D &dbus1_driver;
-
-	builder =3D driver->new(NULL, 0);
-
-	stack[stack_index].type =3D DBUS_CONTAINER_TYPE_STRUCT;
-	stack[stack_index].sig_start =3D signature;
-	stack[stack_index].sig_end =3D signature + strlen(signature);
-	stack[stack_index].n_items =3D 0;
-
-	while (stack_index !=3D 0 || stack[0].sig_start !=3D stack[0].sig_end) {
-		const char *s;
-		const char *str;
-
-		if (stack[stack_index].type =3D=3D DBUS_CONTAINER_TYPE_ARRAY &&
-				stack[stack_index].n_items =3D=3D 0)
-			stack[stack_index].sig_start =3D
-				stack[stack_index].sig_end;
-
-		if (stack[stack_index].sig_start =3D=3D
-				stack[stack_index].sig_end) {
-			bool ret;
-
-			/*
-			 * Sanity check in case of an invalid signature that
-			 * isn't caught elsewhere.
-			 */
-			if (unlikely(stack_index =3D=3D 0))
-				goto error;
-
-			switch (stack[stack_index].type) {
-			case DBUS_CONTAINER_TYPE_STRUCT:
-				ret =3D driver->leave_struct(builder);
-				break;
-			case DBUS_CONTAINER_TYPE_DICT_ENTRY:
-				ret =3D driver->leave_dict(builder);
-				break;
-			case DBUS_CONTAINER_TYPE_VARIANT:
-				ret =3D driver->leave_variant(builder);
-				break;
-			case DBUS_CONTAINER_TYPE_ARRAY:
-				ret =3D driver->leave_array(builder);
-				break;
-			default:
-				ret =3D false;
-			}
-
-			if (!ret)
-				goto error;
-
-			stack_index -=3D 1;
-			continue;
-		}
-
-		s =3D stack[stack_index].sig_start;
-
-		if (stack[stack_index].type !=3D DBUS_CONTAINER_TYPE_ARRAY)
-			stack[stack_index].sig_start +=3D 1;
-		else
-			stack[stack_index].n_items -=3D 1;
-
-		switch (*s) {
-		case 'o':
-		case 's':
-		case 'g':
-			str =3D va_arg(args, const char *);
-
-			if (!driver->append_basic(builder, *s, str))
-				goto error;
-			break;
-		case 'b':
-		case 'y':
-		{
-			uint8_t y =3D (uint8_t) va_arg(args, int);
-
-			if (!driver->append_basic(builder, *s, &y))
-				goto error;
-
-			break;
-		}
-		case 'n':
-		case 'q':
-		{
-			uint16_t n =3D (uint16_t) va_arg(args, int);
-
-			if (!driver->append_basic(builder, *s, &n))
-				goto error;
-
-			break;
-		}
-		case 'i':
-		case 'u':
-		{
-			uint32_t u =3D va_arg(args, uint32_t);
-
-			if (!driver->append_basic(builder, *s, &u))
-				goto error;
-
-			break;
-		}
-		case 'h':
-		{
-			int fd =3D va_arg(args, int);
-
-			if (!driver->append_basic(builder, *s,
-							&message->num_fds))
-				goto error;
-
-			if (message->num_fds < L_ARRAY_SIZE(message->fds))
-				message->fds[message->num_fds++] =3D
-					fcntl(fd, F_DUPFD_CLOEXEC, 3);
-
-			break;
-		}
-		case 'x':
-		case 't':
-		{
-			uint64_t x =3D va_arg(args, uint64_t);
-
-			if (!driver->append_basic(builder, *s, &x))
-				goto error;
-			break;
-		}
-		case 'd':
-		{
-			double d =3D va_arg(args, double);
-
-			if (!driver->append_basic(builder, *s, &d))
-				goto error;
-			break;
-		}
-		case '(':
-		case '{':
-			if (stack_index =3D=3D DBUS_MAX_NESTING)
-				goto error;
-
-			sigend =3D _dbus_signature_end(s);
-			memcpy(subsig, s + 1, sigend - s - 1);
-			subsig[sigend - s - 1] =3D '\0';
-
-			if (*s =3D=3D '(' && !driver->enter_struct(builder, subsig))
-				goto error;
-
-			if (*s =3D=3D '{' && !driver->enter_dict(builder, subsig))
-				goto error;
-
-			if (stack[stack_index].type !=3D
-					DBUS_CONTAINER_TYPE_ARRAY)
-				stack[stack_index].sig_start =3D sigend + 1;
-
-			stack_index +=3D 1;
-			stack[stack_index].sig_start =3D s + 1;
-			stack[stack_index].sig_end =3D sigend;
-			stack[stack_index].n_items =3D 0;
-			stack[stack_index].type =3D *s =3D=3D '(' ?
-						DBUS_CONTAINER_TYPE_STRUCT :
-						DBUS_CONTAINER_TYPE_DICT_ENTRY;
-
-			break;
-		case 'v':
-			if (stack_index =3D=3D DBUS_MAX_NESTING)
-				goto error;
-
-			str =3D va_arg(args, const char *);
-
-			if (!str)
-				goto error;
-
-			if (!driver->enter_variant(builder, str))
-				goto error;
-
-			stack_index +=3D 1;
-			stack[stack_index].type =3D DBUS_CONTAINER_TYPE_VARIANT;
-			stack[stack_index].sig_start =3D str;
-			stack[stack_index].sig_end =3D str + strlen(str);
-			stack[stack_index].n_items =3D 0;
-
-			break;
-		case 'a':
-			if (stack_index =3D=3D DBUS_MAX_NESTING)
-				goto error;
-
-			sigend =3D _dbus_signature_end(s + 1) + 1;
-			memcpy(subsig, s + 1, sigend - s - 1);
-			subsig[sigend - s - 1] =3D '\0';
+	struct l_dbus_message_builder *builder;
+	bool ret;
 =

-			if (!driver->enter_array(builder, subsig))
-				goto error;
-
-			if (stack[stack_index].type !=3D
-					DBUS_CONTAINER_TYPE_ARRAY)
-				stack[stack_index].sig_start =3D sigend;
-
-			stack_index +=3D 1;
-			stack[stack_index].sig_start =3D s + 1;
-			stack[stack_index].sig_end =3D sigend;
-			stack[stack_index].n_items =3D va_arg(args, unsigned int);
-			stack[stack_index].type =3D DBUS_CONTAINER_TYPE_ARRAY;
+	builder =3D l_dbus_message_builder_new(message);
+	if (!builder)
+		return false;
 =

-			break;
-		default:
-			goto error;
-		}
+	if (!l_dbus_message_builder_append_from_valist(builder, signature, args))=
 {
+		l_dbus_message_builder_destroy(builder);
+		return false;
 	}
 =

-	generated_signature =3D driver->finish(builder, &message->body,
-						&message->body_size);
-	driver->free(builder);
+	l_dbus_message_builder_finalize(builder);
 =

-	if (strcmp(signature, generated_signature))
-		return false;
+	ret =3D strcmp(signature, builder->message->signature) =3D=3D 0;
 =

-	build_header(message, signature);
-	message->sealed =3D true;
-	message->signature =3D generated_signature;
-	message->signature_free =3D true;
+	l_dbus_message_builder_destroy(builder);
 =

-	return true;
-
-error:
-	driver->free(builder);
-	return false;
+	return ret;
 }
 =

 LIB_EXPORT bool l_dbus_message_get_error(struct l_dbus_message *message,
-- =

2.14.3


--===============0718876431411430414==--

