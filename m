Content-Type: multipart/mixed; boundary="===============6893343931153305697=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] util: Silence warnings from strict compiler settings
Date: Tue, 23 Oct 2018 16:34:59 -0700
Message-ID: <20181023233459.18708-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20181023233459.18708-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6893343931153305697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the standardized __func__ symbol instead of gcc's
__PRETTY_FUNCTION__ alias, and add the __extension__ keyword for
braced-groups within expressions. This allows use of more strict
compiler settings in ELL-based programs.
---
 ell/util.c | 12 ++++++------
 ell/util.h |  6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/ell/util.c b/ell/util.c
index c021a83..4d74ced 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -64,7 +64,7 @@ LIB_EXPORT void *l_malloc(size_t size)
 			return ptr;
 =

 		fprintf(stderr, "%s:%s(): failed to allocate %zd bytes\n",
-					STRLOC, __PRETTY_FUNCTION__, size);
+					STRLOC, __func__, size);
 		abort();
 	}
 =

@@ -94,7 +94,7 @@ LIB_EXPORT void *l_realloc(void *mem, size_t size)
 			return ptr;
 =

 		fprintf(stderr, "%s:%s(): failed to re-allocate %zd bytes\n",
-					STRLOC, __PRETTY_FUNCTION__, size);
+					STRLOC, __func__, size);
 		abort();
 	} else
 		l_free(mem);
@@ -154,7 +154,7 @@ LIB_EXPORT char *l_strdup(const char *str)
 			return tmp;
 =

 		fprintf(stderr, "%s:%s(): failed to allocate string\n",
-						STRLOC, __PRETTY_FUNCTION__);
+						STRLOC, __func__);
 		abort();
 	}
 =

@@ -182,7 +182,7 @@ LIB_EXPORT char *l_strndup(const char *str, size_t max)
 			return tmp;
 =

 		fprintf(stderr, "%s:%s(): failed to allocate string\n",
-						STRLOC, __PRETTY_FUNCTION__);
+						STRLOC, __func__);
 		abort();
 	}
 =

@@ -208,7 +208,7 @@ LIB_EXPORT char *l_strdup_printf(const char *format, ..=
.)
 =

 	if (len < 0) {
 		fprintf(stderr, "%s:%s(): failed to allocate string\n",
-					STRLOC, __PRETTY_FUNCTION__);
+					STRLOC, __func__);
 		abort();
 =

 		return NULL;
@@ -233,7 +233,7 @@ LIB_EXPORT char *l_strdup_vprintf(const char *format, v=
a_list args)
 =

 	if (len < 0) {
 		fprintf(stderr, "%s:%s(): failed to allocate string\n",
-					STRLOC, __PRETTY_FUNCTION__);
+					STRLOC, __func__);
 		abort();
 =

 		return NULL;
diff --git a/ell/util.h b/ell/util.h
index e42d751..7bfcbfa 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -41,11 +41,11 @@ extern "C" {
 #define L_STRINGIFY(val) L_STRINGIFY_ARG(val)
 #define L_STRINGIFY_ARG(contents) #contents
 =

-#define L_WARN_ON(condition) ({						\
+#define L_WARN_ON(condition) __extension__ ({				\
 		bool r =3D !!(condition);					\
 		if (unlikely(r))					\
 			l_warn("WARNING: %s:%s() condition %s failed",	\
-				__FILE__, __PRETTY_FUNCTION__,		\
+				__FILE__, __func__,			\
 				#condition);				\
 		unlikely(r);						\
 	})
@@ -56,7 +56,7 @@ extern "C" {
 #define L_PTR_TO_INT(p) ((int) ((intptr_t) (p)))
 #define L_INT_TO_PTR(u) ((void *) ((intptr_t) (u)))
 =

-#define L_GET_UNALIGNED(ptr)			\
+#define L_GET_UNALIGNED(ptr) __extension__	\
 ({						\
 	struct __attribute__((packed)) {	\
 		typeof(*(ptr)) __v;		\
-- =

2.19.1


--===============6893343931153305697==--

