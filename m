Content-Type: multipart/mixed; boundary="===============4833634411653018251=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] unit: Add l_strlcpy tests
Date: Fri, 22 Sep 2017 15:12:43 -0700
Message-ID: <20170922221244.12670-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170922221244.12670-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4833634411653018251==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-util.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index 427c74a..d2b5496 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -74,6 +74,45 @@ static void test_has_suffix(const void *test_data)
 	assert(!l_str_has_suffix(suffix, str));
 }
 =

+static void do_strlcpy(size_t dst_bytes, size_t src_bytes)
+{
+	/* A valid address is needed for the destination buffer
+	 * even if l_strlcpy is told to not copy anything there
+	 */
+	char *dst =3D l_malloc(dst_bytes ?: 1);
+	char *src =3D l_malloc(src_bytes);
+	size_t src_strlen =3D src_bytes - 1;
+
+	memset(dst, ' ', dst_bytes ?: 1);
+	memset(src, '@', src_strlen);
+	src[src_strlen] =3D '\0';
+
+	assert(l_strlcpy(dst, src, dst_bytes) =3D=3D src_strlen);
+
+	if (!dst_bytes) {
+		assert(*dst =3D=3D ' ');
+	} else if (src_strlen >=3D dst_bytes) {
+		/* Copy was truncated */
+		assert(strlen(dst) =3D=3D dst_bytes - 1);
+		assert(l_str_has_prefix(src, dst));
+	} else
+		assert(!strcmp(src, dst));
+
+	l_free(dst);
+	l_free(src);
+}
+
+static void test_strlcpy(const void *test_data)
+{
+	do_strlcpy(0, 1);
+	do_strlcpy(0, 10);
+	do_strlcpy(10, 8);
+	do_strlcpy(10, 9);
+	do_strlcpy(10, 10);
+	do_strlcpy(10, 11);
+	do_strlcpy(10, 12);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -83,5 +122,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("l_util_has_suffix", test_has_suffix, NULL);
 =

+	l_test_add("l_strlcpy", test_strlcpy, NULL);
+
 	return l_test_run();
 }
-- =

2.14.1


--===============4833634411653018251==--

