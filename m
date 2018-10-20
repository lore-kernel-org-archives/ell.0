Content-Type: multipart/mixed; boundary="===============4122522988365451787=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] hashmap: Fix removing last entry in l_hashmap_foreach_remove
Date: Sat, 20 Oct 2018 04:33:47 +0200
Message-ID: <20181020023347.29555-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4122522988365451787==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When the last entry in a bucket with 2 or more entries was removed
the loop would roll over and iterate over the remaining entries for a
second time (then stop), add missing check.
---
 ell/hashmap.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/hashmap.c b/ell/hashmap.c
index ee11d31..061080b 100644
--- a/ell/hashmap.c
+++ b/ell/hashmap.c
@@ -607,6 +607,8 @@ LIB_EXPORT unsigned int l_hashmap_foreach_remove(struct=
 l_hashmap *hashmap,
 				free_key(hashmap, entry->key);
 				l_free(entry);
 				entry =3D prev->next;
+				if (entry =3D=3D head)
+					break;
 				continue;
 			}
 =

-- =

2.19.1


--===============4122522988365451787==--

