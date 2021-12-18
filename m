Received: from mail-pf1-f174.google.com (mail-pf1-f174.google.com [209.85.210.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F949168
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:22:40 +0000 (UTC)
Received: by mail-pf1-f174.google.com with SMTP id i12so3840622pfd.6
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:22:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vLvodztH3fcRj/Gf253NL7MrfFOxUzi+4vugFkOcTgM=;
        b=eRZGk7IUh2K6vORq41QMQGiaENnXPEXvHYKXlWMkTE4NY6egrO81N622hVFSb6Tukt
         hUCT4Qvi4EY9aZNOWqVP7sGH1lxtJkJpeJHsfrDZ751nihbPFcLy1QsMydG3E80FP/R8
         nzRI87FM5xQSdz6DgVo9smBeOyhr6MTr5rsEFzVcvwb+e0uNiiVMpwCttgUh7DLUVehl
         RTp4nXJtbyK96Y+oAF7HT0a85S5OmDX84gObllRJSjCF3i/l46zcf2ddctyzg9M1i9dc
         mUn6F7XGWg7GU9KwZqoAqX4jyku9QZqCgyfDlvbUHdUT8zAnxcK39RQrE+ypboeYnMia
         kczQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=vLvodztH3fcRj/Gf253NL7MrfFOxUzi+4vugFkOcTgM=;
        b=6yyKxse4HjiMO2kz08atS2hsje+6BW6h8VE5JGOVHKcr0QN86atdnw+V5jjQL3XB82
         QhbXfD/6z9qqu0iclYlx6rpmzQfZ4C/u3PexB8y6y+X9BEWhVqhS6MbrGMFzU244f7Kr
         YMaxLS39f8BZR9fBtkooPONLrsYlY9LluSrYydcuY3MVhhEsRR3E2kpR417Eu5t5uPnm
         oMqVmdRPp8jna18XjSNjFXb0AVWrRUGemwra5AAwPPKjpOVBhuTLTQo2Rn61FNt+z+zw
         PVuKOMLa6T+JUR9GDWX1goA0EW3zohLAKfyvOEtBPqDDWqL9jsovOyX0Rqzh81TiSW/D
         /TDg==
X-Gm-Message-State: AOAM532W6Ty96vNUkL4uwIqflkdiQ9+lEwWvBXqARJK9PPx3LFQylcXg
	qBTNBqoZWkZfu18QBHqv+YERaAdESiAVeQ==
X-Google-Smtp-Source: ABdhPJzWuV2/54wqpr22t2XrEW4ffHP7cMejmKNWyC8CaCEwJY1WFUTxZwPVmkEx5j99SII2B6gpgw==
X-Received: by 2002:a65:4941:: with SMTP id q1mr5794314pgs.123.1639801359707;
        Fri, 17 Dec 2021 20:22:39 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id j8sm11908238pfc.8.2021.12.17.20.22.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:22:39 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] README: Remove stray '@' from mailing list email
Date: Fri, 17 Dec 2021 20:21:50 -0800
Message-Id: <20211218042150.115073-1-ossama.othman@intel.com>
X-Mailer: git-send-email 2.32.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 README | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/README b/README
index f02f767..99207e3 100644
--- a/README
+++ b/README
@@ -49,7 +49,7 @@ Information
 ===========
 
 Mailing list:
-	ell@@lists.linux.dev
+	ell@lists.linux.dev
 
 IRC:
 	irc://irc.oftc.net/#ell
-- 
2.32.0

