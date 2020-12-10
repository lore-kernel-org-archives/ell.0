Content-Type: multipart/mixed; boundary="===============5410061280645080101=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/13] unit: Re-add the ARC4 test
Date: Thu, 10 Dec 2020 20:32:23 +0100
Message-ID: <20201210193224.526513-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193224.526513-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5410061280645080101==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 7dddffd..8eca796 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -103,6 +103,60 @@ static void test_aes_ctr(const void *data)
 	l_cipher_free(cipher);
 }
 =

+static void test_arc4(const void *data)
+{
+	struct l_cipher *cipher;
+	char buf[256];
+	int r;
+
+	static const unsigned char expect_plaintext[] =3D {
+		0xbb, 0xf3, 0x16, 0xe8, 0xd9, 0x40, 0xaf, 0x0a, 0xd3,
+	};
+	static const unsigned char expect_pedia[] =3D {
+		0x10, 0x21, 0xbf, 0x04, 0x20,
+	};
+	static const unsigned char expect_attack[] =3D {
+		0x45, 0xa0, 0x1f, 0x64, 0x5f, 0xc3, 0x5b, 0x38, 0x35, 0x52,
+		0x54, 0x4b, 0x9b, 0xf5,
+	};
+
+	assert(l_cipher_is_supported(L_CIPHER_ARC4));
+
+	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Key", 3);
+	assert(cipher);
+	l_cipher_encrypt(cipher, "Plaintext", buf, 9);
+	assert(!memcmp(buf, expect_plaintext, 9));
+	l_cipher_free(cipher);
+
+	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Wiki", 4);
+	assert(cipher);
+	l_cipher_encrypt(cipher, "pedia", buf, 5);
+	assert(!memcmp(buf, expect_pedia, 5));
+	l_cipher_free(cipher);
+
+	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Secret", 6);
+	assert(cipher);
+	l_cipher_encrypt(cipher, "Attack at dawn", buf, 14);
+	assert(!memcmp(buf, expect_attack, 14));
+	l_cipher_free(cipher);
+
+	cipher =3D l_cipher_new(L_CIPHER_ARC4, KEY_STR, KEY_LEN);
+	assert(cipher);
+
+	memcpy(buf, FIXED_STR, FIXED_LEN);
+
+	l_cipher_encrypt(cipher, buf, buf, FIXED_LEN);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(r);
+
+	l_cipher_decrypt(cipher, buf, buf, FIXED_LEN);
+	l_cipher_free(cipher);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(!r);
+}
+
 struct aead_test_vector {
 	enum l_aead_cipher_type type;
 	char *aad;
@@ -337,6 +391,8 @@ int main(int argc, char *argv[])
 	if (l_cipher_is_supported(L_CIPHER_AES_CTR))
 		l_test_add("aes_ctr", test_aes_ctr, NULL);
 =

+	l_test_add("arc4", test_arc4, NULL);
+
 	if (l_aead_cipher_is_supported(L_AEAD_CIPHER_AES_CCM)) {
 		l_test_add("aes_ccm long nonce", test_aead, &ccm_long_nonce);
 		l_test_add("aes_ccm short nonce", test_aead, &ccm_short_nonce);
-- =

2.27.0

--===============5410061280645080101==--

