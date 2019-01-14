Content-Type: multipart/mixed; boundary="===============7782114111913565652=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] ecc: add API to get supported groups
Date: Mon, 14 Jan 2019 12:45:05 -0800
Message-ID: <20190114204505.19193-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7782114111913565652==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Protocols using ECC need a way to query which groups ELL supports. ecc.c
now has a zero-terminated  list of supported groups, which is returned
by l_ecc_curve_get_groups().
---
 ell/ecc.c | 7 +++++++
 ell/ecc.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 053e5fb..ff03f24 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -85,6 +85,8 @@ static const struct l_ecc_curve p384 =3D {
 	.b =3D P384_CURVE_B
 };
 =

+static const unsigned int ecc_groups[] =3D { 19, 20, 0 };
+
 static const struct l_ecc_curve *curves[] =3D {
 	&p256,
 	&p384,
@@ -102,6 +104,11 @@ LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(u=
nsigned int group)
 	return NULL;
 }
 =

+LIB_EXPORT const unsigned int *l_ecc_curve_get_groups(void)
+{
+	return ecc_groups;
+}
+
 static bool ecc_valid_point(struct l_ecc_point *point)
 {
 	const struct l_ecc_curve *curve =3D point->curve;
diff --git a/ell/ecc.h b/ell/ecc.h
index 9a852ff..cb6ab50 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -43,6 +43,7 @@ enum l_ecc_point_type {
 };
 =

 const struct l_ecc_curve *l_ecc_curve_get(unsigned int group);
+const unsigned int *l_ecc_curve_get_groups(void);
 =

 struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *curve);
 struct l_ecc_point *l_ecc_point_from_data(const struct l_ecc_curve *curve,
-- =

2.17.1


--===============7782114111913565652==--

