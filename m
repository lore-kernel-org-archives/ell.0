Content-Type: multipart/mixed; boundary="===============6340464264288283854=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 7/7] unit: Add tests for key-based asymmetric crypto
Date: Fri, 29 Jul 2016 11:12:01 -0700
Message-ID: <20160729181201.16446-7-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160729181201.16446-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6340464264288283854==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/cert-client-key-pkcs8.pem |  28 ++++++
 unit/gencerts.sh               |   1 +
 unit/test-key.c                | 198 +++++++++++++++++++++++++++++++++++++=
+++-
 3 files changed, 225 insertions(+), 2 deletions(-)
 create mode 100644 unit/cert-client-key-pkcs8.pem

diff --git a/unit/cert-client-key-pkcs8.pem b/unit/cert-client-key-pkcs8.pem
new file mode 100644
index 0000000..738b825
--- /dev/null
+++ b/unit/cert-client-key-pkcs8.pem
@@ -0,0 +1,28 @@
+-----BEGIN PRIVATE KEY-----
+MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDhOQ/5VIWkwt8S
+9vNbbWT0VEV5Siai8HBxl0ErkJusMGFrQIS8jCxB668hNKAoSncN3lezZ/yDg8b5
+NUvLiLinx1rjXeal/8ruwowlr8optgkiRxduK0BZm/Xj6HXTmZwzDACM+zwt9uSV
+YW6/y0gS26oWdLJh8tRysq88xx8ylOGHEx/9/tx+DB2cJzWX23xuaoUWRjbrv/Lf
+gFlXBKHD0RmGac1iTaugAM6IwB0kjscYrHATIrkPgXaHz8PV4cKUvhbLZK7xfCfR
+X2Y+VNxTpvxIDkJ/Hn561C9t9T6gdUfTyCmL//d/Kd4gzCItBE4iouXHnVlfJtj3
+MpD3TTijAgMBAAECggEBAIbg9YAL7j1NtupUmkkWqm7oSPLqRVkvRSfBvXWplJD6
+KF1itht0lsyjqK3qJj/62HGlxj/a9o6MTIzSLiImLu/Lo9KmWYrwNUfnmqa3MArq
+yW2NxapknJUNoaRrgqTGSZUIiwvjKZcdVKdhQkH6K5+fja0FFg8yrahC+k8bsMNI
+5mw8NwRdR3SvHJWHCLfKCQ31tju7On/4C6jr0siUCc2//W+SO5c+FHDY1bma02cp
+jXTEiFpw91YcyKxiADIaH9/qfxWdefxqYg1WlUeXF3jYt5xYnYr34qKW1gOZ3jy1
+QJ3esn382ZTml3TFZWy+g9tkYyOSgmDwQZbLk/ppBAECgYEA8RzLBFwP018ieMBv
+khDtwcKk6ZihkWZxEPQPuUljWzzAHn/f3dXOcrfmflAKeoDEeYDimDYDizTLDPC4
+zmWkMJHNadcM5H065BbGVFQWXo47ltccfIlB/1vzG8aywfJ/yNfHvH87wbH2eg6N
+yOr+96ZjLJszQ+Rv189BbXDzTcMCgYEA7yEbUL/A1J0l2kLoYyS0vfVa7AyBVOFW
+vPgfkF7HdNpIiFWlukMr+DWOolaoZp5iHqQXFwJsL8qCcrbZuHbaNHAI/5vDE9xG
+fh8KzrfBrjIPIyNm6EWpsBo5unXK+wTeqIAGKdzDo5Q3zEE6G5DkkHItKA7yjPOM
+gz/b/MR3W6ECgYBBv3dA3hXWrreIs/j4nLMoxfoQVPWh34xvcg4jmXaFd6Bv8LDM
+HjRopestgIgK9bgd5d5kYT5AJIpGIhJS/fZy5B9egCzc1aVMc0Vr024yJJjtPgVf
+lFIx3xIA/gLazlS4INcveIaEABJVIEjbg/E4+N9MV5n4Jn+1GqgdvtIp3wKBgQC0
+C3lFkxrc+nVFoJrYCwsK+3E5yTCXeBKWtTsOuE307WUvQU1GsMyqVajPEfA5U4cN
+Cv9Xk7thQFh3hrTm7pXcZX5g9iYrDe8FhtncSv7I6Wf8TOtudwUMUrKkcYwi88ex
+lrMNUer7ft2ELJhTqQRuvYjCYH6/IaDqMWqxJju4AQKBgQDPjOh75ykQc93SsYpt
+Tb4gQKLeqOb57pofT8D44DccatfEgk31D4fBIIQu6XKopQmCtQyX9DUDjOWFTxuo
+IMPysN6Fh1quCbC6Xt5xfKoaJG5yQYKeKtLhknwEW9SUifU2xVrOcPikLs7Iwmmp
+BkDLsu/YKwRFSfrbYZXbTlU8tQ=3D=3D
+-----END PRIVATE KEY-----
diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index fb305d7..cfa6486 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -12,6 +12,7 @@ openssl verify -CAfile cert-ca.pem cert-server.pem
 =

 echo -e "\n*** Client Certificate ***"
 openssl genrsa -out cert-client-key.pem
+openssl pkcs8 -topk8 -nocrypt -in cert-client-key.pem -out cert-client-key=
-pkcs8.pem
 openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DB=
ar Example Organization/CN=3DBar Example Organization/emailAddress=3Dbar(a)=
mail.example' -key cert-client-key.pem -out cert-client.csr
 openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-cl=
ient.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-client.pem
 openssl verify -CAfile cert-ca.pem cert-client.pem
diff --git a/unit/test-key.c b/unit/test-key.c
index d52ae1b..df75df9 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -33,6 +33,12 @@
 #define KEY2_STR "This key is longer than 32 bytes, just to be different."
 #define KEY2_LEN (strlen(KEY2_STR))
 =

+static const char *plaintext =3D
+	"The quick brown fox jumps over the lazy dog. "	\
+	"Jackdaws love my big sphinx of quartz. "	\
+	"Pack my box with five dozen liquor jugs. "	\
+	"How razorback-jumping frogs can level six piqued gymnasts!";
+
 static void test_unsupported(const void *data)
 {
 	struct l_key *key;
@@ -375,9 +381,9 @@ static void test_trusted_keyring(const void *data)
 					&certlen);
 	assert(cert);
 =

-	cakey =3D l_key_new(L_KEY_ASYMMETRIC, cacert, cacertlen);
+	cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
 	assert(cakey);
-	key =3D l_key_new(L_KEY_ASYMMETRIC, cert, certlen);
+	key =3D l_key_new(L_KEY_RSA, cert, certlen);
 	assert(key);
 =

 	trust =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
@@ -400,6 +406,192 @@ static void test_trusted_keyring(const void *data)
 	l_free(cert);
 }
 =

+/* Reference ciphertext:
+ * $ openssl rsautl -in reference_plaintext -inkey cert-client.pem -encryp=
t \
+ * > -pkcs -out reference_ciphertext
+ * $ xxd -i reference_ciphertext
+ *
+ * where reference_plaintext is a file containing the 183 characters of
+ * plaintext[] (above).
+ */
+static uint8_t reference_ciphertext[256] =3D {
+	0x45, 0x1a, 0xa1, 0x49, 0x4f, 0x61, 0xf6, 0x96, 0x23, 0x77, 0x0c, 0x33,
+	0x56, 0x07, 0xe6, 0x0f, 0xd6, 0x7b, 0x90, 0xd0, 0x4f, 0xc7, 0x9f, 0x34,
+	0xd4, 0x99, 0x55, 0x74, 0xd9, 0x68, 0x35, 0x3f, 0xd5, 0xbd, 0x7a, 0xec,
+	0xd3, 0xd1, 0x7e, 0xe3, 0xf0, 0xd6, 0x72, 0x7f, 0xb7, 0x20, 0x10, 0x53,
+	0x1c, 0xaa, 0x2b, 0xf6, 0x82, 0x66, 0xdf, 0xfe, 0x71, 0x62, 0x4e, 0x97,
+	0xdb, 0x83, 0xff, 0xc2, 0xab, 0x79, 0x69, 0xc7, 0xde, 0x77, 0x18, 0x55,
+	0x0c, 0xea, 0x01, 0x4e, 0xeb, 0x8b, 0x13, 0xa3, 0xef, 0xc4, 0x29, 0xa6,
+	0x51, 0x16, 0x3f, 0xa5, 0xe9, 0x91, 0x91, 0x26, 0x45, 0x98, 0x1f, 0x0b,
+	0x34, 0x6e, 0x4a, 0x61, 0xc4, 0xf3, 0x85, 0x78, 0x6b, 0xdf, 0x38, 0x9b,
+	0xeb, 0x6d, 0xc2, 0xed, 0xdf, 0xa9, 0xe6, 0xbb, 0x81, 0x84, 0xd9, 0x4a,
+	0x42, 0xa6, 0x3b, 0xa9, 0x5b, 0xae, 0xee, 0xaa, 0x6a, 0x3a, 0xc0, 0xcb,
+	0x48, 0x5c, 0x61, 0xa0, 0xe2, 0x4c, 0x06, 0x15, 0x7a, 0x8e, 0xe7, 0x47,
+	0x9c, 0x03, 0x86, 0x70, 0x00, 0xa1, 0xa8, 0x68, 0x9e, 0x7e, 0xc7, 0x81,
+	0x38, 0xb3, 0x00, 0xd4, 0xa9, 0xc2, 0x56, 0xf7, 0xf4, 0x3b, 0x9b, 0xb1,
+	0x27, 0xcd, 0xed, 0x2e, 0xf3, 0xa8, 0x9b, 0x08, 0x5e, 0x8a, 0xf3, 0x29,
+	0x67, 0xa4, 0x93, 0xc5, 0x68, 0xa5, 0x26, 0x1b, 0x3b, 0x1d, 0xc7, 0x78,
+	0x32, 0xd9, 0x81, 0x65, 0x8e, 0x17, 0xb3, 0x17, 0x30, 0x12, 0xe3, 0x78,
+	0x23, 0xd9, 0x02, 0x3b, 0xf9, 0x7b, 0x8d, 0x12, 0x4c, 0xff, 0xa0, 0xd2,
+	0x0f, 0x59, 0xb9, 0x75, 0xbd, 0x7f, 0xbb, 0x13, 0x8c, 0x6f, 0xbd, 0x00,
+	0x67, 0xf3, 0xa0, 0x43, 0x05, 0x5d, 0xb7, 0x64, 0xe3, 0xae, 0x81, 0xe1,
+	0x78, 0x5e, 0x81, 0xc5, 0x20, 0xc0, 0xdb, 0xba, 0xd0, 0xbe, 0x1f, 0xc5,
+	0x6a, 0xe4, 0x31, 0x46
+};
+
+/* Reference signature:
+ * $ openssl dgst -sha256 -sign cert-client-key.pem -out reference_signatu=
re \
+ * > good_plaintext
+ * $ xxd -i reference_signature
+ *
+ * where reference_plaintext is a file containing the 183 characters of
+ * plaintext[] (above).
+ */
+
+uint8_t reference_signature[256] =3D {
+	0x39, 0xaf, 0x0d, 0x23, 0x33, 0xcc, 0x48, 0xed, 0xc3, 0x15, 0x9e, 0xb9,
+	0xd3, 0x53, 0xe0, 0x0c, 0xea, 0x45, 0x65, 0xa7, 0x82, 0x8f, 0x4b, 0xfc,
+	0x5e, 0xd3, 0xc9, 0x10, 0xf5, 0xc6, 0x56, 0x3a, 0x0e, 0x60, 0xde, 0x01,
+	0xac, 0xb6, 0xf8, 0xc7, 0xe3, 0x60, 0xd1, 0xec, 0x4f, 0x38, 0x36, 0x42,
+	0xab, 0xf5, 0x90, 0xd6, 0xd8, 0x8b, 0x8a, 0x1c, 0x1a, 0xda, 0xec, 0x10,
+	0xd2, 0xec, 0x8a, 0x77, 0x9f, 0xcf, 0x25, 0x48, 0x13, 0xdf, 0xd0, 0xb1,
+	0xaf, 0x12, 0x55, 0xa0, 0x1a, 0xda, 0x8a, 0x60, 0xbf, 0x10, 0xcf, 0x02,
+	0xae, 0x3e, 0x7c, 0x01, 0x3f, 0x9d, 0xf4, 0xfb, 0x4b, 0x2c, 0x99, 0x7d,
+	0x0e, 0x06, 0xd5, 0x1e, 0x94, 0x38, 0x08, 0x18, 0x62, 0xb1, 0x73, 0x49,
+	0xae, 0x9f, 0x0e, 0x3b, 0x40, 0x48, 0x7f, 0x73, 0x73, 0xe0, 0x5c, 0xdf,
+	0xed, 0xb0, 0xf5, 0x9a, 0xbe, 0xa0, 0xff, 0x3f, 0x70, 0xe6, 0xe4, 0xf4,
+	0x99, 0x1a, 0x79, 0x1d, 0x76, 0x38, 0x8a, 0xae, 0x04, 0xba, 0x9a, 0xf7,
+	0x5e, 0x58, 0x5f, 0x4f, 0x86, 0x4b, 0x89, 0x2f, 0x6c, 0xf7, 0xf0, 0x42,
+	0x5e, 0x2f, 0x01, 0x6f, 0xb4, 0x7e, 0x7e, 0xa8, 0xeb, 0xa4, 0x7b, 0x03,
+	0x63, 0x61, 0x26, 0x1d, 0xc1, 0xba, 0xfa, 0xf3, 0xa9, 0xa4, 0xb1, 0x7e,
+	0x0a, 0x2f, 0x22, 0x30, 0x48, 0x16, 0xfb, 0x25, 0x13, 0x67, 0x86, 0x98,
+	0x39, 0x88, 0x31, 0x78, 0xb4, 0xfb, 0xe3, 0xa0, 0x2e, 0x5c, 0x97, 0xdd,
+	0xfa, 0xe1, 0xd8, 0x3e, 0xd2, 0x9f, 0x33, 0xa4, 0x65, 0xc8, 0x34, 0xa5,
+	0xe7, 0x57, 0x9a, 0xae, 0x97, 0x93, 0x17, 0xa4, 0x72, 0x85, 0x83, 0xc9,
+	0x64, 0x62, 0x58, 0xbf, 0x3b, 0xb4, 0xb8, 0x1f, 0x5c, 0xd5, 0x9a, 0x3f,
+	0x3a, 0xf8, 0xe1, 0x2d, 0x6a, 0xf3, 0x0c, 0x20, 0x6e, 0x87, 0xa6, 0xc8,
+	0xf4, 0x8e, 0x18, 0x07
+};
+
+static void test_key_crypto(const void *data)
+{
+	uint8_t *cert;
+	size_t certlen;
+	uint8_t *pubcert;
+	size_t pubcertlen;
+	struct l_key *key;
+	struct l_key *pubkey;
+	bool is_public;
+	size_t keybits;
+	bool success;
+	uint8_t ciphertext[256];
+	uint8_t decrypted[256];
+	uint8_t msghash[32];
+	ssize_t len;
+	struct l_checksum *checksum;
+	int hash =3D L_CHECKSUM_SHA256;
+	int rsa =3D L_CIPHER_RSA_PKCS1_V1_5;
+
+	cert =3D l_pem_load_private_key(TESTDATADIR "/cert-client-key-pkcs8.pem",
+					NULL, &certlen);
+	assert(cert);
+	pubcert =3D l_pem_load_certificate(TESTDATADIR "/cert-client.pem",
+						&pubcertlen);
+	assert(pubcert);
+
+	key =3D l_key_new(L_KEY_RSA, cert, certlen);
+	assert(key);
+	pubkey =3D l_key_new(L_KEY_RSA, pubcert, pubcertlen);
+	assert(pubkey);
+
+	success =3D l_key_get_info(key, rsa, hash, &keybits, &is_public);
+	assert(success);
+	assert(keybits =3D=3D 2048);
+	assert(!is_public);
+
+	success =3D l_key_get_info(key, rsa, L_CHECKSUM_NONE, &keybits,
+					&is_public);
+	assert(success);
+	assert(keybits =3D=3D 2048);
+	assert(!is_public);
+
+	success =3D l_key_get_info(pubkey, rsa, hash, &keybits, &is_public);
+	assert(success);
+	assert(keybits =3D=3D 2048);
+	assert(is_public);
+
+	memset(ciphertext, 0, sizeof(ciphertext));
+	memset(decrypted, 0, sizeof(decrypted));
+
+	len =3D l_key_encrypt(pubkey, rsa, hash, plaintext, ciphertext,
+				strlen(plaintext), sizeof(ciphertext));
+	assert(len =3D=3D sizeof(ciphertext));
+
+	/* Can't decrypt with public key */
+	len =3D l_key_decrypt(pubkey, rsa, hash, ciphertext, decrypted,
+				sizeof(ciphertext), sizeof(decrypted));
+	assert(len < 0);
+
+	len =3D l_key_decrypt(key, rsa, hash, ciphertext, decrypted,
+				sizeof(ciphertext), sizeof(decrypted));
+	assert(len =3D=3D (ssize_t)strlen(plaintext));
+	assert(strcmp(plaintext, (char *)decrypted) =3D=3D 0);
+
+	/* Decrypt reference ciphertext */
+	memset(decrypted, 0, sizeof(decrypted));
+	len =3D l_key_decrypt(key, rsa, hash, reference_ciphertext, decrypted,
+				sizeof(reference_ciphertext),
+				sizeof(decrypted));
+	assert(len =3D=3D (ssize_t)strlen(plaintext));
+	assert(strcmp(plaintext, (char *)decrypted) =3D=3D 0);
+
+	/* Decrypt corrupted ciphertext */
+	memset(decrypted, 0, sizeof(decrypted));
+	reference_ciphertext[0] =3D reference_ciphertext[0] ^ (uint8_t)0xFF;
+	len =3D l_key_decrypt(key, rsa, hash, reference_ciphertext, decrypted,
+				sizeof(reference_ciphertext),
+				sizeof(decrypted));
+	assert(len < 0);
+
+	checksum =3D l_checksum_new(L_CHECKSUM_SHA256);
+	assert(checksum);
+	l_checksum_update(checksum, plaintext, strlen(plaintext));
+	l_checksum_get_digest(checksum, msghash, sizeof(msghash));
+	l_checksum_free(checksum);
+
+	/* Can't sign with public key */
+	len =3D l_key_sign(pubkey, rsa, hash, msghash, ciphertext,
+				sizeof(msghash), sizeof(ciphertext));
+	assert(len < 0);
+
+	len =3D l_key_sign(key, rsa, hash, msghash, ciphertext, sizeof(msghash),
+				sizeof(ciphertext));
+	assert(len =3D=3D sizeof(ciphertext));
+
+	success =3D l_key_verify(pubkey, rsa, hash, msghash, ciphertext,
+				sizeof(msghash), sizeof(ciphertext));
+	assert(success);
+
+	success =3D l_key_verify(key, rsa, hash, msghash, ciphertext,
+				sizeof(msghash), sizeof(ciphertext));
+	assert(success);
+
+	success =3D l_key_verify(pubkey, rsa, hash, msghash, reference_signature,
+				sizeof(msghash), sizeof(reference_signature));
+	assert(success);
+
+	/* Corrupt signature */
+	msghash[10] =3D msghash[10] ^ (uint8_t)0xFF;
+	success =3D l_key_verify(key, rsa, hash, msghash, ciphertext,
+				sizeof(msghash), sizeof(ciphertext));
+	assert(!success);
+
+	l_key_free(key);
+	l_key_free(pubkey);
+	l_free(cert);
+	l_free(pubcert);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -414,5 +606,7 @@ int main(int argc, char *argv[])
 	l_test_add("simple keyring", test_simple_keyring, NULL);
 	l_test_add("trusted keyring", test_trusted_keyring, NULL);
 =

+	l_test_add("key crypto", test_key_crypto, NULL);
+
 	return l_test_run();
 }
-- =

2.9.2


--===============6340464264288283854==--

