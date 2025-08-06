Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAB84233D9E
	for <ell@lists.linux.dev>; Wed,  6 Aug 2025 16:01:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754496090; cv=none; b=QckN60U43hFg1kXiAPtzFo1Mnar+g/2+9btPlRqm195o1FFiRq/3TRbmTb7XGzmgT+B1XcProT6avBEWITp4EOMsKsWNOW2bHQTFiph8oEvBfCyf9P2fnVoO9hdcefqiQfo5eBe/HiEWg9kxba2bbfwrWD0e4zNymWSd2uYVvew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754496090; c=relaxed/simple;
	bh=kd36ZwRchr4IICfQTsN3CL0vcCEMik8GoO64JNT0/1Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=XAbNjfRMve1Wa4nJMQmRVRnyK41dyw3qTUMjTBycIGeDr8VYog3U/XGZe59c9y6eyuhtxttMPJ7OAvC/O/FzO2ZrXNLfDb/qFE+PXZQGpUvzkDo7ZSZaJf8pXqZSJZq6YeeoSK9ulXgrG6y1ZZn1m2xo2oKDf2A9scrd6lrnB3o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 6A2C2443C6;
	Wed,  6 Aug 2025 16:01:23 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v3 0/1] build: Add meson build system
Date: Wed,  6 Aug 2025 17:59:19 +0200
Message-ID: <20250806160113.707469-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduudekgeejucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieefieevieehieeugedugeeiieeiheeludefuedvheejkeelleeukeelkeefheffnecuffhomhgrihhnpehgihhthhhusgdrtghomhenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

bluez meson port is available for comments and testing here:
https://github.com/hadess/bluez/tree/wip/hadess/add-meson
which can use ell as a meson subproject.

Changes in v3:
- Fixed building as a subproject with tests

Changes in v2:
- fix cert-ca.cnf path (should be a files(), not a string)
- fix cert-ca-index.txt generation

Bastien Nocera (1):
  build: Add meson build system

 ell/meson.build              | 185 +++++++++++++
 examples/meson.build         |  32 +++
 meson.build                  |  66 +++++
 meson_options.txt            |   5 +
 tools/meson.build            |  18 ++
 unit/gen-cert-expired-pem.sh |  14 +
 unit/meson.build             | 501 +++++++++++++++++++++++++++++++++++
 unit/xxd.sh                  |   3 +
 8 files changed, 824 insertions(+)
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

