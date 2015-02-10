Content-Type: multipart/mixed; boundary="===============7534009562274174635=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Tue, 10 Feb 2015 16:42:21 +0200
Message-ID: <1423579344-10933-7-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7534009562274174635==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow user to remove and add values while inside a callback
from foreach function. This is very much needed as it is
easy to get things wrong here and it helps to avoid complicated
call flows in calling applications.

So foreach logic is changed so that if user tries to remove
an entry from the hash while inside foreach callback, the
entry is not yet removed from hash but marked as removable.
After foreach has finished calling the callback function,
it checks what elements it needs to remove from the hash.

This valgrind report was seen and it relates to this issue.
Here a DBus message was received and its callback function
eventually called l_dbus_unregister() because of application
logic. This then caused the signal_list hash to get corrupted
because the unregister removed an entry from hash while
traversing it.

=3D=3D28077=3D=3D Invalid read of size 1
=3D=3D28077=3D=3D    at 0x4044A9: l_hashmap_foreach (hashmap.c:606)
=3D=3D28077=3D=3D    by 0x4071D9: message_read_handler (dbus.c:244)
=3D=3D28077=3D=3D    by 0x410D94: io_callback (io.c:120)
=3D=3D28077=3D=3D    by 0x404C42: l_main_run (main.c:346)
=3D=3D28077=3D=3D    by 0x401D08: main (test-agent.c:460)
=3D=3D28077=3D=3D  Address 0x1c is not stack'd, malloc'd or (recently) free=
'd
=3D=3D28077=3D=3D
=3D=3D28077=3D=3D
=3D=3D28077=3D=3D Process terminating with default action of signal 11 (SIG=
SEGV)
=3D=3D28077=3D=3D  Access not within mapped region at address 0x1C
=3D=3D28077=3D=3D    at 0x4044A9: l_hashmap_foreach (hashmap.c:606)
=3D=3D28077=3D=3D    by 0x4071D9: message_read_handler (dbus.c:244)
=3D=3D28077=3D=3D    by 0x410D94: io_callback (io.c:120)
=3D=3D28077=3D=3D    by 0x404C42: l_main_run (main.c:346)
=3D=3D28077=3D=3D    by 0x401D08: main (test-agent.c:460)
=3D=3D28077=3D=3D  If you believe this happened as a result of a stack
=3D=3D28077=3D=3D  overflow in your program's main thread (unlikely but
=3D=3D28077=3D=3D  possible), you can try to increase the size of the
=3D=3D28077=3D=3D  main thread stack using the --main-stacksize=3D flag.
=3D=3D28077=3D=3D  The main thread stack size used in this run was 8388608.
---
 ell/hashmap.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 67 insertions(+), 2 deletions(-)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index a204726..6c7c10f 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -42,6 +42,7 @@ struct entry {
 	void *value;
 	struct entry *next;
 	unsigned int hash;
+	bool removed;
 };
 =

 /**
@@ -50,6 +51,8 @@ struct entry {
  * Opague object representing the hash table.
  */
 struct l_hashmap {
+	bool dirty;
+	bool traversing;
 	l_hashmap_hash_func_t hash_func;
 	l_hashmap_compare_func_t compare_func;
 	l_hashmap_key_new_func_t key_new_func;
@@ -431,6 +434,7 @@ LIB_EXPORT bool l_hashmap_insert(struct l_hashmap *hash=
map,
 				free_key(hashmap, entry->key);
 				entry->key =3D key_new;
 			}
+			entry->removed =3D false;
 =

 			if (entry->value !=3D value) {
 				free_value(hashmap, entry->value);
@@ -490,11 +494,20 @@ LIB_EXPORT void *l_hashmap_remove(struct l_hashmap *h=
ashmap, const void *key)
 		if (entry->hash !=3D hash)
 			goto next;
 =

+		if (entry->removed)
+			goto next;
+
 		if (hashmap->compare_func(key, entry->key))
 			goto next;
 =

 		value =3D entry->value;
 =

+		if (hashmap->traversing) {
+			entry->removed =3D true;
+			hashmap->dirty =3D true;
+			goto skip;
+		}
+
 		if (entry =3D=3D head) {
 			if (entry->next =3D=3D head) {
 				free_key(hashmap, entry->key);
@@ -517,6 +530,7 @@ LIB_EXPORT void *l_hashmap_remove(struct l_hashmap *has=
hmap, const void *key)
 			l_free(entry);
 		}
 =

+	skip:
 		hashmap->entries--;
 =

 		return value;
@@ -553,7 +567,7 @@ LIB_EXPORT void *l_hashmap_lookup(struct l_hashmap *has=
hmap, const void *key)
 		return NULL;
 =

 	for (entry =3D head;; entry =3D entry->next) {
-		if (entry->hash =3D=3D hash &&
+		if (entry->hash =3D=3D hash && !entry->removed &&
 				!hashmap->compare_func(key, entry->key))
 			return entry->value;
 =

@@ -580,6 +594,8 @@ LIB_EXPORT void l_hashmap_foreach(struct l_hashmap *has=
hmap,
 	if (unlikely(!hashmap || !function))
 		return;
 =

+	hashmap->traversing =3D true;
+
 	for (i =3D 0; i < NBUCKETS; i++) {
 		struct entry *entry, *head =3D &hashmap->buckets[i];
 =

@@ -587,12 +603,61 @@ LIB_EXPORT void l_hashmap_foreach(struct l_hashmap *h=
ashmap,
 			continue;
 =

 		for (entry =3D head;; entry =3D entry->next) {
-			function(entry->key, entry->value, user_data);
+			if (!entry->removed)
+				function(entry->key, entry->value, user_data);
 =

 			if (entry->next =3D=3D head)
 				break;
 		}
 	}
+
+	hashmap->traversing =3D false;
+
+	if (!hashmap->dirty)
+		return;
+
+	/* Remove the entries that were marked removed. */
+	for (i =3D 0; i < NBUCKETS; i++) {
+		struct entry *entry, *prev, *head =3D &hashmap->buckets[i];
+
+		if (!head->next)
+			continue;
+
+		for (entry =3D head, prev =3D NULL; entry;
+					prev =3D entry, entry =3D entry->next) {
+
+			if (!entry->removed)
+				goto next;
+
+			if (entry =3D=3D head) {
+				if (entry->next =3D=3D head) {
+					free_key(hashmap, entry->key);
+					head->key =3D NULL;
+					head->value =3D NULL;
+					head->hash =3D 0;
+					head->next =3D NULL;
+				} else {
+					entry =3D entry->next;
+					free_key(hashmap, head->key);
+					head->key =3D entry->key;
+					head->value =3D entry->value;
+					head->hash =3D entry->hash;
+					head->next =3D entry->next;
+					l_free(entry);
+				}
+			} else {
+				prev->next =3D entry->next;
+				free_key(hashmap, entry->key);
+				l_free(entry);
+			}
+
+		next:
+			if (entry->next =3D=3D head)
+				break;
+		}
+	}
+
+	hashmap->dirty =3D false;
 }
 =

 /**
-- =

1.8.3.1


--===============7534009562274174635==--

