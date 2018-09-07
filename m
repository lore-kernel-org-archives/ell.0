Content-Type: multipart/mixed; boundary="===============4017681782477272956=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] hwdb: Allow loading of v2 or v3 hwdb.bin files
Date: Fri, 07 Sep 2018 13:12:48 -0700
Message-ID: <20180907201250.17651-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4017681782477272956==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The hwdb trie entry has been extended in a reverse-compatible way, but
ELL had a strict check for the size of struct trie_entry that caused the
load to fail. Instead of requiring an exact size, only make sure the
entry is not too small.
---
 ell/hwdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/hwdb.c b/ell/hwdb.c
index 29b7557..0d5f95a 100644
--- a/ell/hwdb.c
+++ b/ell/hwdb.c
@@ -136,7 +136,7 @@ LIB_EXPORT struct l_hwdb *l_hwdb_new(const char *pathna=
me)
 	if (L_LE64_TO_CPU(hdr->child_size) !=3D sizeof(struct trie_child))
 		goto failed;
 =

-	if (L_LE64_TO_CPU(hdr->entry_size) !=3D sizeof(struct trie_entry))
+	if (L_LE64_TO_CPU(hdr->entry_size) < sizeof(struct trie_entry))
 		goto failed;
 =

 	if (L_LE64_TO_CPU(hdr->header_size) + L_LE64_TO_CPU(hdr->nodes_size) +
-- =

2.18.0


--===============4017681782477272956==--

