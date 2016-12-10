Content-Type: multipart/mixed; boundary="===============8948533840674819556=="
MIME-Version: 1.0
From: Markus Ongyerth <ongy@ongy.net>
Subject: [PATCH 2/2] Add testcase for MD4 hash
Date: Sat, 10 Dec 2016 09:44:57 +0100
Message-ID: <20161210084457.12774-2-ongy@ongy.net>
In-Reply-To: <20161210084457.12774-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8948533840674819556==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ell@ongy.net>

---
 unit/test-checksum.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/unit/test-checksum.c b/unit/test-checksum.c
index 156bf85..c1527a3 100644
--- a/unit/test-checksum.c
+++ b/unit/test-checksum.c
@@ -42,6 +42,26 @@ static void test_unsupported(const void *data)
 	assert(!checksum);
 }
 =

+static void test_md4(const void *data)
+{
+	struct l_checksum *checksum;
+	unsigned char digest[16];
+	char *str;
+
+	checksum =3D l_checksum_new(L_CHECKSUM_MD4);
+	assert(checksum);
+
+	l_checksum_update(checksum, FIXED_STR, FIXED_LEN);
+
+	l_checksum_get_digest(checksum, digest, sizeof(digest));
+
+	str =3D l_checksum_get_string(checksum);
+	l_info("%s", str);
+	l_free(str);
+
+	l_checksum_free(checksum);
+}
+
 static void test_md5(const void *data)
 {
 	struct l_checksum *checksum;
@@ -162,6 +182,8 @@ int main(int argc, char *argv[])
 =

 	l_test_add("unsupported", test_unsupported, NULL);
 =

+	l_test_add("md4-1", test_md4, NULL);
+
 	l_test_add("md5-1", test_md5, NULL);
 =

 	l_test_add("sha1-1", test_sha1, NULL);
-- =

2.10.2


--===============8948533840674819556==--

