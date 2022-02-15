Content-Type: multipart/mixed; boundary="===============2153650744180247806=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] unit: add compressed point test
Date: Tue, 15 Feb 2022 09:54:51 -0800
Message-ID: <20220215175451.1265748-1-prestwoj@gmail.com>

--===============2153650744180247806==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This tests the 4 different ways a compressed point can be computed:
The two compressed point types with and without subtraction.
---
 unit/test-ecc.c | 61 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/unit/test-ecc.c b/unit/test-ecc.c
index 1cd8b22..21f73f1 100644
--- a/unit/test-ecc.c
+++ b/unit/test-ecc.c
@@ -366,6 +366,66 @@ static void run_test_zero_or_one(const void *arg)
 	assert(!_vli_is_zero_or_one(_2, L_ECC_MAX_DIGITS));
 }
 =

+struct compressed_point_data {
+	char *x;
+	char *exp_y;
+	enum l_ecc_point_type type;
+};
+
+static struct compressed_point_data compressed_tests[] =3D {
+	{
+		/* BIT1, subtraction performed */
+		.x =3D "19b3fec1c000a888ee9c44272e4d7317e6e36577fc9d53e1edfb4e296b0b7ce1=
",
+		.exp_y =3D "a8f9efd0ab526cd930870779621f4e9a53d4e78887ac9f4ed45ff75ded32=
b158",
+		.type =3D L_ECC_POINT_TYPE_COMPRESSED_BIT1,
+	},
+	{
+		/* BIT1, no subtraction */
+		.x =3D "958df5997362a9695ad73938c86be34a4730da877eccaaf8b189e73ff20e67c3=
",
+		.exp_y =3D "1042f37262ded34d8424c1728a1ed23a726645b71db30a38f2932001a202=
7f46",
+		.type =3D L_ECC_POINT_TYPE_COMPRESSED_BIT1,
+	},
+	{
+		/* BIT0, subtraction performed */
+		.x =3D "069bd56634454ca76e7ba434244137509141cbbf532586c6b36e9b5be8a2cc34=
",
+		.exp_y =3D "f4f34d46e4bdc1473fec4b4c8724f349375a8a602f5e83c260d6724e64ec=
7e99",
+		.type =3D L_ECC_POINT_TYPE_COMPRESSED_BIT0,
+	},
+	{
+		/* BIT0, no subtraction */
+		.x =3D "8cade296a68e0c40bcf45a049f1993263bdc8524825e2be44b14ce114e475df0=
",
+		.exp_y =3D "94ed7d09b2a0e95d8df993eaf81eb64d5ff734d01da57e53b2e0277199bc=
5897",
+		.type =3D L_ECC_POINT_TYPE_COMPRESSED_BIT0,
+	},
+};
+
+static void run_test_compressed_points(const void *arg)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < L_ARRAY_SIZE(compressed_tests); i++) {
+		const struct l_ecc_curve *curve =3D l_ecc_curve_from_ike_group(19);
+		struct compressed_point_data *data =3D &compressed_tests[i];
+		uint64_t x[L_ECC_MAX_DIGITS];
+		uint64_t y[L_ECC_MAX_DIGITS];
+		uint64_t exp_y[L_ECC_MAX_DIGITS];
+		size_t bytes =3D l_ecc_curve_get_scalar_bytes(curve);
+		struct l_ecc_point *p;
+
+		HEX2BUF(data->x, x);
+		HEX2BUF(data->exp_y, exp_y);
+
+		p =3D l_ecc_point_from_data(curve, data->type, x, bytes);
+		assert(p);
+
+		l_ecc_point_get_y(p, y, bytes);
+
+		assert(!memcmp(exp_y, y, bytes));
+
+		l_ecc_point_free(p);
+	}
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -387,6 +447,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("ECC reduce test", run_test_reduce, NULL);
 	l_test_add("ECC zero or one test", run_test_zero_or_one, NULL);
+	l_test_add("ECC compressed points", run_test_compressed_points, NULL);
 =

 	return l_test_run();
 }
-- =

2.34.1

--===============2153650744180247806==--

