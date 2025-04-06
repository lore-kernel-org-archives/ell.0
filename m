Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AA83192B7D
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:06:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977177; cv=none; b=M7k8nDy9xDHnPFh7Pf9vJtKUzETS+XjR73/B4FPOIlnewyBv9Xup67PYMr5xaLcZv1p5su/DtdFWuDnEGzeMLL3TVrnQ+Wmb+xUZR16kHnKr6TrDdP9kIrTXVnFj8hyPymJm9zmBPO8JPygw17c1eppTAaMvoWs7CIh0Vd/MNiI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977177; c=relaxed/simple;
	bh=8BC1eD/l+/I4U7pptyti+bNAYN1xzNUT/OVJvakBtp8=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aa0qPeSZV42lg+yBQfM30GKp0dzR2icTzTjC4af6ULkNyi+bVeXNu1PXsC4gXcfwM+ZQxrOzKpXyw4E6WTgPhhp2XOkzO/IJvdMpZRAEfLHm9u9MnogOiIr0knn658L9mEMiwjUXTTnVbnWjwkEeKEQ4+t5TQDO0W91TTcH2IZ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=hDn63fQ/; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="hDn63fQ/"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id BDCD7164A71
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:10 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 76C30124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:10 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 8/9] ell/term: Add an 'l_term_is_acquired' introspection function.
Date: Sun,  6 Apr 2025 15:06:04 -0700
Message-ID: <e7f27b91a0a1bf3a234dbcbdce03d0cfea5b27c8.1743976923.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743976923.git.gerickson@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=ApiDEOp2NYQK7ekk9BikRmcUGFlx5Z9vqHyRXsK1tl4=; b=hDn63fQ/p9TNCI3Yc4feGU6Zt6TsWw/WeL9/Q+mCS6rYuJCFPmVW8JO/Y9lAtsm6Aw1s19JmdPOtHJKjR13IzeGFx12Uj856YKH/HmkhFR7VJZoJltHaX2qjR9JfbtTo0wKCHZANL0jbEBJbvQaekRHF5hex0IxNcpBSb5YPDwgETgzvaCVhjRwSdkIwDYBhHWiN1shALH9590YURRvM9P+cXx/8YkvvTEt4Cxrbh+zb0ae3XUzVVj5CDhVkuKySYHKPogcukuG6ebNemwCyjlcQONo5StZvDo5IHY4Do4w9dtBEnDg/Nbt9FCjUZEbKK3r6cdanhQRSFDcSJgMRRQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Adds an 'l_term_is_acquired' introspection function that indicates
whether the terminal has acquired and modified the TTY settings for
the input and output descriptors associated with the terminal.
---
 ell/ell.sym | 1 +
 ell/term.c  | 8 ++++++++
 ell/term.h  | 2 ++
 3 files changed, 11 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 2e198bd57461..9c149d717e48 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -652,6 +652,7 @@ global:
 	l_term_set_output;
 	l_term_set_output_stdout;
 	l_term_set_key_handler;
+	l_term_is_acquired;
 	l_term_acquire;
 	l_term_release;
 	l_term_io_callback;
diff --git a/ell/term.c b/ell/term.c
index f3801bcb1200..a56ede4e98ec 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -241,6 +241,14 @@ static void sigwinch_handler(void *user_data)
 					&term->num_row, &term->num_col);
 }
 
+LIB_EXPORT bool l_term_is_acquired(struct l_term *term)
+{
+	if (!term)
+		return false;
+
+	return term->is_acquired;
+}
+
 LIB_EXPORT int l_term_acquire(struct l_term *term)
 {
 	struct termios termios;
diff --git a/ell/term.h b/ell/term.h
index 50831c166c78..66059212b436 100644
--- a/ell/term.h
+++ b/ell/term.h
@@ -44,6 +44,8 @@ typedef void (*l_term_key_func_t) (struct l_term *term, wint_t wch, void *user_d
 int  l_term_set_key_handler(struct l_term *term,
 				l_term_key_func_t handler, void *user_data);
 
+bool l_term_is_acquired(struct l_term *term);
+
 int  l_term_acquire(struct l_term *term);
 int  l_term_release(struct l_term *term);
 
-- 
2.45.0

