Content-Type: multipart/mixed; boundary="===============2980328595033366992=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 1/2] ecc: add l_ecc_curve_get_supported_groups
Date: Tue, 15 Jan 2019 14:43:07 -0800
Message-ID: <20190115224308.6100-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2980328595033366992==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ecc.c   | 18 ++++++++++++++++++
 ell/ecc.h   |  1 +
 ell/ell.sym |  1 +
 3 files changed, 20 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 053e5fb..b2110df 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -90,6 +90,9 @@ static const struct l_ecc_curve *curves[] =3D {
 	&p384,
 };
 =

+static unsigned int supported_groups[L_ARRAY_SIZE(curves) + 1];
+static bool first =3D true;
+
 LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(unsigned int group)
 {
 	int i;
@@ -102,6 +105,21 @@ LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(u=
nsigned int group)
 	return NULL;
 }
 =

+LIB_EXPORT const unsigned int *l_ecc_curve_get_supported_groups(void)
+{
+	if (first) {
+		unsigned int i;
+
+		for (i =3D 0; i < L_ARRAY_SIZE(curves); i++)
+			supported_groups[i] =3D curves[i]->group;
+
+		supported_groups[i] =3D 0;
+		first =3D false;
+	}
+
+	return supported_groups;
+}
+
 static bool ecc_valid_point(struct l_ecc_point *point)
 {
 	const struct l_ecc_curve *curve =3D point->curve;
diff --git a/ell/ecc.h b/ell/ecc.h
index 9a852ff..0c2b33c 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -43,6 +43,7 @@ enum l_ecc_point_type {
 };
 =

 const struct l_ecc_curve *l_ecc_curve_get(unsigned int group);
+const unsigned int *l_ecc_curve_get_supported_groups(void);
 =

 struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *curve);
 struct l_ecc_point *l_ecc_point_from_data(const struct l_ecc_curve *curve,
diff --git a/ell/ell.sym b/ell/ell.sym
index 58b8c8e..4a806aa 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -458,6 +458,7 @@ global:
 	l_certchain_verify;
 	/* ecc */
 	l_ecc_curve_get;
+	l_ecc_curve_get_supported_groups;
 	l_ecc_curve_get_order;
 	l_ecc_curve_get_prime;
 	l_ecc_point_add;
-- =

2.17.1


--===============2980328595033366992==--

