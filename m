Received: from mail-oa1-f49.google.com (mail-oa1-f49.google.com [209.85.160.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D735B7B3FD
	for <ell@lists.linux.dev>; Tue, 30 Jan 2024 19:45:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706643943; cv=none; b=mO6HdRspKRYCN2hCNvr8ygr5TdWiEZZjrRTwFhC16nM55siynSmBzgu/kTWxWd5svaaOsoghdwrk7ONeDCEXtLCDR3MabW/WtChfoGDahpqTT23kc+6xXfMZ5HYDIH0/Gmq154lCq2AzJRbt7Posw1JBMwSmm1PwLGsQ99PL59s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706643943; c=relaxed/simple;
	bh=BDGCVP+ZTF0A5+a7Vz9LyZDfmfFW+Jp/rfBjp0j+ZAU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=TpV1qHdJSJeQ8GOnBY7qgMnOr5SYL5IBnwNj6J1bCKMu2il5PieAQlKOw2q1+hbfLL9b3T9Yj2uMjDxx37D3awAFL4corP0ERRP3SIfWGMb18jnwWAvGTCRC8OV8z2uIAMBbITF/h1+N+K9eoZHqbHxhkfZ4aBUu6p6Iz+fhpw8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lw3zSC50; arc=none smtp.client-ip=209.85.160.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lw3zSC50"
Received: by mail-oa1-f49.google.com with SMTP id 586e51a60fabf-204235d0913so2490519fac.1
        for <ell@lists.linux.dev>; Tue, 30 Jan 2024 11:45:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706643940; x=1707248740; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=uapj32PjUJi/xc6nJ2KcrfIUnG9JF8C6RrgWk4NsckU=;
        b=lw3zSC50MJiW4/CtkP67pqaBm+7W8tdjWFnFEtNIpPFhGRtVzo/h4ffBDZfoPaqMEK
         LGMXgp8+qmNee38eCizWnf6HmAXGdr8lzszE2JyALet49U0Mo3Hp7YkPcIyRMJH73YBi
         PCzXSBGYgr9oRMUIE+kYX8UpHQGDpZboKIDJlmYt6ONP8/WjDTgxlOewmNNh+yzondwL
         7VR6Nd9l/hjcOS4FnFhEOUUlQ9UmeYRQ/fj3VOj6l4xyWr9XOVfjJbztYrTL+nozrYhL
         aLvBAeOp+e2Yee1L0DVRXLeK+180aFd6bUnY8TXrXTYfZrPPuLBvgwo9GeOtYXgtFmcb
         PQmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706643940; x=1707248740;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=uapj32PjUJi/xc6nJ2KcrfIUnG9JF8C6RrgWk4NsckU=;
        b=EfsMcYI4skg6Ujr9G7pSKKREhyu9tJFjF//8aCBXVhtCNHFUOZ+sH90g/AduTkkWAI
         D9dUkGOU2WCcA3Pm2oai03BTuaSUTpFNUeTtiTiRME6HWt+J0UuYDyVmeT9oP9EEosBM
         /OV6fHH9EptuYPcAhF+6cIkP05i7pgucPX1fcjRioprEeVaRBxn+MhpTXToIx5iKaKGI
         RJG39ECzZrbpOKBEKYkXJT+4f/q9fBCSmWwMWe8OXT0he7ZE1Zrp7eFTNlM97YIBmN6J
         mfGUdlCc/DKT8ekzXkwsD+xeSDl37uP5NPo6kUce/Kbap42kQbZ8boZNxsk+yMyiq+YU
         Baog==
X-Gm-Message-State: AOJu0YxNyLZoaM0ySffKXiFnGrO/yy7kC+5D2Ed7b2c75MS7cUwkJy/V
	fCPjvUKCI7CHRfVSL8Tf6YzfzP4I/qHe23k8e7fX34/2BGgXXzJ4c84e7glb
X-Google-Smtp-Source: AGHT+IF5pyjcv4QtBLHzsLmFEMrdXwn89VbrNfaNiCy8WAGa3HCe4Dgt9HzZ+Bjo4DgF+uq9/U8r2Q==
X-Received: by 2002:a05:6870:1b83:b0:214:7ef2:ef7 with SMTP id hm3-20020a0568701b8300b002147ef20ef7mr8274410oab.18.1706643940658;
        Tue, 30 Jan 2024 11:45:40 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id ra21-20020a056871611500b00214d57a61easm2648440oab.44.2024.01.30.11.45.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 30 Jan 2024 11:45:40 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] cleanup: Promote _auto_ to public API
Date: Tue, 30 Jan 2024 13:44:29 -0600
Message-ID: <20240130194453.805041-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Move this out of useful.h which is not installed by default and requires
special build time hacks into cleanup.h, which is installed as part of
public headers / api.
---
 ell/cleanup.h |  6 ++++++
 ell/useful.h  | 20 --------------------
 ell/util.h    | 11 +++++++++++
 3 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/ell/cleanup.h b/ell/cleanup.h
index 337c8ad5d753..220240bdd4cf 100644
--- a/ell/cleanup.h
+++ b/ell/cleanup.h
@@ -10,3 +10,9 @@
 #define DEFINE_CLEANUP_FUNC(func)			\
 	inline __attribute__((always_inline))		\
 	void func ## _cleanup(void *p) { func(*(void **) p); }
+
+#define __AUTODESTRUCT(func)				\
+	__attribute((cleanup(func ## _cleanup)))
+
+#define _auto_(func)					\
+	__AUTODESTRUCT(func)
diff --git a/ell/useful.h b/ell/useful.h
index 5a4a5eba091c..a3d5ad916bd8 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -5,11 +5,6 @@
  * SPDX-License-Identifier: LGPL-2.1-or-later
  */
 
-#include <unistd.h>
-#include <errno.h>
-
-#include <ell/util.h>
-
 #define align_len(len, boundary) (((len)+(boundary)-1) & ~((boundary)-1))
 
 #define likely(x)   __builtin_expect(!!(x), 1)
@@ -64,21 +59,6 @@ static inline unsigned char bit_field(const unsigned char oct,
 	_x / _d;					\
 })
 
-#define __AUTODESTRUCT(func)				\
-	__attribute((cleanup(func ## _cleanup)))
-
-#define _auto_(func)					\
-	__AUTODESTRUCT(func)
-
-/* Enables declaring _auto_(close) int fd = <-1 or L_TFR(open(...))>; */
-inline __attribute__((always_inline)) void close_cleanup(void *p)
-{
-	int fd = *(int *) p;
-
-	if (fd >= 0)
-		L_TFR(close(fd));
-}
-
 /*
  * Trick the compiler into thinking that var might be changed somehow by
  * the asm
diff --git a/ell/util.h b/ell/util.h
index 5dfc35c89ea6..daec4024fdfa 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -15,6 +15,8 @@
 #include <endian.h>
 #include <byteswap.h>
 #include <sys/uio.h>
+#include <errno.h>
+#include <unistd.h>
 #include <ell/cleanup.h>
 
 #ifdef __cplusplus
@@ -437,6 +439,15 @@ int l_safe_atox32(const char *s, uint32_t *out_u);
 int l_safe_atox16(const char *s, uint16_t *out_u);
 int l_safe_atox8(const char *s, uint8_t *out_u);
 
+/* Enables declaring _auto_(close) int fd = <-1 or L_TFR(open(...))>; */
+inline __attribute__((always_inline)) void close_cleanup(void *p)
+{
+	int fd = *(int *) p;
+
+	if (fd >= 0)
+		L_TFR(close(fd));
+}
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.43.0

