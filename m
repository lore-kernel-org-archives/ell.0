Content-Type: multipart/mixed; boundary="===============4413902305884918346=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] unit: Add test for l_strv_append().
Date: Thu, 14 Feb 2019 12:45:48 -0800
Message-ID: <20190214204549.26138-2-ossama.othman@intel.com>
In-Reply-To: <20190214204549.26138-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4413902305884918346==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-string.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/unit/test-string.c b/unit/test-string.c
index c59a35f..710617b 100644
--- a/unit/test-string.c
+++ b/unit/test-string.c
@@ -253,6 +253,24 @@ static void test_strv_contains(const void *test_data)
 	assert(l_strv_contains(strv3, "Bar") =3D=3D true);
 }
 =

+static void test_strv_append(const void *test_data)
+{
+	const char *src[] =3D { "Foo", "Bar" };
+	char **dst =3D NULL;
+
+	size_t len =3D L_ARRAY_SIZE(src);
+
+	for (size_t i =3D 0; i < len; i++)
+		dst =3D l_strv_append(dst, src[i]);
+
+	assert(l_strv_length(dst) =3D=3D len);
+
+	for (size_t i =3D 0; i < len; i++)
+		assert(strcmp(src[i], dst[i]) =3D=3D 0);
+
+        l_strv_free(dst);
+}
+
 static void test_parse_args(const void *test_data)
 {
 	static struct test_case {
@@ -319,6 +337,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("strv_length", test_strv_length, NULL);
 	l_test_add("strv_contains", test_strv_contains, NULL);
+	l_test_add("strv_append", test_strv_append, NULL);
 =

 	l_test_add("parse_args", test_parse_args, NULL);
 =

-- =

2.17.1


--===============4413902305884918346==--

