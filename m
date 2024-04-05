Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85DA7639
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276417; cv=none; b=hyAtYDjMIuvBtdVHf6kd9xf597+ANrgzhEhnaFIXUrkAlY8FCGmpYEqb+K65qVnT4Z8AuJzjDBJiIk5V5RuXpnvO5kqsxpZXdcnBZEJagnWWKY0CPYsui/TAZwe47mSdT82uEFvZWnKKym9PKKirRAHyde4hwLN0+bKFjPfDkSo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276417; c=relaxed/simple;
	bh=/VZT5OWfzehRrwsK7Pld/7Ea1f5YhealQ3rG0Yt/dn0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BYd0dUTs6afs+tNzXcTszx+mutm976xmmrrhVl+dN4vLSEgjX6QgV4QZ9W86ShqOt2QPYn6JiBjuvGsZ4lnejOM3XyQYOYieA1f8EEoSR8W5iEr+MVIC8/VPBtp90ub6Ltx2Sr7HGsOfzMnndgjpRnZDbOV82jsEwtRgToPf+Tc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=naghZlyM; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="naghZlyM"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 936F01649CB;
	Thu,  4 Apr 2024 20:20:14 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 154ED124F66;
	Thu,  4 Apr 2024 20:20:14 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] ell: Add include directive for 'ell/edit.h'.
Date: Thu,  4 Apr 2024 17:20:05 -0700
Message-ID: <20240405002011.3480886-3-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=pAWAL268wdeu4GPd31FExdbZgfZ/ORz5kDPbplj4CVk=; b=naghZlyM9mOplj5YHPNMAgGpMhH+cPD4N9n93lj6LNVWZZNDsO6nRdZ689c+DtOJY1hNZBN2OQMK57gepilm6Kd1H5yY0OPAsF/AA96ZmQydyXV06lZHPlPcUsm+yXBuGvZqRxcmFjjrVuZBxWkDFRAFK0zfPKJdmVxveE2kgIbz4TlchAopTjI9rL9vIV1ME1kw4qtU1YZjaqAR+0kz/OPpbDVgok8vHNDM2CmfDC5SJXlUbA1sKVmjyBX3xtpvIWH8TGJHLqgykJ0Nt16KvADKgMBx2tj7imxuXVvdEVao9pr3chQJjf+km7cXkgFzxh84S6eQrvISyBV01Rkwmw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.h b/ell/ell.h
index f67339105e8f..875bbb2cd43f 100644
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
2.42.0

