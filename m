Content-Type: multipart/mixed; boundary="===============5216078402954780372=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 3/5] ecdh: moved ECDH from IWD
Date: Wed, 05 Dec 2018 09:38:03 -0800
Message-ID: <20181205173805.7141-3-james.prestwood@linux.intel.com>
In-Reply-To: <20181205173805.7141-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5216078402954780372==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Moved the ECDH implementation from IWD. API changes were made to utilize
l_ecc_point/l_ecc_constant types, as well as the curve object. Some sanity
checks were also added to ensure random keys were within the allowable rang=
e.
---
 Makefile.am |   7 +++-
 ell/ecdh.c  | 106 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecdh.h  |  51 +++++++++++++++++++++++++
 ell/ell.h   |   1 +
 4 files changed, 163 insertions(+), 2 deletions(-)
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
index 0000000..b3e4f4e
--- /dev/null
+++ b/ell/ecdh.c
@@ -0,0 +1,106 @@
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
+LIB_EXPORT bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
+					struct l_ecc_constant **private,
+					struct l_ecc_point **public)
+{
+	bool compliant =3D false;
+	int iter =3D 0;
+	uint64_t p2[L_ECC_MAX_DIGITS];
+
+	_ecc_calculate_p2(curve, p2);
+
+	*public =3D l_ecc_point_new(curve);
+
+	while (!compliant && iter++ < ECDH_MAX_ITERATIONS) {
+		*private =3D l_ecc_constant_new_random(curve);
+
+		_ecc_point_mult(*public, &curve->g, (*private)->c,
+					NULL, curve->p);
+
+		/* ensure public key is compliant */
+		if (_vli_cmp((*public)->y, p2, curve->ndigits) >=3D 0) {
+			compliant =3D true;
+			break;
+		}
+
+		l_ecc_constant_free(*private);
+	}
+
+	if (!compliant) {
+		l_ecc_point_free(*public);
+		return false;
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *cu=
rve,
+					const struct l_ecc_constant *private,
+					const struct l_ecc_point *other_public,
+					struct l_ecc_constant **secret)
+{
+	struct l_ecc_constant *z;
+	struct l_ecc_point *product;
+
+	if (unlikely(!curve))
+		return false;
+
+	z =3D l_ecc_constant_new_random(curve);
+
+	product =3D l_ecc_point_new(curve);
+
+	_ecc_point_mult(product, other_public, private->c, z->c, curve->p);
+
+	*secret =3D l_ecc_constant_new(curve, product->x, curve->ndigits * 8);
+
+	l_ecc_point_free(product);
+	l_ecc_constant_free(z);
+
+	return true;
+}
diff --git a/ell/ecdh.h b/ell/ecdh.h
new file mode 100644
index 0000000..51e80ca
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
+ * Generate a private/public key pair. private/public are out parameters a=
nd
+ * must be freed.
+ */
+bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
+					struct l_ecc_constant **private,
+					struct l_ecc_point **public);
+/*
+ * Generate a shared secret from a private/public key. secret is an out
+ * parameters and must be freed.
+ */
+bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *curve,
+					const struct l_ecc_constant *private,
+					const struct l_ecc_point *other_public,
+					struct l_ecc_constant **secret);
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


--===============5216078402954780372==--

