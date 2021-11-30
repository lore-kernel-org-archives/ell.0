Content-Type: multipart/mixed; boundary="===============5548783879417052867=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 1/2] uintset: add l_uintset_size
Date: Tue, 30 Nov 2021 10:12:51 -0800
Message-ID: <20211130181252.428774-1-prestwoj@gmail.com>

--===============5548783879417052867==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This counts the number of set elements
---
 ell/ell.sym   |  1 +
 ell/uintset.c | 24 ++++++++++++++++++++++++
 ell/uintset.h |  1 +
 3 files changed, 26 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index d9b48ee..febb855 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -530,6 +530,7 @@ global:
 	l_uintset_clone;
 	l_uintset_intersect;
 	l_uintset_isempty;
+	l_uintset_size;
 	/* uuid */
 	l_uuid_v3;
 	l_uuid_v4;
diff --git a/ell/uintset.c b/ell/uintset.c
index 74de420..863bc56 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -555,3 +555,27 @@ LIB_EXPORT bool l_uintset_isempty(const struct l_uints=
et *set)
 =

 	return true;
 }
+
+/**
+ * l_uintset_size
+ *
+ * @set: The set of numbers
+ *
+ * Returns the number of set elements
+ */
+LIB_EXPORT uint32_t l_uintset_size(const struct l_uintset *set)
+{
+	uint16_t i;
+	uint32_t offset_max;
+	uint32_t count =3D 0;
+
+	if (unlikely(!set))
+		return 0;
+
+	offset_max =3D (set->size + BITS_PER_LONG - 1) / BITS_PER_LONG;
+
+	for (i =3D 0; i < offset_max; i++)
+		count +=3D __builtin_popcountl(set->bits[i]);
+
+	return count;
+}
diff --git a/ell/uintset.h b/ell/uintset.h
index 07ed778..aa9de48 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -61,6 +61,7 @@ struct l_uintset *l_uintset_clone(const struct l_uintset =
*original);
 struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
 						const struct l_uintset *set_b);
 bool l_uintset_isempty(const struct l_uintset *set);
+uint32_t l_uintset_size(const struct l_uintset *set);
 =

 #ifdef __cplusplus
 }
-- =

2.31.1

--===============5548783879417052867==--

