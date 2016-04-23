Content-Type: multipart/mixed; boundary="===============6948525708833699854=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] unit: Gvariant iterator and builder test for empty structs
Date: Sat, 23 Apr 2016 03:10:06 +0200
Message-ID: <1461373807-19793-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6948525708833699854==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-gvariant-util.c | 51 +++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 51 insertions(+)

diff --git a/unit/test-gvariant-util.c b/unit/test-gvariant-util.c
index 9714df0..331b1f7 100644
--- a/unit/test-gvariant-util.c
+++ b/unit/test-gvariant-util.c
@@ -553,6 +553,32 @@ static void test_iter_nested_struct_1(const void *test=
_data)
 	assert(i =3D=3D -1);
 }
 =

+static const unsigned char empty_struct_data_1[] =3D {
+	0x00
+};
+
+static struct parser_data empty_struct_1 =3D {
+	.data =3D empty_struct_data_1,
+	.len =3D sizeof(empty_struct_data_1),
+	.signature =3D "()",
+};
+
+static void test_iter_empty_struct_1(const void *test_data)
+{
+	const struct parser_data *test =3D test_data;
+	struct l_dbus_message_iter iter;
+	bool ret;
+	struct l_dbus_message_iter str;
+
+	_gvariant_iter_init(&iter, NULL, test->signature,
+				test->signature + strlen(test->signature),
+				test->data, test->len);
+
+	ret =3D _gvariant_iter_enter_struct(&iter, &str);
+	assert(ret);
+	assert(str.sig_len =3D=3D 0);
+}
+
 static const unsigned char variant_data_1[] =3D {
 	0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x66, 0x6f, 0x6f, 0x62,
 	0x61, 0x72, 0x00, 0x00, 0x73, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
@@ -1360,6 +1386,25 @@ static void test_builder_nested_struct_1(const void =
*test_data)
 	FINISH_AND_CHECK_BUILT_RESULT();
 }
 =

+static void test_builder_empty_struct_1(const void *test_data)
+{
+	const struct parser_data *test =3D test_data;
+	struct dbus_builder *builder;
+	bool ret;
+	BUILDER_TEST_HEADER();
+
+	builder =3D _gvariant_builder_new(NULL, 0);
+	assert(builder);
+
+	ret =3D _gvariant_builder_enter_struct(builder, "");
+	assert(ret);
+
+	ret =3D _gvariant_builder_leave_struct(builder);
+	assert(ret);
+
+	FINISH_AND_CHECK_BUILT_RESULT();
+}
+
 static void test_builder_variant_1(const void *test_data)
 {
 	const struct parser_data *test =3D test_data;
@@ -1840,6 +1885,9 @@ int main(int argc, char *argv[])
 	l_test_add("Iter Test Nested Struct '((us)yi)'",
 			test_iter_nested_struct_1, &nested_struct_1);
 =

+	l_test_add("Iter Test Empty Struct '()'",
+			test_iter_empty_struct_1, &empty_struct_1);
+
 	l_test_add("Iter Test Variant '(uvu)i'", test_iter_variant_1,
 						&variant_1);
 	l_test_add("Iter Test Variant 'v'", test_iter_variant_2, &variant_2);
@@ -1876,6 +1924,9 @@ int main(int argc, char *argv[])
 	l_test_add("Builder Test Nested Struct '((us)yi)'",
 			test_builder_nested_struct_1, &nested_struct_1);
 =

+	l_test_add("Builder Test Empty Struct '()'",
+			test_builder_empty_struct_1, &empty_struct_1);
+
 	l_test_add("Builder Test Variant '(uvu)i'", test_builder_variant_1,
 						&variant_1);
 	l_test_add("Builder Test Variant 'v'", test_builder_variant_2,
-- =

2.5.0


--===============6948525708833699854==--

