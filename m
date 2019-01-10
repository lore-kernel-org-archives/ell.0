Content-Type: multipart/mixed; boundary="===============5779008863948048066=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 2/4] ecc: added API's to support SAE
Date: Thu, 10 Jan 2019 10:53:14 -0800
Message-ID: <20190110185316.27969-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190110185316.27969-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5779008863948048066==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The functionality require was:
 - Scalar multiplication
 - Find a scalars legendre symbol
 - Sum the curve equations X side
 - Get prime from curve (needed for input to SAE KDF)
 - Check if scalars/points are equal
---
 ell/ecc.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 ell/ecc.h | 15 ++++++++++++++
 2 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 8e8d2ac..61e839e 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -160,7 +160,7 @@ void _ecc_native2be(uint64_t *dest, const uint64_t *nat=
ive,
 }
 =

 static void ecc_compute_y_sqr(const struct l_ecc_curve *curve,
-					uint64_t *y_sqr, uint64_t *x)
+					uint64_t *y_sqr, const uint64_t *x)
 {
 	uint64_t sum[L_ECC_MAX_DIGITS] =3D { 0 };
 	uint64_t tmp[L_ECC_MAX_DIGITS] =3D { 0 };
@@ -488,3 +488,62 @@ LIB_EXPORT bool l_ecc_point_inverse(struct l_ecc_point=
 *p)
 =

 	return true;
 }
+
+LIB_EXPORT bool l_ecc_scalar_multiply(struct l_ecc_scalar *ret,
+					const struct l_ecc_scalar *a,
+					const struct l_ecc_scalar *b)
+{
+	if (unlikely(!ret || !a || !b))
+		return false;
+
+	_vli_mod_mult_fast(ret->c, a->c, b->c, a->curve->p, a->curve->ndigits);
+
+	return true;
+}
+
+LIB_EXPORT int l_ecc_scalar_legendre(struct l_ecc_scalar *value)
+{
+	if (unlikely(!value))
+		return -1;
+
+	return _vli_legendre(value->c, value->curve->p, value->curve->ndigits);
+}
+
+LIB_EXPORT bool l_ecc_scalar_sum_x(struct l_ecc_scalar *ret,
+					const struct l_ecc_scalar *x)
+{
+	if (unlikely(!ret || !x))
+		return false;
+
+	ecc_compute_y_sqr(x->curve, ret->c, x->c);
+
+	return true;
+}
+
+LIB_EXPORT struct l_ecc_scalar *l_ecc_curve_get_prime(
+						const struct l_ecc_curve *curve)
+{
+	if (unlikely(!curve))
+		return NULL;
+
+	return _ecc_constant_new(curve, (void *) curve->p, curve->ndigits * 8);
+}
+
+LIB_EXPORT bool l_ecc_scalars_are_equal(const struct l_ecc_scalar *a,
+						const struct l_ecc_scalar *b)
+{
+	if (unlikely(!a || !b))
+		return false;
+
+	return (memcmp(a->c, b->c, a->curve->ndigits * 8) =3D=3D 0);
+}
+
+LIB_EXPORT bool l_ecc_points_are_equal(const struct l_ecc_point *a,
+						const struct l_ecc_point *b)
+{
+	if (unlikely(!a || !b))
+		return false;
+
+	return ((memcmp(a->x, b->x, a->curve->ndigits * 8) =3D=3D 0) &&
+			(memcmp(a->y, b->y, a->curve->ndigits * 8) =3D=3D 0));
+}
diff --git a/ell/ecc.h b/ell/ecc.h
index 1020724..9a852ff 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -75,6 +75,21 @@ bool l_ecc_point_add(struct l_ecc_point *ret, const stru=
ct l_ecc_point *a,
 				const struct l_ecc_point *b);
 bool l_ecc_point_inverse(struct l_ecc_point *p);
 =

+/* extra operations needed for SAE */
+bool l_ecc_scalar_multiply(struct l_ecc_scalar *ret,
+				const struct l_ecc_scalar *a,
+				const struct l_ecc_scalar *b);
+int l_ecc_scalar_legendre(struct l_ecc_scalar *value);
+bool l_ecc_scalar_sum_x(struct l_ecc_scalar *ret, const struct l_ecc_scala=
r *x);
+
+struct l_ecc_scalar *l_ecc_curve_get_prime(const struct l_ecc_curve *curve=
);
+
+bool l_ecc_scalars_are_equal(const struct l_ecc_scalar *a,
+				const struct l_ecc_scalar *b);
+
+bool l_ecc_points_are_equal(const struct l_ecc_point *a,
+				const struct l_ecc_point *b);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1


--===============5779008863948048066==--

