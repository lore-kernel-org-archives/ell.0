Content-Type: multipart/mixed; boundary="===============2633382047256105832=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 14:46:18 +0100
Message-ID: <20190201134617.28831-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2633382047256105832==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>

This commit adds API complementary to l_uuid_to_string, allowing parsing
canonical string representation into a byte array.

I've also changed printf/scanf formatting to use PRIx/SCNx macros, for
better portability.
---
 ell/uuid.c       | 54 ++++++++++++++++++++++++++++++++++++-------
 ell/uuid.h       |  1 +
 unit/test-uuid.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 107 insertions(+), 8 deletions(-)

diff --git a/ell/uuid.c b/ell/uuid.c
index a4d72fc..26893a5 100644
--- a/ell/uuid.c
+++ b/ell/uuid.c
@@ -25,6 +25,7 @@
 #endif
 =

 #define _GNU_SOURCE
+#include <inttypes.h>
 #include <stdio.h>
 =

 #include "checksum.h"
@@ -210,17 +211,54 @@ LIB_EXPORT bool l_uuid_to_string(const uint8_t uuid[1=
6],
 {
 	int n;
 =

-	n =3D snprintf(dest, dest_size, "%02x%02x%02x%02x-%02x%02x-%02x%02x-"
-					"%02x%02x-%02x%02x%02x%02x%02x%02x",
-					uuid[0], uuid[1], uuid[2], uuid[3],
-					uuid[4], uuid[5],
-					uuid[6], uuid[7],
-					uuid[8], uuid[9],
-					uuid[10], uuid[11], uuid[12],
-					uuid[13], uuid[14], uuid[15]);
+	n =3D snprintf(dest, dest_size,
+			"%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "-"
+			"%02" PRIx8 "%02" PRIx8 "-"
+			"%02" PRIx8 "%02" PRIx8 "-"
+			"%02" PRIx8 "%02" PRIx8 "-"
+			"%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8 "%02" PRIx8=
 "",
+			uuid[0], uuid[1], uuid[2], uuid[3],
+			uuid[4], uuid[5],
+			uuid[6], uuid[7],
+			uuid[8], uuid[9],
+			uuid[10], uuid[11], uuid[12], uuid[13], uuid[14], uuid[15]);
 =

 	if (n < 0 || (size_t) n >=3D dest_size)
 		return false;
 =

 	return true;
 }
+
+LIB_EXPORT bool l_uuid_parse(const char *src, size_t src_size,
+							 uint8_t uuid[16])
+{
+	uint8_t buf[16];
+	int n;
+
+	/*
+	 * textual representation: 32 hex digits + 4 group separators
+	 */
+	if (src_size !=3D 16 * 2 + 4)
+		return false;
+
+	n =3D sscanf(src,
+			"%02" SCNx8 "%02" SCNx8 "%02" SCNx8 "%02" SCNx8 "-"
+			"%02" SCNx8 "%02" SCNx8 "-"
+			"%02" SCNx8 "%02" SCNx8 "-"
+			"%02" SCNx8 "%02" SCNx8 "-"
+			"%02" SCNx8 "%02" SCNx8 "%02" SCNx8 "%02" SCNx8 "%02" SCNx8 "%02" SCNx8=
 "",
+			&buf[0], &buf[1], &buf[2], &buf[3],
+			&buf[4], &buf[5],
+			&buf[6], &buf[7],
+			&buf[8], &buf[9],
+			&buf[10], &buf[11], &buf[12], &buf[13], &buf[14], &buf[15]);
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
index 89be520..1cb7923 100644
--- a/ell/uuid.h
+++ b/ell/uuid.h
@@ -53,6 +53,7 @@ bool l_uuid_is_valid(const uint8_t uuid[16]);
 enum l_uuid_version l_uuid_get_version(const uint8_t uuid[16]);
 =

 bool l_uuid_to_string(const uint8_t uuid[16], char *dest, size_t dest_size=
);
+bool l_uuid_parse(const char *src, size_t src_size, uint8_t uuid[16]);
 =

 #ifdef __cplusplus
 }
diff --git a/unit/test-uuid.c b/unit/test-uuid.c
index 088d45c..5a4650d 100644
--- a/unit/test-uuid.c
+++ b/unit/test-uuid.c
@@ -158,6 +158,61 @@ static void test_to_string(const void *data)
 	assert(!strcmp(buf, expected_uuid));
 }
 =

+static void test_parse_too_short(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7d";
+	bool r;
+
+	r =3D l_uuid_parse(string_uuid, strlen(string_uuid), uuid);
+	assert(!r);
+}
+
+static void test_parse_too_long(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7detoolong";
+	bool r;
+
+	r =3D l_uuid_parse(string_uuid, strlen(string_uuid), uuid);
+	assert(!r);
+}
+
+static void test_parse_invalid_variant(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-0776-5bf9-c573-72a51080c7de";
+	bool r;
+
+	r =3D l_uuid_parse(string_uuid, strlen(string_uuid), uuid);
+	assert(!r);
+}
+
+static void test_parse_invalid_hex(const void *data)
+{
+	uint8_t uuid[16];
+	const char *string_uuid =3D "65fcc697-this-isno-tava-lidhexstring";
+	bool r;
+
+	r =3D l_uuid_parse(string_uuid, strlen(string_uuid), uuid);
+	assert(!r);
+}
+
+static void test_parse(const void *data)
+{
+	uint8_t uuid[16];
+	bool r;
+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7de";
+	uint8_t expected_uuid[16] =3D { 0x65, 0xfc, 0xc6, 0x97, 0x07, 0x76, 0x5b,=
 0xf9,
+		                          0x85, 0x73, 0x72, 0xa5, 0x10, 0x80, 0xc7, 0xde=
 };
+
+	r =3D l_uuid_parse(string_uuid, strlen(string_uuid), uuid);
+	assert(r);
+
+	assert(!memcmp(uuid, expected_uuid, sizeof(uuid)));
+
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -169,6 +224,11 @@ int main(int argc, char *argv[])
 =

 	l_test_add("/uuid/v5", test_v5, NULL);
 	l_test_add("/uuid/to string", test_to_string, NULL);
+	l_test_add("/uuid/parse too short", test_parse_too_short, NULL);
+	l_test_add("/uuid/parse too long", test_parse_too_long, NULL);
+	l_test_add("/uuid/parse invalid variant", test_parse_invalid_variant, NUL=
L);
+	l_test_add("/uuid/parse invalid hex", test_parse_invalid_hex, NULL);
+	l_test_add("/uuid/parse", test_parse, NULL);
 =

 	return l_test_run();
 =

-- =

2.19.1


--===============2633382047256105832==--

