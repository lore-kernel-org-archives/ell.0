Content-Type: multipart/mixed; boundary="===============2666634377472843261=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/3] unit: Fix buffer overrun in test-pbkdf2
Date: Fri, 27 Jul 2018 14:27:51 -0700
Message-ID: <20180727212752.20497-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180727212752.20497-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2666634377472843261==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The overrun was in the unit test itself, not the pbkdf2 implementation.
---
 unit/test-pbkdf2.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
index f1b13ea..ad9c47c 100644
--- a/unit/test-pbkdf2.c
+++ b/unit/test-pbkdf2.c
@@ -45,8 +45,7 @@ static void pbkdf2_test(const void *data)
 	unsigned int salt_len;
 	unsigned int key_len;
 	unsigned char output[25];
-	char key[50];
-	unsigned int i;
+	char *key;
 	bool result;
 =

 	password_len =3D strlen(test->password);
@@ -67,12 +66,13 @@ static void pbkdf2_test(const void *data)
 =

 	assert(result =3D=3D true);
 =

-	for (i =3D 0; i < key_len; i++)
-		sprintf(key + (i * 2), "%02x", output[i]);
+	key =3D l_util_hexstring(output, key_len);
 =

 	printf("Result   =3D %s\n", key);
 =

 	assert(strcmp(test->key, key) =3D=3D 0);
+
+	l_free(key);
 }
 =

 static const struct pbkdf2_data pbkdf2_test_vector_1 =3D {
-- =

2.18.0


--===============2666634377472843261==--

