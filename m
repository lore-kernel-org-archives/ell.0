Received: from mail-oa1-f49.google.com (mail-oa1-f49.google.com [209.85.160.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0EBC51649BE
	for <ell@lists.linux.dev>; Thu,  1 Feb 2024 15:18:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706800721; cv=none; b=iKz66CHSBnqbC3aKIoWVuQ9r4x7Iv8f3Pn17EvA5MUqmQZNGj9h5SEp6Z3cmuOQNOZhnf1c5mnbKu+qkzE8CehpTMKeHnOZKM/uZzULwhUsqKZGctaaYazckCefbGEfBWAANcVBOv/JvPDYQJ24dPCye8axie/2hBIeHpdIjPZ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706800721; c=relaxed/simple;
	bh=8AmGOrxF5BJKtp6H6Muu441eLF+YwZwWk+YEoILDZyk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=SJqws+U2ZO5WiWRnigryevYyhUOnlxI53TmmTsbejZxQNFNqGcJO/8RSmkmKsUn49oCHwRgcw8DnFRxH5LOXr1H0ya7n6mrabku2JCkoivIjL3kHBWcrLC0fTM1d3/DvPE+HXxg467XCXcDc4y3Cg6gXaAAaOSjgFiM3mpPNwak=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=I3RCHi7P; arc=none smtp.client-ip=209.85.160.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I3RCHi7P"
Received: by mail-oa1-f49.google.com with SMTP id 586e51a60fabf-218dd3fdb7cso565996fac.2
        for <ell@lists.linux.dev>; Thu, 01 Feb 2024 07:18:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706800719; x=1707405519; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=ioTtzmBOSMPWiRFt+shKVv+FPLdllL79t9aczybFkMk=;
        b=I3RCHi7PWdw+NXrw/8E6JREo3NWaFIvI7/53JlVV1DHNTb5PYszMrKx6yGzOZidJgw
         5bCLOqlM0guCffRJdErmk5DqVLliT5n8+mPjvc+8wX9M1jcO1/r/8LIAsKE5H4/Qt1/+
         k4ohqNds/c9P5MACcePW+qG8DtoxPJmEGHt6VAy67u9AQGq22rn75IojugO3sW0UiMnJ
         LK+crv0+zLafAVPAMPb1312s6B4FouOQnehCHkGhKF0Q/fegt9RqxoLSj38IyL4HxXi6
         4Tezj74jwdq3EJWK0fITDmRvkrEUVpms5i1P2WtAXlQpHMEdYrdQHfeRWTHZLAHDnqjP
         G6bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706800719; x=1707405519;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=ioTtzmBOSMPWiRFt+shKVv+FPLdllL79t9aczybFkMk=;
        b=JPTCTDudGL5qIrXHjmonJYevB/xxZvm59V82uaYHAC7L3tmGHU/d9oKTeNj5BLgy8z
         tLc+w7cZgPoRoHMxcZnhSvGpYpiWnH8Wyt1S2hx2puwVzWwuC75auBzF8LdVB3Q0W7Ri
         UJQC7t859ooENozO2CJxf6XiCqkey2nymeZHkl3QfhfSsJjQEG95ZozdiAdTEd0UwBei
         rx3K8gCTqtyVez7uvbm8eUS2GTZiSVSeLeaoH0CBowD804sXSZRFSrgAFk+d8IG1YTls
         IanBL9jksrAmgkKJJIhcSsnSX4OeT2Po7sFclrTSxziJJvIbbcx2svWhVbY2gt/ofH7h
         ORqw==
X-Gm-Message-State: AOJu0Yxa4jH7EIknkom01BDG9MQfEo+yPzfE5gBYCqfZge8cGtTTsXt6
	itOTr6596mx9/hiciz7UOJG73pifuFT7wDRtr6xUFlXS8MiArfgmJpFoNqU4
X-Google-Smtp-Source: AGHT+IF1LMNYnOH+H3NRlpYiikBWxlmrQc8KbpE4/46tQ65w54Rb4n8HPa89Zpq24LmXUpyt9jlrDw==
X-Received: by 2002:a05:6871:89e:b0:218:58d5:d102 with SMTP id r30-20020a056871089e00b0021858d5d102mr4976416oaq.52.1706800718801;
        Thu, 01 Feb 2024 07:18:38 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id e12-20020a056870450c00b00218496d80b7sm3153326oao.29.2024.02.01.07.18.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 01 Feb 2024 07:18:38 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/2] useful: Move close cleanup into ell/util.h
Date: Thu,  1 Feb 2024 09:17:33 -0600
Message-ID: <20240201151751.880279-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/useful.h | 14 --------------
 ell/util.h   | 11 +++++++++++
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/ell/useful.h b/ell/useful.h
index 5a4a5eba091c..8a4bf2ce70c9 100644
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
@@ -70,15 +65,6 @@ static inline unsigned char bit_field(const unsigned char oct,
 #define _auto_(func)					\
 	__AUTODESTRUCT(func)
 
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
index 5dfc35c89ea6..db86bfe278ea 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -14,6 +14,8 @@
 #include <inttypes.h>
 #include <endian.h>
 #include <byteswap.h>
+#include <unistd.h>
+#include <errno.h>
 #include <sys/uio.h>
 #include <ell/cleanup.h>
 
@@ -314,6 +316,15 @@ const char *l_util_get_debugfs_path(void);
        while (__result == -1L && errno == EINTR);  \
        __result; }))
 
+/* Enables declaring _auto_(close) int fd = <-1 or L_TFR(open(...))>; */
+inline __attribute__((always_inline)) void close_cleanup(void *p)
+{
+	int fd = *(int *) p;
+
+	if (fd >= 0)
+		L_TFR(close(fd));
+}
+
 #define _L_IN_SET_CMP(val, type, cmp, ...) __extension__ ({		\
 		const type __v = (val);					\
 		const typeof(__v) __elems[] = {__VA_ARGS__};		\
-- 
2.43.0

