Content-Type: multipart/mixed; boundary="===============1994726482895941168=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 03/12] unit: Add gcm(aes) test vectors
Date: Wed, 14 Nov 2018 14:18:53 +0100
Message-ID: <20181114131902.1695-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1994726482895941168==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-cipher.c | 127 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 114 insertions(+), 13 deletions(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 4765c3e..fe9ae72 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -124,7 +124,8 @@ static void test_arc4(const void *data)
 	l_cipher_free(cipher);
 }
 =

-struct ccm_test_vector {
+struct aead_test_vector {
+	enum l_aead_cipher_type type;
 	char *aad;
 	char *plaintext;
 	char *key;
@@ -133,7 +134,8 @@ struct ccm_test_vector {
 	char *tag;
 };
 =

-static const struct ccm_test_vector ccm_long_nonce =3D {
+static const struct aead_test_vector ccm_long_nonce =3D {
+	.type =3D L_AEAD_CIPHER_AES_CCM,
 	.aad =3D
 	"333b6b8fda49c6e671bad05c7e2cafa88bd47f9b0aef1a358bc87d04f26f6c82",
 	.plaintext =3D
@@ -145,7 +147,8 @@ static const struct ccm_test_vector ccm_long_nonce =3D {
 	.tag =3D "e0a03b982c5afc8a937373d7d2b0e7a3"
 };
 =

-static const struct ccm_test_vector ccm_short_nonce =3D {
+static const struct aead_test_vector ccm_short_nonce =3D {
+	.type =3D L_AEAD_CIPHER_AES_CCM,
 	.plaintext =3D
 	"a3b3fdf26d213f83c5f656b00f77253b68959c188767d584914887602c787595",
 	.aad =3D
@@ -157,7 +160,8 @@ static const struct ccm_test_vector ccm_short_nonce =3D=
 {
 	.tag =3D "ee007aafe91135c39855ebf3db96d7ff"
 };
 =

-static const struct ccm_test_vector ccm_no_aad =3D {
+static const struct aead_test_vector ccm_no_aad =3D {
+	.type =3D L_AEAD_CIPHER_AES_CCM,
 	.plaintext =3D
 	"90795fffab99cffdeee5cadafe448ea4df74c480f9d7e1e481ee49adeee2732a",
 	.aad =3D "",
@@ -168,7 +172,94 @@ static const struct ccm_test_vector ccm_no_aad =3D {
 	.tag =3D "efd1dc938802cd845a16f32a60eabd0f"
 };
 =

-static void test_aes_ccm(const void *data)
+/* https://tools.ietf.org/html/draft-mcgrew-gcm-test-01 */
+
+static const struct aead_test_vector gcm_test1 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D "000043218765432100000000",
+	.plaintext =3D
+	"45000048699a000080114db7c0a80102c0a801010a9bf15638d3010000010000"
+	"00000000045f736970045f756470037369700963796265726369747902646b00"
+	"0021000101020201",
+	/* 128-bit key */
+	.key =3D "4c80cdefbb5d10da906ac73c3613a634",
+	.nonce =3D "2e443b684956ed7e3b244cfe",
+	.ciphertext =3D
+	"fecf537e729d5b07dc30df528dd22b768d1b98736696a6fd348509fa13ceac34"
+	"cfa2436f14a3f3cf65925bf1f4a13c5d15b21e1884f5ff6247aeabb786b93bce"
+	"61bc17d768fd9732",
+	.tag =3D "459018148f6cbe722fd04796562dfdb4",
+};
+
+static const struct aead_test_vector gcm_test2 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D "0000a5f80000000a",
+	.plaintext =3D
+	"45000028a4ad4000400678800a01038f0a010612802306b8cb712602dd6bb03e"
+	"501016d075680001",
+	/* 192-bit key */
+	.key =3D "feffe9928665731c6d6a8f9467308308feffe9928665731c",
+	.nonce =3D "cafebabefacedbaddecaf888",
+	.ciphertext =3D
+	"a5b1f8066029aea40e598b8122de02420938b3ab33f828e687b8858b5bfbdbd0"
+	"315b27452144cc77",
+	.tag =3D "95457b9652037f5318027b5b4cd7a636",
+};
+
+static const struct aead_test_vector gcm_test3 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D "4a2cbfe300000002",
+	.plaintext =3D
+	"4500003069a6400080062690c0a801029389155e0a9e008b2dc57ee000000000"
+	"7002400020bf0000020405b40101040201020201",
+	/* 256-bit key */
+	.key =3D
+	"abbccddef00112233445566778899aababbccddef00112233445566778899aab",
+	.nonce =3D "112233440102030405060708",
+	.ciphertext =3D
+	"ff425c9b724599df7a3bcd510194e00d6a78107f1b0b1cbf06efae9d65a5d763"
+	"748a637985771d347f0545659f14e99def842d8e",
+	.tag =3D "b335f4eecfdbf831824b4c4915956c96",
+};
+
+static const struct aead_test_vector gcm_test4 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D "0000000000000001",
+	.plaintext =3D
+	"4500003c99c500008001cb7a40679318010101010800075c0200440061626364"
+	"65666768696a6b6c6d6e6f707172737475767761626364656667686901020201",
+	.key =3D "00000000000000000000000000000000",
+	.nonce =3D "000000000000000000000000",
+	.ciphertext =3D
+	"4688daf2f973a392732909c331d56d60f694abaa414b5e7ff5fdcdfff5e9a284"
+	"456476492719ffb64de7d9dca1e1d894bc3bd57873ed4d181d19d4d5c8c18af3",
+	.tag =3D "f821d496eeb096e98ad2b69e4799c71d",
+};
+
+static const struct aead_test_vector gcm_test5 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D "335467aeffffffff",
+	.plaintext =3D "01020201",
+	.key =3D "7d773d00c144c525ac619d18c84a3f47",
+	.nonce =3D "d966426743457e9182443bc6",
+	.ciphertext =3D "437f866b",
+	.tag =3D "cb3f699fe9b0822bac961c4504bef270",
+};
+
+static const struct aead_test_vector gcm_test6 =3D {
+	.type =3D L_AEAD_CIPHER_AES_GCM,
+	.aad =3D
+	"0000432100000007000000000000000045000030da3a00008001df3bc0a80005"
+	"c0a800010800c6cd020007006162636465666768696a6b6c6d6e6f7071727374"
+	"01020201",
+	.plaintext =3D "",
+	.key =3D "4c80cdefbb5d10da906ac73c3613a634",
+	.nonce =3D "22433c640000000000000000",
+	.ciphertext =3D "",
+	.tag =3D "f2a9a836e155106aa8dcd618e4099aaa",
+};
+
+static void test_aead(const void *data)
 {
 	struct l_aead_cipher *cipher;
 	char *encbuf;
@@ -177,10 +268,11 @@ static void test_aes_ccm(const void *data)
 	size_t decbuflen;
 	int r;
 	bool success;
-	const struct ccm_test_vector *tv =3D data;
+	const struct aead_test_vector *tv =3D data;
 =

 	size_t ptlen;
-	uint8_t *pt =3D l_util_from_hexstring(tv->plaintext, &ptlen);
+	uint8_t *pt =3D l_util_from_hexstring(tv->plaintext, &ptlen) ?:
+		(uint8_t[]) {};
 	size_t aadlen;
 	uint8_t *aad =3D l_util_from_hexstring(tv->aad, &aadlen);
 	size_t keylen;
@@ -199,7 +291,7 @@ static void test_aes_ccm(const void *data)
 	decbuf =3D alloca(decbuflen);
 	memset(decbuf, 0, decbuflen);
 =

-	cipher =3D l_aead_cipher_new(L_AEAD_CIPHER_AES_CCM, key, keylen, taglen);
+	cipher =3D l_aead_cipher_new(tv->type, key, keylen, taglen);
 	assert(cipher);
 =

 	success =3D l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
@@ -225,7 +317,8 @@ static void test_aes_ccm(const void *data)
 	assert(!r);
 =

 	l_aead_cipher_free(cipher);
-	l_free(pt);
+	if (ptlen)
+		l_free(pt);
 	l_free(key);
 	l_free(aad);
 	l_free(nonce);
@@ -246,10 +339,18 @@ int main(int argc, char *argv[])
 		l_test_add("arc4", test_arc4, NULL);
 =

 	if (l_aead_cipher_is_supported(L_AEAD_CIPHER_AES_CCM)) {
-		l_test_add("aes_ccm long nonce", test_aes_ccm, &ccm_long_nonce);
-		l_test_add("aes_ccm short nonce", test_aes_ccm,
-							&ccm_short_nonce);
-		l_test_add("aes_ccm no AAD", test_aes_ccm, &ccm_no_aad);
+		l_test_add("aes_ccm long nonce", test_aead, &ccm_long_nonce);
+		l_test_add("aes_ccm short nonce", test_aead, &ccm_short_nonce);
+		l_test_add("aes_ccm no AAD", test_aead, &ccm_no_aad);
+	}
+
+	if (l_aead_cipher_is_supported(L_AEAD_CIPHER_AES_GCM)) {
+		l_test_add("aes_gcm test 1", test_aead, &gcm_test1);
+		l_test_add("aes_gcm test 2", test_aead, &gcm_test2);
+		l_test_add("aes_gcm test 3", test_aead, &gcm_test3);
+		l_test_add("aes_gcm test 4", test_aead, &gcm_test4);
+		l_test_add("aes_gcm test 5", test_aead, &gcm_test5);
+		l_test_add("aes_gcm test 6", test_aead, &gcm_test6);
 	}
 =

 	return l_test_run();
-- =

2.19.1


--===============1994726482895941168==--

