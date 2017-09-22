Content-Type: multipart/mixed; boundary="===============3588370504018464554=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/4] util: Add l_strlcpy
Date: Fri, 22 Sep 2017 15:12:42 -0700
Message-ID: <20170922221244.12670-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170922221244.12670-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3588370504018464554==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/util.c | 32 ++++++++++++++++++++++++++++++++
 ell/util.h |  2 ++
 2 files changed, 34 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 98916e5..2879f9f 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -443,6 +443,38 @@ LIB_EXPORT bool l_str_has_prefix(const char *str, cons=
t char *prefix)
 	return !strncmp(str, prefix, prefix_len);
 }
 =

+/**
+ * l_strlcpy:
+ * @dst: Destination buffer for string
+ * @src: Source buffer containing null-terminated string to copy
+ * @len: Maximum destination buffer space to use
+ *
+ * Copies a string from the @src buffer to the @dst buffer, using no
+ * more than @len bytes in @dst. @dst is guaranteed to be
+ * null-terminated. The caller can determine if the copy was truncated by
+ * checking if the return value is greater than or equal to @len.
+ *
+ * Returns: The length of the @src string, not including the null
+ * terminator.
+ */
+LIB_EXPORT size_t l_strlcpy(char* dst, const char *src, size_t len)
+{
+	size_t src_len =3D strlen(src);
+
+	if (len) {
+		if (src_len < len) {
+			len =3D src_len + 1;
+		} else {
+			len -=3D 1;
+			dst[len] =3D '\0';
+		}
+
+		memcpy(dst, src, len);
+	}
+
+	return src_len;
+}
+
 /**
  * l_str_has_suffix:
  * @str: A string to be examined
diff --git a/ell/util.h b/ell/util.h
index a77c0b8..126a172 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -222,6 +222,8 @@ char *l_strjoinv(char **str_array, const char delim);
 bool l_str_has_prefix(const char *str, const char *prefix);
 bool l_str_has_suffix(const char *str, const char *suffix);
 =

+size_t l_strlcpy(char* dst, const char *src, size_t len);
+
 char *l_util_hexstring(const unsigned char *buf, size_t len);
 unsigned char *l_util_from_hexstring(const char *str, size_t *out_len);
 =

-- =

2.14.1


--===============3588370504018464554==--

