Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5565918E750
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971727; cv=none; b=uaN48brARqQHsS5ZLrxUPRa4vCm/ctMv8xCrU9wskI/rXXVe6K763CXu2QFL5L+NQcUdWAoBGGj/FriCpra9GgwhmV8KR6iz607b7TqRKrE6sOpCDoSfCm35qwo1uyEfD8AhkHbZMATZulMxRdMB3vVtREuxHIPZxqC5DgFVap0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971727; c=relaxed/simple;
	bh=BJD8BA9bS+wxVU0T8S+hJcAa/8v728wKAciNwy0gIrg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EbvB6cYaLuOZHw2DEUy8BasWy4F7D74turCiZ+lYI6FqQhjhGrNH07h3ei0pu3U6pIOUcBuxYOaEN0+kS+5uoF/QJXSzMxrgcOX13ZiX4CQn1KRp7Ad3Oi1WTPbdJNw0h6nLuF6oQulyuhRUkDZrgO1at8NttqJtppT7SIZ2nuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 9704B444D0;
	Thu, 31 Jul 2025 14:22:03 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 5/5] unit: Fix maxkeys test output
Date: Thu, 31 Jul 2025 16:20:39 +0200
Message-ID: <20250731142153.2802258-6-hadess@hadess.net>
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

The output from our "maxkeys" check was made before running the tests,
which meant that the output didn't conform to the TAP specification.

Move the check to a test, it should provide the same information to test
runners.
---
 unit/test-tls.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 540416974751..1f7961dc21e6 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -700,6 +700,18 @@ static void test_tls_test(const void *data)
 	test_tls_with_ver(test, L_TLS_V10, 0);
 }
 
+static void test_max_keys(const void *data)
+{
+	uint32_t maxkeys;
+	int r;
+
+	r = l_sysctl_get_u32(&maxkeys, "/proc/sys/kernel/keys/%s",
+				getuid() > 0 ? "maxkeys" : "root_maxkeys");
+	if (!r && maxkeys < 2000)
+		l_info("# Running sysctl kernel.keys.%s=2000 is recommended",
+			getuid() > 0 ? "maxkeys" : "root_maxkeys");
+}
+
 static void test_tls_version_mismatch_test(const void *data)
 {
 	test_tls_with_ver(&tls_conn_test_version_mismatch,
@@ -929,8 +941,6 @@ static void test_tls_suite_test(const void *data)
 int main(int argc, char *argv[])
 {
 	unsigned int i;
-	uint32_t maxkeys;
-	int r;
 
 	l_test_init(&argc, &argv);
 
@@ -979,12 +989,8 @@ int main(int argc, char *argv[])
 		goto done;
 	}
 
-	r = l_sysctl_get_u32(&maxkeys, "/proc/sys/kernel/keys/%s",
-				getuid() > 0 ? "maxkeys" : "root_maxkeys");
-	if (!r && maxkeys < 2000)
-		printf("Running sysctl kernel.keys.%s=2000 is recommended\n",
-			getuid() > 0 ? "maxkeys" : "root_maxkeys");
-
+	l_test_add_func("Test maxkeys",
+			test_max_keys, 0);
 	l_test_add_data_func("TLS connection no auth",
 			&tls_conn_test_no_auth, test_tls_test,
 			L_TEST_FLAG_ALLOW_FAILURE);
-- 
2.50.0

