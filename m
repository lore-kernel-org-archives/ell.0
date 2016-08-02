Content-Type: multipart/mixed; boundary="===============6855234965474212898=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] hwdb: Optimize lookup execution
Date: Tue, 02 Aug 2016 12:21:20 -0700
Message-ID: <20160802192120.14887-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160802192120.14887-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6855234965474212898==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Decide whether to descend into child nodes based on fnmatch() results,
rather than performing a depth-first search of all nodes.

Using test-hwdb as an example, it now takes an average of ~50 calls to
trie_fnmatch to perform a lookup instead of ~100000.
---
 ell/hwdb.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/ell/hwdb.c b/ell/hwdb.c
index b251f27..0addaa2 100644
--- a/ell/hwdb.c
+++ b/ell/hwdb.c
@@ -216,6 +216,18 @@ static void trie_fnmatch(const void *addr, uint64_t of=
fset, const char *prefix,
 	sprintf(scratch_buf, "%s%s", prefix, prefix_str);
 	scratch_buf[scratch_len + 1] =3D '\0';
 =

+	/*
+	 * Only incur the cost of this fnmatch() if there are children
+	 * to visit.  In practice, nodes have either entries or children
+	 * so fnmatch() will only be called once per node.
+	 */
+	if (child_count) {
+		scratch_buf[scratch_len] =3D '*';
+
+		if (fnmatch(scratch_buf, string, 0) =3D=3D FNM_NOMATCH)
+			child_count =3D 0;
+	}
+
 	for (i =3D 0; i < child_count; i++) {
 		const struct trie_child *child =3D addr_ptr;
 =

@@ -281,13 +293,6 @@ LIB_EXPORT struct l_hwdb_entry *l_hwdb_lookup_valist(s=
truct l_hwdb *hwdb,
 	if (len < 0)
 		return NULL;
 =

-	/*
-	 * This search operation is not optimized for the Patricia Trie
-	 * and will compare every single entry in the database.
-	 *
-	 * An optimized version should allow using the Patricia Trie data
-	 * structure and follow the shortest path to the matching entry.
-	 */
 	trie_fnmatch(hwdb->addr, hwdb->root, "", modalias, &entries);
 =

 	free(modalias);
-- =

2.9.2


--===============6855234965474212898==--

