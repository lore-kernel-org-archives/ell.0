Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B9E918DB03
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971726; cv=none; b=IoLHJxePOxmV8jOoB3/p+n3KhDw8Nf3ZbSlP+/ClALRvtXubIhyLY7uJDtkRyMtftjTeN8LKAsYu2x+VH1U3YDd+HKtkDyb9TahbhU8dedfRVRWoj6RcylRGevjb/cHSQ1P1472BOodxDNaKUE/r2diVsxL4V/DSqbbGKl0hifc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971726; c=relaxed/simple;
	bh=8s8bb6AFDOxM0kWVR6tqgyNMWXKvPyZgBorl2C2zbQ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fNSJByEoxUyIhzyegYGRrALrkhnwZpT2i550jGq98A9glulCYJaCQFgK5NXXG0ZbndfzEuZtJR0rmPUhTU5xecAnZ/1PTkB5gWRRAxy2kpxtIWITYDXx7LC0/wmlcMxR77RNFnhFanFst5wB7qJMC4xrh0l7yB9wPW7O20eQUrA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 4B104444CE;
	Thu, 31 Jul 2025 14:22:03 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 4/5] unit: Respect TAP comments format
Date: Thu, 31 Jul 2025 16:20:38 +0200
Message-ID: <20250731142153.2802258-5-hadess@hadess.net>
X-Mailer: git-send-email 2.50.0
In-Reply-To: <20250731142153.2802258-1-hadess@hadess.net>
References: <20250731142153.2802258-1-hadess@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddutddutdefucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveethfelveejffetkeelheehueejlefhvdehteehgfeghfekgfdvfefhgeekieetnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth
X-GND-Sasl: hadess@hadess.net

Comment lines must start with '#'.
---
 unit/test-cipher.c |  8 ++++----
 unit/test-key.c    | 10 +++++-----
 unit/test-pem.c    | 10 +++++-----
 unit/test-tls.c    | 12 ++++++------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/unit/test-cipher.c b/unit/test-cipher.c
index 23bc748f7f4e..1abe9cff593f 100644
--- a/unit/test-cipher.c
+++ b/unit/test-cipher.c
@@ -543,10 +543,10 @@ static void test_aead(const void *data)
 	success = l_aead_cipher_encrypt(cipher, pt, ptlen, aad, aadlen,
 					nonce, noncelen, encbuf, encbuflen);
 	if (!success) {
-		printf("* Some kernel versions before v4.9 have a known AEAD\n"
-			"* bug. If the system running this test is using a\n"
-			"* v4.8 or earlier kernel, a failure here is likely\n"
-			"* due to that kernel bug.\n");
+		printf("# Some kernel versions before v4.9 have a known AEAD\n"
+			"# bug. If the system running this test is using a\n"
+			"# v4.8 or earlier kernel, a failure here is likely\n"
+			"# due to that kernel bug.\n");
 	}
 	assert(success);
 
diff --git a/unit/test-key.c b/unit/test-key.c
index cd5c28a2e5db..c9eb8507da81 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -555,11 +555,11 @@ static void test_key_crypto(const void *data)
 	privkey = l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pem",
 						NULL, NULL);
 	if (!privkey) {
-		l_info("* Some kernel versions do not automatically load\n"
-			"* the pkcs8_key_parser module. If the system running\n"
-			"* test has not loaded this module, a failure here is\n"
-			"* likely. Running \"modprobe pkcs8_key_parser\" may\n"
-			"* correct this issue.\n");
+		l_info("# Some kernel versions do not automatically load\n"
+			"# the pkcs8_key_parser module. If the system running\n"
+			"# test has not loaded this module, a failure here is\n"
+			"# likely. Running \"modprobe pkcs8_key_parser\" may\n"
+			"# correct this issue.\n");
 		exit(1);
 	}
 
diff --git a/unit/test-pem.c b/unit/test-pem.c
index 7580b6ae59c3..7ee0597ed172 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -202,11 +202,11 @@ static void test_priv_key_from_data(const void *data)
 						strlen(raw_private_key),
 						"abc", &is_encrypted);
 	if (!key) {
-		l_info("* Some kernel versions do not automatically load\n"
-			"* the pkcs8_key_parser module. If the system running\n"
-			"* test has not loaded this module, a failure here is\n"
-			"* likely. Running \"modprobe pkcs8_key_parser\" may\n"
-			"* correct this issue.\n");
+		l_info("# Some kernel versions do not automatically load\n"
+			"# the pkcs8_key_parser module. If the system running\n"
+			"# test has not loaded this module, a failure here is\n"
+			"# likely. Running \"modprobe pkcs8_key_parser\" may\n"
+			"# correct this issue.\n");
 		exit(1);
 	}
 
diff --git a/unit/test-tls.c b/unit/test-tls.c
index a95de3b314f4..540416974751 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -613,12 +613,12 @@ static void test_tls_with_ver(const struct tls_conn_test *test,
 						test->server_key_passphrase,
 						NULL);
 		if (!server_key) {
-			l_info("* Some kernel versions do not automatically\n"
-				"* load the pkcs8_key_parser module. If the\n"
-				"* system running test has not loaded this\n"
-				"* module, a failure here is likely. Running\n"
-				"* \"modprobe pkcs8_key_parser\" may correct\n"
-				"* this issue.\n");
+			l_info("# Some kernel versions do not automatically\n"
+				"# load the pkcs8_key_parser module. If the\n"
+				"# system running test has not loaded this\n"
+				"# module, a failure here is likely. Running\n"
+				"# \"modprobe pkcs8_key_parser\" may correct\n"
+				"# this issue.\n");
 			exit(1);
 		}
 
-- 
2.50.0

