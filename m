Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C4832E62C
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977482; cv=none; b=bztyfIxmM5ZFBPa6xlDHj2cowww1AvMEbx8lESz87JRTPUgGMh9c3myYeCh7tAwx3AydkCLZZKIcZwYZrSQeFy7YUbShXc/wRIzRKXUa8VWRH2R5VMnxAwQ+YQh1sxMS3+jlIh+rpKoc0/GJHpMbQGF3pKjMyejR84IN4fpDTWU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977482; c=relaxed/simple;
	bh=6hoS0wp7r8aA5i4svIyT6icEwxy0IsxgYMY+v1EsfLk=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=am+p0GdQlG1xEIoRy53/z3E9r4Modc+AkoPKCGpcAdryQUd3g2AbQ5Nn1a/9JhxCOtyWigyulRlDdceKovoA9vVNkxzb4fHN05WBkEVK7yMM9rJtRSzYnQZ4fJ83SiAIJNth8VPlbW/a6i+VyLjipuc79XZY4s9vErdU4YEGf9c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=mULuoK1Z; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="mULuoK1Z"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 313AF164A4D
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:08 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id D51C4124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:07 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 2/9] ell: Add include directive for 'ell/term.h'.
Date: Sun,  6 Apr 2025 15:05:58 -0700
Message-ID: <1492d6bfdbf32b52f07c531235bb2437c0313be1.1743976923.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743976923.git.gerickson@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=aEf/AjCWKiblwanNvh2Fi4UB/LwhpwC01iJUuCygrBw=; b=mULuoK1Z3o2EU4arNyvdt+rehA2ppP6Z7Z/zl9tTvXRuo4SP1pfmJ/bheiHKIo+qeyW3oFun18gI7ApnlQNolsMPgQxysUqbB3ktxkXLHe98LfkgYEDVR64Eta8lJ8lWUcp/MY6wkq54FlaXOEquclerPceM6IeQxF894zlztCLKF0kZD4lFh54mhN9w/Zbq3UT8uhVUkxmBzwVXjdR01TuXJrkRuNB8RVlptlGovV+1xWBIpnYIeCXIe1TwVEIWbs0Hl+X1NA8P5j1UsW9Em/mPuVQ5knWWBhBfZaPkEpM4yGwvrw2siiVAwsYW3QaXhPFtDJcGlq2ylYAflHdU8A==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.h b/ell/ell.h
index 7a263e9376de..1176c163f4f9 100644
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
2.45.0

