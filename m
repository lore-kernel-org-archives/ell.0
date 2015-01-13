Content-Type: multipart/mixed; boundary="===============2358069910562698342=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] hashmap: Entry pointers were not freed when map was destroyed
Date: Tue, 13 Jan 2015 14:56:15 +0200
Message-ID: <1421153775-30398-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2358069910562698342==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_hashmap_destroy() did not free the left over entry pointers
that were allocated in l_hashmap_insert(). If user did not remove
them by calling the l_hashmap_remove(), then the entries were left
in the hash which caused a memory leak.
---
 ell/hashmap.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index 8cfe421..b60cc62 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -322,18 +322,23 @@ LIB_EXPORT void l_hashmap_destroy(struct l_hashmap *h=
ashmap,
 		return;
 =

 	for (i =3D 0; i < NBUCKETS; i++) {
-		struct entry *entry, *head =3D &hashmap->buckets[i];
+		struct entry *entry, *next, *head =3D &hashmap->buckets[i];
 =

 		if (!head->next)
 			continue;
 =

-		for (entry =3D head;; entry =3D entry->next) {
+		for (entry =3D head;; entry =3D next) {
 			if (destroy)
 				destroy(entry->value);
 =

 			free_key(hashmap, entry->key);
 =

-			if (entry->next =3D=3D head)
+			next =3D entry->next;
+
+			if (entry !=3D head)
+				l_free(entry);
+
+			if (next =3D=3D head)
 				break;
 		}
 	}
-- =

1.8.3.1


--===============2358069910562698342==--

