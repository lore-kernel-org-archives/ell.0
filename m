Content-Type: multipart/mixed; boundary="===============6886349201233753892=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/7] ecdh: Drop the curve parameter to
 l_ecdh_generate_shared_secret
Date: Fri, 21 Dec 2018 23:03:22 +0100
Message-ID: <20181221220326.10112-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6886349201233753892==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We already have a pointer to the curve in the public and private keys so
we can skip this parameter.
---
 ell/ecdh.c | 6 ++----
 ell/ecdh.h | 3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/ell/ecdh.c b/ell/ecdh.c
index 2c162e9..5ecbd44 100644
--- a/ell/ecdh.c
+++ b/ell/ecdh.c
@@ -83,17 +83,15 @@ LIB_EXPORT bool l_ecdh_generate_key_pair(const struct l=
_ecc_curve *curve,
 	return true;
 }
 =

-LIB_EXPORT bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *cu=
rve,
+LIB_EXPORT bool l_ecdh_generate_shared_secret(
 				const struct l_ecc_scalar *private_key,
 				const struct l_ecc_point *other_public,
 				struct l_ecc_scalar **secret)
 {
+	const struct l_ecc_curve *curve =3D private_key->curve;
 	struct l_ecc_scalar *z;
 	struct l_ecc_point *product;
 =

-	if (unlikely(!curve))
-		return false;
-
 	z =3D l_ecc_scalar_new_random(curve);
 =

 	product =3D l_ecc_point_new(curve);
diff --git a/ell/ecdh.h b/ell/ecdh.h
index 4b14535..34cbc6b 100644
--- a/ell/ecdh.h
+++ b/ell/ecdh.h
@@ -42,8 +42,7 @@ bool l_ecdh_generate_key_pair(const struct l_ecc_curve *c=
urve,
  * Generate a shared secret from a private/public key. secret is an out
  * parameters and must be freed.
  */
-bool l_ecdh_generate_shared_secret(const struct l_ecc_curve *curve,
-				const struct l_ecc_scalar *private_key,
+bool l_ecdh_generate_shared_secret(const struct l_ecc_scalar *private_key,
 				const struct l_ecc_point *other_public,
 				struct l_ecc_scalar **secret);
 =

-- =

2.19.1


--===============6886349201233753892==--

