Content-Type: multipart/mixed; boundary="===============4457961506061317766=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Fri, 08 Jan 2021 02:13:22 +0100
Message-ID: <20210108011324.1551320-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4457961506061317766==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a generic buffer class that can extend to the left and to the right
as data is appended or prepended.  Nested buffers can also be added.
Building the complicated structures of nested genl attributes and also
various structures like 802.11 IEs passed in the contents of those
attributes is the motivation for this.

l_buf_new() and l_buf_append_new() take the amount of buffer space and
the number of nested buffers to pre-allocate but the user can go over
these values and the buffers will grow.  While the code looks a little
complicated most operations are actually simple when the buffers don't
need to grow.

I considered these few features, all of which would be nice to have
for l_genl_msg building for example, but, some of which are mutually
exclusive without blowing up the size of struct l_buf, the complexity
or the number of mallocs:

1. nested l_bufs can be added *at the head*, in addition to at the
   tail, of the parent l_buf.  (similar to how static data can be
   prepended or appended to the current l_buf)

2. multiple nested buffers of one parent can exist at the same time
   and be written into or have their own children added in random
   order.

3. l_buf contains enough information to detect when the initial
   @nested_cnt iovecs are exhausted, in l_buf_append_new().

4. on top of 3. the iov array automatically extends when the initial
   @nested_cnt iovecs are exhausted, in l_buf_append_new(), rather
   than return NULL.
   When the iov array extends parent/children nested l_bufs don't
   become invalid.

5. no extra "finalize" call is required after all data is written
   to all nested buffers and no tree structure needs to be flattened,
   the iov array is ready to use in a writev() at any time.

6. on top of 5. no l_buf_free() is needed for nested buffers.
   The number of l_buf_free calls matches the number of l_buf_new
   calls only.

This version sacrifices 1. and 2. for 3., 4., 5. and 6.
---
 Makefile.am |   6 +-
 ell/buf.c   | 192 ++++++++++++++++++++++++++++++++++++++
 ell/buf.h   | 258 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ell.h   |   1 +
 ell/ell.sym |   5 +
 5 files changed, 460 insertions(+), 2 deletions(-)
 create mode 100644 ell/buf.c
 create mode 100644 ell/buf.h

diff --git a/Makefile.am b/Makefile.am
index 2f9a4ce..93bbbf2 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -58,7 +58,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
-			ell/acd.h
+			ell/acd.h \
+			ell/buf.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -141,7 +142,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/path.c \
 			ell/icmp6.c \
 			ell/icmp6-private.h \
-			ell/acd.c
+			ell/acd.c \
+			ell/buf.c
 =

 ell_libell_la_LDFLAGS =3D -Wl,--no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/buf.c b/ell/buf.c
new file mode 100644
index 0000000..8900656
--- /dev/null
+++ b/ell/buf.c
@@ -0,0 +1,192 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2021  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <errno.h>
+
+#include "util.h"
+#include "private.h"
+#include "buf.h"
+
+LIB_EXPORT struct l_buf *l_buf_new(size_t headroom, size_t tailroom,
+					unsigned int nested_cnt)
+{
+	struct l_buf *buf;
+	unsigned int iov_cnt =3D 1 + nested_cnt;
+	struct iovec *alloced;
+
+	buf =3D l_malloc(sizeof(struct l_buf) +
+				iov_cnt * 2 * sizeof(struct iovec) +
+				headroom + tailroom);
+	buf->parent =3D NULL;
+	buf->child =3D NULL;
+	/* Point @used to the first byte after the end of the struct */
+	buf->used =3D buf->iovecs;
+	buf->used_cnt =3D 1;
+	/* Point @alloced to the first byte after the end of @used */
+	alloced =3D buf->used + iov_cnt;
+	buf->alloced_cnt =3D iov_cnt;
+	/* Point @alloced[0].iov_base to first byte after the end of @alloced */
+	alloced->iov_base =3D alloced + iov_cnt;
+	alloced->iov_len =3D headroom + tailroom;
+
+	buf->used->iov_base =3D alloced->iov_base + headroom;
+	buf->used->iov_len =3D 0;
+
+	return buf;
+}
+
+LIB_EXPORT bool l_buf_append_init(struct l_buf *buf, struct l_buf *parent,
+					size_t headroom, size_t tailroom)
+{
+	struct l_buf *base;
+
+	if (unlikely(!buf || !parent))
+		return false;
+
+	for (base =3D parent; base->parent; base =3D base->parent);
+
+	if (unlikely(base->used_cnt =3D=3D base->alloced_cnt)) {
+		struct iovec *old_used =3D base->used;
+		struct l_buf *i;
+
+		/* Allocate a bigger buffer for the used+allocated array */
+		base->alloced_cnt *=3D 2;
+
+		if (old_used =3D=3D base->iovecs) {
+			struct iovec *old_alloced =3D old_used + base->used_cnt;
+
+			/* Assign the now uneeded space to the first iovec */
+			if (old_alloced->iov_base =3D=3D
+					old_alloced + base->used_cnt) {
+				old_alloced->iov_base =3D old_used;
+				old_alloced->iov_len +=3D base->used_cnt * 2 *
+                                                sizeof(struct iovec);
+			}
+
+			base->used =3D l_malloc(base->alloced_cnt * 2 *
+						sizeof(struct iovec));
+			memcpy(base->used, old_used,
+				base->used_cnt * sizeof(struct iovec));
+			memcpy(base->used + base->alloced_cnt, old_alloced,
+				base->used_cnt * sizeof(struct iovec));
+		} else {
+			base->used =3D l_realloc(base->used, base->alloced_cnt *
+						2 * sizeof(struct iovec));
+			memcpy(base->used + base->alloced_cnt,
+				base->used + base->used_cnt,
+				base->used_cnt * sizeof(struct iovec));
+		}
+
+		/* Update all intermediate l_bufs */
+		for (i =3D parent; i !=3D base; i =3D i->parent) {
+			i->used =3D base->used + (i->used - old_used);
+			i->alloced_cnt =3D base->alloced_cnt;
+		}
+	}
+
+	buf->parent =3D parent;
+	buf->child =3D NULL;
+	buf->used =3D base->used + (base->used_cnt++);
+	buf->alloced_cnt =3D base->alloced_cnt;
+	return true;
+}
+
+LIB_EXPORT void l_buf_free(struct l_buf *buf)
+{
+	const void *static_iov_base;
+	const struct iovec *used;
+	const struct iovec *alloced;
+
+	if (unlikely(!buf || buf->parent))
+		return;
+
+	used =3D buf->used;
+	alloced =3D used + buf->alloced_cnt;
+
+	if (used =3D=3D buf->iovecs)
+		static_iov_base =3D alloced + buf->alloced_cnt;
+	else
+		static_iov_base =3D buf->iovecs;
+
+	for (; buf->used_cnt; buf->used_cnt--, used++, alloced++) {
+		explicit_bzero(used->iov_base, used->iov_len);
+
+		if (alloced->iov_base !=3D static_iov_base)
+			l_free(alloced->iov_base);
+	}
+
+	if (buf->used !=3D buf->iovecs)
+		l_free(buf->used);
+
+	do {
+		struct l_buf *child =3D buf->child;
+
+		l_free(buf);
+		buf =3D child;
+	} while (buf);
+}
+
+LIB_EXPORT void l_buf_extend(struct l_buf *buf, size_t bytes, bool at_head)
+{
+	struct iovec *cur =3D buf->used;
+	struct iovec *cur_alloced =3D cur + buf->alloced_cnt;
+	size_t headroom =3D cur->iov_base - cur_alloced->iov_base;
+	const void *static_iov_base;
+
+	if (!buf->parent) {
+		if (cur =3D=3D buf->iovecs)
+			static_iov_base =3D cur_alloced + buf->alloced_cnt;
+		else
+			static_iov_base =3D buf->iovecs;
+	} else
+		static_iov_base =3D NULL;
+
+	cur_alloced->iov_len +=3D bytes;
+
+	/* Use realloc only if it can save us the memcpy/memmove */
+	if (cur_alloced->iov_base !=3D static_iov_base && !at_head &&
+			cur->iov_len) {
+		cur_alloced->iov_base =3D
+			l_realloc(cur_alloced->iov_base, cur_alloced->iov_len);
+		cur->iov_base =3D cur_alloced->iov_base + headroom;
+	} else {
+		void *old_buf =3D cur_alloced->iov_base;
+
+		cur_alloced->iov_base =3D l_malloc(cur_alloced->iov_len);
+		cur->iov_base =3D cur_alloced->iov_base + headroom;
+
+		if (at_head)
+			cur->iov_base +=3D bytes;
+
+		if (cur->iov_len) {
+			memcpy(cur->iov_base, old_buf + headroom, cur->iov_len);
+			explicit_bzero(old_buf + headroom, cur->iov_len);
+		}
+
+		if (old_buf !=3D static_iov_base)
+			l_free(old_buf);
+	}
+}
diff --git a/ell/buf.h b/ell/buf.h
new file mode 100644
index 0000000..a3d64d3
--- /dev/null
+++ b/ell/buf.h
@@ -0,0 +1,258 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2021  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_BUF_H
+#define __ELL_BUF_H
+
+#include <sys/uio.h>
+#include <stdint.h>
+#include <stddef.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+/*
+ * At the low level this stores up to @alloced_cnt contiguous buffers or
+ * segments.  Within each segment there's a "used" part of the segment
+ * identified by the start pointer and the length.  There's also
+ * differentation between base l_bufs, that own the allocated memory,
+ * and nested l_bufs that point to their parent l_buf's segments.
+ *
+ * In the base l_buf, the @iovecs array contains 2 * @alloced_cnt iovecs.
+ * The last @alloced_cnt iovecs each point at the entirety of the
+ * corresponding segment's allocated memory while the first @alloced_cnt
+ * iovecs point at the "used" part of the corresponding segment.  Only
+ * segments from 0 to (@used_cnt - 1) have memory allocated.
+ *
+ * @used[0] is the "used" iovec for the "current" segment, i.e. anything
+ * between @used->iov_base and @used->iov_base + @used->iov_len.
+ * @used + @alloced_cnt points at the entirety of the "current" segment.
+ * Anything before @used->iov_base (and after @used[alloced_cnt].iov_base)
+ * is the headroom and anything after @used->iov_base + @used->iov_len
+ * (up to @used[alloced_cnt].iov_base + @used[alloced_cnt].iov_len) is
+ * the tailroom.  Initally the "used" part is empty, i.e. @used->iov_base
+ * points somewhere inside the allocated segment and @used->iov_len is 0.
+ * l_buf_prepend() is then used to expand it into the headroom and
+ * l_buf_append() to expand it into the tailroom, reducing the available
+ * room.  The headroom and tailroom of the allocated segments, and the
+ * @iov_base and @iov_len of the not-yet-allocated segments have
+ * uninitialized values.
+ *
+ * There's no way to change which segment is "current".  The segments
+ * after "current" are accessed by creating a nested l_buf using
+ * l_buf_append_init() and l_buf_append_new().  Its "current" segment is
+ * going to be different.  Segments are allocated their memory when they
+ * become the "current" segment of an l_buf.  That memory is not freed
+ * until the base l_buf is freed though.  Nested l_bufs can't be freed
+ * using l_buf_free, they're also automatically freed with the base l_buf.
+ * A nested l_buf and all its childred l_bufs also become invalid when
+ * a new call to l_buf_append_new() is made for the same parent l_buf or
+ * its ancestor.
+ */
+struct l_buf {
+	struct {
+		struct l_buf *parent;
+		struct l_buf *child;
+		struct iovec *used;
+		unsigned int alloced_cnt;
+	};
+	unsigned int used_cnt;
+	struct iovec iovecs[0];
+};
+
+struct l_buf *l_buf_new(size_t headroom, size_t tailroom,
+			unsigned int nested_cnt);
+bool l_buf_append_init(struct l_buf *buf, struct l_buf *parent,
+			size_t headroom, size_t tailroom);
+
+static inline struct l_buf *l_buf_append_new(struct l_buf *parent,
+						size_t headroom,
+						size_t tailroom)
+{
+	struct l_buf *ref_parent =3D parent;
+	struct l_buf *old_child;
+
+	if (unlikely(!parent))
+		return NULL;
+
+	/*
+	 * Find the first ancestor referenced by its .parent->child, i.e.
+	 * one that was allocated dynamically by l_buf_append_new().
+	 * That ancestor is going to hold the reference to the new l_buf
+	 * so that it can be automatically re-used and freed later.  Don't
+	 * link the new l_buf to a parent that is not part of the singly
+	 * linked list formed by the .child pointers, otherwise it'd leak.
+	 */
+	while (ref_parent->parent && ref_parent->parent->child !=3D ref_parent)
+		ref_parent =3D ref_parent->parent;
+
+	if (ref_parent->child)
+		/* Save previous child(ren) l_buf(s) for re-use */
+		old_child =3D ref_parent->child->child;
+	else {
+		ref_parent->child =3D l_malloc(offsetof(struct l_buf, used_cnt));
+		old_child =3D NULL;
+	}
+
+	/* Cannot fail when parent and parent->child are non-NULL */
+	l_buf_append_init(ref_parent->child, parent, headroom, tailroom);
+
+	ref_parent->child->child =3D old_child;
+	return parent->child;
+}
+
+void l_buf_free(struct l_buf *buf);
+void l_buf_extend(struct l_buf *buf, size_t bytes, bool at_head);
+
+static inline uint8_t *l_buf_get_headroom(struct l_buf *buf, size_t bytes)
+{
+	struct iovec *cur =3D buf->used;
+	struct iovec *cur_alloced =3D cur + buf->alloced_cnt;
+
+	if (cur->iov_base - bytes < cur_alloced->iov_base)
+		l_buf_extend(buf, cur_alloced->iov_base + bytes - cur->iov_base,
+				true);
+
+	cur->iov_base -=3D bytes;
+	cur->iov_len +=3D bytes;
+	return cur->iov_base;
+}
+
+static inline uint8_t *l_buf_get_tailroom(struct l_buf *buf, size_t bytes)
+{
+	struct iovec *cur =3D buf->used;
+	struct iovec *cur_alloced =3D cur + buf->alloced_cnt;
+	void *end =3D cur->iov_base + cur->iov_len;
+
+	if (end + bytes > cur_alloced->iov_base + cur_alloced->iov_len) {
+		l_buf_extend(buf, end + bytes -
+				cur_alloced->iov_base - cur_alloced->iov_len,
+				false);
+		end =3D cur->iov_base + cur->iov_len;
+	}
+
+	cur->iov_len +=3D bytes;
+	return end;
+}
+
+static inline void l_buf_prepend(struct l_buf *buf, const void *data,
+					size_t len)
+{
+	if (likely(len))
+		memcpy(l_buf_get_headroom(buf, len), data, len);
+}
+
+static inline void l_buf_append(struct l_buf *buf, const void *data, size_=
t len)
+{
+	if (likely(len))
+		memcpy(l_buf_get_tailroom(buf, len), data, len);
+}
+
+static inline void l_buf_prependv(struct l_buf *buf, const struct iovec *i=
ov,
+				unsigned int iov_cnt)
+{
+	while (iov_cnt) {
+		iov_cnt--;
+		l_buf_prepend(buf, iov[iov_cnt].iov_base, iov[iov_cnt].iov_len);
+	}
+}
+
+static inline void l_buf_appendv(struct l_buf *buf, const struct iovec *io=
v,
+				unsigned int iov_cnt)
+{
+	while (iov_cnt) {
+		iov_cnt--;
+		l_buf_append(buf, iov->iov_base, iov->iov_len);
+		iov++;
+	}
+}
+
+#define l_buf_prepends(buf, in) l_buf_prepend((buf), &(in), sizeof(in))
+#define l_buf_appends(buf, in) l_buf_append((buf), &(in), sizeof(in))
+
+static inline void l_buf_pad(struct l_buf *buf, uint8_t value, size_t len)
+{
+	if (likely(len))
+		memset(l_buf_get_tailroom(buf, len), value, len);
+}
+
+static inline size_t l_buf_get_len(const struct l_buf *buf)
+{
+	const struct l_buf *base;
+	unsigned int i;
+	size_t len =3D 0;
+
+	if (unlikely(!buf))
+		return 0;
+
+	for (base =3D buf; base->parent; base =3D base->parent);
+
+	for (i =3D buf->used - base->used; i < base->used_cnt; i++)
+		len +=3D base->used[i].iov_len;
+
+	return len;
+}
+
+static inline bool l_buf_put_headroom(struct l_buf *buf, size_t bytes)
+{
+	if (buf->used->iov_len < bytes)
+		return false;
+
+	buf->used->iov_base +=3D bytes;
+	buf->used->iov_len -=3D bytes;
+	return true;
+}
+
+static inline bool l_buf_put_tailroom(struct l_buf *buf, size_t bytes)
+{
+	if (buf->used->iov_len < bytes)
+		return false;
+
+	buf->used->iov_len -=3D bytes;
+	return true;
+}
+
+static inline uint8_t *l_buf_get_data(const struct l_buf *buf, size_t *out=
_len)
+{
+	size_t len =3D l_buf_get_len(buf);
+	uint8_t *data =3D l_malloc(len);
+	uint8_t *ptr =3D data;
+	int i;
+
+	if (out_len)
+		*out_len =3D len;
+
+	for (i =3D 0; len; i++) {
+		memcpy(ptr, buf->used[i].iov_base, buf->used[i].iov_len);
+		ptr +=3D buf->used[i].iov_len;
+		len -=3D buf->used[i].iov_len;
+	}
+
+	return data;
+}
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_BUF_H */
diff --git a/ell/ell.h b/ell/ell.h
index 22fddf7..ab8f0f0 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -64,3 +64,4 @@
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
+#include <ell/buf.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index aa0c046..8372e5f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -664,6 +664,11 @@ global:
 	l_acd_set_debug;
 	l_acd_set_skip_probes;
 	l_acd_set_defend_policy;
+	/* buf */
+	l_buf_new;
+	l_buf_append_init;
+	l_buf_free;
+	l_buf_extend;
 local:
 	*;
 };
-- =

2.27.0

--===============4457961506061317766==--

