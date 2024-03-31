Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA38C147C7C
	for <ell@lists.linux.dev>; Sun, 31 Mar 2024 23:47:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711928864; cv=none; b=ge0UXGDUz2+j7CoA4XgLjdj8na7BJknw9dy/7z4sHRMX2nBcbmvoZo7QbnLre68JM8PHSs2eJUduM3usekz5Mw1F6A4NrxraSan3RASvNZ3G1dN8I45hQot143Bpe5LFmH/AIcA5WZCRQkyYgOCCJ0c55zjwnMrbfF1Xgn11iCs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711928864; c=relaxed/simple;
	bh=iZ/RA8XVoPeKVnzjVCnulrf8rQ6LZt9cF/0nP7kLDbY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ff40sPGW5x0ZXgqsvlD8pr9zw9b+XJqp338g1B5Zoi8wxQX9EJHDSAUelXsl/kaVeaO2mWvjjJN5NdtyLcsXyyPiF3RwiweNIDLqyadLEjkPc2Dbq4tD+RbIEKwdl3Cw/BTzmm69jE3CwKDQUyHOji/Ei7HbzeCXlNGQlXcp2CI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=gszBOIaB; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="gszBOIaB"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id A9C861649C8;
	Sun, 31 Mar 2024 19:47:40 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 48D3A124F8E;
	Sun, 31 Mar 2024 19:47:40 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
Date: Sun, 31 Mar 2024 16:47:36 -0700
Message-ID: <20240331234737.2452696-4-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=A4lGAn0XrWXIA8QFoY7e4UOgcDitezEd7I5VUnfs1sQ=; b=gszBOIaBLGsxiuc3s3hqFZQiqhRRZd27Y2gPLH/IYj+LsfpsbglOv65Nkuq3vJwDZ0Ommt4jQQvXvY9Js2xj6dbtLfDV7ukUyXK+pEbMqMycmrRedqMhxU+2DTsQYjZtmjI6QRPTGPCjFg5TIWRu08rLK0Ei2MXbUHiHu9UYd12KzljwVSIzpC3YQHSItoSEC4D4PVAVIFYtmkGnDWVXOZgZbVSG8Q1a8d1Zz/qPOL8Nz45s8kd4N3b5Nvei/iIaxepBe3bE7i23NVNnWYsefeNricwjSis8T3fUwePARqau4J+Wt40S+tVC0qmjYnseFNDOClEbML3axXVxqxPS3Q==
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

