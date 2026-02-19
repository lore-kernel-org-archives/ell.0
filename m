Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CAFF33A70A
	for <ell@lists.linux.dev>; Thu, 19 Feb 2026 13:27:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771507656; cv=none; b=acRyvbHyS8PZEYs6xVCFHeG3o3aAyWSRHwH0mbfc7njtjrqOmS7zPtjYHPvLckcydlSBo5u4VpKztC7D4r3oSBIikgg0hgeSQx5zO11yrPCl79Bfz11do9eoo+v8F6KdYu9mQVMu5tbSTLNSJ1Zj9T1qPsnBfyrDl2kPteIPQRA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771507656; c=relaxed/simple;
	bh=0T7FwouJyxDrDIuAg8XF6012b+fsOevhFEm7jVnOPgs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qVqjd92Bdaz4Cb0I4W1Ugji5HN3ZAVdeiAdsSgzxeGpG8BHQMn+WSQ5bSwLC1v3FLcyar/vZOuIwfsRQOGmGPBAzhn2zNhSGwLOB7ZkuhgKClt6Csosr+iRLfDzoTxEd+0hhoNnH4ADo+q3u7I/S9mf6ElI3+eE3D0kR3376P/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 683D544352;
	Thu, 19 Feb 2026 13:27:32 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v3] unit: Skip tests that rely on PKCS#8 when parser is missing
Date: Thu, 19 Feb 2026 14:23:54 +0100
Message-ID: <20260219132723.2266067-1-hadess@hadess.net>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvvdehieehucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepffetkedtjeduvdfhtdeftddvteegieeltefhtefgtdehkeevgfeuieffhfevhfefnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepieekfeffheeggeefhedvpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth
X-GND-State: clean
X-GND-Score: 0

Add pre-check to tests that need the pkcs8_key_parser module loaded
(whether built-in or external), and allow tests that rely on it to fail.

This makes it possible to run the test suite successfully even on
systems where we might not be able to load modules if they're missing
such as CIs, or other systems where we lack permissions.

The test definitions were further simplified by using macros to avoid
repeated test definition arguments, including the PKCS#8 precheck.

---
Changes since v2:
- Use macros for the encrypted pkey and load_file tests

Changes since v1:
- Use precheck test mechanism instead of flags


 unit/test-pem.c | 124 ++++++++++++++++++++++--------------------------
 1 file changed, 58 insertions(+), 66 deletions(-)

diff --git a/unit/test-pem.c b/unit/test-pem.c
index 7ee0597ed172..75d606ee971d 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -10,6 +10,7 @@
 #endif
 
 #include <assert.h>
+#include <sys/stat.h>
 
 #include <ell/ell.h>
 
@@ -136,6 +137,18 @@ static const struct pem_from_data_test single_line_cert_chain = {
 		"-----END CERTIFICATE-----\n",
 };
 
+static bool pkcs8_key_parser_precheck(const void *data)
+{
+	struct stat s;
+
+	/* Despite the path, this directory exists whether the module
+	 * is external or built-in. */
+	if (stat ("/sys/module/pkcs8_key_parser", &s) != 0)
+		return false;
+
+	return S_ISDIR (s.st_mode);
+}
+
 static void destroy_cert(void *cert)
 {
 	l_cert_free(cert);
@@ -342,6 +355,10 @@ struct test_load_file_params {
 	(&(struct test_load_file_params) {				\
 		CERTDIR fn, (cert), (certchain), (privkey), (encrypted) })
 
+#define add_encrypted_pkey_test(name, fn)				\
+	l_test_add_data_func_precheck(name, fn, test_encrypted_pkey,	\
+		pkcs8_key_parser_precheck, 0)
+
 static void test_load_file(const void *data)
 {
 	const struct test_load_file_params *params = data;
@@ -382,6 +399,11 @@ static void test_load_file(const void *data)
 		l_key_free(privkey);
 }
 
+#define add_file_test(name, fn, cert, certchain, privkey, encrypted)	\
+	l_test_add_data_func_precheck(name, TEST_LOAD_PARAMS(fn, cert,	\
+		certchain, privkey, encrypted),				\
+		test_load_file, pkcs8_key_parser_precheck, 0)
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -394,7 +416,8 @@ int main(int argc, char *argv[])
 	l_test_add("pem/empty label", test_pem, &empty_label);
 	l_test_add("pem/cert chain from data", test_chain_from_data,
 			&single_line_cert_chain);
-	l_test_add("pem/private key from data", test_priv_key_from_data, NULL);
+	l_test_add_func_precheck("pem/private key from data",
+			test_priv_key_from_data, pkcs8_key_parser_precheck, 0);
 
 	if (!l_checksum_is_supported(L_CHECKSUM_MD5, false) ||
 			!l_checksum_is_supported(L_CHECKSUM_SHA1, false) ||
@@ -402,74 +425,56 @@ int main(int argc, char *argv[])
 			!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		goto done;
 
-	l_test_add("pem/PKCS#1 vs. PKCS#8 unenecrypted Private Key",
-			test_unencrypted_pkey, NULL);
+	l_test_add_func_precheck("pem/PKCS#1 vs. PKCS#8 unenecrypted Private Key",
+			test_unencrypted_pkey, pkcs8_key_parser_precheck, 0);
 
-	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
-			test_encrypted_pkey,
+	add_encrypted_pkey_test("pem/v1 MD5AndDES encrypted Private Key",
 			CERTDIR "cert-client-key-pkcs8-md5-des.pem");
-	l_test_add("pem/v1 SHA1AndDES encrypted Private Key",
-			test_encrypted_pkey,
+	add_encrypted_pkey_test("pem/v1 SHA1AndDES encrypted Private Key",
 			CERTDIR "cert-client-key-pkcs8-sha1-des.pem");
-	l_test_add("pem/v2 DES encrypted Private Key", test_encrypted_pkey,
+	add_encrypted_pkey_test("pem/v2 DES encrypted Private Key",
 			CERTDIR "cert-client-key-pkcs8-v2-des.pem");
 
 	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC) &&
 			l_checksum_is_supported(L_CHECKSUM_SHA224, false)) {
-		l_test_add("pem/v2 DES EDE3 encrypted Private Key",
-				test_encrypted_pkey, CERTDIR
-				"cert-client-key-pkcs8-v2-des-ede3.pem");
+		add_encrypted_pkey_test("pem/v2 DES EDE3 encrypted Private Key",
+				CERTDIR "cert-client-key-pkcs8-v2-des-ede3.pem");
 	}
 
 	if (l_cipher_is_supported(L_CIPHER_AES)) {
 		if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
-			l_test_add("pem/v2 AES128-encrypted Private Key",
-				test_encrypted_pkey,
+			add_encrypted_pkey_test("pem/v2 AES128-encrypted Private Key",
 				CERTDIR "cert-client-key-pkcs8-v2-aes128.pem");
 
 		if (l_checksum_is_supported(L_CHECKSUM_SHA512, false))
-			l_test_add("pem/v2 AES256-encrypted Private Key",
-				test_encrypted_pkey,
+			add_encrypted_pkey_test("pem/v2 AES256-encrypted Private Key",
 				CERTDIR "cert-client-key-pkcs8-v2-aes256.pem");
 	}
 
-	l_test_add("pem/PKCS#1 DES-encrypted RSA Private Key",
-			test_encrypted_pkey,
+	add_encrypted_pkey_test("pem/PKCS#1 DES-encrypted RSA Private Key",
 			CERTDIR "cert-client-key-pkcs1-des.pem");
 
 	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC))
-		l_test_add("pem/PKCS#1 DES-EDE3-encrypted RSA Private Key",
-				test_encrypted_pkey,
+		add_encrypted_pkey_test("pem/PKCS#1 DES-EDE3-encrypted RSA Private Key",
 				CERTDIR "cert-client-key-pkcs1-des3.pem");
 
 	if (l_cipher_is_supported(L_CIPHER_AES_CBC)) {
-		l_test_add("pem/PKCS#1 AES128-encrypted RSA Private Key",
-				test_encrypted_pkey,
+		add_encrypted_pkey_test("pem/PKCS#1 AES128-encrypted RSA Private Key",
 				CERTDIR "cert-client-key-pkcs1-aes128.pem");
-		l_test_add("pem/PKCS#1 AES192-encrypted RSA Private Key",
-				test_encrypted_pkey,
+		add_encrypted_pkey_test("pem/PKCS#1 AES192-encrypted RSA Private Key",
 				CERTDIR "cert-client-key-pkcs1-aes192.pem");
-		l_test_add("pem/PKCS#1 AES256-encrypted RSA Private Key",
-				test_encrypted_pkey,
+		add_encrypted_pkey_test("pem/PKCS#1 AES256-encrypted RSA Private Key",
 				CERTDIR "cert-client-key-pkcs1-aes256.pem");
 	}
 
-	l_test_add("detect-format/PEM PKCS#1 unencrypted private key",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-client-key-pkcs1.pem",
-						false, false, true, false));
-	l_test_add("detect-format/PEM PKCS#1 encrypted private key",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-client-key-pkcs1-des.pem",
-						false, false, true, true));
-	l_test_add("detect-format/PEM PKCS#8 unencrypted private key",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-client-key-pkcs8.pem",
-						false, false, true, false));
-	l_test_add("detect-format/PEM PKCS#8 encrypted private key",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-client-key-pkcs8-sha1-des.pem",
-						false, false, true, true));
+	add_file_test("detect-format/PEM PKCS#1 unencrypted private key",
+			"cert-client-key-pkcs1.pem", false, false, true, false);
+	add_file_test("detect-format/PEM PKCS#1 encrypted private key",
+			"cert-client-key-pkcs1-des.pem", false, false, true, true);
+	add_file_test("detect-format/PEM PKCS#8 unencrypted private key",
+			"cert-client-key-pkcs8.pem", false, false, true, false);
+	add_file_test("detect-format/PEM PKCS#8 encrypted private key",
+			"cert-client-key-pkcs8-sha1-des.pem", false, false, true, true);
 	l_test_add("detect-format/PEM X.509 certificate",
 			test_load_file,
 			TEST_LOAD_PARAMS("cert-client.pem",
@@ -478,31 +483,18 @@ int main(int argc, char *argv[])
 			test_load_file,
 			TEST_LOAD_PARAMS("cert-client.crt",
 						true, false, false, false));
-	l_test_add("detect-format/PEM combined",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-combined.pem",
-						true, true, true, true));
-	l_test_add("detect-format/DER PKCS#12 combined",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-pkcs12-nomac.p12",
-						true, false, true, true));
-
-	l_test_add("pkcs#12/Combined RC2-based ciphers + SHA1",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc2-sha1.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined DES-based ciphers + SHA256",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-pkcs12-des-sha256.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined RC4-based ciphers + SHA384",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc4-sha384.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined PKCS#5 ciphers + SHA512",
-			test_load_file,
-			TEST_LOAD_PARAMS("cert-entity-pkcs12-pkcs5-sha512.p12",
-						true, true, true, true));
+	add_file_test("detect-format/PEM combined",
+			"cert-entity-combined.pem", true, true, true, true);
+	add_file_test("detect-format/DER PKCS#12 combined",
+			"cert-entity-pkcs12-nomac.p12", true, false, true, true);
+	add_file_test("pkcs#12/Combined RC2-based ciphers + SHA1",
+			"cert-entity-pkcs12-rc2-sha1.p12", true, true, true, true);
+	add_file_test("pkcs#12/Combined DES-based ciphers + SHA256",
+			"cert-entity-pkcs12-des-sha256.p12", true, true, true, true);
+	add_file_test("pkcs#12/Combined RC4-based ciphers + SHA384",
+			"cert-entity-pkcs12-rc4-sha384.p12", true, true, true, true);
+	add_file_test("pkcs#12/Combined PKCS#5 ciphers + SHA512",
+			"cert-entity-pkcs12-pkcs5-sha512.p12", true, true, true, true);
 
 done:
 	return l_test_run();
-- 
2.53.0

