Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAE6D393
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:37:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712277422; cv=none; b=IRjv7B8kkTrRukyH6sP6b8TJwqwAipiAR2eVZhpeTyWfvO3FmJdnG0U4J2wZ9f1i/bqDd9S1mZWBFy482Y9J6nLBxgK1XTPS/AKxu4AyX7shSNCp2doUMYPzik7edDlL3N/KbT8aycH0NViH8SU5pz1OIqt+hZKLj3C9A6nVHLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712277422; c=relaxed/simple;
	bh=yyMsoWryZrGKwPRrb8AGiA5GBW7BBqdlpAQeVzAjIaU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nlO/shTcxkreHGqE6D2KjszcUK8EA0C2gZWD4vvVsjOyy1pZIdXI4Siwxg85aWexE/u4qZPRCQkhsuelerxQ2UhAVCwlwnFeHRRsdHHlV5jP+802xNG4rpUt1k4YO3vIBfryWmJ3BTaBNvN0uIlJz4NH57WYz+shE3ZefZv04Wg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=DrPJ1R0k; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="DrPJ1R0k"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id C110A16491C;
	Thu,  4 Apr 2024 20:36:59 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 5D4C0124F66;
	Thu,  4 Apr 2024 20:36:59 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v8] Input/Output Terminal Abstraction
Date: Thu,  4 Apr 2024 17:36:49 -0700
Message-ID: <20240405003658.3490494-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=x7UzE6RvA21KyHVLlBqlqqdGGEgetGRtvkVHgr8fKEs=; b=DrPJ1R0kumhwOcHknVEuCMpl4+LNCG8lQxHXHUfACEeUYxtr1J4CZSlU6fBfYggTYqpZySfcUtYvjLQHbmlhwMReIbGo3J/I7/yjuPf1+PrlX/4Y1oQGLyPF1oRiFXqRLG1P8xGdV9doAl+gstTKYRI4ZjhmFnty43uHEHxH7SJAq28LgEprc6jGDbWRgZ4A0/zYP4VvSGiWF456jJhdE8Hq7kCSTmZozjInCcEa8+E3TUp5oQC8rt9CYJqNBOLz9WWtUFcEyGjbpE5wgoPm+RHInuigoWjkdtN/sc+I0/rurxZMBhu6UpV2pQsHPhEddbLuNMjxYJmwKkiMy36iQw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
input/output terminal abstraction.

Substantive changes from the v7 version:

  * Fixed a typo in the  ASCII C0 and C1 control code mnemonics.

Grant Erickson (9):
  term: Initial revision.
  ell: Add include directive for 'ell/term.h'.
  ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
  term: Added 'l_term_*' symbols.
  ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
    running.
  ell/term: Return error on writes if the output descriptor is invalid.
  ell/edit: Rename 'l_term_{open,close}'.
  ell/term: Add an 'l_term_is_acquired' introspection function.
  ell/term: Added ASCII C0 and C1 control code mnemonics.

 Makefile.am |   2 +
 ell/ell.h   |   1 +
 ell/ell.sym |  22 +++
 ell/term.c  | 501 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/term.h  | 215 ++++++++++++++++++++++
 5 files changed, 741 insertions(+)
 create mode 100644 ell/term.c
 create mode 100644 ell/term.h

-- 
2.42.0

