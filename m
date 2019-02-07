Content-Type: multipart/mixed; boundary="===============3542670622438304456=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] ecc: fix potential buffer overrun
Date: Thu, 07 Feb 2019 10:14:58 -0800
Message-ID: <20190207181458.29466-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3542670622438304456==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_ecc_curve_get_[tls|ike]_group were iterating over curves and assuming
a NULL terminated list which was not the case. This never got caught
because IWD played nice and only got groups it already new existed.

This was changed to iterate over L_ARRAY_SIZE(curves).
---
 ell/ecc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index eeb12dd..88c8373 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -134,9 +134,9 @@ LIB_EXPORT size_t l_ecc_curve_get_scalar_bytes(const st=
ruct l_ecc_curve *curve)
 LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_ike_group(
 							unsigned int group)
 {
-	int i;
+	unsigned int i;
 =

-	for (i =3D 0; curves[i]; i++) {
+	for (i =3D 0; i < L_ARRAY_SIZE(curves); i++) {
 		if (curves[i]->ike_group =3D=3D group)
 			return curves[i];
 	}
@@ -147,9 +147,9 @@ LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_ik=
e_group(
 LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_tls_group(
 							unsigned int group)
 {
-	int i;
+	unsigned int i;
 =

-	for (i =3D 0; curves[i]; i++) {
+	for (i =3D 0; i < L_ARRAY_SIZE(curves); i++) {
 		if (curves[i]->tls_group =3D=3D group)
 			return curves[i];
 	}
-- =

2.17.1


--===============3542670622438304456==--

