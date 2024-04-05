Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8AFD217F8
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276420; cv=none; b=LLgZc4P/r64MTKW1lOjgNfLHlUOLXUGDYezz3e/YCkYnXjIf/4dRwHjjDCGJWFZM/6eRTRaLmqSm0iGXwaAzOhPts7OfoqrW5Lra9jw4eDJwC44Lqdgsw/yejwNVAiXjHqf1fQBwnwDqFoo4gyckIaWti/78CSXJbGUKgbNuMBk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276420; c=relaxed/simple;
	bh=80mp6916iE+3AkPWUz0Ur9Wbpw5y/adrofMVCYQ8r2c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HySMpditPv3wQBA7LSiaJfuHzahEWjUAY61WlsEeIJ47acRwtOBkeeBJMdyF4PUZ/CfdoZNgVfY1mpXOOATXuYNqVjfjkE+LqYxrlOV1XJfHMzYbxUXIItWABEv8O5nYJ7iClfo9jtp0p1/ZW51LPiYF/kUUUZa7bDqRnusQOoQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=mwfM3MiI; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="mwfM3MiI"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id DA9081649CB;
	Thu,  4 Apr 2024 20:20:17 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 80DBE124F66;
	Thu,  4 Apr 2024 20:20:17 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] edit: improve error handling of 'mbstowcs' and 'wcstombs' functions.
Date: Thu,  4 Apr 2024 17:20:11 -0700
Message-ID: <20240405002011.3480886-9-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=F4/jB31I4qqFfJ+4RuKRq1KaO3LlCMTdSoZ95lWKBec=; b=mwfM3MiI7G9F9Aow5Kr7UEGRINtxshcxAWAlpvgZk5Pl05ESL38t7zg9u1u5QqGmnOU/p5Ibrw5gsq11ZjW78o1bXiPd4YR0li721XdT4qgKXXzkeZhN5FCyF4c8STvPxo/Tfwer+qF6liad407o8Gs13+WvxeGTu+aDCdqWCInvC3jGBCsbZxTUsghX06clVj9d/1rr6bQoRNi2WSvbfNZNO+Mc7hipLRg4ZCEl3he7kupDsM29xue80O4LfYs0k8VsLeLbK4uZv8k+89p8ehZxJEq39aMihTxMylIdGib3l9O2W2WORoidGkrSkQ5QM9xJZpDYDyQr/9RAFrTA6g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

On error, the 'mbstowcs' and 'wcstombs' functions could return
'SIZE_MAX' when uncountering unconvertable character sequences.

Ensure that such errors are not obscured and are passed along to the
caller.
---
 ell/edit.c | 53 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 44 insertions(+), 9 deletions(-)

diff --git a/ell/edit.c b/ell/edit.c
index 6747f92e289e..5551ae52bfdb 100644
--- a/ell/edit.c
+++ b/ell/edit.c
@@ -104,10 +104,16 @@ static void reset_input_buf(struct input_buf *buf, const char *input)
 	if (input) {
 		size_t len;
 
-		/* Calculate the required size of the wide character string
-		 * including its terminating null character.
+		/* Calculate the required size of the wide character string.
 		 */
-		len = mbstowcs(NULL, input, 0) + 1;
+		len = mbstowcs(NULL, input, 0);
+		if (len == SIZE_MAX)
+			return;
+
+		/* Increase the size of the wide character string by one to
+		 * cover its terminating null character.
+		 */
+		len += 1;
 
 		/* If the current buffer is to small, then allocate a new
 		 * one and free the previous one. Since in most cases the
@@ -125,6 +131,9 @@ static void reset_input_buf(struct input_buf *buf, const char *input)
 		 * and then move the cursor to the end.
 		 */
 		buf->len = mbstowcs(buf->buf, input, buf->size);
+		if (buf->len == SIZE_MAX)
+			return;
+
 		buf->pos = buf->len;
 	} else {
 		/* Reset the main item to an empty string */
@@ -197,6 +206,7 @@ static void update_debug(struct l_edit *edit)
 	struct l_string *str;
 	char *tmp;
 	size_t len;
+    size_t status;
 	unsigned int pos = 0;
 
 	if (!edit->debug_handler)
@@ -218,9 +228,14 @@ static void update_debug(struct l_edit *edit)
 
 	buf = edit->head;
 	while (buf) {
-		len = wcstombs(NULL, buf->buf, 0) + 1;
+		len = wcstombs(NULL, buf->buf, 0);
+		if (len == SIZE_MAX)
+			return;
+		len += 1;
 		tmp = l_malloc(len);
-		wcstombs(tmp, buf->buf, len);
+		status = wcstombs(tmp, buf->buf, len);
+		if (status == SIZE_MAX)
+			return;
 		l_string_append_printf(str, "%3u %s\n", pos, tmp);
 		l_free(tmp);
 		pos++;
@@ -415,9 +430,18 @@ LIB_EXPORT int l_edit_enter(struct l_edit *edit, char **line)
 	/* Convert the wide character string into the multibyte string
 	 * representation like UTF-8 for example.
 	 */
-	len = wcstombs(NULL, edit->main->buf, 0) + 1;
+	len = wcstombs(NULL, edit->main->buf, 0);
+	if (len == SIZE_MAX)
+		return -EILSEQ;
+
+	len += 1;
+
 	str = l_malloc(len);
-	wcstombs(str, edit->main->buf, len);
+	if (!str)
+		return -ENOMEM;
+
+	if (wcstombs(str, edit->main->buf, len) == SIZE_MAX)
+		return -EILSEQ;
 
 	if (edit->main->len > 0) {
 		/* If the current entered item is different from the first
@@ -775,10 +799,21 @@ LIB_EXPORT int l_edit_history_save(struct l_edit *edit, const char *pathname)
 	while (buf) {
 		char *tmp;
 		size_t len;
+		size_t status;
 
-		len = wcstombs(NULL, buf->buf, 0) + 1;
+		len = wcstombs(NULL, buf->buf, 0);
+		if (len == SIZE_MAX) {
+			close(fd);
+			return -EILSEQ;
+		}
+		len += 1;
 		tmp = l_malloc(len);
-		wcstombs(tmp, buf->buf, len);
+		status = wcstombs(tmp, buf->buf, len);
+		if (status == SIZE_MAX) {
+			l_free(tmp);
+			close(fd);
+			return -EILSEQ;
+		}
 		dprintf(fd, "%s\n", tmp);
 		l_free(tmp);
 
-- 
2.42.0

