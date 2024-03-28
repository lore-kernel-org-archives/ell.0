Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11DE442A86
	for <ell@lists.linux.dev>; Thu, 28 Mar 2024 17:31:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711647080; cv=none; b=Zscz1nTF/bpZH3ycE8G9jp75L+u90fdCi/kUyHgGkBRDtINN49EKewoaGZO8KBMOkJa9isPESmjnzz01I5H51pnXb9XFP8UdqoOG10zXOXgHpBOnA/jHdlgzjEu384YZ/RiDlbPjHK5QOh/ofsDfHZ7W2lIJqYZBEZnA1vrj198=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711647080; c=relaxed/simple;
	bh=fx4+OiXo13SneMVcGPW3ESu2os8O7mkwv/oJtQVESPQ=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=eosvSFcJ4vwQjLb7Wd591nkshIw3YZhGSmtqYIcTTiP1pyYGbKbKg9qF08HA4F70h3EOW62SnPis+iQ3SUmU69P/UN9wy0VbqSd739Yn/GFAEIb419JC7U9HElUwfVkawV6QP7bWi7tVzF2RXK/aPry2IvHKreSXlOI+zJRz6Do=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=fRqNtmY4; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="fRqNtmY4"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 7ADC51649D1
	for <ell@lists.linux.dev>; Thu, 28 Mar 2024 13:25:48 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 19C3C124E93
	for <ell@lists.linux.dev>; Thu, 28 Mar 2024 13:25:48 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH] util: Add portable casting preprocessor macros.
Date: Thu, 28 Mar 2024 10:25:46 -0700
Message-ID: <20240328172546.123434-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=34IQnb0RKLJftF9aAd4tfQZcMUhn42qeurtofEIlKKA=; b=fRqNtmY4zJlTx6LyyOpHoTa1umygarZGKeL4WNF5kXl3ZY9KIMThECHe15N1coLeHhxf6v9Is3mpTvaflGqP/PzJwQDRXs+apimaNEc0//lW/qHOzCkH3oMYJUqoMBblEMmcTTSARRSYa/ATAsUeYcifY+YjSoRAgTSHZAe/HkK/OWI85UpZm/VsiforVNlX7nSq2GTnWSigC+99Oh/d25c7SsZaJpYIVbzpLZrFBIDpwkp8xZDFgPVHg2oLxvS9mnZruoareCyJK3J2EMTLQCMdrHjFHlbjF7A4vGdFpZ6t94nHWevV6sUmOrcOunKe8KWFSe4kv5cH0r9bqph5jg==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

ELL itself is a pure C source-based project and is compiled as such.
However, if ELL headers and interfaces end up getting integrated with
and compiled in a C++ environment, certain assignments within ELL inline
header functions may be flagged by the C++ compiler as errors or
warnings.

The added casting preprocessor macros are generally useful across any
source based that might want to leverage them from ELL. However, within
ELL, they should be used in inline header functions where such functions
may be consumed in either a C or C++ environment with a  towards
L_PERMISSIVE_CAST where possible. Since L_PERMISSIVE_CAST is not a cast
at all in C, it will not mask otherwise-legitimate warnings in that
environment.
---
 ell/util.h | 33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/ell/util.h b/ell/util.h
index 4ae03095d013..80b29b7bb6e3 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -43,6 +43,27 @@ _Pragma("GCC diagnostic pop")						\
 		r;							\
 	})
 
+/*
+ * If ELL headers and iterfaces end up getting compiled in a C++
+ * environment, even though ELL itself is a C source based and is
+ * compiled as such, certain assignments may be flagged by the C++
+ * compiler as errors or warnings. The following portable casts should
+ * be used in such cases, with a preference towards L_PERMISSIVE_CAST
+ * where possible since it is not a cast in C and, therefore, will not
+ * mask otherwise-legitimate warnings in that environment.
+ */
+#ifdef __cplusplus
+#define L_CONST_CAST(t, v)       const_cast<t>(v)
+#define L_REINTERPRET_CAST(t, v) reinterpret_cast<t>(v)
+#define L_STATIC_CAST(t, v)      static_cast<t>(v)
+#define L_PERMISSIVE_CAST(t, v)  L_STATIC_CAST(t, v)
+#else
+#define L_CONST_CAST(t, v)       ((t)(v))
+#define L_REINTERPRET_CAST(t, v) ((t)(v))
+#define L_STATIC_CAST(t, v)      ((t)(v))
+#define L_PERMISSIVE_CAST(t, v)  (v)
+#endif
+
 #define L_PTR_TO_UINT(p) ((unsigned int) ((uintptr_t) (p)))
 #define L_UINT_TO_PTR(u) ((void *) ((uintptr_t) (u)))
 
@@ -381,8 +402,10 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 static inline int l_secure_memcmp(const void *a, const void *b,
 					size_t size)
 {
-	const volatile uint8_t *aa = a;
-	const volatile uint8_t *bb = b;
+	const volatile uint8_t *aa =
+		L_PERMISSIVE_CAST(const volatile uint8_t *, a);
+	const volatile uint8_t *bb =
+		L_PERMISSIVE_CAST(const volatile uint8_t *, b);
 	int res = 0, diff, mask;
 
 	/*
@@ -433,9 +456,9 @@ static inline void l_secure_select(bool select_left,
 				const void *left, const void *right,
 				void *out, size_t len)
 {
-	const uint8_t *l = left;
-	const uint8_t *r = right;
-	uint8_t *o = out;
+	const uint8_t *l = L_PERMISSIVE_CAST(const uint8_t *, left);
+	const uint8_t *r = L_PERMISSIVE_CAST(const uint8_t *, right);
+	uint8_t *o = L_PERMISSIVE_CAST(uint8_t *, out);
 	uint8_t mask = -(!!select_left);
 	size_t i;
 
-- 
2.42.0

