Content-Type: multipart/mixed; boundary="===============2879955583967866835=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Thu, 04 Mar 2021 22:53:58 +0100
Message-ID: <20210304215358.838251-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2879955583967866835==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

L_AUTO_FREE_OBJ can be used for ell object types that define a
destructor named l_<type>_free such as l_settings_free().  The "FREE" in
the name hopefully is enough to communicate this.

Some of our classes use l_<type>_destroy and similar names and some of
those functions, like l_queue_destroy, take additional parameters so for
those classes if a similar "AUTO" macros is wanted, it may be better
defined directly in that class's header.

l_steal_ptr is similar to g_steal_pointer except for being a macro.
Both macros can be used like in this example:

struct l_settings *load_settings(const char *path)
{
	L_AUTO_FREE_OBJ(l_settings, s) =3D l_settings_new();

	if (!l_settings_load_from_file(s, path))
		return NULL;

	return l_steal_ptr(s);
}
---
This is an RFC.  L_AUTO_FREE_OBJ is based on James's idea.

 ell/util.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index b112878..94a4178 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -235,6 +235,11 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 #define L_AUTO_FREE_VAR(vartype,varname) \
 	vartype varname __attribute__((cleanup(auto_free)))
 =

+#define L_AUTO_FREE_OBJ(l_type,varname) \
+	void varname ## _auto_free(void *_ptr)		\
+		{ l_type ## _free(*(void **) _ptr); }	\
+	L_AUTO_CLEANUP_VAR(struct l_type *, varname, varname ## _auto_free)
+
 #define L_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 =

 void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
@@ -276,6 +281,9 @@ static inline size_t minsize(size_t a, size_t b)
 		__p;				\
 	}))
 =

+#define l_steal_ptr(ptr)	\
+	(__extension__ ({ typeof(ptr) *_tmp =3D (ptr); (ptr) =3D NULL; _tmp; }))
+
 char *l_strdup(const char *str);
 char *l_strndup(const char *str, size_t max);
 char *l_strdup_printf(const char *format, ...)
-- =

2.27.0

--===============2879955583967866835==--

