Content-Type: multipart/mixed; boundary="===============6733793425036445447=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v5 3/4] ecdh: moved ECDH from IWD
Date: Tue, 11 Dec 2018 14:37:08 -0800
Message-ID: <20181211223709.31531-3-james.prestwood@linux.intel.com>
In-Reply-To: <20181211223709.31531-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6733793425036445447==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Moved the ECDH implementation from IWD. API changes were made to utilize
l_ecc_point/l_ecc_constant types, as well as the curve object. Some sanity
checks were also added to ensure random keys were within the allowable rang=
e.
---
 Makefile.am |   6 ++-
 ell/ecdh.c  | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/ecdh.h  |  53 +++++++++++++++++++++++++
 ell/ell.h   |   1 +
 ell/ell.sym |   2 +
 5 files changed, 169 insertions(+), 2 deletions(-)
 create mode 100644 ell/ecdh.c
 create mode 100644 ell/ecdh.h

diff --git a/Makefile.am b/Makefile.am
index 061a36f..821ddc8 100644
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

@@ -117,7 +118,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/ecc-private.h \
 			ell/ecc.h \
 			ell/ecc-external.c \
-			ell/ecc.c
+			ell/ecc.c \
+			ell/ecdh.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ecdh.c b/ell/ecdh.c
new file mode 100644
index 0000000..0b8c347
--- /dev/null
+++ b/ell/ecdh.c
@@ -0,0 +1,109 @@
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
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
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
+ * Some sane maximum for calculating the public key.
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
+					struct l_ecc_scalar **out_private,
+					struct l_ecc_point **out_public)
+{
+	bool compliant =3D false;
+	int iter =3D 0;
+	uint64_t p2[L_ECC_MAX_DIGITS];
+
+	_ecc_calculate_p2(curve, p2);
+
+	*out_public =3D l_ecc_point_new(curve);
+
+	while (!compliant && iter++ < ECDH_MAX_ITERATIONS) {
+		*out_private =3D l_ecc_scalar_new_random(curve);
+
+		_ecc_point_mult(*out_public, &curve->g, (*out_private)->c,
+					NULL, curve->p);
+
+		/* ensure public key is compliant */
+		if (_vli_cmp((*out_public)->y, p2, curve->ndigits) >=3D 0) {
+			compliant =3D true;
+			break;
+		}
+
+		l_ecc_scalar_free(*out_private);
+	}
+
+	if (!compliant) {
+		l_ecc_point_free(*out_public);
+		return false;
+	}
+
+	return true;
+}
+
+LIB_EXPORT bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *cu=
rve,
+				const struct l_ecc_scalar *private_key,
+				const struct l_ecc_point *other_public,
+				struct l_ecc_scalar **secret)
+{
+	struct l_ecc_scalar *z;
+	struct l_ecc_point *product;
+
+	if (unlikely(!curve))
+		return false;
+
+	z =3D l_ecc_scalar_new_random(curve);
+
+	product =3D l_ecc_point_new(curve);
+
+	_ecc_point_mult(product, other_public, private_key->c, z->c, curve->p);
+
+	*secret =3D _ecc_constant_new(curve, product->x, curve->ndigits * 8);
+
+	l_ecc_point_free(product);
+	l_ecc_scalar_free(z);
+
+	return true;
+}
diff --git a/ell/ecdh.h b/ell/ecdh.h
new file mode 100644
index 0000000..f6f2d40
--- /dev/null
+++ b/ell/ecdh.h
@@ -0,0 +1,53 @@
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
+struct l_ecc_curve;
+struct l_ecc_point;
+struct l_ecc_scalar;
+
+/*
+ * Generate a private/public key pair. private/public are out parameters a=
nd
+ * must be freed.
+ */
+bool l_ecdh_generate_key_pair(const struct l_ecc_curve *curve,
+					struct l_ecc_scalar **out_private,
+					struct l_ecc_point **out_public);
+/*
+ * Generate a shared secret from a private/public key. secret is an out
+ * parameters and must be freed.
+ */
+bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *curve,
+				const struct l_ecc_scalar *private_key,
+				const struct l_ecc_point *other_public,
+				struct l_ecc_scalar **secret);
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
diff --git a/ell/ell.sym b/ell/ell.sym
index 38f0eb4..70a38f9 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -459,6 +459,8 @@ global:
 	l_ecc_scalar_new_random;
 	l_ecc_scalar_get_data;
 	l_ecc_scalar_free;
+	l_ecdh_generate_key_pair;
+	l_ecdh_generate_shared_secret;
 local:
 	*;
 };
-- =

2.17.1


--===============6733793425036445447==--

