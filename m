Content-Type: multipart/mixed; boundary="===============5420406982340556815=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 5/9] unit: hashmap: Add replace entry test
Date: Tue, 10 Feb 2015 16:42:20 +0200
Message-ID: <1423579344-10933-6-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5420406982340556815==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-hashmap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/unit/test-hashmap.c b/unit/test-hashmap.c
index 836ed1c..75c249c 100644
--- a/unit/test-hashmap.c
+++ b/unit/test-hashmap.c
@@ -164,6 +164,14 @@ static void test_str(const void *test_data)
 		assert(ptr =3D=3D itr);
 	}
 =

+	/* check we can replace entry with new value */
+	entries =3D l_hashmap_size(hashmap);
+	assert(l_hashmap_insert(hashmap, strings[0], (char *)strings[0]));
+	assert(l_hashmap_insert(hashmap, duplicate, (char *)duplicate));
+	assert(entries =3D=3D l_hashmap_size(hashmap));
+
+	l_hashmap_destroy(hashmap, NULL);
+
 	/* check that value free function works */
 	hashmap =3D l_hashmap_string_new();
 	assert(l_hashmap_set_value_free_function(hashmap, free_value,
-- =

1.8.3.1


--===============5420406982340556815==--

