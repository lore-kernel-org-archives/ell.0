Content-Type: multipart/mixed; boundary="===============5841921150929475358=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/3] ecc: added P384 curve definition
Date: Tue, 11 Dec 2018 16:28:59 -0800
Message-ID: <20181212002900.11739-3-james.prestwood@linux.intel.com>
In-Reply-To: <20181212002900.11739-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5841921150929475358==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ecc.c | 30 ++++++++++++++++++++++++++++++
 ell/ecc.h |  2 +-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 05e2098..9421cd7 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -36,8 +36,38 @@ static struct l_ecc_curve p256 =3D {
 	.b =3D P256_CURVE_B,
 };
 =

+#define P384_CURVE_P {	0x00000000FFFFFFFFull, 0xFFFFFFFF00000000ull, \
+			0xFFFFFFFFFFFFFFFEull, 0xFFFFFFFFFFFFFFFFull, \
+			0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFFFFFFFFFFull }
+#define P384_CURVE_GX {	0x3A545E3872760AB7ull, 0x5502F25DBF55296Cull, \
+			0x59F741E082542A38ull, 0x6E1D3B628BA79B98ull, \
+			0x8EB1C71EF320AD74ull, 0xAA87CA22BE8B0537ull }
+#define P384_CURVE_GY {	0x7A431D7C90EA0E5Full, 0x0A60B1CE1D7E819Dull, \
+			0xE9DA3113B5F0B8C0ull, 0xF8F41DBD289A147Cull, \
+			0x5D9E98BF9292DC29ull, 0x3617DE4A96262C6Full }
+#define P384_CURVE_N {	0xECEC196ACCC52973ull, 0x581A0DB248B0A77Aull, \
+			0xC7634D81F4372DDFull, 0xFFFFFFFFFFFFFFFFull, \
+			0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFFFFFFFFFFull }
+#define P384_CURVE_B {	0x2A85C8EDD3EC2AEFull, 0xC656398D8A2ED19Dull, \
+			0x0314088F5013875Aull, 0x181D9C6EFE814112ull, \
+			0x988E056BE3F82D19ull, 0xB3312FA7E23EE7E4ull }
+
+static struct l_ecc_curve p384 =3D {
+	.group =3D 20,
+	.ndigits =3D 6,
+	.g =3D {
+		.x =3D P384_CURVE_GX,
+		.y =3D P384_CURVE_GY,
+		.curve =3D &p384
+	},
+	.p =3D P384_CURVE_P,
+	.n =3D P384_CURVE_N,
+	.b =3D P384_CURVE_B
+};
+
 static struct l_ecc_curve *curves[] =3D {
 	&p256,
+	&p384,
 };
 =

 LIB_EXPORT const struct l_ecc_curve *l_ecc_curve_get(unsigned int group)
diff --git a/ell/ecc.h b/ell/ecc.h
index 2d207af..40c7d47 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -27,7 +27,7 @@
 extern "C" {
 #endif
 =

-#define L_ECC_MAX_DIGITS 4
+#define L_ECC_MAX_DIGITS 6
 #define L_ECC_SCALAR_MAX_BYTES		L_ECC_MAX_DIGITS * 8
 #define L_ECC_POINT_MAX_BYTES		L_ECC_SCALAR_MAX_BYTES * 2
 =

-- =

2.17.1


--===============5841921150929475358==--

