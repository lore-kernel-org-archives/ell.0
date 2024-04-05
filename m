Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6908E632
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276420; cv=none; b=Wc9fwvq82tX0AVKXwgKbVW99G9QvEgmfkT0WfPv5eHrKnvI/pM3AdxrMVdTSjrPR61OV3uisyX0ZRVVlIIJItsRfsHfZDA58GHp2xyKAvUxHzgd31lbzaaB3lMSzqNNyIASEgfgPxz6/PIbujjrTO7LTP2XSF8B+HLvCr6HReCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276420; c=relaxed/simple;
	bh=xA8GPXbqGBIwHePSHGaXXRd0puDol4M/vE54tSVkTDs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Wz+Hzaq/NmpWda4neXMr7HlkTNpWY8IDYBJ8mzZ0B7l/sjxXzJ6zmGlSotKqW0Oq3qs7LHOB+GIzfyf5y/bjT7uyBjTa4coWBF1vZc6gzzZswsf+kgx9RQFwIU5a9YYFAJB3jhigzThGz0OaskjI6Juw3dxqTt+4fdnQstmu1Ck=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=dHHmtyjj; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="dHHmtyjj"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 5C4211649C8;
	Thu,  4 Apr 2024 20:20:17 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 01AFF124F66;
	Thu,  4 Apr 2024 20:20:16 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] edit: change the 'l_edit_enter' return signature from 'char *' to 'int'
Date: Thu,  4 Apr 2024 17:20:10 -0700
Message-ID: <20240405002011.3480886-8-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240405002011.3480886-1-gerickson@nuovations.com>
References: <20240405002011.3480886-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=0kirP3mNY/QozfXnzqXT68eabXHYamQa2cbRuI7MTsE=; b=dHHmtyjj/jYR1HD5no3T4RE5HHWdeGf0VxrquEm1XE6c/ElX4I9WPU9YUFaSgxpxOnfRKLv6NMFwgqmxtviZSscpEd0FRS5DGr9b8p/vWoXwcNO/XAD8tcvntFIFFS0dg7bBEWrmZs52iBc8SlR3ga1DYQyf+lQnE3Fs2WPqGAIpAxVlPoRwn02E60lr0r25SWs3yNj9fKBbTMszVwB2ySSK2gpRv774XCDax8EBfOhd8Ny/WGkcKuOleFKHmidi1j8HPMVLQ7jGcjK4bR3wURyFVaoTTR9ULUJn0Mm9thpX1gwstqxGDaZAvoC2rFl8VFpV0kqhGt+FbwaMgwYHlw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Using an 'int' signature with 0 for success and < 0 for failure with
failure enumerations sources from the negated POSIX errors from errno.h
eases system integration by precluding system integrators from having
to synthesize their own errors on the prior 'false' returns.

In addition, this sets the stage for better error handling of the
'wcstombs' and 'mbstowcs' functions.

The entered line is now returned via a return parameter.
---
 ell/edit.c | 12 +++++++++---
 ell/edit.h |  2 +-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/ell/edit.c b/ell/edit.c
index d6329d063c78..6747f92e289e 100644
--- a/ell/edit.c
+++ b/ell/edit.c
@@ -403,14 +403,14 @@ LIB_EXPORT bool l_edit_is_empty(struct l_edit *edit)
 	return (edit->main->len == 0);
 }
 
-LIB_EXPORT char *l_edit_enter(struct l_edit *edit)
+LIB_EXPORT int l_edit_enter(struct l_edit *edit, char **line)
 {
 	struct input_buf *buf;
 	char *str;
 	size_t len;
 
 	if (!edit)
-		return NULL;
+		return -EINVAL;
 
 	/* Convert the wide character string into the multibyte string
 	 * representation like UTF-8 for example.
@@ -458,9 +458,15 @@ LIB_EXPORT char *l_edit_enter(struct l_edit *edit)
 	}
 
 	edit->main = edit->head;
+
 	update_display(edit);
 
-	return str;
+	if (line)
+		*line = str;
+	else
+		l_free(str);
+
+	return 0;
 }
 
 LIB_EXPORT int l_edit_reset(struct l_edit *edit, const char *input)
diff --git a/ell/edit.h b/ell/edit.h
index 811246578894..425039733ad0 100644
--- a/ell/edit.h
+++ b/ell/edit.h
@@ -36,7 +36,7 @@ int  l_edit_set_max_input_length(struct l_edit *edit, size_t len);
 int  l_edit_set_history_size(struct l_edit *edit, unsigned int size);
 int  l_edit_refresh(struct l_edit *edit);
 bool l_edit_is_empty(struct l_edit *edit);
-char *l_edit_enter(struct l_edit *edit);
+int  l_edit_enter(struct l_edit *edit, char **line);
 int  l_edit_reset(struct l_edit *edit, const char *input);
 int  l_edit_insert(struct l_edit *edit, wint_t ch);
 int  l_edit_delete(struct l_edit *edit);
-- 
2.42.0

