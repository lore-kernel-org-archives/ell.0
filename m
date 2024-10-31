Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 707BC1A2562
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 20:26:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730406392; cv=none; b=FNrcNFoFRfbVPcR/dy7MuT8OUEObtxwZBBYIXLOVH3G8louzINPo/M1aYw4GX8RVyIYbh1Qmy5TyV109k0c0F27j1VaFnyCVHl210ibo2ngZtnjUaSYkZrM5aJSvAU6UEoMhk8pG2YlzPE2TKHrOPnjzcO2Cgibaa1uw3QLXHL8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730406392; c=relaxed/simple;
	bh=eExCDLRWnL7f3djdLgTxCPnRYFWJWOu1kwRrsxfYLYU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jXt9GxxFJuCi1ZLsUpmjtfgtLbmo8bEhU0ioRLk868PV0YpAY3i7kg2qTkQF4CyngMTngQo6eSL0Mey/fo7kXvELoWjlLIZ2sNJVsgXZ7A5v66vGjG3AtQQyT3rBl0Uz3SEliLpW9PjWnAL9J8cCc4tpuyrJoxexniRFk5weUzU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ihciixPZ; arc=none smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ihciixPZ"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-277e6002b7dso630359fac.1
        for <ell@lists.linux.dev>; Thu, 31 Oct 2024 13:26:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1730406389; x=1731011189; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=PxwnaxOFz4hmKVKtLA+35P45umGgN5wIsUSBwetIxvU=;
        b=ihciixPZ2gsLO2Ft+i1G7KrLM22KjLaNQ86+1EUCZJU/y/Mg8GqwNywIJqAq+8EFZz
         6cCgeoQjLa+puMzkHdvSdU0cJ9ts01Sj7KwOTs3AD+Js+moihEmTrNCGnsCgRFeeaCyi
         zhNmjS/WRvoIVhg9jvOU689avAK8pyNd+cQ4tYNc5pC4djZ5CIB9x/auO/tTToBpx7sd
         Yt4DlvjNOZ6Fo9DXoxAE4W3+pD/fIM/TObbaq2NEjx6oRLDP9eeejU2tKODdO7CS/qQr
         LLE6RGuJHEck6F3VCoolu3V2kZhsZ+r/SolkIcc6rTDrGCBakWOnuz4O7g6Rktjj3D1U
         /dMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1730406389; x=1731011189;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=PxwnaxOFz4hmKVKtLA+35P45umGgN5wIsUSBwetIxvU=;
        b=hsfi2SABhGI1DgbI85tPosHcwPTsZCv9wBxt3sRfGWl7wzRQGSfeRM5SrhbPBxTSD2
         JY9/sT7Xad85TQlblW4oqpxAoT3PINopdJh07NWwM5py2vAVqPT3ftHOdk+nVHzmRVRX
         fNVGAxk40ZG1yojqObJho4ypYqwCaqhH7IDVTrS6RwSOujf4a+WElhvOyXff6NgyBcXK
         PtmR0brlGI0CEZ+4ESl33RZx06uB35Gc2ThpZZqYjXGhJVfUs2s8dnUzzy8ljq0o5BVb
         jzi7kC+FkEP1uzHKUOlWhycLP80PElRHJzYYgOUz4nYTi83yJVOKYdoTGli9y2qGdq9z
         CXhw==
X-Gm-Message-State: AOJu0YzSP1eWsXr/mZItqPoPVEVn7mL3GanVdRt4C0jMkjDqSJQy3hHv
	5Rvl8iPm2nMARYhhW54KlXZxqQQrtqZRmXurYiIifX+onVHw3mEDN5feJA==
X-Google-Smtp-Source: AGHT+IGm04treFjmmpyDo8gAH2hKQaENE0v4lP1NEdG/6u0ZbtVhJ8BUmlU4/pHNLPOvtHmsKIVP8g==
X-Received: by 2002:a05:6871:5308:b0:261:1f7d:cf71 with SMTP id 586e51a60fabf-2949effac5dmr1229011fac.34.1730406389372;
        Thu, 31 Oct 2024 13:26:29 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-294874d6687sm712930fac.31.2024.10.31.13.26.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 31 Oct 2024 13:26:28 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 1/3] timeout: add l_timeout_remaining
Date: Thu, 31 Oct 2024 15:26:13 -0500
Message-ID: <20241031202627.1548592-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: James Prestwood <prestwoj@gmail.com>

Gets the remaining microseconds left on a timer. Microseconds were
chosen in order to be easily compatible with l_time APIs.
---
 ell/ell.sym   |  1 +
 ell/timeout.c | 29 +++++++++++++++++++++++++++++
 ell/timeout.h |  3 ++-
 3 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 00123136a527..af7395f3f1ae 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -529,6 +529,7 @@ global:
 	l_timeout_create_ms;
 	l_timeout_modify;
 	l_timeout_modify_ms;
+	l_timeout_remaining;
 	l_timeout_remove;
 	l_timeout_set_callback;
 	/* tls */
diff --git a/ell/timeout.c b/ell/timeout.c
index 4fc21a0854c1..541692ecff93 100644
--- a/ell/timeout.c
+++ b/ell/timeout.c
@@ -23,6 +23,7 @@
 #include "timeout.h"
 #include "main-private.h"
 #include "private.h"
+#include "time-private.h"
 
 /**
  * SECTION:timeout
@@ -298,3 +299,31 @@ LIB_EXPORT void l_timeout_set_callback(struct l_timeout *timeout,
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
+LIB_EXPORT bool l_timeout_remaining(struct l_timeout *timeout,
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
+		*remaining = _time_from_timespec(&current.it_value);
+
+	return true;
+}
diff --git a/ell/timeout.h b/ell/timeout.h
index 2db78d8fcd41..c0d463c1d021 100644
--- a/ell/timeout.h
+++ b/ell/timeout.h
@@ -34,7 +34,8 @@ void l_timeout_remove(struct l_timeout *timeout);
 void l_timeout_set_callback(struct l_timeout *timeout,
 				l_timeout_notify_cb_t callback, void *user_data,
 				l_timeout_destroy_cb_t destroy);
-
+bool l_timeout_remaining(struct l_timeout *timeout,
+				uint64_t *remaining);
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.2

