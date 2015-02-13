Content-Type: multipart/mixed; boundary="===============2829833874352191491=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 1/2] hashmap: Ensure one unique key exists in all entries
Date: Fri, 13 Feb 2015 12:58:00 +0200
Message-ID: <1423825081-4137-2-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423825081-4137-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2829833874352191491==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The current insert handles properly hash collision, but not key
collision. Instead it appends the new key/value pair at the end of the
relevant list. But then, as it is anyway not documented anywhere, this
can lead to misuses and memory loss. For instance if no
l_hashmap_lookup() is ran before any insertion. Or if no
l_hashmap_remove() is subsequently ran until it cannot find the key.
Most - if not all - hashtable implementations ensure such unicity of the
keys. Thus the risk to handle this differently, if it was not a bug.

The only difference in performance here is the key comparison added to
the list traversal loop (and one minor variable gain).
---
 ell/hashmap.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index 6d757ca..8f10536 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -356,7 +356,7 @@ LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *has=
hmap,
  * @key: key pointer
  * @value: value pointer
  *
- * Insert new @value entry with @key.
+ * Insert new @value entry related to a unique @key.
  *
  * Returns: #true when value has been added and #false in case of failure
  **/
@@ -365,35 +365,37 @@ LIB_EXPORT bool l_hashmap_insert(struct l_hashmap *ha=
shmap,
 {
 	struct entry *entry, *head;
 	unsigned int hash;
-	void *key_new;
 =

 	if (unlikely(!hashmap))
 		return false;
 =

-	key_new =3D get_key_new(hashmap, key);
-	hash =3D hashmap->hash_func(key_new);
+	hash =3D hashmap->hash_func(key);
 	head =3D &hashmap->buckets[hash % NBUCKETS];
+	entry =3D head;
 =

 	if (!head->next) {
-		head->key =3D key_new;
 		head->value =3D value;
 		head->hash =3D hash;
 		head->next =3D head;
 		goto done;
 	}
 =

-	entry =3D l_new(struct entry, 1);
-	entry->key =3D key_new;
+	do {
+		if (entry->hash =3D=3D hash &&
+				!hashmap->compare_func(key, entry->key))
+			return false;
+
+		entry =3D entry->next;
+	} while (entry->next !=3D head);
+
+	entry->next =3D l_new(struct entry, 1);
+	entry =3D entry->next;
 	entry->value =3D value;
 	entry->hash =3D hash;
 	entry->next =3D head;
 =

-	while (head->next !=3D entry->next)
-		head =3D head->next;
-
-	head->next =3D entry;
-
 done:
+	entry->key =3D get_key_new(hashmap, key);
 	hashmap->entries++;
 =

 	return true;
-- =

2.0.5


--===============2829833874352191491==--

