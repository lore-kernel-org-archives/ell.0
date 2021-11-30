Content-Type: multipart/mixed; boundary="===============6651859365493337636=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 2/2] unit: add test for l_uintset_size
Date: Tue, 30 Nov 2021 10:12:52 -0800
Message-ID: <20211130181252.428774-2-prestwoj@gmail.com>
In-Reply-To: 20211130181252.428774-1-prestwoj@gmail.com

--===============6651859365493337636==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 3c9790e..0918ef2 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -363,6 +363,29 @@ static void test_uintset_isempty(const void *user_data)
 	l_uintset_free(b);
 }
 =

+static void test_uintset_size(const void *user_data)
+{
+	uint32_t i;
+	struct l_uintset *set =3D l_uintset_new(32);
+
+	assert(l_uintset_size(set) =3D=3D 0);
+
+	for (i =3D 0; i < 32; i++) {
+		l_uintset_put(set, i);
+		assert(l_uintset_size(set) =3D=3D i);
+	}
+
+	assert(l_uintset_size(set) =3D=3D i - 1);
+
+	l_uintset_take(set, 10);
+	assert(l_uintset_size(set) =3D=3D i - 2);
+
+	for (i =3D 0; i < 32; i++)
+		l_uintset_take(set, i);
+
+	assert(l_uintset_size(set) =3D=3D 0);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -381,6 +404,7 @@ int main(int argc, char *argv[])
 	l_test_add("l_uintset intersect test 2", test_uintset_intersect_test,
 							&intersect_data_2);
 	l_test_add("l_uintset isempty", test_uintset_isempty, NULL);
+	l_test_add("l_uintset size", test_uintset_size, NULL);
 =

 	return l_test_run();
 }
-- =

2.31.1

--===============6651859365493337636==--

