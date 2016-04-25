Content-Type: multipart/mixed; boundary="===============0311952655414265302=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH v2 1/2] util: Add suffix check for a string
Date: Mon, 25 Apr 2016 13:51:02 -0700
Message-ID: <1461617463-31883-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0311952655414265302==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/util.c | 32 ++++++++++++++++++++++++++++++++
 ell/util.h |  1 +
 2 files changed, 33 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index f920895..98916e5 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -444,6 +444,38 @@ LIB_EXPORT bool l_str_has_prefix(const char *str, cons=
t char *prefix)
 }
 =

 /**
+ * l_str_has_suffix:
+ * @str: A string to be examined
+ * @suffix: Suffix string
+ *
+ * Determines if the string given by @str ends with the specified @suffix.
+ *
+ * Returns: True if @str ends with the specified @suffix.  False otherwise.
+ */
+LIB_EXPORT bool l_str_has_suffix(const char *str, const char *suffix)
+{
+	size_t str_len;
+	size_t suffix_len;
+	size_t len_diff;
+
+	if (unlikely(!str))
+		return false;
+
+	if (unlikely(!suffix))
+		return false;
+
+	str_len =3D strlen(str);
+	suffix_len =3D strlen(suffix);
+
+	if (str_len < suffix_len)
+		return false;
+
+	len_diff =3D str_len - suffix_len;
+
+	return !strcmp(&str[len_diff], suffix);
+}
+
+/**
  * l_util_hexstring:
  * @buf: buffer pointer
  * @len: length of buffer
diff --git a/ell/util.h b/ell/util.h
index f6a88a0..92e7c8a 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -208,6 +208,7 @@ char **l_strsplit_set(const char *str, const char *sepa=
rators);
 char *l_strjoinv(char **str_array, const char delim);
 =

 bool l_str_has_prefix(const char *str, const char *prefix);
+bool l_str_has_suffix(const char *str, const char *suffix);
 =

 char *l_util_hexstring(const unsigned char *buf, size_t len);
 unsigned char *l_util_from_hexstring(const char *str, size_t *out_len);
-- =

2.5.0


--===============0311952655414265302==--

