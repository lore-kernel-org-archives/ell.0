Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBEBF1A8F9E
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977540; cv=none; b=HeSoNx0avulnIa/53zdL949/mPHYcVez+JALhu93bGEarQ6mM8l7tT0Shfm/lA0Ud45BTyc0PaJNjkyexYwQ+yi3wOPY+jXajiwQOpvTi/xH/iID+GUPgWe3rDYjQJHdyA2OkY2D83mMIG/bmOan4NpFWGBD+ZvSajejTz19xq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977540; c=relaxed/simple;
	bh=siltQyIgFGEDAaysDlLQo7hvtOvLIgvt2toL/b1I6kg=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=JDDMPGxVC+yS+5rbdQC9MZkP6yX9hT2JHG8JAjePWJwIKjTUCrpRUSjUYgg2Lxwil8zweVaLdC2F0eHDtHQGS2dJrCqB/gw9LNNKHTY/vSl2k6/3fTHQhYZNGIvIK+gKe3McJGP36ctQnjHo1gep99GzgjL3MbW4fD43zqAt+JM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=hOA5f9m9; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="hOA5f9m9"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 012EE164A4D
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id A68951260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:17 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 2/8] ell: Add include directive for 'ell/edit.h'.
Date: Sun,  6 Apr 2025 15:12:09 -0700
Message-ID: <ca624cd0bfacbc292b8922b5170f633375a3e059.1743977403.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743977403.git.gerickson@nuovations.com>
References: <cover.1743977403.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=m6L3GTgxskf5oiAebVFLMKGZSXyGGVPx2cddEDTfkNA=; b=hOA5f9m9nZ0ECncMzRz/uio8uhavhKExKYOCxrDlHLZq49JOn5SSvfsS7KwBxU67YuR7WR9+dX9UAyC2vaeneZHmFQf240pgrnJG+95zPg8RoDwinvc/L+upzuTW3QrBpoRKcLYiDQNjmXVT07E2+JTkKtH35F8HnmRnP1OszDt38IJJXqJK3Jceq3UIniwNwGRnf4JsSr/VZuD3Dk5h0iwn2LkElJPBnzEosydTDM8zDRCU0XyqAHzWPM94SIjwFD2ttuIlKP0t/dZBzr0wizqEC7CSWzDXnGFCIcbMn4tL/lnVHrbcr6WgY8fYf5J4LN8bsAGZ+GHRSWMPOsEe1A==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.h b/ell/ell.h
index 7a263e9376de..6db35b9cfb6b 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -46,6 +46,7 @@
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
 #include <ell/time.h>
+#include <ell/edit.h>
 #include <ell/gpio.h>
 #include <ell/path.h>
 #include <ell/acd.h>
-- 
2.45.0

