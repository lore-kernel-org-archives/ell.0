Content-Type: multipart/mixed; boundary="===============5434308691422051567=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 1/9] hashmap: Add value free function
Date: Tue, 10 Feb 2015 16:42:16 +0200
Message-ID: <1423579344-10933-2-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5434308691422051567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

User is able to set a function to free the value of the hashmap
entry.
---
 ell/hashmap.c | 37 +++++++++++++++++++++++++++++++++++++
 ell/hashmap.h |  6 ++++++
 2 files changed, 43 insertions(+)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index b60cc62..f707d64 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -54,6 +54,8 @@ struct l_hashmap {
 	l_hashmap_compare_func_t compare_func;
 	l_hashmap_key_new_func_t key_new_func;
 	l_hashmap_key_free_func_t key_free_func;
+	l_hashmap_value_free_func_t value_free_func;
+	void *user_data;
 	unsigned int entries;
 	struct entry buckets[NBUCKETS];
 };
@@ -73,6 +75,12 @@ static inline void free_key(const struct l_hashmap *hash=
map, void *key)
 		hashmap->key_free_func(key);
 }
 =

+static inline void free_value(const struct l_hashmap *hashmap, void *value)
+{
+	if (hashmap->value_free_func)
+		hashmap->value_free_func(hashmap, value, hashmap->user_data);
+}
+
 static inline unsigned int hash_superfast(const uint8_t *key, unsigned int=
 len)
 {
 	/*
@@ -307,6 +315,35 @@ LIB_EXPORT bool l_hashmap_set_key_free_function(struct=
 l_hashmap *hashmap,
 }
 =

 /**
+ * l_hashmap_set_value_free_function:
+ * @hashmap: hash table object
+ * @func: Value destructor function
+ *
+ * Sets the value destructor function to be used by this object.
+ * This function can be NULL, in which case no destructor is called.
+ *
+ * This function can only be called when the @hashmap is empty.
+ *
+ * Returns: #true when the value free function could be updated successful=
ly,
+ * and #false otherwise.
+ **/
+LIB_EXPORT bool l_hashmap_set_value_free_function(struct l_hashmap *hashma=
p,
+					l_hashmap_value_free_func_t func,
+					void *user_data)
+{
+	if (unlikely(!hashmap))
+		return false;
+
+	if (hashmap->entries !=3D 0)
+		return false;
+
+	hashmap->value_free_func =3D func;
+	hashmap->user_data =3D user_data;
+
+	return true;
+}
+
+/**
  * l_hashmap_destroy:
  * @hashmap: hash table object
  * @destroy: destroy function
diff --git a/ell/hashmap.h b/ell/hashmap.h
index 9f4f5fa..a904109 100644
--- a/ell/hashmap.h
+++ b/ell/hashmap.h
@@ -39,6 +39,9 @@ typedef void (*l_hashmap_key_free_func_t) (void *p);
 =

 struct l_hashmap;
 =

+typedef void (*l_hashmap_value_free_func_t) (const struct l_hashmap *hashm=
ap,
+					void *p, void *user_data);
+
 unsigned int l_str_hash(const void *p);
 =

 struct l_hashmap *l_hashmap_new(void);
@@ -52,6 +55,9 @@ bool l_hashmap_set_key_copy_function(struct l_hashmap *ha=
shmap,
 						l_hashmap_key_new_func_t func);
 bool l_hashmap_set_key_free_function(struct l_hashmap *hashmap,
 					l_hashmap_key_free_func_t func);
+bool l_hashmap_set_value_free_function(struct l_hashmap *hashmap,
+				l_hashmap_value_free_func_t func,
+				void *user_data);
 =

 void l_hashmap_destroy(struct l_hashmap *hashmap,
 			l_hashmap_destroy_func_t destroy);
-- =

1.8.3.1


--===============5434308691422051567==--

