Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 500D0335B5
	for <ell@lists.linux.dev>; Sun, 31 Mar 2024 23:47:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711928863; cv=none; b=XCS7uIdfwRiLuOI7zCrJoqYRSKMyDKI/Bo43TZAit+2AvGZ50FBqKMkgrvqovOXY7/nXPKQ8Z9unZM4Enz94MYxHDngi7uxUBSADjqtb0OZF52pD94nqUGYhyy9gP5u2dPaDanBm8sq1gxYlG/sU7zNYdgiA5U9KYi1dsyeuPXQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711928863; c=relaxed/simple;
	bh=HV8xC4QkddTHpIR+MvHFtfq47f1HwVl3PmbRl59BTu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Uh5GX2wDpJz7IEhX0J4KBDMvAg7Yp0SA5yXRiTdpaZ3HPlHLHfEwp58jILRfla9q8/AVNQmODZn8yZNv4oPkvHw6EaRMH8Y54E6uwyhw4enSIFPeNc7LiwXUDbMO64uagtxxR9EfcjxXHVa4LEDMKZ+b7l/8Gm53YHCLCSR/GKc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=PnacOz4r; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="PnacOz4r"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 2AC1A1649C2;
	Sun, 31 Mar 2024 19:47:40 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id AE92D124F8E;
	Sun, 31 Mar 2024 19:47:39 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] ell: Add include directive for 'ell/term.h'.
Date: Sun, 31 Mar 2024 16:47:35 -0700
Message-ID: <20240331234737.2452696-3-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240331234737.2452696-1-gerickson@nuovations.com>
References: <20240331234737.2452696-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=e2IMjXnGOf4cD3mE8zrZzIJAPok5u2I1JSviK3kZevo=; b=PnacOz4rrPHVZU5ClfqK4uIJ7GmL8OlYfYMd6KylkAG7jmFD1HUnMiufcUFAsl8W1RuqQ0N66d7WTupYJEqPJqnriEU6dhfjBaq1rJs1+beE0pv3M0Vz8UDcUb7BTNCID9e3G5PXwdcDzIzfHCRKcFUTbe+di/lVVIrtfcqOAKVNTvMtso2HWG9UcJCEbiEa8NpUgsHLspWl3UBXS+rBegLDc+W0UkS17hgLsiP8lyvT7gGCJvLSnDdHBznAwjOap4Pohaf3MCP+VyNOrwD2p4ozm9ttgbhAmAdXbyNSIrRnaR+MbC6sloD1+QawKZRrG9DmjeO01ZwZJrfcuNWJPg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.h b/ell/ell.h
index f67339105e8f..c648715e9bce 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -46,6 +46,7 @@
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
 #include <ell/time.h>
+#include <ell/term.h>
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
-- 
2.42.0

