Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48B213E6DCF
	for <ell@lists.linux.dev>; Tue, 17 Mar 2026 14:30:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757836; cv=none; b=IX11dpJQat2tpk64f5PaSNyIZQpi1VqsoyO/0sxTaSkYENVKBRMKdzA5w52MLNY4Ji0Xxc2IjLCrsnLe74cxe+ll9EoH+QgngXSvHb9AEJAYss8tIEiJaditZNl0cw7cD3phMR0X8v4G1k7s2C3JFEnAzppFIzxGgN5llwX9ACQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757836; c=relaxed/simple;
	bh=N6YAHYIaHerSsMuy8YxIkY5CMG5WxvOykv4EDpLXVSQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kARH1GCB+EVY78dId6HYFP9bynXBnyqHlwNnTwM0ctoiMdmWjeKVDihHBwqEbexBwhYqDiPupPRzaV4av5DhF4i860BdUJe6YEFHv0uw8HnAgdWB37nGRbWmf0BazIYi1wnPUKJWDibk4+UIAMDS9itNKpfTEvJLFjJ79p9PWCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id E0B0A3EE1A;
	Tue, 17 Mar 2026 14:30:27 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 4/4] unit: Skip hwdb test when hwdb isn't available
Date: Tue, 17 Mar 2026 15:28:57 +0100
Message-ID: <20260317143018.628844-5-hadess@hadess.net>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260317143018.628844-1-hadess@hadess.net>
References: <20260317143018.628844-1-hadess@hadess.net>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-Sasl: hadess@hadess.net
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftddugeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveethfelveejffetkeelheehueejlefhvdehteehgfeghfekgfdvfefhgeekieetnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpqhhiugepgfdtuedtteefgffgudetpdhmohguvgepshhmthhpohhuthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth

Alpine includes a compatible libudev without implementing hwdb, so skip
the test on that platform.
---
 unit/test-hwdb.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/unit/test-hwdb.c b/unit/test-hwdb.c
index 1c4928f3f993..f45f3973d2b9 100644
--- a/unit/test-hwdb.c
+++ b/unit/test-hwdb.c
@@ -14,6 +14,8 @@
 
 #include <ell/ell.h>
 
+static struct l_hwdb *hwdb = NULL;
+
 struct hwdb_stats {
 	int aliases;
 	int entries;
@@ -56,11 +58,9 @@ static void check_entry(const char *modalias, struct l_hwdb_entry *entries,
 
 static void test_hwdb(const void *data)
 {
-	struct l_hwdb *hwdb;
 	struct hwdb_stats stats = { 0 };
 	bool result;
 
-	hwdb = l_hwdb_new_default();
 	assert(hwdb);
 
 	result = l_hwdb_foreach(hwdb, check_entry, &stats);
@@ -84,11 +84,18 @@ static void test_hwdb(const void *data)
 	l_hwdb_unref(hwdb);
 }
 
+static bool test_hwdb_precheck (const void *data)
+{
+	hwdb = l_hwdb_new_default();
+	return hwdb != NULL;
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 
-	l_test_add("hwdb", test_hwdb, NULL);
+	l_test_add_func_precheck("hwdb",
+				test_hwdb, test_hwdb_precheck, 0);
 
 	return l_test_run();
 }
-- 
2.53.0

