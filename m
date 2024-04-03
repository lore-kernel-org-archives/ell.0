Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 507961534F7
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164949; cv=none; b=OV4Atmivr431Fy5AdOXvMIaudMTiP0QAy1Lt2gTOqTsvDwNeody6wp55oRdE9SBkOF8FF36W2xabYiQG/lDD2mnlaIX7cD7Q9EN3XA5umfgU+5+ybSKWmjUASsf01pL2XXk1YOcasGmlEgk4+kYdvMdWB6bgg3PJ1zZxP/N1B4Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164949; c=relaxed/simple;
	bh=iZ/RA8XVoPeKVnzjVCnulrf8rQ6LZt9cF/0nP7kLDbY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jxAT/3MPFBwUk8PCygZdEaE7EtVzUYiAYYHHWlN3CxyK8/NbdXUbWXphCv/VIMoQMWNP1+gZKnm0uzxmi6FTFZwW0ob3GNNsqBL/g8w+Ta/J89Ipw6q8czcBlSDJ9+3w/TgVZ0Zbi4Ya9wk2z4GOr6rbCQnRyC6aK/Z7SrWRnFc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=DMGVFWHR; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="DMGVFWHR"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id CC1D6164A8B;
	Wed,  3 Apr 2024 13:22:19 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 568C6124F66;
	Wed,  3 Apr 2024 13:22:19 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
Date: Wed,  3 Apr 2024 10:22:11 -0700
Message-ID: <20240403172216.3254805-4-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240403172216.3254805-1-gerickson@nuovations.com>
References: <20240403172216.3254805-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=A4lGAn0XrWXIA8QFoY7e4UOgcDitezEd7I5VUnfs1sQ=; b=DMGVFWHRxuOy4j60i28LbJ7nIbbDbRqAoRpb/QFwktWf6Yz2yCGd43iQZ3Cjcb2HGeYqVEfVPJK8Oc/EyqCnBFQFigkSuPvR5N0AOMDDdbtWiHp61817cg80ro+lwcEHE6sCS/wccC69ny6ipg9jBvu/HXTd6E0V6pQxUOqokBRU2J6ectBE5mfxVYvV1JwFWocUJ4ExdK6W/Tw8+EyHWU9XxkdyO4Lmw+fz+/X8DxA5wzJLTRJSW7LkGKXKVIV05vtPbWURbj4XJ+95JarQwg7OUhTatfzmY9izI80UkyhgX7+lMHG/HoyOcE7QpabgleBXQXK1FAY4kpBafWO68g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 Makefile.am | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..5059682eec5f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -55,6 +55,7 @@ pkginclude_HEADERS = ell/ell.h \
 			ell/ecc.h \
 			ell/ecdh.h \
 			ell/time.h \
+			ell/term.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
@@ -145,6 +146,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/term.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-- 
2.42.0

