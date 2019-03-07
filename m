Content-Type: multipart/mixed; boundary="===============4883403769362044080=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/2] uintset: Add l_uintset_intersect
Date: Wed, 06 Mar 2019 16:17:06 -0800
Message-ID: <20190307001707.22395-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4883403769362044080==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_uintset_intersect computes the intersection of two sets
of an equal base.
---
 ell/uintset.c | 37 +++++++++++++++++++++++++++++++++++++
 ell/uintset.h |  3 +++
 2 files changed, 40 insertions(+)

diff --git a/ell/uintset.c b/ell/uintset.c
index 3f20098..60a9822 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -469,3 +469,40 @@ LIB_EXPORT void l_uintset_foreach(struct l_uintset *se=
t,
 			bit =3D find_next_bit(set->bits, set->size, bit + 1))
 		function(set->min + bit, user_data);
 }
+
+/**
+ * l_uintset_intersect:
+ * @set_a: The set of numbers
+ * @set_b: The set of numbers
+ *
+ * Intersects the two sets of numbers of an equal base, e.g.:
+ * l_uintset_get_min(set_a) must be equal to l_uintset_get_min(set_b) and
+ * l_uintset_get_max(set_a) must be equal to l_uintset_get_max(set_b)
+ *
+ * Returns: A newly allocated l_uintset object containing the intersection=
 of
+ * @set_a and @set_b. If the bases are not equal returns NULL. If either @=
set_a
+ * or @set_b is NULL returns NULL.
+ **/
+LIB_EXPORT struct l_uintset *l_uintset_intersect(const struct l_uintset *s=
et_a,
+						const struct l_uintset *set_b)
+{
+	struct l_uintset *intersection;
+	uint32_t offset;
+	uint32_t offset_max;
+
+	if (unlikely(!set_a || !set_b))
+		return NULL;
+
+	if (unlikely(set_a->min !=3D set_b->min || set_a->max !=3D set_b->max))
+		return NULL;
+
+	intersection =3D l_uintset_new_from_range(set_a->min, set_a->max);
+
+	offset_max =3D (set_a->size + BITS_PER_LONG - 1) / BITS_PER_LONG;
+
+	for (offset =3D 0; offset < offset_max; offset++)
+		intersection->bits[offset] =3D
+				set_a->bits[offset] & set_b->bits[offset];
+
+	return intersection;
+}
diff --git a/ell/uintset.h b/ell/uintset.h
index dd03cd7..c05a21b 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -55,6 +55,9 @@ uint32_t l_uintset_find_unused(struct l_uintset *set, uin=
t32_t start);
 void l_uintset_foreach(struct l_uintset *set,
 			l_uintset_foreach_func_t function, void *user_data);
 =

+struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
+						const struct l_uintset *set_b);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.13.6


--===============4883403769362044080==--

