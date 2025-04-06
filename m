Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31D1022068B
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977542; cv=none; b=BO+3cBEK5Fk1pDMVPagjd0eNeNzVLE/tgL2gV/5KYbYgmh34vBnmIeejLfsnsgnRItnU6NCMQGvn178VtbTXKedwpB1wssQ9qwjvWJfK+/FTIUNNT5PNr2Xg9C2bfkn0URfJkGqJlvdrCvpJkPGU9CILirZUj5rNadio19vDJfM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977542; c=relaxed/simple;
	bh=jptL6KRnIjB0TN0f2Vlsrs2HGMs6lPiN/f2QCMTuVJE=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nJPCKnIc4XszWeMZ7whDVmqrKIDz1VUqdn75SEr+RhA1fafOfmPYHn1uJ0ZJtO4xpvMlUcKgFL67hqtt/T/Pv6K00s2nTkHD5r7mbllnDznh+SJIZvJJC/NWNe2MTKvMjhvJG8GZSrgEVzbEeiMsISMT4v0Z9Svj4nE+Uw1LLoE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=JL+EyXqU; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="JL+EyXqU"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 7B5461649AF
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:20 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 36EF31260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:20 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 8/8] edit: improve error handling of 'mbstowcs' and 'wcstombs' functions.
Date: Sun,  6 Apr 2025 15:12:15 -0700
Message-ID: <645e2d6dbe40ce23ce256199a6941605c568224d.1743977403.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743977403.git.gerickson@nuovations.com>
References: <cover.1743977403.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=XbMbbyqF5gXNXq8YdEUv5r8DO4HkwtVdVkj1Y7GyX78=; b=JL+EyXqUPSz2HkWVgFGI3wOlrbk8eseaLjDFMHs0D7srIoHpP3ZR7QVLZte3IHgPra/C3gdUdYHBLsIekSadRPLPrGCdMlZSpP38B/qlcv/MTnt7uadIxEwwyzHsQB9kwzLxeFs7sBFq+sR5RPQbEtlGBCSnyMVwLEnDlHlaJs9R+Hz+gGVTg/zdszcsnZrHqD+RJ75ymW1CQ+JCOB5xb3A3hh6bRZcuxyvNI64uOh7QL0N4T0UI1ufbVyZUW/TJ5LY/5dxpa5d7m2DJmJK3HFK3kUDdmPQCjiob6lsMXb+WjBWdYO4zTkOJl5tPEY2WalUWLXzBvC0eR38XOQkThw==
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
2.45.0

