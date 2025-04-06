Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AA048C1F
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 22:06:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743977176; cv=none; b=WlOAintK5Jg0O/wN85fTXfDVRP5+1UeT4YvWV2N2GqFynr2mHLnckcWIuqU1k12YjFZwXpiaVNZOFMVB4Vl0yHJi3sq8LSSo114hqz8v+hTeWnwDRwhiBX8w7KUfPz22jqeiqsGHsgUxXlhMHU0Z4HN+Livq8ne3IGEcGrbLEyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743977176; c=relaxed/simple;
	bh=Cu49dRnhNbz1XpUGX7De4zO0o7Qd9uEbPJlTMpR4J9k=;
	h=From:To:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HwKGXVFFbIc+UptPKE2HfUPepLwQtBb/SIkqGpB6gMH05W5mb/HytdeSB60LaRmm+BzYT6P+HWpWYHBQCpvQ5C5BgbmoNCB2ZuvFsrfFBlcXDczduBDujkJUA4KLALNATCpaUqMO9RbUPv4QG9UtJqOfm1m7up5Phvhen9Ker24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=jtJHbJEP; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="jtJHbJEP"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id E22F3164A6F
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
Received: from localhost.localdomain (c-73-202-173-252.hsd1.ca.comcast.net [73.202.173.252])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id 9B8BF124FD2
	for <ell@lists.linux.dev>; Sun,  6 Apr 2025 18:06:09 -0400 (EDT)
From: Grant Erickson <gerickson@nuovations.com>
To: ell@lists.linux.dev
Subject: [PATCH v9 6/9] ell/term: Return error on writes if the output descriptor is invalid.
Date: Sun,  6 Apr 2025 15:06:02 -0700
Message-ID: <7de7f13c49042a0e09fe9760055c81787b3aee4b.1743976923.git.gerickson@nuovations.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <cover.1743976923.git.gerickson@nuovations.com>
References: <cover.1743976923.git.gerickson@nuovations.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=from:to:subject:date:message-id:in-reply-to:references:mime-version:content-transfer-encoding; s=pair-202401062137; bh=iktyWn9nIxURY4iSzPRdEdGBc8zwcnlOyw/qDmgcL9k=; b=jtJHbJEPVvcDyXta+CaxM9dvw9R7mR4vl7iZEspXgHNEqV8SoXccvYLHgNRrJKed+HPOvV8wYCVQETgJhApcTXsoU2YOibnmcYuuqcwAzQ6j/n/x1FcDKa6OkFHNZlUONFRJxX7Z7hwcK4zOQlxNIgMfEZtygGp+hiTpzgL0EYPTE2ylFjdaJbY+f3b5KFmIwEVUMpgyO/hkc0VpZPd+N+/9PlJoTwEFgAWwo1OjYR6J+uVZXeIq6oyY7yYd9UDMbYzXS+YjAoIm07RtwpAfpQQTzIebi2tX1izeY9VGPrkKcdcUC1+n0ogAGBkxeazNDzRnPLhOIDZwpgjFAMl1XQ==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

Returns -EBADF for 'putnstr' and 'vdprintf' if the output descriptor
for the terminal is invalid.
---
 ell/term.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/term.c b/ell/term.c
index c867b240090c..7ec92476e14e 100644
--- a/ell/term.c
+++ b/ell/term.c
@@ -391,6 +391,9 @@ LIB_EXPORT int l_term_putnstr(struct l_term *term, const char *str, size_t n)
 	if (!term)
 		return -EINVAL;
 
+	if (term->out_fd < 0)
+		return -EBADF;
+
 	res = write(term->out_fd, str, n);
 	if (res < 0)
 		return -errno;
@@ -432,6 +435,9 @@ LIB_EXPORT int l_term_vprint(struct l_term *term, const char *str, va_list ap)
 	if (!term || !str)
 		return -EINVAL;
 
+	if (term->out_fd < 0)
+		return -EBADF;
+
 	if (vdprintf(term->out_fd, str, ap) < 0)
 		return -errno;
 
-- 
2.45.0

