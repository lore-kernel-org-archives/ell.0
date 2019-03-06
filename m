Content-Type: multipart/mixed; boundary="===============0849156077467442717=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/2] uintset: Add l_uintset_foreach
Date: Wed, 06 Mar 2019 14:03:10 -0800
Message-ID: <20190306220311.18897-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0849156077467442717==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Enables an efficient traversal through the numbers in the set.
---
 ell/uintset.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 ell/uintset.h |  7 ++++++-
 2 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/ell/uintset.c b/ell/uintset.c
index 1d96e68..3f20098 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2015-2019  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
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
@@ -404,3 +447,25 @@ LIB_EXPORT uint32_t l_uintset_find_min(struct l_uintse=
t *set)
 =

 	return bit + set->min;
 }
+
+/**
+ * l_uintset_foreach:
+ * @set: The set of numbers
+ * @function: callback function
+ * @user_data: user data given to callback function
+ *
+ * Call @function for every given number in @set.
+ **/
+LIB_EXPORT void l_uintset_foreach(struct l_uintset *set,
+					l_uintset_foreach_func_t function,
+					void *user_data)
+{
+	unsigned int bit;
+
+	if (unlikely(!set || !function))
+		return;
+
+	for (bit =3D find_first_bit(set->bits, set->size); bit < set->size;
+			bit =3D find_next_bit(set->bits, set->size, bit + 1))
+		function(set->min + bit, user_data);
+}
diff --git a/ell/uintset.h b/ell/uintset.h
index 474c5e4..dd03cd7 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -2,7 +2,7 @@
  *
  *  Embedded Linux library
  *
- *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *  Copyright (C) 2015-2019  Intel Corporation. All rights reserved.
  *
  *  This library is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU Lesser General Public
@@ -31,6 +31,8 @@ extern "C" {
 #include <stddef.h>
 #include <stdbool.h>
 =

+typedef void (*l_uintset_foreach_func_t) (uint32_t number, void *user_data=
);
+
 struct l_uintset;
 =

 struct l_uintset *l_uintset_new_from_range(uint32_t min, uint32_t max);
@@ -50,6 +52,9 @@ uint32_t l_uintset_find_min(struct l_uintset *set);
 uint32_t l_uintset_find_unused_min(struct l_uintset *set);
 uint32_t l_uintset_find_unused(struct l_uintset *set, uint32_t start);
 =

+void l_uintset_foreach(struct l_uintset *set,
+			l_uintset_foreach_func_t function, void *user_data);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.13.6


--===============0849156077467442717==--

