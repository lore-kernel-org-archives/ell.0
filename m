Content-Type: multipart/mixed; boundary="===============4165249368910840638=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 7/9] unit: hashmap: Re-entrancy tests added
Date: Tue, 10 Feb 2015 16:42:22 +0200
Message-ID: <1423579344-10933-8-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4165249368910840638==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Check that we can add and remove items from hash while inside
foreach callback.
---
 unit/test-hashmap.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 81 insertions(+)

diff --git a/unit/test-hashmap.c b/unit/test-hashmap.c
index 75c249c..51d03ba 100644
--- a/unit/test-hashmap.c
+++ b/unit/test-hashmap.c
@@ -184,11 +184,92 @@ static void test_str(const void *test_data)
 	l_hashmap_destroy(hashmap, NULL);
 }
 =

+static void foreach_cb(const void *key, void *value, void *user_data)
+{
+	struct l_hashmap *hashmap =3D user_data;
+	static bool removed, insert, conflict;
+	unsigned int entries;
+	char *str, *mykey =3D "b";
+	bool ret;
+
+	if (!removed) {
+		printf("Removing entry in foreach\n");
+
+		entries =3D l_hashmap_size(hashmap);
+
+		str =3D l_hashmap_remove(hashmap, "a");
+		assert(str);
+
+		assert(!l_hashmap_lookup(hashmap, "a"));
+
+		assert(entries =3D=3D (l_hashmap_size(hashmap) + 1));
+
+		removed =3D true;
+	}
+
+	if (!insert) {
+		printf("Adding entry in foreach\n");
+
+		entries =3D l_hashmap_size(hashmap);
+
+		ret =3D l_hashmap_insert(hashmap, mykey, mykey);
+		assert(ret);
+
+		assert(entries =3D=3D (l_hashmap_size(hashmap) - 1));
+
+		insert =3D true;
+	}
+
+	if (!conflict) {
+		printf("Adding conflicting entry in foreach\n");
+
+		entries =3D l_hashmap_size(hashmap);
+
+		assert(l_hashmap_lookup(hashmap, mykey));
+
+		ret =3D l_hashmap_insert(hashmap, mykey, mykey);
+		assert(ret);
+
+		assert(entries =3D=3D l_hashmap_size(hashmap));
+
+		conflict =3D true;
+	}
+}
+
+static void test_reentrant(const void *test_data)
+{
+	struct l_hashmap *hashmap;
+	const void *ptr;
+	const char **itr, *strings[] =3D {
+		"hello",
+		"world",
+		"a",
+		"a longer key here",
+		NULL
+	};
+
+	hashmap =3D l_hashmap_string_new();
+	assert(hashmap);
+	assert(l_hashmap_size(hashmap) =3D=3D 0);
+	assert(l_hashmap_isempty(hashmap));
+
+	for (itr =3D strings; *itr !=3D NULL; itr++) {
+		assert(l_hashmap_insert(hashmap, *itr, itr));
+		ptr =3D l_hashmap_lookup(hashmap, *itr);
+		assert(ptr =3D=3D itr);
+	}
+
+	l_hashmap_foreach(hashmap, foreach_cb, hashmap);
+
+	l_hashmap_destroy(hashmap, NULL);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 =

 	l_test_add("Pointer Test", test_ptr, NULL);
 	l_test_add("String Test", test_str, NULL);
+	l_test_add("Re-entrant Test", test_reentrant, NULL);
 	return l_test_run();
 }
-- =

1.8.3.1


--===============4165249368910840638==--

