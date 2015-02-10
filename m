Content-Type: multipart/mixed; boundary="===============6816506221944652721=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 9/9] unit: hashmap: Add unit test for l_hashmap_find
Date: Tue, 10 Feb 2015 16:42:24 +0200
Message-ID: <1423579344-10933-10-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6816506221944652721==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-hashmap.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/unit/test-hashmap.c b/unit/test-hashmap.c
index 51d03ba..e9c4541 100644
--- a/unit/test-hashmap.c
+++ b/unit/test-hashmap.c
@@ -236,6 +236,39 @@ static void foreach_cb(const void *key, void *value, v=
oid *user_data)
 	}
 }
 =

+static unsigned int find_called =3D 0;
+
+static bool find_cb(const void *key, void *value, void *user_data)
+{
+	struct l_hashmap *hashmap =3D user_data;
+	static bool removed;
+	static unsigned int entries;
+	char *str, *mykey =3D "b";
+	bool ret;
+
+	if (!removed) {
+		printf("Removing entry in find\n");
+
+		str =3D l_hashmap_remove(hashmap, "world");
+		assert(str);
+
+		assert(!l_hashmap_lookup(hashmap, "world"));
+
+		entries =3D l_hashmap_size(hashmap);
+
+		removed =3D true;
+	}
+
+	find_called++;
+
+	if (!(find_called % 2)) {
+		assert(entries =3D=3D 3);
+		return true;
+	}
+
+	return false;
+}
+
 static void test_reentrant(const void *test_data)
 {
 	struct l_hashmap *hashmap;
@@ -261,6 +294,9 @@ static void test_reentrant(const void *test_data)
 =

 	l_hashmap_foreach(hashmap, foreach_cb, hashmap);
 =

+	l_hashmap_find(hashmap, find_cb, hashmap);
+	assert(find_called =3D=3D 2);
+
 	l_hashmap_destroy(hashmap, NULL);
 }
 =

-- =

1.8.3.1


--===============6816506221944652721==--

