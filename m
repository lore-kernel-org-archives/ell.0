Content-Type: multipart/mixed; boundary="===============2178793912052530082=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] unit: Add l_uintset_isempty() test
Date: Mon, 16 Sep 2019 13:36:09 -0700
Message-ID: <20190916203610.19722-2-ossama.othman@intel.com>
In-Reply-To: <20190916203610.19722-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2178793912052530082==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 99888b3..3c9790e 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -347,6 +347,22 @@ static void test_uintset_intersect_test(const void *us=
er_data)
 	l_uintset_free(set_r);
 }
 =

+static void test_uintset_isempty(const void *user_data)
+{
+	struct l_uintset *a =3D NULL;
+	struct l_uintset *b =3D l_uintset_new(32);
+	struct l_uintset *c =3D l_uintset_new(32);
+
+	assert(l_uintset_put(c, 10));
+
+	assert(l_uintset_isempty(a));
+	assert(l_uintset_isempty(b));
+	assert(!l_uintset_isempty(c));
+
+	l_uintset_free(c);
+	l_uintset_free(b);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -364,6 +380,7 @@ int main(int argc, char *argv[])
 							&intersect_data_1);
 	l_test_add("l_uintset intersect test 2", test_uintset_intersect_test,
 							&intersect_data_2);
+	l_test_add("l_uintset isempty", test_uintset_isempty, NULL);
 =

 	return l_test_run();
 }
-- =

2.20.1


--===============2178793912052530082==--

