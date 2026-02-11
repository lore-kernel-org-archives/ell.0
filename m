Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98C7D25DAEA
	for <ell@lists.linux.dev>; Wed, 11 Feb 2026 16:42:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770828138; cv=none; b=s4tRKNlBMyu4JJrIovIuGUWd8zhQuTW/RrmalmMSkChOJx7JTz+SxV3pVQKJOqZcAkgMac1ljNZlpWHsk3Zsd+RZNf+VkcxeofIzV7+UCGJRjTTL/7GXS2f8BJ8NciZDZf8wOVjSR0ZQaRyGqAe2TkzGfHCR5qSI2pkEDdyC1Kk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770828138; c=relaxed/simple;
	bh=7aFG9Uypc+A7XTl4pTjS7OyckxL+PiutGDzlwyX3cCc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Ui7Q47RJWe8KuvojOpzHVvJRRLe6yp8XodOqYdHJubabpbll8ERh6Qiso8qfbIFZOW4YjuMl02RmY2eUpJJAIktLtBuIkCOeI3vuxdKEYrjnb9kbyDbzKF9I4xT+ua5yPx2i9fRqLiVpc6ydD7GEqOjeLHuZIG/UKZRkJoulL+o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 3D0BD443B0;
	Wed, 11 Feb 2026 16:42:09 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH] unit: Skip tests that rely on PKCS#8 when parser is missing
Date: Wed, 11 Feb 2026 17:41:46 +0100
Message-ID: <20260211164200.3968281-1-hadess@hadess.net>
X-Mailer: git-send-email 2.52.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvtdeftdeiucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepffetkedtjeduvdfhtdeftddvteegieeltefhtefgtdehkeevgfeuieffhfevhfefnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemlegsvdelmegtugefieemieekfhgumegttdelfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemlegsvdelmegtugefieemieekfhgumegttdelfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepfefftdeuffeggeefuedtpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth
X-GND-State: clean
X-GND-Score: 0

Check whether the kernel has the pkcs8_key_parser module loaded (whether
built-in or external), and allow tests that rely on it to fail.

This makes it possible to run the test suite successfully even on
systems where we might not be able to load modules if they're missing.
---
 unit/test-pem.c | 137 +++++++++++++++++++++++++++++++-----------------
 1 file changed, 88 insertions(+), 49 deletions(-)

diff --git a/unit/test-pem.c b/unit/test-pem.c
index 7ee0597ed172..4ff62ea06d7a 100644
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
 
+static bool pkcs8_key_parser_loaded(void)
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
@@ -384,6 +397,11 @@ static void test_load_file(const void *data)
 
 int main(int argc, char *argv[])
 {
+	int flags = 0;
+
+	if (!pkcs8_key_parser_loaded())
+		flags = L_TEST_FLAG_ALLOW_FAILURE;
+
 	l_test_init(&argc, &argv);
 
 	l_test_add("pem/invalid header/test 1", test_pem, &invalid_header1);
@@ -394,7 +412,7 @@ int main(int argc, char *argv[])
 	l_test_add("pem/empty label", test_pem, &empty_label);
 	l_test_add("pem/cert chain from data", test_chain_from_data,
 			&single_line_cert_chain);
-	l_test_add("pem/private key from data", test_priv_key_from_data, NULL);
+	l_test_add_func("pem/private key from data", test_priv_key_from_data, flags);
 
 	if (!l_checksum_is_supported(L_CHECKSUM_MD5, false) ||
 			!l_checksum_is_supported(L_CHECKSUM_SHA1, false) ||
@@ -402,74 +420,90 @@ int main(int argc, char *argv[])
 			!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		goto done;
 
-	l_test_add("pem/PKCS#1 vs. PKCS#8 unenecrypted Private Key",
-			test_unencrypted_pkey, NULL);
+	l_test_add_func("pem/PKCS#1 vs. PKCS#8 unenecrypted Private Key",
+			test_unencrypted_pkey, flags);
 
-	l_test_add("pem/v1 MD5AndDES encrypted Private Key",
+	l_test_add_data_func("pem/v1 MD5AndDES encrypted Private Key",
+			CERTDIR "cert-client-key-pkcs8-md5-des.pem",
 			test_encrypted_pkey,
-			CERTDIR "cert-client-key-pkcs8-md5-des.pem");
-	l_test_add("pem/v1 SHA1AndDES encrypted Private Key",
+			flags);
+	l_test_add_data_func("pem/v1 SHA1AndDES encrypted Private Key",
+			CERTDIR "cert-client-key-pkcs8-sha1-des.pem",
 			test_encrypted_pkey,
-			CERTDIR "cert-client-key-pkcs8-sha1-des.pem");
-	l_test_add("pem/v2 DES encrypted Private Key", test_encrypted_pkey,
-			CERTDIR "cert-client-key-pkcs8-v2-des.pem");
+			flags);
+	l_test_add_data_func("pem/v2 DES encrypted Private Key",
+			CERTDIR "cert-client-key-pkcs8-v2-des.pem",
+			test_encrypted_pkey,
+			flags);
 
 	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC) &&
 			l_checksum_is_supported(L_CHECKSUM_SHA224, false)) {
-		l_test_add("pem/v2 DES EDE3 encrypted Private Key",
-				test_encrypted_pkey, CERTDIR
-				"cert-client-key-pkcs8-v2-des-ede3.pem");
+		l_test_add_data_func("pem/v2 DES EDE3 encrypted Private Key",
+				CERTDIR "cert-client-key-pkcs8-v2-des-ede3.pem",
+				test_encrypted_pkey,
+				flags);
 	}
 
 	if (l_cipher_is_supported(L_CIPHER_AES)) {
 		if (l_checksum_is_supported(L_CHECKSUM_SHA256, false))
-			l_test_add("pem/v2 AES128-encrypted Private Key",
+			l_test_add_data_func("pem/v2 AES128-encrypted Private Key",
+				CERTDIR "cert-client-key-pkcs8-v2-aes128.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs8-v2-aes128.pem");
+				flags);
 
 		if (l_checksum_is_supported(L_CHECKSUM_SHA512, false))
-			l_test_add("pem/v2 AES256-encrypted Private Key",
+			l_test_add_data_func("pem/v2 AES256-encrypted Private Key",
+				CERTDIR "cert-client-key-pkcs8-v2-aes256.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs8-v2-aes256.pem");
+				flags);
 	}
 
-	l_test_add("pem/PKCS#1 DES-encrypted RSA Private Key",
+	l_test_add_data_func("pem/PKCS#1 DES-encrypted RSA Private Key",
+			CERTDIR "cert-client-key-pkcs1-des.pem",
 			test_encrypted_pkey,
-			CERTDIR "cert-client-key-pkcs1-des.pem");
+			flags);
 
 	if (l_cipher_is_supported(L_CIPHER_DES3_EDE_CBC))
-		l_test_add("pem/PKCS#1 DES-EDE3-encrypted RSA Private Key",
+		l_test_add_data_func("pem/PKCS#1 DES-EDE3-encrypted RSA Private Key",
+				CERTDIR "cert-client-key-pkcs1-des3.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs1-des3.pem");
+				flags);
 
 	if (l_cipher_is_supported(L_CIPHER_AES_CBC)) {
-		l_test_add("pem/PKCS#1 AES128-encrypted RSA Private Key",
+		l_test_add_data_func("pem/PKCS#1 AES128-encrypted RSA Private Key",
+				CERTDIR "cert-client-key-pkcs1-aes128.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs1-aes128.pem");
-		l_test_add("pem/PKCS#1 AES192-encrypted RSA Private Key",
+				flags);
+		l_test_add_data_func("pem/PKCS#1 AES192-encrypted RSA Private Key",
+				CERTDIR "cert-client-key-pkcs1-aes192.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs1-aes192.pem");
-		l_test_add("pem/PKCS#1 AES256-encrypted RSA Private Key",
+				flags);
+		l_test_add_data_func("pem/PKCS#1 AES256-encrypted RSA Private Key",
+				CERTDIR "cert-client-key-pkcs1-aes256.pem",
 				test_encrypted_pkey,
-				CERTDIR "cert-client-key-pkcs1-aes256.pem");
+				flags);
 	}
 
-	l_test_add("detect-format/PEM PKCS#1 unencrypted private key",
-			test_load_file,
+	l_test_add_data_func("detect-format/PEM PKCS#1 unencrypted private key",
 			TEST_LOAD_PARAMS("cert-client-key-pkcs1.pem",
-						false, false, true, false));
-	l_test_add("detect-format/PEM PKCS#1 encrypted private key",
+						false, false, true, false),
 			test_load_file,
+			flags);
+	l_test_add_data_func("detect-format/PEM PKCS#1 encrypted private key",
 			TEST_LOAD_PARAMS("cert-client-key-pkcs1-des.pem",
-						false, false, true, true));
-	l_test_add("detect-format/PEM PKCS#8 unencrypted private key",
+						false, false, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("detect-format/PEM PKCS#8 unencrypted private key",
 			TEST_LOAD_PARAMS("cert-client-key-pkcs8.pem",
-						false, false, true, false));
-	l_test_add("detect-format/PEM PKCS#8 encrypted private key",
+						false, false, true, false),
 			test_load_file,
+			flags);
+	l_test_add_data_func("detect-format/PEM PKCS#8 encrypted private key",
 			TEST_LOAD_PARAMS("cert-client-key-pkcs8-sha1-des.pem",
-						false, false, true, true));
+						false, false, true, true),
+			test_load_file,
+			flags);
 	l_test_add("detect-format/PEM X.509 certificate",
 			test_load_file,
 			TEST_LOAD_PARAMS("cert-client.pem",
@@ -478,31 +512,36 @@ int main(int argc, char *argv[])
 			test_load_file,
 			TEST_LOAD_PARAMS("cert-client.crt",
 						true, false, false, false));
-	l_test_add("detect-format/PEM combined",
-			test_load_file,
+	l_test_add_data_func("detect-format/PEM combined",
 			TEST_LOAD_PARAMS("cert-entity-combined.pem",
-						true, true, true, true));
-	l_test_add("detect-format/DER PKCS#12 combined",
+						true, true, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("detect-format/DER PKCS#12 combined",
 			TEST_LOAD_PARAMS("cert-entity-pkcs12-nomac.p12",
-						true, false, true, true));
-
-	l_test_add("pkcs#12/Combined RC2-based ciphers + SHA1",
+						true, false, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("pkcs#12/Combined RC2-based ciphers + SHA1",
 			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc2-sha1.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined DES-based ciphers + SHA256",
+						true, true, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("pkcs#12/Combined DES-based ciphers + SHA256",
 			TEST_LOAD_PARAMS("cert-entity-pkcs12-des-sha256.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined RC4-based ciphers + SHA384",
+						true, true, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("pkcs#12/Combined RC4-based ciphers + SHA384",
 			TEST_LOAD_PARAMS("cert-entity-pkcs12-rc4-sha384.p12",
-						true, true, true, true));
-	l_test_add("pkcs#12/Combined PKCS#5 ciphers + SHA512",
+						true, true, true, true),
 			test_load_file,
+			flags);
+	l_test_add_data_func("pkcs#12/Combined PKCS#5 ciphers + SHA512",
 			TEST_LOAD_PARAMS("cert-entity-pkcs12-pkcs5-sha512.p12",
-						true, true, true, true));
+						true, true, true, true),
+			test_load_file,
+			flags);
 
 done:
 	return l_test_run();
-- 
2.52.0

