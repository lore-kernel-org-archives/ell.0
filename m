Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 435D1160
	for <ell@lists.linux.dev>; Fri,  5 Apr 2024 00:20:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712276416; cv=none; b=Br5oN36FgGmwkLCuU3BTiB6sM9yywxPT560Zc/ewRJY/ytrJTt2rlCWTv/HOUBSWIHGR+q0cMnpVviJZK4qd3Xq3vY+5hpA8M0OylFZgwxS72KWhgzY/njuM8miWDiUDxTeOxOQZzDa4GpPI2OYgBhA7nC0jDxsDqJ8KLiu28VY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712276416; c=relaxed/simple;
	bh=4ZwPQUQOWbsWnRCBIvngk1/uHOb/x5M1Fpoe18SUJfM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HjMQeYNeCGT5TcPCvAFyKhuQWmXrJLvEqqiN/emtUHvQCwPHjCMsjbaynmf5MXIeoqgflGLXyRU44zgcHvAIo+zyagJMEnvYsD4R1HkYme5weM30+qm1XLG0c4meGxFRc98feMiV+nqJNdbAi0KwwUKzsBgmizWBMMCkKKXWcx8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=eizBgY2S; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="eizBgY2S"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 5F3301649C8;
	Thu,  4 Apr 2024 20:20:13 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 00306124F66;
	Thu,  4 Apr 2024 20:20:12 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] Line Editor
Date: Thu,  4 Apr 2024 17:20:03 -0700
Message-ID: <20240405002011.3480886-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=rzuIAc1xmb7PDwaF9rl1CX6DzlV+ob+8LVqVuZCg6XY=; b=eizBgY2S4XdhEvEDZqL0xBvVV/AXjmzD5nyqcry3Zqlwsl8RnUtoqlUUFjoFD1GS5hYRt72sKy42goiQiQad3fh5ygvun8aQgBoEPSoV5mMeJ6Yy7zAX5vdNwz9/nQlMElTax3YqqhnWh+EKhXaFywpca3o4Wz5GQK3pG45UkxIMN625GuzzYgTI0ju42TIYR2d47YJHChUyjoei70v+4eoCvJM+rKzaXJcTukINOhPp8sfAi+lgYn4bDpuJrP7RI1EUB9bHNXV4967uWOnl3cV6JtmpruOpQNJ5ULk1nyIMXoUSzDLsl3I7HEgo6YLJWj5qwJbCxNu/BXmRO5OQ6g==
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
2.42.0

