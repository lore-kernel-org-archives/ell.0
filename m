Content-Type: multipart/mixed; boundary="===============7960251851739367874=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: Gvariant method call with no arguments tests
Date: Sat, 23 Apr 2016 03:10:07 +0200
Message-ID: <1461373807-19793-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7960251851739367874==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-gvariant-message.c | 51 ++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 51 insertions(+)

diff --git a/unit/test-gvariant-message.c b/unit/test-gvariant-message.c
index 836ba29..85326a6 100644
--- a/unit/test-gvariant-message.c
+++ b/unit/test-gvariant-message.c
@@ -110,6 +110,30 @@ static const struct message_data message_data_complex_=
1 =3D {
 	.binary_len	=3D sizeof(message_binary_complex_1),
 };
 =

+static const unsigned char message_binary_empty_sig[] =3D {
+	0x6c, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x57, 0x04, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x2f, 0x66, 0x6f, 0x6f, 0x2f, 0x62, 0x61, 0x72, 0x00, 0x00, 0x6f, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x46, 0x6f, 0x6f, 0x62, 0x61, 0x72, 0x00, 0x00, 0x73, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x66, 0x6f, 0x6f, 0x2e, 0x62, 0x61, 0x72, 0x00, 0x00, 0x73, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x66, 0x6f, 0x6f, 0x2e, 0x62, 0x61, 0x72, 0x00, 0x00, 0x73, 0x13, 0x29,
+	0x42, 0x5a, 0x00, 0x00, 0x00, 0x00, 0x28, 0x29, 0x6e,
+};
+
+static const struct message_data message_data_empty_sig =3D {
+	.type		=3D "method_call",
+	.path		=3D "/foo/bar",
+	.interface	=3D "foo.bar",
+	.member		=3D "Foobar",
+	.destination	=3D "foo.bar",
+	.signature	=3D "",
+	.binary		=3D message_binary_empty_sig,
+	.binary_len	=3D sizeof(message_binary_empty_sig),
+};
+
 static struct l_dbus_message *check_message(const struct message_data *msg=
_data)
 {
 	struct l_dbus_message *msg;
@@ -303,6 +327,28 @@ static void build_complex_1(const void *data)
 	compare_message(msg, data);
 }
 =

+static void check_empty_sig(const void *data)
+{
+	struct l_dbus_message *msg =3D check_message(data);
+
+	assert(l_dbus_message_get_arguments(msg, ""));
+
+	l_dbus_message_unref(msg);
+}
+
+static void build_empty_sig(const void *data)
+{
+	struct l_dbus_message *msg =3D build_message(data);
+	bool result;
+
+	result =3D l_dbus_message_set_arguments(msg, "");
+	assert(result);
+
+	_dbus_message_set_serial(msg, 1111);
+
+	compare_message(msg, data);
+}
+
 static void builder_rewind(const void *data)
 {
 	struct l_dbus_message *msg =3D build_message(data);
@@ -364,6 +410,11 @@ int main(int argc, char *argv[])
 	l_test_add("Complex 1 (build)", build_complex_1,
 						&message_data_complex_1);
 =

+	l_test_add("Empty signature (parse)", check_empty_sig,
+						&message_data_empty_sig);
+	l_test_add("Empty signature (build)", build_empty_sig,
+						&message_data_empty_sig);
+
 	l_test_add("Message Builder Rewind Complex 1", builder_rewind,
 						&message_data_complex_1);
 =

-- =

2.5.0


--===============7960251851739367874==--

