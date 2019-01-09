Content-Type: multipart/mixed; boundary="===============3242096403622998067=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/2] ecc: added API's to support SAE
Date: Wed, 09 Jan 2019 09:10:40 -0800
Message-ID: <20190109171040.32584-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190109171040.32584-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3242096403622998067==
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
 ell/ecc.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc.h | 12 +++++++++++
 2 files changed, 71 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index c7e7089..b6b2cd6 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -485,3 +485,62 @@ LIB_EXPORT bool l_ecc_point_inverse(struct l_ecc_point=
 *p)
 =

 	return true;
 }
+
+LIB_EXPORT bool l_ecc_scalar_multiply(struct l_ecc_scalar *ret,
+					struct l_ecc_scalar *a,
+					struct l_ecc_scalar *b)
+{
+	if (unlikely(!ret) || unlikely(!a) || unlikely(!b))
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
+					struct l_ecc_scalar *x)
+{
+	if (unlikely(!ret) || unlikely(!x))
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
+LIB_EXPORT bool l_ecc_scalars_are_equal(struct l_ecc_scalar *a,
+						struct l_ecc_scalar *b)
+{
+	if (unlikely(!a) || unlikely(!b))
+		return false;
+
+	return (memcmp(a->c, b->c, a->curve->ndigits * 8) =3D=3D 0);
+}
+
+LIB_EXPORT bool l_ecc_points_are_equal(struct l_ecc_point *a,
+						struct l_ecc_point *b)
+{
+	if (unlikely(!a) || unlikely(!b))
+		return false;
+
+	return ((memcmp(a->x, b->x, a->curve->ndigits * 8) =3D=3D 0) &&
+			(memcmp(a->y, b->y, a->curve->ndigits * 8)));
+}
diff --git a/ell/ecc.h b/ell/ecc.h
index fd10f16..dc3d9c3 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -75,6 +75,18 @@ bool l_ecc_point_add(struct l_ecc_point *ret, struct l_e=
cc_point *a,
 				struct l_ecc_point *b);
 bool l_ecc_point_inverse(struct l_ecc_point *p);
 =

+/* extra operations needed for SAE */
+bool l_ecc_scalar_multiply(struct l_ecc_scalar *ret, struct l_ecc_scalar *=
a,
+				struct l_ecc_scalar *b);
+int l_ecc_scalar_legendre(struct l_ecc_scalar *value);
+bool l_ecc_scalar_sum_x(struct l_ecc_scalar *ret, struct l_ecc_scalar *x);
+
+struct l_ecc_scalar *l_ecc_curve_get_prime(const struct l_ecc_curve *curve=
);
+
+bool l_ecc_scalars_are_equal(struct l_ecc_scalar *a, struct l_ecc_scalar *=
b);
+
+bool l_ecc_points_are_equal(struct l_ecc_point *a, struct l_ecc_point *b);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1


--===============3242096403622998067==--

