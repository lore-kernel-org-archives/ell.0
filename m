Content-Type: multipart/mixed; boundary="===============5708688243717604904=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 1/9] ecc: moved ecc from IWD into ell
Date: Thu, 29 Nov 2018 14:08:00 -0800
Message-ID: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5708688243717604904==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

IWD had its own implementation for ECC and math operations. Eventually
TLS will indirectly require this (via ECDH) so it made sense to move
everything into ell. Some changes had to be made to the original file
to accomidate the ell style.

The original file (ecc.c) required some changes. The ecc_point type
is now exposed as l_ecc_point. Several vli_ functions were prefixed
with "_" so they could be exposed privately. All ecc functions
that needed to be exposed as library API's were prefixed with l_ecc,
and changed to take a l_ecc_curve object, explained below.

A new type was also added, l_ecc_curve, which holds all the information
for a given curve. Users will call l_curve_get(int group) to get a
supported curve object. This curve object can then be passed to all
l_ecc API's which avoids the need for the user to know any of the
curve parameters (prime, g, n, b, etc.) or vli lengths. Some of these
parameters may still need to be obtained, so several getters were added
as well.

When using any of the l_ecc API's, any vli integers should be
created as a uint64_t array of size L_ECC_MAX_DIGITS. This ensures
that the integer will support all supported curves. L_ECC_MAX_DIGITS
should also be updated if any larger bit size curves are added.
---
 Makefile.am       |    8 +-
 ell/ecc-private.h |   50 ++
 ell/ecc.c         | 1288 +++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc.h         |   84 +++
 ell/ell.h         |    1 +
 5 files changed, 1429 insertions(+), 2 deletions(-)
 create mode 100644 ell/ecc-private.h
 create mode 100644 ell/ecc.c
 create mode 100644 ell/ecc.h

diff --git a/Makefile.am b/Makefile.am
index d115360..4e5f01b 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -49,7 +49,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/dir.h \
 			ell/net.h \
 			ell/dhcp.h \
-			ell/cert.h
+			ell/cert.h \
+			ell/ecc.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -112,7 +113,10 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp-transport.c \
 			ell/dhcp-lease.c \
 			ell/cert.c \
-			ell/cert-private.h
+			ell/cert-private.h \
+			ell/ecc-private.h \
+			ell/ecc.h \
+			ell/ecc.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ecc-private.h b/ell/ecc-private.h
new file mode 100644
index 0000000..7e0c7f8
--- /dev/null
+++ b/ell/ecc-private.h
@@ -0,0 +1,50 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018 Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#include <stdbool.h>
+#include <stdint.h>
+
+struct l_ecc_curve;
+
+void _vli_mod_inv(uint64_t *result, const uint64_t *input, const uint64_t =
*mod,
+			unsigned int ndigits);
+
+void _vli_mod_sub(uint64_t *result, const uint64_t *left, const uint64_t *=
right,
+		const uint64_t *curve_prime, unsigned int ndigits);
+
+void _vli_mod_add(uint64_t *result, const uint64_t *left, const uint64_t *=
right,
+			const uint64_t *curve_prime, unsigned int ndigits);
+
+void _vli_rshift1(uint64_t *vli, unsigned int ndigits);
+
+void _vli_mod_mult_fast(uint64_t *result, const uint64_t *left,
+		const uint64_t *right, const uint64_t *curve_prime,
+		unsigned int ndigits);
+
+void _vli_mod_exp(uint64_t *result, uint64_t *base, uint64_t *exp,
+		const uint64_t *mod, unsigned int ndigits);
+
+int _vli_cmp(const uint64_t *left, const uint64_t *right, unsigned int ndi=
gits);
+
+int _vli_legendre(uint64_t *val, const uint64_t *p, unsigned int ndigits);
+
+bool _ecc_compute_y(struct l_ecc_curve *curve, uint64_t *y, uint64_t *x);
diff --git a/ell/ecc.c b/ell/ecc.c
new file mode 100644
index 0000000..b3ddf30
--- /dev/null
+++ b/ell/ecc.c
@@ -0,0 +1,1288 @@
+/*
+ * Copyright (c) 2013, Kenneth MacKay
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are
+ * met:
+ *  * Redistributions of source code must retain the above copyright
+ *   notice, this list of conditions and the following disclaimer.
+ *  * Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <linux/types.h>
+#include <stdint.h>
+#include <stdbool.h>
+
+#include "private.h"
+#include "ecc.h"
+#include "ecc-private.h"
+#include "random.h"
+
+typedef struct {
+	uint64_t m_low;
+	uint64_t m_high;
+} uint128_t;
+
+static void vli_clear(uint64_t *vli, unsigned int ndigits)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++)
+		vli[i] =3D 0;
+}
+
+/* Returns true if vli =3D=3D 0, false otherwise. */
+static bool vli_is_zero(const uint64_t *vli, unsigned int ndigits)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++) {
+		if (vli[i])
+			return false;
+	}
+
+	return true;
+}
+
+/* Returns nonzero if bit bit of vli is set. */
+static uint64_t vli_test_bit(const uint64_t *vli, unsigned int bit)
+{
+	return (vli[bit / 64] & ((uint64_t) 1 << (bit % 64)));
+}
+
+/* Counts the number of 64-bit "digits" in vli. */
+static unsigned int vli_num_digits(const uint64_t *vli, unsigned int ndigi=
ts)
+{
+	int i;
+
+	/* Search from the end until we find a non-zero digit.
+	 * We do it in reverse because we expect that most digits will
+	 * be nonzero.
+	 */
+	for (i =3D ndigits - 1; i >=3D 0 && vli[i] =3D=3D 0; i--);
+
+	return (i + 1);
+}
+
+/* Counts the number of bits required for vli. */
+static unsigned int vli_num_bits(const uint64_t *vli, unsigned int ndigits)
+{
+	unsigned int i, num_digits;
+	uint64_t digit;
+
+	num_digits =3D vli_num_digits(vli, ndigits);
+	if (num_digits =3D=3D 0)
+		return 0;
+
+	digit =3D vli[num_digits - 1];
+	for (i =3D 0; digit; i++)
+		digit >>=3D 1;
+
+	return ((num_digits - 1) * 64 + i);
+}
+
+/* Sets dest =3D src. */
+static void vli_set(uint64_t *dest, const uint64_t *src, unsigned int ndig=
its)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++)
+		dest[i] =3D src[i];
+}
+
+/* Returns sign of left - right. */
+int _vli_cmp(const uint64_t *left, const uint64_t *right, unsigned int ndi=
gits)
+{
+	int i;
+
+	for (i =3D ndigits - 1; i >=3D 0; i--) {
+		if (left[i] > right[i])
+			return 1;
+		else if (left[i] < right[i])
+			return -1;
+	}
+
+	return 0;
+}
+
+/* Computes result =3D in << c, returning carry. Can modify in place
+ * (if result =3D=3D in). 0 < shift < 64.
+ */
+static uint64_t vli_lshift(uint64_t *result, const uint64_t *in,
+							unsigned int shift,
+							unsigned int ndigits)
+{
+	uint64_t carry =3D 0;
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++) {
+		uint64_t temp =3D in[i];
+
+		result[i] =3D (temp << shift) | carry;
+		carry =3D temp >> (64 - shift);
+	}
+
+	return carry;
+}
+
+/* Computes vli =3D vli >> 1. */
+void _vli_rshift1(uint64_t *vli, unsigned int ndigits)
+{
+	uint64_t *end =3D vli;
+	uint64_t carry =3D 0;
+
+	vli +=3D ndigits;
+
+	while (vli-- > end) {
+		uint64_t temp =3D *vli;
+		*vli =3D (temp >> 1) | carry;
+		carry =3D temp << 63;
+	}
+}
+
+/* Computes result =3D left + right, returning carry. Can modify in place.=
 */
+static uint64_t vli_add(uint64_t *result, const uint64_t *left,
+							const uint64_t *right,
+							unsigned int ndigits)
+{
+	uint64_t carry =3D 0;
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++) {
+		uint64_t sum;
+
+		sum =3D left[i] + right[i] + carry;
+		if (sum !=3D left[i])
+			carry =3D (sum < left[i]);
+
+		result[i] =3D sum;
+	}
+
+	return carry;
+}
+
+/* Computes result =3D left - right, returning borrow. Can modify in place=
. */
+static uint64_t vli_sub(uint64_t *result, const uint64_t *left,
+							const uint64_t *right,
+							unsigned int ndigits)
+{
+	uint64_t borrow =3D 0;
+	unsigned int i;
+
+	for (i =3D 0; i < ndigits; i++) {
+		uint64_t diff;
+
+		diff =3D left[i] - right[i] - borrow;
+		if (diff !=3D left[i])
+			borrow =3D (diff > left[i]);
+
+		result[i] =3D diff;
+	}
+
+	return borrow;
+}
+
+static uint128_t mul_64_64(uint64_t left, uint64_t right)
+{
+	uint64_t a0 =3D left & 0xffffffffull;
+	uint64_t a1 =3D left >> 32;
+	uint64_t b0 =3D right & 0xffffffffull;
+	uint64_t b1 =3D right >> 32;
+	uint64_t m0 =3D a0 * b0;
+	uint64_t m1 =3D a0 * b1;
+	uint64_t m2 =3D a1 * b0;
+	uint64_t m3 =3D a1 * b1;
+	uint128_t result;
+
+	m2 +=3D (m0 >> 32);
+	m2 +=3D m1;
+
+	/* Overflow */
+	if (m2 < m1)
+		m3 +=3D 0x100000000ull;
+
+	result.m_low =3D (m0 & 0xffffffffull) | (m2 << 32);
+	result.m_high =3D m3 + (m2 >> 32);
+
+	return result;
+}
+
+static uint128_t add_128_128(uint128_t a, uint128_t b)
+{
+	uint128_t result;
+
+	result.m_low =3D a.m_low + b.m_low;
+	result.m_high =3D a.m_high + b.m_high + (result.m_low < a.m_low);
+
+	return result;
+}
+
+static void vli_mult(uint64_t *result, const uint64_t *left,
+							const uint64_t *right,
+							unsigned int ndigits)
+{
+	uint128_t r01 =3D { 0, 0 };
+	uint64_t r2 =3D 0;
+	unsigned int i, k;
+
+	/* Compute each digit of result in sequence, maintaining the
+	 * carries.
+	 */
+	for (k =3D 0; k < ndigits * 2 - 1; k++) {
+		unsigned int min;
+
+		if (k < ndigits)
+			min =3D 0;
+		else
+			min =3D (k + 1) - ndigits;
+
+		for (i =3D min; i <=3D k && i < ndigits; i++) {
+			uint128_t product;
+
+			product =3D mul_64_64(left[i], right[k - i]);
+
+			r01 =3D add_128_128(r01, product);
+			r2 +=3D (r01.m_high < product.m_high);
+		}
+
+		result[k] =3D r01.m_low;
+		r01.m_low =3D r01.m_high;
+		r01.m_high =3D r2;
+		r2 =3D 0;
+	}
+
+	result[ndigits * 2 - 1] =3D r01.m_low;
+}
+
+static void vli_square(uint64_t *result, const uint64_t *left,
+			unsigned int ndigits)
+{
+	uint128_t r01 =3D { 0, 0 };
+	uint64_t r2 =3D 0;
+	unsigned int i, k;
+
+	for (k =3D 0; k < ndigits * 2 - 1; k++) {
+		unsigned int min;
+
+		if (k < ndigits)
+			min =3D 0;
+		else
+			min =3D (k + 1) - ndigits;
+
+		for (i =3D min; i <=3D k && i <=3D k - i; i++) {
+			uint128_t product;
+
+			product =3D mul_64_64(left[i], left[k - i]);
+
+			if (i < k - i) {
+				r2 +=3D product.m_high >> 63;
+				product.m_high =3D (product.m_high << 1) |
+							(product.m_low >> 63);
+				product.m_low <<=3D 1;
+			}
+
+			r01 =3D add_128_128(r01, product);
+			r2 +=3D (r01.m_high < product.m_high);
+		}
+
+		result[k] =3D r01.m_low;
+		r01.m_low =3D r01.m_high;
+		r01.m_high =3D r2;
+		r2 =3D 0;
+	}
+
+	result[ndigits * 2 - 1] =3D r01.m_low;
+}
+
+/* Computes result =3D (left + right) % mod.
+ * Assumes that left < mod and right < mod, result !=3D mod.
+ */
+void _vli_mod_add(uint64_t *result, const uint64_t *left,
+				const uint64_t *right, const uint64_t *mod,
+				unsigned int ndigits)
+{
+	uint64_t carry;
+
+	carry =3D vli_add(result, left, right, ndigits);
+
+	/* result > mod (result =3D mod + remainder), so subtract mod to
+	 * get remainder.
+	 */
+	if (carry || _vli_cmp(result, mod, ndigits) >=3D 0)
+		vli_sub(result, result, mod, ndigits);
+}
+
+/* Computes result =3D (left - right) % mod.
+ * Assumes that left < mod and right < mod, result !=3D mod.
+ */
+void _vli_mod_sub(uint64_t *result, const uint64_t *left,
+				const uint64_t *right, const uint64_t *mod,
+				unsigned int ndigits)
+{
+	uint64_t borrow =3D vli_sub(result, left, right, ndigits);
+
+	/* In this case, p_result =3D=3D -diff =3D=3D (max int) - diff.
+	 * Since -x % d =3D=3D d - x, we can get the correct result from
+	 * result + mod (with overflow).
+	 */
+	if (borrow)
+		vli_add(result, result, mod, ndigits);
+}
+
+/* Computes p_result =3D p_product % curve_p.
+ * See algorithm 5 and 6 from
+ * http://www.isys.uni-klu.ac.at/PDF/2001-0126-MT.pdf
+ */
+static void vli_mmod_fast_192(uint64_t *result, const uint64_t *product,
+				const uint64_t *curve_prime, uint64_t *tmp)
+{
+	const unsigned int ndigits =3D 3;
+	int carry;
+
+	vli_set(result, product, ndigits);
+
+	vli_set(tmp, &product[3], ndigits);
+	carry =3D vli_add(result, result, tmp, ndigits);
+
+	tmp[0] =3D 0;
+	tmp[1] =3D product[3];
+	tmp[2] =3D product[4];
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	tmp[0] =3D tmp[1] =3D product[5];
+	tmp[2] =3D 0;
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	while (carry || _vli_cmp(curve_prime, result, ndigits) !=3D 1)
+		carry -=3D vli_sub(result, result, curve_prime, ndigits);
+}
+
+/* Computes result =3D product % curve_prime
+ * from http://www.nsa.gov/ia/_files/nist-routines.pdf
+ */
+static void vli_mmod_fast_256(uint64_t *result, const uint64_t *product,
+				const uint64_t *curve_prime, uint64_t *tmp)
+{
+	int carry;
+	const unsigned int ndigits =3D 4;
+
+	/* t */
+	vli_set(result, product, ndigits);
+
+	/* s1 */
+	tmp[0] =3D 0;
+	tmp[1] =3D product[5] & 0xffffffff00000000ull;
+	tmp[2] =3D product[6];
+	tmp[3] =3D product[7];
+	carry =3D vli_lshift(tmp, tmp, 1, ndigits);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s2 */
+	tmp[1] =3D product[6] << 32;
+	tmp[2] =3D (product[6] >> 32) | (product[7] << 32);
+	tmp[3] =3D product[7] >> 32;
+	carry +=3D vli_lshift(tmp, tmp, 1, ndigits);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s3 */
+	tmp[0] =3D product[4];
+	tmp[1] =3D product[5] & 0xffffffff;
+	tmp[2] =3D 0;
+	tmp[3] =3D product[7];
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* s4 */
+	tmp[0] =3D (product[4] >> 32) | (product[5] << 32);
+	tmp[1] =3D (product[5] >> 32) | (product[6] & 0xffffffff00000000ull);
+	tmp[2] =3D product[7];
+	tmp[3] =3D (product[6] >> 32) | (product[4] << 32);
+	carry +=3D vli_add(result, result, tmp, ndigits);
+
+	/* d1 */
+	tmp[0] =3D (product[5] >> 32) | (product[6] << 32);
+	tmp[1] =3D (product[6] >> 32);
+	tmp[2] =3D 0;
+	tmp[3] =3D (product[4] & 0xffffffff) | (product[5] << 32);
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	/* d2 */
+	tmp[0] =3D product[6];
+	tmp[1] =3D product[7];
+	tmp[2] =3D 0;
+	tmp[3] =3D (product[4] >> 32) | (product[5] & 0xffffffff00000000ull);
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	/* d3 */
+	tmp[0] =3D (product[6] >> 32) | (product[7] << 32);
+	tmp[1] =3D (product[7] >> 32) | (product[4] << 32);
+	tmp[2] =3D (product[4] >> 32) | (product[5] << 32);
+	tmp[3] =3D (product[6] << 32);
+	carry -=3D vli_sub(result, result, tmp, ndigits);
+
+	/* d4 */
+	tmp[0] =3D product[7];
+	tmp[1] =3D product[4] & 0xffffffff00000000ull;
+	tmp[2] =3D product[5];
+	tmp[3] =3D product[6] & 0xffffffff00000000ull;
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
+/* Computes result =3D product % curve_prime
+ *  from http://www.nsa.gov/ia/_files/nist-routines.pdf
+*/
+static bool vli_mmod_fast(uint64_t *result, uint64_t *product,
+				const uint64_t *curve_prime,
+				unsigned int ndigits)
+{
+	uint64_t tmp[2 * L_ECC_MAX_DIGITS];
+
+	switch (ndigits) {
+	case 3:
+		vli_mmod_fast_192(result, product, curve_prime, tmp);
+		break;
+	case 4:
+		vli_mmod_fast_256(result, product, curve_prime, tmp);
+		break;
+	default:
+		return false;
+	}
+
+	return true;
+}
+
+/* Computes result =3D (left * right) % curve_p. */
+void _vli_mod_mult_fast(uint64_t *result, const uint64_t *left,
+			const uint64_t *right, const uint64_t *curve_prime,
+			unsigned int ndigits)
+{
+	uint64_t product[2 * L_ECC_MAX_DIGITS];
+
+	vli_mult(product, left, right, ndigits);
+	vli_mmod_fast(result, product, curve_prime, ndigits);
+}
+
+/* Computes result =3D left^2 % curve_p. */
+static void vli_mod_square_fast(uint64_t *result, const uint64_t *left,
+					const uint64_t *curve_prime,
+					unsigned int ndigits)
+{
+	uint64_t product[2 * L_ECC_MAX_DIGITS];
+
+	vli_square(product, left, ndigits);
+	vli_mmod_fast(result, product, curve_prime, ndigits);
+}
+
+#define EVEN(vli) (!(vli[0] & 1))
+/* Computes result =3D (1 / p_input) % mod. All VLIs are the same size.
+ * See "From Euclid's GCD to Montgomery Multiplication to the Great Divide"
+ * https://labs.oracle.com/techrep/2001/smli_tr-2001-95.pdf
+ */
+void _vli_mod_inv(uint64_t *result, const uint64_t *input,
+						const uint64_t *mod,
+						unsigned int ndigits)
+{
+	uint64_t a[L_ECC_MAX_DIGITS], b[L_ECC_MAX_DIGITS];
+	uint64_t u[L_ECC_MAX_DIGITS], v[L_ECC_MAX_DIGITS];
+	uint64_t carry;
+	int cmp_result;
+
+	if (vli_is_zero(input, ndigits)) {
+		vli_clear(result, ndigits);
+		return;
+	}
+
+	vli_set(a, input, ndigits);
+	vli_set(b, mod, ndigits);
+	vli_clear(u, ndigits);
+	u[0] =3D 1;
+	vli_clear(v, ndigits);
+
+	while ((cmp_result =3D _vli_cmp(a, b, ndigits)) !=3D 0) {
+		carry =3D 0;
+
+		if (EVEN@) {
+			_vli_rshift1(a, ndigits);
+
+			if (!EVEN(u))
+				carry =3D vli_add(u, u, mod, ndigits);
+
+			_vli_rshift1(u, ndigits);
+			if (carry)
+				u[ndigits - 1] |=3D 0x8000000000000000ull;
+		} else if (EVEN(b)) {
+			_vli_rshift1(b, ndigits);
+
+			if (!EVEN(v))
+				carry =3D vli_add(v, v, mod, ndigits);
+
+			_vli_rshift1(v, ndigits);
+			if (carry)
+				v[ndigits - 1] |=3D 0x8000000000000000ull;
+		} else if (cmp_result > 0) {
+			vli_sub(a, a, b, ndigits);
+			_vli_rshift1(a, ndigits);
+
+			if (_vli_cmp(u, v, ndigits) < 0)
+				vli_add(u, u, mod, ndigits);
+
+			vli_sub(u, u, v, ndigits);
+			if (!EVEN(u))
+				carry =3D vli_add(u, u, mod, ndigits);
+
+			_vli_rshift1(u, ndigits);
+			if (carry)
+				u[ndigits - 1] |=3D 0x8000000000000000ull;
+		} else {
+			vli_sub(b, b, a, ndigits);
+			_vli_rshift1(b, ndigits);
+
+			if (_vli_cmp(v, u, ndigits) < 0)
+				vli_add(v, v, mod, ndigits);
+
+			vli_sub(v, v, u, ndigits);
+			if (!EVEN(v))
+				carry =3D vli_add(v, v, mod, ndigits);
+
+			_vli_rshift1(v, ndigits);
+			if (carry)
+				v[ndigits - 1] |=3D 0x8000000000000000ull;
+		}
+	}
+
+	vli_set(result, u, ndigits);
+}
+
+/* ------ Point operations ------ */
+
+/* Point multiplication algorithm using Montgomery's ladder with co-Z
+ * coordinates. From http://eprint.iacr.org/2011/338.pdf
+ */
+
+/* Double in place */
+static void ecc_point_double_jacobian(uint64_t *x1, uint64_t *y1, uint64_t=
 *z1,
+					const uint64_t *curve_prime,
+					unsigned int ndigits)
+{
+	/* t1 =3D x, t2 =3D y, t3 =3D z */
+	uint64_t t4[L_ECC_MAX_DIGITS];
+	uint64_t t5[L_ECC_MAX_DIGITS];
+
+	if (vli_is_zero(z1, ndigits))
+		return;
+
+	/* t4 =3D y1^2 */
+	vli_mod_square_fast(t4, y1, curve_prime, ndigits);
+	/* t5 =3D x1*y1^2 =3D A */
+	_vli_mod_mult_fast(t5, x1, t4, curve_prime, ndigits);
+	/* t4 =3D y1^4 */
+	vli_mod_square_fast(t4, t4, curve_prime, ndigits);
+	/* t2 =3D y1*z1 =3D z3 */
+	_vli_mod_mult_fast(y1, y1, z1, curve_prime, ndigits);
+	/* t3 =3D z1^2 */
+	vli_mod_square_fast(z1, z1, curve_prime, ndigits);
+
+	/* t1 =3D x1 + z1^2 */
+	_vli_mod_add(x1, x1, z1, curve_prime, ndigits);
+	/* t3 =3D 2*z1^2 */
+	_vli_mod_add(z1, z1, z1, curve_prime, ndigits);
+	/* t3 =3D x1 - z1^2 */
+	_vli_mod_sub(z1, x1, z1, curve_prime, ndigits);
+	/* t1 =3D x1^2 - z1^4 */
+	_vli_mod_mult_fast(x1, x1, z1, curve_prime, ndigits);
+
+	/* t3 =3D 2*(x1^2 - z1^4) */
+	_vli_mod_add(z1, x1, x1, curve_prime, ndigits);
+	/* t1 =3D 3*(x1^2 - z1^4) */
+	_vli_mod_add(x1, x1, z1, curve_prime, ndigits);
+	if (vli_test_bit(x1, 0)) {
+		uint64_t carry =3D vli_add(x1, x1, curve_prime, ndigits);
+		_vli_rshift1(x1, ndigits);
+		x1[ndigits - 1] |=3D carry << 63;
+	} else {
+		_vli_rshift1(x1, ndigits);
+	}
+	/* t1 =3D 3/2*(x1^2 - z1^4) =3D B */
+
+	/* t3 =3D B^2 */
+	vli_mod_square_fast(z1, x1, curve_prime, ndigits);
+	/* t3 =3D B^2 - A */
+	_vli_mod_sub(z1, z1, t5, curve_prime, ndigits);
+	/* t3 =3D B^2 - 2A =3D x3 */
+	_vli_mod_sub(z1, z1, t5, curve_prime, ndigits);
+	/* t5 =3D A - x3 */
+	_vli_mod_sub(t5, t5, z1, curve_prime, ndigits);
+	/* t1 =3D B * (A - x3) */
+	_vli_mod_mult_fast(x1, x1, t5, curve_prime, ndigits);
+	/* t4 =3D B * (A - x3) - y1^4 =3D y3 */
+	_vli_mod_sub(t4, x1, t4, curve_prime, ndigits);
+
+	vli_set(x1, z1, ndigits);
+	vli_set(z1, y1, ndigits);
+	vli_set(y1, t4, ndigits);
+}
+
+/* Modify (x1, y1) =3D> (x1 * z^2, y1 * z^3) */
+static void apply_z(uint64_t *x1, uint64_t *y1, uint64_t *z,
+			const uint64_t *curve_prime, unsigned int ndigits)
+{
+	uint64_t t1[L_ECC_MAX_DIGITS];
+
+	vli_mod_square_fast(t1, z, curve_prime, ndigits);    /* z^2 */
+	_vli_mod_mult_fast(x1, x1, t1, curve_prime, ndigits); /* x1 * z^2 */
+	_vli_mod_mult_fast(t1, t1, z, curve_prime, ndigits);  /* z^3 */
+	_vli_mod_mult_fast(y1, y1, t1, curve_prime, ndigits); /* y1 * z^3 */
+}
+
+/* P =3D (x1, y1) =3D> 2P, (x2, y2) =3D> P' */
+static void xycz_initial_double(uint64_t *x1, uint64_t *y1, uint64_t *x2,
+					uint64_t *y2, uint64_t *p_initial_z,
+					const uint64_t *curve_prime,
+					unsigned int ndigits)
+{
+	uint64_t z[L_ECC_MAX_DIGITS];
+
+	vli_set(x2, x1, ndigits);
+	vli_set(y2, y1, ndigits);
+
+	vli_clear(z, ndigits);
+	z[0] =3D 1;
+
+	if (p_initial_z)
+		vli_set(z, p_initial_z, ndigits);
+
+	apply_z(x1, y1, z, curve_prime, ndigits);
+
+	ecc_point_double_jacobian(x1, y1, z, curve_prime, ndigits);
+
+	apply_z(x2, y2, z, curve_prime, ndigits);
+}
+
+/* Input P =3D (x1, y1, Z), Q =3D (x2, y2, Z)
+ * Output P' =3D (x1', y1', Z3), P + Q =3D (x3, y3, Z3)
+ * or P =3D> P', Q =3D> P + Q
+ */
+static void xycz_add(uint64_t *x1, uint64_t *y1, uint64_t *x2, uint64_t *y=
2,
+			const uint64_t *curve_prime, unsigned int ndigits)
+{
+	/* t1 =3D X1, t2 =3D Y1, t3 =3D X2, t4 =3D Y2 */
+	uint64_t t5[L_ECC_MAX_DIGITS];
+
+	/* t5 =3D x2 - x1 */
+	_vli_mod_sub(t5, x2, x1, curve_prime, ndigits);
+	/* t5 =3D (x2 - x1)^2 =3D A */
+	vli_mod_square_fast(t5, t5, curve_prime, ndigits);
+	/* t1 =3D x1*A =3D B */
+	_vli_mod_mult_fast(x1, x1, t5, curve_prime, ndigits);
+	/* t3 =3D x2*A =3D C */
+	_vli_mod_mult_fast(x2, x2, t5, curve_prime, ndigits);
+	/* t4 =3D y2 - y1 */
+	_vli_mod_sub(y2, y2, y1, curve_prime, ndigits);
+	/* t5 =3D (y2 - y1)^2 =3D D */
+	vli_mod_square_fast(t5, y2, curve_prime, ndigits);
+
+	/* t5 =3D D - B */
+	_vli_mod_sub(t5, t5, x1, curve_prime, ndigits);
+	/* t5 =3D D - B - C =3D x3 */
+	_vli_mod_sub(t5, t5, x2, curve_prime, ndigits);
+	/* t3 =3D C - B */
+	_vli_mod_sub(x2, x2, x1, curve_prime, ndigits);
+	/* t2 =3D y1*(C - B) */
+	_vli_mod_mult_fast(y1, y1, x2, curve_prime, ndigits);
+	/* t3 =3D B - x3 */
+	_vli_mod_sub(x2, x1, t5, curve_prime, ndigits);
+	/* t4 =3D (y2 - y1)*(B - x3) */
+	_vli_mod_mult_fast(y2, y2, x2, curve_prime, ndigits);
+	/* t4 =3D y3 */
+	_vli_mod_sub(y2, y2, y1, curve_prime, ndigits);
+
+	vli_set(x2, t5, ndigits);
+}
+
+/* Input P =3D (x1, y1, Z), Q =3D (x2, y2, Z)
+ * Output P + Q =3D (x3, y3, Z3), P - Q =3D (x3', y3', Z3)
+ * or P =3D> P - Q, Q =3D> P + Q
+ */
+static void xycz_add_c(uint64_t *x1, uint64_t *y1, uint64_t *x2, uint64_t =
*y2,
+			const uint64_t *curve_prime, unsigned int ndigits)
+{
+	/* t1 =3D X1, t2 =3D Y1, t3 =3D X2, t4 =3D Y2 */
+	uint64_t t5[L_ECC_MAX_DIGITS];
+	uint64_t t6[L_ECC_MAX_DIGITS];
+	uint64_t t7[L_ECC_MAX_DIGITS];
+
+	/* t5 =3D x2 - x1 */
+	_vli_mod_sub(t5, x2, x1, curve_prime, ndigits);
+	/* t5 =3D (x2 - x1)^2 =3D A */
+	vli_mod_square_fast(t5, t5, curve_prime, ndigits);
+	/* t1 =3D x1*A =3D B */
+	_vli_mod_mult_fast(x1, x1, t5, curve_prime, ndigits);
+	/* t3 =3D x2*A =3D C */
+	_vli_mod_mult_fast(x2, x2, t5, curve_prime, ndigits);
+	/* t4 =3D y2 + y1 */
+	_vli_mod_add(t5, y2, y1, curve_prime, ndigits);
+	/* t4 =3D y2 - y1 */
+	_vli_mod_sub(y2, y2, y1, curve_prime, ndigits);
+
+	/* t6 =3D C - B */
+	_vli_mod_sub(t6, x2, x1, curve_prime, ndigits);
+	/* t2 =3D y1 * (C - B) */
+	_vli_mod_mult_fast(y1, y1, t6, curve_prime, ndigits);
+	/* t6 =3D B + C */
+	_vli_mod_add(t6, x1, x2, curve_prime, ndigits);
+	/* t3 =3D (y2 - y1)^2 */
+	vli_mod_square_fast(x2, y2, curve_prime, ndigits);
+	/* t3 =3D x3 */
+	_vli_mod_sub(x2, x2, t6, curve_prime, ndigits);
+
+	/* t7 =3D B - x3 */
+	_vli_mod_sub(t7, x1, x2, curve_prime, ndigits);
+	/* t4 =3D (y2 - y1)*(B - x3) */
+	_vli_mod_mult_fast(y2, y2, t7, curve_prime, ndigits);
+	/* t4 =3D y3 */
+	_vli_mod_sub(y2, y2, y1, curve_prime, ndigits);
+
+	/* t7 =3D (y2 + y1)^2 =3D F */
+	vli_mod_square_fast(t7, t5, curve_prime, ndigits);
+	/* t7 =3D x3' */
+	_vli_mod_sub(t7, t7, t6, curve_prime, ndigits);
+	/* t6 =3D x3' - B */
+	_vli_mod_sub(t6, t7, x1, curve_prime, ndigits);
+	/* t6 =3D (y2 + y1)*(x3' - B) */
+	_vli_mod_mult_fast(t6, t6, t5, curve_prime, ndigits);
+	/* t2 =3D y3' */
+	_vli_mod_sub(y1, t6, y1, curve_prime, ndigits);
+
+	vli_set(x1, t7, ndigits);
+}
+
+static void ecc_point_mult(struct l_ecc_point *result,
+			const struct l_ecc_point *point, const uint64_t *scalar,
+			uint64_t *initial_z, const uint64_t *curve_prime)
+{
+	/* R0 and R1 */
+	uint64_t rx[2][L_ECC_MAX_DIGITS];
+	uint64_t ry[2][L_ECC_MAX_DIGITS];
+	uint64_t z[L_ECC_MAX_DIGITS];
+	int i, nb;
+	unsigned int ndigits =3D point->ndigits;
+	int num_bits =3D vli_num_bits(scalar, ndigits);
+
+	vli_set(rx[1], point->x, ndigits);
+	vli_set(ry[1], point->y, ndigits);
+
+	xycz_initial_double(rx[1], ry[1], rx[0], ry[0], initial_z, curve_prime,
+			    ndigits);
+
+	for (i =3D num_bits - 2; i > 0; i--) {
+		nb =3D !vli_test_bit(scalar, i);
+		xycz_add_c(rx[1 - nb], ry[1 - nb], rx[nb], ry[nb], curve_prime,
+			   ndigits);
+		xycz_add(rx[nb], ry[nb], rx[1 - nb], ry[1 - nb], curve_prime,
+			 ndigits);
+	}
+
+	nb =3D !vli_test_bit(scalar, 0);
+	xycz_add_c(rx[1 - nb], ry[1 - nb], rx[nb], ry[nb], curve_prime,
+		   ndigits);
+
+	/* Find final 1/Z value. */
+	/* X1 - X0 */
+	_vli_mod_sub(z, rx[1], rx[0], curve_prime, ndigits);
+	/* Yb * (X1 - X0) */
+	_vli_mod_mult_fast(z, z, ry[1 - nb], curve_prime, ndigits);
+	/* xP * Yb * (X1 - X0) */
+	_vli_mod_mult_fast(z, z, point->x, curve_prime, ndigits);
+
+	/* 1 / (xP * Yb * (X1 - X0)) */
+	_vli_mod_inv(z, z, curve_prime, point->ndigits);
+
+	/* yP / (xP * Yb * (X1 - X0)) */
+	_vli_mod_mult_fast(z, z, point->y, curve_prime, ndigits);
+	/* Xb * yP / (xP * Yb * (X1 - X0)) */
+	_vli_mod_mult_fast(z, z, rx[1 - nb], curve_prime, ndigits);
+	/* End 1/Z calculation */
+
+	xycz_add(rx[nb], ry[nb], rx[1 - nb], ry[1 - nb], curve_prime, ndigits);
+
+	apply_z(rx[0], ry[0], z, curve_prime, ndigits);
+
+	vli_set(result->x, rx[0], ndigits);
+	vli_set(result->y, ry[0], ndigits);
+}
+
+/*
+ * The code below was not in the original file and was added to support
+ * additional ECC operations. The above ECC implementation did not include
+ * functionality for point addition or the ability to solve for Y value gi=
ven
+ * some X.
+ */
+
+struct l_ecc_curve {
+	unsigned int ndigits;
+	unsigned int group;
+	struct l_ecc_point g;
+	uint64_t p[L_ECC_MAX_DIGITS];
+	uint64_t n[L_ECC_MAX_DIGITS];
+	uint64_t b[L_ECC_MAX_DIGITS];
+};
+
+#define P256_CURVE_P {	0xFFFFFFFFFFFFFFFFull, 0x00000000FFFFFFFFull, \
+			0x0000000000000000ull, 0xFFFFFFFF00000001ull }
+#define P256_CURVE_GX {	0xF4A13945D898C296ull, 0x77037D812DEB33A0ull,	\
+			0xF8BCE6E563A440F2ull, 0x6B17D1F2E12C4247ull }
+#define P256_CURVE_GY {	0xCBB6406837BF51F5ull, 0x2BCE33576B315ECEull,	\
+			0x8EE7EB4A7C0F9E16ull, 0x4FE342E2FE1A7F9Bull }
+#define P256_CURVE_N {	0xF3B9CAC2FC632551ull, 0xBCE6FAADA7179E84ull,	\
+			0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFF00000000ull }
+#define P256_CURVE_B {	0x3BCE3C3E27D2604Bull, 0x651D06B0CC53B0F6ull,	\
+			0xB3EBBD55769886BCull, 0x5AC635D8AA3A93E7ull }
+
+static struct l_ecc_curve p256 =3D {
+	.group =3D 19,
+	.ndigits =3D 4,
+	.g =3D {
+		.x =3D P256_CURVE_GX,
+		.y =3D P256_CURVE_GY,
+		.ndigits =3D 4
+	},
+	.p =3D P256_CURVE_P,
+	.n =3D P256_CURVE_N,
+	.b =3D P256_CURVE_B,
+};
+
+static struct l_ecc_curve *curves[] =3D {
+	&p256,
+};
+
+LIB_EXPORT struct l_ecc_curve *l_ecc_curve_get(unsigned int group)
+{
+	int i;
+
+	for (i =3D 0; curves[i]; i++) {
+		if (curves[i]->group =3D=3D group)
+			return curves[i];
+	}
+
+	return NULL;
+}
+
+LIB_EXPORT unsigned int l_ecc_curve_get_ndigits(struct l_ecc_curve *curve)
+{
+	return curve->ndigits;
+}
+
+LIB_EXPORT const uint64_t *l_ecc_curve_get_prime(struct l_ecc_curve *curve)
+{
+	return curve->p;
+}
+
+LIB_EXPORT const uint64_t *l_ecc_curve_get_b(struct l_ecc_curve *curve)
+{
+	return curve->b;
+}
+
+LIB_EXPORT struct l_ecc_point *l_ecc_curve_get_generator(
+						struct l_ecc_curve *curve)
+{
+	return &curve->g;
+}
+
+/* (rx, ry) =3D (px, py) + (qx, qy) */
+static void ecc_point_add(struct l_ecc_point *ret, struct l_ecc_point *p,
+		struct l_ecc_point *q, const uint64_t *curve_prime)
+{
+	/*
+	 * s =3D (py - qy)/(px - qx)
+	 *
+	 * rx =3D s^2 - px - qx
+	 * ry =3D s(px - rx) - py
+	 */
+	uint64_t s[L_ECC_MAX_DIGITS];
+	uint64_t kp1[L_ECC_MAX_DIGITS];
+	uint64_t kp2[L_ECC_MAX_DIGITS];
+	uint64_t resx[L_ECC_MAX_DIGITS];
+	uint64_t resy[L_ECC_MAX_DIGITS];
+	unsigned int ndigits =3D p->ndigits;
+
+	vli_clear(s, ndigits);
+
+	/* kp1 =3D py - qy */
+	_vli_mod_sub(kp1, q->y, p->y, curve_prime, ndigits);
+	/* kp2 =3D px - qx */
+	_vli_mod_sub(kp2, q->x, p->x, curve_prime, ndigits);
+	/* s =3D kp1/kp2 */
+	_vli_mod_inv(kp2, kp2, curve_prime, ndigits);
+	_vli_mod_mult_fast(s, kp1, kp2, curve_prime, ndigits);
+	/* rx =3D s^2 - px - qx */
+	_vli_mod_mult_fast(kp1, s, s, curve_prime, ndigits);
+	_vli_mod_sub(kp1, kp1, p->x, curve_prime, ndigits);
+	_vli_mod_sub(resx, kp1, q->x, curve_prime, ndigits);
+	/* ry =3D s(px - rx) - py */
+	_vli_mod_sub(kp1, p->x, resx, curve_prime, ndigits);
+	_vli_mod_mult_fast(kp1, s, kp1, curve_prime, ndigits);
+	_vli_mod_sub(resy, kp1, p->y, curve_prime, ndigits);
+
+	vli_set(ret->x, resx, ndigits);
+	vli_set(ret->y, resy, ndigits);
+}
+
+/* result =3D (base ^ exp) % p */
+void _vli_mod_exp(uint64_t *result, uint64_t *base, uint64_t *exp,
+		const uint64_t *mod, unsigned int ndigits)
+{
+	unsigned int i;
+	int bit;
+	uint64_t n[L_ECC_MAX_DIGITS];
+	uint64_t r[L_ECC_MAX_DIGITS] =3D { 1 };
+
+	vli_set(n, base, ndigits);
+
+	for (i =3D 0; i < ndigits; i++) {
+		for (bit =3D 0; bit < 64; bit++) {
+			uint64_t tmp[L_ECC_MAX_DIGITS];
+
+			if (exp[i] & (1ull << bit)) {
+				_vli_mod_mult_fast(tmp, r, n, mod, ndigits);
+				vli_set(r, tmp, ndigits);
+			}
+
+			_vli_mod_mult_fast(tmp, n, n, mod, ndigits);
+			vli_set(n, tmp, ndigits);
+		}
+	}
+
+	vli_set(result, r, ndigits);
+}
+
+int _vli_legendre(uint64_t *val, const uint64_t *p, unsigned int ndigits)
+{
+	uint64_t tmp[L_ECC_MAX_DIGITS];
+	uint64_t exp[L_ECC_MAX_DIGITS];
+	uint64_t _1[L_ECC_MAX_DIGITS] =3D { 1ull };
+	uint64_t _0[L_ECC_MAX_DIGITS] =3D { 0 };
+
+	/* check that val ^ ((p - 1) / 2) =3D=3D [1, 0 or -1] */
+
+	vli_sub(exp, p, _1, ndigits);
+	_vli_rshift1(exp, ndigits);
+	_vli_mod_exp(tmp, val, exp, p, ndigits);
+
+	if (_vli_cmp(tmp, _1, ndigits) =3D=3D 0)
+		return 1;
+	else if (_vli_cmp(tmp, _0, ndigits) =3D=3D 0)
+		return 0;
+	else
+		return -1;
+}
+
+LIB_EXPORT bool l_ecc_point_multiply(struct l_ecc_curve *curve,
+					struct l_ecc_point *ret,
+					struct l_ecc_point *p, uint64_t *scalar,
+					uint64_t *initial_z)
+{
+	ecc_point_mult(ret, p, scalar, initial_z, curve->p);
+
+	ret->ndigits =3D curve->ndigits;
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_add(struct l_ecc_curve *curve,
+				struct l_ecc_point *ret,
+				struct l_ecc_point *p, struct l_ecc_point *q)
+{
+	ecc_point_add(ret, p, q, curve->p);
+
+	ret->ndigits =3D curve->ndigits;
+
+	return true;
+}
+
+/* Returns true if p_point is the point at infinity, false otherwise. */
+static bool ecc_point_is_zero(const struct l_ecc_point *point)
+{
+	return (vli_is_zero(point->x, point->ndigits) &&
+		vli_is_zero(point->y, point->ndigits));
+}
+
+LIB_EXPORT bool l_ecc_valid_point(struct l_ecc_curve *curve,
+					struct l_ecc_point *point)
+{
+	uint64_t tmp1[L_ECC_MAX_DIGITS];
+	uint64_t tmp2[L_ECC_MAX_DIGITS];
+	uint64_t _3[L_ECC_MAX_DIGITS] =3D { 3 };	/* -a =3D 3 */
+	const uint64_t *curve_prime =3D curve->p;
+	const uint64_t *curve_b =3D curve->b;
+
+	/* The point at infinity is invalid. */
+	if (ecc_point_is_zero(point))
+		return false;
+
+	/* x and y must be smaller than p. */
+	if (_vli_cmp(curve_prime, point->x, point->ndigits) !=3D 1 ||
+			_vli_cmp(curve_prime, point->y, point->ndigits) !=3D 1)
+		return false;
+
+	/* Computes result =3D y^2. */
+	vli_mod_square_fast(tmp1, point->y, curve_prime, point->ndigits);
+
+	/* Computes result =3D x^3 + ax + b. result must not overlap x. */
+	/* r =3D x^2 */
+	vli_mod_square_fast(tmp2, point->x, curve_prime, point->ndigits);
+	/* r =3D x^2 - 3 */
+	_vli_mod_sub(tmp2, tmp2, _3, curve_prime, point->ndigits);
+	/* r =3D x^3 - 3x */
+	_vli_mod_mult_fast(tmp2, tmp2, point->x, curve_prime, point->ndigits);
+	/* r =3D x^3 - 3x + b */
+	_vli_mod_add(tmp2, tmp2, curve_b, curve_prime, point->ndigits);
+	/* Make sure that y^2 =3D=3D x^3 + ax + b */
+	return (_vli_cmp(tmp1, tmp2, point->ndigits) =3D=3D 0);
+}
+
+LIB_EXPORT void l_ecc_be2native(struct l_ecc_curve *curve, uint64_t *dest,
+				uint64_t *bytes)
+{
+	unsigned int i;
+	uint64_t tmp[L_ECC_MAX_DIGITS];
+
+	for (i =3D 0; i < curve->ndigits; i++)
+		tmp[curve->ndigits - 1 - i] =3D l_get_be64(&bytes[i]);
+
+	vli_set(dest, tmp, curve->ndigits);
+}
+
+LIB_EXPORT void l_ecc_native2be(struct l_ecc_curve *curve, uint64_t *dest,
+				uint64_t *native)
+{
+	unsigned int i;
+	uint64_t tmp[L_ECC_MAX_DIGITS];
+
+	for (i =3D 0; i < curve->ndigits; i++)
+		l_put_be64(native[curve->ndigits - 1 - i], &tmp[i]);
+
+	vli_set(dest, tmp, curve->ndigits);
+}
+
+LIB_EXPORT void l_ecc_compute_y_sqr(struct l_ecc_curve *curve, uint64_t *y=
_sqr,
+				uint64_t *x)
+{
+	uint64_t sum[L_ECC_MAX_DIGITS] =3D { 0 };
+	uint64_t tmp[L_ECC_MAX_DIGITS] =3D { 0 };
+	uint64_t _3[L_ECC_MAX_DIGITS] =3D { 3ull }; /* -a =3D 3 */
+
+	/* x^3 */
+	vli_mod_square_fast(sum, x, curve->p, curve->ndigits);
+	_vli_mod_mult_fast(sum, sum, x, curve->p, curve->ndigits);
+	/* x^3 - ax */
+	_vli_mod_mult_fast(tmp, _3, x, curve->p, curve->ndigits);
+	_vli_mod_sub(sum, sum, tmp, curve->p, curve->ndigits);
+	/* x^3 - ax + b */
+	_vli_mod_add(sum, sum, curve->b, curve->p, curve->ndigits);
+
+	vli_set(y_sqr, sum, curve->ndigits);
+}
+
+bool _ecc_compute_y(struct l_ecc_curve *curve, uint64_t *y, uint64_t *x)
+{
+	/*
+	 * y =3D sqrt(x^3 + ax + b) (mod p)
+	 *
+	 * Since our prime p satisfies p =3D 3 (mod 4), we can say:
+	 *
+	 * y =3D (x^3 - 3x + b)^((p + 1) / 4)
+	 *
+	 * This avoids the need for a square root function.
+	 */
+
+	uint64_t sum[L_ECC_MAX_DIGITS] =3D { 0 };
+	uint64_t expo[L_ECC_MAX_DIGITS] =3D { 0 };
+	uint64_t one[L_ECC_MAX_DIGITS] =3D { 1ull };
+	uint64_t check[L_ECC_MAX_DIGITS] =3D { 0 };
+
+	vli_set(expo, curve->p, curve->ndigits);
+
+	/* x^3 - 3x + b */
+	l_ecc_compute_y_sqr(curve, sum, x);
+
+	/* (p + 1) / 4  =3D=3D (p >> 2) + 1 */
+	_vli_rshift1(expo, curve->ndigits);
+	_vli_rshift1(expo, curve->ndigits);
+	_vli_mod_add(expo, expo, one, curve->p, curve->ndigits);
+	/* sum ^ ((p + 1) / 4) */
+	_vli_mod_exp(y, sum, expo, curve->p, curve->ndigits);
+
+	/* square y to ensure we have a correct value */
+	_vli_mod_mult_fast(check, y, y, curve->p, curve->ndigits);
+
+	if (_vli_cmp(check, sum, curve->ndigits) !=3D 0)
+		return false;
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_compute_y(struct l_ecc_curve *curve, uint64_t *y,
+					uint64_t *x, uint8_t y_bit)
+{
+	if (!_ecc_compute_y(curve, y, x))
+		return false;
+
+	if ((y[0] & 1) !=3D y_bit)
+		_vli_mod_sub(y, curve->p, y, curve->p, curve->ndigits);
+
+	return true;
+}
+
+/*
+ * Several ECC use cases (SAE/PWD) share a similar set of operations. They
+ * require computing 3 integer values: rand, mask, and scalar where:
+ *
+ * 1 < rand < n
+ * 1 < mask < n
+ *
+ * scalar =3D (rand + mask) mod n
+ *
+ * (where n is curve order)
+ */
+LIB_EXPORT bool l_ecc_compute_scalar(struct l_ecc_curve *curve,
+					uint64_t *scalar, uint64_t *rand,
+					uint64_t *mask)
+{
+	unsigned int nbytes =3D curve->ndigits * 8;
+	uint64_t one[L_ECC_MAX_DIGITS] =3D { 1 };
+
+	if (unlikely(!curve) || unlikely(!scalar) ||
+			unlikely(!rand) || unlikely(!mask))
+		return false;
+
+	l_getrandom(rand, nbytes);
+
+	/* ensure 1 < p_rand < r */
+	while (!((_vli_cmp(rand, one, curve->ndigits) > 0) &&
+			(_vli_cmp(rand, curve->n, curve->ndigits) < 0)))
+		l_getrandom(rand, nbytes);
+
+	l_getrandom(mask, nbytes);
+
+	/* ensure 1 < p_mask < r */
+	while (!((_vli_cmp(mask, one, curve->ndigits) > 0) &&
+			(_vli_cmp(mask, curve->n, curve->ndigits) < 0)))
+		l_getrandom(mask, nbytes);
+
+	_vli_mod_add(scalar, rand, mask, curve->n, curve->ndigits);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_point_inverse(struct l_ecc_curve *curve,
+					struct l_ecc_point *point)
+{
+	if (unlikely(!curve) || unlikely(!point))
+		return false;
+
+	vli_sub(point->y, curve->p, point->y, curve->ndigits);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_compute_residue(struct l_ecc_curve *curve,
+					uint64_t *qr_or_qnr, bool residue)
+{
+	int check =3D (residue) ? -1 : 1;
+
+	l_getrandom(qr_or_qnr, curve->ndigits * 8);
+
+	while (_vli_legendre(qr_or_qnr, curve->p, curve->ndigits) !=3D check)
+		l_getrandom(qr_or_qnr, curve->ndigits * 8);
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecc_is_quadradic_residue(struct l_ecc_curve *curve,
+						uint64_t *value, uint64_t *qr,
+						uint64_t *qnr)
+{
+	unsigned int nbytes =3D l_ecc_curve_get_ndigits(curve) * 8;
+	uint64_t y_sqr[L_ECC_MAX_DIGITS];
+	uint64_t r[L_ECC_MAX_DIGITS];
+	uint64_t num[L_ECC_MAX_DIGITS];
+
+	if (_vli_cmp(value, curve->p, curve->ndigits) >=3D 0)
+		return false;
+
+	l_ecc_compute_y_sqr(curve, y_sqr, value);
+
+	l_getrandom(r, nbytes);
+
+	while (_vli_cmp(r, curve->p, curve->ndigits) >=3D 0)
+		l_getrandom(r, nbytes);
+
+	_vli_mod_mult_fast(num, y_sqr, r, curve->p, curve->ndigits);
+	_vli_mod_mult_fast(num, num, r, curve->p, curve->ndigits);
+
+	if (r[0] & 1) {
+		_vli_mod_mult_fast(num, num, qr, curve->p, curve->ndigits);
+
+		if (_vli_legendre(num, curve->p, curve->ndigits) =3D=3D -1)
+			return true;
+	} else {
+		_vli_mod_mult_fast(num, num, qnr, curve->p, curve->ndigits);
+
+		if (_vli_legendre(num, curve->p, curve->ndigits) =3D=3D 1)
+			return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT bool l_ecc_integer_add(struct l_ecc_curve *curve, uint64_t *ret,
+					uint64_t *a, uint64_t *b)
+{
+	_vli_mod_add(ret, a, b, curve->n, curve->ndigits);
+
+	return true;
+}
+
+/*
+ * This should be used when manually creating a l_ecc_point (have x[,y] and
+ * need to copy into p.x/y). Using this ensures that ndigits gets set. If a
+ * point is being initialized via l_ecc_point_add/l_ecc_point_multiply this
+ * does not need to be used since both set ndigits already.
+ */
+LIB_EXPORT void l_ecc_point_set(struct l_ecc_curve *curve,
+					struct l_ecc_point *p, void *x, void *y)
+{
+	vli_set(p->x, x, curve->ndigits);
+
+	if (y)
+		vli_set(p->y, y, curve->ndigits);
+
+	p->ndigits =3D curve->ndigits;
+}
diff --git a/ell/ecc.h b/ell/ecc.h
new file mode 100644
index 0000000..0601780
--- /dev/null
+++ b/ell/ecc.h
@@ -0,0 +1,84 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018 Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_ECC_H
+#define __ELL_ECC_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#define L_ECC_MAX_DIGITS 4
+
+struct l_ecc_curve;
+
+struct l_ecc_point {
+	uint64_t x[L_ECC_MAX_DIGITS];
+	uint64_t y[L_ECC_MAX_DIGITS];
+	unsigned int ndigits;
+};
+
+struct l_ecc_curve *l_ecc_curve_get(unsigned int group);
+
+unsigned int l_ecc_curve_get_ndigits(struct l_ecc_curve *curve);
+
+const uint64_t *l_ecc_curve_get_prime(struct l_ecc_curve *curve);
+
+const uint64_t *l_ecc_curve_get_b(struct l_ecc_curve *curve);
+struct l_ecc_point *l_ecc_curve_get_generator(struct l_ecc_curve *curve);
+void l_ecc_point_set(struct l_ecc_curve *curve, struct l_ecc_point *p,
+			void *x, void *y);
+bool l_ecc_point_multiply(struct l_ecc_curve *curve, struct l_ecc_point *r=
et,
+				struct l_ecc_point *p, uint64_t *scalar,
+				uint64_t *initial_z);
+bool l_ecc_point_add(struct l_ecc_curve *curve, struct l_ecc_point *ret,
+			struct l_ecc_point *p, struct l_ecc_point *q);
+bool l_ecc_valid_point(struct l_ecc_curve *curve, struct l_ecc_point *poin=
t);
+void l_ecc_be2native(struct l_ecc_curve *curve, uint64_t *dest,
+			uint64_t *bytes);
+
+void l_ecc_native2be(struct l_ecc_curve *curve, uint64_t *dest,
+			uint64_t *native);
+void l_ecc_compute_y_sqr(struct l_ecc_curve *curve, uint64_t *y_sqr,
+				uint64_t *x);
+bool l_ecc_compute_y(struct l_ecc_curve *curve, uint64_t *y, uint64_t *x,
+			uint8_t y_bit);
+
+bool l_ecc_compute_scalar(struct l_ecc_curve *curve, uint64_t *scalar,
+				uint64_t *rand, uint64_t *mask);
+
+bool l_ecc_point_inverse(struct l_ecc_curve *curve, struct l_ecc_point *po=
int);
+
+bool l_ecc_compute_residue(struct l_ecc_curve *curve,
+					uint64_t *qr_or_qnr, bool residue);
+
+bool l_ecc_is_quadradic_residue(struct l_ecc_curve *curve,
+					uint64_t *value, uint64_t *qr,
+					uint64_t *qnr);
+bool l_ecc_integer_add(struct l_ecc_curve *curve, uint64_t *ret, uint64_t =
*a,
+			uint64_t *b);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_ECC_H */
diff --git a/ell/ell.h b/ell/ell.h
index 4b0eac4..7bc26bc 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -57,3 +57,4 @@
 #include <ell/dbus-client.h>
 #include <ell/dhcp.h>
 #include <ell/cert.h>
+#include <ell/ecc.h>
-- =

2.17.1


--===============5708688243717604904==--

