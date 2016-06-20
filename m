Content-Type: multipart/mixed; boundary="===============2933690071438953248=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v6 4/5] unit: Check decryption against known ciphertext
Date: Mon, 20 Jun 2016 14:47:19 -0700
Message-ID: <20160620214720.24016-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160620214720.24016-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2933690071438953248==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Include known-good ciphertext and make sure it can be correctly
decrypted. Also confirm that corrupted ciphertext triggers a
decryption error.
---
 unit/test-cipher.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 8c27d03..12a922a 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -180,6 +180,29 @@ static uint8_t rsa_priv_key[] =3D {
 	0x05, 0x3e, 0x55, 0x14, 0xd9, 0xe4, 0xa4, 0x7f, 0xb7, 0x4f
 };
 =

+/* Reference ciphertext:
+ * $ openssl rsautl -in fixed_str -inkey privkey.der -keyform DER -encrypt=
 \
+ * > -pkcs -out ciphertext
+ * $ xxd -i ciphertext
+ *
+ * where fixed_str is a file containing the first 100 characters of
+ * FIXED_STR (above) and privkey.der contains the binary data from the
+ * rsa_priv_key array.
+ */
+static uint8_t ciphertext[128] =3D {
+	0x50, 0x86, 0x87, 0x72, 0x37, 0xc1, 0xc7, 0x99, 0xa9, 0xff, 0x56, 0x92,
+	0x9b, 0x8a, 0xf6, 0x31, 0x9b, 0x11, 0x2c, 0x27, 0x1c, 0xa9, 0x07, 0x9b,
+	0xac, 0xb9, 0x31, 0xcd, 0xc1, 0x10, 0x90, 0xd7, 0x3c, 0xa1, 0x43, 0xa1,
+	0xdb, 0xb2, 0x67, 0x48, 0x28, 0xac, 0x0e, 0xbd, 0xd4, 0x62, 0x6b, 0xbd,
+	0x81, 0xf9, 0x5b, 0xd0, 0x29, 0xe5, 0xc8, 0x9a, 0x71, 0x69, 0xd1, 0x61,
+	0x72, 0x95, 0xa5, 0x10, 0x83, 0xee, 0xb4, 0x6d, 0x79, 0xf8, 0xae, 0xe1,
+	0x49, 0xdd, 0x5b, 0x1f, 0x4d, 0x2e, 0xd7, 0xa9, 0xf0, 0xf0, 0x81, 0x01,
+	0x38, 0x58, 0x78, 0x0f, 0x89, 0x3d, 0x60, 0xdb, 0x99, 0x19, 0xb0, 0x14,
+	0x9d, 0xf7, 0xc8, 0x6e, 0xc3, 0x69, 0xdd, 0xb2, 0xcc, 0x07, 0x32, 0x3b,
+	0x88, 0xd3, 0xfa, 0x72, 0xe9, 0xaa, 0x66, 0xc5, 0xd3, 0x4a, 0xff, 0x87,
+	0x6a, 0x78, 0x05, 0x2d, 0x16, 0x7c, 0x98, 0x58
+};
+
 static void test_rsa(const void *data)
 {
 	struct l_asymmetric_cipher *cipher;
@@ -198,9 +221,22 @@ static void test_rsa(const void *data)
 =

 	decrypted =3D l_asymmetric_cipher_decrypt(cipher, buf, buf, 128, 128);
 	assert(decrypted =3D=3D 100);
+	assert(!memcmp(FIXED_STR, buf, 100));
 =

+	/* Decrypt reference ciphertext */
+	memset(buf, 0, 128);
+	decrypted =3D l_asymmetric_cipher_decrypt(cipher, ciphertext, buf,
+						128, 128);
+	assert(decrypted =3D=3D 100);
 	assert(!memcmp(FIXED_STR, buf, 100));
 =

+	/* Decrypt corrupted ciphertext */
+	ciphertext[0] =3D ciphertext[0] ^ (uint8_t)0xFF;
+	memset(buf, 0, 128);
+	decrypted =3D l_asymmetric_cipher_decrypt(cipher, ciphertext, buf,
+						128, 128);
+	assert(decrypted < 0);
+
 	l_asymmetric_cipher_free(cipher);
 }
 =

-- =

2.9.0


--===============2933690071438953248==--

