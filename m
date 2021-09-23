Content-Type: multipart/mixed; boundary="===============7900020932776353516=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH] strv: Add l_strv_eq
Date: Thu, 23 Sep 2021 12:40:46 +0200
Message-ID: <20210923104046.54286-1-andrew.zaborowski@intel.com>

--===============7900020932776353516==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/strv.c  | 20 ++++++++++++++++++++
 ell/strv.h  |  1 +
 3 files changed, 22 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 9fcf334..10865af 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -40,6 +40,7 @@ global:
 	l_strv_append_printf;
 	l_strv_append_vprintf;
 	l_strv_copy;
+	l_strv_eq;
 	/* utf8 */
 	l_ascii_table;
 	l_utf8_get_codepoint;
diff --git a/ell/strv.c b/ell/strv.c
index 3df47be..1343519 100644
--- a/ell/strv.c
+++ b/ell/strv.c
@@ -359,3 +359,23 @@ LIB_EXPORT char **l_strv_copy(char **str_array)
 =

 	return copy;
 }
+
+/**
+ * l_strv_eq:
+ * @a: a %NULL terminated array of strings or %NULL
+ * @b: another %NULL terminated array of strings or %NULL
+ *
+ * Returns: Whether @a and @b's contents are identical, including the
+ * order, or @a and @b are both %NULL.
+ */
+LIB_EXPORT bool l_strv_eq(char **a, char **b)
+{
+	if (!a || !b)
+		return a =3D=3D b;
+
+	for (; *a; a++, b++)
+		if (!*b || strcmp(*a, *b))
+			return false;
+
+	return !*b;
+}
diff --git a/ell/strv.h b/ell/strv.h
index e673fec..db15cc7 100644
--- a/ell/strv.h
+++ b/ell/strv.h
@@ -46,6 +46,7 @@ char **l_strv_append_vprintf(char **str_array, const char=
 *format,
 							va_list args)
 					__attribute__((format(printf, 2, 0)));
 char **l_strv_copy(char **str_array);
+bool l_strv_eq(char **a, char **b);
 =

 #ifdef __cplusplus
 }
-- =

2.30.2

--===============7900020932776353516==--

