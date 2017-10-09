Content-Type: multipart/mixed; boundary="===============2911973129882017469=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] unit: Add PBKDF2 tests from iwd
Date: Mon, 09 Oct 2017 11:46:59 +0200
Message-ID: <20171009094659.5793-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2911973129882017469==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Test l_pkcs5_pbkdf2 using test data from iwd with the exception of the
test case that contained a \0 inside the password string.
---
 .gitignore         |   1 +
 Makefile.am        |   5 +-
 unit/test-pbkdf2.c | 206 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 3 files changed, 211 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-pbkdf2.c

diff --git a/.gitignore b/.gitignore
index 8d7c374..369bbe9 100644
--- a/.gitignore
+++ b/.gitignore
@@ -53,6 +53,7 @@ unit/test-tls
 unit/test-pem
 unit/test-uuid
 unit/test-key
+unit/test-pbkdf2
 unit/cert-*.pem
 unit/cert-*.csr
 unit/cert-*.srl
diff --git a/Makefile.am b/Makefile.am
index 98c06ca..9b4ca06 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -133,7 +133,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-util \
 			unit/test-uintset \
 			unit/test-base64 \
-			unit/test-uuid
+			unit/test-uuid \
+			unit/test-pbkdf2
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
@@ -234,6 +235,8 @@ unit_test_uintset_LDADD =3D ell/libell-private.la
 =

 unit_test_base64_LDADD =3D ell/libell-private.la
 =

+unit_test_pbkdf2_LDADD =3D ell/libell-private.la
+
 unit_test_pem_LDADD =3D ell/libell-private.la
 unit_test_pem_DEPENDENCIES =3D $(cert_files)
 =

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
new file mode 100644
index 0000000..7d087c8
--- /dev/null
+++ b/unit/test-pbkdf2.c
@@ -0,0 +1,206 @@
+/*
+ *
+ *  Wireless daemon for Linux
+ *
+ *  Copyright (C) 2013-2014  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <stdio.h>
+#include <string.h>
+#include <assert.h>
+#include <ell/ell.h>
+
+struct pbkdf2_data {
+	const char *password;
+	const char *salt;
+	unsigned int salt_len;
+	unsigned int count;
+	unsigned int key_len;
+	const char *key;
+};
+
+static void pbkdf2_test(const void *data)
+{
+	const struct pbkdf2_data *test =3D data;
+	unsigned int password_len;
+	unsigned int salt_len;
+	unsigned int key_len;
+	unsigned char output[25];
+	char key[50];
+	unsigned int i;
+	bool result;
+
+	password_len =3D strlen(test->password);
+	salt_len =3D test->salt_len ? : strlen(test->salt);
+
+	key_len =3D test->key_len ? : (strlen(test->key) / 2);
+
+	printf("Password =3D \"%s\" (%d octects)\n",
+					test->password, password_len);
+	printf("Salt     =3D \"%s\" (%d octects)\n",
+					test->salt, salt_len);
+	printf("Count    =3D %d\n", test->count);
+	printf("Key      =3D %s (%d octects)\n", test->key, key_len);
+
+	result =3D l_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
+				(const uint8_t *) test->salt, salt_len,
+				test->count, output, key_len);
+
+	assert(result =3D=3D true);
+
+	for (i =3D 0; i < key_len; i++)
+		sprintf(key + (i * 2), "%02x", output[i]);
+
+	printf("Result   =3D %s\n", key);
+
+	assert(strcmp(test->key, key) =3D=3D 0);
+}
+
+static const struct pbkdf2_data pbkdf2_test_vector_1 =3D {
+	.password	=3D "password",
+	.salt		=3D "salt",
+	.count		=3D 1,
+	.key		=3D "0c60c80f961f0e71f3a9b524af6012062fe037a6",
+	.key_len	=3D 20,
+};
+
+static const struct pbkdf2_data pbkdf2_test_vector_2 =3D {
+	.password	=3D "password",
+	.salt		=3D "salt",
+	.count		=3D 2,
+	.key		=3D "ea6c014dc72d6f8ccd1ed92ace1d41f0d8de8957",
+	.key_len	=3D 20,
+};
+
+static const struct pbkdf2_data pbkdf2_test_vector_3 =3D {
+	.password	=3D "password",
+	.salt		=3D "salt",
+	.count		=3D 4096,
+	.key		=3D "4b007901b765489abead49d926f721d065a429c1",
+	.key_len	=3D 20,
+};
+
+static const struct pbkdf2_data pbkdf2_test_vector_4 =3D {
+	.password	=3D "password",
+	.salt		=3D "salt",
+	.count		=3D 16777216,
+	.key		=3D "eefe3d61cd4da4e4e9945b3d6ba2158c2634e984",
+	.key_len	=3D 20,
+};
+
+static const struct pbkdf2_data pbkdf2_test_vector_5 =3D {
+	.password	=3D "passwordPASSWORDpassword",
+	.salt		=3D "saltSALTsaltSALTsaltSALTsaltSALTsalt",
+	.count		=3D 4096,
+	.key		=3D "3d2eec4fe41c849b80c8d83662c0e44a8b291a964cf2f07038",
+	.key_len	=3D 25,
+};
+
+static const struct pbkdf2_data athena_test_vector_1 =3D {
+	.password	=3D "password",
+	.salt		=3D "ATHENA.MIT.EDUraeburn",
+	.count		=3D 1,
+	.key		=3D "cdedb5281bb2f801565a1122b2563515",
+};
+
+static const struct pbkdf2_data athena_test_vector_2 =3D {
+	.password	=3D "password",
+	.salt		=3D "ATHENA.MIT.EDUraeburn",
+	.count		=3D 2,
+	.key		=3D "01dbee7f4a9e243e988b62c73cda935d",
+};
+
+static const struct pbkdf2_data athena_test_vector_3 =3D {
+	.password	=3D "password",
+	.salt		=3D "ATHENA.MIT.EDUraeburn",
+	.count		=3D 1200,
+	.key		=3D "5c08eb61fdf71e4e4ec3cf6ba1f5512b",
+};
+
+static const struct pbkdf2_data athena_test_vector_4 =3D {
+	.password	=3D "password",
+	.salt		=3D "\x12\x34\x56\x78\x78\x56\x34\x12",
+	.count		=3D 5,
+	.key		=3D "d1daa78615f287e6a1c8b120d7062a49",
+};
+
+static const struct pbkdf2_data athena_test_vector_5 =3D {
+	.password	=3D "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
+			  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
+	.salt		=3D "pass phrase equals block size",
+	.count		=3D 1200,
+	.key		=3D "139c30c0966bc32ba55fdbf212530ac9",
+};
+
+static const struct pbkdf2_data athena_test_vector_6 =3D {
+	.password	=3D "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
+			  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
+	.salt		=3D "pass phrase exceeds block size",
+	.count		=3D 1200,
+	.key		=3D "9ccad6d468770cd51b10e6a68721be61",
+};
+
+static const struct pbkdf2_data athena_test_vector_7 =3D {
+	.password	=3D "\xf0\x9d\x84\x9e",	/* g-clef (0xf09d849e) */
+	.salt		=3D "EXAMPLE.COMpianist",
+	.count		=3D 50,
+	.key		=3D "6b9cf26d45455a43a5b8bb276a403b39",
+};
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	if (!l_checksum_is_supported(L_CHECKSUM_SHA1, true)) {
+		printf("SHA1 support missing, skipping...\n");
+		goto done;
+	}
+
+	l_test_add("/pbkdf2-sha1/PBKDF2 Test vector 1",
+					pbkdf2_test, &pbkdf2_test_vector_1);
+	l_test_add("/pbkdf2-sha1/PBKDF2 Test vector 2",
+					pbkdf2_test, &pbkdf2_test_vector_2);
+	l_test_add("/pbkdf2-sha1/PBKDF2 Test vector 3",
+					pbkdf2_test, &pbkdf2_test_vector_3);
+	l_test_add("/pbkdf2-sha1/PBKDF2 Test vector 4",
+					pbkdf2_test, &pbkdf2_test_vector_4);
+	l_test_add("/pbkdf2-sha1/PBKDF2 Test vector 5",
+					pbkdf2_test, &pbkdf2_test_vector_5);
+
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 1",
+					pbkdf2_test, &athena_test_vector_1);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 2",
+					pbkdf2_test, &athena_test_vector_2);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 3",
+					pbkdf2_test, &athena_test_vector_3);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 4",
+					pbkdf2_test, &athena_test_vector_4);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 5",
+					pbkdf2_test, &athena_test_vector_5);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 6",
+					pbkdf2_test, &athena_test_vector_6);
+	l_test_add("/pbkdf2-sha1/ATHENA Test vector 7",
+					pbkdf2_test, &athena_test_vector_7);
+
+done:
+	return l_test_run();
+}
-- =

2.11.0


--===============2911973129882017469==--

