Content-Type: multipart/mixed; boundary="===============7934470603233905971=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/7] unit: Update l_ecdh_generate_shared_secret parameters
Date: Fri, 21 Dec 2018 23:03:24 +0100
Message-ID: <20181221220326.10112-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7934470603233905971==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-ecdh.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/unit/test-ecdh.c b/unit/test-ecdh.c
index cc0f3a8..d340f64 100644
--- a/unit/test-ecdh.c
+++ b/unit/test-ecdh.c
@@ -73,8 +73,8 @@ static void test_basic(const void *data)
 	assert(l_ecdh_generate_key_pair(curve, &private1, &public1));
 	assert(l_ecdh_generate_key_pair(curve, &private2, &public2));
 =

-	assert(l_ecdh_generate_shared_secret(curve, private1, public2, &secret1));
-	assert(l_ecdh_generate_shared_secret(curve, private2, public1, &secret2));
+	assert(l_ecdh_generate_shared_secret(private1, public2, &secret1));
+	assert(l_ecdh_generate_shared_secret(private2, public1, &secret2));
 =

 	assert(!memcmp(secret1->c, secret2->c, 32));
 =

@@ -130,10 +130,8 @@ static void test_vector_p256(const void *data)
 =

 	use_real_getrandom =3D false;
 =

-	assert(l_ecdh_generate_shared_secret(curve, a_secret, b_public,
-						&a_shared));
-	assert(l_ecdh_generate_shared_secret(curve, b_secret, a_public,
-						&b_shared));
+	assert(l_ecdh_generate_shared_secret(a_secret, b_public, &a_shared));
+	assert(l_ecdh_generate_shared_secret(b_secret, a_public, &b_shared));
 =

 	assert(!memcmp(a_shared->c, ss_buf, 32));
 	assert(!memcmp(b_shared->c, ss_buf, 32));
@@ -195,10 +193,8 @@ static void test_vector_p384(const void *data)
 =

 	use_real_getrandom =3D false;
 =

-	assert(l_ecdh_generate_shared_secret(curve, a_secret, b_public,
-						&a_shared));
-	assert(l_ecdh_generate_shared_secret(curve, b_secret, a_public,
-						&b_shared));
+	assert(l_ecdh_generate_shared_secret(a_secret, b_public, &a_shared));
+	assert(l_ecdh_generate_shared_secret(b_secret, a_public, &b_shared));
 =

 	assert(!memcmp(a_shared->c, ss_buf, 48));
 	assert(!memcmp(b_shared->c, ss_buf, 48));
-- =

2.19.1


--===============7934470603233905971==--

