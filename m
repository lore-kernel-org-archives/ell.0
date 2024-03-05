Received: from mail-pl1-f177.google.com (mail-pl1-f177.google.com [209.85.214.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93B1458ADC
	for <ell@lists.linux.dev>; Tue,  5 Mar 2024 13:28:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709645293; cv=none; b=TEPFCf5zF5yy1VTbU39pLUHB6cDKDIgk6Yg8GVWxiN7zwDPr0S3gIsmGySd5Be9EDgdv4JuzvtjUGEhVZvT72EpXmfLuvhgcXC+bD7sx8APCo2c7TTCHoVngnDU4LdmljWP2aYu7nDqA8bbiSLJ93aET+I1vSEbZoR0JjdUDO28=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709645293; c=relaxed/simple;
	bh=gRVG+5rEWFAd6eRUaZublcBONbEZD0u4Kr59icHF1+4=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=jO/Gor2Xehd8mujlowdt1V4s7hsHDmeUcr0f1XawTaLSeKBzYGyOps0f/iZY6ODEnPJLioPJRP1KwpLkJ1uCOyo4tcHHaEn8A/Lf//KWSpR+/a1XjIfW1Y8DLHx2s6Vzk+hcSMYKLvW0fiN5TbiHPAfPKVBANrR+UElRKCExMaU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=RtSbp56K; arc=none smtp.client-ip=209.85.214.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RtSbp56K"
Received: by mail-pl1-f177.google.com with SMTP id d9443c01a7336-1dc418fa351so48426195ad.1
        for <ell@lists.linux.dev>; Tue, 05 Mar 2024 05:28:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1709645291; x=1710250091; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=K5XY6E+dKQAXK5icK+7YYYas90wBpH6iMsKhCSqE+wA=;
        b=RtSbp56KDqDC52QEodnJoGQ6R5ZPzuO21p/vdmKsxC6P4vx69mNZEsHHNNQsObx0ID
         NjMNCZUpTWobEjdcQH4486e5fu7PQWE/5leCmYItNQmYEo5UmPBmXZrLYF/9VYynt5Vr
         /tfhs/miwfb0dykirhpUb679qxwrmynSWkLchtctrHP+QPcXc9r+JA3yXyul62R8Mw0f
         xk4A3mGb3viLvXm8Ga2+He/jDIMUUb8SUs45RVnC2AG0xaV2rBXTZCVniTPqgGxFFpx9
         lliiGZyb/ttwsQKdu6s9bTXCPuzUKQ81tCrLaJWbkvR9myZfiWOh+4//eEOHgeSVyus6
         FDGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709645291; x=1710250091;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=K5XY6E+dKQAXK5icK+7YYYas90wBpH6iMsKhCSqE+wA=;
        b=gMBVvWWDVUGV3dU5RkiEeqQD+UTaRQX9URaS6yIaa9RRZ7TZZnTDM3Zf8OXdGg64qF
         ZmGppHL4pfHbBo94k1JuhMzWjsVTTtHcBI/fpoz6vMQR8smLOOtPdlg5b6j7yeUfNY7Z
         eQez5AAf9HYjpVns48KlcEu03ELAoGXbszFrTmU520RTirdTRWAczMRucoMsRZ59Cno9
         wvta7wAuIAoZl+pMGh4o5vquLNWt60uvHs9NcZRWN/0TK0Mrrk8JkHqhgKS0dVoyEIxJ
         mysS4Q+X0su9DUB2rnWS2CM8mjsEsIGFU+Cilk4DnEfqKeUuVWnkCL3g+mXowSgQVut7
         5klQ==
X-Gm-Message-State: AOJu0Yzh1Hc+eQWjYnUwp0USLj0JKfQsFKTU/3VIogUZAWma94sSS6T7
	2W/L2p7W98WPyOgKX3l4SZZHLm7XIkwHxJpkhgISTfiFSm0oRBXMrp+v6p1B
X-Google-Smtp-Source: AGHT+IFOpF/cD/6O61oYjfuLeHGqd5tys6va4iYbVwcTQdqzBD/oaAVDnJxtzjuK3Bmq+/bEW+VfGQ==
X-Received: by 2002:a17:902:ec8f:b0:1dc:fc84:198 with SMTP id x15-20020a170902ec8f00b001dcfc840198mr2620803plg.29.1709645291344;
        Tue, 05 Mar 2024 05:28:11 -0800 (PST)
Received: from LOCLAP699.. ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id 4-20020a170902e9c400b001d7252fef6bsm10489493plk.299.2024.03.05.05.28.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Mar 2024 05:28:11 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/5] queue: remove unneeded entry advancement
Date: Tue,  5 Mar 2024 05:28:06 -0800
Message-Id: <20240305132807.85724-4-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240305132807.85724-1-prestwoj@gmail.com>
References: <20240305132807.85724-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

At this point the loop is over and there is no point advancing
the entry pointer.
---
 ell/queue.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ell/queue.c b/ell/queue.c
index 487a949..9018402 100644
--- a/ell/queue.c
+++ b/ell/queue.c
@@ -511,8 +511,6 @@ LIB_EXPORT void *l_queue_remove_if(struct l_queue *queue,
 			if (!entry->next)
 				queue->tail = prev;
 
-			entry = entry->next;
-
 			data = tmp->data;
 
 			l_free(tmp);
-- 
2.34.1

