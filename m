Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C4641E4B3
	for <ell@lists.linux.dev>; Sun, 31 Mar 2024 23:47:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711928863; cv=none; b=cQF3MeI+ynfqPACtGIoX5BRV6XMdF0i7L9qqlHaQY6pWPzXcLg3jx84HJ/3GroE+CMH9bfFZS0b8uf2XiBq4ZaCC42e/R6ooxNTYvZLmojUyxBbjEhsq8qGnSS05D5ryY/rRsT+Iyf34hVvpQSLMHHxxrVoQcwnv6QfeobKIRq8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711928863; c=relaxed/simple;
	bh=0/q3dJhQjH+BlONqRe1bYCVK3GE3KcAjrfwoISg4Ir8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tMoyK3wEyTvTNZCW/eWsOpASunmE4VCGQyNJ3LgIrnmwuqc5KQMjMQEZH4wOz0au4GqVxim8RRprL7gYbog8eXT4JWf6kgd+C7oSN0zxjUBQYTQODoFDbElRaJJauOIfK9k+dAURR6GChky7IxUbYZJ4d9TrzL66wdW90kHSDu4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=XGWn0IPs; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="XGWn0IPs"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 1CE49164948;
	Sun, 31 Mar 2024 19:47:39 -0400 (EDT)
Received: from localhost.localdomain (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id B0421124F8E;
	Sun, 31 Mar 2024 19:47:38 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Subject: [RFC PATCH v5] Input/Output Terminal Abstraction
Date: Sun, 31 Mar 2024 16:47:33 -0700
Message-ID: <20240331234737.2452696-1-gerickson@nuovations.com>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:cc:subject:date:message-id:mime-version:content-transfer-encoding; s=pair-202401062137; bh=d+L/QxY39e2KATmxN8QuPSft5AijJkUbvA34EZFJbuY=; b=XGWn0IPsL6oA93KWKBBqNdVXU3Q6NNo5+9EQWLk4ftUvISMWNNx3JG9wQNDFIRf2bVKis8h1swIHt53jBRVUZNYWaRmUc78CoOJ9uZ51L/QkipYa9CO5sQ+LpKHdtVLAhb7XDXqNu/topuB/2e3rzXyo4JOeIBWuGBt8o/nmM5Dx1ox8TraJb5CX18jpsYlFR8XUFB0MOh4EyzNxeBlUiEeu0d/KEPRXSFLuaaFYbHp8RHorLTS5pPyyaMedcIdyPC2niF2dei+FjXupf7xWfnWqafdWOupROM7i/TpswSKi9pl6cu7EnhzBT1F4G+/rIOeXrt0beNKgi5NkEWpoYw==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

This expands on Marcel Holtman's 2023-12-22 RFCv4 patch for an
input/output terminal abstraction.

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

Grant Erickson (4):
  term: Initial revision.
  ell: Add include directive for 'ell/term.h'.
  ell/Makefile: Added 'term.[ch]' to HEADERS and SOURCES.
  term: Added 'l_term_*' symbols.

 Makefile.am |   2 +
 ell/ell.h   |   1 +
 ell/ell.sym |  21 +++
 ell/term.c  | 487 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/term.h  |  69 ++++++++
 5 files changed, 580 insertions(+)
 create mode 100644 ell/term.c
 create mode 100644 ell/term.h

-- 
2.42.0

