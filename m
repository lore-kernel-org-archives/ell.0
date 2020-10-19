Content-Type: multipart/mixed; boundary="===============1679188136059103415=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v5 01/12] util: add l_memeq/l_memeqzero
Date: Mon, 19 Oct 2020 16:28:03 -0700
Message-ID: <20201019232814.1541221-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1679188136059103415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Utility functions for testing if memory equals a byte, or zero.
---
 ell/ell.sym |  2 ++
 ell/util.h  | 16 ++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 5268b48..0b0a6cc 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -20,6 +20,8 @@ global:
 	l_util_hexdumpv;
 	l_util_debug;
 	l_util_get_debugfs_path;
+	l_memeq;
+	l_memeqzero;
 	/* test */
 	l_test_init;
 	l_test_run;
diff --git a/ell/util.h b/ell/util.h
index ca894c7..a8b52ad 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -391,6 +391,22 @@ static inline int l_secure_memcmp(const void *a, const=
 void *b,
 	return res;
 }
 =

+static inline bool l_memeq(const uint8_t *field, size_t size, uint8_t byte)
+{
+	size_t i;
+
+	for (i =3D 0; i < size; i++)
+		if (field[i] !=3D byte)
+			return false;
+
+	return true;
+}
+
+static inline bool l_memeqzero(const uint8_t *field, size_t size)
+{
+	return l_memeq(field, size, 0);
+}
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.26.2

--===============1679188136059103415==--

