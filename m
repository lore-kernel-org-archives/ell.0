Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EE4E148312
	for <ell@lists.linux.dev>; Sun, 31 Mar 2024 23:47:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711928864; cv=none; b=GiEG1cuJg67HFQnNRBV7Oxwk0PqM4QuUvLNaMPxiCq6w/8lJVDHyDrl56X7uYD64gP4+RhOkaTwWYKen28SL3p97/pYF1iNvTh0ul434VVQzQG7MnW1BWLA329TWykkCuS02qRGZXeih/N5fVv8FA+gY/H/2GonM3uYRSkrzWNE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711928864; c=relaxed/simple;
	bh=9gLA1kPZ3Z3/ssottB/wWbIxi753z6P8NOweMm9MQcw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Pg0uwCIrRD6NBt/OYRjYva6aD9ISKLyimzBrvmBQveKkr48pT+h+3MKnwVNVK/Hqf/rKyzhZ+zueUtLv+4a8ObNz+vBVDRTdazkiHUoNdxCLgVSmWupBquvK2Yd+UDjPj1+VHhgu/iqNp2d7LpJDE8sbrIkXyCyEywrbQB4Qoks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=lNreRVxB; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="lNreRVxB"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 3EA5E1649CB;
	Sun, 31 Mar 2024 19:47:41 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id C8A94124F8E;
	Sun, 31 Mar 2024 19:47:40 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] term: Added 'l_term_*' symbols.
Date: Sun, 31 Mar 2024 16:47:37 -0700
Message-ID: <20240331234737.2452696-5-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20240331234737.2452696-1-gerickson@nuovations.com>
References: <20240331234737.2452696-1-gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=dJbKnIfpqOo6Qzd01X57bVsNN3PJpfYrwsp8Kc0fHeU=; b=lNreRVxBbRr3sWylayScMUj3n9phNCKgVQ3uLNpioQ+x+xcfXMqPHpUhh75Rf5XA1us+7ktXJmFz1Va8bMdiskXXIO61g9ERDodb2sWbi6P+LCPZu8tJBfvniSkWHAdm5lste8S+zVxR5Ote+HkedsZbzwoyc4ogxXkAw2tNEAPMTWfBKJp1BgABhE2b6Fod1IFikNQKLNcfb0q4Fw6Sgh3E1BXQFKeIs4WUZJwLWyaPLaV/fk9pQkcz0Z18/0UxUyJv7op6IHYFFqX6WRHHb/USqdSPsIATr2gvn/Lg+CWpcDZXpWffe9PpA00Wu+1k7Vun+FzT/rgo7YP9DwDpfQ==
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

