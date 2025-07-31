Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D671018C928
	for <ell@lists.linux.dev>; Thu, 31 Jul 2025 14:22:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753971726; cv=none; b=QQXpMYYiDLg4j1zclAFiTEVWiuVGg4xiCZZrW/qVTXgek9QxVbJHYt3+fYCi4IS4fAjJ00GVrWx3k2PWtF1rhA3eiokSgR0mOCxZZrUMUOL3nAiDhzlifvn3ocYKhNl+STgcpFeXqWYS1WP/iiVDEi4KSZL9ZEc2xuSIybONZSc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753971726; c=relaxed/simple;
	bh=GwT4EeQ2PJ6XeYW+xSaVM+82g7kRo/s9GMffUUHXM3s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mb7dZiXYSJYHNC86W7XsRpmstgYOGJJfBO78RJTzsZn0TFnoMPxB5ZS1958XLm7FnjnEgCKELY1giXtzE82VnJBfT1jgjVnxGqscFHz8AG9iZBa6A4HjBwQpowW8oAdDwuHFSS1b6IXcAuCknVFTwriEnf6TUJ+nWNCQ3kS7tNA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id EECB5444CC;
	Thu, 31 Jul 2025 14:22:02 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH 3/5] test: Bump support TAP version
Date: Thu, 31 Jul 2025 16:20:37 +0200
Message-ID: <20250731142153.2802258-4-hadess@hadess.net>
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
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddutddutdefucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhephffvvefufffkofgjfhgggfestdekredtredttdenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepuddvieetffelhfehueegudehfffhfeehgeetgffhkeeiteevvddtueetffegudefnecuffhomhgrihhnpehtvghsthgrnhihthhhihhnghdrohhrghenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

Version 13 is the last upstream supported version. See:
https://testanything.org/
---
 ell/test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/test.c b/ell/test.c
index 061d4eb38bbb..23d91e299e54 100644
--- a/ell/test.c
+++ b/ell/test.c
@@ -456,7 +456,7 @@ LIB_EXPORT int l_test_run(void)
 	}
 
 	if (tap_enable) {
-		printf("TAP version 12\n");
+		printf("TAP version 13\n");
 		printf("1..%u\n", test_count);
 	}
 
-- 
2.50.0

