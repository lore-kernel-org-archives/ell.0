Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F17AF153563
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164950; cv=none; b=F6fZN/ibyhcJpoU7IZfWll4zgYYV0SgyCcxJJU6w7IVBNNVShJJVEdw18ST4YsulGnPGR+63yhiJnZaX7G6aoXYUmV309+qKk339pQPFKu4fHX/tTNgKrdinrZzkzhpy3dJ0DWdMtFnMByTPG+dLiARSDZInWz7IKh4QBvRypyo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164950; c=relaxed/simple;
	bh=/oeeUSpzo+ABTdUMz8wRA6l3huHaqh1Y/pIqJTpGOUU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fKZKuUXk/EseWTW8hqbz22YvuJnpxliwzLluffZZfQSlROxhNUeOaG2TIrluK+2qWirmrMRug6DqBYaDHen9AZrOid5hRvw7febq70EE/8GgTMnE7x5D+pnDUbtdd4C8izU3pIMWlE0KJSzq5E2a3KzbVA/XbzfVrvsATBgXYKw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=TItkzmpd; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="TItkzmpd"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id D2163164A92;
	Wed,  3 Apr 2024 13:22:25 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 740A5124F66;
	Wed,  3 Apr 2024 13:22:25 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] ell/term: Add an 'l_term_is_acquired' introspection function.
Date: Wed,  3 Apr 2024 10:22:16 -0700
Message-ID: <20240403172216.3254805-9-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240403172216.3254805-1-gerickson@nuovations.com>
References: <20240403172216.3254805-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=3o1u3hVWt/nFitJnm1d562dxom90SrkEy/KJOwneWSQ=; b=TItkzmpdmoEhhjC+UkkR0PTeVGAhE9ZDcdpYwJgEzf4m2ZnVvAfvISNzuqnAa6J4JpeVXqs2CG+0vFPq/MtZ6dFJ2wk1HUC41EBK3Ua5FyU/CTrGCD8mkuvZsevbjLbFZhKrvNz7xoAUAoOOZNvPkPp10iL1wTuuX+7nyqjhEdEZjelWImV8hh+Q9Asx9K+fTYWRhfsX84cg4pSQ+l441vFDoDRHL1fHPQIsFiPGHNlKUrEKAgS6N6QC62JeyyN2Ufn5pOaqeWYe6AR4PRMj2ToBEIvTso/PGNtg7iVkI4AUzV4SWxR9sEXyqmsZV8nXiFQYpX4F70F7nagsXMeHng==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This adds an 'l_term_is_acquired' introspection function that
indicates whether the terminal has acquired and modified the TTY
settings for the input and output descriptors associated with the
terminal.
---
 ell/ell.sym | 1 +
 ell/term.c  | 8 ++++++++
 ell/term.h  | 2 ++
 3 files changed, 11 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0026bbe1afcf..e288d6c32f67 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -632,6 +632,7 @@ global:
 	l_term_set_output;
 	l_term_set_output_stdout;
 	l_term_set_key_handler;
+	l_term_is_acquired;
 	l_term_acquire;
 	l_term_release;
 	l_term_io_callback;
diff --git a/ell/term.c b/ell/term.c
index 86050740e967..ae66b9034c86 100644
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
2.42.0

