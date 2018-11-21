Content-Type: multipart/mixed; boundary="===============8970129135339929120=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 16/16] unit: Update tests usage of certificate API
Date: Wed, 21 Nov 2018 16:09:03 +0100
Message-ID: <20181121150903.24437-16-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8970129135339929120==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 34 ++++++++++++----------------
 unit/test-pem.c | 60 +++++++++++++++++++++++++++++--------------------
 unit/test-tls.c | 16 ++++++-------
 3 files changed, 58 insertions(+), 52 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index ba27e19..f4235b9 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -493,10 +493,8 @@ static void test_trust_chain(const void *data)
 =

 static void test_key_crypto(const void *data)
 {
-	uint8_t *privkey;
-	size_t privkeylen;
 	struct l_cert *cert;
-	struct l_key *key;
+	struct l_key *privkey;
 	struct l_key *pubkey;
 	bool is_public;
 	size_t keybits;
@@ -507,23 +505,21 @@ static void test_key_crypto(const void *data)
 	int hash =3D L_CHECKSUM_NONE;
 	int rsa =3D L_KEY_RSA_PKCS1_V1_5;
 =

-	privkey =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
-						NULL, NULL, &privkeylen);
-	assert(privkey);
 	cert =3D tls_cert_load_file(CERTDIR "cert-client.pem");
 	assert(cert);
-
 	pubkey =3D l_cert_get_pubkey(cert);
 	assert(pubkey);
+	l_cert_free(cert);
 =

-	key =3D l_key_new(L_KEY_RSA, privkey, privkeylen);
-	assert(key);
-	success =3D l_key_get_info(key, rsa, hash, &keybits, &is_public);
+	privkey =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
+						NULL, NULL);
+	assert(privkey);
+	success =3D l_key_get_info(privkey, rsa, hash, &keybits, &is_public);
 	assert(success);
 	assert(keybits =3D=3D 2048);
 	assert(!is_public);
 =

-	success =3D l_key_get_info(key, rsa, L_CHECKSUM_NONE, &keybits,
+	success =3D l_key_get_info(privkey, rsa, L_CHECKSUM_NONE, &keybits,
 					&is_public);
 	assert(success);
 	assert(keybits =3D=3D 2048);
@@ -546,14 +542,14 @@ static void test_key_crypto(const void *data)
 				sizeof(ciphertext), sizeof(decrypted));
 	assert(len < 0);
 =

-	len =3D l_key_decrypt(key, rsa, hash, ciphertext, decrypted,
+	len =3D l_key_decrypt(privkey, rsa, hash, ciphertext, decrypted,
 				sizeof(ciphertext), sizeof(decrypted));
 	assert(len =3D=3D (ssize_t)strlen(plaintext));
 	assert(strcmp(plaintext, (char *)decrypted) =3D=3D 0);
 =

 	/* Decrypt reference ciphertext */
 	memset(decrypted, 0, sizeof(decrypted));
-	len =3D l_key_decrypt(key, rsa, hash, reference_ciphertext, decrypted,
+	len =3D l_key_decrypt(privkey, rsa, hash, reference_ciphertext, decrypted,
 				sizeof(reference_ciphertext),
 				sizeof(decrypted));
 	assert(len =3D=3D (ssize_t)strlen(plaintext));
@@ -563,7 +559,7 @@ static void test_key_crypto(const void *data)
 	memset(decrypted, 0, sizeof(decrypted));
 	memcpy(ciphertext, reference_ciphertext, sizeof(ciphertext));
 	ciphertext[0] =3D ciphertext[0] ^ (uint8_t)0xFF;
-	len =3D l_key_decrypt(key, rsa, hash, ciphertext, decrypted,
+	len =3D l_key_decrypt(privkey, rsa, hash, ciphertext, decrypted,
 				sizeof(ciphertext),
 				sizeof(decrypted));
 	assert(len < 0);
@@ -573,7 +569,7 @@ static void test_key_crypto(const void *data)
 				strlen(plaintext), sizeof(ciphertext));
 	assert(len < 0);
 =

-	len =3D l_key_sign(key, rsa, hash, plaintext, ciphertext,
+	len =3D l_key_sign(privkey, rsa, hash, plaintext, ciphertext,
 				strlen(plaintext), sizeof(ciphertext));
 	assert(len =3D=3D sizeof(ciphertext));
 =

@@ -581,7 +577,7 @@ static void test_key_crypto(const void *data)
 				strlen(plaintext), sizeof(ciphertext));
 	assert(success);
 =

-	success =3D l_key_verify(key, rsa, hash, plaintext, ciphertext,
+	success =3D l_key_verify(privkey, rsa, hash, plaintext, ciphertext,
 				strlen(plaintext), sizeof(ciphertext));
 	assert(success);
 =

@@ -592,14 +588,12 @@ static void test_key_crypto(const void *data)
 =

 	/* Corrupt signature */
 	ciphertext[42] =3D ciphertext[52] ^ (uint8_t)0xFF;
-	success =3D l_key_verify(key, rsa, hash, plaintext, ciphertext,
+	success =3D l_key_verify(privkey, rsa, hash, plaintext, ciphertext,
 				strlen(plaintext), sizeof(ciphertext));
 	assert(!success);
 =

-	l_key_free(key);
+	l_key_free(privkey);
 	l_key_free(pubkey);
-	l_free(privkey);
-	l_cert_free(cert);
 }
 =

 int main(int argc, char *argv[])
diff --git a/unit/test-pem.c b/unit/test-pem.c
index 3325e54..085e061 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -91,36 +91,47 @@ static void test_encrypted_pkey(const void *data)
 {
 	const char *encrypted_pem =3D data;
 	const char *plaintext_pem =3D CERTDIR "cert-client-key-pkcs8.pem";
-	bool encrypted;
-	size_t size1, size2;
-	uint8_t *pkey1, *pkey2;
+	bool is_encrypted;
+	size_t size;
+	uint8_t encrypted1[256], encrypted2[256], plaintext[256];
+	struct l_key *pkey1, *pkey2;
+	bool is_public;
 =

-	encrypted =3D false;
-	assert(!l_pem_load_private_key(encrypted_pem, NULL,
-					&encrypted, &size1));
-	assert(encrypted);
+	is_encrypted =3D false;
+	assert(!l_pem_load_private_key(encrypted_pem, NULL, &is_encrypted));
+	assert(is_encrypted);
 =

-	encrypted =3D false;
+	is_encrypted =3D false;
 	assert(!l_pem_load_private_key(encrypted_pem, "wrong-passwd",
-					&encrypted, &size1));
-	assert(encrypted);
+					&is_encrypted));
+	assert(is_encrypted);
 =

-	encrypted =3D false;
-	pkey1 =3D l_pem_load_private_key(encrypted_pem, "abc",
-					&encrypted, &size1);
+	is_encrypted =3D false;
+	pkey1 =3D l_pem_load_private_key(encrypted_pem, "abc", &is_encrypted);
 	assert(pkey1);
-	assert(encrypted);
+	assert(is_encrypted);
 =

-	pkey2 =3D l_pem_load_private_key(plaintext_pem, NULL,
-					&encrypted, &size2);
+	pkey2 =3D l_pem_load_private_key(plaintext_pem, NULL, &is_encrypted);
 	assert(pkey2);
-	assert(!encrypted);
-
-	assert(size1 =3D=3D size2);
-	assert(!memcmp(pkey1, pkey2, size1));
-
-	l_free(pkey1);
-	l_free(pkey2);
+	assert(!is_encrypted);
+
+	/*
+	 * l_key_extract doesn't work for private keys so compare encrypt
+	 * results instead of key exponent.
+	 */
+	memset(plaintext, 42, 256);
+	assert(l_key_get_info(pkey1, L_KEY_RSA_RAW, L_CHECKSUM_NONE,
+				&size, &is_public));
+	assert(size =3D=3D 2048);
+	assert(!is_public);
+	assert(l_key_encrypt(pkey1, L_KEY_RSA_RAW, L_CHECKSUM_NONE,
+				plaintext, encrypted1, 256, 256) =3D=3D 256);
+	assert(l_key_encrypt(pkey2, L_KEY_RSA_RAW, L_CHECKSUM_NONE,
+				plaintext, encrypted2, 256, 256) =3D=3D 256);
+	assert(!memcmp(encrypted1, encrypted2, 256));
+
+	l_key_free(pkey1);
+	l_key_free(pkey2);
 }
 =

 int main(int argc, char *argv[])
@@ -136,7 +147,8 @@ int main(int argc, char *argv[])
 =

 	if (!l_checksum_is_supported(L_CHECKSUM_MD5, false) ||
 			!l_checksum_is_supported(L_CHECKSUM_SHA1, false) ||
-			!l_cipher_is_supported(L_CIPHER_DES_CBC))
+			!l_cipher_is_supported(L_CIPHER_DES_CBC) ||
+			!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		goto done;
 =

 	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
diff --git a/unit/test-tls.c b/unit/test-tls.c
index a3a8905..8f00736 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -213,19 +213,19 @@ static void test_tls12_prf(const void *data)
 static void test_certificates(const void *data)
 {
 	struct l_cert *cert;
-	struct l_cert *cacert;
-	struct l_cert *wrongca;
+	struct l_queue *cacert;
+	struct l_queue *wrongca;
 	struct l_certchain *chain;
 =

 	cert =3D tls_cert_load_file(CERTDIR "cert-server.pem");
 	assert(cert);
 	chain =3D certchain_new_from_leaf(cert);
 =

-	cacert =3D tls_cert_load_file(CERTDIR "cert-ca.pem");
-	assert(cacert);
+	cacert =3D l_pem_load_certificate_list(CERTDIR "cert-ca.pem");
+	assert(cacert && !l_queue_isempty(cacert));
 =

-	wrongca =3D tls_cert_load_file(CERTDIR "cert-intca.pem");
-	assert(wrongca);
+	wrongca =3D l_pem_load_certificate_list(CERTDIR "cert-intca.pem");
+	assert(wrongca && !l_queue_isempty(wrongca));
 =

 	assert(!l_certchain_verify(chain, wrongca));
 =

@@ -234,8 +234,8 @@ static void test_certificates(const void *data)
 	assert(l_certchain_verify(chain, NULL));
 =

 	l_certchain_free(chain);
-	l_cert_free(cacert);
-	l_cert_free(wrongca);
+	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
+	l_queue_destroy(wrongca, (l_queue_destroy_func_t) l_cert_free);
 }
 =

 struct tls_conn_test {
-- =

2.19.1


--===============8970129135339929120==--

