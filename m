Content-Type: multipart/mixed; boundary="===============8843445056914050415=="
MIME-Version: 1.0
From: Markus Ongyerth <ongy@ongy.net>
Subject: [PATCH 1/2] Add l_utf8_get_codepoint to string
Date: Sun, 11 Dec 2016 15:48:06 +0100
Message-ID: <20161211144807.25441-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8843445056914050415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a function to get an unicode codepoint from a utf-8 string.
This can be used to convert strings to other representations.
Also rewrite the l_utf8_validdate to use the new function.
---
 ell/string.c | 86 +++++++++++++++++++++++++++++++++++++++-----------------=
----
 ell/string.h |  2 ++
 2 files changed, 58 insertions(+), 30 deletions(-)

diff --git a/ell/string.c b/ell/string.c
index 6c443d0..0ae099c 100644
--- a/ell/string.c
+++ b/ell/string.c
@@ -345,6 +345,58 @@ static inline bool __attribute__ ((always_inline))
 }
 =

 /**
+ * l_utf8_get_codepoint
+ * @str: a pointer to codepoint data
+ * @len: maximum bytes to read
+ * @cp: destination for codepoint
+ *
+ * Returns: number of bytes read, or -1 for invalid coddepoint
+ **/
+LIB_EXPORT int l_utf8_get_codepoint(const char *str, size_t len, wchar_t *=
cp)
+{
+	static const int mins[3] =3D { 1 << 7, 1 << 11, 1 << 16 };
+	unsigned int expect_bytes;
+	wchar_t val;
+	size_t i;
+
+	if (str[0] > 0) {
+		*cp =3D str[0];
+		return 1;
+	}
+
+	expect_bytes =3D __builtin_clz(~(str[0] << 24));
+
+	if (expect_bytes < 2 || expect_bytes > 4)
+		goto error;
+
+	if (expect_bytes > len)
+		goto error;
+
+	val =3D str[0] & (0xff >> (expect_bytes + 1));
+
+	for (i =3D 1; i < expect_bytes; i++) {
+		if ((str[i] & 0xc0) =3D=3D 0)
+			goto error;
+
+		val <<=3D 6;
+		val |=3D str[i] & 0x3f;
+	}
+
+	if (val < mins[expect_bytes - 2])
+		goto error;
+
+	if (valid_unicode(val) =3D=3D false)
+		goto error;
+
+	*cp =3D val;
+	return expect_bytes;
+
+error:
+	*cp =3D 0;
+	return -1;
+}
+
+/**
  * l_utf8_validate:
  * @str: a pointer to character data
  * @len: max bytes to validate
@@ -359,43 +411,17 @@ static inline bool __attribute__ ((always_inline))
  **/
 LIB_EXPORT bool l_utf8_validate(const char *str, size_t len, const char **=
end)
 {
-	static const int mins[3] =3D { 1 << 7, 1 << 11, 1 << 16 };
 	size_t pos =3D 0;
-	unsigned int expect_bytes;
+	int ret;
 	wchar_t val;
-	size_t i;
 =

 	while (pos < len && str[pos]) {
-		if (str[pos] > 0) {
-			pos +=3D 1;
-			continue;
-		}
-
-		expect_bytes =3D __builtin_clz(~(str[pos] << 24));
-
-		if (expect_bytes < 2 || expect_bytes > 4)
-			goto error;
-
-		if (pos + expect_bytes > len)
-			goto error;
-
-		val =3D str[pos] & (0xff >> (expect_bytes + 1));
-
-		for (i =3D pos + 1; i < pos + expect_bytes; i++) {
-			if ((str[i] & 0xc0) =3D=3D 0)
-				goto error;
-
-			val <<=3D 6;
-			val |=3D str[i] & 0x3f;
-		}
-
-		if (val < mins[expect_bytes - 2])
-			goto error;
+		ret =3D l_utf8_get_codepoint(str + pos, len - pos, &val);
 =

-		if (valid_unicode(val) =3D=3D false)
+		if (ret < 0)
 			goto error;
 =

-		pos +=3D expect_bytes;
+		pos +=3D ret;
 	}
 =

 error:
diff --git a/ell/string.h b/ell/string.h
index 6549a05..09e6f2d 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -25,6 +25,7 @@
 =

 #include <stdbool.h>
 #include <stdarg.h>
+#include <wchar.h>
 =

 #ifdef __cplusplus
 extern "C" {
@@ -117,6 +118,7 @@ struct l_string *l_string_truncate(struct l_string *str=
ing, size_t new_size);
 unsigned int l_string_length(struct l_string *string);
 =

 bool l_utf8_validate(const char *src, size_t len, const char **end);
+int l_utf8_get_codepoint(const char *str, size_t len, wchar_t *cp);
 size_t l_utf8_strlen(const char *src);
 =

 #ifdef __cplusplus
-- =

2.10.2


--===============8843445056914050415==--

