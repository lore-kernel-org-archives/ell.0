Content-Type: multipart/mixed; boundary="===============5393966004630582157=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] uintset: add l_uintset_isempty
Date: Mon, 16 Sep 2019 10:24:24 -0700
Message-ID: <20190916172424.8159-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5393966004630582157==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym   |  1 +
 ell/uintset.c | 21 +++++++++++++++++++++
 ell/uintset.h |  1 +
 3 files changed, 23 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index d54a874..05f2d75 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -461,6 +461,7 @@ global:
 	l_uintset_find_min;
 	l_uintset_foreach;
 	l_uintset_intersect;
+	l_uintset_isempty;
 	/* uuid */
 	l_uuid_v3;
 	l_uuid_v5;
diff --git a/ell/uintset.c b/ell/uintset.c
index 60a9822..50119a0 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -506,3 +506,24 @@ LIB_EXPORT struct l_uintset *l_uintset_intersect(const=
 struct l_uintset *set_a,
 =

 	return intersection;
 }
+
+/**
+ * l_uintset_isempty
+ * @set: The set of numbers
+ *
+ * Returns true if the uintset has no entries, or if set is NULL.
+ */
+LIB_EXPORT bool l_uintset_isempty(const struct l_uintset *set)
+{
+	uint16_t i;
+
+	if (unlikely(!set))
+		return true;
+
+	for (i =3D 0; i < set->size; i++) {
+		if (set->bits[i])
+			return false;
+	}
+
+	return true;
+}
diff --git a/ell/uintset.h b/ell/uintset.h
index c05a21b..8215def 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -57,6 +57,7 @@ void l_uintset_foreach(struct l_uintset *set,
 =

 struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
 						const struct l_uintset *set_b);
+bool l_uintset_isempty(const struct l_uintset *set);
 =

 #ifdef __cplusplus
 }
-- =

2.17.1


--===============5393966004630582157==--

