Content-Type: multipart/mixed; boundary="===============8068865532021742457=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v7 3/5] unit: Check asymmetric cipher result lengths
Date: Mon, 20 Jun 2016 16:53:38 -0700
Message-ID: <20160620235340.30410-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160620235340.30410-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8068865532021742457==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 78d1fcb..8c27d03 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -184,16 +184,20 @@ static void test_rsa(const void *data)
 {
 	struct l_asymmetric_cipher *cipher;
 	char buf[128];
+	ssize_t encrypted, decrypted;
 =

 	cipher =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1_V1_5,
 						rsa_priv_key,
 						sizeof(rsa_priv_key), false);
 	assert(cipher);
-	assert(l_asymmetric_cipher_encrypt(cipher, FIXED_STR, buf, 100, 128));
+	encrypted =3D l_asymmetric_cipher_encrypt(cipher, FIXED_STR, buf,
+						100, 128);
+	assert(encrypted =3D=3D 128);
 =

 	assert(memcmp(FIXED_STR, buf, 100));
 =

-	assert(l_asymmetric_cipher_decrypt(cipher, buf, buf, 128, 128));
+	decrypted =3D l_asymmetric_cipher_decrypt(cipher, buf, buf, 128, 128);
+	assert(decrypted =3D=3D 100);
 =

 	assert(!memcmp(FIXED_STR, buf, 100));
 =

-- =

2.9.0


--===============8068865532021742457==--

