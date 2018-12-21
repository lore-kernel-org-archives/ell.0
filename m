Content-Type: multipart/mixed; boundary="===============2836603578232460186=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/7] ecdh: Erase local copy of shared-secret after use
Date: Fri, 21 Dec 2018 23:03:20 +0100
Message-ID: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2836603578232460186==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ecdh.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/ecdh.c b/ell/ecdh.c
index 0b8c347..2c162e9 100644
--- a/ell/ecdh.c
+++ b/ell/ecdh.c
@@ -102,6 +102,8 @@ LIB_EXPORT bool l_ecdh_generate_shared_secret(const str=
uct l_ecc_curve *curve,
 =

 	*secret =3D _ecc_constant_new(curve, product->x, curve->ndigits * 8);
 =

+	memset(product->x, 0, curve->ndigits * 8);
+	memset(product->y, 0, curve->ndigits * 8);
 	l_ecc_point_free(product);
 	l_ecc_scalar_free(z);
 =

-- =

2.19.1


--===============2836603578232460186==--

