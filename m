Content-Type: multipart/mixed; boundary="===============2572708342170637520=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] ecc: add checks for zero, one and order
Date: Wed, 10 Apr 2019 11:37:52 -0700
Message-ID: <20190410183752.6176-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2572708342170637520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

To mitigate potential attacks, checks were added to the two
scalar initalization APIs l_ecc_scalar{new,new_random}. After
the scalar is created we check that its not zero or one, and
less than the group order. For new_random we also keep the check
that the scalar is less than the group prime, as this is required
in several RFCs/spec for creating random values.
---
 ell/ecc.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 6182155..d0c7393 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -448,6 +448,20 @@ int _vli_legendre(uint64_t *val, const uint64_t *p, un=
signed int ndigits)
 		return -1;
 }
 =

+static bool vli_is_zero_or_one(const uint64_t *vli, unsigned int ndigits)
+{
+	unsigned int i;
+
+	if (ndigits =3D=3D 0 || vli[0] > 1)
+		return false;
+
+	for (i =3D 1; i < ndigits; i++) {
+		if (vli[i])
+			return false;
+	}
+
+	return true;
+}
 =

 LIB_EXPORT struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *c=
urve)
 {
@@ -584,22 +598,30 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new(
 	if (!c)
 		return NULL;
 =

-	if (buf)
-		_ecc_be2native(c->c, buf, curve->ndigits);
+	if (!buf)
+		return c;
 =

-	return c;
+	_ecc_be2native(c->c, buf, curve->ndigits);
+
+	if (!vli_is_zero_or_one(c->c, curve->ndigits) &&
+				_vli_cmp(c->c, curve->n, curve->ndigits) < 0)
+		return c;
+
+	l_ecc_scalar_free(c);
+
+	return NULL;
 }
 =

 LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new_random(
 					const struct l_ecc_curve *curve)
 {
 	uint64_t r[L_ECC_MAX_DIGITS];
-	uint64_t zero[L_ECC_MAX_DIGITS] =3D { 0 };
 =

 	l_getrandom(r, curve->ndigits * 8);
 =

 	while (_vli_cmp(r, curve->p, curve->ndigits) > 0 ||
-			_vli_cmp(r, zero, curve->ndigits) =3D=3D 0)
+			_vli_cmp(r, curve->n, curve->ndigits) > 0 ||
+			vli_is_zero_or_one(r, curve->ndigits))
 		l_getrandom(r, curve->ndigits * 8);
 =

 	return _ecc_constant_new(curve, r, curve->ndigits * 8);
-- =

2.17.1


--===============2572708342170637520==--

