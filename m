Content-Type: multipart/mixed; boundary="===============8366035155253452660=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] ecc: Clear point coordinates, use explicit_bzero
Date: Tue, 19 Mar 2019 01:48:40 +0100
Message-ID: <20190319004843.13451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8366035155253452660==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We would only zero out memory used by the scalar type because
Diffie-Hellman secrets are scalars, but in PWD the PWD and PK values may
be points so also clear those.  Update l_ecc_scalar_free to use
explicit_bzero too.
---
 ell/ecc.c  | 7 ++++++-
 ell/ecdh.c | 2 --
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index 88c8373..5fa91a8 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -541,6 +541,11 @@ LIB_EXPORT ssize_t l_ecc_point_get_data(const struct l=
_ecc_point *p, void *buf,
 =

 LIB_EXPORT void l_ecc_point_free(struct l_ecc_point *p)
 {
+	if (unlikely(!p))
+		return;
+
+	explicit_bzero(p->x, p->curve->ndigits * 8);
+	explicit_bzero(p->y, p->curve->ndigits * 8);
 	l_free(p);
 }
 =

@@ -612,7 +617,7 @@ LIB_EXPORT void l_ecc_scalar_free(struct l_ecc_scalar *=
c)
 	if (unlikely(!c))
 		return;
 =

-	memset(c->c, 0, c->curve->ndigits * 8);
+	explicit_bzero(c->c, c->curve->ndigits * 8);
 	l_free(c);
 }
 =

diff --git a/ell/ecdh.c b/ell/ecdh.c
index 5ecbd44..a10189f 100644
--- a/ell/ecdh.c
+++ b/ell/ecdh.c
@@ -100,8 +100,6 @@ LIB_EXPORT bool l_ecdh_generate_shared_secret(
 =

 	*secret =3D _ecc_constant_new(curve, product->x, curve->ndigits * 8);
 =

-	memset(product->x, 0, curve->ndigits * 8);
-	memset(product->y, 0, curve->ndigits * 8);
 	l_ecc_point_free(product);
 	l_ecc_scalar_free(z);
 =

-- =

2.19.1


--===============8366035155253452660==--

