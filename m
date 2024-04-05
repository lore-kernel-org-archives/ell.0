Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FAB6652
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276418; cv=none; b=iKF2I9onFk38gAt1hRs9ONX+ez8kNQOi61f8lnuB7Pfukg0CwogPBFiJxjwM1nrikJiUv10uvlk6ZBkzV0pTnSLZavia5KZI0eX8h6gBeZzeq6n5Fvli7VliOYi67l6oowFWHwp4ElmGALGnwNeqQ5kA9X6PZu2qzOM9m8FHlJI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276418; c=relaxed/simple;
	bh=ilIxmrr0XEVErLxgD8sgR/pru8QCekdZAdoQ+o4JGTk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oPYUWfLlCMMYC/WJVvqBSXkIbfz1thj9UPfAQo0axQwkXpkdVWks9y0gJBlTeEixWbGx9q/HrauMiEniBxGc5TzvvvEuVcNc8Mwn98+Vv2PwF1wW+eEu4qfND0Z+M/0tJSVTqv7H6IvtwbU1X8buystZ4HHKlSyNbekHWOS3w4w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=IDlrlvYN; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="IDlrlvYN"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 345C41649CC;
	Thu,  4 Apr 2024 20:20:15 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id B570B124F66;
	Thu,  4 Apr 2024 20:20:14 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] ell/Makefile: Added 'edit.[ch]' to HEADERS and SOURCES.
Date: Thu,  4 Apr 2024 17:20:06 -0700
Message-ID: <20240405002011.3480886-4-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240405002011.3480886-1-gerickson@nuovations.com>
References: <20240405002011.3480886-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=MydMjUzicnOQPS7Mk920AzjOp6pymJsXxgb2qKWinxk=; b=IDlrlvYN0wuv83r2KGCgVW94s9e66iKyvjKxKlB42ophGuxMq/S9xcchk9+gklPgj3ukuyMJntVC0RubGsYPFLYFKVuJO5prX0Nsxrqyc5zXj22SDfo55ms7a6ktWlEoPkTGbGkXZHKCDN7YWBq9hy3t5XcCqHQYng1dvp9WBWnDEbLl757ejOhUz9qXyCUbhvYQaAPfbUlFA9bNSS79xTVU+l44ST53Ffz3FcAdhi94FhPd73JtML5U/zaPJvLrIywuYxnIQgIpU5gQTfgDAayAtytIuxVJ6P0MDSNa4oWXhifM3vX/BNfV0XD4vWW6TzPFJlt4DXPRf1NYJ7GxGg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 Makefile.am | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..d39a3845077c 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -55,6 +55,7 @@ pkginclude_HEADERS = ell/ell.h \
 			ell/ecc.h \
 			ell/ecdh.h \
 			ell/time.h \
+			ell/edit.h \
 			ell/gpio.h \
 			ell/path.h \
 			ell/icmp6.h \
@@ -145,6 +146,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/edit.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-- 
2.42.0

