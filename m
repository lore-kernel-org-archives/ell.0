Content-Type: multipart/mixed; boundary="===============8462859815053477669=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 4/4] ecc: Updated _ecc_point_mult to match kernel
Date: Thu, 10 Jan 2019 10:53:16 -0800
Message-ID: <20190110185316.27969-4-james.prestwood@linux.intel.com>
In-Reply-To: <20190110185316.27969-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8462859815053477669==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Commit 3da2c1dfdb802b184eea0653d1e589515b52d74b was added to the kernel
which addressed potential timing attacks. This updates our ecc code with
the same fix. It was slightly modified to not change the internal API
parameters (we can get the curve from the point, rather than passing in
the curve structure).
---
 ell/ecc-external.c | 43 ++++++++++---------------------------------
 1 file changed, 10 insertions(+), 33 deletions(-)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index 71b3e68..1c118c2 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -68,37 +68,6 @@ static uint64_t vli_test_bit(const uint64_t *vli, unsign=
ed int bit)
 	return (vli[bit / 64] & ((uint64_t) 1 << (bit % 64)));
 }
 =

-/* Counts the number of 64-bit "digits" in vli. */
-static unsigned int vli_num_digits(const uint64_t *vli, unsigned int ndigi=
ts)
-{
-	int i;
-
-	/* Search from the end until we find a non-zero digit.
-	 * We do it in reverse because we expect that most digits will
-	 * be nonzero.
-	 */
-	for (i =3D ndigits - 1; i >=3D 0 && vli[i] =3D=3D 0; i--);
-
-	return (i + 1);
-}
-
-/* Counts the number of bits required for vli. */
-static unsigned int vli_num_bits(const uint64_t *vli, unsigned int ndigits)
-{
-	unsigned int i, num_digits;
-	uint64_t digit;
-
-	num_digits =3D vli_num_digits(vli, ndigits);
-	if (num_digits =3D=3D 0)
-		return 0;
-
-	digit =3D vli[num_digits - 1];
-	for (i =3D 0; digit; i++)
-		digit >>=3D 1;
-
-	return ((num_digits - 1) * 64 + i);
-}
-
 /* Sets dest =3D src. */
 static void vli_set(uint64_t *dest, const uint64_t *src, unsigned int ndig=
its)
 {
@@ -916,12 +885,20 @@ void _ecc_point_mult(struct l_ecc_point *result,
 			uint64_t *initial_z, const uint64_t *curve_prime)
 {
 	/* R0 and R1 */
+	const struct l_ecc_curve *curve =3D point->curve;
 	uint64_t rx[2][L_ECC_MAX_DIGITS];
 	uint64_t ry[2][L_ECC_MAX_DIGITS];
 	uint64_t z[L_ECC_MAX_DIGITS];
+	uint64_t sk[2][L_ECC_MAX_DIGITS];
 	int i, nb;
-	unsigned int ndigits =3D point->curve->ndigits;
-	int num_bits =3D vli_num_bits(scalar, ndigits);
+	unsigned int ndigits =3D curve->ndigits;
+	int num_bits;
+	int carry;
+
+	carry =3D vli_add(sk[0], scalar, curve->n, ndigits);
+	vli_add(sk[1], sk[0], curve->n, ndigits);
+	scalar =3D sk[!carry];
+	num_bits =3D sizeof(uint64_t) * ndigits * 8 + 1;
 =

 	vli_set(rx[1], point->x, ndigits);
 	vli_set(ry[1], point->y, ndigits);
-- =

2.17.1


--===============8462859815053477669==--

