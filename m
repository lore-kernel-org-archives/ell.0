Content-Type: multipart/mixed; boundary="===============4519040050935224655=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 2/2] unit: add test for l_uintset_count
Date: Tue, 30 Nov 2021 09:45:07 -0800
Message-ID: <20211130174507.383992-2-prestwoj@gmail.com>
In-Reply-To: 20211130174507.383992-1-prestwoj@gmail.com

--===============4519040050935224655==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 3c9790e..6afa7a8 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -363,6 +363,29 @@ static void test_uintset_isempty(const void *user_data)
 	l_uintset_free(b);
 }
 =

+static void test_uintset_count(const void *user_data)
+{
+	uint32_t i;
+	struct l_uintset *set =3D l_uintset_new(32);
+
+	assert(l_uintset_count(set) =3D=3D 0);
+
+	for (i =3D 0; i < 32; i++) {
+		l_uintset_put(set, i);
+		assert(l_uintset_count(set) =3D=3D i);
+	}
+
+	assert(l_uintset_count(set) =3D=3D i - 1);
+
+	l_uintset_take(set, 10);
+	assert(l_uintset_count(set) =3D=3D i - 2);
+
+	for (i =3D 0; i < 32; i++)
+		l_uintset_take(set, i);
+
+	assert(l_uintset_count(set) =3D=3D 0);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -381,6 +404,7 @@ int main(int argc, char *argv[])
 	l_test_add("l_uintset intersect test 2", test_uintset_intersect_test,
 							&intersect_data_2);
 	l_test_add("l_uintset isempty", test_uintset_isempty, NULL);
+	l_test_add("l_uintset count", test_uintset_count, NULL);
 =

 	return l_test_run();
 }
-- =

2.31.1

--===============4519040050935224655==--

