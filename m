Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 096B41B414A
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977540; cv=none; b=jBVNBDeimgoe1xz2TTnaoyRzjt2TwLFuNQtcWzoKvGR4A1BpfCp55ga2eZLfo9z2ECQ61FWKFGrLUTk4LGD9jf6c54A+kdllEziz8CfSDNP94T/4nqvyvSo8cnQMI/tKiNwKF+MdG7vkq6ZcZU/o0u0DM9skseRBEZlWZ5Nem3Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977540; c=relaxed/simple;
	bh=ha2HAu8ieEfQe+bJLL8MEztxFP/Urer8UmEPLRVmKeU=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qiwcUu+0tNoQnoVPxAHImoykMOgZZUsxSOfsnEpgnt3T103+GxRA4yHNUEiLrg+17eQy+s941BJhoyEUyjOGZzSuVvIR6Qz6LaR5K9L+cUh/3CLsV7SLTUELhXiGac0zV20/M7SswZu/08OH5EJ77FXycV2P6bH4hUXCc7Ny1BM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=hdEiQVzv; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="hdEiQVzv"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 70FFC164A54
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 208A21260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 3/8] ell/Makefile: Added 'edit.[ch]' to HEADERS and SOURCES.
Date: Sun,  6 Apr 2025 15:12:10 -0700
Message-ID: <14d3dbc69f3e2c1702b0d52dab64c3c02700c9c8.1743977403.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=iA+XzckOV341mbIzz/ofVbfUCkFRaJcpGbcZUr27j3s=; b=hdEiQVzvZXi4lG/IdzlQcc4d3bKoglSTbh5+DidhIzDuNQa1FCwlyKbpNntL4h97kFD/H6oc8TeuUBU851k/hlz0rlj/2Xuy+i2ZfjeBcBk9ziVbcr4EAwG2ymLw3iNFcN1k1Bh43DpZMrUrTwqGZBGnmOgQaClJLlpFASSb0HTqDP4SWT2BZlzF+LRVlUBBCVFm3u2W1b4+he+SEFCT+F3ipua82xzJ4GZwVMW9pcL727nOahFU/DirYqnnvtsQoxYHApkyqyqJmJ/bIVpN2+HhRrwVbJ1AyIpJDdVj6UEzYIMAi88t6FDP3XaqyMaRwf9i/mkAi3ATpQ4H+fYZ9g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 Makefile.am | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 84d008febe0c..ae2612f4b770 100644
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
@@ -148,6 +149,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/edit.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-- 
2.45.0

