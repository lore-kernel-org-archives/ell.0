Content-Type: multipart/mixed; boundary="===============8568401994209860019=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 2/2] ecc: document where ECC groups came from
Date: Tue, 15 Jan 2019 14:43:08 -0800
Message-ID: <20190115224308.6100-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190115224308.6100-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8568401994209860019==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For future reference a comment was added pointing to RFC 5114
---
 ell/ecc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index b2110df..a9eedf4 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -32,6 +32,9 @@
 #include "ecc-private.h"
 #include "random.h"
 =

+/*
+ * RFC 5114 - Section 2.6 256-bit Random ECP Group
+ */
 #define P256_CURVE_P { 0xFFFFFFFFFFFFFFFFull, 0x00000000FFFFFFFFull, \
 			0x0000000000000000ull, 0xFFFFFFFF00000001ull }
 #define P256_CURVE_GX { 0xF4A13945D898C296ull, 0x77037D812DEB33A0ull,   \
@@ -56,6 +59,9 @@ static const struct l_ecc_curve p256 =3D {
 	.b =3D P256_CURVE_B,
 };
 =

+/*
+ * RFC 5114 - Section 2.7 384-bit Random ECP Group
+ */
 #define P384_CURVE_P {	0x00000000FFFFFFFFull, 0xFFFFFFFF00000000ull, \
 			0xFFFFFFFFFFFFFFFEull, 0xFFFFFFFFFFFFFFFFull, \
 			0xFFFFFFFFFFFFFFFFull, 0xFFFFFFFFFFFFFFFFull }
-- =

2.17.1


--===============8568401994209860019==--

