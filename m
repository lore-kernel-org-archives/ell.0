Content-Type: multipart/mixed; boundary="===============4483557511717383094=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] ecc: make l_ecc_point_from_data const time (for compressed
 points)
Date: Wed, 12 Jan 2022 14:40:55 -0800
Message-ID: <20220112224055.1308675-1-prestwoj@gmail.com>

--===============4483557511717383094==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This only alters the two compressed point types as there isn't a security
reason to make the function const time for compliant/full point data as
these are never used in conjunction with compressed points.

The timing difference came down mainly to the conditional _vli_mod_sub call
which was only called depending on the first bit of p->y. More subtly the
check differered between BIT0 and BIT1 by a '!' operation which would result
in an additional instruction.

This patch addresses the '!' operation by checking if the subtraction is
needed and considering both compressed types in that logic.

For the subtraction, it is now done unconditionally and the result is stored
in a temporary variable. Then l_secure_select is used to copy the data to
p->y, or back into the temporary variable depending on if 'need_sub' evalua=
ted
to true.
---
 ell/ecc.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 24b7cff..5830e01 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -535,6 +535,8 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 {
 	struct l_ecc_point *p;
 	size_t bytes =3D curve->ndigits * 8;
+	uint64_t tmp[L_ECC_MAX_DIGITS];
+	bool sub;
 =

 	if (!data)
 		return NULL;
@@ -554,20 +556,18 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 =

 		break;
 	case L_ECC_POINT_TYPE_COMPRESSED_BIT0:
-		if (!_ecc_compute_y(curve, p->y, p->x))
-			goto failed;
-
-		if (!(p->y[0] & 1))
-			_vli_mod_sub(p->y, curve->p, p->y, curve->p,
-						curve->ndigits);
-		break;
 	case L_ECC_POINT_TYPE_COMPRESSED_BIT1:
 		if (!_ecc_compute_y(curve, p->y, p->x))
 			goto failed;
 =

-		if (p->y[0] & 1)
-			_vli_mod_sub(p->y, curve->p, p->y, curve->p,
-						curve->ndigits);
+		sub =3D ((type =3D=3D L_ECC_POINT_TYPE_COMPRESSED_BIT0 &&
+				!(p->y[0] & 1)) ||
+				(type =3D=3D L_ECC_POINT_TYPE_COMPRESSED_BIT1 &&
+				(p->y[0] & 1)));
+
+		_vli_mod_sub(tmp, curve->p, p->y, curve->p, curve->ndigits);
+
+		l_secure_select(sub, tmp, p->y, p->y, curve->ndigits * 8);
 =

 		break;
 	case L_ECC_POINT_TYPE_FULL:
-- =

2.31.1

--===============4483557511717383094==--

