Content-Type: multipart/mixed; boundary="===============6001861298320605935=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 8/9] hashmap: Add support to finding an element from hash
Date: Tue, 10 Feb 2015 16:42:23 +0200
Message-ID: <1423579344-10933-9-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6001861298320605935==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add new function l_hashmap_find() which is similar to foreach.
The find will start to call a user supplied function for every
entry in hashmap. If user function returns true, then the find
will return and not call remaining hash elements.
---
 ell/hashmap.c | 39 +++++++++++++++++++++++++++++++++++++++
 ell/hashmap.h |  5 +++++
 2 files changed, 44 insertions(+)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index 6c7c10f..03fcd7c 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -687,3 +687,42 @@ LIB_EXPORT bool l_hashmap_isempty(struct l_hashmap *ha=
shmap)
 =

 	return hashmap->entries =3D=3D 0;
 }
+
+/**
+ * l_hashmap_find:
+ * @hashmap: hash table object
+ * @function: callback function
+ * @user_data: user data given to callback function
+ *
+ * Call @function for every entry in @hashmap. If @function returns true,
+ * then quit calling @function.
+ **/
+LIB_EXPORT void l_hashmap_find(struct l_hashmap *hashmap,
+			l_hashmap_find_func_t function, void *user_data)
+{
+	unsigned int i;
+
+	if (unlikely(!hashmap || !function))
+		return;
+
+	for (i =3D 0; i < NBUCKETS; i++) {
+		struct entry *entry, *head =3D &hashmap->buckets[i];
+
+		if (!head->next)
+			continue;
+
+		for (entry =3D head;; entry =3D entry->next) {
+			bool found;
+
+			if (!entry->removed) {
+				found =3D function(entry->key, entry->value,
+						user_data);
+				if (found)
+					return;
+			}
+
+			if (entry->next =3D=3D head)
+				break;
+		}
+	}
+}
diff --git a/ell/hashmap.h b/ell/hashmap.h
index a904109..3085477 100644
--- a/ell/hashmap.h
+++ b/ell/hashmap.h
@@ -31,6 +31,8 @@ extern "C" {
 =

 typedef void (*l_hashmap_foreach_func_t) (const void *key, void *value,
 							void *user_data);
+typedef bool (*l_hashmap_find_func_t) (const void *key, void *value,
+							void *user_data);
 typedef void (*l_hashmap_destroy_func_t) (void *value);
 typedef unsigned int (*l_hashmap_hash_func_t) (const void *p);
 typedef int (*l_hashmap_compare_func_t) (const void *a, const void *b);
@@ -70,6 +72,9 @@ void *l_hashmap_lookup(struct l_hashmap *hashmap, const v=
oid *key);
 void l_hashmap_foreach(struct l_hashmap *hashmap,
 			l_hashmap_foreach_func_t function, void *user_data);
 =

+void l_hashmap_find(struct l_hashmap *hashmap,
+			l_hashmap_find_func_t function, void *user_data);
+
 unsigned int l_hashmap_size(struct l_hashmap *hashmap);
 bool l_hashmap_isempty(struct l_hashmap *hashmap);
 =

-- =

1.8.3.1


--===============6001861298320605935==--

