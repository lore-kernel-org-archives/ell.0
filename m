Content-Type: multipart/mixed; boundary="===============2064688046030050568=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/5] string: Add l_string_unwrap and simplify l_string_free
Date: Wed, 02 Nov 2016 14:50:44 -0700
Message-ID: <20161102215048.19166-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2064688046030050568==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This removes the "free a string object but return the internal data"
functionality of l_string_free. The option to not free everything was a
source of confusion.

l_string_unwrap is the same as the old l_string_free(ptr, false).
---
 ell/dbus-filter.c   |  4 ++--
 ell/dbus-service.c  |  2 +-
 ell/dbus-util.c     |  4 ++--
 ell/gvariant-util.c |  4 ++--
 ell/key.c           |  2 +-
 ell/settings.c      |  2 +-
 ell/string.c        | 32 +++++++++++++++++++++-----------
 ell/string.h        |  3 ++-
 8 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
index 9e3cad5..0af1b67 100644
--- a/ell/dbus-filter.c
+++ b/ell/dbus-filter.c
@@ -393,7 +393,7 @@ char *_dbus_filter_rule_to_str(const struct _dbus_filte=
r_condition *rule,
 					rule->type - L_DBUS_MATCH_ARG0);
 			break;
 		default:
-			l_string_free(str, true);
+			l_string_free(str);
 			return NULL;
 		}
 =

@@ -417,5 +417,5 @@ char *_dbus_filter_rule_to_str(const struct _dbus_filte=
r_condition *rule,
 			l_string_append_c(str, ',');
 	}
 =

-	return l_string_free(str, false);
+	return l_string_unwrap(str);
 }
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 98f6e7a..8bc9244 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1600,7 +1600,7 @@ bool _dbus_object_tree_dispatch(struct _dbus_object_t=
ree *tree,
 =

 		buf =3D l_string_new(0);
 		_dbus_object_tree_introspect(tree, path, buf);
-		xml =3D l_string_free(buf, false);
+		xml =3D l_string_unwrap(buf);
 =

 		reply =3D l_dbus_message_new_method_return(message);
 		l_dbus_message_set_arguments(reply, "s", xml);
diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index 1298228..c4e8419 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -901,7 +901,7 @@ void _dbus1_builder_free(struct dbus_builder *builder)
 	if (unlikely(!builder))
 		return;
 =

-	l_string_free(builder->signature, true);
+	l_string_free(builder->signature);
 	l_queue_destroy(builder->containers,
 				(l_queue_destroy_func_t) container_free);
 	l_free(builder->body);
@@ -1265,7 +1265,7 @@ char *_dbus1_builder_finish(struct dbus_builder *buil=
der,
 	if (unlikely(l_queue_length(builder->containers) !=3D 1))
 		return NULL;
 =

-	signature =3D l_string_free(builder->signature, false);
+	signature =3D l_string_unwrap(builder->signature);
 	builder->signature =3D NULL;
 =

 	*body =3D builder->body;
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 2172ad9..e6f70ad 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -918,7 +918,7 @@ void _gvariant_builder_free(struct dbus_builder *builde=
r)
 	if (unlikely(!builder))
 		return;
 =

-	l_string_free(builder->signature, true);
+	l_string_free(builder->signature);
 	l_queue_destroy(builder->containers,
 				(l_queue_destroy_func_t) container_free);
 	l_free(builder->body);
@@ -1319,7 +1319,7 @@ char *_gvariant_builder_finish(struct dbus_builder *b=
uilder,
 =

 	root =3D l_queue_peek_head(builder->containers);
 =

-	signature =3D l_string_free(builder->signature, false);
+	signature =3D l_string_unwrap(builder->signature);
 	builder->signature =3D NULL;
 =

 	if (_gvariant_is_fixed_size(signature)) {
diff --git a/ell/key.c b/ell/key.c
index 370b3c8..11700e8 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -169,7 +169,7 @@ static char *format_key_info(const char *encoding, cons=
t char *hash)
 	if (hash)
 		l_string_append_printf(info, "hash=3D%s", hash);
 =

-	return l_string_free(info, false);
+	return l_string_unwrap(info);
 }
 =

 static long kernel_query_key(int32_t key_serial, const char *encoding,
diff --git a/ell/settings.c b/ell/settings.c
index c6eec35..08ba967 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -427,7 +427,7 @@ LIB_EXPORT char *l_settings_to_data(struct l_settings *=
settings, size_t *len)
 		group_entry =3D group_entry->next;
 	}
 =

-	ret =3D l_string_free(buf, false);
+	ret =3D l_string_unwrap(buf);
 =

 	if (len)
 		*len =3D strlen(ret);
diff --git a/ell/string.c b/ell/string.c
index 98e1c46..e6e7140 100644
--- a/ell/string.c
+++ b/ell/string.c
@@ -117,27 +117,37 @@ LIB_EXPORT struct l_string *l_string_new(size_t initi=
al_length)
 /**
  * l_string_free:
  * @string: growable string object
+ *
+ * Free the growable string object and all associated data
+ **/
+LIB_EXPORT void l_string_free(struct l_string *string)
+{
+	if (unlikely(!string))
+		return;
+
+	l_free(string->str);
+	l_free(string);
+}
+
+/**
+ * l_string_unwrap:
+ * @string: growable string object
  * @free_data: internal string array
  *
- * Free the growable string object.  If @free_data #true, then the internal
- * string data will be freed and NULL will be returned.  Otherwise the
- * internal string data will be returned to the caller.  The caller is
- * responsible for freeing it using l_free().
+ * Free the growable string object and return the internal string data.
+ * The caller is responsible for freeing the string data using l_free(),
+ * and the string object is no longer usable.
  *
- * Returns: @string's internal buffer or NULL
+ * Returns: @string's internal buffer
  **/
-LIB_EXPORT char *l_string_free(struct l_string *string, bool free_data)
+LIB_EXPORT char *l_string_unwrap(struct l_string *string)
 {
 	char *result;
 =

 	if (unlikely(!string))
 		return NULL;
 =

-	if (free_data) {
-		l_free(string->str);
-		result =3D NULL;
-	} else
-		result =3D string->str;
+	result =3D string->str;
 =

 	l_free(string);
 =

diff --git a/ell/string.h b/ell/string.h
index a778b31..6549a05 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -100,7 +100,8 @@ static inline bool __attribute__ ((always_inline))
 }
 =

 struct l_string *l_string_new(size_t initial_length);
-char *l_string_free(struct l_string *string, bool free_data);
+void l_string_free(struct l_string *string);
+char *l_string_unwrap(struct l_string *string);
 =

 struct l_string *l_string_append(struct l_string *dest, const char *src);
 struct l_string *l_string_append_c(struct l_string *dest, const char c);
-- =

2.10.2


--===============2064688046030050568==--

