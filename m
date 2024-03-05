Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAEEA58ADC
	for <ell@lists.linux.dev>; Tue,  5 Mar 2024 13:28:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709645292; cv=none; b=nE+kd1hMRfOO4rp5lRoovfJO9YPhbnFkr25+TShSmKrtCjysBs22KnXPL5JsJIUKy4dQ8AA+RzZtDipMqa6KHQ5AlSK1JxBhMESw++wSh35RIiFR5jaizXlOX53jU40KR4sxsUBXuJEgQtSW7Wewyj24HCS6xUYwza3A5XN9QaM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709645292; c=relaxed/simple;
	bh=KCKwzkWFJeYdZlmipFTXjbIZfPiNeyzFCRfrmcAbKM4=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=lRwuiRu33C+fdiowT/hajhEjgCXS4QE9SrjwmN+lTiOQgGwJ62twkoW4iFtHJI2bKyAhuSbws1OTeHqAxNUnIjN6PtI5iA4Kjj+TrIj6JYEFvuAOOajUwvrIV+zfrRJEmOaNjw22HAy8ieuTrDNKIx3w+XUuzMpAIpq37Wry7LI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=anQdXE0W; arc=none smtp.client-ip=209.85.214.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="anQdXE0W"
Received: by mail-pl1-f170.google.com with SMTP id d9443c01a7336-1dc9222b337so56087205ad.2
        for <ell@lists.linux.dev>; Tue, 05 Mar 2024 05:28:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1709645290; x=1710250090; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=xrMfbkn1tuU6SUPOaVeOyAcTiWbi2hvPZXXg+AE9aRo=;
        b=anQdXE0WDNpOrwkNiGshrftNH2bypyTyTF35+UkT6Sp/6H4fj1PaXSC4lvGTIVSS9E
         Qhdck3HQkZxeAQUQv24HRUtzouvLv0ijxqNsUMdXEDE12g41FJWvPz/S6QU64B6Enk/U
         YETQNTIwewJFsJcHt3DY5OZbbDWPBNIadPd1oA1pPZAjlYpEX8Cs6I5Ww5YvBYUZm4qe
         zzF81OZmwCDiyojcgBH+2WqnivHZd9sMK4F3wKNI/AXL9Dl5ziuHkCUF/Ydn/cshClrn
         AmlqrhdcTjJ8KrP0DL+R/JPDFMkG1UoqvZNcquM0oV1w/BQzC01bcEgmi7m1t2WAiKc5
         2big==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709645290; x=1710250090;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=xrMfbkn1tuU6SUPOaVeOyAcTiWbi2hvPZXXg+AE9aRo=;
        b=L7y1gqtiAxqtfBorGl85/cr+YNVpu1IuenD+CJZJsucFsGHaUxW4Rx7Tg9cFEYc7JW
         daIQ+s5TJZZGHGz+bHI1MpXfGNSLwo7+tFkk+OzvuJK9L4qDQO4JSeS96fkdOjW7yh1i
         qMaJ0aNirOeUiTiS5udPPhhpaRC6I3zlymk+OmEz2n3fVFf32Na5DoK5A+dJRL6BbSTd
         GjksrS1wecCQkzKWMTseULJTHwr7QGiFhEvyvRuzgWHaw8UhIKVGsdmwPgYohLh2gQ54
         9J9Xxf+64+PNCVoKpZWuQ4zQu9TXDGTwc2OawbLxl8bVgyFsBYVpzgRVW9A466hlsnVu
         vf3g==
X-Gm-Message-State: AOJu0YxmbORQQ7ZXkL0XLogO5nWcInrLbEH8VkQsWLjnqxlH3AtpRFyV
	wzfPHpL3860itbTTSuJ6k/aA0VgJ9Bb0kbZdKSsmr5QsYLyawHjuobUN1SAr
X-Google-Smtp-Source: AGHT+IHCLue61+v7U0pofjnWd+LMwjNWGbQG3PQqYMJyUe7Y5qxYcGTEKdpXw2MW4d+hsJy1rYan+g==
X-Received: by 2002:a17:902:e98d:b0:1dc:f833:c8ae with SMTP id f13-20020a170902e98d00b001dcf833c8aemr1779735plb.36.1709645289701;
        Tue, 05 Mar 2024 05:28:09 -0800 (PST)
Received: from LOCLAP699.. ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id 4-20020a170902e9c400b001d7252fef6bsm10489493plk.299.2024.03.05.05.28.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Mar 2024 05:28:09 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/5] cert: remove usused elem_data variable
Date: Tue,  5 Mar 2024 05:28:03 -0800
Message-Id: <20240305132807.85724-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This was being set in the if block, but never used after that.
Instead just check the return value directly.
---
 ell/cert.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index ead9cfd..38bb01a 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -1658,7 +1658,6 @@ static int cert_try_load_der_format(const uint8_t *content, size_t content_len,
 {
 	const uint8_t *seq;
 	size_t seq_len;
-	const uint8_t *elem_data;
 	size_t elem_len;
 	uint8_t tag;
 
@@ -1674,8 +1673,7 @@ static int cert_try_load_der_format(const uint8_t *content, size_t content_len,
 	 * to add any more formats we'll probably need to start guessing
 	 * from the filename suffix.
 	 */
-	if (!(elem_data = asn1_der_find_elem(seq, seq_len,
-						0, &tag, &elem_len)))
+	if (!asn1_der_find_elem(seq, seq_len,0, &tag, &elem_len))
 		return -ENOMSG;
 
 	if (tag == ASN1_ID_SEQUENCE) {
-- 
2.34.1

