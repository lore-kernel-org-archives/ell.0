Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68BBB1C2BD
	for <ell@lists.linux.dev>; Fri, 27 Dec 2024 18:57:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1735325879; cv=none; b=EMJsYeOCjiymHsYy9nkPLLZObqvI4zbgEIWFD2QHq38vTI64NHlt2yt4VXNaEq96SIpBqG4Vnz/MeC+Nmto0TVSTJaA/t6IUj4LxWAYH9Q3iUmhptoobB97AqIwB6D2y5L+ds7/0Mgv03NOvwSDrX435WcYlcFKC0YWlfc/89C8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1735325879; c=relaxed/simple;
	bh=Y4knQxP464JKPtvHAyzQbXD0/BbnBiobMPra5zwpQw0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=izEL+QaDm3ddOSz8ItlX25wErp4SXuxeM9WQ7Se0HvFaqpMLrIARPHZ3tbtHW5Gmoy6paaxudZ0OITgEdRXwMYnx5dBSTVxq2CNpEFfvl8p3kT5u0H6oPhGz3Y7KM8N1zcIavJDjvcihgImaRixM4LiztOwm3vPeez5BBi2gopQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Q9mKsw3l; arc=none smtp.client-ip=209.85.128.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q9mKsw3l"
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-43618283dedso74624545e9.3
        for <ell@lists.linux.dev>; Fri, 27 Dec 2024 10:57:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1735325875; x=1735930675; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=jQrUe9Oct25qlNKFW9swCQjUy1OBTJDlvWtEZKaSz3Y=;
        b=Q9mKsw3leCQ3X8hrB2Y5szbk/y/rzN/S5WHLi4wfxPGJ4vLyo8nAUDfTNcop1PYzVN
         x3qsiEcCeHD50Eg8M6eoO52L95Mkq4okhbSxxJ9GCjYWrg428IoymT9s0ZEUT6Jv3ZCU
         5Jo6JNtNLxTaQeqbpOETXNQR67C0487bxsJZZzLp/fmCnMD4NuU7m5TvvL/vF+hgTo4s
         OalgTeX3ZtKZlKZOzn61ntWtP2uazm1Y3TNdnNVvAqQJV3gkGhIlOQbURw4E7xrJQhhF
         xmpdkR2LAakL4ccJqVUkdDEWVY8xxDmEhWbqeI9wUyaQ7NU9/ZwJ2KNfEKyPx19y9eQJ
         W8rA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1735325875; x=1735930675;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=jQrUe9Oct25qlNKFW9swCQjUy1OBTJDlvWtEZKaSz3Y=;
        b=ol5wkiRv8KG8KF6/gyLfvD6/cLlXjKK9XLh0bSd782jSrcdQ/hjKE9J/cLR+mKwz2t
         MjDEOAU+lhGcJpisJNw+f6ozCtbiENRYd+0RGUhC0yPNuNZaM3qQQ6AzIA7TDb6GneNA
         8ZJVZHgkSWD7yjsq16Zf0338MGxS+m2lCQxnzYzIi0oNT7EroMd9zBXqGbWekxgS4VTT
         WkAlo/c8qAmxLJCDorkc8DuIhw6N/Woco4anf1WDXdP72pqLQpRhfIWbpGwxpiPz8Wsz
         sOZ5TKtH1SmJ2Yzb6dk9ROoyTPXMmOx6HnUtB1ulq9Mu2Lv2FCEWp64mQzjBxNg5C6oK
         Y3GQ==
X-Gm-Message-State: AOJu0Yy7F3qYA+qSNmTpl2M+QlPpekZzLMdKVzfxhDxQb0BPZ355wFMt
	DSmkwggjsNnA22RCRUlwKYGjE/KA8hsQmEjip+sYxPmahy6a3OuZPuO+sw==
X-Gm-Gg: ASbGncuLjfnqWeMqsVezieYKV3s3LIW0WA7PL12UnWTGxjmoaA2Cn8Y8TGP0iU/0JwQ
	MYVBf1bgH+tu94D0gGyIKZxfE262LHT8bjKRq6T1+gQbJOXCGvo5IVPuFaJuIEOp8/dXqJHy6U0
	dF2QcdaDuT4u1Zm+O25XiGxbsHw/4+OunW8kMUwww+GhIvU2S6ucJcpoDKerrPr+xHtefM3wLCS
	8mzrz24sIw5CHwA/Ond9OvfvZFbc9BGdxfyPxL0B60lAPUEVvrDYiNS+sG7Mn+pG6aDEUevcH+w
	wORPn+PzwW0ga59r43f/SLAqP3s=
X-Google-Smtp-Source: AGHT+IHj3jnlWzhBwG6ve3xmeXzAk2CS5xvKeIGUV+Fy6YR5cAYWRTIMptBrlk8GOSVH1IsHflsAuQ==
X-Received: by 2002:a05:600c:1d2a:b0:435:330d:de86 with SMTP id 5b1f17b1804b1-4366790d3c0mr265398135e9.0.1735325875070;
        Fri, 27 Dec 2024 10:57:55 -0800 (PST)
Received: from localhost.localdomain (95-26-112-31.broadband.corbina.ru. [95.26.112.31])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-38a1c89e4ebsm22948952f8f.85.2024.12.27.10.57.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 27 Dec 2024 10:57:53 -0800 (PST)
From: Artem Sinkevich <artsin666@gmail.com>
To: ell@lists.linux.dev
Cc: Artem Sinkevich <artsin666@gmail.com>
Subject: [PATCH] dbus: fix use of `va_arg` with incorrect type
Date: Fri, 27 Dec 2024 22:55:30 +0400
Message-ID: <20241227185530.99708-1-artsin666@gmail.com>
X-Mailer: git-send-email 2.47.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

`rule_len` is computed by iterating over `enum l_dbus_match_type`
(32-bit wide) variadic arguments, but the function also takes
`const char *` (usually 64-bit wide) arguments. Count the arguments
in the same way as they are used below to fix undefined behavior.
---
 ell/dbus.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 1ab4ded..7fa5c18 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1825,8 +1825,14 @@ LIB_EXPORT unsigned int l_dbus_add_signal_watch(struct l_dbus *dbus,
 	va_start(args, member);
 
 	rule_len = 0;
-	while (va_arg(args, enum l_dbus_match_type) != L_DBUS_MATCH_NONE)
+	while (true) {
+		type = va_arg(args, enum l_dbus_match_type);
+		if (type == L_DBUS_MATCH_NONE)
+			break;
+
+		va_arg(args, const char *);
 		rule_len++;
+	}
 
 	va_end(args);
 
-- 
2.47.1

