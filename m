Content-Type: multipart/mixed; boundary="===============3968827513265564230=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/2] ecc: clarify curves to group mapping
Date: Wed, 16 Jan 2019 11:08:00 -0800
Message-ID: <20190116190801.25091-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3968827513265564230==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

RFC 5114 defines the ECC group numbers, and depending on if your using
TLS these group numbers differ. Rather than TLS maintaining the mapping
between TLS group numbers and IKE group numbers we store both group
numbers in the curve structures as 'ike_group' and 'tls_group'. Also,
the curve name was added.

There are now several new APIs where you can get a curve for either
tls or ike, as well as get a curve by group name. Similarly there is
a set of APIs for getting supported groups for both ike and tls.
---
 ell/ecc-private.h |  4 ++-
 ell/ecc.c         | 83 ++++++++++++++++++++++++++++++++++++++++-------
 ell/ecc.h         |  8 +++--
 ell/tls-suites.c  |  4 +--
 4 files changed, 82 insertions(+), 17 deletions(-)

diff --git a/ell/ecc-private.h b/ell/ecc-private.h
index 3863620..0e85d98 100644
--- a/ell/ecc-private.h
+++ b/ell/ecc-private.h
@@ -35,7 +35,9 @@ struct l_ecc_point {
 =

 struct l_ecc_curve {
 	unsigned int ndigits;
-	unsigned int group;
+	unsigned int ike_group;
+	unsigned int tls_group;
+	const char *name;
 	struct l_ecc_point g;
 	uint64_t p[L_ECC_MAX_DIGITS];
 	uint64_t n[L_ECC_MAX_DIGITS];
diff --git a/ell/ecc.c b/ell/ecc.c
index 2b63432..dd2e11a 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -47,7 +47,9 @@
 			0xB3EBBD55769886BCull, 0x5AC635D8AA3A93E7ull }
 =

 static const struct l_ecc_curve p256 =3D {
-	.group =3D 19,
+	.name =3D "secp256r1",
+	.ike_group =3D 19,
+	.tls_group =3D 23,
 	.ndigits =3D 4,
 	.g =3D {
 		.x =3D P256_CURVE_GX,
@@ -79,7 +81,9 @@ static const struct l_ecc_curve p256 =3D {
 			0x988E056BE3F82D19ull, 0xB3312FA7E23EE7E4ull }
 =

 static const struct l_ecc_curve p384 =3D {
-	.group =3D 20,
+	.name =3D "secp384r1",
+	.ike_group =3D 20,
+	.tls_group =3D 24,
 	.ndigits =3D 6,
 	.g =3D {
 		.x =3D P384_CURVE_GX,
@@ -96,34 +100,89 @@ static const struct l_ecc_curve *curves[] =3D {
 	&p384,
 };
 =

-LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(unsigned int group)
+LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(const char *name)
+{
+	int i;
+
+	if (unlikely(!name))
+		return NULL;
+
+	for (i =3D 0; curves[i]; i++) {
+		if (!strcmp(curves[i]->name, name))
+			return curves[i];
+	}
+
+	return NULL;
+}
+
+LIB_EXPORT const char *l_ecc_curve_get_name(const struct l_ecc_curve *curv=
e)
+{
+	if (unlikely(!curve))
+		return NULL;
+
+	return curve->name;
+}
+
+LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_ike_group(
+							unsigned int group)
+{
+	int i;
+
+	for (i =3D 0; curves[i]; i++) {
+		if (curves[i]->ike_group =3D=3D group)
+			return curves[i];
+	}
+
+	return NULL;
+}
+
+LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get_tls_group(
+							unsigned int group)
 {
 	int i;
 =

 	for (i =3D 0; curves[i]; i++) {
-		if (curves[i]->group =3D=3D group)
+		if (curves[i]->tls_group =3D=3D group)
 			return curves[i];
 	}
 =

 	return NULL;
 }
 =

-LIB_EXPORT const unsigned int *l_ecc_curve_get_supported_groups(void)
+LIB_EXPORT const unsigned int *l_ecc_curve_get_supported_ike_groups(void)
+{
+	static unsigned int supported_ike_groups[L_ARRAY_SIZE(curves) + 1];
+	static bool ike_first =3D true;
+
+	if (ike_first) {
+		unsigned int i;
+
+		for (i =3D 0; i < L_ARRAY_SIZE(curves); i++)
+			supported_ike_groups[i] =3D curves[i]->ike_group;
+
+		supported_ike_groups[i] =3D 0;
+		ike_first =3D false;
+	}
+
+	return supported_ike_groups;
+}
+
+LIB_EXPORT const unsigned int *l_ecc_curve_get_supported_tls_groups(void)
 {
-	static unsigned int supported_groups[L_ARRAY_SIZE(curves) + 1];
-	static bool first =3D true;
+	static unsigned int supported_tls_groups[L_ARRAY_SIZE(curves) + 1];
+	static bool tls_first =3D true;
 =

-	if (first) {
+	if (tls_first) {
 		unsigned int i;
 =

 		for (i =3D 0; i < L_ARRAY_SIZE(curves); i++)
-			supported_groups[i] =3D curves[i]->group;
+			supported_tls_groups[i] =3D curves[i]->tls_group;
 =

-		supported_groups[i] =3D 0;
-		first =3D false;
+		supported_tls_groups[i] =3D 0;
+		tls_first =3D false;
 	}
 =

-	return supported_groups;
+	return supported_tls_groups;
 }
 =

 static bool ecc_valid_point(struct l_ecc_point *point)
diff --git a/ell/ecc.h b/ell/ecc.h
index 0c2b33c..e867ef9 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -42,8 +42,12 @@ enum l_ecc_point_type {
 	L_ECC_POINT_TYPE_FULL =3D 0x04,
 };
 =

-const struct l_ecc_curve *l_ecc_curve_get(unsigned int group);
-const unsigned int *l_ecc_curve_get_supported_groups(void);
+const struct l_ecc_curve *l_ecc_curve_get(const char *name);
+const char *l_ecc_curve_get_name(const struct l_ecc_curve *curve);
+const unsigned int *l_ecc_curve_get_supported_ike_groups(void);
+const unsigned int *l_ecc_curve_get_supported_tls_groups(void);
+const struct l_ecc_curve *l_ecc_curve_get_ike_group(unsigned int group);
+const struct l_ecc_curve *l_ecc_curve_get_tls_group(unsigned int group);
 =

 struct l_ecc_point *l_ecc_point_new(const struct l_ecc_curve *curve);
 struct l_ecc_point *l_ecc_point_from_data(const struct l_ecc_curve *curve,
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d99f08b..330a323 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -428,7 +428,7 @@ static bool tls_send_ecdhe_server_key_xchg(struct l_tls=
 *tls)
 	 */
 =

 	params =3D l_new(struct tls_ecdhe_params, 1);
-	params->curve =3D l_ecc_curve_get(tls->negotiated_curve->ec.l_group);
+	params->curve =3D l_ecc_curve_get_tls_group(tls->negotiated_curve->id);
 	tls->pending.key_xchg_params =3D params;
 =

 	if (!l_ecdh_generate_key_pair(params->curve,
@@ -510,7 +510,7 @@ static void tls_handle_ecdhe_server_key_xchg(struct l_t=
ls *tls,
 	 * format is used.
 	 */
 	params =3D l_new(struct tls_ecdhe_params, 1);
-	params->curve =3D l_ecc_curve_get(tls->negotiated_curve->ec.l_group);
+	params->curve =3D l_ecc_curve_get_tls_group(tls->negotiated_curve->id);
 	params->public =3D l_ecc_point_from_data(params->curve,
 						L_ECC_POINT_TYPE_FULL,
 						buf, len);
-- =

2.17.1


--===============3968827513265564230==--

