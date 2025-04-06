Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67B2021883C
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977540; cv=none; b=NYJTyBFRroVH8XjQ7eQUv3bmAL40XFGP2+aOrLV+quEqww01XqVd6uHcsBTTC3PUrtGpI1jyDF3PNdop1hr447BZSsMpFTOqKKBxinw3PgtM7KXAZkYBK1jHFcqb48GIcPPXN8xS1A96Wf27SsdARXJwR4pvGNhNtYu476VfGx4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977540; c=relaxed/simple;
	bh=d63Tu+Q0NJvTkI1FUcfH9WAKZrfZWtXxnbMKbIN+iyk=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aRd2/tjVreptx5rj/5nGRJIulCiQmXH/VvjTcCwgjAvrBnVgF2ACil0rYiC3lkfI8lI8qXBdWxqRz0XydsgItdjYN3ClLakb6QP7OpqnoWV1NQrGlwDrEzzGZbg9CAtGtF13oDqEiSbB6oXj9kQtPNZbzui68mUVqOWptQvY5VI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=NL2juyli; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="NL2juyli"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id D530A164A58
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 902BE1260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:18 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 4/8] edit: Added 'l_edit_*' symbols.
Date: Sun,  6 Apr 2025 15:12:11 -0700
Message-ID: <00030ad625bcf5115c992323dd29c5f8f84770e3.1743977403.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=oEiBHzH3WJ9iqTEOX0ImJUkVeoHl74y7EdeCMGp9GD8=; b=NL2juyli45hS+A3XjNEDU4bdl7DItcI9oi3x90UnE3F3MDw9EUBcDpcfOreSrSt0T9baFtgTacaPCox+2nrSE9GYnFVXHNA6SPwXY8eWDcW+p0EqCQQr5BUaxr1HZ+Foi92x2hUUFvmMrub+NDcsVF/7bGsrosjw1AIJQq4y0lPkRcwayAOoBRH8cQXIVpkDQYluj72cCEVxvmanG9XBQDJTEpx2NBt5y617Y9plCapfwc0xvzzIjmXrupWNSabfYmjk42fBbHyZ+KqOK336lveY608wzU2oPP++EAQaeHjfcxlM0o2gPyKiEZ8cLO7++WSx1rCScU7V31O5QO8IzQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.sym | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index f192c471a40c..3c31fd608e3a 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -643,6 +643,31 @@ global:
 	l_ecdh_generate_shared_secret;
 	/* time */
 	l_time_now;
+	/* edit */
+	l_edit_new;
+	l_edit_free;
+	l_edit_set_debug_handler;
+	l_edit_set_display_handler;
+	l_edit_set_max_display_length;
+	l_edit_set_max_input_length;
+	l_edit_set_history_size;
+	l_edit_refresh;
+	l_edit_is_empty;
+	l_edit_enter;
+	l_edit_reset;
+	l_edit_insert;
+	l_edit_delete;
+	l_edit_delete_all;
+	l_edit_truncate;
+	l_edit_backspace;
+	l_edit_move_left;
+	l_edit_move_right;
+	l_edit_move_home;
+	l_edit_move_end;
+	l_edit_history_backward;
+	l_edit_history_forward;
+	l_edit_history_load;
+	l_edit_history_save;
 	/* gpio */
 	l_gpio_chips_with_line_label;
 	l_gpio_chip_new;
-- 
2.45.0

