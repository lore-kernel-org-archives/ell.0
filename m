Received: from mail-pl1-f171.google.com (mail-pl1-f171.google.com [209.85.214.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CF0D168486
	for <ell@lists.linux.dev>; Wed, 28 Aug 2024 16:43:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724863431; cv=none; b=FlD/0r4zBhIjFk1R+4HkFVMfEZOEpxP3KrLP8tyP5PERzSWdycr90T/U5iF5M0srd4kXMYCctaAawQYimII9R3PmLGbMZoVHZ0KG3utOhhm8ZvqG2ZqESoPiMoTkR1NxFNBy0g6G/fwxw/uUhnjiEdQoFiJK2r8cuKzQGuzJlx4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724863431; c=relaxed/simple;
	bh=XxDKAQzsrAVNN1aChVyXD1qgrd37g660a8V0Dwyw190=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=sSTOmk6gxDOBW7quhJXdbTY+lmQJ7wtNgk079qsNLjVdVUQGfkPePQDAPoTgC8MEYlIMc7MGEQsQhXQSy6ofA/ZBzHqdvImpFkudGXZ31xd+4lWGJnYKXrIjxuAf4c+yYe0Cz3O6TNgmI7ZAMxBizwM0MMnIqr0gl5dNiMUZp4Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NCNXa/p9; arc=none smtp.client-ip=209.85.214.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NCNXa/p9"
Received: by mail-pl1-f171.google.com with SMTP id d9443c01a7336-201d5af11a4so62755085ad.3
        for <ell@lists.linux.dev>; Wed, 28 Aug 2024 09:43:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724863429; x=1725468229; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=TdxSLkTm23jmYKNjI/HZqVTVkDbXI5AZ3Q2Hn58Ljk0=;
        b=NCNXa/p9dpwEyW0XMu8iFo0ix10SHqY0x5jVinRyC0VvfiuLGghZk1CEoHi9pAkyZ2
         BAHiGukp6gefHFosjR7YXOav+y6E7k9vsgWL36y3gYotngzrEB66tWeKEfYBRg4CqOdn
         Cln/3rz3TI425TTJ7Eoyo1LbE/fcN4+PPHSdTafMX+CHrYLAnmfkIN03vpuoBdWEMmR8
         yx4rfTrpxzWJ7HBkn7hAarak7kzXO56SYU/6xXaoSzU5I20AiqMG42wH8w+muUMh2sW8
         vPLGZGFNuoXrZQ7HED6aMreRDuxooy+HPlXFuTjgouieOzjm88rUhJVo66I9OM4B1Qjc
         ew6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724863429; x=1725468229;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=TdxSLkTm23jmYKNjI/HZqVTVkDbXI5AZ3Q2Hn58Ljk0=;
        b=Rk4Gf3V6IHZrn8xnKHBw5TwbrNLkF3y/X5evdrjRhcjo+80CHnE+9VE5/wIoY1Vzme
         ZISqBX3LSRnvxTSq4ZaGVQcHoGQ1iZiQ2W0P0qLL28H+slwIYPD+dz+Ov1hTgo1dAr7u
         PDPyJRxFyzK9A/PGc/GGj/vjnYDMRM2mfGyKAJx4soELWtt1tTvkRfo5IToKzvCZ5qTC
         wmNGBhnuQXBYpLtSrEjCFW3PtJWVlv2N+QohVNL90BSjvt5AO1Lj++CPX64Zm8UVo4BB
         q2t2bwVNdBstzOwmcssNCVRzn6R2lib2wKcGohruA2kd6m/gQYvLiivzVPihG1ASD08v
         agAw==
X-Gm-Message-State: AOJu0Yxman02SkNQyl2cpU+TmQbPg6xeCsqPpa6HRWaOR6kI8FFAYcoT
	lT/cMbjJIhY+594IaoohCRBbr4cA5LeAJYNz/XdF24Lwe8y3wu1xHHgsDQ==
X-Google-Smtp-Source: AGHT+IGwu2td9In7C0CwZxWQI5VPLDzNfvdIQz4LdFujhf3XTMBnPd4NzBRyRxFWBeKeHC+aw6Mduw==
X-Received: by 2002:a17:903:191:b0:202:60e:7700 with SMTP id d9443c01a7336-2050c235d61mr824135ad.7.1724863429041;
        Wed, 28 Aug 2024 09:43:49 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-203855dbf84sm101335135ad.167.2024.08.28.09.43.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 28 Aug 2024 09:43:48 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] timeout: add l_timeout_get_remaining
Date: Wed, 28 Aug 2024 09:43:41 -0700
Message-Id: <20240828164341.875578-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Gets the remaining microseconds left on a timer. Microseconds were
chosen in order to be easily compatible with l_time APIs.
---
 ell/ell.sym   |  1 +
 ell/timeout.c | 30 ++++++++++++++++++++++++++++++
 ell/timeout.h |  3 ++-
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index c7dc9e6..759a84c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -524,6 +524,7 @@ global:
 	/* timeout */
 	l_timeout_create;
 	l_timeout_create_ms;
+	l_timeout_get_remaining;
 	l_timeout_modify;
 	l_timeout_modify_ms;
 	l_timeout_remove;
diff --git a/ell/timeout.c b/ell/timeout.c
index 4fc21a0..220b2df 100644
--- a/ell/timeout.c
+++ b/ell/timeout.c
@@ -23,6 +23,7 @@
 #include "timeout.h"
 #include "main-private.h"
 #include "private.h"
+#include "time.h"
 
 /**
  * SECTION:timeout
@@ -298,3 +299,32 @@ LIB_EXPORT void l_timeout_set_callback(struct l_timeout *timeout,
 	timeout->user_data = user_data;
 	timeout->destroy = destroy;
 }
+
+/**
+ * l_timeout_get_remaining:
+ *
+ * Get the remaining time for a timeout in microseconds
+ *
+ * @timeout: timeout object
+ * @remaining: microseconds remaining on timer
+ *
+ * Returns: True if successfully got remaining time
+ *          False if failure to get remaining time
+ **/
+LIB_EXPORT bool l_timeout_get_remaining(struct l_timeout *timeout,
+						uint64_t *remaining)
+{
+	struct itimerspec current;
+
+	if (unlikely(!timeout))
+		return false;
+
+	if (timerfd_gettime(timeout->fd, &current) < 0)
+		return false;
+
+	if (remaining)
+		*remaining = current.it_value.tv_sec * L_USEC_PER_SEC +
+				current.it_value.tv_nsec / L_NSEC_PER_USEC;
+
+	return true;
+}
diff --git a/ell/timeout.h b/ell/timeout.h
index 2db78d8..b9735a4 100644
--- a/ell/timeout.h
+++ b/ell/timeout.h
@@ -34,7 +34,8 @@ void l_timeout_remove(struct l_timeout *timeout);
 void l_timeout_set_callback(struct l_timeout *timeout,
 				l_timeout_notify_cb_t callback, void *user_data,
 				l_timeout_destroy_cb_t destroy);
-
+bool l_timeout_get_remaining(struct l_timeout *timeout,
+				uint64_t *remaining);
 #ifdef __cplusplus
 }
 #endif
-- 
2.34.1

