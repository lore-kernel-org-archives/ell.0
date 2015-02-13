Content-Type: multipart/mixed; boundary="===============6618759288970006782=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 2/2] unit: Slightly change hash duplicity test to verify key
 unitiy behavior
Date: Fri, 13 Feb 2015 12:58:01 +0200
Message-ID: <1423825081-4137-3-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423825081-4137-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6618759288970006782==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-hashmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/unit/test-hashmap.c b/unit/test-hashmap.c
index e6bd1f9..5717cba 100644
--- a/unit/test-hashmap.c
+++ b/unit/test-hashmap.c
@@ -171,13 +171,13 @@ static void test_duplicate(const void *test_data)
 =

 	assert(l_hashmap_insert(hashmap, "one", &one));
 	assert(l_hashmap_insert(hashmap, "two", &two));
-	assert(l_hashmap_insert(hashmap, "one", &three));
+	assert(!l_hashmap_insert(hashmap, "one", &three));
 =

 	assert(l_hashmap_lookup(hashmap, "two") =3D=3D &two);
 	assert(l_hashmap_lookup(hashmap, "one") =3D=3D &one);
 =

 	assert(l_hashmap_remove(hashmap, "one") =3D=3D &one);
-	assert(l_hashmap_lookup(hashmap, "one") =3D=3D &three);
+	assert(!l_hashmap_lookup(hashmap, "one"));
 =

 	l_hashmap_destroy(hashmap, NULL);
 };
-- =

2.0.5


--===============6618759288970006782==--

