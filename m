Content-Type: multipart/mixed; boundary="===============9017506541463104803=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: reuse mark+rewind,
 complex 1 tests for gvariant-message.
Date: Sat, 19 Mar 2016 07:00:47 +0100
Message-ID: <1458367247-14607-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9017506541463104803==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-gvariant-message.c | 158 +++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 152 insertions(+), 6 deletions(-)

diff --git a/unit/test-gvariant-message.c b/unit/test-gvariant-message.c
index 5573e63..c2cb811 100644
--- a/unit/test-gvariant-message.c
+++ b/unit/test-gvariant-message.c
@@ -79,6 +79,40 @@ static const struct message_data message_data_basic_1 =
=3D {
 	.binary_len	=3D 184,
 };
 =

+static const unsigned char message_binary_complex_1[] =3D {
+	0x6c, 0x01, 0x00, 0x02, 0x4f, 0x00, 0x00, 0x00, 0x57, 0x04, 0x00, 0x00,
+	0x86, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x2f, 0x63, 0x6f, 0x6d, 0x2f, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65,
+	0x2f, 0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x00, 0x00, 0x6f, 0x00, 0x00,
+	0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x65, 0x74, 0x68,
+	0x6f, 0x64, 0x00, 0x00, 0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63, 0x6f, 0x6d, 0x2e,
+	0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x69, 0x6e, 0x74, 0x65,
+	0x72, 0x66, 0x61, 0x63, 0x65, 0x00, 0x00, 0x73, 0x06, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x63, 0x6f, 0x6d, 0x2e, 0x65, 0x78, 0x61, 0x6d,
+	0x70, 0x6c, 0x65, 0x00, 0x00, 0x73, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x6f, 0x61, 0x7b, 0x73, 0x76, 0x7d, 0x00, 0x00,
+	0x67, 0x1e, 0x31, 0x58, 0x6e, 0x81, 0x00, 0x00, 0x2f, 0x63, 0x6f, 0x6d,
+	0x2f, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2f, 0x6f, 0x62, 0x6a,
+	0x65, 0x63, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4e, 0x61, 0x6d, 0x65,
+	0x00, 0x00, 0x00, 0x00, 0x4c, 0x69, 0x6e, 0x75, 0x73, 0x20, 0x54, 0x6f,
+	0x72, 0x76, 0x61, 0x6c, 0x64, 0x73, 0x00, 0x00, 0x73, 0x05, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x44, 0x65, 0x76, 0x65, 0x6c, 0x6f, 0x70, 0x65,
+	0x72, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x62, 0x0a,
+	0x1a, 0x34, 0x14,
+};
+
+static const struct message_data message_data_complex_1 =3D {
+	.type		=3D "method_call",
+	.path		=3D "/com/example/object",
+	.interface	=3D "com.example.interface",
+	.member		=3D "method",
+	.destination	=3D "com.example",
+	.signature	=3D "oa{sv}",
+	.binary		=3D message_binary_complex_1,
+	.binary_len	=3D sizeof(message_binary_complex_1),
+};
+
 static struct l_dbus_message *check_message(const struct message_data *msg=
_data)
 {
 	struct l_dbus_message *msg;
@@ -133,6 +167,17 @@ static struct l_dbus_message *check_message(const stru=
ct message_data *msg_data)
 	return msg;
 }
 =

+static struct l_dbus_message *build_message(const struct message_data *msg=
_data)
+{
+	struct l_dbus_message *msg;
+
+	msg =3D _dbus_message_new_method_call(2, msg_data->destination,
+			msg_data->path, msg_data->interface, msg_data->member);
+	assert(msg);
+
+	return msg;
+}
+
 static void compare_message(struct l_dbus_message *msg,
 					const struct message_data *msg_data)
 {
@@ -198,14 +243,9 @@ static void parse_basic_1(const void *data)
 =

 static void build_basic_1(const void *data)
 {
-	const struct message_data *msg_data =3D data;
-	struct l_dbus_message *msg;
+	struct l_dbus_message *msg =3D build_message(data);
 	bool result;
 =

-	msg =3D _dbus_message_new_method_call(2, msg_data->destination,
-			msg_data->path, msg_data->interface, msg_data->member);
-	assert(msg);
-
 	result =3D l_dbus_message_set_arguments(msg, "bynqiuxtd", true, 255,
 						-32, 32, -24, 24,
 						(uint64_t) 140179142606749,
@@ -217,6 +257,104 @@ static void build_basic_1(const void *data)
 	compare_message(msg, data);
 }
 =

+static void check_complex_1(const void *data)
+{
+	struct l_dbus_message *msg =3D check_message(data);
+	struct l_dbus_message_iter dict, iter;
+	const char *path, *str;
+	bool result, val;
+
+	result =3D l_dbus_message_get_arguments(msg, "oa{sv}", &path, &dict);
+	assert(result);
+	assert(!strcmp(path, "/com/example/object"));
+
+	result =3D l_dbus_message_iter_next_entry(&dict, &str, &iter);
+	assert(result);
+	assert(!strcmp(str, "Name"));
+
+	result =3D l_dbus_message_iter_get_variant(&iter, "s", &str);
+	assert(result);
+	assert(!strcmp(str, "Linus Torvalds"));
+
+	result =3D l_dbus_message_iter_next_entry(&dict, &str, &iter);
+	assert(result);
+	assert(!strcmp(str, "Developer"));
+
+	result =3D l_dbus_message_iter_get_variant(&iter, "b", &val);
+	assert(result);
+	assert(val);
+
+	result =3D l_dbus_message_iter_next_entry(&dict, &str, &iter);
+	assert(!result);
+
+	l_dbus_message_unref(msg);
+}
+
+static void build_complex_1(const void *data)
+{
+	struct l_dbus_message *msg =3D build_message(data);
+	bool result;
+
+	result =3D l_dbus_message_set_arguments(msg, "oa{sv}",
+						"/com/example/object", 2,
+						"Name", "s", "Linus Torvalds",
+						"Developer", "b", true);
+	assert(result);
+
+	_dbus_message_set_serial(msg, 1111);
+
+	compare_message(msg, data);
+}
+
+static void builder_rewind(const void *data)
+{
+	struct l_dbus_message *msg =3D build_message(data);
+	struct l_dbus_message_builder *builder;
+	bool b =3D true;
+
+	builder =3D l_dbus_message_builder_new(msg);
+	assert(builder);
+
+	assert(l_dbus_message_builder_append_basic(builder, 'o',
+							"/com/example/object"));
+
+	assert(l_dbus_message_builder_enter_array(builder, "{sv}"));
+
+	assert(_dbus_message_builder_mark(builder));
+
+	assert(l_dbus_message_builder_enter_dict(builder, "sv"));
+	assert(l_dbus_message_builder_append_basic(builder, 's', "Name"));
+	assert(l_dbus_message_builder_enter_variant(builder, "s"));
+	assert(l_dbus_message_builder_append_basic(builder, 's',
+							"Invalid"));
+	assert(l_dbus_message_builder_leave_variant(builder));
+	assert(l_dbus_message_builder_leave_dict(builder));
+
+	assert(_dbus_message_builder_rewind(builder));
+
+	assert(l_dbus_message_builder_enter_dict(builder, "sv"));
+	assert(l_dbus_message_builder_append_basic(builder, 's', "Name"));
+	assert(l_dbus_message_builder_enter_variant(builder, "s"));
+	assert(l_dbus_message_builder_append_basic(builder, 's',
+							"Linus Torvalds"));
+	assert(l_dbus_message_builder_leave_variant(builder));
+	assert(l_dbus_message_builder_leave_dict(builder));
+
+	assert(l_dbus_message_builder_enter_dict(builder, "sv"));
+	assert(l_dbus_message_builder_append_basic(builder, 's', "Developer"));
+	assert(l_dbus_message_builder_enter_variant(builder, "b"));
+	assert(l_dbus_message_builder_append_basic(builder, 'b', &b));
+	assert(l_dbus_message_builder_leave_variant(builder));
+	assert(l_dbus_message_builder_leave_dict(builder));
+
+	assert(l_dbus_message_builder_leave_array(builder));
+
+	assert(l_dbus_message_builder_finalize(builder));
+	l_dbus_message_builder_destroy(builder);
+
+	compare_message(msg, data);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -224,5 +362,13 @@ int main(int argc, char *argv[])
 	l_test_add("Basic 1 (parse)", parse_basic_1, &message_data_basic_1);
 	l_test_add("Basic 1 (build)", build_basic_1, &message_data_basic_1);
 =

+	l_test_add("Complex 1 (parse)", check_complex_1,
+						&message_data_complex_1);
+	l_test_add("Complex 1 (build)", build_complex_1,
+						&message_data_complex_1);
+
+	l_test_add("Message Builder Rewind Complex 1", builder_rewind,
+						&message_data_complex_1);
+
 	return l_test_run();
 }
-- =

2.5.0


--===============9017506541463104803==--

