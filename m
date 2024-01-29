Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7D494C631
	for <ell@lists.linux.dev>; Mon, 29 Jan 2024 19:42:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706557350; cv=none; b=b/BAu/vKWYWlqUJs814yeZfZfjOfGPtyUWsj1e5kv7HywUs22duOnP9B44WaNs3av+u5UiaKTlZH1IgrqspWCz0YTEpl8Wav+hyjIcYj1cyBwEALBc/KukQUV5mwOAFUzpHUFjdegVp7gJbzFQQ6K0YJZ81MSjlLYsPJXHgTuiY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706557350; c=relaxed/simple;
	bh=ux3r4nTs20pYd4F8EanBionz0JPTBFCu2wHJRldk+sw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZQSmHaJzswkeF2bfhdwpjLgnCXpSMQhFBO1L58yndZ/ym5ogC4mmUkVLmJ1m60MkVwSQlx1wsDYIBfwHa05JmbXpSxM15dKPMdP+3FFngp2CCa0EZP7XUNRzWADIMhBhsDd0XEU0tr33p3Fj+RqODFriQXx2v0uXeU4gLH0OIi0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SSvRXJyq; arc=none smtp.client-ip=209.85.160.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SSvRXJyq"
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-214c940145bso1474281fac.1
        for <ell@lists.linux.dev>; Mon, 29 Jan 2024 11:42:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706557347; x=1707162147; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=7HSQi70AoannJuAQoAdEZ1HI6LdcgKf+0N0or9le8IE=;
        b=SSvRXJyqnzFvQl7YPEbVzrVadxibn9ZAW/KMAzVwVjdQla0V0pdSLP30MhQD3WhIv5
         h117tWUPEldTZ5KliJMrvZdX3m0Zl2FL1AYsXRiRlovFw3j8aoeHwJMpaKvwdIekkcwA
         OWFEuBaCgoYH5x4tIqsNIfXGIDrWOsEuRf0p+COL4IKrUAq43IfFdRzmzSU42iMfmYGO
         XkRHJmrqPavFYgemCBHwjUq1t/QlR3LXrM8fnAc3aAnX5f+Ayvbqnxu5+OmcoOYFWK28
         OiI1ONRQoVO6rbqst5YAU5hqwFOLynCtrLLs/7PjUqBuKZ4fWKYr/GCDycgOF7fs/jVx
         ojDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706557347; x=1707162147;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=7HSQi70AoannJuAQoAdEZ1HI6LdcgKf+0N0or9le8IE=;
        b=Zd5+sjvmYaUGgZesfEwGTvwyNNADNgsPXZVXORch/OUD8vXMwiEg5yt9RauLe0n9xX
         nVN83gzMeGRpZcduCNjP4GUGsFWpMQVNADeEN67F1UmT2aOmDt3eu7UoAE/J820/fGZg
         qbq6AWwZyojI0ReY7HytGbzRV7lYjFlUOW6Yz2ndhlbql5bFTFbqz2BfHW+uWX6Fy3Jf
         KVB/ulTinqa4AaD/Q75lgrPP/sOgk43bgujuyl/nrKAEJI30WDcPDHFymmbbTIKZvX/R
         5LtKnmbf7ULjyX1oafmR+IE5G6Dwf9Fih7PxeTsqNfGoOsh3JBI9hQgScSHK3xTIRQ0Y
         IGVA==
X-Gm-Message-State: AOJu0YyT8ufgV/dqWgykkJp8FwVoVZEGklyqz0PitI4+2or/SvYZdcK6
	7gMziWxOuBL7frrdvkhJe5q1yB5fX59JbIAf109en6PTPsUmLuw8RuWwXg2j
X-Google-Smtp-Source: AGHT+IHdUuyF2KhnGCMXeaYpp8fhTPvzfoKJXTjf135vKHqLauhEw21a1e+A8XhP2NGkJDLxJ2LNSQ==
X-Received: by 2002:a05:6870:c192:b0:210:c59c:dae8 with SMTP id h18-20020a056870c19200b00210c59cdae8mr3532075oad.55.1706557347488;
        Mon, 29 Jan 2024 11:42:27 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id e1-20020a0568301e4100b006e1164fdbc3sm1327850otj.73.2024.01.29.11.42.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 29 Jan 2024 11:42:27 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/2] file: Add l_file_set_contents
Date: Mon, 29 Jan 2024 13:41:37 -0600
Message-ID: <20240129194139.714209-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20240129194139.714209-1-denkenz@gmail.com>
References: <20240129194139.714209-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ell.sym |  1 +
 ell/file.c  | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/file.h  |  1 +
 3 files changed, 58 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 17acd40683e8..6ef885dd9d83 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -312,6 +312,7 @@ global:
 	l_dir_watch_destroy;
 	/* file */
 	l_file_get_contents;
+	l_file_set_contents;
 	/* genl */
 	l_genl_new;
 	l_genl_ref;
diff --git a/ell/file.c b/ell/file.c
index fb510d17fb4a..6f0a909f88e5 100644
--- a/ell/file.c
+++ b/ell/file.c
@@ -15,9 +15,12 @@
 #include <fcntl.h>
 #include <unistd.h>
 #include <errno.h>
+#include <stdlib.h>
+#include <stdio.h>
 
 #include "file.h"
 #include "private.h"
+#include "useful.h"
 
 /**
  * l_file_get_contents:
@@ -72,3 +75,56 @@ error:
 	close(fd);
 	return NULL;
 }
+
+/**
+ * l_file_set_contents:
+ * @filename: Destination filename
+ * @contents: Pointer to the contents
+ * @len: Length in bytes of the contents buffer
+ *
+ * Given a content buffer, write it to a file named @filename.  This function
+ * ensures that the contents are consistent (i.e. due to a crash right after
+ * opening or during write() by writing the contents to a tempoary which is then
+ * renamed to @filename.
+ *
+ * Returns: 0 if successful, a negative errno otherwise
+ **/
+LIB_EXPORT int l_file_set_contents(const char *filename,
+					const void *contents, size_t len)
+{
+	_auto_(l_free) char *tmp_path = NULL;
+	ssize_t r;
+	int fd;
+
+	if (!filename || !contents)
+		return -EINVAL;
+
+	tmp_path = l_strdup_printf("%s.XXXXXX.tmp", filename);
+
+	fd = L_TFR(mkostemps(tmp_path, 4, O_CLOEXEC));
+	if (fd == -1)
+		return -errno;
+
+	r = L_TFR(write(fd, contents, len));
+	L_TFR(close(fd));
+
+	if (r != (ssize_t) len) {
+		r = -EIO;
+		goto error_write;
+	}
+
+	/*
+	 * Now that the file contents are written, rename to the real
+	 * file name; this way we are uniquely sure that the whole
+	 * thing is there.
+	 * conserve @r's value from 'write'
+	 */
+	if (rename(tmp_path, filename) == -1)
+		r = -errno;
+
+error_write:
+	if (r < 0)
+		unlink(tmp_path);
+
+	return r < 0 ? r : 0;
+}
diff --git a/ell/file.h b/ell/file.h
index a93d8e9c27c2..f1ed8790fd02 100644
--- a/ell/file.h
+++ b/ell/file.h
@@ -13,6 +13,7 @@ extern "C" {
 #endif
 
 void *l_file_get_contents(const char *filename, size_t *out_len);
+int l_file_set_contents(const char *filename, const void *data, size_t len);
 
 #ifdef __cplusplus
 }
-- 
2.43.0

