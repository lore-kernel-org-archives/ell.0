Content-Type: multipart/mixed; boundary="===============5137803123044327022=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/2] unit: update test-ecc and test-ecdh with new ECC APIs
Date: Wed, 16 Jan 2019 11:08:01 -0800
Message-ID: <20190116190801.25091-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190116190801.25091-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5137803123044327022==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-ecc.c  | 2 +-
 unit/test-ecdh.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/unit/test-ecc.c b/unit/test-ecc.c
index 547d157..821640d 100644
--- a/unit/test-ecc.c
+++ b/unit/test-ecc.c
@@ -218,7 +218,7 @@ static void run_test_p256(const void *arg)
 			scalar[L_ECC_MAX_DIGITS], result[L_ECC_MAX_DIGITS],
 			check[L_ECC_MAX_DIGITS];
 	struct l_ecc_point point1, point2, point_ret;
-	const struct l_ecc_curve *curve =3D l_ecc_curve_get(19);
+	const struct l_ecc_curve *curve =3D l_ecc_curve_get_ike_group(19);
 =

 	point_ret.curve =3D curve;
 =

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index 9ddf71d..0b58ead 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -65,7 +65,7 @@ bool __wrap_l_getrandom(void *buf, size_t len)
  */
 static void test_basic(const void *data)
 {
-	const struct l_ecc_curve *curve =3D l_ecc_curve_get(19);
+	const struct l_ecc_curve *curve =3D l_ecc_curve_get_ike_group(19);
 =

 	struct l_ecc_scalar *private1;
 	struct l_ecc_scalar *private2;
@@ -97,7 +97,7 @@ static void test_basic(const void *data)
  */
 static void test_vector_p256(const void *data)
 {
-	const struct l_ecc_curve *curve =3D l_ecc_curve_get(19);
+	const struct l_ecc_curve *curve =3D l_ecc_curve_get_ike_group(19);
 =

 	uint64_t a_sec_buf[4] =3D { 0x867B7291D507A3AFull, 0x3FAF432A5ABCE59Eull,
 				0xE96A8E337A128499ull, 0x814264145F2F56F2ull };
@@ -157,7 +157,7 @@ static void test_vector_p256(const void *data)
  */
 static void test_vector_p384(const void *data)
 {
-	const struct l_ecc_curve *curve =3D l_ecc_curve_get(20);
+	const struct l_ecc_curve *curve =3D l_ecc_curve_get_ike_group(20);
 =

 	uint64_t a_sec_buf[6] =3D { 0x86F05FEADB9376F1ull, 0xD706A90CBCB5DF29ull,
 				0xD709EE7A7962A156ull, 0x5DFD8A7965571C48ull,
-- =

2.17.1


--===============5137803123044327022==--

