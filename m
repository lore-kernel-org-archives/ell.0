Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6489B197A8A
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977482; cv=none; b=ujzCoztGXeQ4HtkBfV1C8MU/zqZm4w4shs5JALtTAhqQn+9/QWTSdfKsoFfx/Wg2xrYxYwzkGYNS2hKjjBytSKwfazGsBynveWPD7UY+JRqMALuunT6OEmoxDHG7ARe/PBOe4XdQtlVx4089jRoeM+9kRbGATqXaVfszKY4NaoA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977482; c=relaxed/simple;
	bh=HoH0fnElLVu4zqlw1gFKDPAhSGYzo5E0VyXoVOrwLcQ=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HX22j8twbixUs+TwM5re05QTyW6fENZ0s++E+Xa5qnuQJ2IZ2psgxTHJ08xR3rc3U7DEg486ej2AUjCPuyEs6aMWGdp3dOc9TDNEorOQe+6qBWHWEwyzbMXrVgsp/FumnUxaNKHQOTpHcbRrvVnkJjXdUwF83mv0ijdPUUARaNw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=m2gR3wVN; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="m2gR3wVN"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 14434164A58
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id C2D0D124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:08 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 4/9] term: Added 'l_term_*' symbols.
Date: Sun,  6 Apr 2025 15:06:00 -0700
Message-ID: <c20126dcbb9979cc945dab59ae581d97a6d2c39a.1743976923.git.gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=Lu2apvJtfyPUIFb59w3g/V32Nu756tVL2gwncU8sOr8=; b=m2gR3wVN2Cp7JYgGcVCOMwv3QLassAmlOOsnNFfC9wzTxW6w8RNDjYSjQauZ0fwi5LQsmWHy6CRmturefXEaSOvmlF7Tfp7eInOTFKynVXnY8DlQRXbsEykEZFsc1XR1/FVMLaXjfMW/M1rOOhfSKXnQeJep2ldv4Ha+Kmny4CJNKMiDjyXXnQlh+jCTH3wBK4x8o8eMacqdsEgmz3Wxqd84raXwpJnbcxMvJqIgR8FMoDo0X+ecfCx3e8K+M3SYmeQ/ZGdAPxbm1/J3AZk/hts3Cz3w4fiila+Curgrr/CxtDzAEpEj+4yDH6hE3aZ38CxAaCya7G83xq6u2EmULA==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.sym | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index f192c471a40c..0d009e2d1927 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -643,6 +643,27 @@ global:
 	l_ecdh_generate_shared_secret;
 	/* time */
 	l_time_now;
+	/* term */
+	l_term_new;
+	l_term_free;
+	l_term_set_io_handler;
+	l_term_set_input;
+	l_term_set_input_stdin;
+	l_term_set_output;
+	l_term_set_output_stdout;
+	l_term_set_key_handler;
+	l_term_open;
+	l_term_close;
+	l_term_io_callback;
+	l_term_process;
+	l_term_putnstr;
+	l_term_putstr;
+	l_term_putchar;
+	l_term_print;
+	l_term_vprint;
+	l_term_set_bounds;
+	l_term_get_rows;
+	l_term_get_columns;
 	/* gpio */
 	l_gpio_chips_with_line_label;
 	l_gpio_chip_new;
-- 
2.45.0

