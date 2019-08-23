Content-Type: multipart/mixed; boundary="===============7534806004322944202=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/8] strv: Implement l_strv_copy
Date: Fri, 23 Aug 2019 02:41:35 +0200
Message-ID: <20190823004138.5480-5-andrew.zaborowski@intel.com>
In-Reply-To: <20190823004138.5480-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7534806004322944202==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/strv.c | 24 ++++++++++++++++++++++++
 ell/strv.h |  1 +
 2 files changed, 25 insertions(+)

diff --git a/ell/strv.c b/ell/strv.c
index cd6467f..7c7dbf5 100644
--- a/ell/strv.c
+++ b/ell/strv.c
@@ -335,3 +335,27 @@ LIB_EXPORT char **l_strv_append_vprintf(char **str_arr=
ay,
 =

 	return ret;
 }
+
+/**
+ * l_strv_copy:
+ * @str_array: a %NULL terminated array of strings or %NULL
+ *
+ * Returns: An independent copy of @str_array.
+ */
+LIB_EXPORT char **l_strv_copy(char **str_array)
+{
+	int i, len;
+	char **copy;
+
+	if (unlikely(!str_array))
+		return NULL;
+
+	for (len =3D 0; str_array[len]; len++);
+
+	copy =3D l_malloc(sizeof(char *) * (len + 1));
+
+	for (i =3D len; i >=3D 0; i--)
+		copy[i] =3D l_strdup(str_array[i]);
+
+	return copy;
+}
diff --git a/ell/strv.h b/ell/strv.h
index 11d023a..b0ec17c 100644
--- a/ell/strv.h
+++ b/ell/strv.h
@@ -41,6 +41,7 @@ char **l_strv_append_printf(char **str_array, const char =
*format, ...)
 					__attribute__((format(printf, 2, 3)));
 char **l_strv_append_vprintf(char **str_array, const char *format,
 							va_list args);
+char **l_strv_copy(char **str_array);
 =

 #ifdef __cplusplus
 }
-- =

2.20.1


--===============7534806004322944202==--

