Content-Type: multipart/mixed; boundary="===============7431793466315501509=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/2] unit: Add AEAD cipher tests
Date: Wed, 21 Dec 2016 18:09:35 -0800
Message-ID: <20161222020935.21617-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161222020935.21617-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7431793466315501509==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 105 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 105 insertions(+)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index eaf97a0..64216c6 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <assert.h>
+#include <alloca.h>
 =

 #include <ell/ell.h>
 =

@@ -122,6 +123,106 @@ static void test_arc4(const void *data)
 	l_cipher_free(cipher);
 }
 =

+struct ccm_test_vector {
+	char *aad;
+	char *plaintext;
+	char *key;
+	char *nonce;
+	char *ciphertext;
+	char *tag;
+};
+
+static const struct ccm_test_vector ccm_long_nonce =3D {
+	.aad =3D
+	"333b6b8fda49c6e671bad05c7e2cafa88bd47f9b0aef1a358bc87d04f26f6c82",
+	.plaintext =3D
+	"1293201eb30ddd693b2eb23c1e6c20d5add2202afc71679ca2eba14f73b77bcd",
+	.key =3D "fa536cf6c309d45c1baaa658f674758d",
+	.nonce =3D "e0c5241bf0014ca88511d73a30",
+	.ciphertext =3D
+	"2e54ebaa38da9a2b03a1147495565c31d07e793b01fd28b2adeacac6f76ae84e",
+	.tag =3D "e0a03b982c5afc8a937373d7d2b0e7a3"
+};
+
+static const struct ccm_test_vector ccm_short_nonce =3D {
+	.plaintext =3D
+	"a3b3fdf26d213f83c5f656b00f77253b68959c188767d584914887602c787595",
+	.aad =3D
+	"fcc20524894b4603fefb8029eff485a513ce4753d0d3a27c3a2c69088fa7fab7",
+	.key =3D "7d84efac51291e868c7b7702181a3936",
+	.nonce =3D "1bb3e62620462a",
+	.ciphertext =3D
+	"3222192ee773cef4a87175b73b3875320f18b7e016d17d52fb01f0f6ca10bb5f",
+	.tag =3D "ee007aafe91135c39855ebf3db96d7ff"
+};
+
+static const struct ccm_test_vector ccm_no_aad =3D {
+	.plaintext =3D
+	"90795fffab99cffdeee5cadafe448ea4df74c480f9d7e1e481ee49adeee2732a",
+	.aad =3D "",
+	.key =3D "7b3da7d5ef41b5eef19cf8fb4ca19519",
+	.nonce =3D "96722de7516afb",
+	.ciphertext =3D
+	"9160dd0e0a8ddd13bf4acb0c6f3cf4794c5459d36a378cfb4a31e6b00840d78a",
+	.tag =3D "efd1dc938802cd845a16f32a60eabd0f"
+};
+
+static void test_aes_ccm(const void *data)
+{
+	struct l_aead_cipher *cipher;
+	char *encbuf;
+	size_t encbuflen;
+	char *decbuf;
+	size_t decbuflen;
+	int r;
+	const struct ccm_test_vector *tv =3D data;
+
+	size_t ptlen;
+	uint8_t *pt =3D l_util_from_hexstring(tv->plaintext, &ptlen);
+	size_t aadlen;
+	uint8_t *aad =3D l_util_from_hexstring(tv->aad, &aadlen);
+	size_t keylen;
+	uint8_t *key =3D l_util_from_hexstring(tv->key, &keylen);
+	size_t noncelen;
+	uint8_t *nonce =3D l_util_from_hexstring(tv->nonce, &noncelen);
+	size_t ctlen;
+	uint8_t *ct =3D l_util_from_hexstring(tv->ciphertext, &ctlen);
+	size_t taglen;
+	uint8_t *tag =3D l_util_from_hexstring(tv->tag, &taglen);
+
+	encbuflen =3D ctlen + taglen;
+	encbuf =3D alloca(encbuflen);
+	memset(encbuf, 0, encbuflen);
+	decbuflen =3D ptlen;
+	decbuf =3D alloca(decbuflen);
+	memset(decbuf, 0, decbuflen);
+
+	cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM, key, keylen, taglen);
+	assert(cipher);
+
+	l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
+				nonce, noncelen, encbuf, encbuflen);
+
+	r =3D memcmp(encbuf, ct, ctlen);
+	assert(!r);
+	r =3D memcmp(encbuf + ctlen, tag, taglen);
+	assert(!r);
+
+	l_aead_cipher_decrypt(cipher, encbuf, encbuflen, aad, aadlen, nonce,
+				noncelen, decbuf, decbuflen);
+
+	r =3D memcmp(decbuf, pt, ptlen);
+	assert(!r);
+
+	l_aead_cipher_free(cipher);
+	l_free(pt);
+	l_free(key);
+	l_free(aad);
+	l_free(nonce);
+	l_free(ct);
+	l_free(tag);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -132,5 +233,9 @@ int main(int argc, char *argv[])
 =

 	l_test_add("arc4", test_arc4, NULL);
 =

+	l_test_add("aes_ccm long nonce", test_aes_ccm, &ccm_long_nonce);
+	l_test_add("aes_ccm short nonce", test_aes_ccm, &ccm_short_nonce);
+	l_test_add("aes_ccm no AAD", test_aes_ccm, &ccm_no_aad);
+
 	return l_test_run();
 }
-- =

2.11.0


--===============7431793466315501509==--

