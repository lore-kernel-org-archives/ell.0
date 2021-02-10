Content-Type: multipart/mixed; boundary="===============4132081724311133751=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] util: Add a constant time version of l_memeq
Date: Thu, 11 Feb 2021 00:36:57 +0100
Message-ID: <20210210233659.270554-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4132081724311133751==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/util.c  | 12 ++++++++++++
 ell/util.h  |  1 +
 3 files changed, 14 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index aa0c046..9938216 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -21,6 +21,7 @@ global:
 	l_util_debug;
 	l_util_get_debugfs_path;
 	l_memeq;
+	l_secure_memeq;
 	/* test */
 	l_test_init;
 	l_test_run;
diff --git a/ell/util.c b/ell/util.c
index 6896bc8..5b443a9 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -652,3 +652,15 @@ LIB_EXPORT bool l_memeq(const void *field, size_t size=
, uint8_t byte)
 =

 	return true;
 }
+
+LIB_EXPORT bool l_secure_memeq(const void *field, size_t size, uint8_t byt=
e)
+{
+	const volatile uint8_t *mem =3D field;
+	size_t i;
+	bool diff =3D false;
+
+	for (i =3D 0; i < size; i++)
+		diff |=3D mem[i] !=3D byte;
+
+	return !diff;
+}
diff --git a/ell/util.h b/ell/util.h
index 11708c2..b112878 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -412,6 +412,7 @@ static inline int l_secure_memcmp(const void *a, const =
void *b,
 }
 =

 bool l_memeq(const void *field, size_t size, uint8_t byte);
+bool l_secure_memeq(const void *field, size_t size, uint8_t byte);
 =

 static inline bool l_memeqzero(const void *field, size_t size)
 {
-- =

2.27.0

--===============4132081724311133751==--

