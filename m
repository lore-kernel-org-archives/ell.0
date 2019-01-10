Content-Type: multipart/mixed; boundary="===============8393970082882542162=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 1/4] ecc: add API's to support EAP-PWD
Date: Thu, 10 Jan 2019 10:53:13 -0800
Message-ID: <20190110185316.27969-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8393970082882542162==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

EAP-PWD requires the following ECC functionality
 - Point multiplication
 - Point addition
 - Point inverse
 - Scalar addition
---
 ell/ecc.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc.h | 14 ++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index c7043ef..8e8d2ac 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -435,3 +435,56 @@ LIB_EXPORT void l_ecc_scalar_free(struct l_ecc_scalar =
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
+					const struct l_ecc_scalar *a,
+					const struct l_ecc_scalar *b,
+					const struct l_ecc_scalar *mod)
+{
+	if (unlikely(!ret || !a || !b || !mod))
+		return false;
+
+	_vli_mod_add(ret->c, a->c, b->c, mod->c, a->curve->ndigits);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_multiply(struct l_ecc_point *ret,
+					const struct l_ecc_scalar *scalar,
+					const struct l_ecc_point *point)
+{
+	if (unlikely(!ret || !scalar || !point))
+		return false;
+
+	_ecc_point_mult(ret, point, scalar->c, NULL, scalar->curve->p);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_add(struct l_ecc_point *ret,
+					const struct l_ecc_point *a,
+					const struct l_ecc_point *b)
+{
+	if (unlikely(!ret || !a || !b))
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
index 569757f..1020724 100644
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
+bool l_ecc_scalar_add(struct l_ecc_scalar *ret, const struct l_ecc_scalar =
*a,
+				const struct l_ecc_scalar *b,
+				const struct l_ecc_scalar *mod);
+
+/* Point operations */
+bool l_ecc_point_multiply(struct l_ecc_point *ret,
+				const struct l_ecc_scalar *scalar,
+				const struct l_ecc_point *point);
+bool l_ecc_point_add(struct l_ecc_point *ret, const struct l_ecc_point *a,
+				const struct l_ecc_point *b);
+bool l_ecc_point_inverse(struct l_ecc_point *p);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.17.1


--===============8393970082882542162==--

