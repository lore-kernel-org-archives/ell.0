Content-Type: multipart/mixed; boundary="===============5178711099615864715=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 3/4] ecc: moved point add, exp, and legendre into ecc.c
Date: Thu, 10 Jan 2019 10:53:15 -0800
Message-ID: <20190110185316.27969-3-james.prestwood@linux.intel.com>
In-Reply-To: <20190110185316.27969-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5178711099615864715==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

_ecc_point_add, _vli_mod_exp, and _vli_legendre were all written in
house, in addition to the ecc code taken from the kernel. Inside IWD
it was much more convenient to just bundle these into the same file.
Now (in ELL), since we have ecc-private.h, its much easier to keep
these separate and out of ecc-external.c.
---
 ell/ecc-external.c | 123 +++++++--------------------------------------
 ell/ecc-private.h  |   4 ++
 ell/ecc.c          |  90 +++++++++++++++++++++++++++++++++
 3 files changed, 111 insertions(+), 106 deletions(-)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index 0cdb198..71b3e68 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -180,7 +180,7 @@ static uint64_t vli_add(uint64_t *result, const uint64_=
t *left,
 }
 =

 /* Computes result =3D left - right, returning borrow. Can modify in place=
. */
-static uint64_t vli_sub(uint64_t *result, const uint64_t *left,
+uint64_t _vli_sub(uint64_t *result, const uint64_t *left,
 							const uint64_t *right,
 							unsigned int ndigits)
 {
@@ -327,7 +327,7 @@ void _vli_mod_add(uint64_t *result, const uint64_t *lef=
t,
 	 * get remainder.
 	 */
 	if (carry || _vli_cmp(result, mod, ndigits) >=3D 0)
-		vli_sub(result, result, mod, ndigits);
+		_vli_sub(result, result, mod, ndigits);
 }
 =

 /* Computes result =3D (left - right) % mod.
@@ -337,7 +337,7 @@ void _vli_mod_sub(uint64_t *result, const uint64_t *lef=
t,
 				const uint64_t *right, const uint64_t *mod,
 				unsigned int ndigits)
 {
-	uint64_t borrow =3D vli_sub(result, left, right, ndigits);
+	uint64_t borrow =3D _vli_sub(result, left, right, ndigits);
 =

 	/* In this case, p_result =3D=3D -diff =3D=3D (max int) - diff.
 	 * Since -x % d =3D=3D d - x, we can get the correct result from
@@ -372,7 +372,7 @@ static void vli_mmod_fast_192(uint64_t *result, const u=
int64_t *product,
 	carry +=3D vli_add(result, result, tmp, ndigits);
 =

 	while (carry || _vli_cmp(curve_prime, result, ndigits) !=3D 1)
-		carry -=3D vli_sub(result, result, curve_prime, ndigits);
+		carry -=3D _vli_sub(result, result, curve_prime, ndigits);
 }
 =

 /* Computes result =3D product % curve_prime
@@ -421,28 +421,28 @@ static void vli_mmod_fast_256(uint64_t *result, const=
 uint64_t *product,
 	tmp[1] =3D (product[6] >> 32);
 	tmp[2] =3D 0;
 	tmp[3] =3D (product[4] & 0xffffffff) | (product[5] << 32);
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	/* d2 */
 	tmp[0] =3D product[6];
 	tmp[1] =3D product[7];
 	tmp[2] =3D 0;
 	tmp[3] =3D (product[4] >> 32) | (product[5] & 0xffffffff00000000ull);
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	/* d3 */
 	tmp[0] =3D (product[6] >> 32) | (product[7] << 32);
 	tmp[1] =3D (product[7] >> 32) | (product[4] << 32);
 	tmp[2] =3D (product[4] >> 32) | (product[5] << 32);
 	tmp[3] =3D (product[6] << 32);
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	/* d4 */
 	tmp[0] =3D product[7];
 	tmp[1] =3D product[4] & 0xffffffff00000000ull;
 	tmp[2] =3D product[5];
 	tmp[3] =3D product[6] & 0xffffffff00000000ull;
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	if (carry < 0) {
 		do {
@@ -450,7 +450,7 @@ static void vli_mmod_fast_256(uint64_t *result, const u=
int64_t *product,
 		} while (carry < 0);
 	} else {
 		while (carry || _vli_cmp(curve_prime, result, ndigits) !=3D 1)
-			carry -=3D vli_sub(result, result, curve_prime, ndigits);
+			carry -=3D _vli_sub(result, result, curve_prime, ndigits);
 	}
 }
 =

@@ -550,7 +550,7 @@ static void vli_mmod_fast_384(uint64_t *result, const u=
int64_t *product,
 	tmp[3] =3D ECC_SET_S(product, 18, 17);
 	tmp[4] =3D ECC_SET_S(product, 20, 19);
 	tmp[5] =3D ECC_SET_S(product, 22, 21);
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	/* s8 */
 	tmp[0] =3D ECC_SET_S(product, 20, -1);
@@ -559,7 +559,7 @@ static void vli_mmod_fast_384(uint64_t *result, const u=
int64_t *product,
 	tmp[3] =3D 0;
 	tmp[4] =3D 0;
 	tmp[5] =3D 0;
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	/* s9 */
 	tmp[0] =3D 0;
@@ -568,7 +568,7 @@ static void vli_mmod_fast_384(uint64_t *result, const u=
int64_t *product,
 	tmp[3] =3D 0;
 	tmp[4] =3D 0;
 	tmp[5] =3D 0;
-	carry -=3D vli_sub(result, result, tmp, ndigits);
+	carry -=3D _vli_sub(result, result, tmp, ndigits);
 =

 	if (carry < 0) {
 		do {
@@ -576,7 +576,7 @@ static void vli_mmod_fast_384(uint64_t *result, const u=
int64_t *product,
 		} while (carry < 0);
 	} else {
 		while (carry || _vli_cmp(curve_prime, result, ndigits) !=3D 1)
-			carry -=3D vli_sub(result, result, curve_prime, ndigits);
+			carry -=3D _vli_sub(result, result, curve_prime, ndigits);
 	}
 }
 =

@@ -675,13 +675,13 @@ void _vli_mod_inv(uint64_t *result, const uint64_t *i=
nput,
 			if (carry)
 				v[ndigits - 1] |=3D 0x8000000000000000ull;
 		} else if (cmp_result > 0) {
-			vli_sub(a, a, b, ndigits);
+			_vli_sub(a, a, b, ndigits);
 			_vli_rshift1(a, ndigits);
 =

 			if (_vli_cmp(u, v, ndigits) < 0)
 				vli_add(u, u, mod, ndigits);
 =

-			vli_sub(u, u, v, ndigits);
+			_vli_sub(u, u, v, ndigits);
 			if (!EVEN(u))
 				carry =3D vli_add(u, u, mod, ndigits);
 =

@@ -689,13 +689,13 @@ void _vli_mod_inv(uint64_t *result, const uint64_t *i=
nput,
 			if (carry)
 				u[ndigits - 1] |=3D 0x8000000000000000ull;
 		} else {
-			vli_sub(b, b, a, ndigits);
+			_vli_sub(b, b, a, ndigits);
 			_vli_rshift1(b, ndigits);
 =

 			if (_vli_cmp(v, u, ndigits) < 0)
 				vli_add(v, v, mod, ndigits);
 =

-			vli_sub(v, v, u, ndigits);
+			_vli_sub(v, v, u, ndigits);
 			if (!EVEN(v))
 				carry =3D vli_add(v, v, mod, ndigits);
 =

@@ -972,92 +972,3 @@ bool _ecc_point_is_zero(const struct l_ecc_point *poin=
t)
 	return (vli_is_zero(point->x, point->curve->ndigits) &&
 		vli_is_zero(point->y, point->curve->ndigits));
 }
-
-/* (rx, ry) =3D (px, py) + (qx, qy) */
-void _ecc_point_add(struct l_ecc_point *ret, const struct l_ecc_point *p,
-			const struct l_ecc_point *q,
-			const uint64_t *curve_prime)
-{
-	/*
-	* s =3D (py - qy)/(px - qx)
-	*
-	* rx =3D s^2 - px - qx
-	* ry =3D s(px - rx) - py
-	*/
-	uint64_t s[L_ECC_MAX_DIGITS];
-	uint64_t kp1[L_ECC_MAX_DIGITS];
-	uint64_t kp2[L_ECC_MAX_DIGITS];
-	uint64_t resx[L_ECC_MAX_DIGITS];
-	uint64_t resy[L_ECC_MAX_DIGITS];
-	unsigned int ndigits =3D p->curve->ndigits;
-
-	vli_clear(s, ndigits);
-
-	/* kp1 =3D py - qy */
-	_vli_mod_sub(kp1, q->y, p->y, curve_prime, ndigits);
-	/* kp2 =3D px - qx */
-	_vli_mod_sub(kp2, q->x, p->x, curve_prime, ndigits);
-	/* s =3D kp1/kp2 */
-	_vli_mod_inv(kp2, kp2, curve_prime, ndigits);
-	_vli_mod_mult_fast(s, kp1, kp2, curve_prime, ndigits);
-	/* rx =3D s^2 - px - qx */
-	_vli_mod_mult_fast(kp1, s, s, curve_prime, ndigits);
-	_vli_mod_sub(kp1, kp1, p->x, curve_prime, ndigits);
-	_vli_mod_sub(resx, kp1, q->x, curve_prime, ndigits);
-	/* ry =3D s(px - rx) - py */
-	_vli_mod_sub(kp1, p->x, resx, curve_prime, ndigits);
-	_vli_mod_mult_fast(kp1, s, kp1, curve_prime, ndigits);
-	_vli_mod_sub(resy, kp1, p->y, curve_prime, ndigits);
-
-	vli_set(ret->x, resx, ndigits);
-	vli_set(ret->y, resy, ndigits);
-}
-
-/* result =3D (base ^ exp) % p */
-void _vli_mod_exp(uint64_t *result, uint64_t *base, uint64_t *exp,
-			const uint64_t *mod, unsigned int ndigits)
-{
-	unsigned int i;
-	int bit;
-	uint64_t n[L_ECC_MAX_DIGITS];
-	uint64_t r[L_ECC_MAX_DIGITS] =3D { 1 };
-
-	vli_set(n, base, ndigits);
-
-	for (i =3D 0; i < ndigits; i++) {
-		for (bit =3D 0; bit < 64; bit++) {
-			uint64_t tmp[L_ECC_MAX_DIGITS];
-
-			if (exp[i] & (1ull << bit)) {
-				_vli_mod_mult_fast(tmp, r, n, mod, ndigits);
-				vli_set(r, tmp, ndigits);
-			}
-
-			_vli_mod_mult_fast(tmp, n, n, mod, ndigits);
-			vli_set(n, tmp, ndigits);
-		}
-	}
-
-	vli_set(result, r, ndigits);
-}
-
-int _vli_legendre(uint64_t *val, const uint64_t *p, unsigned int ndigits)
-{
-	uint64_t tmp[L_ECC_MAX_DIGITS];
-	uint64_t exp[L_ECC_MAX_DIGITS];
-	uint64_t _1[L_ECC_MAX_DIGITS] =3D { 1ull };
-	uint64_t _0[L_ECC_MAX_DIGITS] =3D { 0 };
-
-	/* check that val ^ ((p - 1) / 2) =3D=3D [1, 0 or -1] */
-
-	vli_sub(exp, p, _1, ndigits);
-	_vli_rshift1(exp, ndigits);
-	_vli_mod_exp(tmp, val, exp, p, ndigits);
-
-	if (_vli_cmp(tmp, _1, ndigits) =3D=3D 0)
-		return 1;
-	else if (_vli_cmp(tmp, _0, ndigits) =3D=3D 0)
-		return 0;
-	else
-		return -1;
-}
diff --git a/ell/ecc-private.h b/ell/ecc-private.h
index 0d8a444..3863620 100644
--- a/ell/ecc-private.h
+++ b/ell/ecc-private.h
@@ -75,6 +75,10 @@ void _vli_mod_exp(uint64_t *result, uint64_t *base, uint=
64_t *exp,
 =

 int _vli_cmp(const uint64_t *left, const uint64_t *right, unsigned int ndi=
gits);
 =

+uint64_t _vli_sub(uint64_t *result, const uint64_t *left,
+							const uint64_t *right,
+							unsigned int ndigits);
+
 int _vli_legendre(uint64_t *val, const uint64_t *p, unsigned int ndigits);
 =

 bool _ecc_point_is_zero(const struct l_ecc_point *point);
diff --git a/ell/ecc.c b/ell/ecc.c
index 61e839e..2bc10f5 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -264,6 +264,96 @@ static bool decode_point(const struct l_ecc_curve *cur=
ve, uint64_t *x,
 	return true;
 }
 =

+/* (rx, ry) =3D (px, py) + (qx, qy) */
+void _ecc_point_add(struct l_ecc_point *ret, const struct l_ecc_point *p,
+			const struct l_ecc_point *q,
+			const uint64_t *curve_prime)
+{
+	/*
+	* s =3D (py - qy)/(px - qx)
+	*
+	* rx =3D s^2 - px - qx
+	* ry =3D s(px - rx) - py
+	*/
+	uint64_t s[L_ECC_MAX_DIGITS];
+	uint64_t kp1[L_ECC_MAX_DIGITS];
+	uint64_t kp2[L_ECC_MAX_DIGITS];
+	uint64_t resx[L_ECC_MAX_DIGITS];
+	uint64_t resy[L_ECC_MAX_DIGITS];
+	unsigned int ndigits =3D p->curve->ndigits;
+
+	memset(s, 0, ndigits * 8);
+
+	/* kp1 =3D py - qy */
+	_vli_mod_sub(kp1, q->y, p->y, curve_prime, ndigits);
+	/* kp2 =3D px - qx */
+	_vli_mod_sub(kp2, q->x, p->x, curve_prime, ndigits);
+	/* s =3D kp1/kp2 */
+	_vli_mod_inv(kp2, kp2, curve_prime, ndigits);
+	_vli_mod_mult_fast(s, kp1, kp2, curve_prime, ndigits);
+	/* rx =3D s^2 - px - qx */
+	_vli_mod_mult_fast(kp1, s, s, curve_prime, ndigits);
+	_vli_mod_sub(kp1, kp1, p->x, curve_prime, ndigits);
+	_vli_mod_sub(resx, kp1, q->x, curve_prime, ndigits);
+	/* ry =3D s(px - rx) - py */
+	_vli_mod_sub(kp1, p->x, resx, curve_prime, ndigits);
+	_vli_mod_mult_fast(kp1, s, kp1, curve_prime, ndigits);
+	_vli_mod_sub(resy, kp1, p->y, curve_prime, ndigits);
+
+	memcpy(ret->x, resx, ndigits * 8);
+	memcpy(ret->y, resy, ndigits * 8);
+}
+
+/* result =3D (base ^ exp) % p */
+void _vli_mod_exp(uint64_t *result, uint64_t *base, uint64_t *exp,
+			const uint64_t *mod, unsigned int ndigits)
+{
+	unsigned int i;
+	int bit;
+	uint64_t n[L_ECC_MAX_DIGITS];
+	uint64_t r[L_ECC_MAX_DIGITS] =3D { 1 };
+
+	memcpy(n, base, ndigits * 8);
+
+	for (i =3D 0; i < ndigits; i++) {
+		for (bit =3D 0; bit < 64; bit++) {
+			uint64_t tmp[L_ECC_MAX_DIGITS];
+
+			if (exp[i] & (1ull << bit)) {
+				_vli_mod_mult_fast(tmp, r, n, mod, ndigits);
+				memcpy(r, tmp, ndigits * 8);
+			}
+
+			_vli_mod_mult_fast(tmp, n, n, mod, ndigits);
+			memcpy(n, tmp, ndigits * 8);
+		}
+	}
+
+	memcpy(result, r, ndigits * 8);
+}
+
+int _vli_legendre(uint64_t *val, const uint64_t *p, unsigned int ndigits)
+{
+	uint64_t tmp[L_ECC_MAX_DIGITS];
+	uint64_t exp[L_ECC_MAX_DIGITS];
+	uint64_t _1[L_ECC_MAX_DIGITS] =3D { 1ull };
+	uint64_t _0[L_ECC_MAX_DIGITS] =3D { 0 };
+
+	/* check that val ^ ((p - 1) / 2) =3D=3D [1, 0 or -1] */
+
+	_vli_sub(exp, p, _1, ndigits);
+	_vli_rshift1(exp, ndigits);
+	_vli_mod_exp(tmp, val, exp, p, ndigits);
+
+	if (_vli_cmp(tmp, _1, ndigits) =3D=3D 0)
+		return 1;
+	else if (_vli_cmp(tmp, _0, ndigits) =3D=3D 0)
+		return 0;
+	else
+		return -1;
+}
+
+
 LIB_EXPORT struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *c=
urve)
 {
 	struct l_ecc_point *p =3D l_new(struct l_ecc_point, 1);
-- =

2.17.1


--===============5178711099615864715==--

