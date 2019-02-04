Content-Type: multipart/mixed; boundary="===============9064344636965311953=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH v2] uuid: Added l_uuid_from_string
Date: Mon, 04 Feb 2019 11:41:07 +0100
Message-ID: <20190204104107.17893-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9064344636965311953==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>

This commit adds API complementary to l_uuid_to_string, allowing parsing
canonical string representation into a byte array.
---
 ell/ell.sym      |  1 +
 ell/uuid.c       | 34 +++++++++++++++++++++++++
 ell/uuid.h       |  1 +
 unit/test-uuid.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index e41e1c3..4fc547e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -445,6 +445,7 @@ global:
 	l_uuid_is_valid;
 	l_uuid_get_version;
 	l_uuid_to_string;
+	l_uuid_from_string;
 	/* cert */
 	l_cert_new_from_der;
 	l_cert_free;
diff --git a/ell/uuid.c b/ell/uuid.c
index a4d72fc..d590487 100644
--- a/ell/uuid.c
+++ b/ell/uuid.c
@@ -224,3 +224,37 @@ LIB_EXPORT bool l_uuid_to_string(const uint8_t uuid[16=
],
 =

 	return true;
 }
+
+LIB_EXPORT bool l_uuid_from_string(const char *src, uint8_t uuid[16])
+{
+	uint8_t buf[16];
+	int n;
+
+	/*
+	 * textual representation: 32 hex digits + 4 group separators
+	 */
+	if (strlen(src) < 16 * 2 + 4)
+		return false;
+
+	n =3D sscanf(src,
+			"%02hhx%02hhx%02hhx%02hhx-"
+			"%02hhx%02hhx-"
+			"%02hhx%02hhx-"
+			"%02hhx%02hhx-"
+			"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx",
+			&buf[0], &buf[1], &buf[2], &buf[3],
+			&buf[4], &buf[5],
+			&buf[6], &buf[7],
+			&buf[8], &buf[9],
+			&buf[10], &buf[11], &buf[12],
+			&buf[13], &buf[14], &buf[15]);
+
+	if (n !=3D 16)
+		return false;
+
+	if (!l_uuid_is_valid(buf))
+		return false;
+
+	memcpy(uuid, buf, sizeof(buf));
+	return true;
+}
diff --git a/ell/uuid.h b/ell/uuid.h
index 89be520..cb59b78 100644
--- a/ell/uuid.h
+++ b/ell/uuid.h
@@ -53,6 +53,7 @@ bool l_uuid_is_valid(const uint8_t uuid[16]);
 enum l_uuid_version l_uuid_get_version(const uint8_t uuid[16]);
 =

 bool l_uuid_to_string(const uint8_t uuid[16], char *dest, size_t dest_size=
);
+bool l_uuid_from_string(const char *src, uint8_t uuid[16]);
 =

 #ifdef __cplusplus
 }
diff --git a/unit/test-uuid.c b/unit/test-uuid.c
index 088d45c..7a6010d 100644
--- a/unit/test-uuid.c
+++ b/unit/test-uuid.c
@@ -158,6 +158,65 @@ static void test_to_string(const void *data)
 	assert(!strcmp(buf, expected_uuid));
 }
 =

+static void test_from_string_too_short(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7d";
+	bool r;
+
+	r =3D l_uuid_from_string(string_uuid, uuid);
+	assert(!r);
+}
+
+static void test_from_string_too_long(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7detoolong";
+	uint8_t expected_uuid[16] =3D { 0x65, 0xfc, 0xc6, 0x97, 0x07, 0x76, 0x5b,=
 0xf9,
+		                          0x85, 0x73, 0x72, 0xa5, 0x10, 0x80, 0xc7, 0xde=
 };
+
+	bool r;
+
+	r =3D l_uuid_from_string(string_uuid, uuid);
+	assert(r);
+
+	assert(!memcmp(uuid, expected_uuid, sizeof(uuid)));
+}
+
+static void test_from_string_invalid_variant(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-c573-72a51080c7de";
+	bool r;
+
+	r =3D l_uuid_from_string(string_uuid, uuid);
+	assert(!r);
+}
+
+static void test_from_string_invalid_hex(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-this-isno-tava-lidhexstring";
+	bool r;
+
+	r =3D l_uuid_from_string(string_uuid, uuid);
+	assert(!r);
+}
+
+static void test_from_string(const void *data)
+{
+	uint8_t uuid[16];
+	bool r;
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7de";
+	uint8_t expected_uuid[16] =3D { 0x65, 0xfc, 0xc6, 0x97, 0x07, 0x76, 0x5b,=
 0xf9,
+		                          0x85, 0x73, 0x72, 0xa5, 0x10, 0x80, 0xc7, 0xde=
 };
+
+	r =3D l_uuid_from_string(string_uuid, uuid);
+	assert(r);
+
+	assert(!memcmp(uuid, expected_uuid, sizeof(uuid)));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -169,6 +228,11 @@ int main(int argc, char *argv[])
 =

 	l_test_add("/uuid/v5", test_v5, NULL);
 	l_test_add("/uuid/to string", test_to_string, NULL);
+	l_test_add("/uuid/from string", test_from_string, NULL);
+	l_test_add("/uuid/from string/too short", test_from_string_too_short, NUL=
L);
+	l_test_add("/uuid/from string/too long", test_from_string_too_long, NULL);
+	l_test_add("/uuid/from string/invalid variant", test_from_string_invalid_=
variant, NULL);
+	l_test_add("/uuid/from string/invalid hex", test_from_string_invalid_hex,=
 NULL);
 =

 	return l_test_run();
 =

-- =

2.19.1


--===============9064344636965311953==--

