Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02F5621D583
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977542; cv=none; b=SyBvUlgSPvY20DpNBRzwSfra7gVHIOtwdGFQuU2ecOZMwPT+iOxG5GoHmnDJrfEM6JPegnNsi323QiVT0hC3qA4WeXUA6vSTN6hwx9ynrbW3jCux02cc/rdxrt1NRau4e07itnNkEhoYCQNTSIx3JF3LhT3qFxc6enECWYnqwBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977542; c=relaxed/simple;
	bh=y3ySH4sLpHcgvxV7ZorFZR5eaZY2MQUfZeVT1TpSDrA=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sNtvhebINLhAjrGFmN0HTz/7wxlEv7+lGmn2jvgfWOIHhNmpmp3TGXMdhE3fMAA+gCpLzBylIKZEoAw45f0OZtHeeBgZP+yo36wkaqGLDoqiQUNUONieDFKGvI/LAkTwKELyJ8T3PMNf37Ua8ou21ZSxneJuRBc/8V3qwER4kuw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=gPKC6utD; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="gPKC6utD"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 17EB8164A70
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:20 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id C73091260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:19 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 7/8] edit: change the 'l_edit_enter' return signature from 'char *' to 'int'
Date: Sun,  6 Apr 2025 15:12:14 -0700
Message-ID: <9aadf6433c5166cfb4c2ab2c1fd010f9718edf3f.1743977403.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=71MtMAj0ksGynXQkmaroKM5+cISjgkLmCEIeWTfpGqU=; b=gPKC6utDHeC6LKDMau8jg1YrnW7HNqv0HB/YbFZbVYiol7jVaToLfNaZnCFXU6qBvHmWtQ+2acLZIjs9+PBfbQDHapEjtf3ItR0FZLQASsx8ByRxlpj0sOrKJByRQprartO4sJWVec05nMl7jyvZ2J3jM83YElCbN8n1AYIUdnSKjW3ZDLTu9V4odhNh3HGXqnjdD66ASotpa6HIyACNCpdlFJkEcKmbQqPsjf5PfmNxnj52og1Ac3Odbj/jN+vnIeBg7InURVlhGIK2MMLElT2nnoRL6x0H73EI0UYKVP9y2p7narT8tO67uAIGOQ0YdtBdck6skJ1kTKEQvSWaUQ==
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
2.45.0

