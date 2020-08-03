Content-Type: multipart/mixed; boundary="===============2264531565714945274=="
MIME-Version: 1.0
From: Ard Biesheuvel <ardb@kernel.org>
Subject: [PATCH 2/2] cipher: remove obsolete arc4 support
Date: Mon, 03 Aug 2020 12:54:49 +0200
Message-ID: <20200803105449.124714-3-ardb@kernel.org>
In-Reply-To: <20200803105449.124714-1-ardb@kernel.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2264531565714945274==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The rc4 cipher is obsolete, and is only relevant for very specific use
cases where compatibility with legacy hardware or software is needed.
Now that iwd has been updated to use its own arc4 implementation, which
is tailored to its needs, and support for the RC4 based TLS cipher suites
has been dropped, we can drop the implementation from libell.

Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
---
 ell/cipher.c       |  8 +--
 ell/cipher.h       |  4 +-
 unit/test-cipher.c | 56 --------------------
 3 files changed, 7 insertions(+), 61 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 4a27b5e3556f..300d7c0dd3b1 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -149,8 +149,6 @@ static const char *cipher_type_to_name(enum l_cipher_ty=
pe type)
 		return "cbc(aes)";
 	case L_CIPHER_AES_CTR:
 		return "ctr(aes)";
-	case L_CIPHER_ARC4:
-		return "ecb(arc4)";
 	case L_CIPHER_DES:
 		return "ecb(des)";
 	case L_CIPHER_DES_CBC:
@@ -619,7 +617,11 @@ static void init_supported()
 	strcpy((char *) salg.salg_type, "skcipher");
 =

 	for (c =3D L_CIPHER_AES; c <=3D L_CIPHER_DES3_EDE_CBC; c++) {
-		strcpy((char *) salg.salg_name, cipher_type_to_name(c));
+		const char *name =3D cipher_type_to_name(c);
+
+		if (!name)
+			continue;
+		strcpy((char *) salg.salg_name, name);
 =

 		if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0)
 			continue;
diff --git a/ell/cipher.h b/ell/cipher.h
index 84f29888253f..e1a4bda14f81 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -33,8 +33,8 @@ enum l_cipher_type {
 	L_CIPHER_AES =3D 0,
 	L_CIPHER_AES_CBC,
 	L_CIPHER_AES_CTR,
-	L_CIPHER_ARC4,
-	L_CIPHER_DES,
+	/* L_CIPHER_ARC4, */
+	L_CIPHER_DES =3D 4,
 	L_CIPHER_DES_CBC,
 	L_CIPHER_DES3_EDE_CBC,
 };
diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 9469e0eefe62..7fe32a21ba57 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -98,59 +98,6 @@ static void test_aes_ctr(const void *data)
 	l_cipher_free(cipher);
 }
 =

-static void test_arc4(const void *data)
-{
-	struct l_cipher *cipher;
-	char buf[256];
-	int r;
-
-	static const unsigned char expect_plaintext[] =3D {
-		0xbb, 0xf3, 0x16, 0xe8, 0xd9, 0x40, 0xaf, 0x0a, 0xd3,
-	};
-	static const unsigned char expect_pedia[] =3D {
-		0x10, 0x21, 0xbf, 0x04, 0x20,
-	};
-	static const unsigned char expect_attack[] =3D {
-		0x45, 0xa0, 0x1f, 0x64, 0x5f, 0xc3, 0x5b, 0x38, 0x35, 0x52,
-		0x54, 0x4b, 0x9b, 0xf5,
-	};
-
-	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Key", 3);
-	assert(cipher);
-	l_cipher_encrypt(cipher, "Plaintext", buf, 9);
-	assert(!memcmp(buf, expect_plaintext, 9));
-	l_cipher_free(cipher);
-
-	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Wiki", 4);
-	assert(cipher);
-	l_cipher_encrypt(cipher, "pedia", buf, 5);
-	assert(!memcmp(buf, expect_pedia, 5));
-	l_cipher_free(cipher);
-
-	cipher =3D l_cipher_new(L_CIPHER_ARC4, "Secret", 6);
-	assert(cipher);
-	l_cipher_encrypt(cipher, "Attack@dawn", buf, 14);
-	assert(!memcmp(buf, expect_attack, 14));
-	l_cipher_free(cipher);
-
-	cipher =3D l_cipher_new(L_CIPHER_ARC4, KEY_STR, KEY_LEN);
-	assert(cipher);
-
-	memcpy(buf, FIXED_STR, FIXED_LEN);
-
-	l_cipher_encrypt(cipher, buf, buf, FIXED_LEN);
-
-	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
-	assert(r);
-
-	l_cipher_decrypt(cipher, buf, buf, FIXED_LEN);
-
-	r =3D memcmp(buf, FIXED_STR, FIXED_LEN);
-	assert(!r);
-
-	l_cipher_free(cipher);
-}
-
 struct aead_test_vector {
 	enum l_aead_cipher_type type;
 	char *aad;
@@ -385,9 +332,6 @@ int main(int argc, char *argv[])
 	if (l_cipher_is_supported(L_CIPHER_AES_CTR))
 		l_test_add("aes_ctr", test_aes_ctr, NULL);
 =

-	if (l_cipher_is_supported(L_CIPHER_ARC4))
-		l_test_add("arc4", test_arc4, NULL);
-
 	if (l_aead_cipher_is_supported(L_AEAD_CIPHER_AES_CCM)) {
 		l_test_add("aes_ccm long nonce", test_aead, &ccm_long_nonce);
 		l_test_add("aes_ccm short nonce", test_aead, &ccm_short_nonce);
-- =

2.20.1

--===============2264531565714945274==--

