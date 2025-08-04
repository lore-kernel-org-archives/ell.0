Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9666F35979
	for <ell@lists.linux.dev>; Mon,  4 Aug 2025 10:46:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754304376; cv=none; b=Itkdjb7HdMCW7ab2Mu8RDp3DRbhu5kKbh+snWspSFB5wqsX7R4ruEB3F9nSeP47DCyoq8wzlJDQOirGwzRpz16wzJbtjGMStGd+wI/bIlHQbCWt0MVmMekVHvG4ZVyhyoPfvzj5IKxZFWIRd3GGy8kOSVtFbfoRs5Njgg9nSn48=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754304376; c=relaxed/simple;
	bh=AsiKviGy6AXrJSrkpJuA9io3pGz6Hjt+kag9Uv5oc40=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=S7ZnQpW8z3+8AEM1+oMemdLIKioiwr4cNoGmVBXxZfS2RbTjCBiwNhGTRqkTvVqIOagbyFN/v1SAw9fqIVuXNVu1w8RtUuxjwKH/cODZLPjjpDPUAXfamGmzet4sl+STzjlibXFFNkfuJpX37Xbyy5MqUbq7F2XD3FzGMDF8GiM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id E6C0643371;
	Mon,  4 Aug 2025 10:46:05 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH v2 0/1] build: Add meson build system
Date: Mon,  4 Aug 2025 12:44:55 +0200
Message-ID: <20250804104557.4061152-1-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduuddvtdejucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepffetkedtjeduvdfhtdeftddvteegieeltefhtefgtdehkeevgfeuieffhfevhfefnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeholhhimhhpihgtpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghvpdhrtghpthhtohephhgruggvshhssehhrgguvghsshdrnhgvth
X-GND-Sasl: hadess@hadess.net

Changes since v1:
- fix cert-ca.cnf path (should be a files(), not a string)
- fix cert-ca-index.txt generation

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

