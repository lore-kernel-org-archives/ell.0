Content-Type: multipart/mixed; boundary="===============2311798323709814856=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/2] uintset: Add l_uintset_intersect
Date: Tue, 05 Mar 2019 12:35:42 -0800
Message-ID: <20190305203543.1492-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2311798323709814856==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_uintset_intersect computes the intersection of two sets.
In addition, it introduces find_next_bit(=E2=80=A6) that is used to
efficiently loop through the set bits in the set and may have
multiple implication in the future.
---
 ell/uintset.c | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/uintset.h |  3 ++
 2 files changed, 99 insertions(+)

diff --git a/ell/uintset.c b/ell/uintset.c
index 1d96e68..6b657b8 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -122,6 +122,49 @@ static unsigned long find_last_bit(const unsigned long=
 *addr, unsigned int size)
 	return size;
 }
 =

+static unsigned long find_next_bit(const unsigned long *addr,
+							unsigned long size,
+							unsigned long bit)
+{
+	unsigned long mask;
+	unsigned long offset;
+
+	if (bit >=3D size)
+		return size;
+
+	addr +=3D bit / BITS_PER_LONG;
+	offset =3D bit % BITS_PER_LONG;
+	bit -=3D offset;
+
+	if (offset) {
+		mask =3D *addr & ~(~0UL >> (BITS_PER_LONG - offset));
+		if (mask)
+			return bit + __ffs(mask);
+
+		bit +=3D BITS_PER_LONG;
+		addr++;
+	}
+
+	for (size -=3D bit; size >=3D BITS_PER_LONG;
+			size -=3D BITS_PER_LONG, bit +=3D BITS_PER_LONG, addr++) {
+		if (!*addr)
+			continue;
+
+		return bit + __ffs(*addr);
+	}
+
+	if (!size)
+		return bit;
+
+	mask =3D *addr & (~0UL >> (BITS_PER_LONG - size));
+	if (mask)
+		bit +=3D __ffs(mask);
+	else
+		bit +=3D size;
+
+	return bit;
+}
+
 struct l_uintset {
 	unsigned long *bits;
 	uint16_t size;
@@ -404,3 +447,56 @@ LIB_EXPORT uint32_t l_uintset_find_min(struct l_uintse=
t *set)
 =

 	return bit + set->min;
 }
+
+/**
+ * l_uintset_intersect:
+ * @set_a: The set of numbers
+ * @set_b: The set of numbers
+ *
+ * Returns: A newly allocated l_uintset object containing intersection of
+ * @set_a and @set_b. If @set_a and @set_b cannot be intersected returns N=
ULL.
+ * If either @set_a or @set_b is NULL returns NULL.
+ **/
+LIB_EXPORT struct l_uintset *l_uintset_intersect(const struct l_uintset *s=
et_a,
+						const struct l_uintset *set_b)
+{
+	struct l_uintset *intersection;
+	uint32_t min;
+	uint32_t max;
+	unsigned int bit_a;
+	unsigned int bit_b;
+
+	if (unlikely(!set_a) || unlikely(!set_b))
+		return NULL;
+
+	if (set_a->max < set_b->min || set_b->max < set_a->min)
+		return NULL;
+
+	min =3D set_a->min <=3D set_b->min ? set_a->min : set_b->min;
+	max =3D set_a->max >=3D set_b->max ? set_a->max : set_b->max;
+
+	intersection =3D l_uintset_new_from_range(min, max);
+
+	bit_a =3D find_first_bit(set_a->bits, set_a->size);
+	bit_b =3D find_first_bit(set_b->bits, set_b->size);
+
+	while (bit_a < set_a->size && bit_b < set_b->size) {
+		if (set_a->min + bit_a < set_b->min + bit_b) {
+			bit_a =3D find_next_bit(set_a->bits, set_a->size,
+								bit_a + 1);
+			continue;
+		}
+
+		if (set_a->min + bit_a > set_b->min + bit_b) {
+			bit_b =3D find_next_bit(set_b->bits, set_b->size,
+								bit_b + 1);
+			continue;
+		}
+
+		l_uintset_put(intersection, set_a->min + bit_a);
+		bit_a =3D find_next_bit(set_a->bits, set_a->size, bit_a + 1);
+		bit_b =3D find_next_bit(set_b->bits, set_b->size, bit_b + 1);
+	}
+
+	return intersection;
+}
diff --git a/ell/uintset.h b/ell/uintset.h
index 474c5e4..9986086 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -50,6 +50,9 @@ uint32_t l_uintset_find_min(struct l_uintset *set);
 uint32_t l_uintset_find_unused_min(struct l_uintset *set);
 uint32_t l_uintset_find_unused(struct l_uintset *set, uint32_t start);
 =

+struct l_uintset *l_uintset_intersect(const struct l_uintset *set_a,
+						const struct l_uintset *set_b);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.13.6


--===============2311798323709814856==--

