Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD20AA2A
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277423; cv=none; b=nyF/i0g0CORwpUbG/kq7ppwQSYqdUwSYoBXG3EkvJ+vxJK1/W0o9JIfJ+CRxsKK7Qm3hnGU2cdh+bKUlF0Q4Q9wiPS9Ehrzj57RsEIuaHvqaGdeW0afIjzW6lmjbf4NDpjT2J0Bd1EUpR2jqHhlWYUmoayplWeUgD/+qaUZ+RHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277423; c=relaxed/simple;
	bh=HV8xC4QkddTHpIR+MvHFtfq47f1HwVl3PmbRl59BTu8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GKHJX7TDU+2X+tcNN/Aqcle0o/OtUPpRSnWIszbpeEdqd2YQpLmupD7TIO1LtjiyNunQR9EOdo0gq+wemgktFnP0Thv1zBlkocq8AzXaOJl4he+bLD4xNa1X4MhSKhJ8CBnJmGUOa9GLnqtgg9hvxp/IVagSaBWXWSLAzCLhfJ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=OJ/gFph6; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="OJ/gFph6"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id E35DD1649CB;
	Thu,  4 Apr 2024 20:37:00 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 7F96C124F66;
	Thu,  4 Apr 2024 20:37:00 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] ell: Add include directive for 'ell/term.h'.
Date: Thu,  4 Apr 2024 17:36:51 -0700
Message-ID: <20240405003658.3490494-3-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240405003658.3490494-1-gerickson@nuovations.com>
References: <20240405003658.3490494-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=e2IMjXnGOf4cD3mE8zrZzIJAPok5u2I1JSviK3kZevo=; b=OJ/gFph6FZdPbB24LZLJDmy3wax2i91PYY+lcpPSsy3VwqB1zUZDSrKROk5O4Nx29YtvN1hq6CZwYengx4jGtFT41+33ORVtqzZzKQFRgs6dFkBbykAf3leBmC0CL0+qRkuzEdSpzAmnhjN9XHCOsi+DTN3/0E1AK6Y7dKyw2GYoq16a9BzTjcRD3VeYPDgmNtW56tFDMrYxesgE82CEUeJn9XsaqpoITMWKezHTif44O3IJD+ML8bje/T4UIgREYshZs4snAeiqnJcSBFkMrLYlH7QLvVC+13/Jl42dJn8z83gIGxw9bro7aiQuN2K/AA2tQstXG3Q0TatmTYdLrA==
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

