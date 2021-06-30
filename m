Content-Type: multipart/mixed; boundary="===============9220783461368851176=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] util: Add l_streq0
Date: Wed, 30 Jun 2021 20:51:08 +0200
Message-ID: <20210630185108.263533-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210630185108.263533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9220783461368851176==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a glib/nm-utils -style utility for comparing two strings that
handles NULL values (unlike strcmp).  Two NULL strings are treated as
equal.
---
 ell/util.c | 13 +++++++++++++
 ell/util.h |  1 +
 2 files changed, 14 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 531b49e..5fb1a43 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -342,6 +342,19 @@ LIB_EXPORT bool l_str_has_suffix(const char *str, cons=
t char *suffix)
 	return !strcmp(&str[len_diff], suffix);
 }
 =

+/**
+ * l_streq0:
+ * @a: First operand
+ * @b: Second operand
+ *
+ * Returns: True if @a and @b are both NULL or both non-NULL and identical
+ * according to strcmp.  False otherwise.
+ */
+LIB_EXPORT bool l_streq0(const char *a, const char *b)
+{
+	return a =3D=3D b || (a && b && !strcmp(a, b));
+}
+
 static char *hexstring_common(const unsigned char *buf, size_t len,
 				const char hexdigits[static 16])
 {
diff --git a/ell/util.h b/ell/util.h
index bdf6935..d56c2a5 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -276,6 +276,7 @@ size_t l_strlcpy(char* dst, const char *src, size_t len=
);
 =

 bool l_str_has_prefix(const char *str, const char *prefix);
 bool l_str_has_suffix(const char *str, const char *suffix);
+bool l_streq0(const char *a, const char *b);
 =

 char *l_util_hexstring(const unsigned char *buf, size_t len);
 char *l_util_hexstring_upper(const unsigned char *buf, size_t len);
-- =

2.30.2

--===============9220783461368851176==--

