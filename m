Received: from mail-qt1-f174.google.com (mail-qt1-f174.google.com [209.85.160.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13E9D5C8FC
	for <ell@lists.linux.dev>; Fri, 31 May 2024 14:56:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717167364; cv=none; b=R86JfwZ0AtZFJEamEWh5zf4W1hnnaqFb7kV/D22aefvuTaHNZcH82ErakqNj4UYBpYe9z77HRb261aXvS96bG8sILjBXFyyEkA2bVxQ5Cc8JKLRU5E5R+PI1Uc/D4X9zVZNMmmaiG/Ns1+9HE6wcpfz7j9t5/GHM/3+w7XDx7UA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717167364; c=relaxed/simple;
	bh=ilAgxMwTD0AXkoUJQf2CB2Ogi2Qo0x0ZKAGF8q1C3Os=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=hpBWjbmAtzzluSX2BxxMeokIVQzOQ9YykFKFVpIyN5zMO6mjs7xB6ys2VDAtFhbjkX/5WhlB7+I7peSJmrldMnVZz3oY07EqBJmeELiNbLWM0+RFDvfd7f/ygr7NE1HXQhDkvQTGtQrwYMRnXHgQwq/N6mvZO3ADtHEjya/ukDM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dcWHYkJb; arc=none smtp.client-ip=209.85.160.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dcWHYkJb"
Received: by mail-qt1-f174.google.com with SMTP id d75a77b69052e-43fc100549cso11110351cf.0
        for <ell@lists.linux.dev>; Fri, 31 May 2024 07:56:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717167362; x=1717772162; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=85Y5VfNBfWr6W4qv5vuH9/35nYjZiTGP59kDK0kW0c8=;
        b=dcWHYkJbsRVMQRyvDodjQ49K7dikMxraZud85nUSudNN2W6kQI9o+nGCrIdbvDhgkK
         yxZQcNfUWdOa5mHZz4zul+I3Qk1k7XJT6J0lpTQ7nYe65Tei1QNVGKbnHiVpOQ/xo1Za
         2iE332NBEDdxfrTyAwTiJe8k6f2F19SGjDdVOn6VduCogWxnz/aoqAMJbpQ6hcZBW3XF
         JR6UCoL75LGxy0io1mFJHTmWItytiZm7Tp2Yj4hkMYNWO9kfAZCYyxQqMxrvIgsHvZKK
         lc+yrPXiqdfRkjA6sCFaI83apg1UpEAlWSNXs1aqyxhTtYxiQ3Wu9pOX0ZAK+u/wpx02
         mwZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717167362; x=1717772162;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=85Y5VfNBfWr6W4qv5vuH9/35nYjZiTGP59kDK0kW0c8=;
        b=TQtDLWoOpHBVpEWwuSZys+idsJ8XpdSnLSGALOZlbt6wcXKR7CyKhrGUnqKYWyc7Wr
         gB3p480tc1aB+vpZEE3NXipMweMQOOW0fOdUl7UJguAZhK9v9xrjcHln0+yoEeDDVe/O
         8eP5t4MJrdnwrbhOQbI+TFFQDalpcRKzwvGY9z/GJJOCsnU7y4RNX0D2TL8MNY2NyUpb
         HjcwgWkozcZThd12gXRjLpXHLx+Dr1uLE0u4L4IWdeKr8cfMIwpBlCiIMyBOl2r6n6BC
         nSJU2sJ5Qjb2MxU4/WFYY8V0Vcydnv90BQeUBOMnow0AQp4/h27Teh0xQZNfUtSxxRfC
         Kniw==
X-Gm-Message-State: AOJu0YwIuzeINnsAkI23zBcHYbsj/erprCXL45Y6a9NmoABNQw5ARNiO
	Tu9yWFcW0DDYvQzYYT5gzresQMTrSm/ikvttLyLGWWD/Xx9hdPZy2aDWlw==
X-Google-Smtp-Source: AGHT+IHUhKnI2oWyhAI2Ge2XRNA5YO37Wct3DqHSvnII0cc3CsgF86D9SFNaWSdGp6SXOfjVG2JfUg==
X-Received: by 2002:a05:622a:1309:b0:43d:f612:979e with SMTP id d75a77b69052e-43ff52ab1e4mr23087301cf.47.1717167361800;
        Fri, 31 May 2024 07:56:01 -0700 (PDT)
Received: from LOCLAP699.rst-02.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-43ff23e0e48sm8704841cf.42.2024.05.31.07.56.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 07:56:01 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/3] netconfig: free slaac_domains/slaac_dnses
Date: Fri, 31 May 2024 07:55:54 -0700
Message-Id: <20240531145554.601087-3-prestwoj@gmail.com>
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

Neither of these queues were freed upon freeing the netconfig object
---
 ell/netconfig.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 06a717f..9cebdc3 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1410,6 +1410,8 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig *netconfig)
 	l_queue_destroy(netconfig->routes.updated, NULL);
 	l_queue_destroy(netconfig->routes.removed, NULL);
 	l_queue_destroy(netconfig->icmp_route_data, NULL);
+	l_queue_destroy(netconfig->slaac_domains, NULL);
+	l_queue_destroy(netconfig->slaac_dnses, NULL);
 	l_free(netconfig);
 }
 
-- 
2.34.1

