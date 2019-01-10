Content-Type: multipart/mixed; boundary="===============8069396351609723044=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] util: Add conversion util for uppercase hex string
Date: Thu, 10 Jan 2019 14:32:12 -0800
Message-ID: <20190110223212.8137-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8069396351609723044==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/util.c | 22 ++++++++++++++++++++++
 ell/util.h |  1 +
 2 files changed, 23 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 31aa0c3..b68bbb8 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -365,6 +365,28 @@ LIB_EXPORT char *l_util_hexstring(const unsigned char =
*buf, size_t len)
 }
 =

 /**
+ * l_util_hexstring_upper:
+ * @buf: buffer pointer
+ * @len: length of buffer
+ *
+ * Returns: a newly allocated uppercase hex string
+ **/
+LIB_EXPORT char *l_util_hexstring_upper(const unsigned char *buf, size_t l=
en)
+{
+	char *str;
+	char *p;
+
+	str =3D l_util_hexstring(buf, len);
+	if (!str)
+		return NULL;
+
+	for (p =3D str; *p !=3D '\0'; p++)
+		*p =3D toupper(*p);
+
+	return str;
+}
+
+/**
  * l_util_from_hexstring:
  * @str: Null-terminated string containing the hex-encoded bytes
  * @out_len: Number of bytes decoded
diff --git a/ell/util.h b/ell/util.h
index c31d36b..de4df74 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -276,6 +276,7 @@ bool l_str_has_prefix(const char *str, const char *pref=
ix);
 bool l_str_has_suffix(const char *str, const char *suffix);
 =

 char *l_util_hexstring(const unsigned char *buf, size_t len);
+char *l_util_hexstring_upper(const unsigned char *buf, size_t len);
 unsigned char *l_util_from_hexstring(const char *str, size_t *out_len);
 =

 typedef void (*l_util_hexdump_func_t) (const char *str, void *user_data);
-- =

2.13.6


--===============8069396351609723044==--

