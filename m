Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net [217.70.183.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB5B622FF2E
	for <ell@lists.linux.dev>; Fri,  1 Aug 2025 12:42:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.200
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754052158; cv=none; b=dQW+cUcdc1iW58TQLyCJhX6etGa9CQ/bRek8EaYQIQIYrZCK196ac5iLTEB2ik2FvXr1Qqkki2ZO4mJ2drMv5RFzd/71u9xC/WSVnSccnhgr5GNNdD68Mk8XwfVXtVZ//GDBvKmcBNoAfx9MGOyns5wzWZPeqKKYJkHmv3GqN20=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754052158; c=relaxed/simple;
	bh=VdM8/6CdcKUfI0Q8qBBghIQX5Yy0BWN2sgDNVqv024A=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=o/yompHPLuZWqgAhUz9crVmTsSAx2IV9KCym59+iCYsSoLavr6dRTEaVlHT7WLidJDs3MJbiVridcn6/fZnrlQk7R5MHH4iH/h35whh5anmN/NdyipuAC8boVcM7mUBU5CY9ZDBiPbPtBp8b+DGG8xCIjBmfjjwSUJ2hefuqYKA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.200
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id AFE1B43999;
	Fri,  1 Aug 2025 12:42:33 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 0/1] build: Add meson build system
Date: Fri,  1 Aug 2025 14:36:35 +0200
Message-ID: <20250801124226.3386983-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddutdefjedvucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepgefhtedtgfeiudevgfefveeufefghfelfedthfevffehjedvhfegffdufeelueffnecuffhomhgrihhnpehmvghsohhnsghuihhlugdrtghomhdpfhhrvggvuggvshhkthhophdrohhrghenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

This adds meson as an alternative build system. I'm doing this to get
bluez also ported, and have a try at porting some plugins to Rust,
something which meson makes easier on the build system side at least.
See: https://mesonbuild.com/Rust-module.html#rust-module

Benefits of meson:
- build and tests is marginally faster with meson on my i9-9900k from 2018:
  autotools with -j 16: about 11 seconds
  meson: 6 seconds
- it can be used as a subproject for other projects (so either
  vendored, or external) like bluez (see above)
- enforces builddir != srcdir which can be useful to avoid bugs
- no more EXTRA_DIST! meson bundles the whole git repo
  when running meson dist
- no more m4 macros or libtool :)
- only dependency is python3 and ninja (which also only needs python3)

notes about the port:
- symbols export was verified with abidiff, if there's a CI, it would
  be great to add a regression test:
  https://gitlab.freedesktop.org/hadess/check-abi
- cert-ca.cnf could be a static file
- xxd.sh is only needed because xxd behaves differently when passed a
  file and stdin as input, but we could change both autotools and
  meson to use the file directly
- we could do with more de-duplication in the certificate generation
- 100% of the tests run successfully

Bastien Nocera (1):
  build: Add meson build system

 ell/meson.build              | 185 +++++++++++++
 examples/meson.build         |  32 +++
 meson.build                  |  66 +++++
 meson_options.txt            |   5 +
 tools/meson.build            |  18 ++
 unit/gen-cert-expired-pem.sh |  15 ++
 unit/meson.build             | 501 +++++++++++++++++++++++++++++++++++
 unit/xxd.sh                  |   3 +
 8 files changed, 825 insertions(+)
 create mode 100644 ell/meson.build
 create mode 100644 examples/meson.build
 create mode 100644 meson.build
 create mode 100644 meson_options.txt
 create mode 100644 tools/meson.build
 create mode 100755 unit/gen-cert-expired-pem.sh
 create mode 100644 unit/meson.build
 create mode 100755 unit/xxd.sh

-- 
2.50.0

