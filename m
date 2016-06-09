Content-Type: multipart/mixed; boundary="===============5806722533392329275=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 4/5] unit: Check asymmetric cipher result lengths
Date: Thu, 09 Jun 2016 16:59:58 -0700
Message-ID: <20160609235959.1527-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160609235959.1527-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5806722533392329275==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 2527dcc..23021bf 100644
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
 						sizeof(rsa_priv_key));
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

2.8.4


--===============5806722533392329275==--

