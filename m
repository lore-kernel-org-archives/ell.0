Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06E50152533
	for <ell@lists.linux.dev>; Wed,  3 Apr 2024 17:22:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712164947; cv=none; b=nQYd0nlfYpWVkpGFTEqeu5j8YfVqxx7/ZsNr1nLOnwzrMR/ouFfb8+G26O75VWja/4yPlomQM/h0OVJtBIhQ49FN6lLHeQyceXJs4cSHvlr2DIc8E53d4ecIVf5pTMmRal8M+52zM88bU0FDfLgT27/w6iy5pnFKZ8fdvhSEGxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712164947; c=relaxed/simple;
	bh=bC+nuiwSv3J4SeSkhGl0+b5mDxDQV0yGfVVtjyhI8U4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=nm9/eHmXQl0ycF7OvqNnPCop4eL9yFdYMtLm7je2oNh4jimZZDtv8MrW3ZLVnlYWe4IqJ+kngShOXjkbfLdajp7g6cKaX8xmmxrgKAIs0UMaW6tnfAqQc74ShL0DL3ZXZhITQIRKAu/mnhY+30mRjjFxQLF6fM3uPRKW3KxwpVU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=MPaF3drF; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="MPaF3drF"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 0D941164948;
	Wed,  3 Apr 2024 13:22:18 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 94492124F66;
	Wed,  3 Apr 2024 13:22:17 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v6] Input/Output Terminal Abstraction
Date: Wed,  3 Apr 2024 10:22:08 -0700
Message-ID: <20240403172216.3254805-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=iFVJn0F2OWEQ0krH+N/4HDJ1md6Nr/4gPdXgI78nngc=; b=MPaF3drFueiO4K0x+/fZiF21qnPphvfcJMq7H4tbE7wXZ+HriLBOwnIL/IGUozzFUBaYIVHVvzyNWBqHw3qvYkw5JGD5QvJRJvN1IJUo5pgX+Zskx+0qMSfrg7bz92DAC5Ux7jUoD6EFWxvuH/z0sOZY3r6+uL3ZaDEjZdIsr68mMpPcVRwEOm5ovg4opGiRahXZrc/KbE4uzOkqOI8tb2H/prOBFh7fGtPPl+ROEhE54TdAN/bnp17hDICJJt8TIDOLvdO8BZelZjOUrRqgfUbtqbdZwF+detQTWNUCwY7TpJleZ4VHXmchoCI2NxkaFoATxxsZDucgZDz3imz4dw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
input/output terminal abstraction.

Substantive changes from the v5 version:

  * Add an 'l_term_is_acquired' introspection function.
    
    This adds an 'l_term_is_acquired' introspection function that
    indicates whether the terminal has acquired and modified the TTY
    settings for the input and output descriptors associated with the
    terminal.

  * Rename 'l_term_{open,close}'.
    
    This renames 'l_term_{open,close}' to 'l_term_{acquire,release}' since
    this aligns more closely with what is happening with the underlying
    file descriptors. In particular, those descriptors are not being
    opened or closed. Rather, their TTY parameters are being saved and
    altered on 'open' (now 'acquire') and restored on 'close' (now
    'release'). At no point are the descriptors being transformed with the
    'open' or 'close' system calls.

  * Return error on writes if the output descriptor is invalid.
    
    This returns -EBADF for 'putnstr' and 'vdprintf' if the output
    descriptor for the terminal is invalid.

  * Do not return -EPERM for 'putnstr' and 'vprint' if not running.
    
    If the 'is_running' flag is not asserted there is no need to return
    -EPERM since it is still valid to write to the terminal when it is not
    running (or acquired in the new parlance).

Substantive changes from the v4 version:

  * Return status is 'int' rather than 'bool' with 0 as success and <
    0 as failure where the failures are negated POSIX error
    numbers. This removes the need for system integrators to intuit
    their own errors on a previously-false Boolean return status.

  * Makes 'l_term_set_{input,output}' public functions.

  * Adds observer functions for the terminal rows and columns.

  * Adds a modifier function for the terminal bounds.

  * Adds:

      - l_term_io_func_t
      - l_term_set_io_handler
      - l_term_process
      - l_term_io_callback

    Collectively, these make the abstraction run loop adaptable with a
    default callback that can be easily used with ELL's run loop,
    'l_term_io_callback'.

  * Adds 'l_term_[v]print' which complete the output interface.

    Of course, its always possible to perform this outside of an atop
    the existing functions; however, this eliminates integrators from
    having to manage the buffers necessary to do this.

This has proven to work well with the RFCv4 l_edit interfaces and the
corresponding demo-{cli,edit} applications.

Grant Erickson (8):
  term: Initial revision.
  ell: Add include directive for 'ell/term.h'.
  ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
  term: Added 'l_term_*' symbols.
  ell/term: Do not return -EPERM for 'putnstr' and 'vprint' if not
    running.
  ell/term: Return error on writes if the output descriptor is invalid.
  ell/edit: Rename 'l_term_{open,close}'.
  ell/term: Add an 'l_term_is_acquired' introspection function.

 Makefile.am |   2 +
 ell/ell.h   |   1 +
 ell/ell.sym |  22 +++
 ell/term.c  | 501 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/term.h  |  71 ++++++++
 5 files changed, 597 insertions(+)
 create mode 100644 ell/term.c
 create mode 100644 ell/term.h

-- 
2.42.0

