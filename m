Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A196F255E53
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 14:14:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1755699249; cv=none; b=lOr9z3MFQJ6MSKn+uzgdika0XIWtFKjlDq7cp5O9YgyovpT3akXTLyPYHhlhVTkXc1SRFKToraKnGIg5LapS3932ZVlZeXO2PCUrHcgQA5l0LTZaNhbfeS6tc9b6GK9WJl0EAHGUAISH3cW0xyZ6VTpiYTfHIBj6bN050M9oAlY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1755699249; c=relaxed/simple;
	bh=iDv3Mtn/ieMOKSYSOs6S1K2sj0tZ9sVvDMIaTshNk/g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=igTggQLbIYLx9RxpuI024RB/GEk5uy0EIfZ74yH/zK9Kfp0ogW53g4DqG8IMM0IApXdlBzzyhDAvE3d6h6xdtwWYLq9q86q6qx/6DE7RqjbhJV+WT/vbqVO6go9+lDGm3TL7a73s1NjORMraqU5RR93HYZkJKP8EonP/No8Myfg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 8BE38438E4;
	Wed, 20 Aug 2025 14:14:04 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH] tls: Fix possible memory leak
Date: Wed, 20 Aug 2025 16:13:58 +0200
Message-ID: <20250820141403.800412-1-hadess@hadess.net>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduheekheekucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepffetkedtjeduvdfhtdeftddvteegieeltefhtefgtdehkeevgfeuieffhfevhfefnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeholhhimhhpihgtrdhrvgguhhgrthdrtghomhdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

ell/tls-suites.c:784:3: leaked_storage: Variable "other_public" going out of scope leaks the storage it points to.
---
 ell/tls-suites.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index eb023a6bf2c0..233ed162fa62 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -781,6 +781,7 @@ static void tls_handle_ecdhe_client_key_xchg(struct l_tls *tls,
 						&secret)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 				"Generating ECDH shared-secret failed");
+		l_ecc_point_free(other_public);
 		return;
 	}
 
-- 
2.50.1

