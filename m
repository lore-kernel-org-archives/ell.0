Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B82B813BC38
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273918; cv=none; b=HhBuGG9Otho1mtvzWZHeWTjkY1ol+ttk7PV7Y6ssfM4O7J76yBxWtFS74lSWCKuUzE/DBQE/ux3INtd1iIiJR+IDVBRKhzmlYS/WwEBn+n0M8ACStNPAClGHfT6l3gxzy1i4I3kfOxxV1LnZ+nIiRVdMm8JnXV86cK1Ha72G3SU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273918; c=relaxed/simple;
	bh=9gLA1kPZ3Z3/ssottB/wWbIxi753z6P8NOweMm9MQcw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lZBZ+clos6gFJBy5GkL5wQ6cZxvKaqUwgZ210pT0cLY/sn85W6H7zurP1Te5MgtTZvy6t8xCEWOfBp7fX1tdx2nZY13D7Z6fkCemlXWoxWSht78llJ6t3g4C0R1QBnRujF21wNCPruo+Hj/uAI4sJjIBW4qkJu+Ydz1ybeTbGWE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=dycpmNZ/; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="dycpmNZ/"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 4D0BB1649E7;
	Thu,  4 Apr 2024 19:38:30 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id E2250124F66;
	Thu,  4 Apr 2024 19:38:29 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] term: Added 'l_term_*' symbols.
Date: Thu,  4 Apr 2024 16:38:21 -0700
Message-ID: <20240404233826.3466674-5-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240404233826.3466674-1-gerickson@nuovations.com>
References: <20240404233826.3466674-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=dJbKnIfpqOo6Qzd01X57bVsNN3PJpfYrwsp8Kc0fHeU=; b=dycpmNZ/sdVsxDDewtnRxRNPC0Yc4RsaTkNpfgR7acBRcyWlnStFcZoFj+ZfJjlhEOZYM0i/RzCK2VxC9FTADFR/joHmrbY6lDO+CoEonT/4bHEwFTtoB8rEqhdHy40RMg7t0/P6DjWwB1T/h3XmvQY89wMSKn1s0GLR+XtQUkKUzxlaV0/PviR2R9ShxmWVSuiMDLO/bYHW8ymGR2CVb/65JxEWfXy43HgtBvCfkw+2F9767smtwhU0m7Tb7OeaMIW929edTGiLGoii+Ui3wsBsoV0/C8unIoa3aS/uAzbLJAMLFz0h5s0cSs0gO0qyVIk9FYR81M2POx5/Otg02g==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.sym | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 28b55d36719b..2767bf55e079 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -623,6 +623,27 @@ global:
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
2.42.0

