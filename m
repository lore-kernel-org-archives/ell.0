Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A80853E6DC2
	for <ell@lists.linux.dev>; Tue, 17 Mar 2026 14:30:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773757836; cv=none; b=qxYpFY0TPAe06qU48ztO6aWOiZ7jcIbfyi5Tm/3pjQQAB00Uil0QyhDVPQciKmQPdO46U/8WbEwLNLmcNqyYP8DLAWfCJzhA7TUFSiSMBb5f3/0sACM8m4TSDIPBqZrQqE6Yzx5FGWGL28UX6YV4WN7LmGUNgM5GPvs8ZK0K2gs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773757836; c=relaxed/simple;
	bh=hGF6+hp1WgwFgHXwL9OPut34hpCX3siXXadHLgeB/es=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Q9G+yhvCoaztwlG3R+jhH/pZl+gMO47FUBTi7gwcSP/isSSqGDozSAPci3ayxyioTJgyYqK8dwCR9vagROR3hu9BiPBoLgwL1kgAVRocYhik3pD8uLmSEfWMt+rNNZ8tfAozdmUEIJLqt+MEj37CF6EDWkP8QOvGQl+ZpL1ARdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 93F5E3EE03;
	Tue, 17 Mar 2026 14:30:26 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 0/4] More build fixes
Date: Tue, 17 Mar 2026 15:28:53 +0100
Message-ID: <20260317143018.628844-1-hadess@hadess.net>
X-Mailer: git-send-email 2.53.0
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeftddugeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieefieevieehieeugedugeeiieeiheeludefuedvheejkeelleeukeelkeefheffnecuffhomhgrihhnpehgihhthhhusgdrtghomhenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmegsrgegfeemrgeijeeimegtvdgufeemjegrheefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmegsrgegfeemrgeijeeimegtvdgufeemjegrheefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhqihgupeelfefhhefgfefggfdtfedpmhhouggvpehsmhhtphhouhhtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght

Another batch of fixes for compiling on Alpine Linux and/or clang:
https://github.com/mesonbuild/wrapdb/pull/2646

Bastien Nocera (4):
  unit: Fix incorrect basename usage
  ell: Fix rawmemchr implementation warning in Alpine/clang
  ell: Fix cert_pkcs12_pbkdf() warning under Alpine/clang
  unit: Skip hwdb test when hwdb isn't available

 ell/cert-crypto.c |  4 ++++
 ell/missing.h     |  4 ++++
 unit/test-hwdb.c  | 13 ++++++++++---
 unit/test-path.c  |  4 ++--
 4 files changed, 20 insertions(+), 5 deletions(-)

-- 
2.53.0

