Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE54417A2E6
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971725; cv=none; b=apcZZlDJDvOeceKNtaFJpW+OeRMulrUOardV3zgzkd4Nmr+KsDWYvtV6SYKnvbmXJaoZRTIsO/3JXtDIpp8+NJXPXqN3VsI0GMCIaPS/1lLZ9PBlFG9eCIdPakWeSMnNzXI4QQOel3Gs+WpvgVuYeePORkmWwyduBZoS/S7t7R4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971725; c=relaxed/simple;
	bh=6yKc9cyHBhQPNVycAv2aAmU6yy8M0POs78G/d3mvAFg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jyWEbIRdpJ4JHHf23j+NCn9O8Med6XN4JeDx9AYl4Sb01Jn8YfrNddETRwd2dZvCCHUcCcnjmtDdFyTEUxZmWaE4QEIRuteJ/CvGFFqlyIpqarCTCugpzwDWIl3pH4wkN10jFkY/40e8m5uSLty65ii3iw/g31zR3x5RGDV2XmA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id E8F594441A;
	Thu, 31 Jul 2025 14:22:01 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 0/5] Misc build and test fixes
Date: Thu, 31 Jul 2025 16:20:34 +0200
Message-ID: <20250731142153.2802258-1-hadess@hadess.net>
X-Mailer: git-send-email 2.50.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddutddutdefucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepffetkedtjeduvdfhtdeftddvteegieeltefhtefgtdehkeevgfeuieffhfevhfefnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth
X-GND-Sasl: hadess@hadess.net

A couple of build and test fixes I found while porting the library
to meson. Those are independent from the port, so I thought I would
post those separately, and early.

Bastien Nocera (5):
  build: Remove endianness check
  build: Remove AC_C_CHAR_UNSIGNED check
  test: Bump support TAP version
  unit: Respect TAP comments format
  unit: Fix maxkeys test output

 configure.ac       |  3 ---
 ell/test.c         |  2 +-
 unit/test-cipher.c |  8 ++++----
 unit/test-key.c    | 10 +++++-----
 unit/test-pem.c    | 10 +++++-----
 unit/test-tls.c    | 34 ++++++++++++++++++++--------------
 6 files changed, 35 insertions(+), 32 deletions(-)

-- 
2.50.0

