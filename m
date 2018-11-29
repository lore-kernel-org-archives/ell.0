Content-Type: multipart/mixed; boundary="===============8293256433423489283=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/9] unit: moved ECC unit tests from IWD
Date: Thu, 29 Nov 2018 14:08:01 -0800
Message-ID: <20181129220808.22151-2-james.prestwood@linux.intel.com>
In-Reply-To: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8293256433423489283==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The test was just modified to use the new l_ecc API's
---
 Makefile.am     |   5 +-
 unit/test-ecc.c | 345 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 349 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-ecc.c

diff --git a/Makefile.am b/Makefile.am
index 4e5f01b..f33f992 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -161,7 +161,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-uuid \
 			unit/test-pbkdf2 \
 			unit/test-dhcp \
-			unit/test-dir-watch
+			unit/test-dir-watch \
+			unit/test-ecc
 =

 dbus_tests =3D unit/test-hwdb \
 			unit/test-dbus \
@@ -280,6 +281,8 @@ unit_test_dhcp_LDADD =3D ell/libell-private.la
 =

 unit_test_dir_watch_LDADD =3D ell/libell-private.la
 =

+unit_test_ecc_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
diff --git a/unit/test-ecc.c b/unit/test-ecc.c
new file mode 100644
index 0000000..2aac10a
--- /dev/null
+++ b/unit/test-ecc.c
@@ -0,0 +1,345 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018 Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <string.h>
+#include <assert.h>
+
+#include <ell/ell.h>
+#include "ell/ecc.h"
+#include "ell/ecc-private.h"
+
+#define HEX2BUF(s, buf) { \
+	unsigned char *tmp =3D l_util_from_hexstring(s, NULL); \
+	memcpy(buf, tmp, l_ecc_curve_get_ndigits(curve) * 8); \
+	l_free(tmp); \
+}
+
+#define CURVE_P_32_STR "ffffffffffffffffffffffff00000000"\
+			"000000000000000001000000ffffffff"
+
+enum ecc_test_type {
+	TEST_ADD =3D 0,
+	TEST_SUB,
+	TEST_MULT,
+	TEST_INV,
+	TEST_EXP,
+	TEST_POINT_ADD,
+	TEST_SCALAR_MULT,
+	TEST_LEGENDRE,
+};
+
+struct ecc_test_data {
+	enum ecc_test_type type;
+	/* basic math arguments/result */
+	char *a;
+	char *b;
+	char *qr;
+	char *qnr;
+	char *r;
+	bool is_residue;
+	char *mod;
+	char *result;
+	int lres;
+	/* point operations */
+	char *scalar;
+	char *ax, *ay;
+	char *bx, *by;
+	char *rx, *ry;
+};
+
+/* (a + b) mod c */
+struct ecc_test_data add_test =3D {
+	.type =3D TEST_ADD,
+	.a =3D "cae1d5624344984073fd955a72d4ebacedc084679333e4beebff94869e9f6ca8",
+	.b =3D "93a02ae89d15e38a33bf3fea4c99937825b279fa8fa81dded1ccb687cec88461",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "5e82004ae05a7bcaa7bcd545bf6e7f25"
+			"1372fe6222dc029dbccc4b0d6d67f10a"
+};
+
+/* (a - b) mod c */
+struct ecc_test_data sub_test =3D {
+	.type =3D TEST_SUB,
+	.a =3D "cae1d5624344984073fd955a72d4ebacedc084679333e4beebff94869e9f6ca8",
+	.b =3D "93a02ae89d15e38a33bf3fea4c99937825b279fa8fa81dded1ccb687cec88461",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "3741aa79a62eb4b6403e5570263b5834"
+			"c80e0a6d038bc6e01a32ddfecfd6e847"
+};
+
+/* (a * b) mod c */
+struct ecc_test_data mult_test =3D {
+	.type =3D TEST_MULT,
+	.a =3D "cae1d5624344984073fd955a72d4ebacedc084679333e4beebff94869e9f6ca8",
+	.b =3D "93a02ae89d15e38a33bf3fea4c99937825b279fa8fa81dded1ccb687cec88461",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "a31ff5c7d65d8bd806b0407f27d1f1bc"
+			"2c072e28c19720f6a654a75efc2faab5"
+
+};
+
+/* (a^-1) mod c */
+struct ecc_test_data inv_test =3D {
+	.type =3D TEST_INV,
+	.a =3D "cae1d5624344984073fd955a72d4ebacedc084679333e4beebff94869e9f6ca8",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "48faaac115571047ead565911fc334fd"
+			"633c986755e87ab10fd79a4453a60bc5"
+
+};
+
+/* (a^-1) mod c */
+struct ecc_test_data inv_test2 =3D {
+	.type =3D TEST_INV,
+	.a =3D "698e5c10b63a9c79a9720b3f7f4d2f5c9fbb31daf93ac0f8fa8ca5cde8234418",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "5fd113c3b6053c38e54e5917826c8520"
+			"c5a0708a8a47345edbb7fc1d67d9b42b"
+
+};
+
+/* (a ^ b) mod c */
+struct ecc_test_data exp_test =3D {
+	.type =3D TEST_EXP,
+	.a =3D "cae1d5624344984073fd955a72d4ebacedc084679333e4beebff94869e9f6ca8",
+	.b =3D "93a02ae89d15e38a33bf3fea4c99937825b279fa8fa81dded1ccb687cec88461",
+	.mod =3D CURVE_P_32_STR,
+	.result =3D "e7488e3a4d56938bbddc2a615c768d48"
+			"9e5634aced9ceee37249fae1caa36fec"
+
+};
+
+struct ecc_test_data legendre_test1 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "b59c0c366aa89ba229f857190497261d5a0a7a0a774caa72aef041ff00092447",
+	.mod =3D "ffffffff00000001000000000000000000000000fffffffffffffffffffffff=
f",
+	.lres =3D -1
+};
+
+struct ecc_test_data legendre_test2 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "1214f9607d348c998b3fba332d884d65945561fd007ff56d8bf603148d74d2e4",
+	.mod =3D "ffffffff000000010000000000000000"
+			"00000000ffffffffffffffffffffffff",
+	.lres =3D 1
+};
+
+struct ecc_test_data legendre_test3 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "282d751c898bfc593b1d21b6812df48e3ec811f40349b30b7294575c47b871d8",
+	.mod =3D "ffffffff000000010000000000000000"
+			"00000000ffffffffffffffffffffffff",
+	.lres =3D 1
+};
+
+struct ecc_test_data legendre_test4 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "0694ccde1db3d02faa26856678bd9358ecc0d82791405eb3892a8b4f07f1e5d6",
+	.mod =3D "ffffffff000000010000000000000000"
+			"00000000ffffffffffffffffffffffff",
+	.lres =3D -1
+};
+
+struct ecc_test_data legendre_test5 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "92247f96df65a6d04af0c57318e999fd493c42864d156f7e5bba75c964f3c6b0",
+	.mod =3D "ffffffff000000010000000000000000"
+			"00000000ffffffffffffffffffffffff",
+	.lres =3D 1
+};
+
+struct ecc_test_data legendre_test6 =3D {
+	.type =3D TEST_LEGENDRE,
+	.a =3D "084f7eb6ed8021d095787fd401b0f19b13937dc23f7c84dfe69bb9a204bb3768",
+	.mod =3D "ffffffff000000010000000000000000"
+			"00000000ffffffffffffffffffffffff",
+	.lres =3D -1
+};
+
+struct ecc_test_data point_add_test =3D {
+	.type =3D TEST_POINT_ADD,
+	.ax =3D "d36b6768a3279fbe23a5bf5cc19b13354"
+		"fa2c6d6fd9de467d62db007c39452df",
+	.ay =3D "4d601e7be3efd7f357452de7584274c54"
+		"c18ddb0ef2f0f4cf43375152a9780c4",
+	.bx =3D "c833c5d3ab916ed37f16597ace5dcf41f"
+		"080891c0c41b6ce561705bd736a29e0",
+	.by =3D "9d266e5ba8ba3e8d9679238f44a376b05"
+		"133df0510a7b8e6e7dd3a654d40a04a",
+	.rx =3D "24c4ede340dbdd144ccaaea67e5b1fca"
+		"87b3aa26dc11114fcd12186318533101",
+	.ry =3D "1d96391fb2942bf286e9251c257b960e"
+		"7d23d4caff4b6fc898aff87e1f6f5514"
+
+};
+
+struct ecc_test_data point_mult_test =3D {
+	.type =3D TEST_SCALAR_MULT,
+	.ax =3D "768bc2f17fbf4e49282fbd4068994562b"
+		"fc7145306762c26a90be1e9c346ac67",
+	.ay =3D "93a02ae89d15e38a33bf3fea4c9993782"
+		"5b279fa8fa81dded1ccb687cec88461",
+	.scalar =3D "7521d940aa073c1675114ed27b866561"
+		"9c826cac8eaa341f70d61b43ad32058b",
+	.rx =3D "d4c80de349966df5542c984e80885d36"
+		"a965ceb74ffe6a0fdc8343184dedfe66",
+	.ry =3D "6d3a1ac3d1d392413286a0e00e94b01e"
+		"ae8423c7f53b9d39cc7fc9c3a5880f3b"
+
+};
+
+static void run_test(const void *arg)
+{
+	const struct ecc_test_data *data =3D arg;
+	uint64_t a[L_ECC_MAX_DIGITS], b[L_ECC_MAX_DIGITS], mod[L_ECC_MAX_DIGITS],
+			scalar[L_ECC_MAX_DIGITS], result[L_ECC_MAX_DIGITS],
+			check[L_ECC_MAX_DIGITS];
+	struct l_ecc_point point1, point2, point_ret;
+	struct l_ecc_curve *curve =3D l_ecc_curve_get(19);
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+
+	memset(result, 0, sizeof(result));
+
+	if (data->a) {
+		HEX2BUF(data->a, a);
+		l_ecc_be2native(curve, a, a);
+	}
+
+	if (data->b) {
+		HEX2BUF(data->b, b);
+		l_ecc_be2native(curve, b, b);
+	}
+
+	if (data->mod) {
+		HEX2BUF(data->mod, mod);
+		l_ecc_be2native(curve, mod, mod);
+	}
+
+	if (data->ax) {
+		HEX2BUF(data->ax, point1.x);
+		l_ecc_be2native(curve, point1.x, point1.x);
+		point1.ndigits =3D ndigits;
+	}
+
+	if (data->ay) {
+		HEX2BUF(data->ay, point1.y);
+		l_ecc_be2native(curve, point1.y, point1.y);
+	}
+
+	if (data->bx) {
+		HEX2BUF(data->bx, point2.x);
+		l_ecc_be2native(curve, point2.x, point2.x);
+		point2.ndigits =3D ndigits;
+	}
+
+	if (data->by) {
+		HEX2BUF(data->by, point2.y);
+		l_ecc_be2native(curve, point2.y, point2.y);
+	}
+
+	if (data->scalar) {
+		HEX2BUF(data->scalar, scalar);
+		l_ecc_be2native(curve, scalar, scalar);
+	}
+
+	switch (data->type) {
+	case TEST_ADD:
+		_vli_mod_add(result, a, b, mod, ndigits);
+		break;
+	case TEST_SUB:
+		_vli_mod_sub(result, a, b, mod, ndigits);
+		break;
+	case TEST_MULT:
+		_vli_mod_mult_fast(result, a, b, mod, ndigits);
+		break;
+	case TEST_INV:
+		_vli_mod_inv(result, a, mod, ndigits);
+		break;
+	case TEST_EXP:
+		_vli_mod_exp(result, a, b, mod, ndigits);
+		break;
+	case TEST_LEGENDRE:
+	{
+		int lres =3D _vli_legendre(a, mod, ndigits);
+		assert(data->lres =3D=3D lres);
+		break;
+	}
+	case TEST_POINT_ADD:
+		assert(l_ecc_valid_point(curve, &point1) =3D=3D true);
+		assert(l_ecc_valid_point(curve, &point2) =3D=3D true);
+
+		l_ecc_point_add(curve, &point_ret, &point1, &point2);
+
+		break;
+	case TEST_SCALAR_MULT:
+		assert(l_ecc_valid_point(curve, &point1) =3D=3D true);
+
+		l_ecc_point_multiply(curve, &point_ret, &point1, scalar, NULL);
+
+		break;
+	}
+
+	if (data->type <=3D TEST_EXP) {
+		HEX2BUF(data->result, check);
+		l_ecc_native2be(curve, check, check);
+
+		assert(memcmp(result, check, 32) =3D=3D 0);
+	} else if (data->type <=3D TEST_SCALAR_MULT) {
+		uint64_t checkx[L_ECC_MAX_DIGITS];
+		uint64_t checky[L_ECC_MAX_DIGITS];
+
+		HEX2BUF(data->rx, checkx);
+		l_ecc_native2be(curve, checkx, checkx);
+		HEX2BUF(data->ry, checky);
+		l_ecc_native2be(curve, checky, checky);
+
+		assert(memcmp(checkx, point_ret.x, 32) =3D=3D 0);
+		assert(memcmp(checky, point_ret.y, 32) =3D=3D 0);
+		assert(l_ecc_valid_point(curve, &point_ret) =3D=3D true);
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("ECC add test", run_test, &add_test);
+	l_test_add("ECC sub test", run_test, &sub_test);
+	l_test_add("ECC mult test", run_test, &mult_test);
+	l_test_add("ECC inv test", run_test, &inv_test);
+	l_test_add("ECC inv test", run_test, &inv_test2);
+	l_test_add("ECC exp test", run_test, &exp_test);
+	l_test_add("ECC point add test", run_test, &point_add_test);
+	l_test_add("ECC point mult test", run_test, &point_mult_test);
+	l_test_add("ECC legendre", run_test, &legendre_test1);
+	l_test_add("ECC legendre", run_test, &legendre_test2);
+	l_test_add("ECC legendre", run_test, &legendre_test3);
+	l_test_add("ECC legendre", run_test, &legendre_test4);
+	l_test_add("ECC legendre", run_test, &legendre_test5);
+	l_test_add("ECC legendre", run_test, &legendre_test6);
+
+	return l_test_run();
+}
-- =

2.17.1


--===============8293256433423489283==--

