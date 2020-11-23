Content-Type: multipart/mixed; boundary="===============3057390887633035666=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] unit: Test loading PKCS#1 PEM private key files
Date: Mon, 23 Nov 2020 12:54:17 +0100
Message-ID: <20201123115417.218473-5-andrew.zaborowski@intel.com>
In-Reply-To: <20201123115417.218473-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3057390887633035666==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 Makefile.am     | 20 ++++++++++++++
 unit/test-pem.c | 70 ++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 546a6aa..28082aa 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -214,6 +214,11 @@ cert_files =3D unit/cert-chain.pem \
 			unit/cert-server-key-pkcs8.pem \
 			unit/cert-client.pem \
 			unit/cert-client-key-pkcs1.pem \
+			unit/cert-client-key-pkcs1-des.pem \
+			unit/cert-client-key-pkcs1-des3.pem \
+			unit/cert-client-key-pkcs1-aes128.pem \
+			unit/cert-client-key-pkcs1-aes192.pem \
+			unit/cert-client-key-pkcs1-aes256.pem \
 			unit/cert-client-key-pkcs8.pem \
 			unit/cert-client-key-pkcs8-md5-des.pem \
 			unit/cert-client-key-pkcs8-sha1-des.pem \
@@ -420,6 +425,21 @@ unit/cert-server: unit/cert-server.pem unit/cert-ca.pem
 unit/cert-client-key-pkcs1.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 =

+unit/cert-client-key-pkcs1-des.pem: unit/cert-client-key-pkcs1.pem
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -des -passout pass:abc
+
+unit/cert-client-key-pkcs1-des3.pem: unit/cert-client-key-pkcs1.pem
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -des3 -passout pass:abc
+
+unit/cert-client-key-pkcs1-aes128.pem: unit/cert-client-key-pkcs1.pem
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -aes128 -passout pass:abc
+
+unit/cert-client-key-pkcs1-aes192.pem: unit/cert-client-key-pkcs1.pem
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -aes192 -passout pass:abc
+
+unit/cert-client-key-pkcs1-aes256.pem: unit/cert-client-key-pkcs1.pem
+	$(AM_V_GEN)openssl rsa -in $< -out $@ -aes256 -passout pass:abc
+
 unit/cert-client-key-pkcs8.pem: unit/cert-client-key-pkcs1.pem
 	$(AM_V_GEN)openssl pkcs8 -topk8 -nocrypt -in $< -out $@
 =

diff --git a/unit/test-pem.c b/unit/test-pem.c
index e81ddde..f875adc 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -257,6 +257,39 @@ static void test_pem(const void *data)
 	l_free(decoded);
 }
 =

+static void test_unencrypted_pkey(const void *data)
+{
+	const char *pkcs1_pem =3D CERTDIR "cert-client-key-pkcs1.pem";
+	const char *pkcs8_pem =3D CERTDIR "cert-client-key-pkcs8.pem";
+	bool is_encrypted;
+	size_t size;
+	uint8_t encrypted1[256], encrypted2[256], plaintext[256];
+	struct l_key *pkey1, *pkey2;
+	bool is_public;
+
+	pkey1 =3D l_pem_load_private_key(pkcs1_pem, NULL, &is_encrypted);
+	assert(pkey1);
+	assert(!is_encrypted);
+
+	pkey2 =3D l_pem_load_private_key(pkcs8_pem, NULL, &is_encrypted);
+	assert(pkey2);
+	assert(!is_encrypted);
+
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
+}
+
 static void test_encrypted_pkey(const void *data)
 {
 	const char *encrypted_pem =3D data;
@@ -324,6 +357,9 @@ int main(int argc, char *argv[])
 			!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		goto done;
 =

+	l_test_add("pem/PKCS#1 vs. PKCS#8 unenecrypted Private Key",
+			test_unencrypted_pkey, NULL);
+
 	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
 			test_encrypted_pkey,
 			CERTDIR "cert-client-key-pkcs8-md5-des.pem");
@@ -340,18 +376,38 @@ int main(int argc, char *argv[])
 				"cert-client-key-pkcs8-v2-des-ede3.pem");
 	}
 =

-	if (!l_cipher_is_supported(L_CIPHER_AES))
-		goto done;
-
-	if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
-		l_test_add("pem/v2 AES128 encrypted Private Key",
+	if (l_cipher_is_supported(L_CIPHER_AES)) {
+		if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
+			l_test_add("pem/v2 AES128-encrypted Private Key",
 				test_encrypted_pkey,
 				CERTDIR "cert-client-key-pkcs8-v2-aes128.pem");
 =

-	if (l_checksum_is_supported(L_CHECKSUM_SHA512, false))
-		l_test_add("pem/v2 AES256 encrypted Private Key",
+		if (l_checksum_is_supported(L_CHECKSUM_SHA512, false))
+			l_test_add("pem/v2 AES256-encrypted Private Key",
 				test_encrypted_pkey,
 				CERTDIR "cert-client-key-pkcs8-v2-aes256.pem");
+	}
+
+	l_test_add("pem/PKCS#1 DES-encrypted RSA Private Key",
+			test_encrypted_pkey,
+			CERTDIR "cert-client-key-pkcs1-des.pem");
+
+	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC))
+		l_test_add("pem/PKCS#1 DES-EDE3-encrypted RSA Private Key",
+				test_encrypted_pkey,
+				CERTDIR "cert-client-key-pkcs1-des3.pem");
+
+	if (l_cipher_is_supported(L_CIPHER_AES_CBC)) {
+		l_test_add("pem/PKCS#1 AES128-encrypted RSA Private Key",
+				test_encrypted_pkey,
+				CERTDIR "cert-client-key-pkcs1-aes128.pem");
+		l_test_add("pem/PKCS#1 AES192-encrypted RSA Private Key",
+				test_encrypted_pkey,
+				CERTDIR "cert-client-key-pkcs1-aes192.pem");
+		l_test_add("pem/PKCS#1 AES256-encrypted RSA Private Key",
+				test_encrypted_pkey,
+				CERTDIR "cert-client-key-pkcs1-aes256.pem");
+	}
 =

 done:
 	return l_test_run();
-- =

2.27.0

--===============3057390887633035666==--

