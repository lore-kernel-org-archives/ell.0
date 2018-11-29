Content-Type: multipart/mixed; boundary="===============6822856790463859779=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 3/9] ecdh: moved ECDH from IWD
Date: Thu, 29 Nov 2018 14:08:02 -0800
Message-ID: <20181129220808.22151-3-james.prestwood@linux.intel.com>
In-Reply-To: <20181129220808.22151-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6822856790463859779==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Moved the ECDH implementation from IWD. Minor API changes were made,
e.g. to take an l_ecc_curve object. Some sanity checks were also
added to ensure random keys were within the allowable range.
---
 Makefile.am |   7 +-
 ell/ecdh.c  | 200 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecdh.h  |  51 ++++++++++++++
 ell/ell.h   |   1 +
 4 files changed, 257 insertions(+), 2 deletions(-)
 create mode 100644 ell/ecdh.c
 create mode 100644 ell/ecdh.h

diff --git a/Makefile.am b/Makefile.am
index f33f992..69c3cea 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -50,7 +50,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/net.h \
 			ell/dhcp.h \
 			ell/cert.h \
-			ell/ecc.h
+			ell/ecc.h \
+			ell/ecdh.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -116,7 +117,9 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/cert-private.h \
 			ell/ecc-private.h \
 			ell/ecc.h \
-			ell/ecc.c
+			ell/ecc.c \
+			ell/ecdh.h \
+			ell/ecdh.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ecdh.c b/ell/ecdh.c
new file mode 100644
index 0000000..be6603c
--- /dev/null
+++ b/ell/ecdh.c
@@ -0,0 +1,200 @@
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
+#include <stdint.h>
+
+#include "private.h"
+#include "ecc-private.h"
+#include "ecc.h"
+#include "ecdh.h"
+#include "random.h"
+
+/*
+ * Some sane maximum for calculating the public key. This *shouldn't* ever=
 be
+ * reached in normal conditions.
+ */
+#define ECDH_MAX_ITERATIONS 20
+
+/*
+ * IETF - Compact representation of an elliptic curve point:
+ * https://tools.ietf.org/id/draft-jivsov-ecc-compact-00.xml
+ *
+ * "min(y,p-y) can be calculated with the help of the pre-calculated value
+ *  p2=3D(p-1)/2. min(y,p-y) is y if y<p2 and p-y otherwise."
+ */
+static void calculate_p2(struct l_ecc_curve *curve, uint64_t *p2)
+{
+	const uint64_t *prime =3D l_ecc_curve_get_prime(curve);
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+	uint64_t one[L_ECC_MAX_DIGITS] =3D { 1 };
+
+	_vli_mod_sub(p2, prime, one, prime, ndigits);
+	_vli_rshift1(p2, ndigits);
+}
+
+/* Checks that 0 < private < prime */
+static bool private_is_valid(struct l_ecc_curve *curve, void *private)
+{
+	const uint64_t *prime =3D l_ecc_curve_get_prime(curve);
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+	uint64_t zero[L_ECC_MAX_DIGITS] =3D { 0 };
+
+	if (_vli_cmp((uint64_t *)private, prime, ndigits) > 0 ||
+			_vli_cmp((uint64_t *)private, zero, ndigits) =3D=3D 0)
+		return false;
+
+	return true;
+}
+
+/*
+ * IETF draft-jivsov-ecc-compact-00 Section 4.2.1
+ *
+ * The following algorithm calculates a key pair {k, Q=3Dk*G=3D(x,y)}, whe=
re k is
+ * the private key and Q=3D(x,y) is the public key.
+ *
+ * Black box generation:
+ *     1. Generate a key pair {k, Q=3Dk*G=3D(x,y)} with KG
+ *     2. if( y !=3D min(y,p-y) ) goto step 1
+ *     3. output {k, Q=3D(x,y)} as a key pair
+ */
+LIB_EXPORT bool l_ecdh_generate_key_pair(struct l_ecc_curve *curve, void *=
private,
+					size_t priv_len, void *public,
+					size_t pub_len)
+{
+	struct l_ecc_point pub;
+	bool compliant =3D false;
+	int iter =3D 0;
+	uint8_t *ptr =3D public;
+	struct l_ecc_point *g =3D l_ecc_curve_get_generator(curve);
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+	unsigned int nbytes =3D ndigits * sizeof(uint64_t);
+	uint64_t p2[L_ECC_MAX_DIGITS];
+
+	calculate_p2(curve, p2);
+
+	/* the caller should only be expecting len(p) or len(p) * 2 */
+	if (pub_len !=3D (nbytes * 2) && pub_len !=3D nbytes)
+		return false;
+
+	while (!compliant && iter++ < ECDH_MAX_ITERATIONS) {
+		if (!l_getrandom(private, priv_len))
+			return false;
+
+		if (!private_is_valid(curve, private))
+			continue;
+
+		/* private * G(x,y) =3D public key */
+		l_ecc_point_multiply(curve, &pub, g, (uint64_t *)private, NULL);
+
+		/* ensure public key is compliant */
+		if (_vli_cmp(pub.y, p2, ndigits) >=3D 0) {
+			compliant =3D true;
+			break;
+		}
+	}
+
+	if (!compliant)
+		return false;
+
+	memcpy(ptr, pub.x, nbytes);
+	pub_len -=3D nbytes;
+	ptr +=3D nbytes;
+
+	if (pub_len)
+		memcpy(ptr, pub.y, nbytes);
+
+	return true;
+}
+
+/*
+ * IETF draft-jivsov-ecc-compact-00 Section 4.1
+ * Encoding and decoding of an elliptic curve point
+ * ...
+ * Decoding:
+ * Given the compact representation of Q, return canonical representation
+ * of Q=3D(x,y) as follows:
+ *     1. y' =3D sqrt( x^3 + a*x + b ), where y'>0
+ *     2. y =3D min(y',p-y')
+ *     3. Q=3D(x,y) is the canonical representation of the point
+ */
+static bool decode_point(struct l_ecc_curve *curve, const uint64_t *x,
+				struct l_ecc_point *point)
+{
+	uint64_t y_min[L_ECC_MAX_DIGITS];
+	uint64_t p2[L_ECC_MAX_DIGITS];
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+	const uint64_t *prime =3D l_ecc_curve_get_prime(curve);
+
+	if (!_ecc_compute_y(curve, y_min, (uint64_t *)x))
+		return false;
+
+	calculate_p2(curve, p2);
+
+	if (_vli_cmp(y_min, p2, ndigits) >=3D 0)
+		_vli_mod_sub(point->y, prime, y_min, prime, ndigits);
+	else
+		memcpy(point->y, y_min, ndigits * 8);
+
+	memcpy(point->x, x, ndigits * 8);
+
+	point->ndigits =3D ndigits;
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecdh_generate_shared_secret(struct l_ecc_curve *curve,
+						const void *private,
+						const void *other_public,
+						size_t pub_len, void *secret,
+						size_t secret_len)
+{
+	struct l_ecc_point product;
+	struct l_ecc_point public;
+	uint64_t z[L_ECC_MAX_DIGITS];
+	unsigned int ndigits =3D l_ecc_curve_get_ndigits(curve);
+	unsigned int nbytes =3D ndigits * sizeof(uint64_t);
+
+	if (secret_len > nbytes)
+		return false;
+
+	if (pub_len =3D=3D nbytes) {
+		/*
+		 * Only half the public key was given, the remainder (Y) must
+		 * be decoded.
+		 */
+		if (!decode_point(curve, other_public, &public))
+			return false;
+	} else if (pub_len =3D=3D nbytes * 2)
+		l_ecc_point_set(curve, &public, (void *)other_public,
+					(void *)other_public + nbytes);
+	else
+		return false;
+
+	if (!l_getrandom(z, nbytes))
+		return false;
+
+	l_ecc_point_multiply(curve, &product, &public, (uint64_t *)private, z);
+
+	memcpy(secret, product.x, secret_len);
+
+	return true;
+}
diff --git a/ell/ecdh.h b/ell/ecdh.h
new file mode 100644
index 0000000..0d41891
--- /dev/null
+++ b/ell/ecdh.h
@@ -0,0 +1,51 @@
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
+#ifndef __ELL_ECDH_H
+#define __ELL_ECDH_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+#include "ecc.h"
+
+/*
+ * Generate a private/public key pair. All inputs are expected in little-e=
ndian.
+ */
+bool l_ecdh_generate_key_pair(struct l_ecc_curve *curve, void *private,
+					size_t priv_len, void *public,
+					size_t pub_len);
+/*
+ * Generate a shared secret from a private/public key. All inputs are expe=
cted
+ * in little-endian.
+ */
+bool l_ecdh_generate_shared_secret(struct l_ecc_curve *curve,
+						const void *private,
+						const void *other_public,
+						size_t pub_len, void *secret,
+						size_t secret_len);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_ECDH_H */
diff --git a/ell/ell.h b/ell/ell.h
index 7bc26bc..aab6417 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -58,3 +58,4 @@
 #include <ell/dhcp.h>
 #include <ell/cert.h>
 #include <ell/ecc.h>
+#include <ell/ecdh.h>
-- =

2.17.1


--===============6822856790463859779==--

