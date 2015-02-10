Content-Type: multipart/mixed; boundary="===============0805595676984295937=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 4/9] unit: hashmap: Add value free hash entry test
Date: Tue, 10 Feb 2015 16:42:19 +0200
Message-ID: <1423579344-10933-5-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0805595676984295937==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the value free function to test that we can replace an
existing value in the hash.
---
 unit/test-hashmap.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/unit/test-hashmap.c b/unit/test-hashmap.c
index a606099..836ed1c 100644
--- a/unit/test-hashmap.c
+++ b/unit/test-hashmap.c
@@ -86,6 +86,14 @@ static void test_ptr(const void *test_data)
 	l_hashmap_destroy(hashmap, NULL);
 }
 =

+static void free_value(const struct l_hashmap *hashmap,
+					void *value, void *user_data)
+{
+	assert(hashmap =3D=3D user_data);
+
+	l_free(value);
+}
+
 static void test_str(const void *test_data)
 {
 	struct l_hashmap *hashmap;
@@ -97,6 +105,8 @@ static void test_str(const void *test_data)
 		"a long key here, bla bla bla bla bla hey! enough?",
 		NULL
 	};
+	const char *duplicate =3D "hello";
+	unsigned int entries;
 =

 	hashmap =3D l_hashmap_string_new();
 	assert(hashmap);
@@ -154,6 +164,13 @@ static void test_str(const void *test_data)
 		assert(ptr =3D=3D itr);
 	}
 =

+	/* check that value free function works */
+	hashmap =3D l_hashmap_string_new();
+	assert(l_hashmap_set_value_free_function(hashmap, free_value,
+							hashmap));
+	assert(l_hashmap_insert(hashmap, strings[0], l_strdup(strings[0])));
+	assert(l_hashmap_insert(hashmap, strings[0], l_strdup(strings[0])));
+
 	assert(l_hashmap_lookup(hashmap, "not in hash") =3D=3D NULL);
 =

 	l_hashmap_destroy(hashmap, NULL);
-- =

1.8.3.1


--===============0805595676984295937==--

