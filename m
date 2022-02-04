Content-Type: multipart/mixed; boundary="===============4624226259886533976=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 5/5] ecc: make l_ecc_point_from_data fully constant time
Date: Fri, 04 Feb 2022 09:46:14 -0800
Message-ID: <20220204174614.261669-5-prestwoj@gmail.com>
In-Reply-To: 20220204174614.261669-1-prestwoj@gmail.com

--===============4624226259886533976==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This was modified earlier to be constant time but there was one
minor problem with how 'sub' was determined. That logic could short
circuit which could alter the timing. The change in timing would be
extremely small, especially compared to the previous fix making
_vli_mod_sub() execute always but in any case there would be a small
difference.

This patch uses l_secure_select_byte to select either of the two
subtraction conditions which depend on the point type.
---
 ell/ecc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index eba9aef..d59b900 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -562,10 +562,9 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 		if (!_ecc_compute_y(curve, p->y, p->x))
 			goto failed;
 =

-		sub =3D ((type =3D=3D L_ECC_POINT_TYPE_COMPRESSED_BIT0 &&
-				!(p->y[0] & 1)) ||
-				(type =3D=3D L_ECC_POINT_TYPE_COMPRESSED_BIT1 &&
-				(p->y[0] & 1)));
+		sub =3D l_secure_select_byte(
+				type =3D=3D L_ECC_POINT_TYPE_COMPRESSED_BIT0,
+				!(p->y[1] & 1), p->y[0] & 1);
 =

 		_vli_mod_sub(tmp, curve->p, p->y, curve->p, curve->ndigits);
 =

-- =

2.31.1

--===============4624226259886533976==--

