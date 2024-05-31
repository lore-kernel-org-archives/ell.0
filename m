Received: from mail-qk1-f169.google.com (mail-qk1-f169.google.com [209.85.222.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F2165731B
	for <ell@lists.linux.dev>; Fri, 31 May 2024 14:56:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717167362; cv=none; b=HKTW36tueXuS0sTarrNev/Hrg5rKM981Go6YAlTVIhzI9w+l61EvhQ+/IU3qSzuOUcXyORgGC2olTsLSPiBntp8knHbbuCsFxS/w1oVIxJhqpuS+1EKiuUmbWqtQIj+L+W9jKz33OoBPp1UR8ada5+B7Ei9QYYwVH2VBba7eaZE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717167362; c=relaxed/simple;
	bh=0QhtWRrZQs36vjEC3NrhSslpyU5nxOi412dAAMrvpWY=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=M8HgT/UOrAT/N2q1+O/bqHFD/ptlqLiW90HB8CVf6hbdjULtgFaX9tsQ57Gr4etOBJ5ai4mdJIjO/hekvezfMMrpN81p2AKOeibvAKIsF3oDQ5WMh6cg8x+O1sNZyA4sLlfLq/LlM04TPO6Emd0JaGhbhPiAyqUdxKrZZD37DOs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=c32ycG4I; arc=none smtp.client-ip=209.85.222.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c32ycG4I"
Received: by mail-qk1-f169.google.com with SMTP id af79cd13be357-7930504b2e2so103350385a.3
        for <ell@lists.linux.dev>; Fri, 31 May 2024 07:56:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717167360; x=1717772160; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=x9DMJMX0YO0v/TNHNWnRe4ZY3CEI9ovzGriqh1VGrOU=;
        b=c32ycG4IrMJCv8iT+zWrymundg16QVHjzgmupZAXSunHy6lK4W57iiEkijJPne+Jz+
         vkNrKbvte3wO7OSSE4YPrZe3t3AfVJU/4BRyHvFEanusqJhOeVPMmINuuDeoDLuFZUlQ
         SCQY7qWqasctQJFyvVBODZPQSYPFdRMa9OnrnS/qbWcbSgXgtIB9EYb7oyQraniJIq0P
         Qx9w3dsBLSNdsN7fps0k7qbPtWzhH+yU7D6RUWzuarLCJ/V/rpxmEXb4K6IUEp1KtA8u
         ydxeVTzh5ln71Ryx31KVk86UsB3ay7IM3LgcjKrVAsL61Zm2dEDj0bOQRV9Nk7bgNDZI
         0jEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717167360; x=1717772160;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=x9DMJMX0YO0v/TNHNWnRe4ZY3CEI9ovzGriqh1VGrOU=;
        b=JKl8oPF0w8GEnbueNc3gKGR94/Qo3Ve8lok0dNkhP+SnCsypjVq2AziY7tywDQMRwk
         +lVTBAHSTSggPvz2a0YU6qZNXbILQkrAi5xaNYkgN39nNXR/xrlANlNDcbMB5El31Wvo
         2uQ/teTxVBj2wS13+ifpjBsWXybBFNFbU1ZugaZzibJgVDU4yoKUHZhfEPLHjhDtjxe2
         Q60SPniyPWiC2UX7Z3VVjKH+Rz+dClamoeoX8nc2CW0wGSdjI/eoedMuu0cuF3GtXLAv
         ia+3Lyc+j451n8Du1d5zc+uVgnnHhWHUvE5dZPS+BgVmWtuO7ISxVPUkle4Z6C3HndfH
         udLg==
X-Gm-Message-State: AOJu0YzIBwNaQzlxRqQO0sSOhhZ/oMX5qBOblPYkgt8g15bVts0hDoMl
	WPEv6QOHTV7LfK/VAqtWo4QBMNIKaNbRYZbni/z4R/AjfXLW0TQsWBqIMQ==
X-Google-Smtp-Source: AGHT+IHQXlNFIs4+Q0meyVb9CbsGF8T5D051K75JNgO9NjrjiMiKA0kuOXqo/H2nDs6088WyNEKA5w==
X-Received: by 2002:a05:620a:2886:b0:794:70cb:8 with SMTP id af79cd13be357-794f5c882f2mr251789585a.40.1717167359591;
        Fri, 31 May 2024 07:55:59 -0700 (PDT)
Received: from LOCLAP699.rst-02.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-43ff23e0e48sm8704841cf.42.2024.05.31.07.55.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 07:55:59 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/3] acd: move l_acd_stop ahead of EVENT_CONFLICT
Date: Fri, 31 May 2024 07:55:52 -0700
Message-Id: <20240531145554.601087-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Stopping ACD after the event callback results in an invalid read if
the callback destroyed the ACD object. Stopping ACD prior resolves
this and is consistent with other call sites.
---
 ell/acd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index b913c9b..e7ad416 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -283,11 +283,11 @@ static bool acd_read_handler(struct l_io *io, void *user_data)
 				target_conflict ? "Target" : "Source",
 				NIPQUAD(acd->ip));
 
+		l_acd_stop(acd);
+
 		if (acd->event_func)
 			acd->event_func(L_ACD_EVENT_CONFLICT, acd->user_data);
 
-		l_acd_stop(acd);
-
 		break;
 	case ACD_STATE_ANNOUNCED:
 		/* Only defend packets with a source conflict */
-- 
2.34.1

