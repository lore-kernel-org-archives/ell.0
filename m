Content-Type: multipart/mixed; boundary="===============3474882366086210092=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/2] ecc: add API's to support EAP-PWD
Date: Wed, 09 Jan 2019 09:10:39 -0800
Message-ID: <20190109171040.32584-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3474882366086210092==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

EAP-PWD requires the following ECC functionality
 - Point multiplication
 - Point addition
 - Point inverse
 - Scalar addition
---
 ell/ecc.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc.h | 14 ++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 6d9ab42..c7e7089 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -433,3 +433,55 @@ LIB_EXPORT void l_ecc_scalar_free(struct l_ecc_scalar =
*c)
 	memset(c->c, 0, c->curve->ndigits * 8);
 	l_free(c);
 }
+
+LIB_EXPORT struct l_ecc_scalar *l_ecc_curve_get_order(
+						const struct l_ecc_curve *curve)
+{
+	return _ecc_constant_new(curve, (void *) curve->n, curve->ndigits * 8);
+}
+
+LIB_EXPORT bool l_ecc_scalar_add(struct l_ecc_scalar *ret,
+					struct l_ecc_scalar *a,
+					struct l_ecc_scalar *b,
+					struct l_ecc_scalar *mod)
+{
+	if (unlikely(!ret) || unlikely(!a) || unlikely(!b) || unlikely(!mod))
+		return false;
+
+	_vli_mod_add(ret->c, a->c, b->c, mod->c, a->curve->ndigits);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_multiply(struct l_ecc_point *ret,
+					struct l_ecc_scalar *scalar,
+					struct l_ecc_point *point)
+{
+	if (unlikely(!ret) || unlikely(!scalar) || unlikely(!point))
+		return false;
+
+	_ecc_point_mult(ret, point, scalar->c, NULL, scalar->curve->p);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_add(struct l_ecc_point *ret, struct l_ecc_poin=
t *a,
+					struct l_ecc_point *b)
+{
+	if (unlikely(!ret) || unlikely(!a) || unlikely(!b))
+		return false;
+
+	_ecc_point_add(ret, a, b, a->curve->p);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_inverse(struct l_ecc_point *p)
+{
+	if (unlikely(!p))
+		return false;
+
+	_vli_mod_sub(p->y, p->curve->p, p->y, p->curve->p, p->curve->ndigits);
+
+	return true;
+}
diff --git a/ell/ecc.h b/ell/ecc.h
index 40c7d47..fd10f16 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -61,6 +61,20 @@ ssize_t l_ecc_scalar_get_data(const struct l_ecc_scalar =
*c, void *buf,
 					size_t len);
 void l_ecc_scalar_free(struct l_ecc_scalar *c);
 =

+/* Constant operations */
+struct l_ecc_scalar *l_ecc_curve_get_order(const struct l_ecc_curve *curve=
);
+bool l_ecc_scalar_add(struct l_ecc_scalar *ret, struct l_ecc_scalar *a,
+				struct l_ecc_scalar *b,
+				struct l_ecc_scalar *mod);
+
+/* Point operations */
+bool l_ecc_point_multiply(struct l_ecc_point *ret,
+				struct l_ecc_scalar *scalar,
+				struct l_ecc_point *point);
+bool l_ecc_point_add(struct l_ecc_point *ret, struct l_ecc_point *a,
+				struct l_ecc_point *b);
+bool l_ecc_point_inverse(struct l_ecc_point *p);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1


--===============3474882366086210092==--

