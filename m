Content-Type: multipart/mixed; boundary="===============2787439204943213719=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] dbus: setters and getters API for properties.
Date: Fri, 05 Feb 2016 03:58:28 +0100
Message-ID: <1454641114-3421-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1454641114-3421-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2787439204943213719==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These setters and getters are not used yet.

(I will split all of the patches by directories when submitting a final
version, this is just for the ease of reviewing)
---
 ell/dbus-service.c       | 28 ++++++------------
 ell/dbus-service.h       | 26 +++++++++++------
 examples/dbus-service.c  | 75 ++++++++++++++++++++++++++++++++++++++++++++=
++--
 unit/test-dbus-service.c | 20 ++++++++++++-
 4 files changed, 119 insertions(+), 30 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 639872b..772e7a7 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -61,6 +61,8 @@ struct _dbus_signal {
 };
 =

 struct _dbus_property {
+	l_dbus_property_get_cb_t getter;
+	l_dbus_property_set_cb_t setter;
 	uint32_t flags;
 	unsigned char name_len;
 	char metainfo[];
@@ -191,7 +193,7 @@ void _dbus_property_introspection(struct _dbus_property=
 *info,
 	l_string_append_printf(buf, "\t\t<property name=3D\"%s\" type=3D\"%s\" ",
 				info->metainfo, signature);
 =

-	if (info->flags & L_DBUS_PROPERTY_FLAG_WRITABLE)
+	if (info->setter)
 		l_string_append(buf, "access=3D\"readwrite\"");
 	else
 		l_string_append(buf, "access=3D\"read\"");
@@ -375,7 +377,9 @@ LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_i=
nterface *interface,
 =

 LIB_EXPORT bool l_dbus_interface_property(struct l_dbus_interface *interfa=
ce,
 					const char *name, uint32_t flags,
-					const char *signature)
+					const char *signature,
+					l_dbus_property_get_cb_t getter,
+					l_dbus_property_set_cb_t setter)
 {
 	unsigned int metainfo_len;
 	struct _dbus_property *info;
@@ -384,7 +388,7 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbus=
_interface *interface,
 	if (!_dbus_valid_method(name))
 		return false;
 =

-	if (unlikely(!signature))
+	if (unlikely(!signature || !getter))
 		return false;
 =

 	if (!_dbus_valid_signature(signature))
@@ -397,6 +401,8 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbus=
_interface *interface,
 	info =3D l_malloc(sizeof(*info) + metainfo_len);
 	info->flags =3D flags;
 	info->name_len =3D strlen(name);
+	info->getter =3D getter;
+	info->setter =3D setter;
 =

 	p =3D stpcpy(info->metainfo, name) + 1;
 	strcpy(p, signature);
@@ -406,22 +412,6 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbu=
s_interface *interface,
 	return true;
 }
 =

-LIB_EXPORT bool l_dbus_interface_ro_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name, 0, signature);
-}
-
-LIB_EXPORT bool l_dbus_interface_rw_property(struct l_dbus_interface *inte=
rface,
-						const char *name,
-						const char *signature)
-{
-	return l_dbus_interface_property(interface, name,
-					L_DBUS_PROPERTY_FLAG_WRITABLE,
-					signature);
-}
-
 struct l_dbus_interface *_dbus_interface_new(const char *name)
 {
 	struct l_dbus_interface *interface;
diff --git a/ell/dbus-service.h b/ell/dbus-service.h
index ce53082..d1825dd 100644
--- a/ell/dbus-service.h
+++ b/ell/dbus-service.h
@@ -46,13 +46,27 @@ enum l_dbus_signal_flag {
 =

 enum l_dbus_property_flag {
 	L_DBUS_PROPERTY_FLAG_DEPRECATED =3D 1,
-	L_DBUS_PROPERTY_FLAG_WRITABLE	=3D 2,
 };
 =

 typedef struct l_dbus_message *(*l_dbus_interface_method_cb_t) (struct l_d=
bus *,
 						struct l_dbus_message *message,
 						void *user_data);
 =

+typedef void (*l_dbus_property_complete_cb_t) (struct l_dbus *,
+						struct l_dbus_message *,
+						struct l_dbus_message *error);
+
+typedef void (*l_dbus_property_set_cb_t) (struct l_dbus *,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data);
+
+typedef bool (*l_dbus_property_get_cb_t) (struct l_dbus *,
+					struct l_dbus_message *message,
+					struct l_dbus_message_builder *builder,
+					void *user_data);
+
 bool l_dbus_interface_method(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
 				l_dbus_interface_method_cb_t cb,
@@ -65,13 +79,9 @@ bool l_dbus_interface_signal(struct l_dbus_interface *in=
terface,
 =

 bool l_dbus_interface_property(struct l_dbus_interface *interface,
 				const char *name, uint32_t flags,
-				const char *signature);
-bool l_dbus_interface_ro_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
-bool l_dbus_interface_rw_property(struct l_dbus_interface *interface,
-					const char *name,
-					const char *signature);
+				const char *signature,
+				l_dbus_property_get_cb_t getter,
+				l_dbus_property_set_cb_t setter);
 =

 #ifdef __cplusplus
 }
diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 40c1646..2620a96 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -187,6 +187,75 @@ static struct l_dbus_message *test_method_call(struct =
l_dbus *dbus,
 	return reply;
 }
 =

+static bool test_string_getter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	struct test_data *test =3D user_data;
+
+	l_dbus_message_builder_append_basic(builder, 's', test->string);
+
+	return true;
+}
+
+static void test_string_setter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_iter *new_value,
+				l_dbus_property_complete_cb_t complete,
+				void *user_data)
+{
+	const char *strvalue;
+	struct test_data *test =3D user_data;
+
+	if (!l_dbus_message_iter_get_variant(new_value, "s", &strvalue)) {
+		complete(dbus, message, l_dbus_message_new_error(message,
+					"org.test.InvalidArguments",
+					"String value expected"));
+		return;
+	}
+
+	l_info("New String value: %s", strvalue);
+	l_free(test->string);
+	test->string =3D l_strdup(strvalue);
+
+	complete(dbus, message, NULL);
+}
+
+static bool test_int_getter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_builder *builder,
+				void *user_data)
+{
+	struct test_data *test =3D user_data;
+
+	l_dbus_message_builder_append_basic(builder, 'u', &test->integer);
+
+	return true;
+}
+
+static void test_int_setter(struct l_dbus *dbus,
+				struct l_dbus_message *message,
+				struct l_dbus_message_iter *new_value,
+				l_dbus_property_complete_cb_t complete,
+				void *user_data)
+{
+	uint32_t u;
+	struct test_data *test =3D user_data;
+
+	if (!l_dbus_message_iter_get_variant(new_value, "u", &u)) {
+		complete(dbus, message, l_dbus_message_new_error(message,
+					"org.test.InvalidArguments",
+					"Integer value expected"));
+		return;
+	}
+
+	l_info("New Integer value: %u", u);
+	test->integer =3D u;
+
+	complete(dbus, message, NULL);
+}
+
 static void setup_test_interface(struct l_dbus_interface *interface)
 {
 	l_dbus_interface_method(interface, "GetProperties", 0,
@@ -201,8 +270,10 @@ static void setup_test_interface(struct l_dbus_interfa=
ce *interface)
 	l_dbus_interface_signal(interface, "PropertyChanged", 0,
 				"sv", "name", "value");
 =

-	l_dbus_interface_rw_property(interface, "String", "s");
-	l_dbus_interface_rw_property(interface, "Integer", "u");
+	l_dbus_interface_property(interface, "String", 0, "s",
+					test_string_getter, test_string_setter);
+	l_dbus_interface_property(interface, "Integer", 0, "u",
+					test_int_getter, test_int_setter);
 }
 =

 int main(int argc, char *argv[])
diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
index 7452269..ea91b87 100644
--- a/unit/test-dbus-service.c
+++ b/unit/test-dbus-service.c
@@ -315,6 +315,22 @@ static void test_dbus_object_tree_dispatch(const void =
*test_data)
 	_dbus_object_tree_free(tree);
 }
 =

+static bool test_property_getter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_builder *builder,
+					void *if_user_data)
+{
+	return true;
+}
+
+static void test_property_setter(struct l_dbus *dbus,
+					struct l_dbus_message *message,
+					struct l_dbus_message_iter *new_value,
+					l_dbus_property_complete_cb_t complete,
+					void *user_data)
+{
+}
+
 int main(int argc, char *argv[])
 {
 	int ret;
@@ -333,7 +349,9 @@ int main(int argc, char *argv[])
 =

 	l_dbus_interface_signal(interface, "Changed", 0, "b", "new_value");
 =

-	l_dbus_interface_rw_property(interface, "Bar", "y");
+	l_dbus_interface_property(interface, "Bar", 0, "y",
+					test_property_getter,
+					test_property_setter);
 =

 	l_test_add("Test Frobate Introspection", test_introspect_method,
 			&frobate_test);
-- =

2.5.0


--===============2787439204943213719==--

