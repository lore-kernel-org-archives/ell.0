Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5075A1534F6
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164949; cv=none; b=uOiGndijJMHRuIMfzGyRI3ShTB2a1XF3KozIQYqVvZnrjUg4jALXz8A3judxur+b8vTqqXXYEc/9MToIDaM2UvpsIp2SWdjcrSkG52U7aaoMlwOoUY46XHo3CbL1qie2IpZD6TeaiBqBv8SmKTuGjtYBU4JnCn3Zio5zQZbZooc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164949; c=relaxed/simple;
	bh=9gLA1kPZ3Z3/ssottB/wWbIxi753z6P8NOweMm9MQcw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=N8+GTn3pY+fXDiuFE0P+5SEWOrf926Pn9FKw/ni76N0LyUlzhBk4fX6RyAzb8SnA8jGnMyB8TWZ6av5paGHPtGHZf1m8MRZDFsRDN+N9MAh3/7p7Ce2muGZDLikg48hwdzLF9w4uFI63DTcPIF9BggIC6sulXr7vF9+EW2bcm+o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=A4VzVpLg; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="A4VzVpLg"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 61FEA164A8C;
	Wed,  3 Apr 2024 13:22:20 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id E60FA124F66;
	Wed,  3 Apr 2024 13:22:19 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] term: Added 'l_term_*' symbols.
Date: Wed,  3 Apr 2024 10:22:12 -0700
Message-ID: <20240403172216.3254805-5-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=dJbKnIfpqOo6Qzd01X57bVsNN3PJpfYrwsp8Kc0fHeU=; b=A4VzVpLgXvZAzRHTlovzm1DQF6lU62zq7sxmkrnYAU0RKkjeRLtI8y53RDgZL24Yrao4SY5OuUd2grSzPFD6zQXIaYGy5MoRTrwdGTCAkB25ltNYIA/LCGFPjQ2RFoRQ7TbPaFCL1+wRYUAZF2ucNGfX11SFLS9mhKN8vQ0horBv+QKrugWjpdc/PYVyk63/zguOEZo7DGsCXI5lWJa4eDY7508sIWYZArO6fCHgJz+aqbhpGsAXnqXsRA5aVIreP3p92gey/3KVuAEnpy22FFqg4CSpgIvNDfFYLyQ+/qiA+QkaQVteWoy2wnJEwKwJyQQXDim6eQkj3DCFZ+zIKQ==
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

