Content-Type: multipart/mixed; boundary="===============0946082409469009540=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 5/5] unit: Make checksum unit tests verify checksum results
Date: Tue, 11 Jul 2017 16:05:01 -0700
Message-ID: <20170711230501.5419-6-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170711230501.5419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0946082409469009540==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The checksum unit tests were reading the digest results from the kernel
twice, and the second read was returning garbage data. Remove the second
read and the associated printing, and instead check the calculated
digest against a known-good value.
---
 unit/test-checksum.c | 66 +++++++++++++++++++++++++++---------------------=
----
 1 file changed, 34 insertions(+), 32 deletions(-)

diff --git a/unit/test-checksum.c b/unit/test-checksum.c
index 09d0ced..296395f 100644
--- a/unit/test-checksum.c
+++ b/unit/test-checksum.c
@@ -46,7 +46,8 @@ static void test_md4(const void *data)
 {
 	struct l_checksum *checksum;
 	unsigned char digest[16];
-	char *str;
+	unsigned char *expected;
+	size_t expectlen;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_MD4);
 	assert(checksum);
@@ -55,10 +56,12 @@ static void test_md4(const void *data)
 =

 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	str =3D l_checksum_get_string(checksum);
-	l_info("%s", str);
-	l_free(str);
+	expected =3D l_util_from_hexstring("be3de05811bec433af48270014a8df0e",
+						&expectlen);
+	assert(expectlen =3D=3D sizeof(digest));
+	assert(!memcmp(digest, expected, expectlen));
 =

+	l_free(expected);
 	l_checksum_free(checksum);
 }
 =

@@ -66,7 +69,8 @@ static void test_md5(const void *data)
 {
 	struct l_checksum *checksum;
 	unsigned char digest[16];
-	char *str;
+	unsigned char *expected;
+	size_t expectlen;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_MD5);
 	assert(checksum);
@@ -75,10 +79,12 @@ static void test_md5(const void *data)
 =

 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	str =3D l_checksum_get_string(checksum);
-	l_info("%s", str);
-	l_free(str);
+	expected =3D l_util_from_hexstring("407b72260377f77f8e63e13dc09bda2c",
+						&expectlen);
+	assert(expectlen =3D=3D sizeof(digest));
+	assert(!memcmp(digest, expected, expectlen));
 =

+	l_free(expected);
 	l_checksum_free(checksum);
 }
 =

@@ -86,7 +92,8 @@ static void test_sha1(const void *data)
 {
 	struct l_checksum *checksum;
 	unsigned char digest[20];
-	char *str;
+	unsigned char *expected;
+	size_t expectlen;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_SHA1);
 	assert(checksum);
@@ -95,10 +102,12 @@ static void test_sha1(const void *data)
 =

 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	str =3D l_checksum_get_string(checksum);
-	l_info("%s", str);
-	l_free(str);
+	expected =3D l_util_from_hexstring(
+		"8802f1d217906250585b75187b1ebfbb5c6cbcae", &expectlen);
+	assert(expectlen =3D=3D sizeof(digest));
+	assert(!memcmp(digest, expected, expectlen));
 =

+	l_free(expected);
 	l_checksum_free(checksum);
 }
 =

@@ -106,7 +115,8 @@ static void test_sha256(const void *data)
 {
 	struct l_checksum *checksum;
 	unsigned char digest[32];
-	char *str;
+	unsigned char *expected;
+	size_t expectlen;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_SHA256);
 	assert(checksum);
@@ -115,10 +125,13 @@ static void test_sha256(const void *data)
 =

 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	str =3D l_checksum_get_string(checksum);
-	l_info("%s", str);
-	l_free(str);
+	expected =3D l_util_from_hexstring(
+		"df3a0c35d5345d6d792415c1310bd458"
+		"9cdf68bac96ed599d6bb0c1545ffc86c", &expectlen);
+	assert(expectlen =3D=3D sizeof(digest));
+	assert(!memcmp(digest, expected, expectlen));
 =

+	l_free(expected);
 	l_checksum_free(checksum);
 }
 =

@@ -126,7 +139,6 @@ static void test_reset(const void *data)
 {
 	struct l_checksum *checksum;
 	unsigned char digest[16];
-	char *str;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_MD5);
 	assert(checksum);
@@ -136,27 +148,21 @@ static void test_reset(const void *data)
 	l_checksum_update(checksum, FIXED_STR, FIXED_LEN);
 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	str =3D l_checksum_get_string(checksum);
-	l_info("%s", str);
-	l_free(str);
-
 	l_checksum_free(checksum);
 }
 =

 static void test_updatev(const void *data)
 {
 	struct l_checksum *checksum;
-	unsigned char digest[20];
+	unsigned char digest1[20];
+	unsigned char digest2[20];
 	struct iovec iov[2];
-	char *str;
-	char *str2;
 =

 	checksum =3D l_checksum_new(L_CHECKSUM_SHA1);
 	assert(checksum);
 =

 	l_checksum_update(checksum, FIXED_STR, FIXED_LEN);
-	l_checksum_get_digest(checksum, digest, sizeof(digest));
-	str =3D l_checksum_get_string(checksum);
+	l_checksum_get_digest(checksum, digest1, sizeof(digest1));
 =

 	iov[0].iov_base =3D FIXED_STR;
 	iov[0].iov_len =3D FIXED_LEN / 2;
@@ -165,13 +171,9 @@ static void test_updatev(const void *data)
 	iov[1].iov_len =3D FIXED_LEN - FIXED_LEN / 2;
 =

 	l_checksum_updatev(checksum, iov, 2);
-	l_checksum_get_digest(checksum, digest, sizeof(digest));
-	str2 =3D l_checksum_get_string(checksum);
-
-	assert(!strcmp(str, str2));
+	l_checksum_get_digest(checksum, digest2, sizeof(digest2));
 =

-	l_free(str);
-	l_free(str2);
+	assert(!memcmp(digest1, digest2, sizeof(digest1)));
 =

 	l_checksum_free(checksum);
 }
-- =

2.13.2


--===============0946082409469009540==--

