Content-Type: multipart/mixed; boundary="===============2691829214901284926=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/3] unit: Remove verbose output from test-pbkdf2
Date: Fri, 27 Jul 2018 14:27:52 -0700
Message-ID: <20180727212752.20497-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180727212752.20497-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2691829214901284926==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The test was printing control characters in the salt value for one test
case, but the verbose output for passing tests wasn't needed anyway.
---
 unit/test-pbkdf2.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
index ad9c47c..37d87ed 100644
--- a/unit/test-pbkdf2.c
+++ b/unit/test-pbkdf2.c
@@ -41,25 +41,16 @@ struct pbkdf2_data {
 static void pbkdf2_test(const void *data)
 {
 	const struct pbkdf2_data *test =3D data;
-	unsigned int password_len;
 	unsigned int salt_len;
 	unsigned int key_len;
 	unsigned char output[25];
 	char *key;
 	bool result;
 =

-	password_len =3D strlen(test->password);
 	salt_len =3D test->salt_len ? : strlen(test->salt);
 =

 	key_len =3D test->key_len ? : (strlen(test->key) / 2);
 =

-	printf("Password =3D \"%s\" (%d octets)\n",
-					test->password, password_len);
-	printf("Salt     =3D \"%s\" (%d octets)\n",
-					test->salt, salt_len);
-	printf("Count    =3D %d\n", test->count);
-	printf("Key      =3D %s (%d octets)\n", test->key, key_len);
-
 	result =3D l_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
 				(const uint8_t *) test->salt, salt_len,
 				test->count, output, key_len);
@@ -68,8 +59,6 @@ static void pbkdf2_test(const void *data)
 =

 	key =3D l_util_hexstring(output, key_len);
 =

-	printf("Result   =3D %s\n", key);
-
 	assert(strcmp(test->key, key) =3D=3D 0);
 =

 	l_free(key);
-- =

2.18.0


--===============2691829214901284926==--

