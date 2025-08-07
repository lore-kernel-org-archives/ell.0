Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF9AD204583
	for <ell@lists.linux.dev>; Thu,  7 Aug 2025 13:49:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754574558; cv=none; b=P7CVBz9QtbPd7Pgl1EBoIN/YE42kK4HuUzeO/+GkTHiEvULEdUtydCjyesiROMgblQ+MDJCZiYDhtEDFlvudg1qk3lRORKAP64EfhpOrTMVfdFOvSgNODKbW8Lh10pE8STBlQrI4jwBwRGicgELEizeKWaDUIrPg0nPa3KNsyYc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754574558; c=relaxed/simple;
	bh=Gd3aWMD8KbekPsXyRcm4sZM0CuynK2RCDalB7H/c98Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YN1LWRaMUz6MqMKvjBuduA2xdlb1z4aHdZCh92idek0JLY1i9J5iRCnv4AGYumRd291wEdlDZgZJ1umHGlZWmKJZkaPjgVMFOScg79PD5ecmcvW2FqwvQrmZPbbxANxG48xumrUFgCGMsp/SHyHr44Gbh0S1aCGgCLj9KdigU1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 7891B1FD75;
	Thu,  7 Aug 2025 13:49:08 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v5 0/1] build: Add meson build system
Date: Thu,  7 Aug 2025 15:47:31 +0200
Message-ID: <20250807134859.930870-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduvddutdelucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepieefieevieehieeugedugeeiieeiheeludefuedvheejkeelleeukeelkeefheffnecuffhomhgrihhnpehgihhthhhusgdrtghomhenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

bluez meson port is available for comments and testing here:
https://github.com/hadess/bluez/tree/wip/hadess/add-meson
which can use ell as a meson subproject.

Changes in v5:
- Don't install pkg-config file or headers if building
  the library statically

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

 ell/meson.build              | 187 +++++++++++++
 examples/meson.build         |  32 +++
 meson.build                  |  69 +++++
 meson_options.txt            |   5 +
 tools/meson.build            |  18 ++
 unit/gen-cert-expired-pem.sh |  14 +
 unit/meson.build             | 501 +++++++++++++++++++++++++++++++++++
 unit/xxd.sh                  |   3 +
 8 files changed, 829 insertions(+)
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

