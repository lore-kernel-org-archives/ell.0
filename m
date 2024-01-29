Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F76E4C61F
	for <ell@lists.linux.dev>; Mon, 29 Jan 2024 19:42:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706557349; cv=none; b=qcXo6Oj6VpZLWqtv83aQtUfHganM/bL3bZvRRoG+Qew4t79LIsbQGXvBBmo2BpxuBHUoREAUPKvT03eGjp44ief1/X8NpUAsuGL17frTghHoI0YMVDgSSJ5bUt9PpPkstCA2LfQbvse/81hJfG1Xq2ghwJvE7qr1h5U38RKurpg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706557349; c=relaxed/simple;
	bh=iXQXUa05zMSL1XhrD18wnoR5SRZGYeJZt59G7Mv5Rgk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=TWOzysbkP5BKb4GryLIIoLp8fAgHFMZ4HKbOwlgd8anJ/ngMsfsNPWPiWkQ6VRLWKYiJP25TflnM9qwgtDmEVdCJ/CZ3DgDPTCxuQcJ7j3LjWz1QexlwYZiDnHjcV5cSoe1VLsuuqqL6l0KVv90tKxZH5tYlHxdn6lX3RJPi/9I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nh7WTgYb; arc=none smtp.client-ip=209.85.210.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nh7WTgYb"
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-6e1226b30ffso748703a34.0
        for <ell@lists.linux.dev>; Mon, 29 Jan 2024 11:42:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706557347; x=1707162147; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=vpFd0FOMQX83VUTki9RI2CieTwVjnsnYF+4CAw4FZTI=;
        b=nh7WTgYbn0GQbptaI946y+T/9xQYnz/x5UsXCgoKa+rjaC1NTcFnrvbtIFEvsCElCo
         mWtRk5enj0n88nNL1dKFwFMwD9QNqRzHImnmWtFhSFaPIZoPSbS1CCmlZE6MMr4q2f0U
         ZOF9gjY6qPOhrc0RLtN1nuinGZlD5wTreeNqkcNw52CogO01viDe7PJUEQYNO198dZoV
         7Cbh7/m4aZTjDLLLLg2ZrqgLXcKuKz0PRvz2X7YMJqsDmLar+EEiBr/7U3xxC6yQzFtZ
         4e4DN2nghrHNJkzkDpaAO0EFcwevXUMtxgcx8KUa6sj+arLWQUROIUxapHXX1YO8GK9h
         QlwQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706557347; x=1707162147;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=vpFd0FOMQX83VUTki9RI2CieTwVjnsnYF+4CAw4FZTI=;
        b=onEV/FUsP/HvRlTzWdZOe7dYClKw5tDoLG96R08fn9Yz9YO+kyFuXTNdsdBRRaj8Q/
         fR5/AcVmu4rskuYED90yvvV7Oa3tlcedJ9VNlyQOhlwcPxtXZ9sFv7f71qlxA9rxb5up
         ZyZjbUqcGSd4wKlGMtAqAdHRdw7Bs74pgIiRHx4KpXiF3aosDnYJa0YYyZExX6MIOXJ9
         CDhAbSNdZsqSvG4vEcw/PQFVd00UtxQ2JVGS2CiAkgN4L2TSgTenI73uva0XxxHccmKL
         hTAAs09YxgSDWtqTe/JlI0HzAhikngo2Qv9n6/IlbrIupND2jK1KTwgE04BBDZV9SdhC
         37HQ==
X-Gm-Message-State: AOJu0Yw9e1YdDKlnl0M6nWFQoGnN5AXqkdaoCcAkx7I+Y63a0IigGKpX
	QrslM07TOUn4hJ1vk4LSLZdd74jMZ8h/c+uH5zm9gF21R2Glu4CNdxofqZEg
X-Google-Smtp-Source: AGHT+IG0VSnqv/mg3lLTh8+YyOBxqsn8FZJOGV9c5ZJwy2/NZkeE71NR5Yg1aOKy+RG0Rnx5bXRmxw==
X-Received: by 2002:a9d:3e17:0:b0:6dc:455:e923 with SMTP id a23-20020a9d3e17000000b006dc0455e923mr4799744otd.11.1706557346739;
        Mon, 29 Jan 2024 11:42:26 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id e1-20020a0568301e4100b006e1164fdbc3sm1327850otj.73.2024.01.29.11.42.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 29 Jan 2024 11:42:26 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/2] dir: Add l_dir_create
Date: Mon, 29 Jan 2024 13:41:36 -0600
Message-ID: <20240129194139.714209-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/dir.c   | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/dir.h   |  2 ++
 ell/ell.sym |  1 +
 3 files changed, 55 insertions(+)

diff --git a/ell/dir.c b/ell/dir.c
index f55382f82508..5f13f8afa0c5 100644
--- a/ell/dir.c
+++ b/ell/dir.c
@@ -15,8 +15,10 @@
 #include <limits.h>
 #include <sys/inotify.h>
 #include <errno.h>
+#include <sys/stat.h>
 
 #include "private.h"
+#include "useful.h"
 #include "queue.h"
 #include "io.h"
 #include "dir.h"
@@ -336,3 +338,53 @@ done:
 
 	l_free(watch);
 }
+
+/**
+ * l_dir_create:
+ * @abspath: Absolute path of the directory to create
+ *
+ * Attempts to create a directory tree given by @abspath.  @abspath must be
+ * an absolute path.
+ *
+ * Returns: 0 if successful, a negative errno otherwise
+ **/
+LIB_EXPORT int l_dir_create(const char *abspath)
+{
+	static const mode_t create_mode = S_IRUSR | S_IWUSR | S_IXUSR;
+	struct stat st;
+	_auto_(l_free) char *dir = NULL;
+	const char *prev, *next;
+	int err;
+
+	if (!abspath || abspath[0] != '/')
+		return -EINVAL;
+
+	err = stat(abspath, &st);
+	if (!err) {
+		/* File exists */
+		if (S_ISDIR(st.st_mode))
+			return 0;
+
+		return -ENOTDIR;
+	}
+
+	if (errno != ENOENT)
+		return -errno;
+
+	dir = l_malloc(strlen(abspath) + 1);
+	dir[0] = '\0';
+
+	for (prev = abspath; prev[0] && (next = strchrnul(prev + 1, '/'));
+								prev = next) {
+		/* Skip consecutive '/' characters */
+		if (next - prev == 1)
+			continue;
+
+		strncat(dir, prev, next - prev);
+
+		if (mkdir(dir, create_mode) == -1 && errno != EEXIST)
+			return -errno;
+	}
+
+	return 0;
+}
diff --git a/ell/dir.h b/ell/dir.h
index 8b786f9f36b3..3da4f82bdbb4 100644
--- a/ell/dir.h
+++ b/ell/dir.h
@@ -33,6 +33,8 @@ struct l_dir_watch *l_dir_watch_new(const char *pathname,
 					l_dir_watch_destroy_func_t destroy);
 void l_dir_watch_destroy(struct l_dir_watch *watch);
 
+int l_dir_create(const char *abspath);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index e12fd0e825b8..17acd40683e8 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -307,6 +307,7 @@ global:
 	l_dhcp6_lease_get_preferred_lifetime;
 	l_dhcp6_lease_get_start_time;
 	/* dir */
+	l_dir_create;
 	l_dir_watch_new;
 	l_dir_watch_destroy;
 	/* file */
-- 
2.43.0

