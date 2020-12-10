Content-Type: multipart/mixed; boundary="===============7745771454288542995=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/13] unit: Add some RC2 test vectors
Date: Thu, 10 Dec 2020 20:32:24 +0100
Message-ID: <20201210193224.526513-4-andrew.zaborowski@intel.com>
In-Reply-To: <20201210193224.526513-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7745771454288542995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 8eca796..15fe25b 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -379,6 +379,61 @@ static void test_aead(const void *data)
 	l_free(tag);
 }
 =

+struct rc2_test_vector {
+	const char *key;
+	const char *plaintext;
+	const char *ciphertext;
+};
+
+/* RFC2268 Section 5 (where Effective key length =3D=3D 8 * Key length) */
+static const struct rc2_test_vector rc2_test_1 =3D {
+	.key =3D "ffffffffffffffff",
+	.plaintext =3D "ffffffffffffffff",
+	.ciphertext =3D "278b27e42e2f0d49",
+};
+
+static const struct rc2_test_vector rc2_test_2 =3D {
+	.key =3D "3000000000000000",
+	.plaintext =3D "1000000000000001",
+	.ciphertext =3D "30649edf9be7d2c2",
+};
+
+static const struct rc2_test_vector rc2_test_3 =3D {
+	.key =3D "88bca90e90875a7f0f79c384627bafb2",
+	.plaintext =3D "0000000000000000",
+	.ciphertext =3D "2269552ab0f85ca6",
+};
+
+static void test_rc2(const void *data)
+{
+	const struct rc2_test_vector *v =3D data;
+	uint8_t *key;
+	size_t key_length;
+	struct l_cipher *cipher;
+	uint8_t *plaintext;
+	uint8_t *ciphertext;
+	uint8_t buf[8];
+
+	assert(l_cipher_is_supported(L_CIPHER_RC2_CBC));
+
+	key =3D l_util_from_hexstring(v->key, &key_length);
+	plaintext =3D l_util_from_hexstring(v->plaintext, NULL);
+	ciphertext =3D l_util_from_hexstring(v->ciphertext, NULL);
+
+	cipher =3D l_cipher_new(L_CIPHER_RC2_CBC, key, key_length);
+	assert(cipher);
+	l_cipher_encrypt(cipher, plaintext, buf, 8);
+	assert(!memcmp(buf, ciphertext, 8));
+
+	l_cipher_decrypt(cipher, buf, buf, 8);
+	l_cipher_free(cipher);
+	assert(!memcmp(buf, plaintext, 8));
+
+	l_free(plaintext);
+	l_free(ciphertext);
+	l_free(key);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -408,5 +463,9 @@ int main(int argc, char *argv[])
 		l_test_add("aes_gcm test 6", test_aead, &gcm_test6);
 	}
 =

+	l_test_add("rc2/test 1", test_rc2, &rc2_test_1);
+	l_test_add("rc2/test 2", test_rc2, &rc2_test_2);
+	l_test_add("rc2/test 3", test_rc2, &rc2_test_3);
+
 	return l_test_run();
 }
-- =

2.27.0

--===============7745771454288542995==--

