Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF78C76025
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:12:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977540; cv=none; b=h1LU3863RAJAuu874DlP4Gn4EzigE5nKHw0mNmUkYStsTmSmK+fGo1OYr0ePoRt5KrVyJ0gI4DQvh4NSieyTuB+d1jub2vquwFqYp1lVn/vWKbPpogENPHG8OH53xWZW5UGNoVYiyzoFl7QHr7elm4VnBNYWQRU28eEwfCUUi2A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977540; c=relaxed/simple;
	bh=j1kyMfAUrqwREFikmDsLxNjLS+v52LvRnB9ckSgheow=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=Qw+wjY+qnMQggLCnn9ExYedMmH1XpinvPw1QWnAPXn6vLlcn7AQfHl/l3GBAuylSQ1r8xtS4FeYhpXHNcvQjHGFI5tJlQ3fkimG5JsQQlB0ODZCdfbLUYRq95+vzY3vcXz/sa0/bH1mN5W8JzCPQ2BYHOpiJOr2RXHHXsnuCd6A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=pyklPzG6; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="pyklPzG6"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 22F3E1649AF
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:17 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id CE9C01260D8
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:12:16 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v6 0/8] Line Editor
Date: Sun,  6 Apr 2025 15:12:07 -0700
Message-ID: <cover.1743977403.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=FOEnRUYJZgP+ZNhYCu+Ke90QMFmlN1/tVVXSCawgurw=; b=pyklPzG68jyYCkBNCXrOZXb6PiEAHJ2uZoeqtN6jrcUajkPkoEMTsKDbYVAcSULq4JAECa8zgzd3quYM/hZOiaT6WSfc86iMiu1IdtEgtxzfotaU24S1nd8hzy/D7PJhwYDm8twMMLXl/4rec6zRstnfnnC1h9xMJLTT1ouZxtab+iTsON1Vdxc70i5kSUAoiGAOaNz4FApkNPXdSIfYCwHEBnrceAxjM+WFrowt/QzGsNLwHOg1VBMGpIWmYuhb6pDq6J6USpqChjB7R2ggJ19j5l0eVmDm33EZvPkrjxJAYvRwuc/Rs/kFJhCAQeKbZcn3TlgvsstkPyS2ruMpCw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for a line
editor.

  * pass the l_edit instance to the display and debug handlers.
    
    l_edit integrations are made easier when they have access to the
    instance pointer in their callbacks.

  * Return status is 'int' rather than 'bool' with 0 as success and <
    0 as failure where the failures are negated POSIX error
    numbers. This removes the need for system integrators to intuit
    their own errors on a previously-false Boolean return status.

  * improve error handling of 'mbstowcs' and 'wcstombs' functions.
    
    On error, the 'mbstowcs' and 'wcstombs' functions could return
    'SIZE_MAX' when uncountering unconvertable character sequences.
    
    Ensure that such errors are not obscured and are passed along to the
    caller.

This has proven to work well with the RFCv4 and the corresponding
demo-{cli,edit} applications.

Grant Erickson (8):
  edit: Initial revision.
  ell: Add include directive for 'ell/edit.h'.
  ell/Makefile: Added 'edit.[ch]' to HEADERS and SOURCES.
  edit: Added 'l_edit_*' symbols.
  edit: pass the l_edit instance to the display and debug handlers.
  edit: change return signatures from 'bool' to 'int'
  edit: change the 'l_edit_enter' return signature from 'char *' to
    'int'
  edit: improve error handling of 'mbstowcs' and 'wcstombs' functions.

 Makefile.am |   2 +
 ell/edit.c  | 826 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/edit.h  |  59 ++++
 ell/ell.h   |   1 +
 ell/ell.sym |  25 ++
 5 files changed, 913 insertions(+)
 create mode 100644 ell/edit.c
 create mode 100644 ell/edit.h

-- 
2.45.0

