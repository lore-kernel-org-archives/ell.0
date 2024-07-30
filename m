Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 563A7188013
	for <ell@lists.linux.dev>; Tue, 30 Jul 2024 16:51:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722358305; cv=none; b=swPnlZLTgkBAJHeoNmFa0uugTiREX2H97QzPgjnHanhcutiOYQxl9wrFQNdqP0vrGedvIpQH9OTWWy7IPz+qrzP3iPt6Pr8zhGD0dkI7e+RDhE8OCUy51AGP93miupjRiF5lV8BI8kfnyKU4+9H54ggrP9ptRz3yRhKOzwMIUBs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722358305; c=relaxed/simple;
	bh=84QfyRT1Q24LHaogorgyBxwiBcxHYNd8d35v3AabQ3U=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=iINQoYyLRdgBD6Kh6NyWZjXOOiqP6WdKNvFGj69oDip4A6/PlXAeUQv5WkeGU/AhmGCGJ/KEc3Qh/C0hT+0mlop29SkXTaTvE8BNthqXqheulU31069begswUyo30QcGTnt9akki1k20fhLbqTVCO6r9vjWUMO6Hpo9TtLvclS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QKVo3JTA; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QKVo3JTA"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-7a1d42da3f7so297648785a.2
        for <ell@lists.linux.dev>; Tue, 30 Jul 2024 09:51:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722358303; x=1722963103; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=rV2wwPc07QOJPl2f51hLovMic6aWzG6SqG2G7F76YAQ=;
        b=QKVo3JTAyjtemd8mpOWId/q42mDVRW5qcmq6iIDyJtYw/OqinBGwvzwvoy8xBaphRx
         J5XVD4mGtLUhQte8Q2UPg5owrsjF0bsiSez2rd4narnK+QdlvBRDIavho9pEMWdfaSmw
         5ziS875dUN9qqEsCP3axACBz9diNOuhGUje6Lql3xA2Nb8ALhuSiSB512YB+QHkfUSW7
         6+yjh3gs24pwk8PcH0i5qc8xXAc6tljp608wa5bb8mOGN6TfDK2qO3b1z0YxCSgM+jTI
         wQawpIs4pGjfhQJxh0hEyKBEYfC8yCGMWFCwHwn0jk579cm7t2fM14L2Xs/Jx0UZZymb
         v9qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722358303; x=1722963103;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=rV2wwPc07QOJPl2f51hLovMic6aWzG6SqG2G7F76YAQ=;
        b=kHkPB2mY/1ps6gbZE1KIxvH//gPRInnOsfZ6WDCiRie/41x+rzV1nhEsDs7S5HdZah
         kVCThrFd/Qe2chwsJdf11mY3lGQsxL7d5upF4b4BJFMx/D9r1Ea3G1KnQ/jCwOXXVA2d
         2rCn27idR4nuLWpRkVwwxrP8SG0g+vUPM6ffI0HFNeQTWPJYihkFY+tfIp79K16x1a/s
         au2s1fV5mU+/sdkhcCwNFl0wozcZMXQinxSytjykJh2pwyUAhmQFmpbU2gz/N6vDJHkU
         S/hNQreT7rNtjjIqGZqPNZVjRz35bmiubiOrsF1E2nlEujpXDk6cv831m+Cz24+NHPiI
         kHWg==
X-Gm-Message-State: AOJu0YzfWozXkjjZY81h3qtwyHY2D5AkrQZqY6Je84P7TAg1hdrnb2J/
	QQ1iWJXj0xw8aliNEV1yW8SOP9t5qs1ztk7ePXOSkSh4NPbgYKke1h3UeQ==
X-Google-Smtp-Source: AGHT+IGPWegIYj6tKeHqXG5131JNGFhJp3BljnF6LqP4Qhy2fnh89KKl7K81J74Mr5xqjcYuawT52Q==
X-Received: by 2002:a05:620a:1929:b0:79f:3f6:55d1 with SMTP id af79cd13be357-7a1e52301afmr1488593285a.8.1722358303001;
        Tue, 30 Jul 2024 09:51:43 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-7a1d73ed346sm656003485a.68.2024.07.30.09.51.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 30 Jul 2024 09:51:42 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] unit: pragma test_address to fix GCC warning on musl-libc
Date: Tue, 30 Jul 2024 09:51:38 -0700
Message-Id: <20240730165138.274112-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This appears to be a compiler bug causing an array-bounds warning:

unit/test-rtnl.c: In function 'test_address':
unit/test-rtnl.c:285:13: error: offset '2305843009213693948' outside bounds of constant string [-Werror=array-bounds]
  285 | static void test_address(const void *data)
      |             ^~~~~~~~~~~~
unit/test-rtnl.c:215:36: note: 'address' declared here
  215 | static const struct l_rtnl_address address = {
      |                                    ^~~~~~~

There is nothing visually wrong with the code, and it appears to be
having an issue with the "label" member, which is a simple constant
string. Doing things like adding a member before "label" or making
"address" not const seems to make it go away, making it really
appear as if the compiler is confused.

Fix this by adding a pragma for that test function.
---
 unit/test-rtnl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-rtnl.c b/unit/test-rtnl.c
index 25e1859..59d8492 100644
--- a/unit/test-rtnl.c
+++ b/unit/test-rtnl.c
@@ -279,6 +279,8 @@ static struct ifaddrmsg *build_ifaddrmsg(const struct l_rtnl_address *addr,
 	return ifamsg;
 }
 
+_Pragma("GCC diagnostic push")
+_Pragma("GCC diagnostic ignored \"-Warray-bounds\"")
 static void test_address(const void *data)
 {
 	static const int ifindex = 3;
@@ -293,6 +295,7 @@ static void test_address(const void *data)
 	assert(messages_equal(nlm, ifamsg, ifamsg_len));
 	l_netlink_message_unref(nlm);
 }
+_Pragma("GCC diagnostic pop")
 
 static void signal_handler(uint32_t signo, void *user_data)
 {
-- 
2.34.1

