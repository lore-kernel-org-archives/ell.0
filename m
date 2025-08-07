Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC05D25A2DE
	for <ell@lists.linux.dev>; Thu,  7 Aug 2025 08:50:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754556654; cv=none; b=Mk41vyJjm/t1OSbKlUsjqV8ufeTlXz7EC9Q8X6fDOVNReTBVTgWhuYy1qkTtJPbhYxexfsY6g6bEvrgPFxRVxYqEvOlSMw3yKRHZgY6PLxGy0fkiSgjRhXPZpviOjtgJZ37CWHS346b8MDO14c/dkKmJsqwplmIgXz2T3TQlT/A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754556654; c=relaxed/simple;
	bh=xt31ZzLise0L6hCV48zeFFwCCeXDhaWpVOKdgHoWvo4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=R0biIpnhG/IgJtj+PJCu6PTIyYMWDpO44RxGcnVvFAUpbBUy7yAAWGv2oXbSJ31bUvF+cUNsJ+hpAlVHF5sIkXevsUAS6lSHJQQpG+qnwcZTC2saHrhtpeYlfa+h5w2VebFCs7K16T5hzAuLMP+Mp0uNJPHcpGpEBoXcHBXRPQI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 5B3A842FD8;
	Thu,  7 Aug 2025 08:50:44 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v4 0/1] build: Add meson build system
Date: Thu,  7 Aug 2025 10:49:13 +0200
Message-ID: <20250807085035.846719-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduvddtgeelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieefieevieehieeugedugeeiieeiheeludefuedvheejkeelleeukeelkeefheffnecuffhomhgrihhnpehgihhthhhusgdrtghomhenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

bluez meson port is available for comments and testing here:
https://github.com/hadess/bluez/tree/wip/hadess/add-meson
which can use ell as a meson subproject.

Changes in v4:
- Fixed library type when used as a subproject (it should
  inherit from the project-wide library type rather than
  force a shared library)

Changes in v3:
- Fixed building as a subproject with tests

Changes in v2:
- fix cert-ca.cnf path (should be a files(), not a string)
- fix cert-ca-index.txt generation

Bastien Nocera (1):
  build: Add meson build system

 ell/meson.build              | 185 +++++++++++++
 examples/meson.build         |  32 +++
 meson.build                  |  69 +++++
 meson_options.txt            |   5 +
 tools/meson.build            |  18 ++
 unit/gen-cert-expired-pem.sh |  14 +
 unit/meson.build             | 501 +++++++++++++++++++++++++++++++++++
 unit/xxd.sh                  |   3 +
 8 files changed, 827 insertions(+)
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

