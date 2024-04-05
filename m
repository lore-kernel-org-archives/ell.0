Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C72A1859
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277424; cv=none; b=ohkVUVb7LOvf38pZjilhXFOY6p8+lxZj4I5Y+eqT+2KUcxwaf2fX0uJ3y0TWudxHv88sE5FiIuv4hhwaa4Z22hIcOTYlshMeNTPPyFF7FdTdIMWgvnMsOSSuejNRL14HJphzWYt5VoyE1dCMDrumQqMKP4itfIS9317HRDgCQSs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277424; c=relaxed/simple;
	bh=iZ/RA8XVoPeKVnzjVCnulrf8rQ6LZt9cF/0nP7kLDbY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Uz8pU8H24t6bA9WzX8FUV6wIvwGDo4HmbbsjmxD0cjglNk3StwLPOI8+MdvdDIhdqU6AYUzoBMTuGNp+JFp+tuidUF1gKxTTCriJVE0hF3esnfP28Qtz7nsSBvwkcuq2lxI60Dw23xNqGqXNq5ANE1V51Xql6kzIG4nY+RvWtdw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=H+Acy/H6; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="H+Acy/H6"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 773DE1649CC;
	Thu,  4 Apr 2024 20:37:01 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 12086124F66;
	Thu,  4 Apr 2024 20:37:01 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
Date: Thu,  4 Apr 2024 17:36:52 -0700
Message-ID: <20240405003658.3490494-4-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=A4lGAn0XrWXIA8QFoY7e4UOgcDitezEd7I5VUnfs1sQ=; b=H+Acy/H61s8AHfPQUYa61mBpNuLdypUl5b1kyP3Lo8qIgs0GOWjbmlOBGFoIJwPx0IwckJMB8zFwsLzUGTJ5I/OQoYJsjq4iVTfK8MR6aU4fyaq/hoopwAYoceeorcq2kQiXA4vVOV9/SlpzBhaQD9QnhZJjDW/DSQce9ci1aCegDz5SOmMEd5HCV7tyGBDxTSqU1xEbDf9t2Nfdb83wNt2q7pGEbD3HK/YZo+9cuEsF+t7J9moh2WpLdlMkPk+DTGkvvcFFbDs3h2CLV//j1c1yFt3JbTMY7YUzj2qZTXJmsnpJMYvA6S0nhqkznNZfHxuSP6GN9C/sJ1SCT6U7Vg==
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

