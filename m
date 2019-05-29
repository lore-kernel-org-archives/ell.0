Content-Type: multipart/mixed; boundary="===============7777858154283404464=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] cipher: add AES-CMAC hashing support
Date: Tue, 28 May 2019 17:49:49 -0700
Message-ID: <20190529004949.25387-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7777858154283404464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The algorythm is supported in the kernel, and it is used heavily by
Bluetooth Mesh, and is the one Mesh required algorythm missing from ELL.
---
 ell/cipher.c       | 88 ++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h       | 16 ++++++++++
 unit/test-cipher.c | 74 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 178 insertions(+)

diff --git a/ell/cipher.c b/ell/cipher.c
index 7b909df..2f2e482 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -90,6 +90,7 @@ struct af_alg_iv {
 =

 static uint32_t supported_ciphers;
 static uint32_t supported_aead_ciphers;
+static uint32_t supported_hash_ciphers;
 =

 struct l_cipher {
 	int type;
@@ -103,6 +104,11 @@ struct l_aead_cipher {
 	int decrypt_sk;
 };
 =

+struct l_hash_cipher {
+	int type;
+	int encrypt_sk;
+};
+
 static int create_alg(const char *alg_type, const char *alg_name,
 			const void *key, size_t key_length, size_t tag_length)
 {
@@ -248,6 +254,42 @@ error_free:
 	return NULL;
 }
 =

+static const char *hash_cipher_type_to_name(enum l_hash_cipher_type type)
+{
+	switch (type) {
+	case L_HASH_CIPHER_AES_CMAC:
+		return "cmac(aes)";
+	}
+
+	return NULL;
+}
+
+LIB_EXPORT struct l_hash_cipher *l_hash_cipher_new(enum l_hash_cipher_type=
 type,
+							const void *key,
+							size_t key_length)
+{
+	struct l_hash_cipher *cipher;
+	const char *uninitialized_var(alg_name);
+
+	if (unlikely(!key))
+		return NULL;
+
+	if (type !=3D L_HASH_CIPHER_AES_CMAC)
+		return NULL;
+
+	cipher =3D l_new(struct l_hash_cipher, 1);
+	cipher->type =3D type;
+	alg_name =3D hash_cipher_type_to_name(type);
+
+	cipher->encrypt_sk =3D create_alg("hash", alg_name, key, key_length,
+					0);
+	if (cipher->encrypt_sk >=3D 0)
+		return cipher;
+
+	l_free(cipher);
+	return NULL;
+}
+
 LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
 {
 	if (unlikely(!cipher))
@@ -270,6 +312,16 @@ LIB_EXPORT void l_aead_cipher_free(struct l_aead_ciphe=
r *cipher)
 	l_free(cipher);
 }
 =

+LIB_EXPORT void l_hash_cipher_free(struct l_hash_cipher *cipher)
+{
+	if (unlikely(!cipher))
+		return;
+
+	close(cipher->encrypt_sk);
+
+	l_free(cipher);
+}
+
 static ssize_t operate_cipher(int sk, __u32 operation,
 				const void *in, size_t in_len,
 				const void *ad, size_t ad_len,
@@ -610,6 +662,20 @@ LIB_EXPORT bool l_aead_cipher_decrypt(struct l_aead_ci=
pher *cipher,
 			(ssize_t)out_len;
 }
 =

+LIB_EXPORT bool l_hash_cipher_encrypt(struct l_hash_cipher *cipher,
+					const void *in, size_t in_len,
+					void *out, size_t out_len)
+{
+	if (unlikely(!cipher))
+		return false;
+
+	if (unlikely(!in) || unlikely(!out))
+		return false;
+
+	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in, in_len,
+				NULL, 0, NULL, 0, out, out_len) >=3D 0;
+}
+
 static void init_supported()
 {
 	static bool initialized =3D false;
@@ -617,6 +683,7 @@ static void init_supported()
 	int sk;
 	enum l_cipher_type c;
 	enum l_aead_cipher_type a;
+	enum l_hash_cipher_type h;
 =

 	if (likely(initialized))
 		return;
@@ -651,6 +718,17 @@ static void init_supported()
 		supported_aead_ciphers |=3D 1 << a;
 	}
 =

+	strcpy((char *) salg.salg_type, "hash");
+
+	for (h =3D L_HASH_CIPHER_AES_CMAC; h <=3D L_HASH_CIPHER_AES_CMAC; h++) {
+		strcpy((char *) salg.salg_name, hash_cipher_type_to_name(h));
+
+		if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0)
+			continue;
+
+		supported_hash_ciphers |=3D 1 << h;
+	}
+
 	close(sk);
 }
 =

@@ -673,3 +751,13 @@ LIB_EXPORT bool l_aead_cipher_is_supported(enum l_aead=
_cipher_type type)
 =

 	return supported_aead_ciphers & (1 << type);
 }
+
+LIB_EXPORT bool l_hash_cipher_is_supported(enum l_hash_cipher_type type)
+{
+	if (type !=3D L_HASH_CIPHER_AES_CMAC)
+		return false;
+
+	init_supported();
+
+	return supported_hash_ciphers & (1 << type);
+}
diff --git a/ell/cipher.h b/ell/cipher.h
index 84f2988..a18fbf0 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -84,8 +84,24 @@ bool l_aead_cipher_decrypt(struct l_aead_cipher *cipher,
 				const void *nonce, size_t nonce_len,
 				void *out, size_t out_len);
 =

+struct l_hash_cipher;
+
+enum l_hash_cipher_type {
+	L_HASH_CIPHER_AES_CMAC =3D 0,
+};
+
+struct l_hash_cipher *l_hash_cipher_new(enum l_hash_cipher_type type,
+					const void *key, size_t key_length);
+
+void l_hash_cipher_free(struct l_hash_cipher *cipher);
+
+bool l_hash_cipher_encrypt(struct l_hash_cipher *cipher,
+					const void *in, size_t len,
+					void *out, size_t out_len);
+
 bool l_cipher_is_supported(enum l_cipher_type type);
 bool l_aead_cipher_is_supported(enum l_aead_cipher_type type);
+bool l_hash_cipher_is_supported(enum l_hash_cipher_type type);
 =

 #ifdef __cplusplus
 }
diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 3bb7602..7d08f39 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -358,6 +358,75 @@ static void test_aead(const void *data)
 	l_free(tag);
 }
 =

+struct hash_test_vector {
+	enum l_hash_cipher_type type;
+	char *plaintext;
+	char *key;
+	char *ciphertext;
+};
+
+/* Hash AES_CMAC tests based on Bluetooth Mesh published sample data */
+static const struct hash_test_vector hash_test1 =3D {
+	.type =3D L_HASH_CIPHER_AES_CMAC,
+	.plaintext =3D "74657374",
+	.key =3D "00000000000000000000000000000000",
+	.ciphertext =3D "b73cefbd641ef2ea598c2b6efb62f79c",
+};
+
+static const struct hash_test_vector hash_test2 =3D {
+	.type =3D L_HASH_CIPHER_AES_CMAC,
+	.plaintext =3D "f7a2a44f8e8a8029064f173ddc1e2b00",
+	.key =3D "4f90480c1871bfbffd16971f4d8d10b1",
+	.ciphertext =3D "2ea6467aa3378c4c545eda62935b9b86",
+};
+
+static void test_hash(const void *data)
+{
+	struct l_hash_cipher *cipher;
+	char *encbuf;
+	size_t encbuflen;
+	char *decbuf;
+	size_t decbuflen;
+	int r;
+	bool success;
+	const struct hash_test_vector *tv =3D data;
+
+	size_t ptlen;
+	uint8_t *pt =3D l_util_from_hexstring(tv->plaintext, &ptlen) ?:
+		(uint8_t[]) {};
+	size_t keylen;
+	uint8_t *key =3D l_util_from_hexstring(tv->key, &keylen);
+	size_t ctlen;
+	uint8_t *ct =3D l_util_from_hexstring(tv->ciphertext, &ctlen) ?:
+		(uint8_t[]) {};
+
+	encbuflen =3D ctlen;
+	encbuf =3D alloca(encbuflen);
+	memset(encbuf, 0, encbuflen);
+	decbuflen =3D ptlen;
+	decbuf =3D alloca(decbuflen);
+	memset(decbuf, 0, decbuflen);
+
+	cipher =3D l_hash_cipher_new(tv->type, key, keylen);
+	assert(cipher);
+
+	success =3D l_hash_cipher_encrypt(cipher, pt, ptlen, encbuf, encbuflen);
+	assert(success);
+
+	r =3D memcmp(encbuf, ct, ctlen);
+	assert(!r);
+
+	l_hash_cipher_free(cipher);
+
+	if (ptlen)
+		l_free(pt);
+
+	l_free(key);
+
+	if (ctlen)
+		l_free(ct);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -388,5 +457,10 @@ int main(int argc, char *argv[])
 		l_test_add("aes_gcm test 6", test_aead, &gcm_test6);
 	}
 =

+	if (l_hash_cipher_is_supported(L_HASH_CIPHER_AES_CMAC)) {
+		l_test_add("hash_aes_cmac test 1", test_hash, &hash_test1);
+		l_test_add("hash_aes_cmac test 2", test_hash, &hash_test2);
+	}
+
 	return l_test_run();
 }
-- =

2.14.5


--===============7777858154283404464==--

