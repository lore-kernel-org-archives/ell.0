Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1135657C8E
	for <ell@lists.linux.dev>; Fri, 31 May 2024 14:56:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717167363; cv=none; b=N3k0s3kAjwjDax/SG/f8bDaOrmgA69EsMOSBX3H55rd+/qVePvZJSf57X4hiYVZ5XT4xOzq6kCeHMScOxZI9wsJIiqvuDq38SmlasL5hWg69CoAlonqVNf8C6Z/wHW1cVWPGJnoRk/qg8HGBnqUoEbcZo3//KxLNWS8T8ZLxgUg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717167363; c=relaxed/simple;
	bh=vdKMQAQGENutMRml6a6UjN2Tsdp76m7UbGUZWOxJ3To=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=kWBeoXOg4mT0jY0XFAF08adIWOQ8ljQfWlPrQtmwD3rFp/iLDZyyhwFO4nLz+zzs9OiTzKNuFb4BFiGFw66XG3g73CPfSy+kWPmOmAznFstUtRBrhSSksGkuwW1rG4MfF18HDegdn1NNIYhRAopSqg4UUar7a8+uDsBx03Ev1lQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=VOebSFIz; arc=none smtp.client-ip=209.85.222.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VOebSFIz"
Received: by mail-qk1-f174.google.com with SMTP id af79cd13be357-794cbdca425so151068085a.0
        for <ell@lists.linux.dev>; Fri, 31 May 2024 07:56:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717167361; x=1717772161; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=TeoZYF+e8wOfTkbr6ksfkhgz19NvRSx+JWt0sNdb1i0=;
        b=VOebSFIzryNOUa0Gvx1x9NByI9InYcwGzJXq34ZnK9Io1IhvN8IX8+eFV5Mfb2XxRl
         D1jkudbQi6BN1Jyye9wcrTxCN8aIGC+IQBzvMLQGh8Mgfsm2GpF6P03at8uKuZOqXIi+
         RTIlk4TJXaL+FFQ61ScTA7T2oFVJbdxYxBHJCDpd9Of36X1RHsKvrP8AQmtjSdXUr0Yy
         kESBYYfdOjiQLLNrxwSOuY2v0alk1QSheqD2Ph4V0sZPf8/ie5rpMmUAAJs1BtuAPjbM
         3N+c4fXpbubbAeEZab96+DOAojPlsbV7RCmfqk1gW5Vc9ZyosrGWkOIGsHGiH1sNhuzA
         i2wQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717167361; x=1717772161;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=TeoZYF+e8wOfTkbr6ksfkhgz19NvRSx+JWt0sNdb1i0=;
        b=Xk/wduzidSB+OsCwWwf/P5UbRnF/Q+5I0A6RtWFqLI9Yx513IAxvLJdW6KRhfoQF8R
         sHiq0sHMv2mUToO2fXjno4w17wlm61i0Aov9Or6OWN/iPWJpUm+2CzrXb4c9cQcgpHG4
         NXt+YskRQi0QG//4zs68LvLTjOC52V6gIbPklL5/DM/qE7f79VQJNoZzn+nlXRZrOgs6
         Q6Hjwf8agjbwQGo50qX2uc3gTGgCje9a3RN75Pjn+1Nop7w4U1tsHhiCKAWN+Wuxl83P
         A3AA1SqpIxI35bOx8AdQh+cwinwuYOJWWT+76Kb28wwtlUNGLpLqI6QReIWSvx0AFd1/
         cVpg==
X-Gm-Message-State: AOJu0YxbWl74DVxh724ngGtGTK4fSA0XzJrxf6Ob2GgzpxWqs18xu51T
	HrmKkanKOCcbH5NoVBtd4m8ULJ+KBnzj5QkiE8lbeR/zlvvW9E5XgSNRQA==
X-Google-Smtp-Source: AGHT+IER4dmOYQ5+DdpAxXst5Zqjq6xhWD39PTs87RQwDvD8XxFYqeYJnEf+zn45/fA6SG0bLb+Ulg==
X-Received: by 2002:a05:620a:450b:b0:790:ed57:1354 with SMTP id af79cd13be357-794f5c664f1mr245545185a.6.1717167360715;
        Fri, 31 May 2024 07:56:00 -0700 (PDT)
Received: from LOCLAP699.rst-02.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-43ff23e0e48sm8704841cf.42.2024.05.31.07.55.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 07:56:00 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/3] icmp6: fix memory leaks with dns_list/domains
Date: Fri, 31 May 2024 07:55:53 -0700
Message-Id: <20240531145554.601087-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240531145554.601087-1-prestwoj@gmail.com>
References: <20240531145554.601087-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Both of these lists were never freed upon freeing the router object
---
 ell/icmp6.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index d94127e..d352955 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -787,8 +787,16 @@ struct l_icmp6_router *_icmp6_router_new()
 
 void _icmp6_router_free(struct l_icmp6_router *r)
 {
+	unsigned int i;
+
 	l_free(r->routes);
 	l_free(r->ac_prefixes);
+	l_free(r->dns_list);
+
+	for (i = 0; i < r->n_domains; i++)
+		l_free(r->domains[i].domain);
+
+	l_free(r->domains);
 	l_free(r);
 }
 
-- 
2.34.1

