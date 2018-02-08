Content-Type: multipart/mixed; boundary="===============1658800594055293576=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Fix typo in pbkdf2 output
Date: Wed, 07 Feb 2018 17:20:46 -0800
Message-ID: <20180208012046.28396-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1658800594055293576==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-pbkdf2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
index c970abe..f1b13ea 100644
--- a/unit/test-pbkdf2.c
+++ b/unit/test-pbkdf2.c
@@ -54,12 +54,12 @@ static void pbkdf2_test(const void *data)
 =

 	key_len =3D test->key_len ? : (strlen(test->key) / 2);
 =

-	printf("Password =3D \"%s\" (%d octects)\n",
+	printf("Password =3D \"%s\" (%d octets)\n",
 					test->password, password_len);
-	printf("Salt     =3D \"%s\" (%d octects)\n",
+	printf("Salt     =3D \"%s\" (%d octets)\n",
 					test->salt, salt_len);
 	printf("Count    =3D %d\n", test->count);
-	printf("Key      =3D %s (%d octects)\n", test->key, key_len);
+	printf("Key      =3D %s (%d octets)\n", test->key, key_len);
 =

 	result =3D l_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
 				(const uint8_t *) test->salt, salt_len,
-- =

2.16.1


--===============1658800594055293576==--

