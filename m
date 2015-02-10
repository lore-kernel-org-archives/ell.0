Content-Type: multipart/mixed; boundary="===============5306055458921091171=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 2/9] hashmap: Call user supplied value free function in destroy
Date: Tue, 10 Feb 2015 16:42:17 +0200
Message-ID: <1423579344-10933-3-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5306055458921091171==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If user has supplied a value free function, then that will be
called for each deleted entry.
---
 ell/hashmap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index f707d64..c51abfd 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -349,6 +349,9 @@ LIB_EXPORT bool l_hashmap_set_value_free_function(struc=
t l_hashmap *hashmap,
  * @destroy: destroy function
  *
  * Free hash table and call @destory on all remaining entries.
+ * If user has set the value free function by
+ * l_hashmap_set_value_free_function() then the user specified free
+ * function will be called in order to free the value.
  **/
 LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *hashmap,
 				l_hashmap_destroy_func_t destroy)
@@ -369,6 +372,7 @@ LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *has=
hmap,
 				destroy(entry->value);
 =

 			free_key(hashmap, entry->key);
+			free_value(hashmap, entry->value);
 =

 			next =3D entry->next;
 =

-- =

1.8.3.1


--===============5306055458921091171==--

