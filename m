Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45E3E13C3FE
	for <ell@lists.linux.dev>; Thu,  4 Apr 2024 23:38:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712273917; cv=none; b=Vrhhif21WGonf8NYImL8Zj4XhiIqB5ImASFoh2QZP6b37JDr/Hz0bEnCmXlPdFVwchbw3O4l4hClN3vMkuz91cIZgIiYg/FZb+x+tTahfhTNg9G7mx2eOYTPWbdzg6vN9i91vaHw0LwggGujt8yROq8bvFVRkw8RkO90dSTygcg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712273917; c=relaxed/simple;
	bh=XLbjfodFDdSSj2inMvn/VH394X0W7Rm9bnxNYWaQvog=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Ju64tUDvHBOKq64o2h40QH2cgsXzT218Rvje4KhGgey4pYAPtuti9XagUtmrpRUvCDkC+PFcQ5Im9td4CVaex7KvLAKlsshPJBk4bJYabrau3SX/Uru5w1ww8+ZP75NwZFH2ItsUTtXUuFAb98CjFoenYhKk+VSI32Moo5Ljlp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=DadTyEIG; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="DadTyEIG"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 0CD581649C8;
	Thu,  4 Apr 2024 19:38:28 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 9B4F3124F66;
	Thu,  4 Apr 2024 19:38:27 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v7] Input/Output Terminal Abstraction
Date: Thu,  4 Apr 2024 16:38:17 -0700
Message-ID: <20240404233826.3466674-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=XcI7v6w8/3p6jpX7hkzgwj4dtCsYkCSazP1gm8M7tEs=; b=DadTyEIGC/ww+3fb24qBGaOV6RAZSgro7cg/6ClsgEVRR1M21t1bbOOo3VogJaDgOm3PuQOrFcF25HvNjPLGporm/R9vaaOaWLMsBj+K8gwqanaKgHpe1rTu2jMHHpLUrftPzYR9gOVQxNs/4yiMvvaYAh/m1Q5SbDn9RznViuXxTQdw6H2zbvZgKLI0hLtc0WaNA224bBnZiP7HWizU51lPCCxU3FvHQoXgqMl3GkqswJbvmRz2HN0BSXtLsOPEbh+HxlU87cOasZ45zGtNz56lgUZNsMHg4Lb9KyNB85oJPXkMDzzFQ6Es8edrDLGkmUx4h/M1nE9Ljv4jVQrcQQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
input/output terminal abstraction.

Substantive changes from the v6 version:

  * Added ASCII C0 and C1 control code mnemonics.
    
    Added ASCII C0 and C1 control code mnemonics useful to anyone
    implementing a l_term key handler.

  * Reflected mailing list feedback from Phil Hodges <philip.hodges@bluewin.ch>.

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

