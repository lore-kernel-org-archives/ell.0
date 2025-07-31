Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 22C72188006
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971726; cv=none; b=XoQxV7G+hZKJBvk0tIctsowfmC8Qq8UqhZgQq5dG/qyn8EMZpFyGNGHF6rcf0CVrTqlfM4CWaBqDty7uSXACVQpJf3Da24yZhGleQHZjAlogRyy2b0g0nPa7xcUX8M7FN3fGyp9GGjsussCoalJlF/59h+mf9UuboEOLqB4I/4c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971726; c=relaxed/simple;
	bh=cTUte+FP9zGrM6eSHIXsiCowo29bMDpdjlz7wc0Nhz4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qobTo7VEZ1GmCe25FTFtJYuYANHWVxBAfhQSXRDENAUHKWTyTER/pX+NHEdWpkdAcJPjmfM0tOPJUkV104fAI+Jo70KCtZxjySPsvoBys1qTsmw3u4xLDMhOXJGhIGg10qymuAzCyKjnf8fZg/NQVgvfyfa4BLbUQSKgfbxJEes=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 47A4D44424;
	Thu, 31 Jul 2025 14:22:02 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 1/5] build: Remove endianness check
Date: Thu, 31 Jul 2025 16:20:35 +0200
Message-ID: <20250731142153.2802258-2-hadess@hadess.net>
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

As used, AC_C_BIGENDIAN() sets a little_endian variable that's never
used anywhere. If an action was not set, the macro would define
WORDS_BIGENDIAN, but that's also not used anywhere.
---
 configure.ac | 1 -
 1 file changed, 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index c629caca6e70..8409909aded8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -29,7 +29,6 @@ AC_PROG_INSTALL
 AC_PROG_AWK
 
 AC_C_CHAR_UNSIGNED
-AC_C_BIGENDIAN(little_endian=no, little_endian=yes, little_endian=no)
 
 LT_PREREQ(2.2)
 LT_INIT([disable-static])
-- 
2.50.0

