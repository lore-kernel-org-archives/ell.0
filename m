Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BC5281F
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276419; cv=none; b=BYVGuTBC0ty4Qd9KwfdX+fRTEVHL7oSSQV0/oc3vIP2ED1brnP3yM8foMDAEDhdQjAftVyZY8Y2QKykJOeb/PBj/tSxAyMkGUH4d4HxH80GCOfjyQQEd4I5QjHUCZF0W00mzu9FCQBJl0qXwVPZhc/NEdwEOGKgNFlSwkGatDzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276419; c=relaxed/simple;
	bh=PjJqHPrk1KekV/jkTYV+L1ZlZrIFCO1ao/ARepovRGU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=d1v2OXEag+HzcW6lBsdhJiKVVCMvtk2lfJv2TwcSUk45gK83ErtDPzHGx2nBtZRhVEv3EMmfPcQtdcQy8eu7O548RAr+8U3DH5I19CwrKAUtLarbnmqMZ7g0CCwPjIqjaDGjlPC/N0oLNkqYwALWVAi+IqYzPvSXq+9LyOpVkrU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=YeApNNK6; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="YeApNNK6"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 52BC01649E7;
	Thu,  4 Apr 2024 20:20:16 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id EBB7B124F66;
	Thu,  4 Apr 2024 20:20:15 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] edit: pass the l_edit instance to the display and debug handlers.
Date: Thu,  4 Apr 2024 17:20:08 -0700
Message-ID: <20240405002011.3480886-6-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=ICRDAX80sF1GT+/7Ba7eEWmWiTEk051qPv2MWH1zqtY=; b=YeApNNK6/qF/8cxjbc5aVRQAhGSPdRQYkrBxu06y6Fshno1zmt83YfdtAi4tf3YxJPHc6xPoaVO6PJzrXXUJzIScQmYWLXd/sRzAw2dPblUS7nmfkw6iiQVXT6eRYEslxZ5A+OvYwk5876evR7D2nGcCUyYeFoLlT2N2pCYV9mcVzpjkYe/E8//MmmJk27fbifYLvA1KsVCNAmRvV3vYUasuyMVzrpvHJm7MGFRxCdLhXqOfH9Ec8gm4zIKUD2PoAIhN+P8MxXkLA/16XWJlKtADI6u8xM9Nk0YAsH2nDdqqVefZdaLv+6BhApYFpVetP/FzCJarL1rLFlC9GfNa2g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

l_edit integrations are made easier when they have access to the
instance pointer in their callbacks.
---
 ell/edit.c | 4 ++--
 ell/edit.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/edit.c b/ell/edit.c
index 899fea4da830..54cfc566c4ad 100644
--- a/ell/edit.c
+++ b/ell/edit.c
@@ -229,7 +229,7 @@ static void update_debug(struct l_edit *edit)
 
 	tmp = l_string_unwrap(str);
 
-	edit->debug_handler(tmp, edit->debug_data);
+	edit->debug_handler(edit, tmp, edit->debug_data);
 
 	l_free(tmp);
 }
@@ -270,7 +270,7 @@ static void update_display(struct l_edit *edit)
 			len--;
 	}
 
-	edit->display_handler(buf, len, pos, edit->display_data);
+	edit->display_handler(edit, buf, len, pos, edit->display_data);
 
 	update_debug(edit);
 }
diff --git a/ell/edit.h b/ell/edit.h
index 45ad2e657156..decf261c7b9e 100644
--- a/ell/edit.h
+++ b/ell/edit.h
@@ -20,12 +20,12 @@ struct l_edit;
 struct l_edit *l_edit_new(void);
 void l_edit_free(struct l_edit *edit);
 
-typedef void (*l_edit_debug_func_t) (const char *str, void *user_data);
+typedef void (*l_edit_debug_func_t) (struct l_edit *edit, const char *str, void *user_data);
 
 bool l_edit_set_debug_handler(struct l_edit *edit,
 				l_edit_debug_func_t handler, void *user_data);
 
-typedef void (*l_edit_display_func_t) (const wchar_t *wstr, size_t wlen,
+typedef void (*l_edit_display_func_t) (struct l_edit *edit, const wchar_t *wstr, size_t wlen,
 						size_t pos, void *user_data);
 
 bool l_edit_set_display_handler(struct l_edit *edit,
-- 
2.42.0

