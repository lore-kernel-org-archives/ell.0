Content-Type: multipart/mixed; boundary="===============4870999318640148503=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v4 4/6] unit: Check asymmetric cipher result lengths
Date: Wed, 15 Jun 2016 10:18:21 -0700
Message-ID: <20160615171823.20699-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160615171823.20699-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4870999318640148503==
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


--===============4870999318640148503==--

