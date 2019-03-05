Content-Type: multipart/mixed; boundary="===============2742710947501651470=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/2] unit: Add l_uintset_intersect tests
Date: Tue, 05 Mar 2019 12:35:43 -0800
Message-ID: <20190305203543.1492-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20190305203543.1492-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2742710947501651470==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-uintset.c | 115 ++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 115 insertions(+)

diff --git a/unit/test-uintset.c b/unit/test-uintset.c
index 42d9698..277cf6a 100644
--- a/unit/test-uintset.c
+++ b/unit/test-uintset.c
@@ -167,6 +167,111 @@ static void test_uintset_find_unused(const void *data)
 	l_uintset_free(set);
 }
 =

+static void test_uintset_intersect_1(const void *data)
+{
+	struct l_uintset *set_a;
+	struct l_uintset *set_b;
+
+	assert(!l_uintset_intersect(NULL, NULL));
+
+	set_a =3D l_uintset_new_from_range(0, 5);
+	assert(!l_uintset_intersect(NULL, set_a));
+	assert(!l_uintset_intersect(set_a, NULL));
+
+	set_b =3D l_uintset_new_from_range(6, 10);
+	assert(!l_uintset_intersect(set_a, set_b));
+
+	l_uintset_free(set_a);
+	l_uintset_free(set_b);
+}
+
+struct uintset_data {
+	uint32_t min;
+	uint32_t max;
+	uint32_t *vals;
+	uint32_t size;
+};
+
+struct uintset_intersect_data {
+	const struct uintset_data set_a;
+	const struct uintset_data set_b;
+	const struct uintset_data set_r;
+};
+
+uint32_t vals1[] =3D { 1, 2, 3 };
+uint32_t vals2[] =3D { 3, 4};
+uint32_t vals3[] =3D { 3 };
+
+static const struct uintset_intersect_data intersect_data_1 =3D {
+	.set_a =3D { 0, 3, vals1, L_ARRAY_SIZE(vals1) },
+	.set_b =3D { 3, 5, vals2, L_ARRAY_SIZE(vals2) },
+	.set_r =3D { 3, 3, vals3, L_ARRAY_SIZE(vals3) },
+};
+
+uint32_t vals4[] =3D { 0, 1, 65, 129 };
+uint32_t vals5[] =3D { 1, 25, 65, 66, 129, 135 };
+uint32_t vals6[] =3D { 1, 65, 129 };
+
+static const struct uintset_intersect_data intersect_data_2 =3D {
+	.set_a =3D { 0, 129, vals4, L_ARRAY_SIZE(vals4) },
+	.set_b =3D { 1, 135, vals5, L_ARRAY_SIZE(vals5) },
+	.set_r =3D { 1, 129, vals6, L_ARRAY_SIZE(vals6) },
+};
+
+uint32_t vals7[] =3D { 0, 191 };
+uint32_t vals8[] =3D { 0, 191 };
+uint32_t vals9[] =3D { 0, 191 };
+
+static const struct uintset_intersect_data intersect_data_3 =3D {
+	.set_a =3D { 0, 192, vals7, L_ARRAY_SIZE(vals7) },
+	.set_b =3D { 0, 192, vals8, L_ARRAY_SIZE(vals8) },
+	.set_r =3D { 0, 192, vals9, L_ARRAY_SIZE(vals9) },
+};
+
+uint32_t vals10[] =3D { 63 };
+uint32_t vals11[] =3D { 63 };
+uint32_t vals12[] =3D { 63 };
+
+static const struct uintset_intersect_data intersect_data_4 =3D {
+	.set_a =3D { 0, 127, vals10, L_ARRAY_SIZE(vals10) },
+	.set_b =3D { 0, 127, vals11, L_ARRAY_SIZE(vals11) },
+	.set_r =3D { 0, 127, vals12, L_ARRAY_SIZE(vals12) },
+};
+
+static void test_uintset_intersect_2(const void *user_data)
+{
+	const struct uintset_intersect_data *data =3D user_data;
+	struct l_uintset *set_a;
+	struct l_uintset *set_b;
+	struct l_uintset *set_r;
+	size_t i;
+
+	set_a =3D l_uintset_new_from_range(data->set_a.min, data->set_a.max);
+
+	for (i =3D 0; i < data->set_a.size; i++)
+		l_uintset_put(set_a, data->set_a.vals[i]);
+
+	set_b =3D l_uintset_new_from_range(data->set_b.min, data->set_b.max);
+
+	for (i =3D 0; i < data->set_b.size; i++)
+		l_uintset_put(set_b, data->set_b.vals[i]);
+
+	set_r =3D l_uintset_intersect(set_a, set_b);
+
+	assert(set_r);
+
+	for (i =3D 0; i < data->set_r.size; i++) {
+		assert(l_uintset_contains(set_r, data->set_r.vals[i]));
+		assert(l_uintset_take(set_r, data->set_r.vals[i]));
+	}
+
+	assert(l_uintset_find_max(set_r) =3D=3D l_uintset_get_max(set_r) + 1);
+
+	l_uintset_free(set_a);
+	l_uintset_free(set_b);
+	l_uintset_free(set_r);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -175,6 +280,16 @@ int main(int argc, char *argv[])
 	l_test_add("l_uintset sanity check #2", test_uintset_2, NULL);
 	l_test_add("l_uintset sanity check #3", test_uintset_3, NULL);
 	l_test_add("l_uintset sanity check #4", test_uintset_4, NULL);
+	l_test_add("l_uintset intersect sanity check", test_uintset_intersect_1,
+									NULL);
+	l_test_add("l_uintset intersect test1", test_uintset_intersect_2,
+							&intersect_data_1);
+	l_test_add("l_uintset intersect test2", test_uintset_intersect_2,
+							&intersect_data_2);
+	l_test_add("l_uintset intersect test3", test_uintset_intersect_2,
+							&intersect_data_3);
+	l_test_add("l_uintset intersect test4", test_uintset_intersect_2,
+							&intersect_data_4);
 	l_test_add("l_uintset find unused tests", test_uintset_find_unused,
 							NULL);
 =

-- =

2.13.6


--===============2742710947501651470==--

