Content-Type: multipart/mixed; boundary="===============0314569906278976203=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/3] ecc: implement P384 fast modulus
Date: Tue, 11 Dec 2018 16:28:58 -0800
Message-ID: <20181212002900.11739-2-james.prestwood@linux.intel.com>
In-Reply-To: <20181212002900.11739-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0314569906278976203==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This algorithm is defined in an IEICE paper:

"Simple Power Analysis on Fast Modular Reduction with Generalized Mersenne
 Prime for Elliptic Curve Cryptosystems"

Unlike the existing P192/P256 algorithms, a macro was written to deal with
converting from 32 bit chunks into 64 bits. This also makes the algorithm
much easier to read since the C values are used directly.
---
 ell/ecc-external.c | 129 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 129 insertions(+)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index 7ddf865..9165bd6 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -455,6 +455,132 @@ static void vli_mmod_fast_256(uint64_t *result, const=
 uint64_t *product,
 	}
 }
 =

+/*
+ * The NIST algorithms define S values, which are comprised of 32 bit C va=
lues
+ * of the original product we are trying to reduce. Since we are working w=
ith
+ * 64 bit 'digits', we need to convert these C values into 64 bit chunks. =
This
+ * macro mainly makes code readability easier since we can directly pass t=
he
+ * two C indexes (h and l). Some of these C values are zero, which is also=
 a
+ * value C index. In this case -1 should be passed to indicate zero.
+ */
+#define ECC_SET_S(prod, h, l) ({ 				\
+	uint64_t r =3D 0;						\
+	if (h =3D=3D -1) {						\
+		/* zero, don't do anything */			\
+	} else if (h & 1)					\
+		r |=3D (prod[h / 2] & 0xffffffff00000000ull);	\
+	else							\
+		r |=3D (prod[h / 2] << 32);			\
+	if (l =3D=3D -1) {						\
+		/* zero, don't do anything */			\
+	} else if (l & 1)					\
+		r |=3D (prod[l / 2] >> 32);			\
+	else							\
+		r |=3D (prod[l / 2] & 0xffffffff);		\
+	r;							\
+})
+
+static void vli_mmod_fast_384(uint64_t *result, const uint64_t *product,
+				const uint64_t *curve_prime, uint64_t *tmp)
+{
+	int carry;
+	const unsigned int ndigits =3D 6;
+
+	/* t */
+	vli_set(result, product, ndigits);
+
+	/* s1 */
+	tmp[0] =3D 0;
+	tmp[1] =3D 0;
+	tmp[2] =3D ECC_SET_S(product, 22, 21);
+	tmp[3] =3D ECC_SET_S(product, -1, 23);
+	tmp[4] =3D 0;
+	tmp[5] =3D 0;
+	carry =3D vli_lshift(tmp, tmp, 1, ndigits);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s2 */
+	tmp[0] =3D product[6];
+	tmp[1] =3D product[7];
+	tmp[2] =3D product[8];
+	tmp[3] =3D product[9];
+	tmp[4] =3D product[10];
+	tmp[5] =3D product[11];
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s3 */
+	tmp[0] =3D ECC_SET_S(product, 22, 21);
+	tmp[1] =3D ECC_SET_S(product, 12, 23);
+	tmp[2] =3D ECC_SET_S(product, 14, 13);
+	tmp[3] =3D ECC_SET_S(product, 16, 15);
+	tmp[4] =3D ECC_SET_S(product, 18, 17);
+	tmp[5] =3D ECC_SET_S(product, 20, 19);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s4 */
+	tmp[0] =3D ECC_SET_S(product, 23, -1);
+	tmp[1] =3D ECC_SET_S(product, 20, -1);
+	tmp[2] =3D ECC_SET_S(product, 13, 12);
+	tmp[3] =3D ECC_SET_S(product, 15, 14);
+	tmp[4] =3D ECC_SET_S(product, 17, 16);
+	tmp[5] =3D ECC_SET_S(product, 19, 18);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s5 */
+	tmp[0] =3D 0;
+	tmp[1] =3D 0;
+	tmp[2] =3D ECC_SET_S(product, 21, 20);
+	tmp[3] =3D ECC_SET_S(product, 23, 22);
+	tmp[4] =3D 0;
+	tmp[5] =3D 0;
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s6 */
+	tmp[0] =3D ECC_SET_S(product, -1, 20);
+	tmp[1] =3D ECC_SET_S(product, 21, -1);
+	tmp[2] =3D ECC_SET_S(product, 23, 22);
+	tmp[3] =3D 0;
+	tmp[4] =3D 0;
+	tmp[5] =3D 0;
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s7 */
+	tmp[0] =3D ECC_SET_S(product, 12, 23);
+	tmp[1] =3D ECC_SET_S(product, 14, 13);
+	tmp[2] =3D ECC_SET_S(product, 16, 15);
+	tmp[3] =3D ECC_SET_S(product, 18, 17);
+	tmp[4] =3D ECC_SET_S(product, 20, 19);
+	tmp[5] =3D ECC_SET_S(product, 22, 21);
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	/* s8 */
+	tmp[0] =3D ECC_SET_S(product, 20, -1);
+	tmp[1] =3D ECC_SET_S(product, 22, 21);
+	tmp[2] =3D ECC_SET_S(product, -1, 23);
+	tmp[3] =3D 0;
+	tmp[4] =3D 0;
+	tmp[5] =3D 0;
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	/* s9 */
+	tmp[0] =3D 0;
+	tmp[1] =3D ECC_SET_S(product, 23, -1);
+	tmp[2] =3D ECC_SET_S(product, -1, 23);
+	tmp[3] =3D 0;
+	tmp[4] =3D 0;
+	tmp[5] =3D 0;
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	if (carry < 0) {
+		do {
+			carry +=3D vli_add(result, result, curve_prime, ndigits);
+		} while (carry < 0);
+	} else {
+		while (carry || _vli_cmp(curve_prime, result, ndigits) !=3D 1)
+			carry -=3D vli_sub(result, result, curve_prime, ndigits);
+	}
+}
+
 /* Computes result =3D product % curve_prime
  *  from http://www.nsa.gov/ia/_files/nist-routines.pdf
 */
@@ -471,6 +597,9 @@ static bool vli_mmod_fast(uint64_t *result, uint64_t *p=
roduct,
 	case 4:
 		vli_mmod_fast_256(result, product, curve_prime, tmp);
 		break;
+	case 6:
+		vli_mmod_fast_384(result, product, curve_prime, tmp);
+		break;
 	default:
 		return false;
 	}
-- =

2.17.1


--===============0314569906278976203==--

