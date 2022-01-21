Content-Type: multipart/mixed; boundary="===============8694471282108061683=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 1/2] ecc: enforce strict length with l_ecc_point_from_data
Date: Fri, 21 Jan 2022 11:36:07 -0800
Message-ID: <20220121193608.2634573-1-prestwoj@gmail.com>

--===============8694471282108061683==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This add some extra convenience to users of l_ecc_point_from_data
allowing the exact length to be verified in addition to creating
the point.
---
 ell/ecc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index a16b1c0..f1adcc4 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -538,8 +538,11 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 	if (!data)
 		return NULL;
 =

-	/* In all cases there should be an X coordinate in data */
-	if (len < bytes)
+	/* Verify the data length matches a full point or X coordinate */
+	if (type =3D=3D L_ECC_POINT_TYPE_FULL) {
+		if (len !=3D bytes * 2)
+			return NULL;
+	} else if (len !=3D bytes)
 		return NULL;
 =

 	p =3D l_ecc_point_new(curve);
@@ -570,9 +573,6 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 =

 		break;
 	case L_ECC_POINT_TYPE_FULL:
-		if (len < bytes * 2)
-			goto failed;
-
 		_ecc_be2native(p->y, (void *) data + bytes, curve->ndigits);
 =

 		if (!ecc_valid_point(p))
-- =

2.31.1

--===============8694471282108061683==--

