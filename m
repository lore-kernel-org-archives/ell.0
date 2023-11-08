Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF50338DE2
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 23:46:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R6hoxVoZ"
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-1f06931e4f7so132927fac.1
        for <ell@lists.linux.dev>; Wed, 08 Nov 2023 15:46:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699487199; x=1700091999; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=hXOCgdKagcLLV8wpRXuPHm/ndyY1/NgrxVXqFRYN/2Y=;
        b=R6hoxVoZTQGIP3Y/xPtiC/7ByV5yQ6PGz440kZtZ4AX5em80IF4qHY6updIsMKO9Ea
         x5QKJkSFOqXdsboWyilsfehLnwnL9HTXVFoxDtgjlC2ZE+zNfoQbnUImjcaOk6dbuLtn
         JJCLKdlZ/WOuf6lqGNOeurWOGttntsmpKE5x2UdDQvDKYsmyIwgnEwXa3AU4fbzbeoif
         EQp2uHuef+bOPZ7f1zOrDKGfWUFPBQXf8bdsWDxo7ydwkWYx9OS0NJuBxw3jbd0c0tic
         cjE0GPfdUSEP9KWVSBgMHuQGUWLtrvaZFL+YTWxR6lqa2SI2kx7PzIeJPxpqyZtAJ46V
         p0Nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699487199; x=1700091999;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=hXOCgdKagcLLV8wpRXuPHm/ndyY1/NgrxVXqFRYN/2Y=;
        b=PKZq/5bKlCTtttf4vXvxWRIjfsY20qXxCT7l7YRw8hFd0Af0PWEB3Z/A9ry3ryADvB
         kCOzC1qrv9j3e6PeD6ifrMBEmtBGLWJ8IZj1teZ10cRoUyuVxq35astS8ymjfrJ4Rcri
         N7TtnPe3aPhHu7bZq7qhfbiNMxbSlBfo2pUUMikGmy2zXrkoc2Mmko2REt75C7YKtBZs
         eNWD8GbKIzLY09lXBzv2jzofDpdQR1WyWSFt5uBID9YD54tuEZMonsp0Cgw6iIC0t6EZ
         foSgKc/65KlNWDwrqkz/XBdr4J7pkLCilzG9oMnucdjH6QPH1kx1QOu/FZ84X9JpD7F/
         rClQ==
X-Gm-Message-State: AOJu0YzZXN+JHvBAJCFCN6yGsmxm2Pl/uaSrJE9tWzlVlsyKMsSRZix9
	v1t1lKdd8OYEttLu5mfHPH+MGVJ6prk=
X-Google-Smtp-Source: AGHT+IF5cLRf+3p9mx8AD+/omCzCRAPckBfeNEJhxiuA3XFbqchOs8kJkQEvPCbZQMrj3Vn/VPJKqA==
X-Received: by 2002:a05:6871:2b09:b0:1e9:a8f4:879f with SMTP id dr9-20020a0568712b0900b001e9a8f4879fmr3955318oac.55.1699487198770;
        Wed, 08 Nov 2023 15:46:38 -0800 (PST)
Received: from localhost.localdomain (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id h5-20020a056870a3c500b001e5c7cc54d3sm491116oak.55.2023.11.08.15.46.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Nov 2023 15:46:37 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 4/4] examples: Fix compilation on old systems
Date: Wed,  8 Nov 2023 17:45:23 -0600
Message-ID: <20231108234544.1050199-4-denkenz@gmail.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20231108234544.1050199-1-denkenz@gmail.com>
References: <20231108234544.1050199-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 examples/dhcp6-client.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/examples/dhcp6-client.c b/examples/dhcp6-client.c
index d566d6965a0f..5992a4a1ecb0 100644
--- a/examples/dhcp6-client.c
+++ b/examples/dhcp6-client.c
@@ -12,6 +12,7 @@
 #define _GNU_SOURCE
 #include <stdio.h>
 #include <signal.h>
+#include <sys/socket.h>
 #include <linux/if_arp.h>
 #include <arpa/inet.h>
 
-- 
2.42.0

