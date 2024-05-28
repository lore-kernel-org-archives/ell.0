Received: from mail-pj1-f42.google.com (mail-pj1-f42.google.com [209.85.216.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E983DF9D6
	for <ell@lists.linux.dev>; Tue, 28 May 2024 15:26:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716910012; cv=none; b=Hj4aPvhuK5BbIw/pTfz8ec/kWoXm1XYAIN+vwwR38mbXEnXXNAqMc/o8lGFBuS+GAzYtsvS89SWMlDHwj9RLjxzR/aKyhloOOLO3LEV/ul5ASqidnnqPUWkPhZJOW3vjbrBSkHrNvnFO4YO7KUcTE1W9CqEPobdF9ybCjk3jUfQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716910012; c=relaxed/simple;
	bh=vxzuQq3mCK2Uw3AhAZXs8l72Kkgrz961oAwQHh96ZXk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bSDvVq/I7e9b3fmzTOUguN8RFb3vzWz7cBpxR7VlHyBHd2blHSwlk033yQ0nCCmuRuWXjuc4J70ERt6wFmf9PzWh/yuaRYZNkREZeQjRtvyXxVYiSK2PfLytOp7JVYGjCrVqBLzuhRSns4ACwVn5Xk6Nx8YotQxIF/gXnpv6C6w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Z6M4NBhL; arc=none smtp.client-ip=209.85.216.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z6M4NBhL"
Received: by mail-pj1-f42.google.com with SMTP id 98e67ed59e1d1-2bdefdeb545so807137a91.2
        for <ell@lists.linux.dev>; Tue, 28 May 2024 08:26:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1716910010; x=1717514810; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=3ZDz5iP4GSbuQnI33OUeRKeTx8owuqob0fSVHSSF1Tc=;
        b=Z6M4NBhL6r9+0iMpOu7a9EUletBY927TSyI7YXcDXXXbm1cOHxeyt7QhiKtpsUvfIj
         esqlRZUqOhWBx5o3s229nojH5jKdbqbokonZ5QET4LvTmoOD9e0yFfJPIVIi+Vs0UDSe
         mps6lUDqxkRb6J1fqyEgqT5qjYYF6tS6Bw+v6zFJymRG96PrYGJgYP6ER4qLHRdfHVIT
         zx3J4IPEJqWNP1uCGYGi6dAOSEIDj1coZRmT4XoxBeN4E+xQRO9wtDsGcEuqrRXqxfmR
         03Re3mfkGIQmttpdsU0DitvkD6/EtlGSGtx/FPYn2qfwUtwZxsWRgjxs9aVwJwLgaV0/
         k/vA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1716910010; x=1717514810;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=3ZDz5iP4GSbuQnI33OUeRKeTx8owuqob0fSVHSSF1Tc=;
        b=Q8uRG1aFCtFJJFb+qS2zJWgmbCNDrrd/GcVCbTfFQPL3aDU+Dbedz36U8XY2QFI6kW
         shJihihEEaUjQ6Xi2nMWxazXqvJANQ4hYLbxvZVHdiBGfY5mMCX1CP18kzYpOcALjs38
         EJv024hRNXIYsAyHNOfrisqfzzi826DMBwaUBIwMDOb3Oofqiw8N8pywkk/xAWJl4RrZ
         h7o+lS8+bc+RH0KJyklbJ9LammwLGaKkTEoUyxCBeFwk+Ozr2L6uA5kWuGkdP0dLZtz1
         e1R7AR2iNXsQ98YyqzY0bTnkdMkOVUf8tSjaZIiK4g3G5D/TVYZcZ1Ou2oGO4dUsgldR
         HxPg==
X-Gm-Message-State: AOJu0YwwTaBjWCdllOutJp/ZmDul8zjbEvfFUo89wWXgPEIs5leVJ/Tu
	ZchMFCJqg4VU/9xwTepai9YCGWr72z53NczDLm0RNqufbEZIFpTaxm4blQ==
X-Google-Smtp-Source: AGHT+IH4tfeGN5w1zmOdOYBU/p3NiwuyKvEKQn+V2a+WDWIdQFZyPKPlw0SGdjz8/9qNv6lhkkdZHg==
X-Received: by 2002:a17:90a:c257:b0:2bd:edbe:4e1 with SMTP id 98e67ed59e1d1-2bf5f2080b5mr11813393a91.31.1716910009865;
        Tue, 28 May 2024 08:26:49 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-2bf5f612836sm7894923a91.25.2024.05.28.08.26.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 28 May 2024 08:26:49 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] path: Add l_basename function
Date: Tue, 28 May 2024 08:25:40 -0700
Message-ID: <20240528152542.168844-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Many ell based projects use the GNU version (obtained using #define
_GNU_SOURCE).  Unlike the POSIX version, this version does not modify
its arguments.  However, some libc implementations such as musl, only
provide the POSIX implementation.  Implement a version of basename in
ell.
---
 ell/ell.sym |  1 +
 ell/path.c  | 19 +++++++++++++++++++
 ell/path.h  |  2 ++
 3 files changed, 22 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 28b55d3..803906c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -434,6 +434,7 @@ global:
 	l_netlink_unregister;
 	l_netlink_set_debug;
 	/* path */
+	l_basename;
 	l_path_find;
 	l_path_get_mtime;
 	l_path_next;
diff --git a/ell/path.c b/ell/path.c
index 8004c2e..e5b7bcb 100644
--- a/ell/path.c
+++ b/ell/path.c
@@ -173,3 +173,22 @@ LIB_EXPORT int l_path_touch(const char *path)
 
 	return -errno;
 }
+
+/**
+ * l_basename:
+ * @path: The path to find the base name of
+ *
+ * This function operates similarly to the glibc version of basename.  This
+ * version never modifies its argument and returns the contents in path after
+ * the last '/' character.  Note that this will result in an empty string being
+ * returned when @path ends in a trailing slash.
+ */
+LIB_EXPORT const char *l_basename(const char *path)
+{
+	const char *p = strrchr(path, '/');
+
+	if (p)
+		return p + 1;
+
+	return path;
+}
diff --git a/ell/path.h b/ell/path.h
index 1f151de..5046dcd 100644
--- a/ell/path.h
+++ b/ell/path.h
@@ -17,6 +17,8 @@ char *l_path_find(const char *basename, const char *path_str, int mode);
 uint64_t l_path_get_mtime(const char *path);
 int l_path_touch(const char *path);
 
+const char *l_basename(const char *path);
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.45.1

