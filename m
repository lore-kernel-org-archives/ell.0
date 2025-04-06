Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64846192D8E
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977483; cv=none; b=tbHzBM516uPkls+34N+6cNR68si/yFTuEIneYCQ1ZL60dwSQKjUH5Bu7sfbOVAVUHCtD7I0W2bq8XgLWD0oP378kP9s+bzsyVy9bFE+l3eViBFTvcW2iRhtUaf2vIT9Jv+nnqTfDzkU/LK33fnlUpptpsK5Vnaa9ZpUjtXIw/Do=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977483; c=relaxed/simple;
	bh=fRkzmZRGdxbkgj6ayYhovsCM0Axfddw1UotV1+8U4pA=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qC+e3B09Y1BRfjmW28B9qyyXC9O5bKMX3CZMWzOzibm9oXDcOT+ELqkpt4ovRryfU6rCISx6KCKnXF9XzZ9VxEWg0h3RZ+wGUyb23WPD3aUbFuz/WG2/qzzO+288VB75i/AMwO5iaKvdwfcvIEUlbGh7tyijVT+7uBYCkEIiH8Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=lE3FqXCC; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="lE3FqXCC"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id A2198164A54
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:08 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 508FD124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:08 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 3/9] ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
Date: Sun,  6 Apr 2025 15:05:59 -0700
Message-ID: <c95a029d357bd38a36c362c1e80bd7284e674c7a.1743976923.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=gFMIYXSzppPP0Uq6G7EQCpPmi+Fg/KcQ7tS2o2n4KZI=; b=lE3FqXCCP+hWO44+Ddrg8zY00S5OmFP6kRxWPo0KdxRzEW477sShslcrq08EkRxt4yITmGDLkZiTpvuADHz3Obip+HMCQkidZ3M3j9IO8B13A96Qie0fmhucr4gPp5Clir7LI8graDxuLfEax8VVO/1fNiixr3IYF0Gt1xlcW0dLWYsq/OF6ySJ0d8mLAgi7Vtx7DeTOOwf1YSMQTAlnwvZYsbi7g+sjfremC8tXuH/jyjSwYhBgGKFSAuvqIhzpO2OrO7injQwd5EPPvDmFVRTc/jxkZPK3InNsQQmGJfhUEC7aZTKQmiPVmx4z5+42D45dxfy5UEFwBnCe2nHUMQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 Makefile.am | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile.am b/Makefile.am
index 84d008febe0c..abe5ac905684 100644
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
@@ -148,6 +149,7 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/ecdh.c \
 			ell/time.c \
 			ell/time-private.h \
+			ell/term.c \
 			ell/gpio.c \
 			ell/path.c \
 			ell/icmp6.c \
-- 
2.45.0

