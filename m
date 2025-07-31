Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66684189902
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971726; cv=none; b=SEU0JpzA235SI3DxrFs2UfB83uORq5wabpZSeihf0oDLmgc9d4EV/ZdfPO1fTRU1uonMKVwaDVO70IB+/DLDecj/f+UyhGsnYLpzqV/mot+KCfw/nQT8os8v9OG18tXgNxEmAIk1IPdSbjLCCDlBjzPrW1RaTYM1IDO1yKF6QKM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971726; c=relaxed/simple;
	bh=kcA/hc4B4SPH7qU/YAyDX36mAysuqKb/5wPY//Oi5bs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=m4AAB8eNmKqQhFvys/hOLakFpqbG1PgtsTqw7kh2a+ngY4lT0klO3b1YMiAQ9Ow+fC5LUhvTOzvOElEAovJ12PupJHO+LtjHRY0gebFZZjl8vopwFrM5sxdWT83jb/jqa+AnxILuZxJ+VHBY5A5/Bahl+5GkH71m4Ya3nYFKrno=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 9CFAC443FE;
	Thu, 31 Jul 2025 14:22:02 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 2/5] build: Remove AC_C_CHAR_UNSIGNED check
Date: Thu, 31 Jul 2025 16:20:36 +0200
Message-ID: <20250731142153.2802258-3-hadess@hadess.net>
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

If the C type char is unsigned, the check defines __CHAR_UNSIGNED__,
but that's not used anywhere in the sources.
---
 configure.ac | 2 --
 1 file changed, 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 8409909aded8..441dcad15036 100644
--- a/configure.ac
+++ b/configure.ac
@@ -28,8 +28,6 @@ AC_PROG_CC_UBSAN
 AC_PROG_INSTALL
 AC_PROG_AWK
 
-AC_C_CHAR_UNSIGNED
-
 LT_PREREQ(2.2)
 LT_INIT([disable-static])
 
-- 
2.50.0

