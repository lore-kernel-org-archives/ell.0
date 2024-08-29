Received: from mail-qt1-f182.google.com (mail-qt1-f182.google.com [209.85.160.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DB5418E348
	for <ell@lists.linux.dev>; Thu, 29 Aug 2024 11:25:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724930757; cv=none; b=S0j0QeugS8uOpDuyfFl9jYocvc6OHMolmlgblr3Y/r4LPIVVfqxVGyDlB4rIrJsaIaUtaUK5aRwq19WOVHnZX3yX53NH4aI/3h5HAJ1riknPEE5EJHagpUHcrSrQzgG9d9rV4TspHHJb791iFYNPvDoRAAmk2I0StcfnCEyNdBc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724930757; c=relaxed/simple;
	bh=Cm1Nvcxb2srp/ch8htOpmB5PL4pTnOHdxOUHrCQPN84=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=KfJDrD8LqaBmBCAHHCSKqF6RgBo+mugq5Kz7ooO2LdHtnOi+oGHIljDFrsxeZKjNdTITdBD+xM3LqXtjtOdZK8kRp5E6AV/o/yYCRHBigcBxBIBPQHBiMaSmP6w17Z8vBDsUHmBiAZDQ4vyr3EBEJK17ZFa1gKVKYkDLRLz35qc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=b9cObdes; arc=none smtp.client-ip=209.85.160.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b9cObdes"
Received: by mail-qt1-f182.google.com with SMTP id d75a77b69052e-45681098bbdso4471301cf.1
        for <ell@lists.linux.dev>; Thu, 29 Aug 2024 04:25:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724930755; x=1725535555; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Mn3zv3RrCXSdp8VmqcDHhcxAGYxRHRhA6W5lAk4jziE=;
        b=b9cObdesOWF0e62zl9K6wIrxxjSuRxd/y6KM7uIElGfs5LwIdRR3u3eIa7TMtX9lIS
         owxwLq39jcKW4xnovwKphjLJ7HIncNYFwxZ53GvZmYTKdN7vw1xmxmaOEzzm7xjliKD7
         J+YMmeIS0GSw5qpaeAhU/QGNPyzq/I5Aq4YdeuQCvYqSdkJmcJCuqpPVtubgf4GcYHZM
         V6bpKhDFZlgGDz7C7qUjiUfZGtrVhGVuTZbgeqCJr8wLPTUgCiVGGDKYfqFshEXYNwQe
         bf4eWWBCAnb/xAh+yle1h9cAcWdFqTuoo230laP5WEkUN1Llb7AN5QhPPRnHPopbuDlo
         q34w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724930755; x=1725535555;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Mn3zv3RrCXSdp8VmqcDHhcxAGYxRHRhA6W5lAk4jziE=;
        b=v/98ZKI2h97HP/j1xtNVOd61Zv7qAvUYX1CVtHArhWEyeLSZtNAJf86/qBpgCZ4OUq
         AbH5XD8hhNoBx9skGbTaf7xclHpOcTbANPr3gL183YG3LQ0V/ywiU1UMpPiiYwntO8Fo
         earX7OIflXkRbaDyGBui8YV2N/PNwj87tuDt1tk1Sp3zjk53BJ8HOW4WNLB5DQLW+SFb
         DVDiOFEknJ7tQzcRszP+oHGN4Z71QPR+MfEb9VEWpz8e0FvNSmxpwRt8I3GCbfZ+asLX
         R3bzR8wXNy0dE+fX+cy8WjaLM3cvMMuALu5M4pI9beCr3+/KmujBqDph5mlrw0xApWSi
         vQWQ==
X-Gm-Message-State: AOJu0YwZd+S8FNaNTSbiP8NmIKUmQDlEBB/lSshPFKY+a/YZ59hpmTK8
	VDvZhE1aTzT/+6FXwM8h25AgTqViN3zGMY1d5cmVfsrDqw670STPPrJQdQ==
X-Google-Smtp-Source: AGHT+IGTP2uLDeqiUJ8tSSiwZZvmSg1MxAj4jXAgzaq49wffZjLRPj9XVZ2E/jWEf1HMTmHbXKvlpQ==
X-Received: by 2002:a05:622a:4a:b0:43e:1231:1040 with SMTP id d75a77b69052e-456802c1101mr31338421cf.20.1724930754717;
        Thu, 29 Aug 2024 04:25:54 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-45682db5c50sm3969221cf.94.2024.08.29.04.25.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2024 04:25:54 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/2] timeout: add l_timeout_remaining
Date: Thu, 29 Aug 2024 04:25:49 -0700
Message-Id: <20240829112549.24935-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240829112549.24935-1-prestwoj@gmail.com>
References: <20240829112549.24935-1-prestwoj@gmail.com>
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
 ell/timeout.c | 29 +++++++++++++++++++++++++++++
 ell/timeout.h |  3 ++-
 3 files changed, 32 insertions(+), 1 deletion(-)

v2:
 * Use _time_from_timespec
 * Changed name to l_timeout_remaining()

diff --git a/ell/ell.sym b/ell/ell.sym
index c7dc9e6..b04ad63 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -526,6 +526,7 @@ global:
 	l_timeout_create_ms;
 	l_timeout_modify;
 	l_timeout_modify_ms;
+	l_timeout_remaining;
 	l_timeout_remove;
 	l_timeout_set_callback;
 	/* tls */
diff --git a/ell/timeout.c b/ell/timeout.c
index 4fc21a0..541692e 100644
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
index 2db78d8..c0d463c 100644
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
2.34.1

