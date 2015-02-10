Content-Type: multipart/mixed; boundary="===============4189905451473360004=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 3/9] hashmap: Call user supplied value free function in insert
Date: Tue, 10 Feb 2015 16:42:18 +0200
Message-ID: <1423579344-10933-4-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4189905451473360004==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If user has supplied a value free function, then that will be
called for each replaced entry.
---
 ell/hashmap.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index c51abfd..a204726 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -393,7 +393,11 @@ LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *ha=
shmap,
  * @key: key pointer
  * @value: value pointer
  *
- * Insert new @value entry with @key.
+ * Insert new @value entry with @key. If there is already an same key
+ * in the hash, the new value will replace the old one. If user has set
+ * the value free function by l_hashmap_set_value_free_function() then
+ * the user specified free function will be called in order to free the
+ * value.
  *
  * Returns: #true when value has been added and #false in case of failure
  **/
@@ -419,6 +423,27 @@ LIB_EXPORT bool l_hashmap_insert(struct l_hashmap *has=
hmap,
 		goto done;
 	}
 =

+	/* If the key is already in the hash, we just replace the value */
+	for (entry =3D head;; entry =3D entry->next) {
+		if (entry->hash =3D=3D hash &&
+				!hashmap->compare_func(key, entry->key)) {
+			if (entry->key !=3D key_new) {
+				free_key(hashmap, entry->key);
+				entry->key =3D key_new;
+			}
+
+			if (entry->value !=3D value) {
+				free_value(hashmap, entry->value);
+				entry->value =3D value;
+			}
+
+			return true;
+		}
+
+		if (entry->next =3D=3D head)
+			break;
+	}
+
 	entry =3D l_new(struct entry, 1);
 	entry->key =3D key_new;
 	entry->value =3D value;
-- =

1.8.3.1


--===============4189905451473360004==--

