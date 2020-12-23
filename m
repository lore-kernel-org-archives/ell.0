Content-Type: multipart/mixed; boundary="===============4203814246675023315=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] util: Add L_IN_SET macros
Date: Thu, 24 Dec 2020 00:14:32 +0100
Message-ID: <20201223231437.1078130-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201223231437.1078130-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4203814246675023315==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This can be used as in L_IN_SET(err, -EIO, -EINVAL) and with enum types
and I'm also adding an L_IN_STRSET() for string comparisons.  This
macro is not equivalent to (x =3D=3D (val1) || x =3D=3D (val2) || ...)
because val2 will be evaluated even if (x =3D=3D (val1)) was true.  There
seems to be no way to avoid that without adding another numbr of macros
dependent on the maximum number of arguments expected.  The "x" in the
above example is evaluated once.

We may have to add a warning about everything being cast to the type of
the "x", I'm not sure how important of a problem this is.
---
 ell/util.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index 0b3e1a8..15cf0d7 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -315,6 +315,26 @@ const char *l_util_get_debugfs_path(void);
        while (__result =3D=3D -1L && errno =3D=3D EINTR);  \
        __result; }))
 =

+#define _L_IN_SET_CMP(val, cmp, ...) __extension__ ({		\
+		__auto_type __v =3D (val);			\
+		typeof(__v) __elems[] =3D {__VA_ARGS__};		\
+		unsigned int __i;				\
+		unsigned int __n =3D L_ARRAY_SIZE(__elems);	\
+		bool __r =3D false;				\
+		for (__i =3D 0; __i < __n && !__r; __i++)		\
+			__r =3D (cmp);				\
+		__r;						\
+	})
+
+/* Warning: evaluates all set elements even after @val has matched one */
+#define L_IN_SET(val, ...)	\
+	_L_IN_SET_CMP((val), __v =3D=3D __elems[__i], ##__VA_ARGS__)
+
+#define L_IN_STRSET(val, ...)				\
+	_L_IN_SET_CMP((val), __v =3D=3D __elems[__i] ||	\
+			(__v && __elems[__i] &&		\
+			 !strcmp(__v, __elems[__i])), ##__VA_ARGS__)
+
 /*
  * Taken from https://github.com/chmike/cst_time_memcmp, adding a volatile=
 to
  * ensure the compiler does not try to optimize the constant time behavior.
-- =

2.27.0

--===============4203814246675023315==--

