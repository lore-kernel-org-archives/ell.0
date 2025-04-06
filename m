Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F3DA1A8F9E
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977482; cv=none; b=I8ix6NsDlBJfTlYaoX/Aminy27UTe5rnguKjqPcMtjjcBbDOw3W88zrpC28ak0k4VMigVNtVPKXO1GeSoTy+N9AzEHLE6+F6TxEqSSxK6Y6v/qMEAKiuCZe4Xr5aHiGv32rG0BOF4NHcWhTyDyGgnkiaVTcB0agQkqTPF4Kq5ek=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977482; c=relaxed/simple;
	bh=Ec4vqp2H7BraA6N2Gc+wT2MrHlBEeS0BYGSw9Kq1QPU=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=N0y9LNI03oH4gpjf1ax4/iKvycf4oA8bk0uy0nz5os9+QEPt8TnDNeVJbo9aEc778eL24AMDQnI406CUuPDIRXnkbe64r4c1xv0F7edFNVdI/TMj0056rbPBqdONGllPdc/rViCfUyIm7SPgSebp5jfNfhCsIpGGjZZDelJqa+4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=WPTUE+qZ; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="WPTUE+qZ"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 4B3F41649AF
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:07 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id EF1B912636C
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:06 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 0/9] Input/Output Terminal Abstraction
Date: Sun,  6 Apr 2025 15:05:56 -0700
Message-ID: <cover.1743976923.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=AD5vY7paTXG481ADv7MsCRgzZ7qXahZ+lLg+uTLduOY=; b=WPTUE+qZbMdaUuf6yOZrEckwVl5a4iOpJHwEAldwbubpipeTihlCnJZK29vUhsefYNEJn+03RowBfLbD5fnmqd3IPmLE9ET0eyaO/G0Q+qxP8GW0kOoFJz6AuMj1WYGZZY+1xEv9QhBY7MHekkV8hcE9Sb+xDSCnnTFjAFM1bpIA+La6MNBZxeI8/ywIOfVUmqq+YeVzuotxyl4qibJIuJGlWvhIktMDiF3dbbzL4btHRi+jxFhvMNLmuK1z+uWGgemEJdLfVS+MvvMUKcVYwJr0F+ElXOejeMZqAFEmS7Hj76tTSsmdd0JuYGiClLPsdfoMacVWoDIU1Lc2y7mf/g==
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
2.45.0

