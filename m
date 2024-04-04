Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E597613C690
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273918; cv=none; b=E3AM+jv6+yXK3013eoUjWTK/VgPctvoIx6rqpFeOSxmFMxD1gp3bsD2NpMOm9JdlXLYo4mchQVoPE2fzT9TjlMaLHdegF8TDbR0aRLCA1GKEW7Mn3D1K9N6KU4Akx0YVK+XmYtLn8299NO03sEjAq/dMuW2ceG5rGsS4+mDFpVU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273918; c=relaxed/simple;
	bh=HV8xC4QkddTHpIR+MvHFtfq47f1HwVl3PmbRl59BTu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=G710zO8z93MSqEa66qTg2engo7xsirT/EH/P1PUAFiAZjQYD/qEnwaLMJGUXsQESQ782KatCFpZAynq2DByh8f++gsDWsTPWdq8yItEjwqc5UWJnWV7E+Woa2nVPddPbRS7A5rs7sBntOKDROGDfnDvbCEd3YP3QsdGP9pRo2RY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=V3HkM/5w; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="V3HkM/5w"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 31ED81649CC;
	Thu,  4 Apr 2024 19:38:29 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id B7816124F66;
	Thu,  4 Apr 2024 19:38:28 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] ell: Add include directive for 'ell/term.h'.
Date: Thu,  4 Apr 2024 16:38:19 -0700
Message-ID: <20240404233826.3466674-3-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240404233826.3466674-1-gerickson@nuovations.com>
References: <20240404233826.3466674-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=e2IMjXnGOf4cD3mE8zrZzIJAPok5u2I1JSviK3kZevo=; b=V3HkM/5wq6FCXgjlKTNEPxeGPqmpH0Byu7Y8Bnr+8M4+q3cxVLwP3bgoUW7b3Xqkq/xSSI57i4d2F2tuIvB/EbZktCH/Ebb3aXtxbj3jK9Olao6xcssQWiR+iWRS0Hx2qL1sU7eMMj4UYQbMEskpOZOC431zfe2DC2O+6enDSU965fb7KGaN7wg8vXD6acTY1t8U4DAG11AZSQpBytRxFzZC4oMrCNECYoQ5BFnqxmvREXiw+JIBGsg5vL6SHMAAbqz7+nxEIE/3HSN3rzBGohYTNTiykorZbPVAwyfYIG0wNpIAxwc9mXTwG7YkwF2znHJVuJuIso0QJgRbW3PbRQ==
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

