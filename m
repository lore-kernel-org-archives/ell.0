Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 946E77FF
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276418; cv=none; b=YtGSQEmn1QYv1RkiDUnHLgObh9dGgwusz17IYl2y9XNoHqi2XthvTRyxVfhcvWk5/+pXWcNmqUQKi7VkNbNuF2bwy0A7wpmcgIRq2ptbXKNeJDZ+xMQS9/IbUZEUBDAueUsfF6mah8L4OxI/cr6HnS6oYYs6QVr1TqT1FGc/hGQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276418; c=relaxed/simple;
	bh=NT1iWwQmwzmyDS6o8pr4Jtrixtnq8YXiJxJpC/NVnnk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VdoMjCrfU72FXeqaVyqYNpslfb/E02juXLk0nC/OQwTewVN79v2cL1yOS7oCtEf+/Xom4YwFNlttZEV7fs03HFBDdMLoTkgJ/QHEbfn1v/hdrgkdxpZVTUEBEXGGSfrchjrruvSA1tM27C2CCg+c2gh3FhGCZPtuM9QBt54XSDg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=RG3i9keh; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="RG3i9keh"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id CB85D1649D3;
	Thu,  4 Apr 2024 20:20:15 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 54EAD124F66;
	Thu,  4 Apr 2024 20:20:15 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] edit: Added 'l_edit_*' symbols.
Date: Thu,  4 Apr 2024 17:20:07 -0700
Message-ID: <20240405002011.3480886-5-gerickson@nuovations.com>
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
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=ANvwEVek2nyqzwpmYAHjduZ+rcRBr2D+i3dzOnKWDZY=; b=RG3i9keh2UA6orxZFKRWP8bTkrQmBx2trFO7g7eEI3gKwocX5+9ztH1HBaJ7poaI+05OiFc+xaTugZgeqM1x47FyjN74AOXdxqcJ9LH+D/HITr5C8ivdpUsUNuqHdeKWjZ9omAZAFkvgbEX616R0Sh8hY8xaYnrzAw25b/8eq4cDcOAQWciRV3uVZM7kbaqitG3rEDYapXkUpDkZxFWBQzQeu5PcZ1K4CphasdC30xiJ4xuwQ9CLbSy1Xy5peItxkpRDCv3JFM9wn6W30AEQrhBQxg5MrJgxXud/bvxqOy4t1pNXyW46puCCPlUCsGg1cARjtk7PZVtczo26sfIVUQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

---
 ell/ell.sym | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 28b55d36719b..6c47304d8044 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -623,6 +623,31 @@ global:
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
2.42.0

