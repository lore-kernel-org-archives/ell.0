Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EAD2021D3FE
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977542; cv=none; b=NNN873guaur68EAAVmtqk1Uy4jtWwIG8ISM2Zc3tXcVj6WxRWPhnJRiI4/no5ag4Y8XhUffmnB0HL2+LfN0wYkjFdt+7p2/2p+0UXK4kd1rxPGhYQcRpZtNY6G2Q7Ehn4r5YNZxLDTrSc+gliPKkr1JzdQzP5YrcJr0KedJ5AFI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977542; c=relaxed/simple;
	bh=I/bPiFutfBafZW7hYkYhxFjGtXQRUrHDSe9+ISn9/ug=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=WYy/tL/GIyfOgRfHgXqx8mhW7tmoPWyvyRqSiihNFzXensAnjkiKMm0HkXk7Klp8XI5uuTk7PcxZJ7iqNNSx6rcDkQ5qi/OAcICVvuMRLGAdtAgcrRTQ+3HSb/Ew9dsT7W2TgwIF6bb0ldyokiSzi1FUkChlGgopV6V5ZrI2ZoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=Z3DDMWA2; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="Z3DDMWA2"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 439CA164A6C
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:19 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id F3C2E1260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 5/8] edit: pass the l_edit instance to the display and debug handlers.
Date: Sun,  6 Apr 2025 15:12:12 -0700
Message-ID: <53394b18e388c2a6048705a7fa7a0a25ec49c868.1743977403.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=G5nrjmn2W7uEE+5lIEZ7pnTFzdNsrOoPo52OqKWuTCM=; b=Z3DDMWA2vFTmm6Thyr9t4vQieUsGwde7T6NuaCaN6fqDYXWHgLb+H32csz6eWGcB98sx3tJX5Pi93BOI5hOW0AfCccdALK5XruzN+A8qg22aoeqK/lsOm3gzXsov9gC/dZsGGY6CwrM4MhO0lyKlOhCus71qkuKXfNQfb7W0+7XDFYArE+ZMCWHd1CEt1qUXh2EAvud7Qr3bK22WTR0hicjhU2fKceE4iWd+h3UEksFNHz0sZPRxHvBwpn2KOILOU7S1KhZCkUXResWYx42rvuRWpvJoqFgY8aWpCDuGQblcJwZi6WECtxHVv48fQcueIqQJRz6Gdjrzjncizabv/Q==
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
2.45.0

