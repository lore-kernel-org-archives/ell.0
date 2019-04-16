Content-Type: multipart/mixed; boundary="===============5140481423451721291=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 2/2] unit: add test for AES-CTR
Date: Tue, 16 Apr 2019 10:46:42 -0700
Message-ID: <20190416174642.16264-2-james.prestwood@linux.intel.com>
In-Reply-To: <20190416174642.16264-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5140481423451721291==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index fe9ae72..bd8c05d 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -71,6 +71,33 @@ static void test_aes(const void *data)
 	l_cipher_free(cipher);
 }
 =

+static void test_aes_ctr(const void *data)
+{
+	struct l_cipher *cipher;
+	uint8_t iv[8] =3D { 0 };
+	char buf[256];
+	int r;
+
+	cipher =3D l_cipher_new(L_CIPHER_AES_CTR, KEY_STR, KEY_LEN);
+	assert(cipher);
+
+	l_cipher_set_iv(cipher, iv, sizeof(iv));
+
+	memcpy(buf, FIXED_STR, FIXED_LEN);
+
+	l_cipher_encrypt(cipher, buf, buf, FIXED_LEN);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(r);
+
+	l_cipher_decrypt(cipher, buf, buf, FIXED_LEN);
+
+	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
+	assert(!r);
+
+	l_cipher_free(cipher);
+}
+
 static void test_arc4(const void *data)
 {
 	struct l_cipher *cipher;
@@ -335,6 +362,9 @@ int main(int argc, char *argv[])
 	if (l_cipher_is_supported(L_CIPHER_AES))
 		l_test_add("aes", test_aes, NULL);
 =

+	if (l_cipher_is_supported(L_CIPHER_AES_CTR))
+		l_test_add("aes_ctr", test_aes_ctr, NULL);
+
 	if (l_cipher_is_supported(L_CIPHER_ARC4))
 		l_test_add("arc4", test_arc4, NULL);
 =

-- =

2.17.1


--===============5140481423451721291==--

