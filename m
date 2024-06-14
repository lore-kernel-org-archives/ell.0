Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com [209.85.160.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C3E616FF23
	for <ell@lists.linux.dev>; Fri, 14 Jun 2024 16:08:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718381331; cv=none; b=LDs99eew+UPz7fL9xGj4Tq1MECU5JKXKqzSqhauuEyCsuoUWFpM55JnfkwfPq3PBjYdIJ+gpWhvk5MAU6N371L0wGe2lTPghsfZZ5Y8WWoDmIaMcu2PGegIRUNbx1uCwj7kzh7Fb7iONhsr1DzWgd1L2A3N+LRwWYE4elZkORK8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718381331; c=relaxed/simple;
	bh=FlcKWnR/Csbm3Zo3ycBqko2qbfbd34Cmy7G/YTnjjL4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jA20H9SDK+IJV3x9FuvMn8XqNtXimU8AAbzMA0cqZdSwz0QemEaABOO869O25IOsJ4HkmCP2GuL551XgoFu8RTSc2AdLZKDzlzpSr0HiIjNbQH7fX2RDgJPCOI8Osv48Ov+LaVFlFO16ZI4yXT+CNp8xGKBD2B1XcSrHwVSio4w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WaMBQJb6; arc=none smtp.client-ip=209.85.160.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WaMBQJb6"
Received: by mail-oa1-f41.google.com with SMTP id 586e51a60fabf-24c9f628e71so1109051fac.1
        for <ell@lists.linux.dev>; Fri, 14 Jun 2024 09:08:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1718381329; x=1718986129; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=z8tQhbxVXB4nasvlzn9maRmSUbwucIlj/I0F/6eji6E=;
        b=WaMBQJb6wXYMj950zpl8kFvhjRVe5Q1B1Jm04Jmeh8Rif+lAn+AlE/v7cxo/AMLHTC
         FPBmCPzKXKDYTmIm11R0lfUKnHE1IkIZxnRhYiCjwc04JhE52y1jYMk5YvVsPipX1KqI
         6PsTVDLA6uSO66S0+yJRaDtcboQ2McgX5SjQ1CbT8A4aQAsglvuOCU2t9whOVtP8mLx/
         yAW3TTfNECmc/ws45Xy79D78AOBw9QQJMcZJ3v9Kqy7I6/uXLErMHcarrRWZ/i637pFT
         4IxtNVbGGdFlb2G/yiHtMVCkcTeIkfWRvv73iFp9moqw7Zo819PPNzauTSlt3sCu3vt5
         1YqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718381329; x=1718986129;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=z8tQhbxVXB4nasvlzn9maRmSUbwucIlj/I0F/6eji6E=;
        b=P+2FTldl3Aqzw/n+Oj9BnuXA/yeQNOoZ8SvF2BnJ9qJJzh/oPj6roirVpVaZnQgkvl
         ZvkFctPo4QDn7vRSDgjjlwLSbwIFnD2g1xE6U6CauezJQN0MwZYRAwleblf854u33/+t
         zHGeoTQt8zFghHDoK4pBCSUTsnmIF3incABkxwpp9q24HRTh1WaGnZDgt9pdSbLtenL2
         WufYMEnLzR26hRcsdP4CnfR6aSKmotzA+0b1j04YvYt4xqWt5vBb07dADVI5fzrYYLQ+
         kEQQa8JUsze00SAHYPFF5AJxtjczCV0hHK90fRECh2XmFGx7GCFgfC16jJUbrm9Pv+qm
         AMDQ==
X-Gm-Message-State: AOJu0Yxk87AuiKfYMUEXrP8D+nfnLUhK9dk5UWqpXxY5jFZ9B33zmvi1
	GYiRQb4sZzWq1SjJywhPZ1kX5D+ANhDiVE1zySlrsRPQPWnzItTCD6z/iw==
X-Google-Smtp-Source: AGHT+IHkagwNJKz27aNLQ8gu5+lsNHkI5ro8e8NofPBw8IzbFUWdhKR9Oux8pL99n7cHbf95h39hWw==
X-Received: by 2002:a05:6870:5707:b0:254:c08d:cb55 with SMTP id 586e51a60fabf-25842853596mr3233553fac.5.1718381329108;
        Fri, 14 Jun 2024 09:08:49 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-2567a94e8f1sm1022778fac.8.2024.06.14.09.08.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Jun 2024 09:08:48 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] sysctl: Add setter / getter for char settings
Date: Fri, 14 Jun 2024 11:08:36 -0500
Message-ID: <20240614160847.1085476-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ell.sym  |  2 ++
 ell/sysctl.c | 24 ++++++++++++++++++++++++
 ell/sysctl.h |  5 +++++
 3 files changed, 31 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0587beb398bc..9fcc3aad9a2f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -788,6 +788,8 @@ global:
 	/* sysctl */
 	l_sysctl_get_u32;
 	l_sysctl_set_u32;
+	l_sysctl_get_char;
+	l_sysctl_set_char;
 	/* notifylist */
 	l_notifylist_new;
 	l_notifylist_free;
diff --git a/ell/sysctl.c b/ell/sysctl.c
index 8b1b575e93a8..4ac569c34bad 100644
--- a/ell/sysctl.c
+++ b/ell/sysctl.c
@@ -95,3 +95,27 @@ LIB_EXPORT int l_sysctl_set_u32(uint32_t v, const char *format, ...)
 
 	return sysctl_write(filename, valuestr, len);
 }
+
+LIB_EXPORT int l_sysctl_get_char(char *out_c, const char *format, ...)
+{
+	_auto_(l_free) char *filename = NULL;
+	va_list ap;
+
+	va_start(ap, format);
+	filename = l_strdup_vprintf(format, ap);
+	va_end(ap);
+
+	return sysctl_read(filename, out_c, sizeof(char));
+}
+
+LIB_EXPORT int l_sysctl_set_char(char c, const char *format, ...)
+{
+	_auto_(l_free) char *filename = NULL;
+	va_list ap;
+
+	va_start(ap, format);
+	filename = l_strdup_vprintf(format, ap);
+	va_end(ap);
+
+	return sysctl_write(filename, &c, sizeof(char));
+}
diff --git a/ell/sysctl.h b/ell/sysctl.h
index b777eb5186f1..a1f9501493a5 100644
--- a/ell/sysctl.h
+++ b/ell/sysctl.h
@@ -20,6 +20,11 @@ int l_sysctl_get_u32(uint32_t *out_v, const char *format, ...)
 int l_sysctl_set_u32(uint32_t v, const char *format, ...)
 			__attribute__((format(printf, 2, 3)));
 
+int l_sysctl_get_char(char *out_c, const char *format, ...)
+			__attribute__((format(printf, 2, 3)));
+int l_sysctl_set_char(char c, const char *format, ...)
+			__attribute__((format(printf, 2, 3)));
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.0

