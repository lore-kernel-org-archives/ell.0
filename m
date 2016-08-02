Content-Type: multipart/mixed; boundary="===============1767127013632778245=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] hwdb: Remove unutilized return value
Date: Tue, 02 Aug 2016 12:21:19 -0700
Message-ID: <20160802192120.14887-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1767127013632778245==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

trie_fnmatch always returned 0. Make it return void instead.
---
 ell/hwdb.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/ell/hwdb.c b/ell/hwdb.c
index caa8eb3..b251f27 100644
--- a/ell/hwdb.c
+++ b/ell/hwdb.c
@@ -198,8 +198,9 @@ LIB_EXPORT void l_hwdb_unref(struct l_hwdb *hwdb)
 	l_free(hwdb);
 }
 =

-static int trie_fnmatch(const void *addr, uint64_t offset, const char *pre=
fix,
-			const char *string, struct l_hwdb_entry **entries)
+static void trie_fnmatch(const void *addr, uint64_t offset, const char *pr=
efix,
+				const char *string,
+				struct l_hwdb_entry **entries)
 {
 	const struct trie_node *node =3D addr + offset;
 	const void *addr_ptr =3D addr + offset + sizeof(*node);
@@ -217,25 +218,22 @@ static int trie_fnmatch(const void *addr, uint64_t of=
fset, const char *prefix,
 =

 	for (i =3D 0; i < child_count; i++) {
 		const struct trie_child *child =3D addr_ptr;
-		int err;
 =

 		scratch_buf[scratch_len] =3D child->c;
 =

-		err =3D trie_fnmatch(addr, le64_to_cpu(child->child_offset),
-						scratch_buf, string, entries);
-		if (err)
-			return err;
+		trie_fnmatch(addr, le64_to_cpu(child->child_offset),
+				scratch_buf, string, entries);
 =

 		addr_ptr +=3D sizeof(*child);
 	}
 =

 	if (!entry_count)
-		return 0;
+		return;
 =

 	scratch_buf[scratch_len] =3D '\0';
 =

 	if (fnmatch(scratch_buf, string, 0))
-		return 0;
+		return;
 =

 	for (i =3D 0; i < entry_count; i++) {
 		const struct trie_entry *entry =3D addr_ptr;
@@ -254,8 +252,6 @@ static int trie_fnmatch(const void *addr, uint64_t offs=
et, const char *prefix,
 =

 		addr_ptr +=3D sizeof(*entry);
 	}
-
-	return 0;
 }
 =

 LIB_EXPORT struct l_hwdb_entry *l_hwdb_lookup(struct l_hwdb *hwdb,
-- =

2.9.2


--===============1767127013632778245==--

